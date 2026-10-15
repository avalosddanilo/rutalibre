-- ============================================================
-- RUTA LIBRE — 0018: el planificador cuenta los metros del colectivo,
-- no solo las paradas
--
-- EL PROBLEMA. La 0017 estima el viaje en colectivo a un minuto por
-- parada. Anda porque acá las paradas están a 224 m en promedio, pero no
-- donde están lejos: en el puente Chaco–Corrientes hay tramos de casi
-- 10 km entre una parada y la siguiente, y el 904 salía "más rápido" de
-- lo que es. Al revés, una línea con paradas cada 100 m pagaba de más.
--
-- LA SOLUCIÓN.
-- 1) `route_stops.dist_m`: los metros desde la primera parada del
--    recorrido hasta cada parada, sumando las distancias en línea recta
--    entre paradas seguidas. Se usa la suma de rectas y no el trazado
--    (`st_linelocatepoint`) porque el trazado se equivoca en los
--    recorridos que pasan dos veces cerca de la misma parada (10 de 125
--    salen con las paradas fuera de orden), y la suma de rectas nunca.
--    Queda un 5% por debajo del largo por el trazado: para ordenar
--    viajes da igual.
-- 2) Un trigger la recalcula sola cuando un seed vuelve a cargar
--    `route_stops`: los seeds no se tocan.
-- 3) `plan_trip_v2` estima el tramo en colectivo como medio minuto por
--    parada más los metros a 27 km/h. Con paradas a 224 m da el mismo
--    minuto por parada de la 0017; la diferencia aparece donde las
--    paradas están lejos o muy juntas.
--
-- MEDIDO sobre 300 viajes al azar contra la 0017:
--   - los mismos viajes resueltos (190) y la misma cantidad de opciones
--     en los 300;
--   - cambia la primera opción en 35, y de línea en 10. En esos 35: 130 m
--     menos arriba del colectivo y 38 m menos de caminata en promedio, el
--     peor caso 75 m más a pie. Ejemplo: Corrientes → Resistencia ya no
--     sugiere el 904B y la 105 (30,4 km en colectivo, 791 m a pie) sino el
--     904C y la 105 (27,8 km, 580 m), aunque tenga 8 paradas más;
--   - los controles de la 0017 dan igual, y el mismo tiempo (~35 ms).
--
-- El JSON no cambia: mismas claves, mismo orden. La app 1.2 no se toca,
-- y `plan_trip` (la de las apps 1.0 y 1.1) tampoco.
--
-- Correr en: Supabase Dashboard → SQL Editor, después de la 0017.
-- ============================================================

alter table public.route_stops
    add column if not exists dist_m double precision;

comment on column public.route_stops.dist_m is
    'Metros desde la primera parada del recorrido, sumando las rectas entre paradas seguidas. La mantiene el trigger route_stops_dist (0018)';

-- Recalcula `dist_m` de los recorridos que se le pasan.
create or replace function public.refresh_route_stop_dist(variant_ids uuid[])
returns void
language sql
security invoker
set search_path = public
as $$
    with c as (
        select rs.route_variant_id,
               rs.stop_id,
               coalesce(sum(st_distance(s.geom, s_prev.geom)) over (
                   partition by rs.route_variant_id
                   order by rs.stop_order
               ), 0) as dist_m
        from (
            select rs.*,
                   lag(rs.stop_id) over (
                       partition by rs.route_variant_id
                       order by rs.stop_order
                   ) as prev_id
            from public.route_stops rs
            where rs.route_variant_id = any (variant_ids)
        ) rs
        join public.stops s           on s.id = rs.stop_id
        left join public.stops s_prev on s_prev.id = rs.prev_id
    )
    update public.route_stops rs
       set dist_m = c.dist_m
      from c
     where rs.route_variant_id = c.route_variant_id
       and rs.stop_id = c.stop_id
       and rs.dist_m is distinct from c.dist_m;
$$;

-- Escribe en la base: nadie de afuera la llama.
revoke execute on function public.refresh_route_stop_dist(uuid[])
    from public, anon, authenticated;

create or replace function public.route_stops_dist_trigger()
returns trigger
language plpgsql
security invoker
set search_path = public
as $$
begin
    -- El update de refresh_route_stop_dist vuelve a disparar el trigger
    -- de update; en esa segunda vuelta ya no cambia nada y termina.
    if pg_trigger_depth() > 1 then
        return null;
    end if;
    perform public.refresh_route_stop_dist(
        array(select distinct route_variant_id from nuevas));
    return null;
end;
$$;

revoke execute on function public.route_stops_dist_trigger()
    from public, anon, authenticated;

drop trigger if exists route_stops_dist_ins on public.route_stops;
create trigger route_stops_dist_ins
    after insert on public.route_stops
    referencing new table as nuevas
    for each statement
    execute function public.route_stops_dist_trigger();

drop trigger if exists route_stops_dist_upd on public.route_stops;
create trigger route_stops_dist_upd
    after update on public.route_stops
    referencing new table as nuevas
    for each statement
    execute function public.route_stops_dist_trigger();

-- Lo que ya está cargado.
select public.refresh_route_stop_dist(
    array(select distinct route_variant_id from public.route_stops));

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
           rs_off.stop_order        as via_order,
           coalesce(rs_off.dist_m - rs_board.dist_m,
                    (rs_off.stop_order - rs_board.stop_order) * 224.0)
                                    as bus_m
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
           d.walk_m                  as walk_m,
           coalesce(rs_off.dist_m - rs_board.dist_m,
                    (rs_off.stop_order - rs_board.stop_order) * 224.0)
                                     as bus_m
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
           d.walk_m                    as walk_end,
           l.bus_m                     as m1
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
           a.walk_end,
           a.m1,
           null::double precision   as m2
    from direct_all a
    join direct_branches b on b.line_id = a.line_id
    -- De los recorridos de la línea, el más rápido (ver `minutos` abajo).
    order by a.line_id,
             (a.walk_start + a.walk_end) / 40.0 + a.n * 0.5 + a.m1 / 450.0
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
           b.walk_m                        as walk_end,
           a.bus_m                         as m1,
           b.bus_m                         as m2
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
           a.walk_end,
           a.m1,
           a.m2
    from transfer_all a
    join transfer_branches b
      on b.line_a = a.line_a and b.line_b = a.line_b
    -- Del par de líneas, la combinación más rápida, no la que menos se
    -- camina: con el orden viejo ganaba ir para el otro lado y volver.
    order by a.line_a, a.line_b,
             (a.walk_start + a.walk_mid + a.walk_end) / 40.0
               + ((a.via_order - a.o1) + (a.alight_order - a.o2)) * 0.5
               + (a.m1 + a.m2) / 450.0
),
-- El orden: primero los directos (un boleto, una sola espera) y, dentro
-- de cada grupo, el que menos tarda. `minutos` es una estimación gruesa:
--   - caminar: 80 m por minuto, y cuenta DOBLE, porque caminar al sol
--     pesa más que ir sentado (es el "walk reluctance" de 2 que usan los
--     planificadores de transporte, OpenTripPlanner por defecto);
--   - en el colectivo (0018): medio minuto por parada (frenar, que suba
--     la gente) más los metros a 27 km/h. Con las paradas a 224 m, el
--     promedio de acá, da el mismo minuto por parada de la 0017; donde
--     están lejos, como en el puente, ahora cuenta lo que se anda.
ranked as (
    select c.*,
           (c.walk_start + c.walk_mid + c.walk_end) / 40.0
             + (c.n1 + coalesce(c.n2, 0)) * 0.5
             + (c.m1 + coalesce(c.m2, 0)) / 450.0 as minutos
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

comment on function public.plan_trip_v2 is
    'Como plan_trip, y además el transbordo puede ser caminando hasta otra parada a menos de max_transfer_m (campo transfer_walk_m). Ordena por minutos estimados: caminata, paradas y metros en colectivo (0018). Para la app 1.2 en adelante; plan_trip queda igual para la 1.0 y la 1.1';

-- Controles, en este orden:
--
-- 1) Todas las paradas de todos los recorridos tienen distancia, y nunca
--    baja a lo largo de un recorrido (tiene que dar 0 | 0).
--      select count(*) filter (where dist_m is null),
--             (select count(*) from (
--                select dist_m < lag(dist_m) over (
--                         partition by route_variant_id order by stop_order) as baja
--                  from public.route_stops) x where baja)
--        from public.route_stops;
--
-- 2) Los cuatro de la 0017 siguen igual:
--    centro de Corrientes → Terminal de Resistencia: 46 paradas.
--      select (select sum((l->>'stop_count')::int)
--                from json_array_elements(
--                  public.plan_trip_v2(-27.4633, -58.8380, -27.45686, -59.02214)
--                  -> 0 -> 'legs') l);
--    Av. Independencia 5000 → UNNE de Resistencia: 102 → 904A.
--      select string_agg(l->>'line_code', ' → ')
--        from json_array_elements(
--          public.plan_trip_v2(-27.48385, -58.79109, -27.46321, -58.98540)
--          -> 0 -> 'legs') l;
--    Dentro de Corrientes, la 102 directa primera.
--      select public.plan_trip_v2(-27.48385, -58.79109, -27.46776, -58.83554)
--             -> 0 -> 'legs' -> 0 ->> 'line_code';
--    Nunca dos tramos del 904 (FALSE).
--      select exists (
--        select 1
--          from json_array_elements(
--                 public.plan_trip_v2(-27.46392, -58.91516, -27.462627, -58.985006)) t
--         where t -> 'legs' -> 0 ->> 'network_code' = 'interurbano-chaco-corrientes'
--           and t -> 'legs' -> 1 ->> 'network_code' = 'interurbano-chaco-corrientes');
