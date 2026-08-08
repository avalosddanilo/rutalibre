-- ============================================================
-- RUTA LIBRE — Esquema de base de datos (Fase 1: datos estáticos)
-- Motor: PostgreSQL 15+ (Supabase) con PostGIS
-- Correr en: Supabase Dashboard → SQL Editor, o `supabase db push`
-- ============================================================

-- PostGIS: tipos geoespaciales e índices espaciales.
-- En Supabase ya viene disponible; solo hay que habilitarla.
create extension if not exists postgis;

-- ------------------------------------------------------------
-- 1. LINES — La línea comercial ("Línea 3", "Línea 110").
--    Es la unidad que el usuario reconoce. NO contiene geometría:
--    una línea tiene N recorridos (ida, vuelta, ramales).
-- ------------------------------------------------------------
create table public.lines (
    id          uuid primary key default gen_random_uuid(),
    code        text not null unique,          -- "3", "110", "9B"
    name        text not null,                 -- "Línea 3 - Villa Río Negro"
    color_hex   char(7) not null default '#1E88E5'
                check (color_hex ~ '^#[0-9A-Fa-f]{6}$'),  -- color del trazado en el mapa
    is_active   boolean not null default true,
    created_at  timestamptz not null default now(),
    updated_at  timestamptz not null default now()
);

comment on table public.lines is 'Líneas comerciales de colectivo del Gran Resistencia';

-- ------------------------------------------------------------
-- 2. ROUTE_VARIANTS — Un recorrido concreto de una línea.
--    Modela ida/vuelta y ramales como filas independientes,
--    cada una con su propia geometría (LineString WGS84).
-- ------------------------------------------------------------
create table public.route_variants (
    id          uuid primary key default gen_random_uuid(),
    line_id     uuid not null references public.lines(id) on delete cascade,
    name        text not null,                 -- "Ida: Centro → Barranqueras"
    direction   smallint not null check (direction in (0, 1)),  -- 0 = ida, 1 = vuelta
    geom        geometry(LineString, 4326) not null,  -- trazado completo del recorrido
    is_active   boolean not null default true,
    created_at  timestamptz not null default now(),
    updated_at  timestamptz not null default now(),
    unique (line_id, name)
);

create index route_variants_line_id_idx on public.route_variants (line_id);
create index route_variants_geom_idx    on public.route_variants using gist (geom);

comment on table public.route_variants is 'Recorridos (trazados) de cada línea: ida, vuelta y ramales';

-- ------------------------------------------------------------
-- 3. STOPS — Paradas físicas. Independientes de las líneas:
--    una parada puede servir a muchas líneas (por eso la N:M
--    se resuelve en route_stops y NO acá).
-- ------------------------------------------------------------
create table public.stops (
    id          uuid primary key default gen_random_uuid(),
    name        text not null,                 -- "Av. 25 de Mayo y French"
    description text,                          -- referencia opcional ("frente a la plaza")
    geom        geography(Point, 4326) not null,  -- geography: distancias en metros gratis
    is_active   boolean not null default true,
    created_at  timestamptz not null default now(),
    updated_at  timestamptz not null default now()
);

create index stops_geom_idx on public.stops using gist (geom);

comment on table public.stops is 'Paradas físicas georreferenciadas del Gran Resistencia';

-- ------------------------------------------------------------
-- 4. ROUTE_STOPS — Tabla puente N:M con orden de paso.
--    "El recorrido X pasa por la parada Y en la posición N".
-- ------------------------------------------------------------
create table public.route_stops (
    route_variant_id uuid not null references public.route_variants(id) on delete cascade,
    stop_id          uuid not null references public.stops(id) on delete cascade,
    stop_order       integer not null check (stop_order > 0),  -- 1 = cabecera
    primary key (route_variant_id, stop_order),
    unique (route_variant_id, stop_id)
);

create index route_stops_stop_id_idx on public.route_stops (stop_id);

comment on table public.route_stops is 'Secuencia ordenada de paradas de cada recorrido';

-- ------------------------------------------------------------
-- 5. SCHEDULES — Horarios de salida desde cabecera, por tipo de día.
--    Una fila por salida. Simple, normalizado y suficiente para
--    frecuencias del interior (no hace falta el modelo GTFS completo).
-- ------------------------------------------------------------
create type public.day_type as enum ('weekday', 'saturday', 'sunday_holiday');

create table public.schedules (
    id               uuid primary key default gen_random_uuid(),
    route_variant_id uuid not null references public.route_variants(id) on delete cascade,
    day_type         public.day_type not null,
    departure_time   time not null,            -- hora de salida desde cabecera
    unique (route_variant_id, day_type, departure_time)
);

create index schedules_variant_day_idx on public.schedules (route_variant_id, day_type);

comment on table public.schedules is 'Salidas desde cabecera por recorrido y tipo de día';

-- ------------------------------------------------------------
-- SEGURIDAD (RLS) — Lectura pública, escritura solo por rol service.
-- La app consume con la anon key: SOLO lectura de datos activos.
-- ------------------------------------------------------------
alter table public.lines          enable row level security;
alter table public.route_variants enable row level security;
alter table public.stops          enable row level security;
alter table public.route_stops    enable row level security;
alter table public.schedules      enable row level security;

create policy "public read active lines"
    on public.lines for select using (is_active);

create policy "public read active variants"
    on public.route_variants for select using (is_active);

create policy "public read active stops"
    on public.stops for select using (is_active);

create policy "public read route_stops"
    on public.route_stops for select using (true);

create policy "public read schedules"
    on public.schedules for select using (true);

-- Nota: no se crean políticas de INSERT/UPDATE/DELETE a propósito.
-- La carga de datos se hace con la service_role key (bypassa RLS).

-- ------------------------------------------------------------
-- RPC — La app pide la geometría como GeoJSON listo para dibujar
-- en flutter_map, sin parsear WKB en el cliente.
-- ------------------------------------------------------------
create or replace function public.get_route_geojson(variant_id uuid)
returns json
language sql
stable
security invoker
as $$
    select st_asgeojson(geom)::json
    from public.route_variants
    where id = variant_id and is_active;
$$;

-- RPC — Paradas cercanas a una ubicación (pantalla "¿dónde estoy?").
-- geography hace que radius_m sea en metros reales.
-- NOTA: reemplazado por la migración 0002 (esta versión devuelve geom
-- en WKB, inparseble en Flutter). Se mantiene acá por historia.
create or replace function public.get_nearby_stops(lat double precision, lng double precision, radius_m integer default 500)
returns setof public.stops
language sql
stable
security invoker
as $$
    select *
    from public.stops
    where is_active
      and st_dwithin(geom, st_point(lng, lat)::geography, radius_m)
    order by geom <-> st_point(lng, lat)::geography;
$$;

-- ------------------------------------------------------------
-- TRIGGER — updated_at automático
-- ------------------------------------------------------------
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
    new.updated_at = now();
    return new;
end;
$$;

create trigger lines_updated_at          before update on public.lines          for each row execute function public.set_updated_at();
create trigger route_variants_updated_at before update on public.route_variants for each row execute function public.set_updated_at();
create trigger stops_updated_at          before update on public.stops          for each row execute function public.set_updated_at();
