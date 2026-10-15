-- ============================================================
-- RUTA LIBRE — 0019: la 102A y la 106A de Corrientes, con su recorrido
-- de agosto
--
-- EL PROBLEMA. El 12/8/2026 la 102A y la 106A cambiaron su recorrido,
-- de ida y de vuelta (El Litoral, y el cartel "Nuevos recorridos" de
-- ERSA). Dos meses después el portal de datos abiertos de la
-- Municipalidad seguía con el trazado viejo —igual al nuestro, a 5 m—,
-- así que la app mostraba recorridos que ya no existen.
--
-- LA SOLUCIÓN. Los cuatro trazados nuevos salen de las calles de la
-- fuente, ruteadas sobre el callejero de OpenStreetMap y revisadas calle
-- por calle por Danilo Avalos el 15/10/2026. Las paradas son las
-- oficiales del municipio (ctes:N) a menos de 25 m del trazado que otro
-- recorrido ya usa en el mismo sentido.
--
-- Todo sale de tools/data/corrientes_correcciones.json, el mismo archivo
-- que el importador aplica al regenerar el seed: la migración y el seed no
-- pueden decir cosas distintas (lo controla test/tools/
-- corrientes_correcciones_test.dart). Cuando el portal publique los
-- recorridos nuevos, se borra la corrección y vuelve a mandar el portal.
--
-- `dist_m` se recalcula solo: lo hace el trigger de la 0018 al insertar.
--
-- Correr en: Supabase Dashboard → SQL Editor, después de la 0018.
-- ============================================================

begin;
-- <correcciones: generado por emitCorrectionsSql, no editar a mano>

-- 102A ida: Florencia y Trento, Trento, Av. Perón, Medrano, Av. Independencia, Av. Ferré, Av. Artigas, San Martín, La Rioja, Puerto.
update public.route_variants
   set geom = st_geomfromtext('LINESTRING(-58.781076 -27.489731, -58.781149 -27.490464, -58.781101 -27.490581, -58.784915 -27.490064, -58.789629 -27.489285, -58.792497 -27.488527, -58.794039 -27.488231, -58.799411 -27.487565, -58.798329 -27.481417, -58.805023 -27.479532, -58.819738 -27.477712, -58.819306 -27.474939, -58.818642 -27.471561, -58.819222 -27.471569, -58.825603 -27.470880, -58.838302 -27.469659, -58.837496 -27.461859, -58.837524 -27.461766, -58.837689 -27.461752)', 4326)
 where id = (select rv.id from public.route_variants rv join public.lines l on l.id = rv.line_id join public.networks n on n.id = l.network_id where n.code = 'corrientes-capital' and l.code = '102' and rv.branch is not distinct from 'A' and rv.direction = 0);
delete from public.route_stops where route_variant_id = (select rv.id from public.route_variants rv join public.lines l on l.id = rv.line_id join public.networks n on n.id = l.network_id where n.code = 'corrientes-capital' and l.code = '102' and rv.branch is not distinct from 'A' and rv.direction = 0);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select (select rv.id from public.route_variants rv join public.lines l on l.id = rv.line_id join public.networks n on n.id = l.network_id where n.code = 'corrientes-capital' and l.code = '102' and rv.branch is not distinct from 'A' and rv.direction = 0), s.id, p.orden
  from unnest(array[1210, 573, 574, 575, 1150, 1074, 895, 1321, 896, 1076, 1077, 1213, 1078, 203, 204, 205, 206, 207, 208, 209, 210, 212, 382, 383, 384, 385, 23, 25, 26, 27, 28, 29, 30, 31, 33])
       with ordinality as p(gid, orden)
  join public.stops s on s.source_ref = 'ctes:' || p.gid;

-- 102A vuelta: Puerto, Av. Costanera, Tucumán, 9 de Julio, Santa Fe, Irigoyen, Av. Artigas, Av. Ferré, Av. Independencia, Las Piedras, Av. Perón, Cnel. Artaza, Florencia hasta Trento.
update public.route_variants
   set geom = st_geomfromtext('LINESTRING(-58.837689 -27.461752, -58.841246 -27.461419, -58.841566 -27.466083, -58.830355 -27.466964, -58.830615 -27.469255, -58.818511 -27.470432, -58.819388 -27.474932, -58.819866 -27.477986, -58.805082 -27.479836, -58.800536 -27.481106, -58.800819 -27.482728, -58.800612 -27.482775, -58.801436 -27.487360, -58.794137 -27.488285, -58.792497 -27.488596, -58.789637 -27.489351, -58.784824 -27.490148, -58.783055 -27.490378, -58.782904 -27.489476, -58.781076 -27.489731)', 4326)
 where id = (select rv.id from public.route_variants rv join public.lines l on l.id = rv.line_id join public.networks n on n.id = l.network_id where n.code = 'corrientes-capital' and l.code = '102' and rv.branch is not distinct from 'A' and rv.direction = 1);
delete from public.route_stops where route_variant_id = (select rv.id from public.route_variants rv join public.lines l on l.id = rv.line_id join public.networks n on n.id = l.network_id where n.code = 'corrientes-capital' and l.code = '102' and rv.branch is not distinct from 'A' and rv.direction = 1);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select (select rv.id from public.route_variants rv join public.lines l on l.id = rv.line_id join public.networks n on n.id = l.network_id where n.code = 'corrientes-capital' and l.code = '102' and rv.branch is not distinct from 'A' and rv.direction = 1), s.id, p.orden
  from unnest(array[906, 565, 566, 396, 222, 397, 84, 39, 40, 41, 42, 400, 401, 402, 228, 229, 230, 231, 232, 233, 234, 236, 913, 914, 1318, 915, 1135, 757, 916, 559, 561, 564, 567])
       with ordinality as p(gid, orden)
  join public.stops s on s.source_ref = 'ctes:' || p.gid;

-- 106A ida: Calle S/N y Mario Gómez, Calle S/N, Cuba, Evaristo González, Trento, Tupac Amaru, Ruta 12, rotonda Virgen de Itatí, Av. Independencia, Av. Ferré, Av. 3 de Abril, Catamarca, Av. Vera, Puerto.
update public.route_variants
   set geom = st_geomfromtext('LINESTRING(-58.787553 -27.504566, -58.787557 -27.505315, -58.780132 -27.506344, -58.779472 -27.502746, -58.779637 -27.502122, -58.779595 -27.502026, -58.775402 -27.500617, -58.781466 -27.486272, -58.781887 -27.484966, -58.781810 -27.484272, -58.781939 -27.484041, -58.782137 -27.483931, -58.782370 -27.483917, -58.782923 -27.484187, -58.783212 -27.484222, -58.790236 -27.483732, -58.791913 -27.483404, -58.802272 -27.480366, -58.804864 -27.479695, -58.833886 -27.476050, -58.833936 -27.475952, -58.833823 -27.474668, -58.832293 -27.461166, -58.834755 -27.461108, -58.836934 -27.461814, -58.837689 -27.461752)', 4326)
 where id = (select rv.id from public.route_variants rv join public.lines l on l.id = rv.line_id join public.networks n on n.id = l.network_id where n.code = 'corrientes-capital' and l.code = '106' and rv.branch is not distinct from 'A' and rv.direction = 0);
delete from public.route_stops where route_variant_id = (select rv.id from public.route_variants rv join public.lines l on l.id = rv.line_id join public.networks n on n.id = l.network_id where n.code = 'corrientes-capital' and l.code = '106' and rv.branch is not distinct from 'A' and rv.direction = 0);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select (select rv.id from public.route_variants rv join public.lines l on l.id = rv.line_id join public.networks n on n.id = l.network_id where n.code = 'corrientes-capital' and l.code = '106' and rv.branch is not distinct from 'A' and rv.direction = 0), s.id, p.orden
  from unnest(array[1069, 1075, 1079, 1207, 1080, 1081, 1082, 1088, 1208, 1070, 1071, 1072, 1073, 1267, 569, 200, 1151, 202, 560, 745, 203, 204, 205, 206, 207, 208, 209, 210, 212, 213, 214, 215, 216, 348, 119, 217, 120, 121, 777, 858, 1002, 776, 1064, 487])
       with ordinality as p(gid, orden)
  join public.stops s on s.source_ref = 'ctes:' || p.gid;

-- 106A vuelta: Puerto, Av. Costanera, Tucumán, 9 de Julio, Santa Fe, Av. 3 de Abril, Av. Ferré, Av. Independencia, rotonda Virgen de Itatí, colectora de Ruta 12, Nápoles, Av. Perón, colectora de Ruta 12, Tupac Amaru, Trento, Evaristo González, Cuba, Calle S/N y Mario Gómez.
update public.route_variants
   set geom = st_geomfromtext('LINESTRING(-58.837689 -27.461752, -58.841246 -27.461419, -58.841566 -27.466083, -58.830355 -27.466964, -58.831417 -27.476449, -58.804862 -27.479752, -58.791338 -27.483633, -58.789726 -27.483852, -58.783525 -27.484268, -58.782825 -27.484425, -58.781940 -27.485721, -58.781853 -27.486380, -58.781089 -27.488276, -58.781193 -27.488057, -58.781741 -27.487980, -58.782168 -27.490487, -58.780847 -27.490733, -58.779931 -27.490454, -58.775596 -27.500692, -58.779595 -27.502026, -58.779637 -27.502122, -58.779472 -27.502746, -58.780119 -27.506279, -58.787568 -27.505248, -58.787553 -27.504566)', 4326)
 where id = (select rv.id from public.route_variants rv join public.lines l on l.id = rv.line_id join public.networks n on n.id = l.network_id where n.code = 'corrientes-capital' and l.code = '106' and rv.branch is not distinct from 'A' and rv.direction = 1);
delete from public.route_stops where route_variant_id = (select rv.id from public.route_variants rv join public.lines l on l.id = rv.line_id join public.networks n on n.id = l.network_id where n.code = 'corrientes-capital' and l.code = '106' and rv.branch is not distinct from 'A' and rv.direction = 1);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select (select rv.id from public.route_variants rv join public.lines l on l.id = rv.line_id join public.networks n on n.id = l.network_id where n.code = 'corrientes-capital' and l.code = '106' and rv.branch is not distinct from 'A' and rv.direction = 1), s.id, p.orden
  from unnest(array[906, 565, 566, 396, 222, 397, 84, 1101, 85, 86, 223, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 236, 237, 238, 239, 240, 241, 1214, 242, 243, 570, 571, 572, 568, 1083, 1084, 1085, 1086, 1087, 1209, 1089, 1090, 1091, 1092, 1093, 1094, 882, 1096])
       with ordinality as p(gid, orden)
  join public.stops s on s.source_ref = 'ctes:' || p.gid;
-- </correcciones>

-- Las dos paradas que solo usaban los recorridos viejos (Cuba y Turín
-- de la vuelta vieja de la 106A, Av. Independencia y Milán de la 102A):
-- sin ningún recorrido, son puntos en el mapa que no contestan nada.
update public.stops s
   set is_active = false
 where s.source_ref in ('ctes:1095', 'ctes:1149')
   and not exists (select 1 from public.route_stops rs where rs.stop_id = s.id);

-- Si a algún recorrido le faltó una parada (una ctes:N que no está en
-- esta base), no se aplica nada: mejor el recorrido viejo entero que uno
-- nuevo a medias.
do $$
declare
    faltan text;
begin
    select string_agg(format('%s%s %s: %s de %s', l.code, rv.branch,
                             case rv.direction when 0 then 'ida' else 'vuelta' end,
                             (select count(*) from public.route_stops rs
                               where rs.route_variant_id = rv.id),
                             e.esperadas), ', ')
      into faltan
      from (values ('102', 0, 35), ('102', 1, 33),
                   ('106', 0, 44), ('106', 1, 48)) e(linea, sentido, esperadas)
      join public.lines l on l.code = e.linea
      join public.networks n on n.id = l.network_id and n.code = 'corrientes-capital'
      join public.route_variants rv on rv.line_id = l.id and rv.branch = 'A'
                                   and rv.direction = e.sentido
     where (select count(*) from public.route_stops rs
             where rs.route_variant_id = rv.id) <> e.esperadas;
    if faltan is not null then
        raise exception 'Faltan paradas, no se aplicó nada: %', faltan;
    end if;
end $$;

commit;

-- Controles, en este orden:
--
-- 1) Las cuatro, con su cantidad de paradas y su largo (tiene que dar
--    102A 0 | 35 | ~8,3 km; 102A 1 | 33 | ~9,1; 106A 0 | 44 | ~11,2;
--    106A 1 | 48 | ~11,9).
--      select l.code || rv.branch, rv.direction,
--             (select count(*) from public.route_stops rs where rs.route_variant_id = rv.id),
--             round((st_length(rv.geom::geography) / 1000)::numeric, 1)
--        from public.route_variants rv
--        join public.lines l on l.id = rv.line_id
--        join public.networks n on n.id = l.network_id and n.code = 'corrientes-capital'
--       where l.code in ('102', '106') and rv.branch = 'A'
--       order by 1, 2;
--
-- 2) La ida de la 102A pasa ahora por San Martín (la primera parada de
--    San Martín tiene que aparecer).
--      select s.name from public.route_stops rs
--        join public.stops s on s.id = rs.stop_id
--        join public.route_variants rv on rv.id = rs.route_variant_id
--        join public.lines l on l.id = rv.line_id and l.code = '102'
--       where rv.branch = 'A' and rv.direction = 0 and s.name like 'San Martín y%'
--       order by rs.stop_order limit 1;
--
-- 3) Todas las paradas tienen distancia (la 0018 sigue andando): 0.
--      select count(*) from public.route_stops where dist_m is null;
