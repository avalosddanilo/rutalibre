-- ============================================================
-- RUTA LIBRE — 0012: el 904 solo lleva gente de una orilla a la otra
--
-- El hallazgo, de la prueba cerrada (18/9/2026): el 904 NO levanta
-- pasajeros para viajes dentro del Chaco — "de Barranqueras a
-- Resistencia centro no deja subir gente". Es un interurbano: lleva
-- gente a Corrientes (o la trae), no hace de urbano en el camino.
--
-- Pero en los datos sus paradas del lado Chaco son paradas como
-- cualquier otra, y el planificador podía contestar "tomá el 904 en
-- Barranqueras y bajate en el centro". Es exactamente lo que la app
-- promete no hacer: mandar a alguien a esperar un colectivo que no lo
-- va a llevar.
--
-- La regla: en la red `interurbano-chaco-corrientes` (904A, 904B y
-- 904C, las tres únicas), un tramo solo vale si la subida y la bajada
-- están en ORILLAS DISTINTAS. Se aplica en leg1 y en leg2, así que
-- vale igual para los viajes directos y para cada tramo de un
-- transbordo: tomar un urbano hasta Barranqueras y ahí el 904 a
-- Corrientes sigue apareciendo; el 904 de Barranqueras al centro, no.
--
-- Es simétrica: tampoco se ofrece el 904 para un viaje DENTRO de
-- Corrientes. Si ahí sí levanta gente, relajarla es una línea (ver el
-- `where` de leg1/leg2): mejor no ofrecer un viaje que sí existe que
-- ofrecer uno que no.
--
-- DÓNDE ESTÁ EL RÍO: el meridiano -58.86. Sale de los datos, no de un
-- mapa: en los seis recorridos del 904, la última parada del lado Chaco
-- es la cabecera "Ruta Nacional 16 y Puente General Belgrano"
-- (-58.8698) y la primera del lado Corrientes está en -58.8481; la
-- parada de Corrientes capital más al oeste está en -58.8499. Ninguna
-- parada del Gran Resistencia queda al este de -58.915. El corte cae
-- en el agua, lejos de todas.
--
-- Y DE PASO, EL SEARCH_PATH: `create or replace` BORRA los atributos
-- que se le pusieron a una función con `alter function`. La 0007 le
-- fijó `search_path = public` a siete funciones con un loop de alter;
-- después, la 0010 re-creó tres (get_stops_for_route,
-- get_nearby_stops, trip_leg_json) y la 0011 re-creó plan_trip, las
-- cuatro sin repetirlo. O sea: desde entonces esas cuatro volvieron a
-- resolver nombres con el search_path de quien las llama, que es
-- justo lo que la 0007 cerraba. Esta migración lo declara en
-- plan_trip misma y, al final, vuelve a pasar el loop de la 0007
-- (idempotente) para las demás.
--
-- La regla para las que vengan: toda `create or replace function`
-- lleva su `set search_path = public` adentro. Si no, se pierde en
-- silencio y nada avisa.
--
-- El contrato no cambia: misma firma, mismo JSON, mismo ranking. Solo
-- desaparecen los viajes que en la calle no existen.
--
-- Correr en: Supabase Dashboard → SQL Editor, DESPUÉS de la 0011.
-- Verificar con los controles del final ANTES de cerrar la pestaña.
-- ============================================================

create or replace function public.plan_trip(
    origin_lat  double precision,
    origin_lng  double precision,
    dest_lat    double precision,
    dest_lng    double precision,
    max_walk_m  integer default 500,
    max_results integer default 6
)
returns json
language sql
stable
security invoker
set search_path = public
as $$
with o as materialized (
    select s.id, st_distance(s.geom, st_point(origin_lng, origin_lat)::geography) as walk_m
    from public.stops s
    where s.is_active
      and st_dwithin(s.geom, st_point(origin_lng, origin_lat)::geography, max_walk_m)
),
d as materialized (
    select s.id, st_distance(s.geom, st_point(dest_lng, dest_lat)::geography) as walk_m
    from public.stops s
    where s.is_active
      and st_dwithin(s.geom, st_point(dest_lng, dest_lat)::geography, max_walk_m)
),
-- Los recorridos que SOLO llevan gente de una orilla a la otra.
cruzan as materialized (
    select rv.id
    from public.route_variants rv
    join public.lines l    on l.id = rv.line_id
    join public.networks n on n.id = l.network_id
    where n.code = 'interurbano-chaco-corrientes'
),
-- De qué orilla es cada parada de esos recorridos (unas pocas
-- centenas: materializado, el cruce con los tramos es un hash chico).
orilla as materialized (
    select distinct rs.stop_id,
           st_x(s.geom::geometry) > -58.86 as corrientes
    from public.route_stops rs
    join cruzan c       on c.id = rs.route_variant_id
    join public.stops s on s.id = rs.stop_id
),
-- Tramo 1, ACOTADO: por cada (recorrido, parada de paso), la mejor
-- subida cercana al origen que la precede. Una fila por fila de
-- route_stops como mucho. En el 904, solo si cruza el río.
leg1 as materialized (
    select distinct on (rs_off.route_variant_id, rs_off.stop_id)
           rs_off.route_variant_id  as variant_id,
           rs_board.stop_id         as board_id,
           rs_board.stop_order      as board_order,
           o.walk_m                 as walk_m,
           rs_off.stop_id           as via_id,
           rs_off.stop_order        as via_order
    from public.route_stops rs_board
    join o                        on o.id = rs_board.stop_id
    join public.route_variants rv on rv.id = rs_board.route_variant_id
                                 and rv.is_active
    join public.route_stops rs_off
      on rs_off.route_variant_id = rs_board.route_variant_id
     and rs_off.stop_order > rs_board.stop_order
    left join cruzan c  on c.id = rv.id
    left join orilla ob on c.id is not null and ob.stop_id = rs_board.stop_id
    left join orilla oa on c.id is not null and oa.stop_id = rs_off.stop_id
    -- Un NULL (una parada sin orilla, que no debería existir) descarta
    -- el tramo: ante la duda, no ofrecerlo.
    where c.id is null
       or ob.corrientes <> oa.corrientes
    order by rs_off.route_variant_id, rs_off.stop_id,
             o.walk_m, rs_board.stop_order desc
),
-- Tramo 2, mirado al revés y con el mismo recorte: por cada
-- (recorrido, parada de paso), la mejor bajada que llega al destino.
-- En el 904, la misma regla del río.
leg2 as materialized (
    select distinct on (rs_board.route_variant_id, rs_board.stop_id)
           rs_board.route_variant_id as variant_id,
           rs_board.stop_id          as via_id,
           rs_board.stop_order       as board_order,
           rs_off.stop_id            as alight_id,
           rs_off.stop_order         as alight_order,
           d.walk_m                  as walk_m
    from public.route_stops rs_board
    join public.route_variants rv on rv.id = rs_board.route_variant_id
                                 and rv.is_active
    join public.route_stops rs_off
      on rs_off.route_variant_id = rs_board.route_variant_id
     and rs_off.stop_order > rs_board.stop_order
    join d on d.id = rs_off.stop_id
    left join cruzan c  on c.id = rv.id
    left join orilla ob on c.id is not null and ob.stop_id = rs_board.stop_id
    left join orilla oa on c.id is not null and oa.stop_id = rs_off.stop_id
    where c.id is null
       or ob.corrientes <> oa.corrientes
    order by rs_board.route_variant_id, rs_board.stop_id,
             d.walk_m, rs_off.stop_order
),
-- --- Un solo colectivo -----------------------------------------
direct_all as (
    select rv.line_id,
           l.variant_id,
           l.board_id,
           l.via_id                    as alight_id,
           l.via_order - l.board_order as n,
           l.walk_m                    as walk_start,
           d.walk_m                    as walk_end
    from leg1 l
    join d on d.id = l.via_id
    join public.route_variants rv on rv.id = l.variant_id
),
direct_branches as (
    select line_id, count(distinct variant_id) as variant_count
    from direct_all
    group by line_id
),
direct as (
    select distinct on (a.line_id)
           1                        as leg_count,
           a.variant_id             as v1,
           a.board_id               as b1,
           a.alight_id              as a1,
           a.n                      as n1,
           (b.variant_count = 1)    as show_b1,
           null::uuid               as v2,
           null::uuid               as b2,
           null::uuid               as a2,
           null::integer            as n2,
           true                     as show_b2,
           a.walk_start,
           a.walk_end
    from direct_all a
    join direct_branches b on b.line_id = a.line_id
    order by a.line_id, a.walk_start + a.walk_end, a.n
),
-- --- Un transbordo, en la misma parada -------------------------
transfer_all as (
    select rva.line_id                     as line_a,
           rvb.line_id                     as line_b,
           a.variant_id                    as v1,
           a.board_id                      as b1,
           a.board_order                   as o1,
           a.via_id,
           a.via_order,
           a.walk_m                        as walk_start,
           b.variant_id                    as v2,
           b.board_order                   as o2,
           b.alight_id,
           b.alight_order,
           b.walk_m                        as walk_end
    from leg1 a
    join leg2 b on b.via_id = a.via_id
    join public.route_variants rva on rva.id = a.variant_id
    join public.route_variants rvb on rvb.id = b.variant_id
    where rva.line_id <> rvb.line_id
),
transfer_branches as (
    select line_a, line_b,
           count(distinct v1) as count_a,
           count(distinct v2) as count_b
    from transfer_all
    group by line_a, line_b
),
transfer as (
    select distinct on (a.line_a, a.line_b)
           2                              as leg_count,
           a.v1,
           a.b1,
           a.via_id                       as a1,
           a.via_order - a.o1             as n1,
           (b.count_a = 1)                as show_b1,
           a.v2,
           a.via_id                       as b2,
           a.alight_id                    as a2,
           a.alight_order - a.o2          as n2,
           (b.count_b = 1)                as show_b2,
           a.walk_start,
           a.walk_end
    from transfer_all a
    join transfer_branches b
      on b.line_a = a.line_a and b.line_b = a.line_b
    order by a.line_a, a.line_b,
             a.walk_start + a.walk_end,
             (a.via_order - a.o1) + (a.alight_order - a.o2)
),
ranked as (
    select *
    from (select * from direct union all select * from transfer) c
    order by c.leg_count,
             c.walk_start + c.walk_end,
             c.n1 + coalesce(c.n2, 0)
    limit max_results
)
select coalesce(json_agg(t order by t.leg_count, t.walk_total_m), '[]'::json)
from (
    select r.leg_count,
           round(r.walk_start)::integer as walk_to_board_m,
           round(r.walk_end)::integer   as walk_from_alight_m,
           round(r.walk_start)::integer
             + round(r.walk_end)::integer as walk_total_m,
           case
               when r.leg_count = 1 then
                   json_build_array(
                       public.trip_leg_json(
                           r.v1, r.b1, r.a1, r.n1, r.show_b1))
               else
                   json_build_array(
                       public.trip_leg_json(
                           r.v1, r.b1, r.a1, r.n1, r.show_b1),
                       public.trip_leg_json(
                           r.v2, r.b2, r.a2, r.n2, r.show_b2))
           end                          as legs
    from ranked r
) t;
$$;

comment on function public.plan_trip is
    'Viajes de un colectivo o un transbordo entre dos puntos, UNA opción por línea (o por par de líneas), del mejor al peor. 0012: el 904 solo de una orilla a la otra, y search_path fijo de vuelta';

-- El loop de la 0007, otra vez (ver el encabezado): re-fija el
-- search_path de las funciones que la 0010 re-creó sin él. Busca las
-- firmas en pg_proc, así que no depende de qué versión haya de cada
-- una. Suma get_all_stops, que ya lo trae declarado: no cambia nada y
-- la deja cubierta si alguien la re-crea sin él.
do $$
declare
    fn          record;
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
              'get_all_stops',
              'trip_leg_json',
              'plan_trip',
              'set_updated_at'
          )
    loop
        execute format(
            'alter function %s set search_path = public', fn.firma
        );
        encontradas := encontradas + 1;
    end loop;
    raise notice '% función(es) con search_path fijo.', encontradas;
end;
$$;

-- Controles. Los tres, en este orden:
--
-- 0) ANTES de correr esta migración, para ver el bug con la base real:
--    Barranqueras (Av. San Martín y Maipú) → Resistencia (cabecera del
--    904 en Sarmiento). Si da TRUE, el planificador de hoy ofrece el
--    904 para un viaje que en la calle no te hace.
--      select public.plan_trip(-27.46392, -58.91516, -27.462627, -58.985006, 500, 6)::text
--             like '%interurbano-chaco-corrientes%';
--
-- 1) DESPUÉS: el mismo viaje. Tiene que dar FALSE, y volver en menos
--    de un segundo.
--      select public.plan_trip(-27.46392, -58.91516, -27.462627, -58.985006, 500, 6)::text
--             like '%interurbano-chaco-corrientes%';
--
-- 2) DESPUÉS: Resistencia → Corrientes. El 904 tiene que SEGUIR
--    apareciendo (TRUE): la regla no puede romper el viaje para el
--    que el 904 existe.
--      select public.plan_trip(-27.462627, -58.985006, -27.46519, -58.837812, 500, 6)::text
--             like '%interurbano-chaco-corrientes%';
--
-- 3) El search_path volvió: las ocho tienen que decir search_path=public
--    y ninguna "(SIN FIJAR)". Corrida ANTES de la migración, esta misma
--    consulta muestra cuáles lo habían perdido.
--      select p.oid::regprocedure as funcion,
--             coalesce(array_to_string(p.proconfig, ', '), '(SIN FIJAR)') as config
--        from pg_proc p
--        join pg_namespace n on n.oid = p.pronamespace
--       where n.nspname = 'public'
--         and p.proname in ('get_route_geojson', 'get_stops_for_route',
--                           'get_nearby_stops', 'get_lines_for_stop', 'get_all_stops',
--                           'trip_leg_json', 'plan_trip', 'set_updated_at')
--       order by 1;
