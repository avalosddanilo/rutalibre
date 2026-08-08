-- ============================================================
-- RUTA LIBRE — Migración 0002: RPCs de paradas con lat/lng planos
--
-- Por qué: PostgREST serializa las columnas geometry/geography como
-- WKB hexadecimal. Devolver `setof stops` (como hacía get_nearby_stops
-- de la 0001) obliga al cliente a parsear WKB. Estos RPCs devuelven
-- JSON con lat/lng calculados por PostGIS: Flutter solo lee números.
--
-- Correr en: Supabase Dashboard → SQL Editor, o `supabase db push`.
-- ============================================================

-- Paradas de un recorrido, en orden de paso (stop_order 1 = cabecera).
-- El cliente lo usa para getStopsForRoute.
create or replace function public.get_stops_for_route(variant_id uuid)
returns json
language sql
stable
security invoker
as $$
    select coalesce(json_agg(t), '[]'::json)
    from (
        select s.id,
               s.name,
               s.description,
               st_y(s.geom::geometry) as lat,
               st_x(s.geom::geometry) as lng,
               rs.stop_order
        from public.route_stops rs
        join public.stops s on s.id = rs.stop_id
        where rs.route_variant_id = variant_id
          and s.is_active
        order by rs.stop_order
    ) t;
$$;

comment on function public.get_stops_for_route is
    'Paradas de un recorrido como JSON [{id,name,description,lat,lng,stop_order}], ordenadas por stop_order';

-- Reemplaza la versión de 0001 (retornaba setof stops con geom en WKB).
-- Cambia el tipo de retorno → hay que dropear antes de recrear.
drop function if exists public.get_nearby_stops(double precision, double precision, integer);

create function public.get_nearby_stops(lat double precision, lng double precision, radius_m integer default 500)
returns json
language sql
stable
security invoker
as $$
    select coalesce(json_agg(t), '[]'::json)
    from (
        select s.id,
               s.name,
               s.description,
               st_y(s.geom::geometry) as lat,
               st_x(s.geom::geometry) as lng,
               st_distance(s.geom, st_point(lng, lat)::geography) as distance_m
        from public.stops s
        where s.is_active
          and st_dwithin(s.geom, st_point(lng, lat)::geography, radius_m)
        order by s.geom <-> st_point(lng, lat)::geography
    ) t;
$$;

comment on function public.get_nearby_stops is
    'Paradas dentro de radius_m metros como JSON [{id,name,description,lat,lng,distance_m}], ordenadas por distancia';

-- Smoke test rápido (opcional):
--   select public.get_nearby_stops(-27.4512, -58.9866, 800);
--   select public.get_stops_for_route('<uuid de un route_variant>');
