# Ruta Libre 🚌

App de transporte público y movilidad para el Gran Resistencia (Chaco) y
Corrientes capital. Rápida, limpia y sin publicidad.

**Qué hace hoy**, con datos **reales** — 32 líneas, 133 recorridos y
1474 paradas de OpenStreetMap y del portal de datos abiertos de Corrientes:

- **Mapa** con las paradas visibles de entrada, sin pedir el GPS ni elegir una
  línea, y el trazado de cada recorrido
- **Buscador** de líneas por número, barrio o **destino** (ignora tildes)
- **Buscá por LUGAR, por CALLE o por DIRECCIÓN con altura**: el hospital, la
  escuela, la plaza — ~2600 lugares, ~2900 calles con su localidad y
  **~58.000 números de puerta** de OpenStreetMap: "San Juan 5240" cae en la
  cuadra real, sin señal y sin saber la esquina
- **"¿Cómo llego?"**: de dónde estás a dónde vas, con directos y un transbordo.
  El origen sale del GPS o **se elige a mano**, así que también sirve para
  planificar desde el sillón o sin dar el permiso de ubicación
- **"Iniciar viaje"**: el viaje paso a paso, uno por pantalla, con la cámara
  **siguiéndote** (y soltándote apenas movés el mapa vos). Sin minutos
  inventados — ver el CHANGELOG
- **Alarma "avisame para bajar"**: por si te dormís arriba del colectivo —
  la pantalla no se apaga y, dos paradas antes de la tuya, suena el tono de
  alarma del sistema (aunque el teléfono esté en silencio) y vibra hasta que
  la apagues
- **"¿Qué colectivos pasan por acá?"** tocando cualquier parada, con a cuánto
  llegás caminando
- **Cerca mío** por GPS, con la distancia real en metros
- **Horarios** por tipo de día, con feriados argentinos resueltos solos y la
  próxima salida resaltada *(cargados los de la 904A, y sin confirmar con la
  empresa: no hay fuente pública — ver `docs/propuesta-datos-abiertos.md`)*
- **Aviso por lluvia**: un chip arriba a la izquierda con la probabilidad; al
  tocarlo cuenta que con lluvia suele haber menos unidades y demoras. Es una
  advertencia general, no un estado en vivo — ese dato no existe todavía
- Arranque instantáneo (cache-first), dark mode, sin publicidad

Para publicarla: [`docs/publicacion.md`](docs/publicacion.md). Qué incluye la
v1.0: [`CHANGELOG.md`](CHANGELOG.md).

## Setup rápido

```bash
# 1. Dependencias
flutter pub get

# 2. Claves de Supabase → crear env.json en la raíz (está gitignoreado):
#    {"SUPABASE_URL": "https://<proyecto>.supabase.co", "SUPABASE_ANON_KEY": "<anon key>"}

# 3. Base de datos (Supabase → SQL Editor, EN ORDEN):
#    supabase/migrations/0001..0010  ← ver la lista completa en ARCHITECTURE.md
#    supabase/seed/seed_gran_resistencia.sql  ← los datos reales (~890 KB)
#    supabase/seed/seed_corrientes.sql        ← Corrientes capital
#    supabase/seed/seed_horarios.sql          ← DESPUÉS de los recorridos

# 4. Correr
flutter run --dart-define-from-file=env.json

# 5. Verificar
flutter analyze && flutter test
```

## Arquitectura

Clean Architecture feature-first (`presentation → domain ← data`), Riverpod 3
con providers manuales (sin codegen), Supabase (Postgres + PostGIS),
flutter_map + OSM, cache-first para arranque instantáneo, errores como
valores (`Either<Failure, T>` con fpdart).

**Leé `ARCHITECTURE.md`** — ahí está el contexto completo del proyecto, las reglas
de arquitectura y los gotchas conocidos.

```
lib/
├── app/                  # composición: router, theme
├── core/                 # errores, Result, UseCase base
└── features/transit/
    ├── domain/           # Dart puro: entidades, contrato, usecases
    ├── data/             # modelos, datasources (Supabase + cache), repo
    └── presentation/     # providers, pantallas, widgets, utils
tools/                    # importador de OSM (CLI, no lo usa la app)
docs/                     # decisiones del import y propuesta de datos abiertos
supabase/                 # migraciones y datos generados
```

## Datos

Dos fuentes, dos importadores, ambos CLIs de Dart puro que emiten SQL
versionado para poder revisarlo antes de aplicarlo:

```bash
dart run tools/osm_import.dart          # Gran Resistencia + interurbano
dart run tools/corrientes_import.dart   # Corrientes capital
```

Detalles y decisiones en [`docs/osm-import.md`](docs/osm-import.md).

- Gran Resistencia e interurbano: **OpenStreetMap**, licencia **ODbL** —
  crédito "© OpenStreetMap contributors" visible sobre el mapa.
- Corrientes capital: **Municipalidad de la Ciudad de Corrientes**, portal de
  datos abiertos. El portal **no declara licencia**: se atribuye la fuente y
  queda por confirmar antes de un uso comercial.

## Tests

581 tests unitarios y de widgets — incluidos los de accesibilidad (texto del sistema al 200%) y los primeros de la pantalla del mapa, con un TileProvider inyectable para no tocar la red: importador (parser, geometría, cosido de
trazados, SQL), repositorio cache-first, mapeos DTO, usecases, resolución de
feriados (computus), buscador de origen y destino, estado del viaje, assets
empaquetados (lugares y paradas de Corrientes), panel de líneas, hoja de
parada y pantalla de horarios.

```bash
flutter test
```
