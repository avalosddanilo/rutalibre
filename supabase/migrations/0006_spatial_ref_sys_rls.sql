-- ============================================================
-- RUTA LIBRE — 0006: RLS en spatial_ref_sys (aviso del linter)
--
-- QUÉ ES: `public.spatial_ref_sys` no la creamos nosotros. La crea
-- `create extension postgis` (migración 0001), y es el catálogo de
-- sistemas de coordenadas: ~8500 filas con las definiciones EPSG,
-- la MISMA data que el registro EPSG publica abierta. No hay un
-- solo dato de usuario adentro.
--
-- POR QUÉ DICE "Critical": es la severidad fija de la regla
-- "tabla sin RLS en un esquema expuesto a PostgREST". La regla
-- existe porque eso normalmente significa datos de gente legibles
-- por cualquiera. Acá significa que un anónimo puede leer que el
-- EPSG 4326 es WGS84. Se arregla igual: una advertencia crítica
-- que se ignora es la que va a tapar la próxima que sí importe.
--
-- LA POLICY ES PERMISIVA A PROPÓSITO. Habilitar RLS sin policy
-- dejaría la tabla ilegible, y hay funciones de PostGIS que la
-- consultan (st_transform, sobre todo). Hoy la app no usa
-- ninguna de esas —solo st_point/st_x/st_y/st_dwithin/st_distance
-- sobre geography 4326 y st_asgeojson, que resuelven con el
-- esferoide compilado—, pero dejarla ilegible sería poner una
-- trampa para el día que alguien reproyecte algo.
--
-- PUEDE QUE NO SE PUEDA. La tabla es de la extensión y en Supabase
-- hosted suele pertenecer a otro rol; ahí `alter table` falla con
-- "must be owner". Por eso va dentro de un bloque que atrapa ese
-- error y avisa, en vez de tumbar la migración. Este script SOLO
-- puede arreglar o no hacer nada: nunca deja la base peor.
--
-- Correr en: Supabase Dashboard → SQL Editor. Mirar los NOTICE.
-- ============================================================

do $$
begin
    alter table public.spatial_ref_sys enable row level security;

    if not exists (
        select 1 from pg_policies
        where schemaname = 'public'
          and tablename  = 'spatial_ref_sys'
          and policyname = 'public read spatial_ref_sys'
    ) then
        create policy "public read spatial_ref_sys"
            on public.spatial_ref_sys for select using (true);
    end if;

    raise notice 'OK: RLS habilitada en spatial_ref_sys con lectura pública. El aviso del linter tiene que desaparecer.';

exception
    when insufficient_privilege then
        raise notice 'NO SE PUDO: spatial_ref_sys pertenece a la extensión PostGIS y este rol no la posee.';
        raise notice 'El aviso va a seguir apareciendo. Es aceptable: la tabla solo tiene el catálogo EPSG, que es público.';
        raise notice 'Si molesta, la otra salida es sacar PostGIS del esquema public, y eso SÍ puede romper cosas: no vale la pena por esto.';
end;
$$;

-- Control: debería decir rowsecurity = true si funcionó.
--   select relname, relrowsecurity
--     from pg_class where relname = 'spatial_ref_sys';
