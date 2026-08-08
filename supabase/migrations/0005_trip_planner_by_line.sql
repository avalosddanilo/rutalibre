-- ============================================================
-- RUTA LIBRE — 0005: el planificador responde POR LÍNEA
--
-- Reemplaza las funciones de la 0004. Lo que se vio al correrla
-- contra la base real (Plaza 25 de Mayo → UNNE, 6 resultados):
--
--   9  ramal A · Alberdi 130 → Alberdi y Jujuy · 122 m + 128 m
--   9  ramal B · Alberdi 130 → Alberdi y Jujuy · 122 m + 128 m
--   8  ramal B · Alberdi 130 → Alberdi y Jujuy · 122 m + 128 m
--   106 ramal C · PAMI       → Alberdi y Jujuy · 143 m + 128 m
--   3  ramal C · Alberdi 150 → Alberdi y Jujuy · 148 m + 128 m
--   8  ramal A · Alberdi 150 → Alberdi y Jujuy · 148 m + 128 m
--
-- Seis lugares para decir cuatro líneas. La 9A y la 9B son el
-- MISMO viaje, y las dos 8 se suben a 26 m una de otra. La
-- redundancia se come los lugares donde deberían entrar las
-- alternativas de verdad.
--
-- El arreglo es el mismo criterio que ya rige el resto de la app:
-- el pasajero piensa en "la 9", no en "la 9 ramal A". Así que se
-- devuelve UNA opción por línea (la de menos caminata), no una
-- por recorrido. En un transbordo, una por PAR de líneas.
--
-- El ramal se sigue mostrando cuando IMPORTA: si de esa línea
-- hay un solo recorrido que sirve para el viaje, el ramal es
-- parte de la respuesta ("tomá la 106C") y va. Si sirven varios,
-- cualquiera lleva y decir "la 9" es más correcto que decir "la
-- 9A" — nombrar un ramal de más hace que el pasajero deje pasar
-- el otro.
--
-- Correr en: Supabase Dashboard → SQL Editor, DESPUÉS de la 0004.
-- ============================================================

-- El tipo de retorno no cambia, pero sí la lista de argumentos:
-- agregar uno con default crearía una SEGUNDA función y las
-- llamadas de 4 argumentos quedarían ambiguas. Hay que dropear.
drop function if exists public.trip_leg_json(uuid, uuid, uuid, integer);

create or replace function public.trip_leg_json(
    variant     uuid,
    board       uuid,
    alight      uuid,
    stop_count  integer,
    show_branch boolean default true
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
        -- Null cuando varios ramales de la línea hacen el mismo viaje:
        -- ahí el ramal no es información, es ruido que puede hacer que
        -- el pasajero deje pasar un colectivo que le servía.
        'branch',           case when show_branch then rv.branch else null end,
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
    'Un tramo de viaje hidratado como JSON. show_branch=false oculta el ramal, para cuando varios ramales de la línea hacen el mismo viaje';

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
-- Tramo 2, mirado AL REVÉS: desde qué parada llego caminando al destino.
-- Armarlo hacia adelante haría un producto cartesiano; así las dos
-- mitades quedan del mismo tamaño y el transbordo es un join por stop_id.
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
-- --- Un solo colectivo -----------------------------------------
direct_all as (
    select rv.line_id,
           l.variant_id,
           l.board_id,
           l.via_id                    as alight_id,
           l.via_order - l.board_order as n,
           l.walk_m                    as walk_start,
           d.walk_m                    as walk_end
    from leg1 l
    join d on d.id = l.via_id
    join public.route_variants rv on rv.id = l.variant_id
),
-- Cuántos recorridos DISTINTOS de la línea sirven para este viaje.
-- Decide si el ramal es parte de la respuesta o es ruido.
direct_branches as (
    select line_id, count(distinct variant_id) as variant_count
    from direct_all
    group by line_id
),
direct as (
    select distinct on (a.line_id)
           1                        as leg_count,
           a.variant_id             as v1,
           a.board_id               as b1,
           a.alight_id              as a1,
           a.n                      as n1,
           (b.variant_count = 1)    as show_b1,
           null::uuid               as v2,
           null::uuid               as b2,
           null::uuid               as a2,
           null::integer            as n2,
           true                     as show_b2,
           a.walk_start,
           a.walk_end
    from direct_all a
    join direct_branches b on b.line_id = a.line_id
    -- Una opción por LÍNEA, la de menos caminata: el pasajero piensa en
    -- "la 9", y ver la 9A y la 9B con el mismo viaje solo le gasta un
    -- lugar de la lista.
    order by a.line_id, a.walk_start + a.walk_end, a.n
),
-- --- Un transbordo, en la misma parada -------------------------
transfer_all as (
    select rva.line_id                     as line_a,
           rvb.line_id                     as line_b,
           a.variant_id                    as v1,
           a.board_id                      as b1,
           a.board_order                   as o1,
           a.via_id,
           a.via_order,
           a.walk_m                        as walk_start,
           b.variant_id                    as v2,
           b.board_order                   as o2,
           b.alight_id,
           b.alight_order,
           b.walk_m                        as walk_end
    from leg1 a
    join leg2 b on b.via_id = a.via_id
    join public.route_variants rva on rva.id = a.variant_id
    join public.route_variants rvb on rvb.id = b.variant_id
    -- Distinta LÍNEA, no solo distinto recorrido: "tomá la 3 y después
    -- la 3" no es una respuesta, aunque sean ramales distintos.
    where rva.line_id <> rvb.line_id
),
transfer_branches as (
    select line_a, line_b,
           count(distinct v1) as count_a,
           count(distinct v2) as count_b
    from transfer_all
    group by line_a, line_b
),
transfer as (
    select distinct on (a.line_a, a.line_b)
           2                              as leg_count,
           a.v1,
           a.b1,
           a.via_id                       as a1,
           a.via_order - a.o1             as n1,
           (b.count_a = 1)                as show_b1,
           a.v2,
           a.via_id                       as b2,
           a.alight_id                    as a2,
           a.alight_order - a.o2          as n2,
           (b.count_b = 1)                as show_b2,
           a.walk_start,
           a.walk_end
    from transfer_all a
    join transfer_branches b
      on b.line_a = a.line_a and b.line_b = a.line_b
    order by a.line_a, a.line_b,
             a.walk_start + a.walk_end,
             (a.via_order - a.o1) + (a.alight_order - a.o2)
),
ranked as (
    select *
    from (select * from direct union all select * from transfer) c
    -- Un colectivo le gana a dos, después menos caminata, después menos
    -- paradas arriba.
    order by c.leg_count,
             c.walk_start + c.walk_end,
             c.n1 + coalesce(c.n2, 0)
    limit max_results
)
select coalesce(json_agg(t order by t.leg_count, t.walk_total_m), '[]'::json)
from (
    select r.leg_count,
           round(r.walk_start)::integer as walk_to_board_m,
           round(r.walk_end)::integer   as walk_from_alight_m,
           -- Se suman los YA redondeados, no se redondea la suma: si no,
           -- la app muestra "122 m + 128 m" y un total de 249.
           round(r.walk_start)::integer
             + round(r.walk_end)::integer as walk_total_m,
           case
               when r.leg_count = 1 then
                   json_build_array(
                       public.trip_leg_json(
                           r.v1, r.b1, r.a1, r.n1, r.show_b1))
               else
                   json_build_array(
                       public.trip_leg_json(
                           r.v1, r.b1, r.a1, r.n1, r.show_b1),
                       public.trip_leg_json(
                           r.v2, r.b2, r.a2, r.n2, r.show_b2))
           end                          as legs
    from ranked r
) t;
$$;

comment on function public.plan_trip is
    'Viajes de un colectivo o un transbordo entre dos puntos, UNA opción por línea (o por par de líneas), del mejor al peor';

-- Control: el mismo par de la 0004 tendría que devolver ahora una sola
-- fila por línea (9, 8, 106, 3) en vez de repetir ramales.
--   select public.plan_trip(-27.4519, -58.9865, -27.4546, -58.9913, 500, 6);
