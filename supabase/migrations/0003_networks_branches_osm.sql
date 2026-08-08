-- ============================================================
-- RUTA LIBRE — Migración 0003
-- Prepara el esquema para DATOS REALES importados de OpenStreetMap
-- y para más de una red (Gran Resistencia + interurbano + Corrientes).
--
-- Es ADITIVA e IDEMPOTENTE: se puede correr sobre una base que ya
-- tiene datos (a diferencia de la 0001, que hace DROP/CREATE).
-- ============================================================

-- ------------------------------------------------------------
-- 1. NETWORKS — La red / sistema al que pertenece una línea.
--
--    Por qué hace falta: `lines.code` era unique GLOBAL. En cuanto
--    entra Corrientes capital (que también tiene una "línea 3") eso
--    colisiona. El código de línea es único DENTRO de su red, no
--    en el universo.
-- ------------------------------------------------------------
create table if not exists public.networks (
    id          uuid primary key default gen_random_uuid(),
    code        text not null unique,          -- 'gran-resistencia'
    name        text not null,                 -- 'Gran Resistencia'
    city        text not null,                 -- 'Resistencia, Chaco'
    sort_order  smallint not null default 0,   -- orden de presentación
    is_active   boolean not null default true,
    created_at  timestamptz not null default now(),
    updated_at  timestamptz not null default now()
);

comment on table public.networks is
    'Redes de transporte: Gran Resistencia (urbano), interurbano Chaco-Corrientes, etc.';

insert into public.networks (code, name, city, sort_order) values
    ('gran-resistencia', 'Gran Resistencia', 'Resistencia, Chaco', 1),
    ('interurbano-chaco-corrientes', 'Chaco – Corrientes', 'Área metropolitana', 2),
    ('corrientes-capital', 'Corrientes Capital', 'Corrientes', 3)
on conflict (code) do update
    set name = excluded.name,
        city = excluded.city,
        sort_order = excluded.sort_order;

-- ------------------------------------------------------------
-- 2. LINES — pertenencia a una red + orden natural + origen OSM.
-- ------------------------------------------------------------
alter table public.lines
    add column if not exists network_id uuid references public.networks(id) on delete restrict;

-- `sort_order` permite ordenar "3" antes que "110" en la BASE, sin que
-- cada cliente reimplemente la comparación natural de códigos.
alter table public.lines
    add column if not exists sort_order integer not null default 0;

-- Las filas preexistentes (seed de desarrollo) caen en Gran Resistencia.
update public.lines
   set network_id = (select id from public.networks where code = 'gran-resistencia')
 where network_id is null;

alter table public.lines alter column network_id set not null;

-- El código pasa a ser único DENTRO de la red.
alter table public.lines drop constraint if exists lines_code_key;
create unique index if not exists lines_network_code_key
    on public.lines (network_id, code);

create index if not exists lines_network_id_idx on public.lines (network_id);

-- ------------------------------------------------------------
-- 3. ROUTE_VARIANTS — ramal explícito + id de OSM para reimportar.
--
--    Decisión de modelado: "3A" NO es una línea, es el ramal A de la
--    línea 3. El usuario piensa en "la 3"; el ramal y el sentido son
--    atributos del recorrido.
-- ------------------------------------------------------------
alter table public.route_variants
    add column if not exists branch text;   -- 'A', 'B', 'C'... o null

-- Trazabilidad y reimportación idempotente: la relation de OSM que
-- originó este recorrido.
alter table public.route_variants
    add column if not exists osm_relation_id bigint;

-- Sin predicado parcial a propósito: en Postgres NULL nunca colisiona con
-- NULL en un índice único, así que las filas sin origen OSM (carga manual)
-- conviven sin problema — y así `on conflict (osm_relation_id)` infiere el
-- índice sin tener que repetir el WHERE.
create unique index if not exists route_variants_osm_relation_id_key
    on public.route_variants (osm_relation_id);

-- `unique (line_id, name)` de la 0001 no sobrevive a los datos reales: hay
-- ramales distintos de la misma línea que comparten nombre porque OSM les
-- puso el mismo (la línea 2 tiene TRES "Ida: Carpincho Macho → Villa
-- Prosperidad", uno por ramal). Si no se dropea, el seed aborta entero con
-- 23505 y no entra ni una fila.
--
-- Lo natural es un recorrido por (línea, ramal, sentido), que es lo que
-- crea el índice de abajo.
alter table public.route_variants
    drop constraint if exists route_variants_line_id_name_key;

create unique index if not exists route_variants_line_branch_direction_key
    on public.route_variants (line_id, coalesce(branch, ''), direction);

-- ------------------------------------------------------------
-- 4. STOPS — id de OSM para deduplicar entre reimportaciones.
-- ------------------------------------------------------------
alter table public.stops
    add column if not exists osm_node_id bigint;

create unique index if not exists stops_osm_node_id_key
    on public.stops (osm_node_id);

-- ------------------------------------------------------------
-- 5. RLS de la tabla nueva — lectura pública igual que el resto.
-- ------------------------------------------------------------
alter table public.networks enable row level security;

drop policy if exists "public read active networks" on public.networks;
create policy "public read active networks"
    on public.networks for select using (is_active);

-- ------------------------------------------------------------
-- 6. RPC — "¿Qué líneas pasan por esta parada?"
--    Es LA pregunta que hace un pasajero parado en la vereda, y sin
--    este RPC el cliente tendría que traerse todo route_stops.
-- ------------------------------------------------------------
create or replace function public.get_lines_for_stop(stop_id uuid)
returns table (
    line_id           uuid,
    line_code         text,
    line_name         text,
    color_hex         text,
    route_variant_id  uuid,
    variant_name      text,
    branch            text,
    direction         smallint
)
language sql
stable
security invoker
as $$
    select l.id, l.code, l.name, l.color_hex::text,
           rv.id, rv.name, rv.branch, rv.direction
      from public.route_stops rs
      join public.route_variants rv on rv.id = rs.route_variant_id
      join public.lines l           on l.id  = rv.line_id
     where rs.stop_id = get_lines_for_stop.stop_id
       and rv.is_active
       and l.is_active
     order by l.sort_order, l.code, rv.branch nulls first, rv.direction;
$$;

-- ------------------------------------------------------------
-- 7. `get_nearby_stops` NO se toca acá.
--
--    La versión de la 0002 YA devuelve `distance_m` dentro del JSON, que es
--    exactamente lo que la UI necesita para mostrar "a 120 m". Redefinirla
--    era innecesario, y además rompía la migración de dos formas:
--
--    1. `create or replace` no puede cambiar el tipo de retorno (la 0002 la
--       declara `returns json`): Postgres corta con "cannot change return
--       type of existing function". Haría falta un DROP previo.
--    2. Declarar `lat`/`lng` como parámetro de ENTRADA y a la vez como
--       columna de SALIDA en el `returns table` es un error de Postgres
--       ("parameter name used more than once").
--
--    Cualquiera de las dos abortaba la migración entera. Se deja la 0002.
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- 8. Trigger de updated_at para la tabla nueva.
-- ------------------------------------------------------------
drop trigger if exists networks_set_updated_at on public.networks;
create trigger networks_set_updated_at
    before update on public.networks
    for each row execute function public.set_updated_at();
