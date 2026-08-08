-- ============================================================
-- RUTA LIBRE — 0004: planificador de viajes ("¿cómo llego?")
--
-- Responde la pregunta del pasajero: estoy ACÁ, quiero ir ALLÁ,
-- ¿qué me tomo? Devuelve viajes DIRECTOS y de UN TRANSBORDO.
--
-- Por qué transbordos y no solo directos: medido sobre los datos
-- reales del Gran Resistencia (1416 paradas, 64 recorridos con
-- secuencia), con 400 m de caminata máxima solo el 40% de los
-- pares origen-destino tiene línea directa. Con un transbordo se
-- llega al 87%. Un planificador "solo directo" contestaría "no
-- hay" 6 de cada 10 veces.
--
-- Por qué NO dos transbordos: sube poco la cobertura y baja
-- mucho la confianza. Con dos transbordos y sin horarios, la
-- respuesta es un itinerario que nadie puede verificar.
--
-- Correr en: Supabase Dashboard → SQL Editor.
-- REQUIERE 0001 + 0002 + 0003 y los seeds de recorridos.
-- ============================================================

-- Los dos sentidos del join de `route_stops` ya están cubiertos:
-- la PK (route_variant_id, stop_order) sirve para "las paradas
-- siguientes de este recorrido" y route_stops_stop_id_idx para
-- "qué recorridos pasan por esta parada".

-- ------------------------------------------------------------
-- Un tramo del viaje, ya hidratado, como JSON.
--
-- Vive aparte porque `plan_trip` lo llama una o dos veces por
-- resultado y meterlo inline duplicaría seis joins.
-- ------------------------------------------------------------
create or replace function public.trip_leg_json(
    variant    uuid,
    board      uuid,
    alight     uuid,
    stop_count integer
)
returns json
language sql
stable
security invoker
as $$
    select json_build_object(
        'line_id',          l.id,
        'line_code',        l.code,
        'line_name',        l.name,
        'color_hex',        l.color_hex,
        'network_code',     n.code,
        'network_name',     n.name,
        'route_variant_id', rv.id,
        'variant_name',     rv.name,
        'branch',           rv.branch,
        'direction',        rv.direction,
        'stop_count',       stop_count,
        'board_stop', json_build_object(
            'id',          bs.id,
            'name',        bs.name,
            'description', bs.description,
            'lat',         st_y(bs.geom::geometry),
            'lng',         st_x(bs.geom::geometry)),
        'alight_stop', json_build_object(
            'id',          als.id,
            'name',        als.name,
            'description', als.description,
            'lat',         st_y(als.geom::geometry),
            'lng',         st_x(als.geom::geometry))
    )
    from public.route_variants rv
    join public.lines l    on l.id = rv.line_id
    join public.networks n on n.id = l.network_id
    join public.stops bs   on bs.id = board
    join public.stops als  on als.id = alight
    where rv.id = variant;
$$;

comment on function public.trip_leg_json is
    'Un tramo de viaje hidratado (línea, recorrido, parada de subida y de bajada) como JSON';

-- ------------------------------------------------------------
-- El planificador.
-- ------------------------------------------------------------
create or replace function public.plan_trip(
    origin_lat  double precision,
    origin_lng  double precision,
    dest_lat    double precision,
    dest_lng    double precision,
    max_walk_m  integer default 500,
    max_results integer default 6
)
returns json
language sql
stable
security invoker
as $$
with origin_g as (
    select st_point(origin_lng, origin_lat)::geography as g
),
dest_g as (
    select st_point(dest_lng, dest_lat)::geography as g
),
-- Paradas caminables desde cada punta.
o as (
    select s.id, st_distance(s.geom, origin_g.g) as walk_m
    from public.stops s cross join origin_g
    where s.is_active and st_dwithin(s.geom, origin_g.g, max_walk_m)
),
d as (
    select s.id, st_distance(s.geom, dest_g.g) as walk_m
    from public.stops s cross join dest_g
    where s.is_active and st_dwithin(s.geom, dest_g.g, max_walk_m)
),
-- Tramo 1: me subo cerca del origen y me puedo bajar en `via`.
leg1 as (
    select rs_board.route_variant_id as variant_id,
           rs_board.stop_id          as board_id,
           rs_board.stop_order       as board_order,
           o.walk_m                  as walk_m,
           rs_off.stop_id            as via_id,
           rs_off.stop_order         as via_order
    from public.route_stops rs_board
    join o                        on o.id = rs_board.stop_id
    join public.route_variants rv on rv.id = rs_board.route_variant_id
                                 and rv.is_active
    join public.route_stops rs_off
      on rs_off.route_variant_id = rs_board.route_variant_id
     and rs_off.stop_order > rs_board.stop_order
),
-- Tramo 2, mirado AL REVÉS: desde qué parada puedo llegar caminando
-- al destino. Se arma desde el destino y no hacia adelante porque así
-- las dos mitades quedan del mismo tamaño (~5000 filas) y el
-- transbordo es un join por stop_id, no un producto cartesiano.
leg2 as (
    select rs_board.route_variant_id as variant_id,
           rs_board.stop_id          as via_id,
           rs_board.stop_order       as board_order,
           rs_off.stop_id            as alight_id,
           rs_off.stop_order         as alight_order,
           d.walk_m                  as walk_m
    from public.route_stops rs_board
    join public.route_variants rv on rv.id = rs_board.route_variant_id
                                 and rv.is_active
    join public.route_stops rs_off
      on rs_off.route_variant_id = rs_board.route_variant_id
     and rs_off.stop_order > rs_board.stop_order
    join d on d.id = rs_off.stop_id
),
-- Un solo colectivo. Una fila por recorrido: la de menos caminata.
direct as (
    select distinct on (l.variant_id)
           1                                    as leg_count,
           l.variant_id                         as v1,
           l.board_id                           as b1,
           l.via_id                             as a1,
           l.via_order - l.board_order          as n1,
           null::uuid                           as v2,
           null::uuid                           as b2,
           null::uuid                           as a2,
           null::integer                        as n2,
           l.walk_m                             as walk_start,
           d.walk_m                             as walk_end
    from leg1 l
    join d on d.id = l.via_id
    order by l.variant_id, l.walk_m + d.walk_m, l.via_order - l.board_order
),
-- Un transbordo, EN LA MISMA PARADA. No se ofrecen transbordos
-- caminando: sin horarios ya es un itinerario que el pasajero no
-- puede verificar, y sumarle "y caminá tres cuadras hasta otra
-- parada" lo vuelve un consejo que nadie sigue. El pase de
-- unificación de paradas del importer es lo que hace que esto
-- alcance: dos líneas que usan la misma esquina hoy comparten parada.
transfer as (
    select distinct on (a.variant_id, b.variant_id)
           2                                    as leg_count,
           a.variant_id                         as v1,
           a.board_id                           as b1,
           a.via_id                             as a1,
           a.via_order - a.board_order          as n1,
           b.variant_id                         as v2,
           b.via_id                             as b2,
           b.alight_id                          as a2,
           b.alight_order - b.board_order       as n2,
           a.walk_m                             as walk_start,
           b.walk_m                             as walk_end
    from leg1 a
    join leg2 b on b.via_id = a.via_id
    join public.route_variants rva on rva.id = a.variant_id
    join public.route_variants rvb on rvb.id = b.variant_id
    -- Distinta LÍNEA, no solo distinto recorrido: "tomá la 3 y después
    -- la 3" no es una respuesta, aunque sean ramales distintos.
    where rva.line_id <> rvb.line_id
    order by a.variant_id, b.variant_id,
             a.walk_m + b.walk_m,
             (a.via_order - a.board_order) + (b.alight_order - b.board_order)
),
ranked as (
    select *
    from (select * from direct union all select * from transfer) c
    -- Un colectivo le gana a dos, después menos caminata, después
    -- menos paradas arriba.
    order by c.leg_count,
             c.walk_start + c.walk_end,
             c.n1 + coalesce(c.n2, 0)
    limit max_results
)
select coalesce(json_agg(t order by t.leg_count, t.walk_total_m), '[]'::json)
from (
    select r.leg_count,
           round(r.walk_start)::integer                as walk_to_board_m,
           round(r.walk_end)::integer                  as walk_from_alight_m,
           round(r.walk_start + r.walk_end)::integer   as walk_total_m,
           case
               when r.leg_count = 1 then
                   json_build_array(
                       public.trip_leg_json(r.v1, r.b1, r.a1, r.n1))
               else
                   json_build_array(
                       public.trip_leg_json(r.v1, r.b1, r.a1, r.n1),
                       public.trip_leg_json(r.v2, r.b2, r.a2, r.n2))
           end                                         as legs
    from ranked r
) t;
$$;

comment on function public.plan_trip is
    'Viajes de un colectivo o un transbordo entre dos puntos, como JSON [{leg_count,walk_to_board_m,walk_from_alight_m,walk_total_m,legs:[...]}], del mejor al peor';

-- Smoke test (opcional): Plaza 25 de Mayo → UNNE Resistencia.
--   select public.plan_trip(-27.4519, -58.9865, -27.4546, -58.9913, 500, 6);
