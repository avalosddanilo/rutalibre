# Auditoría de seguridad y robustez

Revisión **estática** del código, el esquema SQL y la configuración de build.
No se probó en un dispositivo ni se atacó la base real.

**Fecha**: 6 de agosto de 2026 · **Alcance**: `lib/`, `supabase/migrations/`,
`android/`, `ios/`, historial de git completo.

## Resumen

| Severidad | Hallazgos |
|---|---|
| 🔴 Alta | 0 |
| 🟠 Media | 1 — cuota (S4); S2 quedó verificado el 2026-09-18 |
| 🟡 Baja | 1 — sin caché persistente de tiles |
| ⚪ Informativo | 3 |
| ✅ Corregido | 4 |

**No se encontró ninguna credencial filtrada, ninguna vía de inyección, ni
ningún punto donde un dato remoto malformado tire la app.** Lo que queda por
verificar está del lado del dashboard de Supabase, que no se puede auditar
desde el repo.

---

# Seguridad

## ✅ S1 — Secretos: limpio

Se revisó el **historial completo de git**, no solo el árbol actual: se
recorrió cada blob de `git rev-list --all --objects` buscando JWTs
(`eyJhbGciOiJ`), claves de servicio (`service_role`, `sb_secret_`) y cadenas
de conexión de Postgres.

**Un solo resultado, y es un falso positivo**: el comentario de la línea 131
de `0001_initial_schema.sql` que dice *"La carga de datos se hace con la
service_role key"*. Es texto explicativo, no una clave.

`.gitignore` cubre lo que tiene que cubrir, y ninguno de esos archivos estuvo
nunca versionado:

| Archivo | En `.gitignore` | ¿Estuvo commiteado alguna vez? |
|---|---|---|
| `env.json` | ✔ | No |
| `android/key.properties` | ✔ | No |
| `*.jks`, `*.keystore` | ✔ | No |

`lib/core/config/env.dart` lee las claves con `String.fromEnvironment` **sin
valor por defecto**, así que no hay forma de que una clave quede hardcodeada
ahí sin que se vea.

### La anon key viaja dentro de la app, y está bien

Cualquiera puede extraerla de un APK con `unzip` y `strings` — no es una
falla, es cómo funciona el modelo de Supabase. **La anon key no es un
secreto: es un identificador público.** Lo que protege los datos es RLS, no
la clave. Por eso el punto siguiente es el que importa.

Lo que **sí** sería grave es publicar la `service_role` key, que bypassa RLS
por completo. No está en el repo y no tiene que estar nunca en la app.

> **Cómo verificar que la clave que usás es la anon y no la service_role**:
> pegá el JWT en jwt.io (o decodificá el payload en base64) y mirá el campo
> `"role"`. Tiene que decir `anon`. Si dice `service_role`, hay que rotarla
> **ya** desde Supabase → Settings → API.

## ✅ S2 — Superficie de ataque de Supabase: verificado en el dashboard (2026-09-18)

### Qué puede hacer alguien con la anon key

Con RLS **como está en las migraciones**:

- ✅ **Leer** líneas, recorridos, paradas, horarios y redes activas. Son datos
  públicos del transporte: que se lean no es un problema, es el objetivo.
- ✅ Llamar los RPCs (`get_nearby_stops`, `plan_trip`, etc.).
- ❌ **No** puede insertar, modificar ni borrar nada: no existen políticas de
  `INSERT`/`UPDATE`/`DELETE`, y sin política RLS deniega por defecto.
- ❌ **No** puede leer filas con `is_active = false`.

Lo que **sí** puede hacer y no lo impide ninguna policy es **consumir cuota**:
pedir `get_all_stops` en un bucle. Eso no filtra nada, pero puede agotar el
plan. Ver S4.

### Lo que el repo garantiza

Verificado leyendo las migraciones:

- Las **6 tablas** tienen RLS: `lines`, `route_variants`, `stops`,
  `route_stops`, `schedules` (migración 0001) y `networks` (0003).
- Las **6 políticas son `for select`**. No hay ninguna de escritura.
- Las **11 funciones son `security invoker`** — corren con los permisos de
  quien llama, así que RLS se aplica adentro. Si fueran `security definer`,
  cualquier RPC sería un agujero alrededor de RLS.
- La migración 0007 le pone `set search_path = public` a todas las funciones
  propias (CVE-2018-1058).

### Por qué hacía falta verificarlo, y qué se verificó

**Las migraciones se corren A MANO en el editor de Supabase.** El repo dice
cuál es la intención; no prueba cuál es el estado real de la base. Una
migración salteada, una policy tocada desde la UI o una tabla creada a mano
después no aparecerían acá.

**Corrido el 2026-09-18, las 5 verificaciones dieron lo esperado.** La que
prueba algo de verdad es la 4, porque no mira la configuración sino el
comportamiento: el `INSERT` con la anon key contra `stops` devolvió

```
HTTP 401
{"code":"42501", ... "message":"new row violates row-level security policy for table \"stops\""}
```

que es exactamente lo que tiene que pasar. Las otras tres confirmaron RLS
activo en las 6 tablas, las 6 policies en `SELECT` y ninguna función propia
en `security definer`.

**Esto vence.** Cada migración nueva corrida a mano puede cambiar el estado,
así que la verificación se repite después de tocar el esquema, no una vez
para siempre.

### Checklist para verificar en el dashboard

Correr en **Supabase → SQL Editor**. Son de solo lectura, no cambian nada.

**1. ¿Todas las tablas tienen RLS activado?**

```sql
select tablename, rowsecurity
  from pg_tables
 where schemaname = 'public'
 order by rowsecurity, tablename;
```

Esperado: las 6 tablas con `rowsecurity = true`.
`spatial_ref_sys` va a aparecer en `false` — **es de PostGIS, no nuestra, y
ya se comprobó que no se puede cambiar** (ver `ARCHITECTURE.md`). No es un
hallazgo.

**2. ¿Alguna policy permite escribir?**

```sql
select tablename, policyname, cmd, roles, qual, with_check
  from pg_policies
 where schemaname = 'public'
 order by tablename;
```

Esperado: **6 filas, todas con `cmd = 'SELECT'`**. Cualquier fila con
`INSERT`, `UPDATE`, `DELETE` o `ALL` es un hallazgo — borrala.

**3. ¿Alguna función bypassa RLS?**

```sql
select p.proname, p.prosecdef as es_security_definer, p.proconfig
  from pg_proc p
  join pg_namespace n on n.oid = p.pronamespace
 where n.nspname = 'public'
   and p.proname not like 'st\_%'
   and p.proname not like 'postgis%'
 order by p.prosecdef desc, p.proname;
```

Esperado: **todas con `es_security_definer = false`** y `proconfig` con
`{search_path=public}`. Las `st_*` de PostGIS sí son `security definer` y
**no se tocan** — vienen con la extensión.

**4. Probar el ataque, no solo mirar la config.** Es el único paso que
demuestra algo. Desde una terminal, con la **anon key** (no la de servicio):

```bash
curl -X POST "https://TU-PROYECTO.supabase.co/rest/v1/stops" -H "apikey: TU_ANON_KEY" -H "Authorization: Bearer TU_ANON_KEY" -H "Content-Type: application/json" -d '{"name":"prueba de intrusion","lat":0,"lng":0}'
```

Esperado: un error `42501` / *"new row violates row-level security policy"*.
**Si devuelve 201 y crea la fila, es una vulnerabilidad alta**: hay una policy
de escritura que no debería existir.

**5. Confirmar que la anon key es anon** — ver el recuadro de S1.

## ✅ S3 — Inyección: no hay superficie

- **Todas las consultas van parametrizadas.** El datasource usa el query
  builder (`.eq('line_id', lineId)`) o `params: {...}` en los RPCs. No hay
  una sola concatenación de string con input del usuario en todo `lib/`.
- **El buscador no consulta nada.** Filtra en memoria sobre la copia local de
  las paradas (`search_text.dart`). El texto que escribe el usuario **nunca
  llega al servidor**, así que no hay dónde inyectar. Es una decisión de
  producto —que ande sin señal— que además elimina la clase entera de bug.
- Los RPCs reciben parámetros **tipados** (`uuid`, `double precision`). Un
  string arbitrario donde va un uuid lo rechaza Postgres antes de ejecutar
  nada.
- No se usa `.or()`, `.filter()` ni `textSearch` con texto del usuario, que
  son las APIs de PostgREST donde sí se podría meter sintaxis.

## 🟠 S4 — Abuso de cuota (denegación de servicio por costo)

La anon key permite lecturas ilimitadas. Nadie puede robar ni romper datos,
pero sí puede **agotar el plan** pidiendo `get_all_stops` (~267 KB por
respuesta) en un bucle.

**No se arregla desde el código, y por eso sigue abierto.** Es configuración
del proyecto en Supabase: no hay nada que commitear, y ningún test lo puede
verificar. Queda anotado acá como **pendiente de configuración**.

### Qué hay que dejar configurado — **lo hacés vos, en el dashboard**

**1. Alerta de uso.** Es lo primero porque es lo que avisa antes de que
duela. Supabase → *Settings → Billing → Usage* (o *Reports*): poner una
alerta al **50% y al 80%** de la transferencia mensual del plan. Sin esto,
el primero en enterarse de un abuso es el resumen de la tarjeta.

**2. Rate limiting.** Supabase → *Authentication → Rate Limits* cubre auth,
que la app no usa. Para la API de datos el control real está en el **plan** y
en poner Cloudflare (u otro CDN) delante del dominio. En el plan gratuito no
hay una perilla de límite por IP: **asumir que no está** y compensarlo con la
alerta del punto 1.

**3. Si algún día escala.** Mover `get_all_stops` —que es la consulta cara,
~267 KB por respuesta— detrás de una Edge Function con caché, o servir ese
blob directamente desde un CDN. No hace falta antes de tener usuarios.

Hoy, con la app sin publicar, el riesgo es teórico. **El punto 1 conviene
dejarlo listo antes de publicar**; los otros dos, cuando haya tráfico real.

---

# Robustez

## ✅ R1 — Crash al arrancar sin claves — **CORREGIDO**

**Antes**: `main()` hacía `throw StateError` si faltaban las claves, y
`SharedPreferences.getInstance()` / `Supabase.initialize()` corrían sin
`try`. Cualquiera de las tres cosas dejaba la app **muerta en gris, sin una
línea de explicación en el teléfono**.

Es el escenario que `docs/publicacion.md` ya advertía: un AAB compilado sin
`--dart-define-from-file=env.json` **crashea al abrir**, y Google no lo
detecta — te enterás por las reseñas.

**Ahora**: las dos situaciones dibujan una pantalla de error legible con la
instrucción exacta. El camino feliz no cambió en nada.

La pantalla (`_StartupError`) es a propósito **sin tema, sin providers y sin
nada del resto de la app**: se dibuja justo cuando esa maquinaria puede no
estar disponible.

## ✅ R2 — El chip de lluvia multiplicaba los pedidos a Open-Meteo — **CORREGIDO**

Cuando el aviso vivía dentro de la hoja de "¿cómo llego?", se pedía el
pronóstico solo si alguien planificaba un viaje. **Ahora está en la pantalla
principal**, así que se pide en **cada arranque en frío**.

Cuentas del peor caso por usuario y por día: `forecastFreshness` son 20 min y
`coarsePoint` redondea a ~1 km, así que un usuario intenso puede generar
~72 pedidos diarios. El tier gratuito **no comercial** de Open-Meteo son
**10.000 llamadas por día**. Eso pone el techo alrededor de **140 usuarios
activos diarios** en el peor caso, bastante más con uso normal.

No es un problema hoy y no rompe nada cuando se agota —el chip simplemente no
aparece, que es exactamente la degradación que ya está probada— pero es un
límite que hay que tener anotado.

**Corregido**: el pronóstico ahora se persiste en `SharedPreferences` con su
timestamp (`WeatherLocalDataSource`), y el repositorio pasó a ser cache-first
con dos ventanas:

- **45 minutos** (`freshness`) — dentro de esa ventana **no se sale a la red**.
  Los modelos de Open-Meteo se actualizan cada 1-3 horas, así que no se pierde
  precisión. Un arranque en frío dentro de la ventana ya no cuesta un pedido.
- **6 horas** (`staleButUsable`) — solo si la red **falló**. Un pronóstico por
  hora de hace tres horas sigue cubriendo el rato que viene, y eso es mejor
  que no mostrar nada arriba del colectivo sin señal.

Efecto sobre el techo: el peor caso pasa de ~72 pedidos por usuario y día a
**~32**, y el caso realista —abrir la app unas cuantas veces salteadas— cae a
un puñado. El techo del tier gratuito sube de ~140 a **~300 usuarios activos
diarios** en el peor caso, y bastante más en la práctica.

De paso, **el chip ahora funciona sin señal**, que antes no pasaba.

Lo verifica `test/features/weather/weather_cache_test.dart` contando los
pedidos a la red, que es exactamente lo que este hallazgo era.

## ✅ R3 — Manejo de errores de red: completo

**Transit**: los **8 métodos** del datasource pasan por un único `_guard`,
que traduce `PostgrestException` → `ServerException`, `SocketException` y
`TimeoutException` → `NetworkException` (incluyendo el caso en que Supabase
envuelve el socket en otra excepción), cualquier otra cosa →
`ServerException`, y los errores de parseo → `ParsingException`.

**Weather**: mismo patrón, más un **timeout explícito de 8 s** que transit
delega en el cliente de Supabase.

El repositorio convierte todo eso a `Failure` y **nada llega a presentation
como excepción**.

## ✅ R4 — Datos malformados y respuestas vacías

- **Cache corrupta**: `jsonDecode` va dentro de `try`, y falla como
  `CacheException` → el repositorio va a la red. Un cambio de formato entre
  versiones degrada a "descargar de nuevo", no a crash.
- **Casts de `num`**: los RPCs devuelven `num` (puede llegar `int`), y el
  código castea `as num` + `.toDouble()`. Un `as double` directo sí
  explotaría; no hay ninguno.
- **Accesos a colecciones**: se revisaron los 10 usos de `.first` / `.last` /
  `.single` / `[0]` de `lib/`. Todos están guardados por un `isNotEmpty`
  previo, por una condición que lo garantiza, o adentro de un `try` que los
  convierte en `ParsingException`. `_NearbyStopMarkers` usa `stops.first`
  pero solo se construye bajo `if (nearbyStops.isNotEmpty)`.
- **Listas vacías**: cada pantalla tiene su estado vacío escrito (`_NoTrips`
  explica *por qué* puede no haber viaje, en vez de un cartel genérico).

## ✅ R5 — Permisos de ubicación

`LocationService` cubre el árbol completo: servicio apagado, permiso negado,
negado para siempre, y timeout del GPS **con caída a la última posición
conocida** antes de darse por vencido. Los cuatro casos son un `sealed
LocationError` que `failureMessage()` traduce con un `switch` **exhaustivo
sin comodín**: agregar un caso nuevo sin texto es un error de compilación.

`lastKnownPosition()` —la que alimenta el chip de lluvia y "a cuánto llego
caminando"— **nunca lanza y nunca pide permiso**: devuelve `null` y la fila
no se dibuja.

## ✅ R6 — `routeGeometryProvider` hacía casts sin red de contención — **CORREGIDO**

**Antes**: llamaba al RPC y casteaba el GeoJSON sin `try`, a diferencia del
resto de la capa de datos. Una respuesta con otra forma tiraba un `TypeError`.

Nunca crasheó la app —Riverpod lo atrapa y el mapa usa `.value ?? const []`,
así que el efecto era "el recorrido no se dibuja"—, pero el problema estaba en
el **tipo** del error: un `TypeError` no es un `Failure`, así que el `retry`
de `main.dart` no lo excluía y Riverpod lo **reintentaba 10 veces con backoff
(~38 s)** contra un servidor que iba a contestar lo mismo.

**Ahora** traduce a `Failure` como el resto: `PostgrestException` →
`ServerFailure`, socket y timeout → `NetworkFailure`, y cualquier otra cosa
—que en la práctica es siempre "la respuesta vino con otra forma"— →
`DataParsingFailure`. Se corta en el primer intento y la UI recibe un texto
legible en vez de un error crudo.

**Lo que sigue pendiente**: bajar esta consulta a la capa de datos con su
modelo y su `_guard`. Sigue siendo la única consulta que presentation hace
sola. Ya no es un problema de robustez, es de prolijidad.

## 🟡 R7 — Sin caché persistente de tiles del mapa

`flutter_map` usa el `NetworkTileProvider` por defecto: las imágenes del mapa
**no se guardan entre sesiones**. La app abre sin señal y muestra líneas,
paradas y horarios desde la cache, pero **el fondo del mapa queda gris**.

Es un límite conocido y no un bug, pero conviene no decir "funciona sin
conexión" a secas.

## ✅ R8 — `android:allowBackup` estaba en su valor por defecto (`true`) — **CORREGIDO**

El backup automático de Android podía copiar `SharedPreferences` —la cache de
datos de transporte y los favoritos— a Google Drive.

**No era un riesgo y sigue sin serlo**: ahí no hay nada del usuario, ni
cuentas, ni ubicaciones, ni historial de consultas. Son datos públicos que la
app vuelve a bajar sola. Se puso `android:allowBackup="false"` para **no
gastar cuota de backup ajena en ~700 KB de datos regenerables**, no para
proteger nada.

Va solo ese atributo: `allowBackup="false"` ya apaga el Auto Backup y el de
clave-valor, y agregar además `fullBackupContent` sería decir dos veces lo
mismo.

## ⚪ R9 — Sin ofuscación ni minificación (R8)

Deliberado y documentado en `android/app/build.gradle.kts`. Activar R8 sin
reglas propias es la forma clásica de romper en release algo que anda en
debug. **No es una medida de seguridad**: la anon key es pública igual y
ofuscar no la protege.

---

# Dependencias

`flutter pub outdated`: **todas las dependencias directas al día**. Las
transitivas que figuran atrasadas (`analyzer`, `meta`, `vector_math`…) están
fijadas por el SDK de Flutter y no se pueden mover sin cambiar de SDK.

| Paquete | Rol |
|---|---|
| `supabase_flutter` ^2.16.0 | Cliente de la base |
| `flutter_map` ^8.3.1 | Mapa |
| `geolocator` ^14.0.3 | Ubicación |
| `shared_preferences` ^2.5.5 | Cache local |
| `share_plus` ^13.3.0 | Compartir viaje |
| `http` ^1.6.0 | Open-Meteo |
| `go_router`, `fpdart`, `equatable`, `latlong2`, `flutter_riverpod` | — |

`url_launcher` se **quitó** al sacar el botón del 911: era su único uso, y
menos plugins es menos superficie.

⚠️ **`pub` no tiene un `audit` de vulnerabilidades conocidas** — no existe el
equivalente a `npm audit`. Lo revisado acá es "está al día", que **no es lo
mismo que "no tiene CVEs"**. Para cubrir eso hace falta una herramienta
externa: [OSV-Scanner](https://google.github.io/osv-scanner/) lee
`pubspec.lock`, o Dependabot si el repo va a GitHub.

---

# Configuración de red

| Punto | Estado |
|---|---|
| URLs en texto plano (`http://`) | **Ninguna.** Supabase, Open-Meteo y los tiles de OSM van por `https` |
| `usesCleartextTraffic` en el manifest | No declarado ✔ |
| Excepciones ATS en `Info.plist` (iOS) | Ninguna ✔ |
| Permisos Android | Solo `INTERNET`, `ACCESS_COARSE_LOCATION`, `ACCESS_FINE_LOCATION`. Sin ubicación en segundo plano ✔ |
| Logs con datos del usuario | Ninguno. No hay un solo `print` ni `debugPrint` en `lib/` ✔ |

---

# Qué hacer, en orden

**Antes de publicar**

1. ~~Correr las **5 verificaciones del dashboard** de S2.~~ **Hecho el
   2026-09-18**: las cinco dieron lo esperado, incluida la número 4, que es
   la única que prueba algo de verdad (el `INSERT` con la anon key rebotó
   con `42501`).
2. ~~Confirmar que la clave del `env.json` tiene `"role": "anon"`.~~ Hecho:
   es la que usa la prueba de arriba.
3. Dejar puesta la **alerta de uso** de Supabase (S4, punto 1). Es un minuto
   y es lo único que avisa de un abuso antes de que llegue el resumen.
   **Es lo único que queda antes de publicar.**

**Cuando haya tráfico real**

4. Lo demás de S4: CDN adelante y, si escala, `get_all_stops` detrás de una
   Edge Function con caché.

**Cuando toque, por prolijidad**

5. Bajar `routeGeometryProvider` a la capa de datos (R6). Ya no es un
   problema de robustez.

---

## Historial

| Fecha | Qué pasó |
|---|---|
| 2026-08-06 | Auditoría inicial. Corregido R1 (crash de arranque). |
| 2026-08-06 | Corregido R2 (cache del pronóstico), R6 (`routeGeometryProvider` traduce a `Failure`) y R8 (`allowBackup=false`). S4 pasa a pendiente de configuración con los pasos exactos. |
