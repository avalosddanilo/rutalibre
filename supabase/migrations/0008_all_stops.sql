-- ============================================================
-- RUTA LIBRE — 0008: el listado completo de paradas
--
-- Para qué: buscar el destino ESCRIBIENDO. Hasta ahora "¿cómo
-- llego?" obligaba a ubicar el destino a ojo en el mapa; si uno
-- quiere ir a "Ameghino y Sáenz Peña" y no sabe dónde cae, la
-- función no le sirve. Con las 1416 paradas en el teléfono, el
-- buscador es instantáneo y funciona sin señal.
--
-- Por qué TODAS de una vez y no un RPC de búsqueda por texto:
-- son ~1416 filas livianas (id, nombre, dos números) que cambian
-- una vez cada reimportación. Bajarlas UNA vez y cachearlas gana
-- contra un viaje a la red por cada tecla, que además dejaría el
-- buscador inservible en el colectivo sin señal — que es
-- exactamente dónde se usa.
--
-- Por qué un RPC y no `select * from stops`: PostgREST devuelve
-- `geography` como WKB hexadecimal, inparseable en Flutter. El
-- RPC calcula lat/lng con PostGIS y manda números.
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
               st_y(s.geom::geometry) as lat,
               st_x(s.geom::geometry) as lng
        from public.stops s
        where s.is_active
    ) t;
$$;

comment on function public.get_all_stops is
    'Todas las paradas activas como JSON [{id,name,description,lat,lng}], ordenadas por nombre. Para el buscador de destino, que trabaja sobre una copia local';

-- Control: debería devolver 1416 en el Gran Resistencia.
--   select json_array_length(public.get_all_stops());
