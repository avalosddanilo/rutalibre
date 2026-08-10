# Planificador de viajes — "¿cómo llego?"

La pregunta con la que uno abre una app de colectivos no es "¿por dónde va
la 110?": es **"estoy acá, quiero ir allá, ¿qué me tomo?"**. Este documento
explica cómo se contesta y, sobre todo, **por qué se contesta así**.

## La medición que definió el diseño

Antes de escribir nada se midió, sobre los datos reales (1416 paradas, 64
recorridos con secuencia de paradas), qué porcentaje de pares
origen-destino se resuelve con un solo colectivo:

| Caminata máxima | Directo | Con 1 transbordo | Ni con transbordo |
|---|---|---|---|
| 300 m | 32,5 % | 49,5 % | 18,0 % |
| **400 m** | **40,4 %** | **46,4 %** | 13,3 % |
| 600 m | 55,0 % | 37,5 % | 7,5 % |

(4000 pares al azar a más de 800 m entre sí, transbordos en la misma parada.)

**Un planificador "solo directo" contestaría "no hay" 6 de cada 10 veces.**
Por eso el transbordo no es una mejora futura: sin él la función no sirve.

## Qué hace y qué no

**Sí**: viajes de un colectivo y de **un** transbordo, entre dos puntos
cualesquiera del mapa (no entre paradas: uno quiere ir al hospital, no a la
parada tal). Ordenados de mejor a peor — primero los directos, después por
caminata total, después por paradas arriba del colectivo.

**Una opción por LÍNEA, no por recorrido** (migración 0005). La primera
versión devolvía una por recorrido, y al correrla contra la base real
apareció esto:

```
9  ramal A · Alberdi 130 → Alberdi y Jujuy · 122 m + 128 m
9  ramal B · Alberdi 130 → Alberdi y Jujuy · 122 m + 128 m   ← el mismo viaje
8  ramal B · Alberdi 130 → Alberdi y Jujuy · 122 m + 128 m
106 ramal C · PAMI       → Alberdi y Jujuy · 143 m + 128 m
3  ramal C · Alberdi 150 → Alberdi y Jujuy · 148 m + 128 m
8  ramal A · Alberdi 150 → Alberdi y Jujuy · 148 m + 128 m   ← la 8, otra vez
```

Seis lugares para decir cuatro líneas. El pasajero piensa en "la 9", así
que se devuelve una opción por línea (la de menos caminata) y, en los
transbordos, una por PAR de líneas.

**El ramal se muestra solo cuando importa**: si de esa línea hay un único
recorrido que sirve, el ramal es parte de la respuesta ("tomá la 106C") y
va. Si sirven varios, cualquiera lleva, y decir "la 9A" haría que el
pasajero deje pasar la 9B que también le servía.

**No**:

* **Dos transbordos.** Suben poco la cobertura y bajan mucho la confianza:
  sin horarios, un itinerario de tres colectivos es una promesa que nadie
  puede verificar.
* **Transbordos caminando.** Solo se ofrece bajarse y subirse en la MISMA
  parada. Que esto alcance es mérito del [pase de unificación de
  paradas](osm-import.md): dos líneas que usan la misma esquina hoy
  comparten parada en vez de tener una cada una.
* **Cuánto tarda.** No hay horarios (ver [horarios.md](horarios.md)) ni
  velocidades. Se muestra la cantidad de paradas, que es lo único honesto
  que se puede decir.
* **Transbordar entre dos recorridos de la MISMA línea.** "Tomate la 3 y
  después la 3" no es una respuesta, aunque sean ramales distintos.

## Dónde vive cada cosa

```
supabase/migrations/0004_trip_planner.sql   plan_trip() + trip_leg_json()
domain/entities/trip_plan.dart              TripPlan, TripLeg (modelo de lectura)
domain/usecases/plan_trip.dart              PlanTrip + params (topes y validación)
data/models/trip_plan_model.dart            parseo del JSON anidado
presentation/providers/trip_providers.dart  estado del modo + consulta
presentation/widgets/trip_results_sheet.dart la lista de opciones
```

### El SQL

Todo el cruce se hace en Postgres. Traerse las 3030 filas de `route_stops`
al teléfono para cruzarlas ahí sería pagar red y batería por lo mismo.

La forma importa: las dos mitades del viaje se arman **por separado y con
el mismo tamaño** (~5000 filas cada una), y el transbordo es un join por
`stop_id` entre ellas.

* `leg1` mira hacia adelante desde el origen: *"me subo cerca de casa y me
  puedo bajar en estas paradas"*.
* `leg2` mira hacia atrás desde el destino: *"desde estas paradas llego
  caminando a donde voy"*.

Armar `leg2` hacia adelante haría un producto cartesiano.

Los índices ya estaban: la PK `(route_variant_id, stop_order)` sirve para
"las paradas siguientes de este recorrido" y `route_stops_stop_id_idx` para
"qué recorridos pasan por esta parada".

### Por qué `TripLeg` reusa `Stop` y `RouteAtStop` no reusa `BusLine`

Parece incoherente y no lo es. `RouteAtStop` no reusa `BusLine` porque su
RPC no trae la red, y una entidad con campos nullables "según de dónde
venga" miente sobre lo que garantiza. `plan_trip` sí devuelve la parada
completa —id, nombre, coordenadas—, así que `Stop` entra entero. Y las
coordenadas no son opcionales: sin ellas el mapa no puede dibujar dónde
subirse.

## Cómo se usa en la app

1. Botón **"¿Cómo llego?"** → pide el GPS (el origen es dónde estás).
2. **Tocás el mapa** donde querés ir. Aparece el marcador de destino.
3. Se abre la hoja con las opciones, contadas como se las contaría alguien
   en la calle: caminás → tomás la tal → viajás N paradas → bajás en tal →
   caminás.
4. Tocás una opción y el mapa dibuja el viaje: el trazado de cada tramo y
   los pines de subida, transbordo y bajada.

## Verificación contra la base

El SQL no se puede testear desde la suite de Dart (no hay PostGIS ahí), así
que se verifica a mano. Estado:

| Camino | Estado |
|---|---|
| Viaje directo | ✅ verificado — Plaza 25 de Mayo → UNNE devuelve 6 opciones correctas, 122-148 m de caminata |
| La app de punta a punta | ✅ el modo "¿cómo llego?" anda en el teléfono |
| 0005 aplicada | ✅ `trip_leg_json` tiene la firma de 5 argumentos y la vieja se dropeó |
| Una opción por línea | ⏳ falta mirar el resultado: el mismo par no debería repetir líneas |
| Viaje con transbordo | ⏳ sin verificar — **es lo único que queda y lo único que puede fallar feo** |

### Ver los resultados en filas legibles

`plan_trip` devuelve todo en una celda JSON, que en el editor de Supabase
queda cortada. Esta consulta lo abre en una fila por tramo:

```sql
select r.n                              as opcion,
       r.leg_count                      as tramos,
       r.walk_to_board_m                as camina_hasta,
       r.walk_from_alight_m             as camina_desde,
       leg.ord                          as tramo,
       leg.j ->> 'line_code'            as linea,
       leg.j ->> 'branch'               as ramal,
       leg.j -> 'board_stop'  ->> 'name' as sube_en,
       leg.j -> 'alight_stop' ->> 'name' as baja_en,
       leg.j ->> 'stop_count'           as paradas
from (
    select row_number() over () as n, *
    from json_to_recordset(
        -- Cambiar por el par que se quiera probar:
        public.plan_trip(-27.4519, -58.9865, -27.4546, -58.9913, 500, 6)
    ) as t(leg_count int, walk_to_board_m int,
           walk_from_alight_m int, legs json)
) r,
lateral json_array_elements(r.legs) with ordinality as leg(j, ord)
order by opcion, tramo;
```

**El invariante a mirar en un viaje de dos tramos**: el `baja_en` del tramo 1
tiene que ser IDÉNTICO al `sube_en` del tramo 2. Si difieren, el join del
transbordo está mal y la app estaría mandando gente a caminar entre dos
paradas sin decírselo.

### Forzar un viaje con transbordo, y verlo legible

Busca sola un par de paradas lejanas SIN línea directa —así no hay que
adivinar coordenadas— y abre el resultado en una fila por tramo:

```sql
with pair as (
    select st_y(o.geom::geometry) as olat, st_x(o.geom::geometry) as olng,
           st_y(d.geom::geometry) as dlat, st_x(d.geom::geometry) as dlng,
           o.name as origen, d.name as destino
    from public.stops o
    join public.stops d
      on st_dwithin(o.geom, d.geom, 8000)
     and st_distance(o.geom, d.geom) > 5000
    where o.is_active and d.is_active
      and not exists (
          select 1
          from public.route_stops a
          join public.route_stops b
            on b.route_variant_id = a.route_variant_id
           and b.stop_order > a.stop_order
          where a.stop_id = o.id and b.stop_id = d.id)
    limit 1
),
plan as (
    select p.origen, p.destino, row_number() over () as n, t.*
    from pair p,
         json_to_recordset(
             public.plan_trip(p.olat, p.olng, p.dlat, p.dlng, 600, 6)
         ) as t(leg_count int, walk_to_board_m int,
                walk_from_alight_m int, legs json)
)
select origen, destino,
       n                                                as opcion,
       leg_count                                        as tramos,
       leg.ord                                          as tramo,
       (leg.j ->> 'line_code') || coalesce(leg.j ->> 'branch', '') as linea,
       leg.j -> 'board_stop'  ->> 'name'                as sube_en,
       leg.j -> 'alight_stop' ->> 'name'                as baja_en,
       leg.j ->> 'stop_count'                           as paradas
from plan,
     lateral json_array_elements(plan.legs) with ordinality as leg(j, ord)
order by opcion, tramo;
```

**Lo que hay que mirar**: en las opciones con `tramos = 2`, el `baja_en` del
tramo 1 tiene que ser IDÉNTICO al `sube_en` del tramo 2. Si difieren, el
join del transbordo está mal y la app manda gente a caminar entre dos
paradas sin decírselo.

Si no devuelve nada, subir la caminata a 800: puede haber tocado un par que
de verdad no se resuelve ni con transbordo (el 13% de la tabla de arriba).

---

## Verificación AUTOMÁTICA del transbordo — pegá y leé una línea

Las consultas de arriba muestran filas para mirar a ojo. Esta las revisa sola:
corre `plan_trip` sobre diez pares de paradas lejanas **sin línea directa** y
verifica el invariante en todos los viajes de dos tramos que salgan.

Tarda unos segundos (cada par es una corrida completa del planificador).
**Lo único que hay que leer es la columna `mal`: tiene que ser 0.**

```sql
with pares as (
    -- Pares lejanos y sin ninguna línea que los una directo: es donde el
    -- transbordo es la única respuesta posible.
    select st_y(o.geom::geometry) as olat, st_x(o.geom::geometry) as olng,
           st_y(d.geom::geometry) as dlat, st_x(d.geom::geometry) as dlng,
           o.id as o_id, d.id as d_id
    from public.stops o
    join public.stops d
      on st_dwithin(o.geom, d.geom, 9000)
     and st_distance(o.geom, d.geom) > 4000
    where o.is_active and d.is_active
      and not exists (
          select 1
          from public.route_stops a
          join public.route_stops b
            on b.route_variant_id = a.route_variant_id
           and b.stop_order > a.stop_order
          where a.stop_id = o.id and b.stop_id = d.id)
    -- Muestra ESTABLE (no random()): dos corridas miran los mismos pares, así
    -- que si algo falla se puede volver a ver.
    order by md5(o.id::text || d.id::text)
    limit 10
),
planes as (
    select p.o_id, p.d_id,
           row_number() over (partition by p.o_id, p.d_id) as opcion,
           t.*
    from pares p,
         json_to_recordset(
             public.plan_trip(p.olat, p.olng, p.dlat, p.dlng, 700, 6)
         ) as t(leg_count int, walk_to_board_m int,
                walk_from_alight_m int, legs json)
),
tramos as (
    select o_id, d_id, opcion, leg_count, leg.ord as tramo,
           leg.j -> 'board_stop'  ->> 'id' as sube_id,
           leg.j -> 'alight_stop' ->> 'id' as baja_id
    from planes,
         lateral json_array_elements(planes.legs) with ordinality as leg(j, ord)
),
transbordos as (
    select t1.baja_id as baja_tramo1, t2.sube_id as sube_tramo2
    from tramos t1
    join tramos t2
      on t2.o_id = t1.o_id and t2.d_id = t1.d_id
     and t2.opcion = t1.opcion and t2.tramo = t1.tramo + 1
    where t1.leg_count = 2
)
select count(*) as transbordos_probados,
       count(*) filter (where baja_tramo1 = sube_tramo2)               as ok,
       count(*) filter (where baja_tramo1 is distinct from sube_tramo2) as mal
from transbordos;
```

- `mal = 0` → el join del transbordo está bien: se baja y se sube en la MISMA
  parada física.
- `mal > 0` → la app está mandando gente a caminar entre dos paradas sin
  decírselo. Es el bug más caro que puede tener el planificador.
- `transbordos_probados = 0` → la muestra no encontró ningún viaje de dos
  tramos. No es un aprobado: subí la caminata de 700 a 900 o el `limit` de 10
  a 30, y si sigue en cero, mirá la consulta de cobertura de abajo.

Para VER el detalle de lo que falló, la consulta de la sección anterior
("forzar un viaje con transbordo") imprime una fila por tramo con los nombres
de las paradas.

### De paso: qué contesta el planificador y qué no

Sobre la misma muestra —pero sin exigir que no haya línea directa—, cuántos
pares se resuelven directo, cuántos con un transbordo y cuántos no se
resuelven. Es la medición del 46% que justificó implementar el transbordo, y
conviene rehacerla después de cada import.

```sql
with pares as (
    select st_y(o.geom::geometry) as olat, st_x(o.geom::geometry) as olng,
           st_y(d.geom::geometry) as dlat, st_x(d.geom::geometry) as dlng,
           o.id as o_id, d.id as d_id
    from public.stops o
    join public.stops d
      on st_dwithin(o.geom, d.geom, 9000)
     and st_distance(o.geom, d.geom) > 3000
    where o.is_active and d.is_active
    order by md5(o.id::text || d.id::text)
    limit 30
),
mejor as (
    select p.o_id, p.d_id,
           (select min(t.leg_count)
            from json_to_recordset(
                     public.plan_trip(p.olat, p.olng, p.dlat, p.dlng, 700, 6)
                 ) as t(leg_count int, walk_to_board_m int,
                        walk_from_alight_m int, legs json)
           ) as tramos
    from pares p
)
select count(*)                                      as pares,
       count(*) filter (where tramos = 1)             as directo,
       count(*) filter (where tramos = 2)             as con_transbordo,
       count(*) filter (where tramos is null)         as sin_respuesta
from mejor;
```

`sin_respuesta` alto no es necesariamente un bug: puede ser un par que de
verdad no se resuelve con un solo transbordo (era el 13% en la medición
original). Lo que sería una alarma es que `directo` baje de golpe entre dos
imports: significa que se perdieron asignaciones parada↔recorrido.
