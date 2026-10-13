-- ============================================================
-- RUTA LIBRE — 0016: avisos de servicio (paros, desvíos)
--
-- PARA QUÉ. El día de paro todo el mundo quiere saber una sola cosa:
-- si hay colectivos. Y un desvío por obras manda a esperar en una
-- parada por donde ese día no pasa nadie. Ninguna de las dos cosas
-- está en los datos de recorridos, y las dos son lo que más se busca.
--
-- CÓMO SE USA. A mano, desde Supabase → Table Editor → service_alerts
-- → Insert row. Un aviso es un título corto (lo que se ve en el mapa)
-- y, si hace falta, un texto más largo (lo que se ve al tocarlo). Se
-- apaga solo con `ends_at`, o a mano con `is_active = false`. La guía
-- completa, con ejemplos y las reglas de redacción, está en
-- docs/avisos.md.
--
-- QUIÉN LO LEE. La app, con la anon key, y SOLO los avisos vigentes:
-- activos, ya empezados y sin vencer. La policy filtra en la base, así
-- que un aviso cargado para mañana no se ve hoy aunque alguien arme la
-- consulta a mano.
--
-- QUIÉN LO ESCRIBE. Nadie con la anon key. No hay policy de insert,
-- update ni delete, y además se revocan los permisos de escritura que
-- Supabase reparte por defecto (`grant all … to anon, authenticated`).
-- Es la lección de la 0014: RLS y GRANT son dos rejas distintas, y no
-- se deja ninguna abierta. Como esta tabla es NUESTRA (la crea quien
-- corre esto), el revoke sí funciona, a diferencia de spatial_ref_sys.
--
-- Correr en: Supabase Dashboard → SQL Editor, después de la 0015.
-- ============================================================

create table if not exists public.service_alerts (
    id          uuid primary key default gen_random_uuid(),
    -- Lo que se ve en el mapa: una línea. 90 caracteres alcanzan para
    -- "Paro de la UTA: hoy no hay colectivos urbanos en Resistencia".
    title       text not null check (char_length(title) between 3 and 90),
    -- Lo que se ve al tocarlo. Opcional.
    body        text check (body is null or char_length(body) <= 600),
    -- A qué líneas afecta, como se ven en la app ('5', '102', '904A').
    -- Vacío o null = a todas. Solo informativo: el aviso se muestra igual.
    line_codes  text[],
    starts_at   timestamptz not null default now(),
    ends_at     timestamptz,
    is_active   boolean not null default true,
    created_at  timestamptz not null default now(),
    check (ends_at is null or ends_at > starts_at)
);

comment on table public.service_alerts is
    'Avisos de servicio (paros, desvíos) que la app muestra arriba del mapa. Se cargan a mano: ver docs/avisos.md';

alter table public.service_alerts enable row level security;

drop policy if exists "public read current alerts" on public.service_alerts;
create policy "public read current alerts"
    on public.service_alerts for select
    using (
        is_active
        and starts_at <= now()
        and (ends_at is null or ends_at > now())
    );

revoke insert, update, delete, truncate, references, trigger
    on public.service_alerts
  from anon, authenticated;
grant select on public.service_alerts to anon, authenticated;

-- Controles:
--
-- 1) La anon key solo puede leer. Tiene que devolver UNA fila, SELECT.
--      select grantee, string_agg(privilege_type, ', ')
--        from information_schema.role_table_grants
--       where table_name = 'service_alerts' and grantee = 'anon'
--       group by grantee;
--
-- 2) Un aviso de prueba que vence en 10 minutos (aparece en la app al
--    abrirla, y se va solo):
--      insert into public.service_alerts (title, ends_at)
--      values ('Aviso de prueba: ignoralo', now() + interval '10 minutes');
