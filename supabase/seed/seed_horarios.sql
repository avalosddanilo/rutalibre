-- ====================================================================
-- RUTA LIBRE — Horarios
--
-- GENERADO AUTOMÁTICAMENTE por tools/schedules_import.dart.
-- No editar a mano: se regenera con
--   dart run tools/schedules_import.dart
--
-- La fuente editable es supabase/seed/horarios/*.txt.
--
-- FUENTE: transcripción manual — ver los encabezados de 904_campus.txt en supabase/seed/horarios/
-- Generado: 2026-08-05T20:29:45.829212Z
-- Tablas: 4 | Salidas: 72
--
-- OJO: los horarios se transcriben A MANO de lo que publican
-- las empresas. Verificar contra la fuente ANTES de correr.
-- ====================================================================

begin;

-- ------------------------------------------------------------
-- interurbano-chaco-corrientes/904A ida · weekday (20 salidas)
-- ------------------------------------------------------------
delete from public.schedules
 where day_type = 'weekday'::public.day_type
   and route_variant_id in (select rv.id from public.route_variants rv join public.lines l on l.id = rv.line_id join public.networks n on n.id = l.network_id where n.code = 'interurbano-chaco-corrientes' and l.code = '904A' and rv.branch is null and rv.direction = 0);
insert into public.schedules (route_variant_id, day_type, departure_time)
select rv.id, 'weekday'::public.day_type, t.departure
  from (values
         ('05:35'::time),
         ('06:25'::time),
         ('07:15'::time),
         ('08:05'::time),
         ('08:55'::time),
         ('09:45'::time),
         ('10:35'::time),
         ('11:25'::time),
         ('12:15'::time),
         ('13:05'::time),
         ('13:55'::time),
         ('14:45'::time),
         ('15:35'::time),
         ('16:25'::time),
         ('17:15'::time),
         ('18:05'::time),
         ('18:55'::time),
         ('19:45'::time),
         ('20:47'::time),
         ('21:15'::time)
       ) as t(departure)
  cross join (select rv.id from public.route_variants rv join public.lines l on l.id = rv.line_id join public.networks n on n.id = l.network_id where n.code = 'interurbano-chaco-corrientes' and l.code = '904A' and rv.branch is null and rv.direction = 0) rv
on conflict (route_variant_id, day_type, departure_time) do nothing;

-- ------------------------------------------------------------
-- interurbano-chaco-corrientes/904A vuelta · weekday (20 salidas)
-- ------------------------------------------------------------
delete from public.schedules
 where day_type = 'weekday'::public.day_type
   and route_variant_id in (select rv.id from public.route_variants rv join public.lines l on l.id = rv.line_id join public.networks n on n.id = l.network_id where n.code = 'interurbano-chaco-corrientes' and l.code = '904A' and rv.branch is null and rv.direction = 1);
insert into public.schedules (route_variant_id, day_type, departure_time)
select rv.id, 'weekday'::public.day_type, t.departure
  from (values
         ('05:35'::time),
         ('06:25'::time),
         ('07:15'::time),
         ('08:05'::time),
         ('08:55'::time),
         ('09:45'::time),
         ('10:35'::time),
         ('11:25'::time),
         ('12:15'::time),
         ('13:05'::time),
         ('13:55'::time),
         ('14:45'::time),
         ('15:35'::time),
         ('16:25'::time),
         ('17:15'::time),
         ('18:05'::time),
         ('18:55'::time),
         ('19:45'::time),
         ('20:33'::time),
         ('21:20'::time)
       ) as t(departure)
  cross join (select rv.id from public.route_variants rv join public.lines l on l.id = rv.line_id join public.networks n on n.id = l.network_id where n.code = 'interurbano-chaco-corrientes' and l.code = '904A' and rv.branch is null and rv.direction = 1) rv
on conflict (route_variant_id, day_type, departure_time) do nothing;

-- ------------------------------------------------------------
-- interurbano-chaco-corrientes/904A ida · saturday + sunday_holiday (8 salidas)
-- ------------------------------------------------------------
delete from public.schedules
 where day_type = 'saturday'::public.day_type
   and route_variant_id in (select rv.id from public.route_variants rv join public.lines l on l.id = rv.line_id join public.networks n on n.id = l.network_id where n.code = 'interurbano-chaco-corrientes' and l.code = '904A' and rv.branch is null and rv.direction = 0);
insert into public.schedules (route_variant_id, day_type, departure_time)
select rv.id, 'saturday'::public.day_type, t.departure
  from (values
         ('06:00'::time),
         ('07:30'::time),
         ('10:00'::time),
         ('12:00'::time),
         ('13:30'::time),
         ('15:00'::time),
         ('17:00'::time),
         ('19:30'::time)
       ) as t(departure)
  cross join (select rv.id from public.route_variants rv join public.lines l on l.id = rv.line_id join public.networks n on n.id = l.network_id where n.code = 'interurbano-chaco-corrientes' and l.code = '904A' and rv.branch is null and rv.direction = 0) rv
on conflict (route_variant_id, day_type, departure_time) do nothing;

delete from public.schedules
 where day_type = 'sunday_holiday'::public.day_type
   and route_variant_id in (select rv.id from public.route_variants rv join public.lines l on l.id = rv.line_id join public.networks n on n.id = l.network_id where n.code = 'interurbano-chaco-corrientes' and l.code = '904A' and rv.branch is null and rv.direction = 0);
insert into public.schedules (route_variant_id, day_type, departure_time)
select rv.id, 'sunday_holiday'::public.day_type, t.departure
  from (values
         ('06:00'::time),
         ('07:30'::time),
         ('10:00'::time),
         ('12:00'::time),
         ('13:30'::time),
         ('15:00'::time),
         ('17:00'::time),
         ('19:30'::time)
       ) as t(departure)
  cross join (select rv.id from public.route_variants rv join public.lines l on l.id = rv.line_id join public.networks n on n.id = l.network_id where n.code = 'interurbano-chaco-corrientes' and l.code = '904A' and rv.branch is null and rv.direction = 0) rv
on conflict (route_variant_id, day_type, departure_time) do nothing;

-- ------------------------------------------------------------
-- interurbano-chaco-corrientes/904A vuelta · saturday + sunday_holiday (8 salidas)
-- ------------------------------------------------------------
delete from public.schedules
 where day_type = 'saturday'::public.day_type
   and route_variant_id in (select rv.id from public.route_variants rv join public.lines l on l.id = rv.line_id join public.networks n on n.id = l.network_id where n.code = 'interurbano-chaco-corrientes' and l.code = '904A' and rv.branch is null and rv.direction = 1);
insert into public.schedules (route_variant_id, day_type, departure_time)
select rv.id, 'saturday'::public.day_type, t.departure
  from (values
         ('06:00'::time),
         ('07:30'::time),
         ('10:00'::time),
         ('12:00'::time),
         ('13:30'::time),
         ('15:00'::time),
         ('17:00'::time),
         ('19:30'::time)
       ) as t(departure)
  cross join (select rv.id from public.route_variants rv join public.lines l on l.id = rv.line_id join public.networks n on n.id = l.network_id where n.code = 'interurbano-chaco-corrientes' and l.code = '904A' and rv.branch is null and rv.direction = 1) rv
on conflict (route_variant_id, day_type, departure_time) do nothing;

delete from public.schedules
 where day_type = 'sunday_holiday'::public.day_type
   and route_variant_id in (select rv.id from public.route_variants rv join public.lines l on l.id = rv.line_id join public.networks n on n.id = l.network_id where n.code = 'interurbano-chaco-corrientes' and l.code = '904A' and rv.branch is null and rv.direction = 1);
insert into public.schedules (route_variant_id, day_type, departure_time)
select rv.id, 'sunday_holiday'::public.day_type, t.departure
  from (values
         ('06:00'::time),
         ('07:30'::time),
         ('10:00'::time),
         ('12:00'::time),
         ('13:30'::time),
         ('15:00'::time),
         ('17:00'::time),
         ('19:30'::time)
       ) as t(departure)
  cross join (select rv.id from public.route_variants rv join public.lines l on l.id = rv.line_id join public.networks n on n.id = l.network_id where n.code = 'interurbano-chaco-corrientes' and l.code = '904A' and rv.branch is null and rv.direction = 1) rv
on conflict (route_variant_id, day_type, departure_time) do nothing;

commit;

-- ====================================================================
-- CONTROL — debería devolver una fila por tabla cargada
-- ====================================================================
-- select l.code, rv.branch, rv.direction, s.day_type,
--        count(*) as salidas, min(s.departure_time) as primera,
--        max(s.departure_time) as ultima
--   from public.schedules s
--   join public.route_variants rv on rv.id = s.route_variant_id
--   join public.lines l on l.id = rv.line_id
--  group by 1, 2, 3, 4 order by 1, 2, 3, 4;
