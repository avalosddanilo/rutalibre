-- ============================================================
-- RUTA LIBRE — 0007: search_path fijo en nuestras funciones
--
-- El linter marca "Function Search Path Mutable" en las siete
-- funciones nuestras. A diferencia de los avisos de PostGIS,
-- ESTE ES NUESTRO Y ES REAL.
--
-- Qué pasa sin esto: una función sin `search_path` propio
-- resuelve los nombres SIN CALIFICAR usando el search_path de
-- QUIEN LA LLAMA. Nuestros cuerpos califican las tablas
-- (`public.route_stops`), pero NO las funciones de PostGIS:
-- `st_distance(...)`, `st_point(...)`, `st_dwithin(...)`. Si
-- alguien llama al RPC con un search_path que antepone un
-- esquema suyo con una `st_distance` propia, esa es la que se
-- ejecuta. Es el CVE-2018-1058 clásico.
--
-- Se fija en `public` y no en `''` porque PostGIS está instalado
-- ahí: con el search_path vacío habría que calificar cada `st_*`
-- a mano, y la primera función nueva que se olvide se rompería en
-- runtime en vez de fallar al crearse.
--
-- `pg_temp` NO se incluye a propósito: nombrarlo lo vuelve
-- buscable, y una tabla temporal puede tapar a una real. Ninguna
-- de estas funciones usa objetos temporales.
--
-- POR QUÉ UN LOOP Y NO SIETE `alter function` A MANO: escribir
-- las firmas a mano ata esta migración al ORDEN en que se
-- corrieron las otras. La primera versión de este archivo listaba
-- `trip_leg_json(uuid, uuid, uuid, integer, boolean)` —la firma
-- que crea la 0005— y explotaba con "function does not exist" en
-- cualquier base donde la 0005 todavía no se hubiera aplicado.
-- Buscando en `pg_proc` se agarra la firma que HAY, sea cual sea,
-- y las funciones que todavía no existen simplemente no aparecen.
-- Se puede correr en cualquier momento y las veces que haga falta.
--
-- Correr en: Supabase Dashboard → SQL Editor.
-- ============================================================

do $$
declare
    fn        record;
    encontradas int := 0;
begin
    for fn in
        select p.oid::regprocedure as firma
        from pg_proc p
        join pg_namespace n on n.oid = p.pronamespace
        where n.nspname = 'public'
          and p.proname in (
              'get_route_geojson',
              'get_stops_for_route',
              'get_nearby_stops',
              'get_lines_for_stop',
              'trip_leg_json',
              'plan_trip',
              'set_updated_at'
          )
    loop
        execute format(
            'alter function %s set search_path = public', fn.firma
        );
        encontradas := encontradas + 1;
        raise notice 'search_path fijado en %', fn.firma;
    end loop;

    raise notice '% función(es) endurecida(s).', encontradas;
    if encontradas < 7 then
        raise notice 'Son menos de 7: faltan migraciones por correr. Volver a correr esta después.';
    end if;
end;
$$;

-- ------------------------------------------------------------
-- Control: las siete tienen que aparecer con search_path=public.
-- El editor de Supabase no muestra los NOTICE, así que esta
-- consulta es la que dice de verdad si funcionó.
-- ------------------------------------------------------------
-- select p.oid::regprocedure as funcion,
--        coalesce(array_to_string(p.proconfig, ', '), '(SIN FIJAR)') as config
--   from pg_proc p
--   join pg_namespace n on n.oid = p.pronamespace
--  where n.nspname = 'public'
--    and p.proname in ('get_route_geojson', 'get_stops_for_route',
--                      'get_nearby_stops', 'get_lines_for_stop',
--                      'trip_leg_json', 'plan_trip', 'set_updated_at')
--  order by 1;
