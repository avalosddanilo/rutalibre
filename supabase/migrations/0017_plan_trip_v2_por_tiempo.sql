-- ============================================================
-- RUTA LIBRE — 0017: los viajes se ordenan por lo que tardan, y tres
-- vueltas que se llamaban como su ida
--
-- 1) EL ORDEN DE plan_trip_v2.
--
-- EL PROBLEMA. Del centro de Corrientes a la Terminal de Resistencia, la
-- primera opción era: la 101 para el lado CONTRARIO hasta la cabecera
-- del 904A, y de ahí el 904A cruzando otra vez todo el centro. 89
-- paradas. Había opciones de 50.
--
-- La causa: dentro de los transbordos se ordenaba por metros caminados,
-- y las paradas solo desempataban. Y para cada par de líneas se elegía
-- la combinación que menos se caminaba, aunque diera la vuelta entera.
-- Ir hasta la cabecera tenía 1 m de transbordo; eso ganaba todo.
--
-- LA SOLUCIÓN. Se ordena por minutos estimados (caminar cuenta doble,
-- un minuto por parada), en los dos lugares: al elegir la combinación de
-- cada línea o par de líneas, y al ordenar el resultado. Los directos
-- siguen primero. Medido sobre 300 viajes al azar contra la 0015:
--   - los mismos viajes resueltos (199), y la misma cantidad de opciones
--     en 299 de 300 (en el otro sale una menos: era un 904 → 904);
--   - cambia la primera opción en 104: 12,6 paradas menos en promedio, a
--     cambio de 112 m más de caminata (minuto y medio); el peor caso, 374 m
--     más. En 19 se ahorran 20 paradas o más: los "ida y vuelta";
--   - el mismo tiempo de respuesta (~65 ms el caso de arriba).
-- Caminar contando simple (80 m = 1 parada) cambiaba 126 primeras
-- opciones con hasta 615 m más de caminata: demasiado, con este sol.
--
-- Y de paso: dos tramos del 904 (904A → 904C) ya no salen. Cada tramo
-- del 904 cruza el río, así que dos son ir a la otra orilla y volver.
-- Barranqueras → Resistencia lo daba segundo.
--
-- El JSON no cambia: mismas claves, mismo orden. La app 1.2 no se toca,
-- y `plan_trip` (la de las apps 1.0 y 1.1) tampoco.
--
-- 2) TRES VUELTAS CON EL NOMBRE AL REVÉS.
--
-- En OSM la vuelta del 904A, del 206 y del Tirol repiten el "desde →
-- hasta" de su ida, aunque sus paradas van al revés. La app le mostraba
-- "Vuelta: Terminal de Ómnibus Resistencia → Campus Corrientes" a alguien
-- que iba de Corrientes a Resistencia. El importador ya lo corrige
-- (`_fixCopiedReturnNames`) y el seed también; esto lo arregla en la
-- base sin volver a pasar el seed entero.
--
-- Correr en: Supabase Dashboard → SQL Editor, después de la 0016.
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
    -- De los recorridos de la línea, el más rápido (ver `minutos` abajo).
    order by a.line_id,
             (a.walk_start + a.walk_end) / 40.0 + a.n
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
    left join cruzan ca on ca.id = a.variant_id
    left join cruzan cb on cb.id = b.variant_id
    where rva.line_id <> rvb.line_id
      -- Dos tramos del 904 son cruzar el río y volver: cada uno cruza
      -- (la regla de la orilla), así que terminás del lado donde
      -- empezaste. Nunca es el mejor viaje, y salía segundo.
      and (ca.id is null or cb.id is null)
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
    -- Del par de líneas, la combinación más rápida, no la que menos se
    -- camina: con el orden viejo ganaba ir para el otro lado y volver.
    order by a.line_a, a.line_b,
             (a.walk_start + a.walk_mid + a.walk_end) / 40.0
               + (a.via_order - a.o1) + (a.alight_order - a.o2)
),
-- El orden: primero los directos (un boleto, una sola espera) y, dentro
-- de cada grupo, el que menos tarda. `minutos` es una estimación gruesa:
--   - caminar: 80 m por minuto, y cuenta DOBLE, porque caminar al sol
--     pesa más que ir sentado (es el "walk reluctance" de 2 que usan los
--     planificadores de transporte, OpenTripPlanner por defecto);
--   - en el colectivo: un minuto por parada.
-- Las paradas del 904 en el puente están más separadas, así que el 904
-- sale un poco "más rápido" de lo que es. No cambia el ganador en los
-- viajes medidos (ver el encabezado).
ranked as (
    select c.*,
           (c.walk_start + c.walk_mid + c.walk_end) / 40.0
             + c.n1 + coalesce(c.n2, 0) as minutos
    from (select * from direct union all select * from transfer) c
    order by c.leg_count, minutos
    limit max_results
)
select coalesce(json_agg(t.viaje order by t.leg_count, t.minutos), '[]'::json)
from (
    select r.leg_count,
           r.minutos,
           (select row_to_json(v) from (
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
           ) v)                                    as viaje
    from ranked r
) t;
$$;

comment on function public.plan_trip_v2 is
    'Como plan_trip, y además el transbordo puede ser caminando hasta otra parada a menos de max_transfer_m (campo transfer_walk_m). Ordena por minutos estimados (0017). Para la app 1.2 en adelante; plan_trip queda igual para la 1.0 y la 1.1';

update public.route_variants set name = 'Vuelta: Campus Corrientes → Terminal de Ómnibus Resistencia'
 where osm_relation_id = 14438360;  -- 904A
update public.route_variants set name = 'Vuelta: Puerto Tirol → Resistencia'
 where osm_relation_id = 15060597;  -- Tirol
update public.route_variants set name = 'Vuelta: Barranqueras → Resistencia'
 where osm_relation_id = 15540760;  -- 206

-- Controles, en este orden:
--
-- 1) El caso que motivó esto: centro de Corrientes → Terminal de
--    Resistencia. La primera opción ya no es la 101 + 904A (89 paradas):
--    tiene que tener menos de 60 paradas en total.
--      select (select sum((l->>'stop_count')::int)
--                from json_array_elements(
--                  public.plan_trip_v2(-27.4633, -58.8380, -27.45686, -59.02214)
--                  -> 0 -> 'legs') l);
--
-- 2) El cruce de la 1.2 sigue igual: Av. Independencia 5000 (Corrientes)
--    → UNNE de Resistencia (Las Heras y Cervantes) da 102 → 904A.
--      select string_agg(l->>'line_code', ' → ')
--        from json_array_elements(
--          public.plan_trip_v2(-27.48385, -58.79109, -27.46321, -58.98540)
--          -> 0 -> 'legs') l;
--
-- 3) Lo que ya andaba: dentro de Corrientes, la 102 directa sigue primera.
--      select public.plan_trip_v2(-27.48385, -58.79109, -27.46776, -58.83554)
--             -> 0 -> 'legs' -> 0 ->> 'line_code';
--
-- 4) Nunca dos tramos del 904 (tiene que dar FALSE).
--      select exists (
--        select 1
--          from json_array_elements(
--                 public.plan_trip_v2(-27.46392, -58.91516, -27.462627, -58.985006)) t
--         where t -> 'legs' -> 0 ->> 'network_code' = 'interurbano-chaco-corrientes'
--           and t -> 'legs' -> 1 ->> 'network_code' = 'interurbano-chaco-corrientes');
--
-- 5) Los nombres (tres filas, cada una "Vuelta: X → Y" al revés que su ida).
--      select name from public.route_variants
--       where osm_relation_id in (14438360, 15060597, 15540760);
