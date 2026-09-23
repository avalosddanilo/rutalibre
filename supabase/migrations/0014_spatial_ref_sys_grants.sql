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
-- O sea: cualquiera con la anon key —que es pública por diseño—
-- puede hacer `DELETE` sobre el catálogo EPSG por PostgREST. Es la
-- única cosa escribible por un anónimo en toda la base.
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
-- ⚠️ CORRIDA EL 2026-09-23: NO FUNCIONÓ, Y NO PUEDE FUNCIONAR.
-- El `revoke` lo tiene que correr quien otorgó el permiso. La tabla
-- es de `supabase_admin` y el SQL Editor corre como `postgres`:
--
--     rol_que_corre     dueno_de_la_tabla   anon_puede
--     postgres          supabase_admin      DELETE, INSERT, ... UPDATE
--
-- Se deja igual, y corrida, por dos razones: el bloque atrapa el
-- error y nunca deja la base peor, y el `select` de abajo es la
-- verificación que hay que repetir si Supabase algún día cambia el
-- dueño o resuelve el ticket. Ver `docs/auditoria-seguridad.md`
-- para qué se decidió hacer con esto.
--
-- Correr en: Supabase Dashboard → SQL Editor. Devuelve una fila: esa
-- fila es el veredicto.
-- ============================================================

-- CÓMO ESTÁ ESCRITA, Y POR QUÉ NO ES UN `do $$` PELADO COMO LA 0006.
-- La 0006 avisaba por `raise notice`, y el SQL Editor de Supabase muestra
-- "Success. No rows returned" para CUALQUIER bloque anónimo: ande o no
-- ande, se ve igual. Tuvimos la migración corrida y sin saber si había
-- hecho algo. Así que acá el bloque arregla y después un `select` DEVUELVE
-- EL ESTADO: una fila que se lee sola.
--
-- El `when others` es a propósito y no es pereza: `revoke` sobre una tabla
-- ajena puede tirar `insufficient_privilege` o `42501` según la versión, y
-- lo que importa no es cuál de los dos fue sino que el select de abajo
-- muestre qué quedó. El `sqlerrm` sale por notice para el diagnóstico.

do $$
begin
    revoke insert, update, delete, truncate, references, trigger
        on public.spatial_ref_sys
      from anon, authenticated;

exception
    when others then
        raise notice 'El revoke falló: % (%)', sqlerrm, sqlstate;
end;
$$;

-- El veredicto. Esto SÍ devuelve filas.
select
    current_user                        as rol_que_corre,
    pg_get_userbyid(c.relowner)         as dueno_de_la_tabla,
    coalesce((
        select string_agg(distinct privilege_type, ', ' order by privilege_type)
          from information_schema.role_table_grants
         where table_schema = 'public'
           and table_name   = 'spatial_ref_sys'
           and grantee      = 'anon'
    ), '(ninguno)')                     as anon_puede,
    coalesce((
        select string_agg(distinct privilege_type, ', ' order by privilege_type)
          from information_schema.role_table_grants
         where table_schema = 'public'
           and table_name   = 'spatial_ref_sys'
           and grantee      = 'authenticated'
    ), '(ninguno)')                     as authenticated_puede
  from pg_class c
 where c.relname = 'spatial_ref_sys';

-- ============================================================
-- CÓMO SE LEE EL RESULTADO
--
--   anon_puede = 'SELECT'  → arreglado. Leer el catálogo EPSG es
--   inofensivo (es data pública) y PostGIS lo necesita.
--
--   anon_puede con INSERT/UPDATE/DELETE/TRUNCATE → el revoke no entró.
--   Mirá `dueno_de_la_tabla` contra `rol_que_corre`: si no coinciden, es
--   eso, y no hay nada más que hacer desde el SQL Editor.
--   Ahí va ticket a soporte de Supabase pidiendo revocar la escritura de
--   anon sobre public.spatial_ref_sys. ESTO NO SE DEJA PASAR como el
--   aviso de RLS de la 0006: aquel era "un anónimo puede leer que EPSG
--   4326 es WGS84", este es "un anónimo puede vaciar el catálogo".
-- ============================================================
