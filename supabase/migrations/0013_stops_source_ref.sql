-- ------------------------------------------------------------
-- 0013 — Identidad de origen para paradas que NO vienen de OSM.
--
-- Hasta acá toda parada se identificaba por `osm_node_id`, porque todas
-- salían de OpenStreetMap. Las paradas de Corrientes capital vienen del
-- GeoServer del municipio y traen su propio identificador (`gid`), que no
-- es un nodo de OSM y no puede ir en esa columna sin mentir sobre qué es.
--
-- `source_ref` es el identificador natural del origen, con prefijo: para
-- Corrientes queda 'ctes:1437'. Nullable, porque las de OSM siguen sin
-- tenerlo, y con índice único PARCIAL para que esos null no choquen entre
-- sí.
-- ------------------------------------------------------------
alter table public.stops
    add column if not exists source_ref text;

create unique index if not exists stops_source_ref_idx
    on public.stops (source_ref)
 where source_ref is not null;

comment on column public.stops.source_ref is
    'Identificador en el origen, con prefijo de red (ej. ctes:1437). Null en las paradas de OpenStreetMap, que se identifican por osm_node_id.';
