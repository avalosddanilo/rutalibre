-- ============================================================
-- RUTA LIBRE — 0010: el nodo de OSM viaja hasta la app
--
-- Para qué: que se pueda CORREGIR una parada. Una que se levantó
-- en la realidad pero que OpenStreetMap todavía mapea es
-- indistinguible de una vigente — no hay dato nuestro que la
-- delate, y la única forma de arreglarla es editar OSM. Con el
-- nodo a mano, eso pasa de "buscala en el editor" a un toque
-- desde la parada que uno está mirando en el mapa.
--
-- La columna ya existe desde la 0003 (`stops.osm_node_id`, con
-- índice único) y el seed la llena: lo único que faltaba era que
-- los RPCs la devolvieran. Acá se agrega a los cuatro lugares
-- por donde una parada llega al cliente, para que el enlace
-- aparezca igual sin importar de dónde se tocó:
--
--   get_all_stops        capa de fondo del mapa y buscador
--   get_stops_for_route  paradas del recorrido elegido
--   get_nearby_stops     "cerca mío"
--   trip_leg_json        las paradas de subida y bajada del viaje
--
-- Los cuatro son `create or replace` con el MISMO tipo de retorno
-- y la misma firma, así que no hay que dropear nada y las
-- llamadas del cliente no cambian.
--
-- La app tolera que falte (`Stop.osmNodeId` es nullable): sin
-- esta migración se comporta como antes, solo que sin el enlace.
--
-- Correr en: Supabase Dashboard → SQL Editor.
-- ============================================================

create or replace function public.get_all_stops()
returns json
language sql
stable
security invoker
set search_path = public
as $$
    select coalesce(json_agg(t order by t.name), '[]'::json)
    from (
        select s.id,
               s.name,
               s.description,
               s.osm_node_id,
               st_y(s.geom::geometry) as lat,
               st_x(s.geom::geometry) as lng
        from public.stops s
        where s.is_active
    ) t;
$$;

comment on function public.get_all_stops is
    'Todas las paradas activas como JSON [{id,name,description,osm_node_id,lat,lng}], ordenadas por nombre. Para el buscador de destino, que trabaja sobre una copia local';

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
               s.osm_node_id,
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
    'Paradas de un recorrido como JSON [{id,name,description,osm_node_id,lat,lng,stop_order}], ordenadas por stop_order';

create or replace function public.get_nearby_stops(lat double precision, lng double precision, radius_m integer default 500)
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
               s.osm_node_id,
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
    'Paradas dentro de radius_m metros como JSON [{id,name,description,osm_node_id,lat,lng,distance_m}], ordenadas por distancia';

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
            'osm_node_id', bs.osm_node_id,
            'lat',         st_y(bs.geom::geometry),
            'lng',         st_x(bs.geom::geometry)),
        'alight_stop', json_build_object(
            'id',          als.id,
            'name',        als.name,
            'description', als.description,
            'osm_node_id', als.osm_node_id,
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

-- Control: ninguna parada activa debería quedar sin nodo de OSM.
--   select count(*) from public.stops where is_active and osm_node_id is null;
-- Y que el RPC lo esté devolviendo:
--   select (public.get_all_stops() -> 0) ->> 'osm_node_id';
