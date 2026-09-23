-- ============================================================
-- RUTA LIBRE — 0014: sacarle la escritura a `anon` sobre
-- spatial_ref_sys
--
-- POR QUÉ ESTA MIGRACIÓN EXISTE APARTE DE LA 0006. La 0006 fue a
-- buscar RLS, que es el aviso que tira el linter. Mirando los
-- GRANT apareció algo peor y que el linter NO avisa:
--
--     select grantee, privilege_type
--       from information_schema.role_table_grants
--      where table_name = 'spatial_ref_sys';
--
--     anon → SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
--
-- O sea: cualquiera con la anon key —que es pública por diseño y
-- está en el repo— podía hacer `DELETE` sobre el catálogo EPSG por
-- PostgREST. No hay datos de usuario adentro, pero vaciarlo rompe
-- st_transform y cualquier reproyección futura. Es la única cosa
-- escribible por un anónimo en toda la base.
--
-- DE DÓNDE SALIÓ: nadie lo escribió a mano. Supabase corre
-- `grant all on all tables in schema public to anon, authenticated`
-- al crear el proyecto, y PostGIS creó su tabla en `public`
-- (migración 0001), así que le tocó el reparto.
--
-- POR QUÉ NO ALCANZABA CON LA 0006. RLS y GRANT son dos rejas
-- distintas: PostgREST primero mira el GRANT y después la policy.
-- Y si la 0006 no pudo habilitar RLS —que es lo más probable,
-- porque la tabla es de la extensión— entonces el GRANT es lo
-- ÚNICO que está frenando algo. Por eso esta va sí o sí, funcione
-- la otra o no.
--
-- SELECT SE QUEDA. Leer el catálogo EPSG es inofensivo (es data
-- pública del registro EPSG) y hay funciones de PostGIS que lo
-- consultan. Lo que se saca es todo lo que escribe.
--
-- PUEDE FALLAR, IGUAL QUE LA 0006. `revoke` lo tiene que correr
-- quien otorgó el permiso; si la tabla es de `supabase_admin`, el
-- rol del SQL Editor no puede. Por eso va en un bloque que atrapa
-- el error y avisa, en vez de tumbar la migración. Este script
-- SOLO puede arreglar o no hacer nada: nunca deja la base peor.
--
-- Correr en: Supabase Dashboard → SQL Editor. LEER LOS NOTICE.
-- ============================================================

do $$
begin
    revoke insert, update, delete, truncate, references, trigger
        on public.spatial_ref_sys
      from anon, authenticated;

    raise notice 'OK: se intentó el revoke sin error. Verificá con la consulta de control de abajo: anon tiene que quedar SOLO con SELECT.';

exception
    when insufficient_privilege then
        raise notice 'NO SE PUDO: spatial_ref_sys pertenece a otro rol (la extensión PostGIS) y este rol no puede revocar lo que no otorgó.';
        raise notice 'ESTO SÍ HAY QUE RESOLVER, no es como el aviso de RLS: un anónimo puede escribir el catálogo EPSG.';
        raise notice 'Salida: abrir un ticket en Supabase support pidiendo revocar la escritura de anon sobre public.spatial_ref_sys.';
end;
$$;

-- ============================================================
-- CONTROL — correr esto aparte y mirar el resultado. El
-- "Success. No rows returned" del bloque de arriba NO dice nada:
-- es lo que devuelve cualquier `do $$ ... $$`, ande o no ande.
--
--   select grantee, privilege_type
--     from information_schema.role_table_grants
--    where table_schema = 'public'
--      and table_name   = 'spatial_ref_sys'
--      and grantee in ('anon', 'authenticated')
--    order by grantee, privilege_type;
--
-- Esperado: como mucho una fila por rol, y siempre SELECT.
-- Si aparece INSERT, UPDATE, DELETE o TRUNCATE, el revoke no
-- entró y hay que ir por soporte.
-- ============================================================
