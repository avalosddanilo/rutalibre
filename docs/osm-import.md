# Importación de datos desde OpenStreetMap

De dónde salen los recorridos, las paradas y los colores que ves en el mapa.

## Por qué OSM y no otra fuente

El Gran Resistencia **ya está mapeado** en OpenStreetMap por la comunidad:
85 relations `route=bus` y ~2000 nodos de parada dentro del área
metropolitana. No hay que pedirle permiso a nadie ni esperar a que alguien
publique un feed.

Las alternativas que se evaluaron:

| Fuente | Estado |
|---|---|
| **OpenStreetMap** | ✅ Cobertura completa del Gran Resistencia. Licencia ODbL. **Es la que se usa.** |
| SITAM / ChacoBus (provincia) | ❌ Apps propietarias, sin API pública ni datos abiertos. **Y hace rato que ni siquiera funcionan** — ver abajo. |
| [Datos abiertos de Corrientes](https://datos.ciudaddecorrientes.gov.ar/dataset?tags=colectivos) | ✅ **Ya integrado** para Corrientes capital (10 líneas, 60 recorridos) con `tools/corrientes_import.dart`. Sin paradas: ese recurso fue dado de baja del portal. ⚠️ **El portal no declara licencia** — ver más abajo. |
| [Itinerarios del sitio de la Municipalidad](../docs/corrientes-itinerarios.md) | ✅ Las **calles** de los 24 ramales, incluidos 12 de los 13 que el dataset no publica. No es geometría: es la fuente legítima para trazarlos **en OSM**. ⚠️ Tampoco declara licencia. |
| GTFS nacional | ❌ No existe feed para el Gran Resistencia. |

### El estado real de SITAM (observación de campo, 2026-09-18)

No es solo que SITAM no tenga API: como app **está caída hace un buen rato**.
Lo que se ve al abrirla:

- **No dibuja los recorridos.** El mapa queda sin trazado.
- **Tocar una parada no lista ninguna línea.** La pantalla aparece vacía.
- **No hay GPS de las unidades.** Nunca lo hubo público, y hoy tampoco lo
  muestra la app oficial.

Es una observación propia, no un anuncio oficial: si mañana vuelve a andar,
esta nota se corrige con fecha. Pero mientras siga así, sostiene dos cosas
que ya decíamos:

1. **Depender de OSM no era una preferencia, era la única opción.** La única
   fuente que no se cae es la que está en el repo.
2. **"No hay GPS público en la flota" no es una excusa nuestra.** Ni la app
   de la provincia lo tiene. Por eso no se promete "en vivo" en ningún lado
   (ver `marketing/estrategia.md` → palabras prohibidas).

Lo que **no** se hace con esto: usarlo como argumento de venta. No se habla
mal de SITAM en ningún posteo, mail ni respuesta. Que ellos estén caídos no
nos hace buenos; lo que nos hace buenos es andar.

**Lo que OSM tiene viejo o incompleto se corrige EN OSM**, no en el repo: lo
que cuenta la gente sobre recorridos que no coinciden se contrasta y se anota
en [`aportes-de-campo.md`](aportes-de-campo.md), con el primer caso medido (la
línea a Colonia Benítez, a la que le falta toda la punta del centro).

**Lo que OSM NO tiene: horarios.** Esa es la pieza que solo puede aportar la
Secretaría de Transporte (ver `docs/propuesta-datos-abiertos.md`).

## Cómo se corre

```bash
# Baja de Overpass y regenera el SQL
dart run tools/osm_import.dart

# Reusando una descarga previa (no castiga un servicio gratuito)
dart run tools/osm_import.dart --cache .osmcache
```

Genera `supabase/seed/seed_gran_resistencia.sql`. **No se aplica solo**: el
SQL queda versionado para poder revisarlo en el diff antes de correrlo en
Supabase → SQL Editor, después de la migración `0003`.

> El archivo pesa ~800 KB. Si el editor web del navegador se traba, conviene
> aplicarlo con `psql` usando la connection string del proyecto.

## Qué hace, paso a paso

1. **Descarga** las relations `route=bus` del bbox del Gran Resistencia +
   corredor a Corrientes, y por separado los nodos de parada con sus tags.
2. **Descarta** las relations sin `ref`: son los micros de larga distancia
   (Buenos Aires–Corrientes, Corrientes–Paso de los Libres…), que no son
   transporte urbano.
3. **Interpreta** `ref` y `name` para sacar línea, ramal y sentido.
4. **Cose** los ways de cada relation en un trazado continuo.
5. **Ordena las paradas proyectándolas sobre el trazado** (no por el orden de miembros de OSM) y las deduplica.
6. **Unifica**, mirando todo el dataset, los nodos que son la misma parada física.
7. **Emite** SQL idempotente en una transacción.

## Decisiones que vale la pena conocer

**"3A" es el ramal A de la línea 3, no una línea aparte.** El usuario piensa
en "la 3"; ramal y sentido son atributos del recorrido. Por eso 73 recorridos
se agrupan en apenas 20 líneas.

**El `name` le gana al `ref` cuando se contradicen.** Hay al menos una
relation tagueada `ref=207` cuyo nombre es *"206 Vuelta Resistencia -
Barranqueras"*: es un error de tagueo en OSM. Confiar en el `ref` metería ese
recorrido en la línea equivocada. El importer lo detecta, usa el nombre y lo
reporta como advertencia.

**El sentido sale del nombre.** La red sigue el convenio
`{ref} {Ida|Vuelta} {Origen} - {Destino}`. Cuando no está (la 904A no tiene
nombre), se asigna por descarte dentro del ramal y queda registrado.

**El " - " solo separa origen y destino si el nombre sigue el convenio.** En
nombres libres como *"Chaco - Corrientes directo"* ese guion no separa
extremos, y partirlo inventaba destinos.

**Los saltos se puentean y se reportan.** Los recorridos que no cierran
(calles sin mapear en OSM) se unen con una recta y se listan en el
diagnóstico del SQL generado con el tamaño del salto, para saber qué arreglar
en OSM. Ese diagnóstico es la fuente de verdad de cuántos son.

**El trazado se simplifica a 5 m** (Douglas-Peucker): a escala urbana no hay
diferencia visible y el SQL baja a un tercio.

**Las paradas sin nombre se bautizan con la esquina.** 1271 de las 1416
paradas llegan de OSM sin `name`, solo con el código interno de la
concesionaria (`ref`). "Parada C03253" no le dice nada a un pasajero, así que
el importer busca en el callejero la calle sobre la que está la parada y su
transversal más cercana: *"Ameghino y Sáenz Peña"*. El código no se pierde:
queda en `description`. Si no hay calle a menos de 40 m, **no se inventa
nada** y se deja el código. Resultado: 1412 de 1416 paradas con nombre útil.

**Los colores los inventa el importer**, porque OSM casi no trae `colour`
(2 de 85). Se derivan de un hash del código de línea: la misma línea saca
siempre el mismo color, y agregar una línea nueva no le cambia el color a las
demás.

**El orden de las paradas NO sale de OSM: se proyecta sobre el trazado.**
Es la decisión menos obvia del importer y la más importante. Las relations
listan sus miembros en BLOQUES (todas las plataformas y después todas las
posiciones de detención), no en orden de paso. Tomar ese orden literal dejaba
41 de 64 secuencias yendo y viniendo, con saltos de hasta 11 km entre paradas
"consecutivas", y 196 filas que eran la misma parada física repetida.

Ahora cada parada se proyecta sobre el trazado ya cosido y se ordena por
cuánto se avanzó sobre él. Las que caen a más de 250 m del recorrido se
descartan: un error de tagueo no debe inventar una secuencia. Después se
colapsa el par `stop_position` + `platform` de cada parada física (umbral
40 m) y se descartan las repeticiones, porque `route_stops` tiene
`unique (route_variant_id, stop_id)` y un circular pasa dos veces por la
cabecera.

Medido después del cambio: 2 secuencias con saltos grandes (las dos van
derecho: son tramos interurbanos sin paradas) y 0 paradas repetidas.

**Una parada física, un solo registro — y eso hay que decidirlo mirando TODO
el dataset.** El colapsado de arriba es por recorrido, y no alcanza: si la
línea 3 usa el `stop_position` de una esquina y la 9 usa el `platform`, las
dos sobreviven y la tabla `stops` termina con dos paradas separadas por 5 m.
En el mapa se veían dos pines pegados; en "cerca mío", la misma parada
listada dos veces. `tools/src/stop_merge.dart` hace el pase global: **82
nodos** eran una segunda representación de una parada ya existente
(1498 → 1416 paradas).

Las reglas de unión son deliberadamente conservadoras, porque el error caro
es el contrario — unir dos paradas ENFRENTADAS (una por sentido) sería mentir
sobre en qué vereda para cada línea:

| Caso | Radio |
|---|---|
| `platform` + `stop_position` (la pareja PTv2) | 30 m |
| Dos nodos del mismo rol (parada mapeada dos veces) | 12 m — no entra ninguna calle |
| Pareja PTv2 con `name` distinto en cada nodo | no se unen más allá de 12 m |

Gana la **plataforma**: es la vereda donde espera el pasajero, no el eje de
la calzada, así que el pin cae donde uno realmente está. El nombre y el
código de la concesionaria se juntan de todos los nodos del grupo — en PTv2
el nombre suele estar en la plataforma y el `ref` en la posición de
detención.

**Las paradas que quedaron sin ningún recorrido se dan de baja.** Al final
del SQL, después de rehacer `route_stops`. Ahí caen las del seed mock, las
que OSM dejó de usar y las que este pase unificó con otra. Si se quedaran
activas aparecerían en "cerca mío" y al tocarlas no pasaría nada: son las
"paradas que ya no son paradas".

## Reimportar

El SQL es idempotente: se puede correr las veces que haga falta. Los upserts
van por los identificadores de OSM (`osm_relation_id`, `osm_node_id`), así
que reimportar actualiza en lugar de duplicar.

**Ojo:** el script borra los recorridos de estas redes que *no* tengan origen
OSM (los del seed de desarrollo) para que no queden trazados mock mezclados
con los reales — y eso arrastra por cascada los horarios que colgaran de
ellos.

## Corrientes capital (fuente distinta)

Corrientes capital **no tiene red urbana mapeada en OSM**: las 11 relations
del lado correntino son micros interurbanos de larga distancia. Sus
recorridos salen del portal municipal:

```bash
dart run tools/corrientes_import.dart
```

Genera `supabase/seed/seed_corrientes.sql` (10 líneas, 60 recorridos).

Tres diferencias con el importador de OSM, que es por lo que son dos
pipelines y no uno:

1. **La geometría viene proyectada** en Gauss-Krüger Faja 5, no en lat/lng.
   Se reproyecta en `tools/src/gauss_kruger.dart`. Es una conversión que, si
   se rompe, falla **en silencio** (los recorridos se dibujan igual, pero en
   otro lugar del planeta): por eso los tests la validan contra puntos de
   control reales — el Aerobus arranca a 620 m del puerto y termina a 580 m
   del aeropuerto.
2. **El sentido viene explícito** (`linea_descrip` termina en `- IDA` o
   `- VUELTA`), no hay que adivinarlo del nombre.
3. **No hay identificador estable de origen**, así que la identidad es
   natural: `(línea, ramal, sentido)`. Reimportar da de baja lógica todo lo
   anterior de la red y reactiva lo que vino: un recorrido que la
   Municipalidad elimine queda `is_active = false` sin borrar nada.

El `ramal` conserva su descriptor ("C DIRECTO" y no solo "C") porque la 103
tiene dos ramales C distintos que colisionarían.

## Licencia

**OpenStreetMap** (Gran Resistencia e interurbano): licencia **ODbL**. La app
**debe** mantener visible el crédito *"© OpenStreetMap contributors"* — ya
está sobre el mapa en `map_screen.dart`.

**Municipalidad de Corrientes**: el portal **no declara licencia** sobre el
dataset. Publicar un dataset descargable implica intención de reúso, pero la
ambigüedad es real. Decisión tomada: se atribuye la fuente en el SQL, en esta
documentación y en los créditos, y **queda pendiente confirmarlo con la
Municipalidad antes de una publicación comercial**.
