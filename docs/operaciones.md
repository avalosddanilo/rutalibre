# Operaciones: el manual de todos los días

Qué hacer cuando algo anda mal, lento o distinto. Para publicar en Play:
[`publicacion.md`](publicacion.md). Las decisiones de fondo: `ARCHITECTURE.md`.

## Los comandos de todos los días

```bash
# Verificar TODO antes de commitear (lo mismo que corre el CI)
flutter analyze --fatal-infos && dart format --output=none --set-exit-if-changed lib test tools && flutter test

# Compilar el APK de release
flutter build apk --release --dart-define-from-file=env.json

# Instalarlo en el teléfono/emulador conectado — COMPILAR NO INSTALA
flutter install --release

# Correr en caliente (desarrollo)
flutter run --dart-define-from-file=env.json
```

**La trampa clásica**: `flutter build` deja el APK en
`build/app/outputs/flutter-apk/app-release.apk` y NO toca el teléfono. Si
después de un build "no se ven los cambios", es que la app instalada es la
vieja. Instalar de nuevo (o arrastrar el APK a la ventana del emulador).

## "Anda lento" — de dónde viene cada lentitud

Antes de tocar código, ubicar CUÁL lentitud es, porque casi ninguna es de la
app:

1. **En el emulador todo es más lento** — renderiza el mapa por software y
   cada reinstalación arranca con las caches vacías. El único veredicto que
   vale es el teléfono real con el APK de RELEASE (`--release`; el modo
   debug es varias veces más lento por diseño).
2. **El mapa tarda en dibujarse** → son los TILES de OpenStreetMap, que
   viajan por la red del teléfono. Con mala señal tardan; con buena vuelan.
   No hay base nuestra en el medio.
3. **La primera vez tarda, después no** → es el diseño cache-first: líneas,
   recorridos y paradas se bajan UNA vez y quedan en el teléfono. La segunda
   apertura sale de ahí (por eso la app abre sin señal).
4. **"¿Cómo llego?" tarda o falla** → es la base (ver la emergencia #1).

## Emergencias conocidas (pasaron de verdad)

### 1. "¿Cómo llego?" da error / plan_trip devuelve HTTP 500

Pasó DOS veces el 28/8/2026, y la segunda enseñó la lección importante:
**verificar siempre con un viaje CORTO (las dos puntas dentro de
Resistencia), nunca con el viaje a Corrientes.** El viaje largo es
engañosamente rápido —el destino tiene una sola parada cerca— y da por
sano un planificador que se muere en los viajes de todos los días, que
tienen decenas de paradas cerca de cada punta.

Primer auxilio (estadísticas perdidas), en Supabase → SQL Editor:

```sql
analyze public.stops; analyze public.route_stops; analyze public.route_variants; analyze public.lines;
```

Si el ANALYZE no alcanza, el arreglo de fondo es la migración
`0011_plan_trip_acotado.sql` (re-crear la función con las CTEs
materializadas y los tramos acotados — leer su encabezado, ahí está toda
la historia). Es idempotente: correrla de nuevo no rompe nada.

Para verificar desde afuera, con la anon key — EL VIAJE CORTO:

```bash
curl -s -o /dev/null -w "%{http_code} en %{time_total}s\n" -X POST "$SUPABASE_URL/rest/v1/rpc/plan_trip" -H "apikey: $ANON" -H "Authorization: Bearer $ANON" -H "Content-Type: application/json" -d '{"origin_lat":-27.4519,"origin_lng":-58.9865,"dest_lat":-27.4546,"dest_lng":-58.9913,"max_walk_m":500,"max_results":6}'
```

Sano: 200 en menos de un segundo. Si el ANALYZE no alcanza, en orden: (a)
revisar que RLS siga habilitado con las policies de lectura (migración
0009); (b) verificar que los índices existan
(`select indexname from pg_indexes where schemaname='public';` — tienen que
estar `stops_geom_idx`, `route_stops_stop_id_idx`, `route_variants_geom_idx`,
`route_variants_line_id_idx`, `lines_network_id_idx`,
`schedules_variant_day_idx`); (c)
`explain (analyze, buffers) select public.plan_trip(-27.4519,-58.9865,-27.4546,-58.9913,500,6);`
y mirar qué paso se come el tiempo.

### 2. El CI se puso rojo por formato

El formateador de Dart cambia entre versiones. El CI está FIJADO a la
versión de desarrollo (`flutter-version` en `.github/workflows/ci.yml`).
Si actualizás Flutter local, actualizá ese número en el mismo commit, corré
`dart format lib test tools` y listo.

### 3. El emulador no arranca (exit code 1)

Dos condiciones y las dos hacen falta: (1) la virtualización habilitada en
el BIOS (en `systeminfo` tiene que decir "Se habilitó la virtualización en
el firmware: Sí"); (2) el driver AEHD instalado (SDK Manager → Android
Emulator hypervisor driver, y correr su `silent_install.bat` como
administrador). `emulator -accel-check` dice cuál de las dos falta.

### 4. Regenerar los datos

```bash
# Lugares + calles + alturas (Overpass; --cache para no castigar el servicio)
dart run tools/places_import.dart --cache .osmcache

# Recorridos y paradas (genera el SQL de seed; NUNCA editarlo a mano)
dart run tools/osm_import.dart
dart run tools/corrientes_import.dart

# Ícono y splash (si cambia la marca)
flutter test test/brand/brand_assets_test.dart && dart run flutter_launcher_icons && dart run flutter_native_splash:create
```

Después de regenerar seed: aplicarlo en Supabase (SQL Editor) y correr el
ANALYZE de la emergencia #1 — un seed recién cargado sin estadísticas es
exactamente lo que causó el 500.

### 5. El keystore

`android/rutalibre.jks` + `android/key.properties` (los dos gitignoreados).
**Sin ese archivo y su contraseña no se puede actualizar la app en Play
NUNCA MÁS** — copia de seguridad en al menos dos lados (pendrive, Drive).
La contraseña no va en ningún chat, captura ni archivo del repo.

## ¿Cuánta gente aguanta? (plan gratuito de Supabase)

Los números del plan free: 500 MB de base (usamos ~50), 5 GB de salida por
mes, y una instancia chica de cómputo. Cómo gasta la app:

- **Instalación nueva**: baja líneas, recorridos, paradas y trazados una
  vez (~1–2 MB) y los cachea. → 5 GB/mes ≈ **2.000–4.000 instalaciones
  nuevas por mes** solo de sincronización inicial.
- **Uso diario**: casi todo sale de la cache del teléfono. Lo único que
  pega a la base es `plan_trip` (unos KB por consulta, ~100 ms de CPU) y
  las paradas cercanas. → decenas de miles de consultas por mes entran
  sobradas.
- **En simultáneo**: la instancia free banca varias `plan_trip` por
  segundo. Cientos de personas usando la app a la vez está bien; el que
  planifica no consulta cada segundo, consulta una vez por viaje.

Traducido: **para el lanzamiento y los primeros miles de usuarios, el plan
gratis alcanza y sobra.** Las alertas de uso al 50% y 80% (Dashboard →
Settings → Usage) avisan con tiempo; si algún mes explota de usuarios, el
plan Pro (US$25/mes) multiplica todos los límites — y ese sería un gran
problema para tener.

Lo que NO existe y por eso no gasta: colectivos en tiempo real. El día que
exista esa fuente de datos, el diseño cambia (websockets/polling) y hay que
redimensionar — está anotado en la propuesta de datos abiertos.

## Qué se va a romper primero (para irse adelantando)

En orden de probabilidad, con su respuesta:

1. **La base degradada otra vez** (ya pasó dos veces el 28/8): viajes
   cortos en timeout. Emergencia #1 de arriba — y verificar SIEMPRE con el
   viaje corto.
2. **"Los datos están viejos"**: una parada que se movió, un recorrido que
   cambió. No es un bug, es la realidad cambiando: re-correr los
   importadores cada 1-2 meses, re-aplicar seed y ANALYZE después.
3. **Los tiles del mapa, si la app explota**: vienen de los servidores
   gratuitos de OpenStreetMap, que tolueran apps chicas. Con miles de
   usuarios bien; con decenas de miles, cambiar la URL del TileLayer a un
   proveedor con tier gratis (MapTiler, Stadia) — es UNA línea en
   map_screen.dart y la política de OSM lo pide.
4. **Reseñas por los horarios que faltan**: la ficha lo avisa, igual van a
   caer. Responder con la verdad y usar cada una como munición del reclamo
   de datos abiertos.
5. **GPS de gama baja**: el contador aparece y desaparece. La app se calla
   en vez de inventar — es diseño, explicarlo así.
6. **Pre-lanzamiento**: el proyecto free de Supabase SE PAUSA tras ~7 días
   sin tráfico. Mientras dure la prueba cerrada, entrar al dashboard cada
   tanto; con usuarios reales no pasa más.

## Qué sigue (después de la 1.0)

La lista viva está en `ARCHITECTURE.md` → "Pendientes de la 1.1". Los tres
primeros, en orden de valor:

1. La alarma "avisame para bajar" con la pantalla apagada (servicio en
   primer plano de Android).
2. Horarios de más líneas — depende de conseguir la fuente (ver
   `propuesta-datos-abiertos.md` y `mails-para-mandar.md`).
3. Lo que diga la gente que la use. Las mejores funciones de la 1.0
   salieron de probarla en la calle: la alarma, las alturas, el panel de
   iniciar viaje. Escuchar quejas es el roadmap más barato que existe.
