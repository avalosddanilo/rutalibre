-- ============================================================
-- RUTA LIBRE — 0015: transbordo caminando (plan_trip_v2)
--
-- EL PROBLEMA. Desde Corrientes capital no se podía armar un viaje a
-- Resistencia, ni de Resistencia a un barrio de Corrientes lejos del
-- recorrido del 904. Por ejemplo, Av. Independencia 5000 (Corrientes) →
-- Plaza 25 de Mayo (Resistencia) daba `[]`.
--
-- La causa no es que falte un colectivo: la 102 llega al centro y el
-- 904 cruza el puente. Es que `plan_trip` solo sabe hacer el transbordo
-- en la MISMA parada (`join leg2 b on b.via_id = a.via_id`), y las dos
-- redes no comparten ninguna: las paradas del 904 salen de
-- OpenStreetMap y las urbanas de Corrientes de la Municipalidad. Están
-- en las mismas esquinas, pero son filas distintas. De las 20 paradas
-- del 904 del lado correntino, 18 tienen una municipal a menos de
-- 150 m y las 20 a menos de 250 m (mediana: 22 m).
--
-- LA SOLUCIÓN. El segundo colectivo se puede tomar en una parada
-- distinta de donde te bajaste del primero, si está a menos de
-- `max_transfer_m` caminando (250 m por defecto, en línea recta). Vale
-- para cualquier par de líneas, no solo para el 904: cruzar la avenida
-- para tomar otra línea es un transbordo de verdad en el Gran
-- Resistencia también. La caminata del medio suma a la caminata total,
-- así que el transbordo en la misma parada (0 m) sigue ganando cuando
-- existe.
--
-- POR QUÉ UNA FUNCIÓN NUEVA Y NO OTRO `create or replace` DE
-- plan_trip. La app 1.0 y 1.1 dan por hecho que el transbordo es en la
-- misma parada: dicen "Te cambiás a la X en la misma parada", no
-- dibujan la subida del segundo tramo y la guía no tiene un paso de
-- caminata en el medio. Si `plan_trip` empezara a devolver transbordos
-- caminando, esos teléfonos le dirían a alguien que espere en una
-- esquina donde ese colectivo no para. Por eso `plan_trip` queda
-- EXACTAMENTE como la dejó la 0012 y la app nueva llama a
-- `plan_trip_v2`. Cuando ya nadie use la 1.1, `plan_trip` se puede
-- volver un envoltorio de esta.
--
-- EL CONTRATO. El mismo JSON que `plan_trip`, con un campo más por
-- viaje:
--   transfer_walk_m  metros a pie entre la bajada del primer tramo y la
--                    subida del segundo (0 en los directos y en los
--                    transbordos en la misma parada).
--   walk_total_m     ahora incluye transfer_walk_m.
-- Y en los transbordos, `legs[1].board_stop` puede ser distinta de
-- `legs[0].alight_stop`. Ese es todo el cambio.
--
-- El resto se hereda tal cual de la 0012: el 904 solo de una orilla a
-- la otra, una opción por línea o par de líneas, el mismo ranking.
--
-- Correr en: Supabase Dashboard → SQL Editor, DESPUÉS de la 0014.
-- Verificar con los controles del final.
-- ============================================================

create or replace function public.plan_trip_v2(
    origin_lat     double precision,
    origin_lng     double precision,
    dest_lat       double precision,
    dest_lng       double precision,
    max_walk_m     integer default 500,
    max_results    integer default 6,
    max_transfer_m integer default 250
)
returns json
language sql
stable
security invoker
set search_path = public
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
-- El 904 y su regla del río: idénticos a la 0012.
cruzan as materialized (
    select rv.id
    from public.route_variants rv
    join public.lines l    on l.id = rv.line_id
    join public.networks n on n.id = l.network_id
    where n.code = 'interurbano-chaco-corrientes'
),
orilla as materialized (
    select distinct rs.stop_id,
           st_x(s.geom::geometry) > -58.86 as corrientes
    from public.route_stops rs
    join cruzan c       on c.id = rs.route_variant_id
    join public.stops s on s.id = rs.stop_id
),
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
    left join cruzan c  on c.id = rv.id
    left join orilla ob on c.id is not null and ob.stop_id = rs_board.stop_id
    left join orilla oa on c.id is not null and oa.stop_id = rs_off.stop_id
    where c.id is null
       or ob.corrientes <> oa.corrientes
    order by rs_off.route_variant_id, rs_off.stop_id,
             o.walk_m, rs_board.stop_order desc
),
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
    left join cruzan c  on c.id = rv.id
    left join orilla ob on c.id is not null and ob.stop_id = rs_board.stop_id
    left join orilla oa on c.id is not null and oa.stop_id = rs_off.stop_id
    where c.id is null
       or ob.corrientes <> oa.corrientes
    order by rs_board.route_variant_id, rs_board.stop_id,
             d.walk_m, rs_off.stop_order
),
-- --- LO NUEVO: dónde se puede hacer el cambio -------------------
-- Cada parada donde se baja alguien del tramo 1, con cada parada a
-- menos de `max_transfer_m` donde sube alguien del tramo 2. Incluye la
-- misma parada (0 m), que es el transbordo de siempre.
--
-- Se arma sobre las paradas DISTINTAS de cada lado —unas cientos, no
-- las miles de filas de leg1 y leg2— y la búsqueda por distancia usa el
-- índice GiST de stops.geom, así que no es un producto cartesiano.
bajadas as materialized (
    select distinct l.via_id as id
    from leg1 l
),
subidas as materialized (
    select distinct l.via_id as id
    from leg2 l
),
cambio as materialized (
    select b.id                        as from_id,
           s.id                        as to_id,
           st_distance(sb.geom, s.geom) as walk_m
    from bajadas b
    join public.stops sb on sb.id = b.id
    join public.stops s  on s.is_active
                        and st_dwithin(sb.geom, s.geom, max_transfer_m)
    join subidas su      on su.id = s.id
),
-- --- Un solo colectivo (igual que la 0012) ---------------------
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
           0::double precision      as walk_mid,
           a.walk_end
    from direct_all a
    join direct_branches b on b.line_id = a.line_id
    order by a.line_id, a.walk_start + a.walk_end, a.n
),
-- --- Un transbordo, en la misma parada o caminando -------------
transfer_all as (
    select rva.line_id                     as line_a,
           rvb.line_id                     as line_b,
           a.variant_id                    as v1,
           a.board_id                      as b1,
           a.board_order                   as o1,
           a.via_id                        as off_id,
           a.via_order,
           a.walk_m                        as walk_start,
           c.walk_m                        as walk_mid,
           b.variant_id                    as v2,
           b.via_id                        as on_id,
           b.board_order                   as o2,
           b.alight_id,
           b.alight_order,
           b.walk_m                        as walk_end
    from leg1 a
    join cambio c on c.from_id = a.via_id
    join leg2 b   on b.via_id = c.to_id
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
           a.off_id                       as a1,
           a.via_order - a.o1             as n1,
           (b.count_a = 1)                as show_b1,
           a.v2,
           a.on_id                        as b2,
           a.alight_id                    as a2,
           a.alight_order - a.o2          as n2,
           (b.count_b = 1)                as show_b2,
           a.walk_start,
           a.walk_mid,
           a.walk_end
    from transfer_all a
    join transfer_branches b
      on b.line_a = a.line_a and b.line_b = a.line_b
    order by a.line_a, a.line_b,
             a.walk_start + a.walk_mid + a.walk_end,
             (a.via_order - a.o1) + (a.alight_order - a.o2)
),
ranked as (
    select *
    from (select * from direct union all select * from transfer) c
    order by c.leg_count,
             c.walk_start + c.walk_mid + c.walk_end,
             c.n1 + coalesce(c.n2, 0)
    limit max_results
)
select coalesce(json_agg(t order by t.leg_count, t.walk_total_m), '[]'::json)
from (
    select r.leg_count,
           round(r.walk_start)::integer as walk_to_board_m,
           round(r.walk_end)::integer   as walk_from_alight_m,
           round(r.walk_mid)::integer   as transfer_walk_m,
           round(r.walk_start)::integer
             + round(r.walk_mid)::integer
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

comment on function public.plan_trip_v2 is
    'Como plan_trip, y además el transbordo puede ser caminando hasta otra parada a menos de max_transfer_m (campo transfer_walk_m). Para la app 1.2 en adelante; plan_trip queda igual para la 1.0 y la 1.1';

-- Controles, en este orden:
--
-- 1) El viaje que motivó esto: Av. Independencia 5000 (Corrientes) →
--    Plaza 25 de Mayo (Resistencia). Con plan_trip da 0; con
--    plan_trip_v2 tiene que dar viajes, y alguno con el 904.
--      select json_array_length(public.plan_trip(-27.48385, -58.79109, -27.4512, -58.9867));
--      select json_array_length(public.plan_trip_v2(-27.48385, -58.79109, -27.4512, -58.9867));
--      select public.plan_trip_v2(-27.48385, -58.79109, -27.4512, -58.9867)::text
--             like '%interurbano-chaco-corrientes%';
--
-- 2) Lo que ya andaba sigue andando: dentro de Corrientes, la 102
--    directa sigue primera.
--      select public.plan_trip_v2(-27.48385, -58.79109, -27.46776, -58.83554)
--             -> 0 -> 'legs' -> 0 ->> 'line_code';
--
-- 3) La regla del río sigue: Barranqueras → Resistencia sin el 904
--    (FALSE).
--      select public.plan_trip_v2(-27.46392, -58.91516, -27.462627, -58.985006)::text
--             like '%interurbano-chaco-corrientes%';
--
-- 4) Y plan_trip NO cambió: la app 1.0 y 1.1 siguen recibiendo lo
--    mismo que ayer. (Esta migración no la toca.)
