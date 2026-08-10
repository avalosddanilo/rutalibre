# Ruta Libre

App móvil de transporte público para el Gran Resistencia (Chaco, Argentina).
Objetivo: MVP superior a las soluciones gubernamentales actuales — carga
instantánea, UX limpia sin publicidad, arquitectura impecable.

## Stack (decidido — no reabrir sin una razón fuerte)

- **Flutter** + **Riverpod 3** (providers manuales, SIN codegen: no usar
  riverpod_annotation/build_runner; migrar después es mecánico)
- **Supabase** (Postgres + PostGIS), consumo con anon key + RLS de solo lectura
- **flutter_map + OpenStreetMap** (gratis, sin API key; migrable a Mapbox sin
  tocar domain ni data)
- go_router, fpdart (`Either`), equatable, shared_preferences (cache local),
  geolocator (solo presentation), mocktail (solo tests, sin codegen)

## Reglas de arquitectura (no negociables)

- Clean Architecture **feature-first**: `presentation → domain ← data`.
- `lib/features/transit/domain/` es **Dart puro**: no importa Flutter, Supabase,
  flutter_map ni geolocator. Es lo que lo hace testeable.
- Todo usecase y método de repositorio devuelve
  `Result<T> = Future<Either<Failure, T>>` (`core/utils/result.dart`).
  Los errores son valores; nada lanza excepciones hacia presentation.
- Correspondencia 1:1 entre jerarquías sealed: los datasources lanzan
  `AppException` (`ServerException`, `CacheException`, `NetworkException`,
  `ParsingException`); `TransitRepositoryImpl._toFailure` las convierte a
  `Failure` (`ServerFailure`, `CacheFailure`, `NetworkFailure`,
  `DataParsingFailure`).
- **Cache-first** para datos estáticos (líneas, recorridos, paradas, horarios):
  cache → si no vacía, respuesta al instante; miss/corrupción → red → cachear.
  `getNearbyStops` va SIEMPRE a red (depende de la posición del usuario).
- En presentation: `Either → AsyncValue` con `result.fold((f) => throw f, (v) => v)`;
  la UI traduce errores a texto en UN solo lugar:
  `presentation/utils/failure_message.dart` (futuro punto de i18n). Cubre
  Failures del dominio Y los `LocationError` de geolocalización.
- La geolocalización es una preocupación del DISPOSITIVO, no del dominio:
  geolocator vive envuelto en `LocationService`
  (`presentation/providers/location_providers.dart`) y nunca cruza a domain.
- Decidir qué `DayType` es "hoy" (feriados incluidos) es responsabilidad de
  presentation: `presentation/utils/day_type_resolver.dart` (computus + fijos;
  los trasladables NO — el usuario cambia el día a mano en la UI).
- **El código de línea es único POR RED, no globalmente**: existe la tabla
  `networks` y `lines.network_id`. Corrientes capital puede tener su propia
  "línea 3" sin chocar con la del Gran Resistencia.
- **"3A" NO es una línea**: es el ramal A de la línea 3. El pasajero piensa
  en "la 3"; ramal (`route_variants.branch`) y sentido son atributos del
  RECORRIDO. Por eso 73 recorridos se agrupan en 22 líneas.
- **…salvo cruzando el puente, donde el ramal SÍ es la línea**
  (`lineIdentityFor`). Misma razón que sostiene la regla de arriba: lo que
  el pasajero tiene en la cabeza. Nadie espera "la 904" — espera *el
  directo* (904B, por Avenida Sarmiento) o *el que va por Barranqueras*
  (904C), que son servicios distintos con otro recorrido y otra duración.
  Cuál es cuál se VERIFICÓ contra el callejero, no se supuso: el 904B tiene
  117 de 487 vértices sobre Avenida Sarmiento y pasa a 5,4 km de
  Barranqueras; el 904C tiene cero sobre esa avenida y pasa a 450 m.
  **Después apareció el papel y dijo lo mismo**: el recorrido oficial de
  ERSA publicado por la Nación rotula B "por AVENIDA SARMIENTO" y C "por
  BARRANQUERAS" (ver `docs/frecuencias-oficiales.md`). Ojo: ese mismo PDF
  rotula A "por BARRANQUERAS" y su itinerario no pasa por ahí — es un
  copiar-pegar. Le creemos al itinerario, no a la etiqueta.
- **`lines.destinations` existe porque `lines.name` miente por omisión**: el
  nombre entra en un renglón y desde el tercer destino dice "y N más". La
  línea 3 termina en el Shopping Sarmiento y buscar "Sarmiento" no la
  encontraba. Truncar es decisión de PANTALLA; la base guarda la lista
  entera y el buscador la mira.
- `RouteAtStop` es un **modelo de lectura** (no una entidad del dominio con
  identidad): aplana línea + recorrido para responder "¿qué colectivos
  pasan por acá?" en una sola consulta. No se reusa `BusLine` porque ese
  RPC no trae la red y una entidad con campos nullables "según de dónde
  venga" miente sobre lo que garantiza.
- **`tools/` no depende de `lib/` ni al revés.** El importador de OSM es un
  CLI de Dart puro que emite SQL; la app no lo importa nunca.
- Dos features hermanos: `transit` y `weather`. El segundo es el molde de
  cómo entra uno nuevo — sus propias capas, su propio datasource
  (Open-Meteo), y transit lo consume SOLO desde presentation
  (`RainChip`). En Fase 2, `crowdsourcing/` entra igual. **No crear
  carpetas vacías "por si acaso".**
- **El pronóstico también es cache-first, pero con VENCIMIENTO** — es el
  único dato de la app que caduca. Dos ventanas y son dos preguntas
  distintas: `freshness` (45 min) contesta "¿vale la pena volver a pedirlo?"
  y dentro de ella NO se sale a la red; `staleButUsable` (6 h) contesta
  "¿esto todavía dice algo cierto?" y solo se usa **cuando la red ya falló**.
  Existe porque el chip vive en la primera pantalla: sin esto se pedía un
  pronóstico por cada arranque en frío y el tier gratuito de Open-Meteo son
  10.000 llamadas por día. Se guarda **UNA sola entrada**, no una por punto:
  pedir otro punto pisa el anterior, porque a nadie le importa el pronóstico
  de la ciudad donde estuvo ayer y esto va a un archivo que se carga entero
  al arrancar. Lo verifica `weather_cache_test.dart` **contando los pedidos
  a la red**, que es exactamente lo que hay que garantizar.
- **Los LUGARES van en un asset empaquetado, no en la base ni en la cache.**
  Son 2612 nombres (~200 KB) que salen de OSM con
  `tools/places_import.dart`. Tres razones y ninguna es pereza: (a) meterlos
  en `SharedPreferences` los haría cargar ENTEROS en cada arranque, antes del
  primer cuadro, que es justo el costo que `docs/arranque.md` marca como el
  riesgo a no empeorar; como asset se leen recién al abrir el buscador de
  destino; (b) andan desde la instalación y sin señal, sin depender de que
  la cache se haya llenado antes; (c) no obligan a correr una migración a
  mano para que la función exista. El costo es que actualizarlos pide
  publicar una versión — se banca, un hospital no se muda. **La tarifa SÍ
  cambia seguido y por eso está en código con su fecha**, que es un problema
  distinto con otra solución.
- **El buscador de destino mezcla lugares y paradas en UNA lista**, no en dos
  pestañas: pestañas obligarían a adivinar de antemano si lo que uno busca
  "es un lugar" o "es una parada", que es exactamente lo que el usuario no
  sabe ni tiene por qué saber. El orden lo decide `destination_search.dart`
  y a igualdad de match **el lugar le gana a la parada** — quien escribe
  "perrando" quiere el hospital, no la parada que alguien bautizó igual.
- **La tipografía es Inter VARIABLE y va empaquetada**, no por
  `google_fonts`: ese paquete la baja por red la primera vez y hasta que
  llega la app se ve con la fuente del sistema, lo que rompe la promesa de
  abrir bien sin señal. Que la variable aplique de verdad el eje `wght` se
  VERIFICÓ midiendo el ancho del mismo texto en w400 y w700 (192,5 vs 198,4
  px): con una variable mal declarada los pesos se ven todos iguales y no
  hay forma de notarlo leyendo el código.
- **`clockProvider` y `sharedPreferencesProvider` viven en `core/providers/`,
  no en un feature**: los usan los dos features —transit para la próxima
  salida y su cache de líneas; weather para si llueve ahora y la cache del
  pronóstico—. Dos relojes distintos se desincronizarían en los tests, y
  tener las preferencias colgadas de transit obligaba a weather a importar
  del feature hermano, que es justo la dependencia que no queremos.
- **El aviso de lluvia es una ADVERTENCIA DE SERVICIO, no el parte del
  tiempo**: "va a llover en 4 horas" ya está en otras cinco apps del
  teléfono; lo que nadie contesta es qué le pasa al colectivo. El texto
  habla de lo que SUELE pasar, nunca de lo que está pasando —no tenemos
  cuántas unidades hay, ese es el dato de la Fase 2— y el reclamo se GRADÚA
  con la intensidad (`RainIntensity`): una llovizna no afirma que haya menos
  coches. Lo verifica `rain_forecast_test.dart`, que chequea que el texto no
  contenga NINGÚN número. La lectura "lluvia → menos servicio" es de
  PRODUCTO y vive en `presentation/utils/rain_advisory.dart`; el dominio del
  clima no sabe que existen los colectivos.
- **En el chip conviven un DATO y una ADVERTENCIA, y por eso son campos
  separados de `RainAdvisory`**: el porcentaje sale tal cual de Open-Meteo y
  se puede mostrar como número; la frase sobre el servicio es una
  generalidad. Mezclarlos en un párrafo sería prestarle al segundo la
  credibilidad del primero. La probabilidad y la intensidad salen de la
  MISMA `RainHour` (por eso `hourAt`/`wettestHour` devuelven la hora y no la
  intensidad): si no, se puede terminar diciendo "llueve fuerte, 5%".
- **El aviso de lluvia vive SOLO en el chip del mapa** (`RainChip`, arriba a
  la izquierda, debajo de la marca). Estaba también en la hoja de "¿cómo
  llego?" y se sacó de ahí: la hoja llega al 70% de la pantalla y no tapa el
  chip, así que eran dos avisos del mismo hecho a treinta píxeles uno del
  otro. Va DEBAJO de la marca y no al lado porque ese renglón ya se lo pelea
  con el crédito de OSM, que por licencia tiene que verse entero. Cerrado es
  una píldora; abierto anima el radio a `AppTheme.radius`, porque una píldora
  de cuatro renglones se lee como un globo de historieta.
- La geometría de recorridos NO pasa por domain: se pide bajo demanda vía el
  RPC `get_route_geojson` desde `routeGeometryProvider` (presentation).
- Widgets privados de una pantalla se gradúan a `presentation/widgets/`
  cuando dejan de ser triviales (ej: `LineSelector`).
- **Lo visual compartido vive en `app/`, no en un feature**: `theme/motion.dart`
  (duraciones y curvas), `widgets/floating_panel.dart` (lo que flota sobre el
  mapa) y `widgets/staggered_in.dart` (entrada de listas). Transit y weather
  se dibujan sobre el mismo mapa: dos tarjetas con radios y sombras distintas
  se leen como dos apps pegadas.
- **Las animaciones se escriben a mano, sin paquete.** Todo lo que hace falta
  son `AnimatedSize`, `AnimatedSwitcher`, `AnimatedScale` y un
  `TweenAnimationBuilder` con retardo (30 líneas). Un paquete de animaciones
  se sigue de por vida para eso.
- **"¿A dónde vas?" es lo primero del panel de abajo, no un botón flotante.**
  Era uno más en una columna de cinco, del mismo tamaño que "encuadrar el
  recorrido" — y es lo único que contesta la pregunta con la que uno abre la
  app. En el mapa quedó solo la salida del modo, y solo mientras el modo está
  activo.
- **El planificador de viajes vive en el SQL, no en Dart** (RPC `plan_trip`,
  migración 0004): cruzar `route_stops` consigo mismo para encontrar
  directos y transbordos es exactamente lo que Postgres hace gratis y el
  teléfono no. Ver `docs/planificador.md` — incluye POR QUÉ hay transbordos
  (sin ellos la función contestaría "no hay" 6 de cada 10 veces) y por qué
  no hay dos.
- **El buscador de destino trabaja sobre una COPIA LOCAL de las paradas**
  (`allStopsProvider` + RPC `get_all_stops`, migración 0008). Filtrar por
  texto en el servidor sería un viaje a la red por tecla y dejaría el
  buscador inservible arriba del colectivo sin señal — que es exactamente
  dónde se usa. Por eso el filtrado vive en presentation (`search_text.dart`)
  y el usecase no filtra nada.
- **"A cuánto llego caminando" es dominio, no pantalla**: la velocidad de
  caminata y el factor de rodeo (`WalkEstimate`) son decisiones de PRODUCTO
  y las va a necesitar más de una pantalla. La cuenta es Dart puro con su
  propio haversine —el dominio no importa latlong2— y el origen sale de
  `walkOriginProvider`, que NUNCA pide permiso: usa la posición de "cerca
  mío" si está, si no la última que tenga guardada el sistema, y si no hay,
  la fila no se dibuja.
- **Cuántas paradas se DIBUJAN es presentation, cuántas se PIDEN es dominio.**
  El descongestionado por zoom vive en
  `presentation/utils/marker_declutter.dart` (regla de píxeles, no de datos);
  el tope de "cerca mío" vive en `GetNearbyStopsParams.maxResults` porque
  "las N más cercanas" es una regla del dominio.

## Cómo levantar el proyecto

```bash
# 1. Dependencias
flutter pub get

# 2. Claves (env.json está en .gitignore — NUNCA se commitea)
#    Formato: {"SUPABASE_URL": "...", "SUPABASE_ANON_KEY": "..."}

# 3. Base de datos: en Supabase Dashboard → SQL Editor, correr EN ORDEN:
#    supabase/migrations/0001_initial_schema.sql   OJO: DROP/CREATE, solo base nueva
#    supabase/migrations/0002_stop_rpcs.sql
#    supabase/migrations/0003_networks_branches_osm.sql
#    supabase/migrations/0004_trip_planner.sql          (planificador de viajes)
#    supabase/migrations/0005_trip_planner_by_line.sql  (reemplaza sus funciones)
#    supabase/migrations/0006_spatial_ref_sys_rls.sql   (aviso del linter, opcional)
#    supabase/migrations/0007_function_search_path.sql  (endurece nuestras funciones)
#    supabase/migrations/0008_all_stops.sql             (buscador de destino)
#    supabase/migrations/0009_line_destinations_and_networks.sql
#                                        (destinos buscables + parte el interurbano)
#    supabase/migrations/0010_stop_osm_node_id.sql
#                                        (el nodo de OSM llega al cliente:
#                                         habilita "corregí esta parada")
#    supabase/seed/seed_gran_resistencia.sql       (datos REALES, ~815 KB)
#    supabase/seed/seed_corrientes.sql             (Corrientes capital)
#    supabase/seed/seed_horarios.sql               (DESPUÉS de los recorridos)

# 4. Correr — SIEMPRE con las claves:
flutter run --dart-define-from-file=env.json

# 5. Antes de commitear:
flutter analyze && flutter test
```

## Gotchas conocidos (aprendidos a los golpes — no repetir)

- **Riverpod 3**: `valueOrNull` NO existe — es `.value` (que ahora devuelve
  null en vez de tirar). `StateProvider` es legacy: usar `Notifier`.
- **Riverpod 3 AUTO-REINTENTA los providers fallidos** (10 veces, backoff
  hasta ~38 s) y durante la ventana emite `AsyncLoading(error:, retrying:)`
  con `isLoading` E `hasError` a la vez. Dos consecuencias cableadas acá:
  (1) el `ProviderScope` de main.dart tiene `retry:` que NO reintenta
  `Failure`s (son valores deterministas del dominio); (2) para detectar
  "pasó a error" en un `ref.listen` usar la transición
  `!next.isLoading && next.hasError && (previous?.isLoading ?? true)` —
  chequear `previous.hasError` la vuelve inalcanzable
  (ver `_becameError` en map_screen.dart).
- **nearbyStopsProvider es el ÚNICO family autoDispose**: la regla "nearby
  siempre a red" aplica también a la cache en memoria de Riverpod, y evita
  cachear errores para siempre y acumular una entrada por fix de GPS. Los
  demás FutureProviders son cache en memoria a propósito (datos estáticos).
- **supabase_flutter 2.16+**: `Supabase.initialize` usa `publishableKey:`
  (no `anonKey:`, que es la API vieja).
- **El cartel, el parabrisas y el hueco de las ruedas de la marca son
  AGUJEROS** (`PathFillType.evenOdd`), no manchas de otro color. La capa
  monocroma de Android 13+ conserva solo el alfa: cualquier detalle hecho con
  color desaparece ahí y el colectivo quedaría un bloque liso. Las ruedas van
  en un `drawPath` APARTE por lo mismo al revés — sumadas al path `evenOdd`,
  la parte donde pisan la carrocería se cancelaría y quedaría un mordisco.
- **Las escalas de los assets de marca se calculan contra un CÍRCULO**, no
  contra el cuadrado: eso recortan el ícono adaptable y el splash de Android
  12+. Y el splash necesita la suya propia, más grande que la del ícono
  adaptable, porque no tiene parallax. Reusar una para el otro es lo que
  dejaba la marca chiquita al abrir la app.
- **El ícono se GENERA desde `BrandMarkPainter`**, no es un PNG dibujado
  aparte: `REGEN_BRAND=1 flutter test test/brand/brand_assets_test.dart` →
  `dart run flutter_launcher_icons` → `dart run flutter_native_splash:create`.
  Así la marca de adentro de la app y la del launcher no pueden divergir.
  Los PNG de `assets/branding/` NO se declaran en `flutter: assets:` a
  propósito: los leen los generadores en tiempo de build y la app nunca los
  abre.
- **Capturar un PNG dentro de `testWidgets` necesita `tester.runAsync`**:
  rasterizar y codificar lo hace el engine FUERA del reloj falso de los
  tests, así que sin `runAsync` el `await` de `toImage()` no vuelve nunca y
  el test se cuelga hasta el timeout. (`Picture.toImage()` a secas no
  funciona ni con eso: hay que capturar desde un `RepaintBoundary` ya
  pumpeado.)
- **Las migraciones se corren A MANO en el editor de Supabase, así que no
  pueden asumir el orden.** Una que nombra la firma exacta de una función
  explota con "function does not exist" en cualquier base donde falte una
  migración anterior. Pasó con la 0007: listaba la firma de 5 argumentos de
  `trip_leg_json` que crea la 0005. Ahora busca en `pg_proc` la firma que
  HAY. Cuando una migración toca objetos que creó otra, conviene que sea
  idempotente y tolerante a que falten.
- **Toda función nueva lleva `set search_path = public`** (migración 0007).
  Sin eso, los nombres SIN CALIFICAR se resuelven con el search_path de
  quien llama: nuestros cuerpos califican las tablas pero NO las funciones
  de PostGIS (`st_distance`, `st_point`…), así que un llamador podría
  anteponer un esquema con su propia `st_distance`. Es el CVE-2018-1058.
  Se fija en `public` y no en `''` porque PostGIS vive ahí; `pg_temp` NO se
  nombra (nombrarlo lo vuelve buscable y una tabla temporal puede tapar a
  una real).
- **Los avisos del linter de Supabase sobre PostGIS NO son nuestros y no se
  arreglan. Ya se intentó.** Quedan (y van a quedar): `spatial_ref_sys` sin
  RLS, `Extension in Public: postgis`, y `st_estimatedextent` como SECURITY
  DEFINER ×6. Los trae `create extension postgis` (migración 0001).
  `spatial_ref_sys` es el catálogo EPSG — la misma data que el registro
  publica abierta, cero datos de usuario. La 0006 intenta habilitarle RLS y
  **se comprobó que NO se puede**: en Supabase hosted la tabla es de otro
  rol (`select relrowsecurity from pg_class where relname='spatial_ref_sys'`
  → false). NO sacar PostGIS del esquema `public` para callar esto: es la
  otra salida y sí puede romper cosas.
- **Una línea sin recorridos activos es un callejón sin salida**, igual que
  una parada sin líneas: aparece en el listado y al tocarla no pasa nada. Se
  vio en la base real — al partir el 904 en tres servicios, la línea `904`
  original quedó activa con CERO recorridos. Lo limpia la sección 6 del seed,
  acotada a las redes de ese import.
- **La cache vive en SharedPreferences y eso se carga ENTERO al arrancar**:
  hoy `all_stops` son ~267 KB y puede llegar a ~700 KB con uso. No se notó
  todavía; cuando se note, el reemplazo es sqflite cambiando SOLO
  `SharedPrefsTransitLocalDataSource`. Medición y propuesta en
  `docs/arranque.md`.
- **"Unused Index" en una base recién cargada es RUIDO**: sin tráfico las
  estadísticas están vacías y TODOS los índices figuran sin usar.
  `route_variants_line_id_idx` y `lines_network_id_idx` los usa la app en
  cada arranque. No borrarlos por ese aviso.
- **postgrest-dart ordena DESCENDENTE por default** → todo `.order(...)` lleva
  `ascending: true` explícito.
- **PostgREST devuelve geometry/geography como WKB hexadecimal** → nunca hacer
  select de `geom` directo; usar los RPCs (`get_route_geojson`,
  `get_stops_for_route`, `get_nearby_stops` — estos dos últimos definidos en la
  migración 0002, que reemplaza al `get_nearby_stops` de la 0001).
- **flutter_map >= 6**: API `initialCenter` y `Marker.child`. Encuadre:
  `MapController.fitCamera(CameraFit.coordinates(...))`. El controller se
  crea y disposea en el State de la pantalla.
- **Tiles OSM**: requieren `userAgentPackageName` (= applicationId real:
  `com.rutalibre.rutalibre`) y el crédito "© OpenStreetMap contributors"
  visible sobre el mapa (obligación de licencia). Requieren red la primera
  vez. Para producción, evaluar proveedor de tiles con SLA. En dark mode los
  tiles siguen claros — compromiso conocido del MVP.
- **Permiso INTERNET en Android**: el template de Flutter solo lo pone en
  debug/profile; el manifest de main lo declara explícito o el build de
  RELEASE no tiene red.
- **Los RPCs devuelven lat/lng como `num`**: puede llegar int (ej: -27) —
  castear con `as num` y `.toDouble()`, nunca `as double` directo.
- **Todo lo que se guarda en el teléfono va con VERSIÓN en la clave.** **Si
  cambia el JSON de algún modelo, SUBIR EL NÚMERO** — si no, quien actualiza
  queda con datos viejos que solo se salvan porque el parseo falla y cae por
  la rama de "corrupto". Las claves que hay hoy, verificadas contra el código:

  | Prefijo | Dónde | Qué guarda |
  |---|---|---|
  | `ruta_libre_cache_v4` | `SharedPrefsTransitLocalDataSource` | Líneas, recorridos, paradas y horarios |
  | `ruta_libre_weather_v1` | `SharedPrefsWeatherLocalDataSource` | El pronóstico y el punto para el que se pidió |
  | `ruta_libre_fav_lines_v1` | `UserPrefsStore` | Líneas favoritas |
  | `ruta_libre_fav_stops_v1` | `UserPrefsStore` | Paradas favoritas |
  | `ruta_libre_recent_dest_v1` | `UserPrefsStore` | Los últimos 8 destinos |

  Esta tabla ya se desincronizó una vez —decía `v2` cuando el código iba por
  `v4`—, así que al tocar una clave se toca acá. **Y también en
  `docs/politica-de-privacidad.md`**, que le promete al usuario exactamente
  qué se guarda: agregar algo al teléfono sin actualizarla convierte esa
  promesa en mentira.

  Si la cache crece, el reemplazo es drift/sqflite cambiando solo esa clase.
- **Los horarios NO tienen fuente abierta y se transcriben a mano**, pero
  igual pasan por un generador: `supabase/seed/horarios/*.txt` (revisable
  contra la foto de la empresa) → `tools/schedules_import.dart` → SQL. El
  parser ABORTA ante cualquier cosa rara en vez de adivinar: un horario
  inventado manda a alguien a esperar un colectivo que no viene.
- **Los datos reales se generan, no se escriben a mano**: `tools/osm_import.dart`
  produce `supabase/seed/seed_gran_resistencia.sql` (~800 KB) y
  `tools/corrientes_import.dart` produce `supabase/seed/seed_corrientes.sql`.
  Ver `docs/osm-import.md`. Esos archivos NO se editan: se regeneran.
- **Corrientes capital NO está en OSM** (las relations del lado correntino son
  micros de larga distancia): sale del portal municipal, en CSV y con la
  geometría PROYECTADA en Gauss-Krüger Faja 5. `tools/src/gauss_kruger.dart`
  la reproyecta. Es una conversión que falla EN SILENCIO si se rompe (dibuja
  en otro lugar del planeta) — por eso sus tests validan contra puntos de
  control reales (puerto y aeropuerto de Corrientes). No aflojar esos tests.
- **Parsear "IDA"/"VUELTA" necesita límite de palabra**: `endsWith('IDA')`
  matchea "MERIDA". Vale para los dos importadores.
- **OSM tiene errores de tagueo y hay que asumirlo**: existe una relation con
  `ref=207` cuyo nombre es "206 Vuelta ...". El importer confía en el `name`
  antes que en el `ref` y reporta la discrepancia.
- **`sharedPreferencesProvider` lanza UnimplementedError adrede**: se
  sobreescribe en `main.dart` con `overrideWithValue(prefs)`. Vive en
  `core/providers/`, no en transit.
- Bootstrap: `SharedPreferences.getInstance()` y `Supabase.initialize()` corren
  EN PARALELO (record `.wait`) — el arranque rápido es requisito del producto.
- `RouteVariant.direction`: enum `RouteDirection {outbound, inbound}` ↔
  smallint 0/1 solo en `RouteVariantModel`. `Schedule.departureTime` es
  `Duration` desde medianoche ↔ `time` Postgres solo en `ScheduleModel`.
- **Encuadre automático del trazado**: dos `ref.listen` complementarios en
  map_screen (fin de carga de geometría + cambio de selección con geometría
  ya cacheada). Tocar uno sin el otro rompe uno de los dos caminos.
- **Los marcadores se descongestionan por ZOOM, no por pan**: `worldPixels`
  proyecta a píxeles ABSOLUTOS del mundo justo para eso. Si el cálculo fuera
  relativo al viewport, las paradas aparecerían y desaparecerían al arrastrar
  el mapa. `_RouteStopMarkers` / `_NearbyStopMarkers` / `_AllStopMarkers` son
  widgets propios porque `MapCamera.of(context)` solo existe dentro de un
  `FlutterMap` y así se redibuja esa capa sola.
- **Primero se descongestiona, DESPUÉS se recorta al viewport.** Solo pasa en
  `_AllStopMarkers`, que es la única capa que compite con las 1416 paradas.
  Al revés —recortar y después descongestionar— el conjunto que compite por
  cada lugar cambiaría con el pan y las paradas parpadearían, que es
  exactamente lo que `worldPixels` existe para evitar. El recorte igual hace
  falta: acercando el mapa entran casi todas.
- **El pin necesita `alignment: Alignment.topCenter` en el `Marker`**: esa
  alineación deja el widget entero POR ARRIBA de la coordenada, que es lo que
  hace que la PUNTA apoye en la parada. Con el default (`center`) el pin
  queda medio cuadro más abajo de donde señala. El `StopDot`, en cambio, SÍ
  va centrado: un punto no señala, está.
- **En "cerca mío" hay UNA protagonista y el resto son alternativas**: pin
  para una, `StopDot` para las demás. Doce pines iguales se leen como doce
  alertas y no dicen nada. Con una parada elegida
  (`selectedStopProvider`) quedan solo sus 4 vecinas.
- **Ningún color de `marker_colors.dart` puede estar en `linePalette`**
  (`tools/src/line_palette.dart`). Los colores de línea salen de un hash del
  código, así que un color compartido significa que TARDE O TEMPRANO una
  línea cae en él y sus paradas se vuelven indistinguibles de las de "cerca
  mío". Ya pasó con `#00695C`. Lo verifica `marker_colors_test.dart`, que es
  el único test que cruza `lib/` con `tools/` — el invariante vive justo en
  el medio de los dos.
- **`selectedStopProvider` se limpia tocando el mapa** (`MapOptions.onTap`),
  eligiendo otra parada o apagando "cerca mío". Sin esa salida, elegir una
  parada escondía el resto para siempre. Los marcadores absorben su propio
  toque, así que el `onTap` del mapa solo dispara en el mapa vacío.
- **Bajar el panel va ANTES de encuadrar**: `_fitRoute` calcula el aire de
  abajo con lo que el panel ocupa EN ESE MOMENTO, así que encuadrar mientras
  el panel todavía está arriba deja el trazado apretado contra el borde. Por
  eso `_revealRoute` espera el `collapse()` — y por eso el controller del
  panel vive en `lineSheetControllerProvider` y no en el State de LineSheet:
  quien lo baja es el mapa, no el panel.
- **Qué paradas tiene un recorrido NO se le puede preguntar solo a OSM.** La
  relation lista los nodos que el mapeador se acordó de agregar, y eso es
  depender de un trabajo repetitivo hecho miles de veces sin saltear
  ninguno. No pasó: en Avenida San Martín y Laprida figuraba SOLO el 207,
  cuando ahí frenan también el 110, el 204, el 206, el 101 y el 106. Por eso
  el importer además ADOPTA toda parada ya mapeada que el trazado pase a
  menos de 25 m **dejándola a su derecha** (2638 inferidas contra 3261
  declaradas). El lado no es un refinamiento: sin él, en una avenida de
  doble mano cada recorrido se lleva las paradas del que va en contramano.
  De ahí sale `Projection.sideMeters`. **No inventa paradas**: solo usa
  nodos que ya existen en OSM.
- **La unificación global de paradas ve los CANDIDATOS, no los
  sobrevivientes.** El colapsado por recorrido descarta uno de los dos nodos
  de una parada, y el nombre suele estar en la plataforma y el código de la
  concesionaria en la posición de detención. Si la unificación mirara solo
  lo que sobrevivió al colapsado, perdería la mitad de la información. Se
  rompió una vez al agregar la inferencia y lo agarró un test.
- **Una parada física puede ser DOS nodos de OSM** (`stop_position` sobre la
  calzada + `platform` en la vereda). El colapsado por recorrido no alcanza
  cuando dos líneas usan cada una un nodo distinto: por eso existe el pase
  global de `tools/src/stop_merge.dart`. Sus radios son chicos a propósito —
  unir dos paradas ENFRENTADAS sería peor que dejarlas duplicadas.

## Estado actual (2026-08-05)

**Datos REALES cargados**: 20 líneas, 73 recorridos y 1416 paradas del Gran
Resistencia importadas de OpenStreetMap. Se acabó el seed mock.

Hecho: core (errores, Result, UseCase), entidades + red y ramal, contrato
TransitRepository + 6 usecases, capa data completa (remote Supabase + cache
SharedPreferences v2 + repo cache-first), DI con Riverpod, importador de OSM
(`tools/`) con su SQL generado y unificación de paradas duplicadas, MapScreen
(mapa OSM, trazado con halo, paradas como pines tocables con descongestionado
por zoom y cabeceras marcadas, capa de fondo con TODAS las paradas —el mapa ya
no arranca vacío ni exige el GPS—, encuadre automático, crédito OSM, modo
"cerca mío" con GPS), LineSheet (bottom sheet con buscador sin tildes y líneas
agrupadas por red y colapso automático al elegir un recorrido),
StopDetailsSheet ("qué líneas pasan por acá") con "a cuánto llego caminando",, buscador de destino sobre la
copia local de las paradas, botón "¿cómo llego acá?" en el detalle de parada,
compartir el viaje, NearbyStopsSheet (con
distancia real), SchedulesScreen (tipos de día con feriados por computus,
próxima salida que se refresca por minuto), aviso por lluvia (Open-Meteo, sin
API key), dark mode, marca propia —un
colectivo de frente— dibujada en código (`lib/app/theme/brand.dart`) de donde
salen ícono y splash, SQL (0001 a 0009), suite de 426 tests, permisos
Android/iOS.

✅ **Base al día (2026-08-05)**: aplicadas 0001→0009 y los tres seeds.
Verificado: 1474 paradas, 32 líneas, 133 recorridos, 5287 asignaciones
parada↔recorrido, 72 salidas, 22 líneas con destinos, 4 redes.

**Lo que falta y NO depende de nosotros: los horarios.** Ninguna fuente
pública los publica. Ver `docs/propuesta-datos-abiertos.md` — el pedido
concreto a la Secretaría de Transporte (GTFS estático + GTFS-RT).

Este repo es la fuente de verdad del código. El histórico de decisiones vive
en las notas del proyecto.

## Publicar la v1.0

Ver `docs/publicacion.md` (checklist completo con los pasos exactos del
keystore y del AAB), `CHANGELOG.md` y `docs/politica-de-privacidad.md`.
Lo que queda del lado de dani: generar el keystore, armar `key.properties`,
publicar la política en una URL y probar el APK de release en el teléfono.

## Pendientes (próximos PRs, en orden sugerido)

0. ⚠️ **Verificar el TRANSBORDO de `plan_trip`.** El camino directo ya está
   probado contra la base (Plaza 25 de Mayo → UNNE: `leg_count 1`, 122 m +
   128 m). El de transbordo no, y es el 46% de los viajes. Las consultas
   están al final de `docs/planificador.md`; lo que hay que mirar es que la
   parada de bajada del tramo 1 sea IDÉNTICA a la de subida del tramo 2.
1. **Horarios**: sigue sin fuente pública, pero ya hay puente — se
   transcriben a mano en `supabase/seed/horarios/*.txt` y
   `tools/schedules_import.dart` emite el SQL (ver `docs/horarios.md`).
   Cargada la 904A (Terminal Rcia ↔ Campus UNNE Ctes), **sin verificar
   contra la empresa**. Falta: verificarla, cargar más líneas, y el pedido
   de GTFS (ver `docs/propuesta-datos-abiertos.md`), que es el camino real.
   **Lo único oficial que SÍ apareció son FRECUENCIAS, no horas**: el pliego
   que rige el permiso del 904 (Anexo II de la Res. 141/2017, vigente por la
   adjudicación a ERSA de la Res. 113/2018) fija bandas de intervalo por
   ramal. Está en `docs/frecuencias-oficiales.md`, con las tres erratas que
   trae el original. **No se convierte en `schedules`** —una banda dice cada
   cuánto, nunca a qué hora— pero sirve para contestar "¿cada cuánto pasa?"
   citando la fuente, y **ya se muestra**: `ServiceFrequency` (domain, tabla en
   código por la misma razón que `Fare`) + `FrequencyRow`, en la pantalla de
   horarios —arriba de la lista, para que se vea cuando la lista está vacía— y
   como un dato más del resumen del viaje, solo en viajes DIRECTOS: con
   transbordo una banda suelta no dice de cuál de las dos líneas habla. Los cuadros horarios reales los aprueba la CNRT y no
   los publica: ese es el dato que falta, y existe.
   El cambio de esquema más valioso que queda es `route_stop_times`: hoy se
   guarda solo la salida de cabecera, y quien espera en una parada del medio
   necesita SU hora.
2. **Paradas de Corrientes capital**: hoy solo tiene trazados. El recurso de
   paradas fue dado de baja del portal municipal — hay que pedirlo.
   **Ojo con confundirlo**: los tres datasets "recorridos y paradas del
   interurbano" (Campus / Sarmiento / Barranqueras) del portal correntino
   SÍ traen paradas con coordenadas reales (117, en WGS84, no Gauss-Krüger),
   pero son los **ramales A/B/C del 904**, no las líneas urbanas de
   Corrientes. Medidos contra la base: 61 ya las tenemos (≤30 m), 26 caen en
   la banda ambigua de 30-80 m y solo 30 son nuevas. **No se importaron**, y
   la razón NO es el volumen: esos route_variants son del
   `seed_gran_resistencia.sql`, que en su sección 4 borra y reconstruye
   `route_stops`, y en la 5 desactiva las paradas sin recorrido. Todo lo que
   escriba un segundo seed sobre esas variantes se borra en la próxima
   corrida del primero. El camino correcto es alimentar los CSV al
   `osm_import.dart` como fuente adicional, para que el pase de
   `stop_merge.dart` y la reconstrucción queden en manos de un solo emisor.
3. **Paradas que ya no existen EN LA REALIDAD**: el pase de unificación y la
   baja de paradas sin recorrido limpian lo que se puede deducir de los
   datos, pero una parada que se levantó y OSM todavía tiene mapeada es
   indistinguible de una vigente. Dos caminos, ninguno automatizable:
   (a) ~~corregirlo en OSM y reimportar~~ — **el enlace ya está**:
   `OsmStopLink` abre `openstreetmap.org/node/<osm_node_id>` desde la hoja de
   la parada y desde la de Corrientes. Lo que queda es humano: alguien tiene
   que corregir OSM y después hay que **reimportar** (`dart run
   tools/osm_import.dart` y aplicar el seed nuevo), que sigue siendo a mano.
   Tres cosas del camino: el `osm_node_id` sale de los RPCs recién con la
   **migración 0010** —sin ella el enlace no aparece y la app se comporta
   como antes—; la **cache subió a v5** porque la de paradas nunca vence sola
   y el campo nuevo no llegaría jamás a un teléfono que ya abrió la app; y
   `url_launcher` volvió al pubspec (se había ido con el botón del 911).
   Las paradas de Corrientes llevan el nodo en el asset (`v: 2`), sin base de
   por medio;
   (b) reportes de usuarios, que es Fase 2. Sigue pendiente, y es lo que
   cierra el círculo sin depender de que el usuario tenga cuenta en OSM.
4. ~~**Tarifa**~~ — **hecho**. Ver `domain/entities/fare.dart`. Tres cosas que
   se aprendieron haciéndolo y conviene no re-descubrir:
   (a) el número que estaba anotado acá —"$1899 agosto 2026"— **era falso**:
   la tarifa del Gran Resistencia es **$1.885 desde enero de 2026** y no hubo
   aumento posterior verificable;
   (b) **el interurbano no tiene UNA tarifa**: Sarmiento y Barranqueras
   cobran $1.890 pero el ramal del Campus cobra **$2.921,10**, un 55% más,
   por eso existe la tabla de excepciones POR LÍNEA;
   (c) la tarifa **no va en la base** aunque parezca lo obvio: `getLines` es
   cache-first y nunca vuelve a la red, así que un precio actualizado en
   Supabase no le llegaría jamás a quien ya abrió la app.
   El precio SIEMPRE se dibuja con su fecha y su fuente al lado: un precio
   viejo sin fecha es peor que no tenerlo.
5. ~~**Favoritos y destinos recientes**~~ — **hecho**. Ver
   `presentation/providers/user_prefs_providers.dart`. Estrella en cada línea
   y en el detalle de parada; las favoritas se FIJAN arriba del panel y salen
   de su grupo de red (eso significa fijar); el buscador de destino abre con
   lo guardado y los últimos ocho en vez de un cartel. Nada sale del
   teléfono. **Ojo al tocar tests**: LineSheet y StopDetailsSheet ahora leen
   `sharedPreferencesProvider`, así que todo harness que los renderice tiene
   que sobreescribirlo.
6. ~~**Elegir el origen a mano**~~ — **hecho**. `PlaceSearchSheet` (era
   `DestinationSearchSheet`) elige las DOS puntas: el mismo buscador con otro
   título y otra acción al tocar un resultado. Cuatro cosas que conviene no
   re-descubrir:
   (a) el origen viaja con un **nombre opcional** (`originName` en
   `TripSearch`), y null significa "mi ubicación". Sin el nombre no se puede
   decir de dónde sale el viaje, y uno planificado desde el sillón se vería
   idéntico a uno del GPS;
   (b) `setOrigin` **conserva** el destino y `startFrom` lo **descarta**: son
   dos acciones distintas y confundirlas hace perder el destino ya buscado.
   Hay un test de cada una;
   (c) el buscador de origen NO ofrece "tocá el mapa". El planificador arranca
   desde las paradas cercanas, así que la esquina de al lado contesta lo mismo
   que el patio exacto, y un segundo modo de toque pediría otro banner y otro
   estado del sealed;
   (d) el GPS que falla ya no termina en un snackbar: abre este buscador. Vale
   para el CTA del panel y para "¿cómo llego acá?" del detalle de parada, que
   eran los dos lugares donde negar el permiso dejaba a la app sin contestar.
7. ~~**Avisar cuando los datos son guardados**~~ — **hecho**, y en el camino
   apareció algo peor que lo que se venía a arreglar: **la cache no se
   refrescaba NUNCA**. `_cacheFirst` devuelve lo guardado sin mirar la red, así
   que un recorrido corregido en la base no le llegaba a nadie que ya hubiera
   abierto la app hasta publicar una versión con la versión de la cache subida.
   Ahora hay dos cosas:
   (a) cada escritura de la cache deja una marca de cuándo fue
   (`TransitLocalDataSource.lastSyncedAt`), y el pie del panel de líneas dice
   "Datos guardados en el teléfono · hoy / ayer / 28/7/2026". No se intenta
   adivinar el estado de la red: eso pediría un plugin de conectividad para
   contestar algo que da igual —los datos están guardados, haya señal o no—;
   (b) `_cacheFirst` hace **stale-while-revalidate** con `cacheTtl` de 7 días:
   devuelve la copia al instante (el arranque no se negocia) y si está vieja
   dispara un refresco de fondo que no se await-ea y que se traga todos los
   errores. Sin marca de sincronización se considera FRESCA a propósito: no
   sabemos de cuándo es y salir a la red por las dudas sería una consulta que
   nadie pidió.
8. Feriados trasladables: tabla `holidays` en Supabase (reemplaza la lista
   fija de `day_type_resolver.dart` sin tocar pantallas).
9. Widget tests de MapScreen (requieren mockear tiles — evaluar
   `flutter_map` test harness o fake TileProvider).
10. CI (GitHub Actions: analyze + test en cada PR).
11. **Publicarla**: cuenta de desarrollador, capturas, ficha y política de
    privacidad (obligatoria, la app usa ubicación).

## Fases del producto

- **Fase 1 (actual)**: datos estáticos — trazados, paradas, horarios.
- **Fase 2**: GPS colaborativo tipo Waze o APIs de las empresas. Preparado:
  tabla `vehicle_reports(route_variant_id, geom, reported_at, user_id)` +
  Supabase Realtime. Nada del esquema actual cambia.
- **Fase 3**: panel B2B de gestión logística para las concesionarias.

## Flujo de trabajo

- Ramas: `main` protegida, trabajo en `feat/<nombre>` con PR (mientras no haya
  remoto, commits directos a main con mensajes convencionales).
- Commits convencionales: `feat:`, `fix:`, `chore:`, `test:`, `docs:`.
- Lints: `analysis_options.yaml` (flutter_lints + reglas extra).
  `flutter analyze` y `flutter test` limpios antes de cada commit.
