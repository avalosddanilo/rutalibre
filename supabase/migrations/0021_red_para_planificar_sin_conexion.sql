-- ============================================================
-- RUTA LIBRE — 0021: la red entera, para planificar sin conexión
--
-- PARA QUÉ. Hoy "¿cómo llego?" corre en el servidor (plan_trip_v2): sin
-- señal, no hay viaje. El teléfono ya guarda las líneas y todas las
-- paradas, pero las paradas de cada recorrido las baja de a una, cuando
-- alguien abre ese recorrido. Con esto las baja todas juntas, una vez, y
-- un planificador en el teléfono puede contestar lo mismo que el servidor.
--
-- QUÉ DEVUELVE. Cada recorrido activo con su línea, nombre, ramal,
-- sentido y la secuencia de paradas con los metros desde la primera
-- (`dist_m`, de la 0018). Las paradas mismas no van: el teléfono ya las
-- tiene por get_all_stops. Son ~300 KB de JSON para toda la red.
--
-- Solo lectura, `security invoker`, mismas reglas que el resto: no cambia
-- nada para quien no lo use.
--
-- Correr en: Supabase Dashboard → SQL Editor, después de la 0018.
-- ============================================================

create or replace function public.get_planner_network()
returns json
language sql
stable
security invoker
set search_path = public
as $$
    select json_build_object(
        'v', 1,
        'variants', coalesce(json_agg(t order by t.line_id, t.id), '[]'::json))
    from (
        select rv.id,
               rv.line_id,
               rv.name,
               rv.branch,
               rv.direction,
               (select json_agg(rs.stop_id order by rs.stop_order)
                  from public.route_stops rs
                 where rs.route_variant_id = rv.id) as stops,
               (select json_agg(round(coalesce(rs.dist_m, 0))::integer
                                order by rs.stop_order)
                  from public.route_stops rs
                 where rs.route_variant_id = rv.id) as dist
          from public.route_variants rv
         where rv.is_active
           and exists (select 1 from public.route_stops rs
                        where rs.route_variant_id = rv.id)
    ) t;
$$;

comment on function public.get_planner_network is
    'Los recorridos activos con su secuencia de paradas y los metros desde la primera, para el planificador sin conexión de la app (0021)';

-- Control: tiene que dar la cantidad de recorridos con paradas (~130) y
-- ningún recorrido con distinta cantidad de paradas que de distancias.
--   select json_array_length(public.get_planner_network() -> 'variants');
--   select count(*)
--     from json_array_elements(public.get_planner_network() -> 'variants') v
--    where json_array_length(v -> 'stops') <> json_array_length(v -> 'dist');
