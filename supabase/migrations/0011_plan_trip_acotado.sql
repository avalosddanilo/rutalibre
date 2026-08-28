-- ============================================================
-- RUTA LIBRE — 0011: plan_trip ACOTADO — el timeout de los viajes cortos
--
-- El síntoma, medido contra la base real el 28/8/2026: los viajes
-- CORTOS (las dos puntas dentro de Resistencia) morían en el
-- statement timeout (57014, ~3 s) mientras el viaje largo a
-- Corrientes contestaba en 0,3 s. Al revés de toda intuición — y
-- por eso el bug vivió tanto: las pruebas "canónicas" usaban el
-- viaje largo, cuyo secreto es que el destino tiene UNA parada
-- cerca. En el centro hay decenas de paradas cerca de cada punta,
-- y ahí el planificador viejo se ahogaba.
--
-- Dos causas y este archivo ataca las dos:
--
-- 1. Las CTEs de cercanía (o, d) y los tramos (leg1, leg2) se
--    INLINEABAN: Postgres puede expandir una CTE dentro de quien
--    la usa, y leg1 se usa DOS veces (directos y transbordos) —
--    el trabajo geográfico y el self-join se hacían por duplicado
--    y por fila. `as materialized` los calcula UNA vez cada uno.
--
-- 2. Los tramos no estaban acotados: leg1 devolvía TODAS las
--    combinaciones (subida cercana × bajada posterior), y el join
--    del transbordo multiplicaba esas listas entre sí. Para elegir
--    el mejor viaje no hacen falta todas: por cada (recorrido,
--    parada de paso) alcanza con LA MEJOR subida (menos caminata;
--    a igual caminata, la más cercana a la bajada). `distinct on`
--    deja los tramos en a lo sumo una fila por fila de
--    route_stops (~3.000), y todo lo de abajo queda chico.
--
-- El contrato no cambia: misma firma, mismo JSON, mismo criterio
-- de ranking (un colectivo antes que dos, menos caminata, menos
-- paradas arriba). Puede cambiar el desempate FINO entre subidas
-- con exactamente la misma caminata total — se elige la de menos
-- paradas a bordo, que es lo que el orden viejo también premiaba.
--
-- Correr en: Supabase Dashboard → SQL Editor, DESPUÉS de la 0005.
-- Verificar con el "control" del final ANTES de cerrar la pestaña.
-- ============================================================

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
with o as materialized (
    select s.id, st_distance(s.geom, st_point(origin_lng, origin_lat)::geography) as walk_m
    from public.stops s
    where s.is_active
      and st_dwithin(s.geom, st_point(origin_lng, origin_lat)::geography, max_walk_m)
),
d as materialized (
    select s.id, st_distance(s.geom, st_point(dest_lng, dest_lat)::geography) as walk_m
    from public.stops s
    where s.is_active
      and st_dwithin(s.geom, st_point(dest_lng, dest_lat)::geography, max_walk_m)
),
-- Tramo 1, ACOTADO: por cada (recorrido, parada de paso), la mejor
-- subida cercana al origen que la precede. Una fila por fila de
-- route_stops como mucho — antes eran todas las combinaciones.
leg1 as materialized (
    select distinct on (rs_off.route_variant_id, rs_off.stop_id)
           rs_off.route_variant_id  as variant_id,
           rs_board.stop_id         as board_id,
           rs_board.stop_order      as board_order,
           o.walk_m                 as walk_m,
           rs_off.stop_id           as via_id,
           rs_off.stop_order        as via_order
    from public.route_stops rs_board
    join o                        on o.id = rs_board.stop_id
    join public.route_variants rv on rv.id = rs_board.route_variant_id
                                 and rv.is_active
    join public.route_stops rs_off
      on rs_off.route_variant_id = rs_board.route_variant_id
     and rs_off.stop_order > rs_board.stop_order
    order by rs_off.route_variant_id, rs_off.stop_id,
             o.walk_m, rs_board.stop_order desc
),
-- Tramo 2, mirado al revés y con el mismo recorte: por cada
-- (recorrido, parada de paso), la mejor bajada que llega al destino.
leg2 as materialized (
    select distinct on (rs_board.route_variant_id, rs_board.stop_id)
           rs_board.route_variant_id as variant_id,
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
    order by rs_board.route_variant_id, rs_board.stop_id,
             d.walk_m, rs_off.stop_order
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
    'Viajes de un colectivo o un transbordo entre dos puntos, UNA opción por línea (o por par de líneas), del mejor al peor. 0011: CTEs materializadas y tramos acotados — los viajes cortos morían en el statement timeout';

-- Estadísticas frescas para que el planner arranque bien parado.
analyze public.stops;
analyze public.route_stops;
analyze public.route_variants;
analyze public.lines;

-- Control (el viaje CORTO, que era el que moría — tiene que volver en
-- menos de un segundo con resultados):
--   select public.plan_trip(-27.4519, -58.9865, -27.4546, -58.9913, 500, 6);
