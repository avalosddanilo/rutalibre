-- ====================================================================
-- RUTA LIBRE — Recorridos urbanos de Corrientes capital
--
-- GENERADO AUTOMÁTICAMENTE por tools/corrientes_import.dart.
-- No editar a mano: se regenera con
--   dart run tools/corrientes_import.dart
--
-- Fuente: Municipalidad de la Ciudad de Corrientes,
--   Dirección General de Sistemas de Información Geográfica.
--   https://datos.ciudaddecorrientes.gov.ar/dataset/bd941d41-8906-4494-9e31-135d4c309de2/resource/b60f67ef-bf0e-459e-98ff-2cde25c486dc/download/recorridosurbanos.csv
--   OJO: el portal NO declara licencia. Atribución obligatoria
--   y revisar antes de publicar comercialmente.
--
-- Coordenadas: el origen viene en Gauss-Krüger Faja 5 y se
-- reproyecta a WGS84 en el importador (ver gauss_kruger.dart).
--
-- Fecha de extracción: 2026-08-05T07:26:08.379443Z
-- Líneas: 10 | Recorridos: 60 | Paradas: 0 (el portal dio
-- de baja el recurso de paradas).
--
-- REQUIERE la migración 0003 aplicada.
-- ====================================================================

begin;

-- ------------------------------------------------------------
-- 0. Baja lógica de todo lo anterior de esta red
-- ------------------------------------------------------------
update public.route_variants rv
   set is_active = false
  from public.lines l, public.networks n
 where rv.line_id = l.id
   and l.network_id = n.id
   and n.code = 'corrientes-capital';

-- ------------------------------------------------------------
-- 1. Líneas (10)
-- ------------------------------------------------------------
insert into public.lines (network_id, code, name, color_hex, sort_order, is_active)
values ((select id from public.networks where code = 'corrientes-capital'),
        '101', 'B° Cremonte ↔ Puerto y 1 ramal más', '#0288D1', 1, true)
on conflict (network_id, code) do update set
    name = excluded.name,
    color_hex = excluded.color_hex,
    sort_order = excluded.sort_order,
    is_active = true;
insert into public.lines (network_id, code, name, color_hex, sort_order, is_active)
values ((select id from public.networks where code = 'corrientes-capital'),
        '102', 'Laguna Seca ↔ Puerto y 2 ramales más', '#E64A19', 2, true)
on conflict (network_id, code) do update set
    name = excluded.name,
    color_hex = excluded.color_hex,
    sort_order = excluded.sort_order,
    is_active = true;
insert into public.lines (network_id, code, name, color_hex, sort_order, is_active)
values ((select id from public.networks where code = 'corrientes-capital'),
        '103', 'B° Esperanza ↔ Puerto y 4 ramales más', '#512DA8', 3, true)
on conflict (network_id, code) do update set
    name = excluded.name,
    color_hex = excluded.color_hex,
    sort_order = excluded.sort_order,
    is_active = true;
insert into public.lines (network_id, code, name, color_hex, sort_order, is_active)
values ((select id from public.networks where code = 'corrientes-capital'),
        '104', 'Ersa ↔ B° Villa Patono ↔ Centro y 3 ramales más', '#00695C', 4, true)
on conflict (network_id, code) do update set
    name = excluded.name,
    color_hex = excluded.color_hex,
    sort_order = excluded.sort_order,
    is_active = true;
insert into public.lines (network_id, code, name, color_hex, sort_order, is_active)
values ((select id from public.networks where code = 'corrientes-capital'),
        '105', 'Molina ↔ Taitalo y 4 ramales más', '#AD1457', 5, true)
on conflict (network_id, code) do update set
    name = excluded.name,
    color_hex = excluded.color_hex,
    sort_order = excluded.sort_order,
    is_active = true;
insert into public.lines (network_id, code, name, color_hex, sort_order, is_active)
values ((select id from public.networks where code = 'corrientes-capital'),
        '106', 'B° 500 VIV. ↔ Centro y 3 ramales más', '#F9A825', 6, true)
on conflict (network_id, code) do update set
    name = excluded.name,
    color_hex = excluded.color_hex,
    sort_order = excluded.sort_order,
    is_active = true;
insert into public.lines (network_id, code, name, color_hex, sort_order, is_active)
values ((select id from public.networks where code = 'corrientes-capital'),
        '108', '40 VIV. F.J. Quintana-San Roque ↔ Centro', '#1976D2', 7, true)
on conflict (network_id, code) do update set
    name = excluded.name,
    color_hex = excluded.color_hex,
    sort_order = excluded.sort_order,
    is_active = true;
insert into public.lines (network_id, code, name, color_hex, sort_order, is_active)
values ((select id from public.networks where code = 'corrientes-capital'),
        '109', 'B° Rio Parana ↔ B° Yecoha y 1 ramal más', '#388E3C', 8, true)
on conflict (network_id, code) do update set
    name = excluded.name,
    color_hex = excluded.color_hex,
    sort_order = excluded.sort_order,
    is_active = true;
insert into public.lines (network_id, code, name, color_hex, sort_order, is_active)
values ((select id from public.networks where code = 'corrientes-capital'),
        '110', '17 de Agosto ↔ Galvan y 2 ramales más', '#455A64', 9, true)
on conflict (network_id, code) do update set
    name = excluded.name,
    color_hex = excluded.color_hex,
    sort_order = excluded.sort_order,
    is_active = true;
insert into public.lines (network_id, code, name, color_hex, sort_order, is_active)
values ((select id from public.networks where code = 'corrientes-capital'),
        'Aerobus', 'Puerto ↔ Aeropuerto', '#5D4037', 10, true)
on conflict (network_id, code) do update set
    name = excluded.name,
    color_hex = excluded.color_hex,
    sort_order = excluded.sort_order,
    is_active = true;

-- ------------------------------------------------------------
-- 2. Recorridos con su trazado (60)
--    Identidad natural: (línea, ramal, sentido). Estos datos
--    no traen un id estable de origen.
-- ------------------------------------------------------------
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = 'Aerobus'),
        'Ida: Puerto ↔ Aeropuerto', null, 0,
        st_geomfromtext('LINESTRING(-58.837966 -27.461489, -58.838376 -27.461496, -58.838731 -27.461652, -58.841664 -27.461411, -58.843286 -27.462271, -58.843832 -27.462655, -58.844487 -27.463478, -58.844711 -27.463652, -58.845013 -27.463815, -58.845874 -27.463974, -58.846507 -27.464323, -58.846730 -27.466776, -58.846796 -27.467838, -58.846746 -27.467938, -58.841850 -27.468127, -58.833178 -27.468995, -58.832979 -27.466848, -58.832882 -27.466754, -58.830350 -27.466941, -58.830638 -27.469230, -58.822909 -27.469984, -58.822511 -27.467537, -58.821244 -27.466816, -58.820862 -27.466760, -58.819848 -27.466785, -58.818679 -27.466847, -58.818014 -27.467076, -58.813973 -27.467632, -58.808495 -27.467196, -58.807650 -27.467204, -58.807121 -27.467287, -58.801071 -27.469063, -58.800167 -27.469154, -58.799627 -27.469114, -58.779084 -27.464077, -58.769746 -27.461694, -58.768600 -27.461416, -58.767969 -27.461392, -58.753865 -27.450805, -58.753492 -27.450771, -58.750492 -27.448492, -58.750790 -27.448099, -58.755447 -27.451655, -58.757057 -27.449793, -58.757191 -27.449350, -58.757857 -27.449287)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = 'Aerobus'),
        'Vuelta: Aeropuerto ↔ Puerto', null, 1,
        st_geomfromtext('LINESTRING(-58.757867 -27.449290, -58.758318 -27.449251, -58.758675 -27.449317, -58.758769 -27.449384, -58.758807 -27.449589, -58.758736 -27.449659, -58.757045 -27.449862, -58.755459 -27.451734, -58.755449 -27.451904, -58.767508 -27.460995, -58.767886 -27.461161, -58.799395 -27.469006, -58.800203 -27.469074, -58.800938 -27.469007, -58.807611 -27.467142, -58.808452 -27.467129, -58.813899 -27.467540, -58.816594 -27.467200, -58.818688 -27.466804, -58.821249 -27.466662, -58.822393 -27.466348, -58.822909 -27.466596, -58.830107 -27.465926, -58.830238 -27.465963, -58.830736 -27.470341, -58.838189 -27.469651, -58.838273 -27.469614, -58.837504 -27.461884, -58.837584 -27.461700, -58.837956 -27.461492)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = '101'),
        'Vuelta: Puerto ↔ B° Ponce', 'B', 1,
        st_geomfromtext('LINESTRING(-58.837833 -27.461560, -58.838798 -27.461620, -58.841200 -27.461438, -58.841332 -27.462380, -58.841577 -27.466095, -58.830348 -27.466967, -58.830607 -27.469228, -58.814132 -27.470859, -58.803781 -27.473341, -58.798632 -27.474912, -58.792472 -27.476116, -58.788696 -27.476671, -58.788551 -27.476639, -58.788492 -27.476460, -58.787744 -27.471537, -58.787088 -27.471617, -58.786997 -27.470843, -58.787726 -27.470759, -58.788646 -27.476704, -58.785941 -27.477304, -58.784290 -27.477984, -58.778020 -27.479499, -58.775994 -27.479764, -58.770469 -27.480673, -58.770872 -27.482113, -58.769960 -27.482296, -58.771983 -27.494020, -58.769756 -27.494338, -58.770180 -27.496798)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = '101'),
        'Ida: B° Cremonte ↔ Puerto', 'B', 0,
        st_geomfromtext('LINESTRING(-58.770175 -27.496683, -58.770264 -27.496726, -58.773407 -27.496280, -58.773461 -27.496217, -58.773093 -27.493918, -58.775101 -27.493651, -58.776095 -27.493851, -58.776422 -27.493814, -58.777928 -27.494316, -58.778047 -27.494273, -58.781600 -27.485858, -58.781676 -27.485255, -58.781488 -27.484657, -58.781511 -27.484411, -58.782378 -27.483487, -58.783317 -27.481810, -58.783516 -27.481300, -58.783633 -27.480786, -58.783638 -27.480208, -58.783509 -27.479570, -58.783082 -27.478409, -58.783107 -27.478304, -58.783304 -27.478171, -58.784557 -27.477825, -58.786077 -27.477154, -58.788511 -27.476645, -58.787761 -27.471561, -58.787078 -27.471637, -58.786973 -27.470858, -58.787743 -27.470774, -58.788666 -27.476611, -58.792443 -27.476013, -58.798096 -27.474954, -58.803394 -27.473386, -58.812617 -27.471200, -58.812775 -27.471286, -58.813003 -27.472171, -58.819261 -27.471550, -58.823000 -27.471095, -58.838287 -27.469680, -58.837509 -27.461787, -58.837718 -27.461581, -58.837833 -27.461560)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = '101'),
        'Vuelta: Puerto ↔ Riachuelo ↔ Cremonte', 'C', 1,
        st_geomfromtext('LINESTRING(-58.838415 -27.461546, -58.838798 -27.461633, -58.841227 -27.461445, -58.841276 -27.461511, -58.841592 -27.466081, -58.830355 -27.466962, -58.830616 -27.469244, -58.814101 -27.470857, -58.803431 -27.473487, -58.798255 -27.475011, -58.792462 -27.476127, -58.788683 -27.476690, -58.788542 -27.476656, -58.787742 -27.471552, -58.787090 -27.471626, -58.786985 -27.470851, -58.787741 -27.470760, -58.788628 -27.476702, -58.786056 -27.477268, -58.784788 -27.477824, -58.779263 -27.479249, -58.777965 -27.479506, -58.770458 -27.480676, -58.770900 -27.482103, -58.769943 -27.482305, -58.771931 -27.494086, -58.769793 -27.494388, -58.770249 -27.496785, -58.773515 -27.496318, -58.773091 -27.493869, -58.774925 -27.493663, -58.776211 -27.493873, -58.776193 -27.493756, -58.778032 -27.494392, -58.773077 -27.506371, -58.765165 -27.524836, -58.763954 -27.527835, -58.763249 -27.528878, -58.760135 -27.532385, -58.758277 -27.534748, -58.757058 -27.536095, -58.754971 -27.538640, -58.753267 -27.541725, -58.752158 -27.544946, -58.749292 -27.558700, -58.748038 -27.561700, -58.742954 -27.567204, -58.740857 -27.575710, -58.740496 -27.582588, -58.743659 -27.582078, -58.746822 -27.581721)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = '101'),
        'Ida: Bº Cremonte ↔ Riachuelo ↔ Puerto', 'C', 0,
        st_geomfromtext('LINESTRING(-58.746822 -27.581721, -58.743674 -27.582047, -58.740431 -27.582522, -58.740657 -27.575766, -58.742727 -27.567142, -58.747940 -27.561621, -58.749150 -27.558693, -58.752078 -27.544901, -58.753206 -27.541671, -58.754885 -27.538625, -58.756984 -27.536059, -58.758254 -27.534737, -58.760231 -27.532243, -58.763177 -27.528860, -58.763886 -27.527814, -58.766552 -27.521366, -58.781412 -27.486291, -58.781862 -27.484983, -58.781805 -27.484178, -58.781892 -27.484027, -58.782329 -27.483782, -58.782431 -27.483631, -58.783127 -27.481948, -58.783470 -27.480721, -58.783460 -27.479854, -58.783272 -27.478629, -58.783402 -27.478136, -58.784700 -27.477787, -58.786001 -27.477212, -58.788545 -27.476631, -58.787763 -27.471521, -58.787096 -27.471597, -58.786996 -27.470869, -58.787757 -27.470783, -58.788664 -27.476636, -58.791323 -27.476213, -58.798633 -27.474836, -58.804049 -27.473197, -58.812718 -27.471148, -58.812822 -27.471220, -58.812933 -27.472168, -58.829460 -27.470475, -58.838279 -27.469650, -58.837519 -27.461836, -58.837700 -27.461581, -58.838417 -27.461544)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = '102'),
        'Ida: Laguna Seca ↔ Puerto', 'B', 0,
        st_geomfromtext('LINESTRING(-58.808191 -27.490554, -58.805466 -27.490964, -58.803792 -27.491762, -58.802499 -27.492917, -58.799503 -27.492663, -58.799436 -27.492542, -58.799565 -27.491386, -58.799684 -27.491336, -58.801091 -27.491448, -58.801213 -27.490268, -58.801294 -27.490125, -58.802400 -27.489582, -58.802490 -27.489619, -58.803230 -27.490832, -58.805240 -27.489843, -58.807941 -27.489427, -58.807998 -27.489340, -58.807421 -27.486624, -58.807456 -27.486524, -58.807579 -27.486497, -58.811435 -27.487190, -58.816135 -27.486780, -58.814711 -27.478730, -58.814685 -27.478463, -58.814755 -27.478313, -58.838798 -27.475270, -58.838889 -27.475142, -58.838750 -27.473711, -58.837475 -27.461896, -58.837603 -27.461614, -58.837950 -27.461506)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = '102'),
        'Ida: Laguna Brava ↔ Centro', 'C', 0,
        st_geomfromtext('LINESTRING(-58.718522 -27.497543, -58.716429 -27.497841, -58.715753 -27.494163, -58.717811 -27.493892, -58.717696 -27.493013, -58.717756 -27.492945, -58.718665 -27.492783, -58.718155 -27.489952, -58.720076 -27.489625, -58.721475 -27.489574, -58.728922 -27.490193, -58.730749 -27.490478, -58.739463 -27.492548, -58.741289 -27.492681, -58.742639 -27.492592, -58.756221 -27.490350, -58.768999 -27.486266, -58.769741 -27.486080, -58.779583 -27.484516, -58.781651 -27.484261, -58.782072 -27.483936, -58.782253 -27.483887, -58.782479 -27.483913, -58.782974 -27.484170, -58.783442 -27.484177, -58.785100 -27.483990, -58.790040 -27.483618, -58.791586 -27.483341, -58.802859 -27.480080, -58.805056 -27.479517, -58.838712 -27.475306, -58.838856 -27.475190, -58.837463 -27.461847)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = '102'),
        'Vuelta: Puerto ↔ Laguna Seca', 'B', 1,
        st_geomfromtext('LINESTRING(-58.837978 -27.461513, -58.838443 -27.461543, -58.838792 -27.461733, -58.841284 -27.461513, -58.841591 -27.466075, -58.830399 -27.466946, -58.830480 -27.468186, -58.831406 -27.476239, -58.831369 -27.476512, -58.814871 -27.478604, -58.814801 -27.478679, -58.816234 -27.486798, -58.816065 -27.486900, -58.811364 -27.487283, -58.807633 -27.486614, -58.807571 -27.486701, -58.808330 -27.490457, -58.808219 -27.490562)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = '102'),
        'Vuelta: Centro ↔ Laguna Brava', 'C', 1,
        st_geomfromtext('LINESTRING(-58.837463 -27.461847, -58.836975 -27.461873, -58.834890 -27.461168, -58.833751 -27.461200, -58.833797 -27.462498, -58.834237 -27.466671, -58.830384 -27.466933, -58.830338 -27.466993, -58.831353 -27.476144, -58.831364 -27.476456, -58.831274 -27.476545, -58.804916 -27.479841, -58.792385 -27.483424, -58.791176 -27.483737, -58.790273 -27.483888, -58.785711 -27.484216, -58.783218 -27.484281, -58.782783 -27.484445, -58.782501 -27.484720, -58.782197 -27.484765, -58.781634 -27.484370, -58.781224 -27.484346, -58.778778 -27.484673, -58.770107 -27.486039, -58.768374 -27.486506, -58.756192 -27.490389, -58.742779 -27.492606, -58.741005 -27.492708, -58.739350 -27.492560, -58.730982 -27.490563, -58.729610 -27.490306, -58.722189 -27.489646, -58.721117 -27.489598, -58.720302 -27.489641, -58.720243 -27.489712, -58.720786 -27.492485, -58.718764 -27.492777, -58.717797 -27.492977, -58.717724 -27.493061, -58.718522 -27.497543)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = '102'),
        'Ida: 17 de Agosto ↔ Puerto', 'A', 0,
        st_geomfromtext('LINESTRING(-58.789574 -27.489308, -58.784876 -27.490126, -58.781250 -27.490607, -58.781125 -27.490454, -58.781063 -27.489701, -58.782905 -27.489451, -58.783057 -27.490276, -58.784893 -27.490030, -58.789462 -27.489244, -58.792514 -27.488463, -58.793851 -27.488186, -58.795359 -27.487986, -58.795186 -27.486809, -58.795468 -27.486375, -58.795403 -27.484734, -58.795587 -27.483300, -58.795242 -27.482317, -58.804510 -27.479634, -58.806309 -27.479356, -58.838741 -27.475322, -58.838859 -27.475245, -58.838862 -27.475038, -58.837501 -27.461817, -58.837750 -27.461566, -58.837971 -27.461540)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = '102'),
        'Vuelta: Puerto ↔ 17 de Agosto', 'A', 1,
        st_geomfromtext('LINESTRING(-58.837971 -27.461540, -58.838503 -27.461584, -58.838716 -27.461666, -58.841166 -27.461465, -58.841255 -27.461568, -58.841590 -27.466104, -58.830433 -27.466953, -58.830374 -27.466999, -58.830601 -27.469165, -58.830529 -27.469235, -58.818999 -27.470384, -58.818526 -27.470501, -58.819793 -27.477623, -58.819796 -27.477821, -58.819645 -27.478026, -58.805203 -27.479817, -58.803426 -27.480266, -58.791713 -27.483640, -58.789814 -27.483943, -58.783900 -27.484394, -58.783440 -27.484480, -58.782742 -27.484778, -58.782165 -27.485293, -58.781860 -27.485832, -58.781873 -27.486340, -58.781574 -27.487094, -58.782161 -27.490375, -58.784859 -27.490041, -58.789316 -27.489308, -58.789531 -27.489197, -58.789424 -27.488392, -58.789580 -27.489308)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = '103'),
        'Ida: B° Esperanza ↔ Puerto', 'C DIRECTO', 0,
        st_geomfromtext('LINESTRING(-58.790734 -27.547395, -58.786042 -27.546929, -58.786041 -27.546850, -58.786402 -27.542967, -58.789552 -27.543216, -58.789788 -27.543171, -58.789895 -27.543016, -58.791262 -27.530912, -58.792233 -27.530237, -58.794884 -27.527773, -58.795289 -27.527230, -58.795887 -27.525999, -58.796253 -27.525445, -58.799762 -27.521754, -58.801392 -27.519156, -58.801769 -27.518725, -58.808561 -27.512483, -58.809168 -27.511836, -58.809776 -27.510600, -58.810147 -27.509543, -58.810532 -27.507406, -58.810941 -27.506093, -58.813201 -27.500890, -58.816255 -27.496569, -58.819248 -27.492052, -58.820608 -27.489554, -58.830264 -27.477381, -58.830180 -27.476413, -58.833913 -27.475934, -58.832870 -27.465653, -58.832332 -27.461297, -58.832381 -27.461148, -58.834808 -27.461075, -58.836961 -27.461742, -58.837639 -27.461674, -58.837730 -27.461532, -58.838085 -27.461494)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = '103'),
        'Ida: Riachuelo ↔ Puerto', 'D', 0,
        st_geomfromtext('LINESTRING(-58.763613 -27.581259, -58.764473 -27.563619, -58.762492 -27.563775, -58.761429 -27.564086, -58.761202 -27.564788, -58.761007 -27.566624, -58.760166 -27.568571, -58.759594 -27.569277, -58.758842 -27.569681, -58.758883 -27.581410, -58.758201 -27.581528, -58.754556 -27.581432, -58.753458 -27.581292, -58.750561 -27.581371, -58.743809 -27.582025, -58.740592 -27.582560, -58.740400 -27.582408, -58.740785 -27.575798, -58.740930 -27.574700, -58.742228 -27.568944, -58.742928 -27.567266, -58.743456 -27.566476, -58.744223 -27.565540, -58.746926 -27.562737, -58.747604 -27.561940, -58.748240 -27.560967, -58.748785 -27.559832, -58.749159 -27.558581, -58.752110 -27.544910, -58.752485 -27.543624, -58.753119 -27.541922, -58.754253 -27.539654, -58.755375 -27.537928, -58.756385 -27.536692, -58.761255 -27.531085, -58.761942 -27.530483, -58.762469 -27.530152, -58.763373 -27.529738, -58.764402 -27.529531, -58.765107 -27.529500, -58.766301 -27.529638, -58.766869 -27.529809, -58.773318 -27.532845, -58.774661 -27.533414, -58.776210 -27.533821, -58.777029 -27.533943, -58.777677 -27.534012, -58.779291 -27.533989, -58.780894 -27.533745, -58.790184 -27.531329, -58.790952 -27.531066, -58.792070 -27.530369, -58.794729 -27.527928, -58.795291 -27.527225, -58.795796 -27.526176, -58.796422 -27.525226, -58.799837 -27.521705, -58.801584 -27.518930, -58.806181 -27.514660, -58.808300 -27.512801, -58.809156 -27.511909, -58.809548 -27.511226, -58.810051 -27.509969, -58.810852 -27.506431, -58.813334 -27.500799, -58.817923 -27.494165, -58.819279 -27.492053, -58.820435 -27.489926, -58.820775 -27.489431, -58.825036 -27.483966, -58.827369 -27.481246, -58.830273 -27.477480, -58.828949 -27.466037, -58.837826 -27.465234, -58.837469 -27.461786, -58.837736 -27.461557, -58.838042 -27.461555)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = '103'),
        'Ida: DR. Montaña ↔ Puerto', 'B', 0,
        st_geomfromtext('LINESTRING(-58.791045 -27.523017, -58.791635 -27.517800, -58.791588 -27.517737, -58.789364 -27.517563, -58.788764 -27.522852, -58.793309 -27.523284, -58.794274 -27.523871, -58.796561 -27.525040, -58.796767 -27.524901, -58.799811 -27.521761, -58.801133 -27.519653, -58.801792 -27.518743, -58.806463 -27.514412, -58.808845 -27.512300, -58.809209 -27.511888, -58.809400 -27.511611, -58.810065 -27.510095, -58.810395 -27.508823, -58.810627 -27.507382, -58.810926 -27.506360, -58.813146 -27.501226, -58.818050 -27.494009, -58.819863 -27.491094, -58.820797 -27.489416, -58.830298 -27.477398, -58.830211 -27.476701, -58.830398 -27.476424, -58.833911 -27.475916, -58.832343 -27.461198, -58.832464 -27.461114, -58.834834 -27.461061, -58.836930 -27.461735, -58.837520 -27.461712, -58.837789 -27.461524, -58.838229 -27.461496)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = '103'),
        'Vuelta: B° DR. Montaña ↔ B° Esperanza', 'C Bo ESPERANZA Bo DR. MONTAÑA', 1,
        st_geomfromtext('LINESTRING(-58.788813 -27.521850, -58.789969 -27.521953, -58.789834 -27.522984, -58.793190 -27.523266, -58.796476 -27.525068, -58.796549 -27.525240, -58.796137 -27.525768, -58.795376 -27.527243, -58.794887 -27.527897, -58.792181 -27.530389, -58.791309 -27.530988, -58.791270 -27.531079, -58.790336 -27.540098, -58.789915 -27.543244, -58.790279 -27.544783, -58.790696 -27.547357)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = '103'),
        'Vuelta: Puerto ↔ DR. Montaña', 'B', 1,
        st_geomfromtext('LINESTRING(-58.838229 -27.461496, -58.838791 -27.461658, -58.841300 -27.461488, -58.841592 -27.466076, -58.839145 -27.466267, -58.839276 -27.468380, -58.830707 -27.469197, -58.830663 -27.469275, -58.831462 -27.476183, -58.831427 -27.476496, -58.831023 -27.476573, -58.830834 -27.476703, -58.828955 -27.479234, -58.820895 -27.489381, -58.819317 -27.492190, -58.813485 -27.500807, -58.811069 -27.506215, -58.810793 -27.507068, -58.810217 -27.509855, -58.809422 -27.511704, -58.808613 -27.512607, -58.806148 -27.514793, -58.801766 -27.518888, -58.799920 -27.521730, -58.796708 -27.525085, -58.796509 -27.525098, -58.794166 -27.523862, -58.793335 -27.523326, -58.791103 -27.523107, -58.791045 -27.523017)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = '103'),
        'Vuelta: Puerto ↔ B° Esperanza', 'C DIRECTO', 1,
        st_geomfromtext('LINESTRING(-58.838085 -27.461494, -58.838760 -27.461685, -58.841247 -27.461517, -58.841570 -27.466086, -58.839056 -27.466264, -58.839191 -27.468386, -58.830574 -27.469255, -58.831347 -27.476480, -58.830813 -27.476664, -58.826411 -27.482349, -58.820683 -27.489536, -58.819380 -27.491953, -58.816580 -27.496210, -58.813308 -27.500904, -58.810909 -27.506377, -58.810550 -27.507700, -58.810220 -27.509537, -58.809394 -27.511588, -58.808563 -27.512577, -58.801639 -27.518954, -58.799895 -27.521702, -58.796320 -27.525527, -58.795935 -27.526105, -58.795359 -27.527272, -58.794899 -27.527884, -58.792217 -27.530361, -58.791300 -27.530995, -58.789903 -27.543209, -58.790284 -27.544775, -58.790734 -27.547395)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = '103'),
        'Ida: B° Esperanza ↔ B° DR. Montaña', 'C Bo ESPERANZA Bo DR. MONTAÑA', 0,
        st_geomfromtext('LINESTRING(-58.790696 -27.547357, -58.789558 -27.547318, -58.786041 -27.546898, -58.786387 -27.542996, -58.786455 -27.542940, -58.789553 -27.543218, -58.789764 -27.543192, -58.789891 -27.543097, -58.791280 -27.530891, -58.792243 -27.530213, -58.794885 -27.527773, -58.795279 -27.527226, -58.795848 -27.526060, -58.796433 -27.525202, -58.796436 -27.525102, -58.794034 -27.523810, -58.793343 -27.523366, -58.788690 -27.522945, -58.788813 -27.521856)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = '103'),
        'Ida: San Antonio ↔ Puerto', 'A', 0,
        st_geomfromtext('LINESTRING(-58.813296 -27.508005, -58.819213 -27.508744, -58.826386 -27.509486, -58.826040 -27.504449, -58.826093 -27.503812, -58.831315 -27.503109, -58.831361 -27.503047, -58.831160 -27.501741, -58.831225 -27.501157, -58.830872 -27.498687, -58.830779 -27.498649, -58.825739 -27.499332, -58.825582 -27.499304, -58.825227 -27.497532, -58.825348 -27.497456, -58.828716 -27.496947, -58.832338 -27.496236, -58.831237 -27.490866, -58.830823 -27.489929, -58.830696 -27.486914, -58.830781 -27.486653, -58.831143 -27.486142, -58.831172 -27.485722, -58.830321 -27.478648, -58.830186 -27.476660, -58.830231 -27.476383, -58.838862 -27.475303, -58.837508 -27.461883, -58.837601 -27.461677, -58.837984 -27.461537)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = '103'),
        'Vuelta: Puerto ↔ San Antonio', 'A', 1,
        st_geomfromtext('LINESTRING(-58.837984 -27.461537, -58.838494 -27.461568, -58.838707 -27.461659, -58.841164 -27.461460, -58.841260 -27.461562, -58.841584 -27.466070, -58.839048 -27.466258, -58.839198 -27.468331, -58.839125 -27.468400, -58.830648 -27.469198, -58.830568 -27.469254, -58.831478 -27.477262, -58.832429 -27.484460, -58.832467 -27.486736, -58.833003 -27.490476, -58.833564 -27.493397, -58.833465 -27.493502, -58.826672 -27.494433, -58.826508 -27.494356, -58.826122 -27.492298, -58.824384 -27.492563, -58.825628 -27.499270, -58.825722 -27.499317, -58.830880 -27.498631, -58.831274 -27.501268, -58.831184 -27.501723, -58.831372 -27.503104, -58.826096 -27.503845, -58.826051 -27.504211, -58.826454 -27.509508, -58.817900 -27.508634, -58.813287 -27.508040)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = '103'),
        'Vuelta: Puerto ↔ Riachuelo', 'D', 1,
        st_geomfromtext('LINESTRING(-58.838042 -27.461555, -58.838455 -27.461576, -58.838771 -27.461699, -58.839227 -27.468395, -58.830601 -27.469236, -58.831403 -27.476419, -58.831311 -27.476545, -58.830820 -27.476608, -58.826536 -27.482261, -58.820794 -27.489431, -58.819605 -27.491636, -58.818345 -27.493609, -58.813392 -27.500904, -58.810913 -27.506449, -58.810190 -27.509726, -58.809613 -27.511213, -58.809199 -27.511935, -58.808536 -27.512656, -58.806565 -27.514391, -58.801682 -27.518944, -58.799765 -27.521879, -58.796590 -27.525202, -58.795952 -27.526042, -58.795458 -27.527115, -58.794976 -27.527783, -58.793324 -27.529351, -58.792090 -27.530455, -58.790860 -27.531191, -58.781469 -27.533649, -58.779785 -27.533988, -58.778578 -27.534072, -58.776641 -27.533946, -58.775689 -27.533762, -58.774620 -27.533448, -58.773381 -27.532934, -58.767037 -27.529904, -58.766475 -27.529714, -58.765869 -27.529582, -58.765164 -27.529544, -58.764120 -27.529603, -58.763465 -27.529750, -58.762283 -27.530296, -58.761362 -27.531000, -58.757362 -27.535595, -58.755102 -27.538372, -58.753507 -27.541123, -58.752969 -27.542359, -58.752235 -27.544571, -58.749279 -27.558154, -58.749073 -27.559016, -58.748659 -27.560192, -58.748087 -27.561286, -58.747021 -27.562697, -58.745041 -27.564707, -58.743435 -27.566537, -58.742989 -27.567213, -58.742448 -27.568421, -58.741615 -27.571732, -58.740874 -27.575305, -58.740472 -27.582264, -58.740602 -27.582556, -58.744853 -27.581902, -58.750610 -27.581368, -58.752060 -27.581301, -58.753432 -27.581273, -58.754557 -27.581414, -58.758039 -27.581504, -58.763613 -27.581259)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = '104'),
        'Vuelta: Centro ↔ B° Villa Patono', 'B', 1,
        st_geomfromtext('LINESTRING(-58.839172 -27.468388, -58.829309 -27.469339, -58.828943 -27.466094, -58.828989 -27.465981, -58.838969 -27.465114, -58.839254 -27.469508, -58.845502 -27.468971, -58.845705 -27.469108, -58.846867 -27.469066, -58.847356 -27.474406, -58.847345 -27.474487, -58.846914 -27.474590, -58.846885 -27.474685, -58.848111 -27.483588, -58.848211 -27.483600, -58.849411 -27.482894, -58.849608 -27.483013, -58.850140 -27.484504, -58.850796 -27.487445, -58.851656 -27.487818, -58.851745 -27.487933, -58.851517 -27.491246, -58.851499 -27.491425, -58.851396 -27.491524, -58.840944 -27.493483, -58.841581 -27.499495, -58.841618 -27.500470, -58.841567 -27.500487)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = '104'),
        'Ida: Ersa ↔ B° Villa Patono ↔ Centro', 'B', 0,
        st_geomfromtext('LINESTRING(-58.841567 -27.500487, -58.841346 -27.497449, -58.840927 -27.493437, -58.851393 -27.491479, -58.851464 -27.491335, -58.851708 -27.487916, -58.850768 -27.487462, -58.850107 -27.484503, -58.849704 -27.483245, -58.849235 -27.482257, -58.848314 -27.475578, -58.845775 -27.475927, -58.845639 -27.474727, -58.843696 -27.474947, -58.843553 -27.474776, -58.843444 -27.473788, -58.846020 -27.473489, -58.845527 -27.468071, -58.845385 -27.468008, -58.844266 -27.468088, -58.842993 -27.468067, -58.839172 -27.468388)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = '104'),
        'Ida: B° 1000 VIV. ↔ Morgue', 'D', 0,
        st_geomfromtext('LINESTRING(-58.833573 -27.493422, -58.833500 -27.493499, -58.824887 -27.494682, -58.824785 -27.494752, -58.825280 -27.497393, -58.825387 -27.497468, -58.826985 -27.497222, -58.827036 -27.497116, -58.825867 -27.490545, -58.830763 -27.490010, -58.830827 -27.489931, -58.830697 -27.486923, -58.830750 -27.486679, -58.831127 -27.486139, -58.831128 -27.485511, -58.831182 -27.485485, -58.834292 -27.486375, -58.835186 -27.486288, -58.835257 -27.486216, -58.835202 -27.485751, -58.835266 -27.485631, -58.837621 -27.485370, -58.837743 -27.485197, -58.837065 -27.479421, -58.836636 -27.477094, -58.836480 -27.475656, -58.836600 -27.475569, -58.837357 -27.475451, -58.838894 -27.475328, -58.838571 -27.471517, -58.837739 -27.465192, -58.837480 -27.461806, -58.836987 -27.461862, -58.834691 -27.461140, -58.829522 -27.461281, -58.827309 -27.462741, -58.827149 -27.459456, -58.827084 -27.459372, -58.823381 -27.459486, -58.819127 -27.459845, -58.819041 -27.459948, -58.819282 -27.464357)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = '104'),
        'Vuelta: B° Pujol ↔ B° Rio Parana', 'C', 1,
        st_geomfromtext('LINESTRING(-58.805954 -27.464888, -58.806836 -27.464472, -58.806968 -27.464523, -58.808318 -27.467064, -58.814120 -27.467516, -58.816126 -27.467262, -58.818010 -27.466900, -58.818176 -27.466758, -58.817988 -27.461693, -58.829195 -27.461302, -58.829669 -27.461183, -58.829829 -27.461304, -58.830153 -27.464861, -58.830328 -27.465872, -58.839054 -27.465110, -58.839697 -27.475325, -58.839595 -27.475477, -58.837870 -27.475707, -58.837809 -27.475799, -58.839412 -27.485098, -58.839366 -27.485214, -58.839242 -27.485261, -58.838054 -27.485392, -58.837991 -27.485481, -58.838191 -27.486606, -58.838228 -27.497821, -58.838172 -27.497921, -58.838006 -27.497967, -58.834706 -27.498386, -58.832944 -27.498357, -58.831025 -27.498617, -58.830976 -27.498686, -58.831359 -27.501154, -58.831288 -27.501603, -58.834367 -27.501248, -58.834624 -27.502714, -58.826302 -27.503775, -58.826156 -27.503891, -58.826468 -27.508965, -58.826605 -27.509514, -58.830895 -27.510012)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = '104'),
        'Vuelta: Morgue ↔ B° 1000 VIV.', 'D', 1,
        st_geomfromtext('LINESTRING(-58.819282 -27.464357, -58.819275 -27.465523, -58.818042 -27.465565, -58.817860 -27.461751, -58.817949 -27.461698, -58.829182 -27.461304, -58.829360 -27.461209, -58.829670 -27.461191, -58.829742 -27.461272, -58.830212 -27.465893, -58.838973 -27.465143, -58.839634 -27.475359, -58.839575 -27.475477, -58.837748 -27.475740, -58.837718 -27.475850, -58.839311 -27.485191, -58.839254 -27.485257, -58.834760 -27.485762, -58.834077 -27.485736, -58.832548 -27.485288, -58.832431 -27.485360, -58.832491 -27.486408, -58.832432 -27.486719, -58.832856 -27.489329, -58.832823 -27.489502, -58.833573 -27.493422)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = '104'),
        'Vuelta: Morgue ↔ B° Juan de Vera', 'A', 1,
        st_geomfromtext('LINESTRING(-58.819319 -27.464377, -58.825091 -27.464213, -58.825916 -27.463655, -58.826059 -27.464013, -58.826447 -27.466246, -58.839013 -27.465117, -58.839641 -27.474116, -58.847298 -27.473423, -58.847379 -27.474538, -58.846925 -27.474607, -58.847041 -27.475726, -58.844464 -27.476104, -58.845648 -27.484466)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = '104'),
        'Ida: B° Juan de Vera ↔ Morgue', 'A', 0,
        st_geomfromtext('LINESTRING(-58.845648 -27.484466, -58.847085 -27.484255, -58.849416 -27.482919, -58.849608 -27.483003, -58.849750 -27.483258, -58.850188 -27.484728, -58.850798 -27.487497, -58.851700 -27.487873, -58.851726 -27.487952, -58.851480 -27.491443, -58.851289 -27.491545, -58.841105 -27.493408, -58.840982 -27.493408, -58.840771 -27.493214, -58.840650 -27.493205, -58.838087 -27.493274, -58.838033 -27.493154, -58.838052 -27.489181, -58.838105 -27.489114, -58.844727 -27.488234, -58.844797 -27.488149, -58.843350 -27.477433, -58.845958 -27.477090, -58.845795 -27.475912, -58.839188 -27.476788, -58.839121 -27.475730, -58.838951 -27.475250, -58.838611 -27.473074, -58.838113 -27.468533, -58.837536 -27.461862, -58.836934 -27.461852, -58.834833 -27.461170, -58.829552 -27.461306, -58.827176 -27.462902, -58.824711 -27.463013, -58.824642 -27.462989, -58.824639 -27.460968, -58.824543 -27.459462, -58.819180 -27.459878, -58.819319 -27.464377)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = '104'),
        'Ida: B° Rio Parana ↔ B° Pujol', 'C', 0,
        st_geomfromtext('LINESTRING(-58.830895 -27.510012, -58.826554 -27.509543, -58.826439 -27.509059, -58.826094 -27.504092, -58.826137 -27.503801, -58.826279 -27.503750, -58.831405 -27.503085, -58.831234 -27.501742, -58.831333 -27.501260, -58.830953 -27.498733, -58.830799 -27.498634, -58.825698 -27.499338, -58.825620 -27.499287, -58.825314 -27.497547, -58.825404 -27.497467, -58.828578 -27.496994, -58.833794 -27.496004, -58.838115 -27.495399, -58.838086 -27.486332, -58.837692 -27.484660, -58.837142 -27.480124, -58.836467 -27.475594, -58.838923 -27.475268, -58.837542 -27.461820, -58.837043 -27.461860, -58.834803 -27.461154, -58.829617 -27.461281, -58.827443 -27.462698, -58.827360 -27.462591, -58.827213 -27.459380, -58.827048 -27.459337, -58.824521 -27.459432, -58.819229 -27.459851, -58.819167 -27.460007, -58.819432 -27.465495, -58.819453 -27.466641, -58.819363 -27.466766, -58.818545 -27.466841, -58.817901 -27.467085, -58.814038 -27.467613, -58.808931 -27.467185, -58.807856 -27.465154, -58.806438 -27.465682, -58.806352 -27.465647, -58.805954 -27.464888)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = '105'),
        'Vuelta: Taitalo ↔ Molina', 'A COLECTORA', 1,
        st_geomfromtext('LINESTRING(-58.780442 -27.446710, -58.781326 -27.444521, -58.781808 -27.443873, -58.779729 -27.443266, -58.781031 -27.439721, -58.780002 -27.439437, -58.779731 -27.438704, -58.779540 -27.438452, -58.779303 -27.438326, -58.779088 -27.438095, -58.778899 -27.434418, -58.777444 -27.433380, -58.776634 -27.434112)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = '105'),
        'Ida: Molina ↔ Taitalo', 'A COLECTORA', 0,
        st_geomfromtext('LINESTRING(-58.776634 -27.434112, -58.775823 -27.434867, -58.776547 -27.436004, -58.776661 -27.436068, -58.778158 -27.435034, -58.778877 -27.434704, -58.778952 -27.435159, -58.779032 -27.437838, -58.779202 -27.438237, -58.779302 -27.438322, -58.779787 -27.438329, -58.781347 -27.438787, -58.778919 -27.445612, -58.778807 -27.445631, -58.778431 -27.446037, -58.780386 -27.446674)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = '105'),
        'Vuelta: Puerto ↔ Perichon', 'C PERICHON', 1,
        st_geomfromtext('LINESTRING(-58.837929 -27.461526, -58.838393 -27.461525, -58.838760 -27.461720, -58.841228 -27.461501, -58.841597 -27.466103, -58.839061 -27.466274, -58.839187 -27.468329, -58.839122 -27.468391, -58.822927 -27.469973, -58.822517 -27.467494, -58.821079 -27.466739, -58.818641 -27.466815, -58.818046 -27.467039, -58.814073 -27.467620, -58.808398 -27.467165, -58.807454 -27.467196, -58.801381 -27.468960, -58.800340 -27.469133, -58.799718 -27.469117, -58.790108 -27.466751, -58.789314 -27.466606, -58.768607 -27.461394, -58.767966 -27.461377, -58.765820 -27.459763, -58.765796 -27.459591, -58.765912 -27.459516, -58.767344 -27.459675, -58.767615 -27.459649, -58.768537 -27.458447, -58.768642 -27.457331, -58.768586 -27.457250, -58.767054 -27.457105, -58.766785 -27.457342, -58.766485 -27.457111, -58.764923 -27.459013, -58.753879 -27.450832, -58.753545 -27.450804, -58.750504 -27.448486, -58.750879 -27.447915, -58.750877 -27.447703, -58.750833 -27.447556, -58.750345 -27.446963, -58.750022 -27.446047, -58.748413 -27.437306, -58.748204 -27.436249, -58.747949 -27.435428, -58.746742 -27.428457, -58.746441 -27.425048, -58.745226 -27.413965, -58.745264 -27.413796, -58.745425 -27.413646, -58.748040 -27.412025)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = '105'),
        'Ida: Perichon ↔ Puerto', 'C PERICHON', 0,
        st_geomfromtext('LINESTRING(-58.748040 -27.412025, -58.752202 -27.418878, -58.746256 -27.422672, -58.746221 -27.422760, -58.746806 -27.428631, -58.748002 -27.435535, -58.748204 -27.436108, -58.748488 -27.437427, -58.750025 -27.445842, -58.750369 -27.446905, -58.750905 -27.447639, -58.750865 -27.448110, -58.750929 -27.448206, -58.753971 -27.450541, -58.754061 -27.450829, -58.765544 -27.459526, -58.767507 -27.459687, -58.767615 -27.459640, -58.768519 -27.458524, -58.768637 -27.457317, -58.768559 -27.457243, -58.766958 -27.457131, -58.766351 -27.457886, -58.766416 -27.458026, -58.768565 -27.458262, -58.768537 -27.458557, -58.767642 -27.459668, -58.767513 -27.459718, -58.765944 -27.459552, -58.765788 -27.459604, -58.765882 -27.459768, -58.767585 -27.461034, -58.799133 -27.468948, -58.800222 -27.469074, -58.801322 -27.468905, -58.806955 -27.467244, -58.807821 -27.467094, -58.814073 -27.467527, -58.816106 -27.467272, -58.818555 -27.466765, -58.821335 -27.466628, -58.822364 -27.466319, -58.822997 -27.466538, -58.832860 -27.465629, -58.832530 -27.463349, -58.832333 -27.461273, -58.832396 -27.461120, -58.834946 -27.461072, -58.836993 -27.461764, -58.837456 -27.461717, -58.837741 -27.461552, -58.837929 -27.461526)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = '105'),
        'Vuelta: Puerto ↔ B° Docente', 'B', 1,
        st_geomfromtext('LINESTRING(-58.838065 -27.461534, -58.838722 -27.461647, -58.841251 -27.461513, -58.841557 -27.466082, -58.839080 -27.466272, -58.839148 -27.468394, -58.814407 -27.470795, -58.812769 -27.471130, -58.812637 -27.471049, -58.812221 -27.469602, -58.812100 -27.468680, -58.811745 -27.467444, -58.808322 -27.467156, -58.807460 -27.467205, -58.801187 -27.469012, -58.800171 -27.469142, -58.799309 -27.469049, -58.790878 -27.466937, -58.790081 -27.466845, -58.786609 -27.461588, -58.786373 -27.461445, -58.785021 -27.461346, -58.784930 -27.461210, -58.784612 -27.459193, -58.786586 -27.458894, -58.786214 -27.456888, -58.786945 -27.456761, -58.786215 -27.453300, -58.786027 -27.453102, -58.785345 -27.452654, -58.785098 -27.452357, -58.784454 -27.452143, -58.784743 -27.451228, -58.784675 -27.451139, -58.783337 -27.450746, -58.783248 -27.450642, -58.783276 -27.450413, -58.783160 -27.450334, -58.781627 -27.449866, -58.781402 -27.450055, -58.779385 -27.449463, -58.781287 -27.444496, -58.781784 -27.443878, -58.783686 -27.444438, -58.784293 -27.442731, -58.784341 -27.442760)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = '105'),
        'Ida: B° 250 VIV. ↔ Puerto', 'C 250 VIV.', 0,
        st_geomfromtext('LINESTRING(-58.768543 -27.458230, -58.768624 -27.457286, -58.767008 -27.457109, -58.766333 -27.457907, -58.766375 -27.458004, -58.768449 -27.458207, -58.768576 -27.458292, -58.768486 -27.458640, -58.767535 -27.459709, -58.765912 -27.459544, -58.765818 -27.459582, -58.765828 -27.459733, -58.767772 -27.461122, -58.789636 -27.466602, -58.799254 -27.468969, -58.799923 -27.469067, -58.800751 -27.469025, -58.801440 -27.468871, -58.806938 -27.467250, -58.807637 -27.467114, -58.808402 -27.467099, -58.814089 -27.467531, -58.816106 -27.467259, -58.818558 -27.466771, -58.821156 -27.466661, -58.822386 -27.466326, -58.822900 -27.466534, -58.832874 -27.465628, -58.832592 -27.463868, -58.832331 -27.461274, -58.832388 -27.461120, -58.834937 -27.461076, -58.837002 -27.461753, -58.837442 -27.461728, -58.837667 -27.461576, -58.838053 -27.461560)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = '105'),
        'Vuelta: Puerto ↔ B° Molina Punta', 'A', 1,
        st_geomfromtext('LINESTRING(-58.837949 -27.461529, -58.838374 -27.461521, -58.838719 -27.461653, -58.838765 -27.461756, -58.841260 -27.461502, -58.841565 -27.466116, -58.839088 -27.466306, -58.839201 -27.468410, -58.814325 -27.470806, -58.806333 -27.472693, -58.806171 -27.472599, -58.805053 -27.468883, -58.804946 -27.468786, -58.803990 -27.468975, -58.803700 -27.468275, -58.800928 -27.469059, -58.800201 -27.469132, -58.799507 -27.469085, -58.774811 -27.462969, -58.774787 -27.462793, -58.775499 -27.460359, -58.778504 -27.452336, -58.778538 -27.451543, -58.780382 -27.446699, -58.778425 -27.446086, -58.778374 -27.446015, -58.778874 -27.445485, -58.779694 -27.443310)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = '105'),
        'Ida: B° Molina Punta ↔ Puerto', 'A', 0,
        st_geomfromtext('LINESTRING(-58.779694 -27.443310, -58.783677 -27.444423, -58.778631 -27.457543, -58.778805 -27.457746, -58.778789 -27.458157, -58.778594 -27.458435, -58.778279 -27.458504, -58.777408 -27.460709, -58.775643 -27.460519, -58.775536 -27.460557, -58.774830 -27.462763, -58.774904 -27.462892, -58.799534 -27.469023, -58.800129 -27.469073, -58.800975 -27.468985, -58.804929 -27.467839, -58.805027 -27.467896, -58.805328 -27.469216, -58.806346 -27.472604, -58.806426 -27.472634, -58.812465 -27.471193, -58.812768 -27.471240, -58.812988 -27.472039, -58.813133 -27.472103, -58.838208 -27.469643, -58.838273 -27.469570, -58.837469 -27.461837, -58.837578 -27.461628, -58.837949 -27.461529)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = '105'),
        'Ida: B° Docente ↔ Puerto', 'B', 0,
        st_geomfromtext('LINESTRING(-58.784341 -27.442765, -58.783386 -27.445322, -58.781581 -27.449757, -58.781634 -27.449835, -58.783283 -27.450360, -58.783265 -27.450636, -58.783345 -27.450714, -58.784722 -27.451137, -58.784780 -27.451240, -58.784479 -27.452107, -58.785157 -27.452346, -58.785345 -27.452592, -58.786229 -27.453196, -58.786339 -27.453372, -58.787145 -27.457734, -58.783775 -27.458257, -58.784238 -27.461172, -58.786427 -27.461376, -58.786651 -27.461506, -58.789755 -27.466283, -58.790086 -27.466686, -58.799174 -27.468954, -58.800131 -27.469071, -58.801155 -27.468943, -58.806778 -27.467287, -58.807647 -27.467112, -58.808932 -27.467127, -58.814053 -27.467526, -58.818152 -27.466955, -58.818333 -27.467069, -58.818628 -27.469513, -58.818860 -27.469803, -58.819236 -27.471533, -58.838173 -27.469633, -58.838256 -27.469590, -58.838260 -27.469482, -58.837459 -27.461821, -58.837574 -27.461650, -58.837738 -27.461573, -58.838065 -27.461534)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = '105'),
        'Vuelta: Puerto ↔ B° 250 VIV.', 'C 250 VIV.', 1,
        st_geomfromtext('LINESTRING(-58.838053 -27.461560, -58.838385 -27.461559, -58.838747 -27.461703, -58.841268 -27.461513, -58.841574 -27.466097, -58.839097 -27.466287, -58.839187 -27.468351, -58.839112 -27.468400, -58.822919 -27.469980, -58.822518 -27.467499, -58.821305 -27.466821, -58.820897 -27.466733, -58.818667 -27.466816, -58.818041 -27.467042, -58.813995 -27.467631, -58.808402 -27.467162, -58.807455 -27.467197, -58.801157 -27.469011, -58.800055 -27.469137, -58.798998 -27.468978, -58.790740 -27.466902, -58.789382 -27.466625, -58.768851 -27.461452, -58.768397 -27.461361, -58.767951 -27.461366, -58.765789 -27.459732, -58.765753 -27.459603, -58.765805 -27.459533, -58.766021 -27.459517, -58.767584 -27.459658, -58.768490 -27.458572, -58.768543 -27.458230)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = '106'),
        'Ida: B° 500 VIV. ↔ Centro', 'C', 0,
        st_geomfromtext('LINESTRING(-58.781055 -27.522587, -58.779063 -27.519375, -58.778577 -27.519647, -58.775913 -27.515395, -58.776428 -27.515158, -58.778989 -27.519231, -58.784393 -27.516580, -58.784540 -27.516376, -58.784466 -27.516091, -58.782554 -27.512990, -58.782706 -27.512856, -58.784517 -27.511968, -58.784814 -27.511624, -58.784913 -27.510772, -58.784058 -27.505695, -58.785551 -27.505475, -58.785613 -27.505381, -58.785563 -27.502719, -58.784745 -27.498321, -58.784813 -27.497305, -58.784594 -27.495956, -58.784696 -27.495836, -58.785721 -27.495681, -58.784868 -27.490062, -58.789497 -27.489277, -58.792353 -27.488509, -58.794009 -27.488195, -58.802868 -27.487065, -58.807251 -27.486437, -58.806381 -27.479648, -58.806469 -27.479383, -58.806560 -27.479337, -58.821849 -27.477458, -58.827686 -27.476719, -58.830169 -27.476320, -58.833936 -27.475875, -58.832299 -27.461129, -58.834978 -27.461073, -58.837054 -27.461734, -58.837508 -27.461700, -58.837666 -27.461539, -58.837805 -27.461509, -58.838162 -27.461503)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = '106'),
        'Vuelta: B° Pirayui ↔ B° 500 VIV.', 'D', 1,
        st_geomfromtext('LINESTRING(-58.784071 -27.505750, -58.784864 -27.510512, -58.784899 -27.510812, -58.784805 -27.511559, -58.784708 -27.511820, -58.784526 -27.511951, -58.782563 -27.512953, -58.782555 -27.513031, -58.784480 -27.516090, -58.784521 -27.516464, -58.784432 -27.516561, -58.778970 -27.519291, -58.775691 -27.514016)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = '106'),
        'Ida: B° 500 VIV. B° Pirayui', 'D', 0,
        st_geomfromtext('LINESTRING(-58.775691 -27.514016, -58.775750 -27.513976, -58.775814 -27.514061, -58.781238 -27.522946, -58.779009 -27.519399, -58.779014 -27.519240, -58.784419 -27.516530, -58.784526 -27.516326, -58.784467 -27.516102, -58.782563 -27.512953, -58.784596 -27.511896, -58.784735 -27.511758, -58.784800 -27.511549, -58.784907 -27.510859, -58.784869 -27.510498, -58.784071 -27.505750)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = '106'),
        'Ida: B° Pirayui ↔ Puerto', 'A', 0,
        st_geomfromtext('LINESTRING(-58.787592 -27.504507, -58.787549 -27.505299, -58.780058 -27.506295, -58.779416 -27.502860, -58.779547 -27.502094, -58.779507 -27.501991, -58.775520 -27.500676, -58.775134 -27.500455, -58.781098 -27.486330, -58.781269 -27.486032, -58.781606 -27.485722, -58.781852 -27.485060, -58.781900 -27.484741, -58.781785 -27.484305, -58.781861 -27.484069, -58.782022 -27.483943, -58.782455 -27.483899, -58.782721 -27.484087, -58.782786 -27.484414, -58.781902 -27.485745, -58.781848 -27.485989, -58.781897 -27.486335, -58.780891 -27.488702, -58.781219 -27.490524, -58.784953 -27.490010, -58.789513 -27.489253, -58.792336 -27.488491, -58.793782 -27.488214, -58.799243 -27.487513, -58.799337 -27.487384, -58.798339 -27.481728, -58.798372 -27.481468, -58.798474 -27.481355, -58.804237 -27.479689, -58.806446 -27.479322, -58.833911 -27.475916, -58.833996 -27.475753, -58.833751 -27.473322, -58.832366 -27.461199, -58.832412 -27.461112, -58.834813 -27.461048, -58.837049 -27.461775, -58.837655 -27.461713, -58.837760 -27.461571, -58.837967 -27.461536)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = '106'),
        'Vuelta: Puerto ↔ B° Pirayui', 'A', 1,
        st_geomfromtext('LINESTRING(-58.837973 -27.461534, -58.838495 -27.461573, -58.838707 -27.461661, -58.841164 -27.461459, -58.841261 -27.461566, -58.841594 -27.466096, -58.830335 -27.466976, -58.831364 -27.476223, -58.831350 -27.476494, -58.831237 -27.476550, -58.805253 -27.479794, -58.804237 -27.480023, -58.791201 -27.483762, -58.790149 -27.483908, -58.783863 -27.484389, -58.783038 -27.484620, -58.782391 -27.485032, -58.781904 -27.485734, -58.781846 -27.485979, -58.781901 -27.486334, -58.781106 -27.488253, -58.780764 -27.488507, -58.775642 -27.500592, -58.775657 -27.500687, -58.779551 -27.501986, -58.779587 -27.502148, -58.779464 -27.502797, -58.780094 -27.506227, -58.787527 -27.505210, -58.787539 -27.504496)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = '106'),
        'Vuelta: Centro ↔ B° 500 VIV.', 'C', 1,
        st_geomfromtext('LINESTRING(-58.838163 -27.461503, -58.838446 -27.461510, -58.838764 -27.461617, -58.841226 -27.461411, -58.841552 -27.466067, -58.830429 -27.466941, -58.830510 -27.468271, -58.831396 -27.476203, -58.831367 -27.476545, -58.807662 -27.479499, -58.807600 -27.479559, -58.807952 -27.481281, -58.808256 -27.486564, -58.808156 -27.486683, -58.807112 -27.486542, -58.794009 -27.488285, -58.792405 -27.488595, -58.789581 -27.489345, -58.784965 -27.490127, -58.785751 -27.495685, -58.784698 -27.495863, -58.784633 -27.495970, -58.784849 -27.497285, -58.784772 -27.498255, -58.785604 -27.502729, -58.785657 -27.505443, -58.785622 -27.505529, -58.784189 -27.505698, -58.784100 -27.505817, -58.784941 -27.510725, -58.784837 -27.511651, -58.784571 -27.511976, -58.782588 -27.512990, -58.784511 -27.516091, -58.784577 -27.516405, -58.784424 -27.516608, -58.778997 -27.519259, -58.776412 -27.515187, -58.775936 -27.515401, -58.778577 -27.519616, -58.779031 -27.519393, -58.781031 -27.522603)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = '106'),
        'Ida: B° Nuevo ↔ Puerto', 'B', 0,
        st_geomfromtext('LINESTRING(-58.791012 -27.503655, -58.792819 -27.503583, -58.792786 -27.501277, -58.792303 -27.500394, -58.790981 -27.500573, -58.790894 -27.500519, -58.790316 -27.497258, -58.790220 -27.495373, -58.790476 -27.495281, -58.793683 -27.494864, -58.794726 -27.494511, -58.794844 -27.494406, -58.796191 -27.493988, -58.795280 -27.488114, -58.795350 -27.488023, -58.796448 -27.487855, -58.796337 -27.486942, -58.796558 -27.486082, -58.796286 -27.483415, -58.796183 -27.483313, -58.795667 -27.483388, -58.795601 -27.483338, -58.795335 -27.482636, -58.795293 -27.482343, -58.795352 -27.482279, -58.804922 -27.479532, -58.829975 -27.476410, -58.830065 -27.476322, -58.833894 -27.476000, -58.833991 -27.475700, -58.832318 -27.461111, -58.834732 -27.461057, -58.837031 -27.461776, -58.837571 -27.461732, -58.837756 -27.461570, -58.838018 -27.461557)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = '106'),
        'Vuelta: Puerto ↔ B° Nuevo', 'B', 1,
        st_geomfromtext('LINESTRING(-58.838018 -27.461557, -58.838395 -27.461552, -58.838724 -27.461633, -58.841237 -27.461426, -58.841545 -27.466091, -58.830324 -27.466970, -58.831367 -27.476273, -58.831307 -27.476522, -58.805299 -27.479774, -58.804334 -27.479981, -58.799361 -27.481423, -58.799576 -27.482901, -58.799482 -27.483134, -58.799698 -27.484265, -58.797147 -27.484709, -58.797654 -27.487720, -58.797589 -27.487862, -58.795412 -27.488102, -58.795371 -27.488158, -58.796448 -27.494988, -58.796365 -27.495085, -58.793424 -27.496132, -58.790340 -27.496795, -58.790338 -27.497147, -58.790933 -27.500511, -58.790986 -27.500554, -58.792372 -27.500387, -58.792825 -27.501348, -58.792884 -27.503541, -58.791066 -27.503725, -58.791012 -27.503655)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = '108'),
        'Vuelta: Centro ↔ 40 VIV. F.J. Quintana-San Roque', 'C', 1,
        st_geomfromtext('LINESTRING(-58.830223 -27.465897, -58.838923 -27.465106, -58.839187 -27.468339, -58.839128 -27.468395, -58.838127 -27.468452, -58.837928 -27.466389, -58.837799 -27.466344, -58.823867 -27.467417, -58.822479 -27.467465, -58.821882 -27.467139, -58.821316 -27.467531, -58.818681 -27.469831, -58.818487 -27.470133, -58.818481 -27.470417, -58.819340 -27.474909, -58.819762 -27.477641, -58.819707 -27.477909, -58.819535 -27.478030, -58.814923 -27.478584, -58.814778 -27.478697, -58.816690 -27.489368, -58.817283 -27.492221, -58.817212 -27.492292, -58.817081 -27.492282, -58.816075 -27.493491, -58.809242 -27.502112, -58.807395 -27.504041, -58.799057 -27.504749, -58.799159 -27.505936, -58.797902 -27.506031, -58.797852 -27.506107, -58.798030 -27.508480, -58.797971 -27.508541, -58.794135 -27.508841, -58.792592 -27.509075, -58.793142 -27.509980, -58.793280 -27.510819, -58.793251 -27.511563, -58.793374 -27.512084)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = '108'),
        'Ida: 40 VIV. F.J. Quintana-San Roque ↔ Centro', 'C', 0,
        st_geomfromtext('LINESTRING(-58.793272 -27.512061, -58.793258 -27.510938, -58.793106 -27.509977, -58.792451 -27.509040, -58.792545 -27.508949, -58.794210 -27.508701, -58.797939 -27.508409, -58.798028 -27.508521, -58.798071 -27.509580, -58.798521 -27.510166, -58.799023 -27.510625, -58.801301 -27.510334, -58.801358 -27.510414, -58.799090 -27.510709, -58.798485 -27.510208, -58.798018 -27.509592, -58.797851 -27.508172, -58.797749 -27.504852, -58.807363 -27.504006, -58.809579 -27.501646, -58.816041 -27.493465, -58.817090 -27.492236, -58.817129 -27.492075, -58.816978 -27.491078, -58.816589 -27.489259, -58.814685 -27.478631, -58.814721 -27.478449, -58.814856 -27.478295, -58.819524 -27.477722, -58.819683 -27.477574, -58.819103 -27.474045, -58.818350 -27.470351, -58.818472 -27.469853, -58.821668 -27.467066, -58.821836 -27.466588, -58.822147 -27.466362, -58.822364 -27.466319, -58.823013 -27.466536, -58.830223 -27.465897)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = '109'),
        'Vuelta: Laguna Soto ↔ B° Rio Parana', 'A LAGUNA SOTO', 1,
        st_geomfromtext('LINESTRING(-58.690013 -27.456580, -58.693672 -27.456369, -58.697370 -27.456672, -58.701162 -27.456517, -58.701467 -27.456564, -58.704530 -27.457655, -58.707005 -27.457997, -58.707367 -27.457961, -58.711940 -27.456860, -58.714635 -27.456322, -58.716871 -27.456025, -58.717890 -27.455794, -58.720086 -27.454995, -58.720634 -27.454619, -58.721963 -27.453293, -58.722517 -27.453017, -58.723177 -27.452824, -58.728283 -27.451820, -58.733389 -27.451203, -58.741455 -27.449825, -58.750252 -27.448577, -58.750679 -27.448357, -58.750944 -27.448490, -58.767705 -27.461091, -58.799213 -27.468962, -58.800211 -27.469070, -58.801067 -27.468964, -58.806642 -27.467330, -58.807585 -27.467113, -58.808682 -27.467113, -58.814102 -27.467528, -58.815992 -27.467285, -58.818475 -27.466780, -58.821288 -27.466632, -58.822287 -27.466329, -58.822511 -27.466354, -58.822913 -27.466535, -58.830208 -27.465919, -58.831358 -27.476447, -58.831305 -27.476531, -58.830905 -27.476604, -58.830777 -27.476716, -58.829919 -27.477897, -58.820598 -27.489676, -58.819139 -27.492354, -58.816597 -27.496187, -58.813279 -27.500929, -58.810938 -27.506301, -58.810588 -27.507573, -58.810644 -27.507667, -58.810809 -27.507712, -58.816527 -27.508427, -58.830741 -27.510009)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = '109'),
        'Vuelta: B° Yecoha ↔ B° Rio Parana', 'B YECOHA', 1,
        st_geomfromtext('LINESTRING(-58.716397 -27.427953, -58.716803 -27.426764, -58.716986 -27.426669, -58.723648 -27.428618, -58.724803 -27.429046, -58.726179 -27.429779, -58.767705 -27.461091, -58.789637 -27.466599, -58.798906 -27.468890, -58.799830 -27.469057, -58.800558 -27.469048, -58.801323 -27.468902, -58.806642 -27.467330, -58.807585 -27.467113, -58.808682 -27.467113, -58.814102 -27.467528, -58.815992 -27.467285, -58.818475 -27.466780, -58.821288 -27.466646, -58.822287 -27.466329, -58.822511 -27.466354, -58.822913 -27.466535, -58.830208 -27.465919, -58.831358 -27.476447, -58.831305 -27.476531, -58.830905 -27.476604, -58.830777 -27.476716, -58.829919 -27.477897, -58.820598 -27.489676, -58.819139 -27.492354, -58.815251 -27.498147, -58.816428 -27.498744, -58.816166 -27.499130, -58.814649 -27.498866)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = '109'),
        'Ida: B° Rio Parana ↔ B° Yecoha', 'B YECOHA', 0,
        st_geomfromtext('LINESTRING(-58.814649 -27.498866, -58.816021 -27.496908, -58.819475 -27.491661, -58.820769 -27.489329, -58.830159 -27.477461, -58.830186 -27.476393, -58.833835 -27.475883, -58.833887 -27.475757, -58.833829 -27.475060, -58.833367 -27.471233, -58.823176 -27.472225, -58.822561 -27.467570, -58.822513 -27.467477, -58.821305 -27.466823, -58.820925 -27.466725, -58.818668 -27.466819, -58.818032 -27.467038, -58.814069 -27.467614, -58.808465 -27.467164, -58.807671 -27.467170, -58.807022 -27.467294, -58.801045 -27.469032, -58.800217 -27.469129, -58.799338 -27.469057, -58.768651 -27.461404, -58.767971 -27.461378, -58.726121 -27.429777, -58.725010 -27.429172, -58.723912 -27.428731, -58.717023 -27.426710, -58.716831 -27.426809, -58.716400 -27.427952)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = '109'),
        'Ida: B° Rio Parana ↔ Laguna Soto', 'A LAGUNA SOTO', 0,
        st_geomfromtext('LINESTRING(-58.830741 -27.510009, -58.816170 -27.508426, -58.810699 -27.507725, -58.810552 -27.507673, -58.810493 -27.507543, -58.810873 -27.506259, -58.813197 -27.500913, -58.816021 -27.496908, -58.818889 -27.492571, -58.819626 -27.491414, -58.820769 -27.489329, -58.830159 -27.477461, -58.830186 -27.476393, -58.833835 -27.475883, -58.833887 -27.475757, -58.833829 -27.475060, -58.833367 -27.471233, -58.823176 -27.472225, -58.822561 -27.467570, -58.822513 -27.467477, -58.821305 -27.466823, -58.820925 -27.466725, -58.818668 -27.466819, -58.818032 -27.467038, -58.814069 -27.467614, -58.808465 -27.467164, -58.807671 -27.467170, -58.807022 -27.467294, -58.801045 -27.469032, -58.800217 -27.469129, -58.799338 -27.469057, -58.768651 -27.461404, -58.767971 -27.461378, -58.750956 -27.448543, -58.750652 -27.448412, -58.750150 -27.448620, -58.741454 -27.449845, -58.733539 -27.451208, -58.728286 -27.451847, -58.723194 -27.452844, -58.722469 -27.453064, -58.721969 -27.453322, -58.721580 -27.453638, -58.720643 -27.454649, -58.720089 -27.455026, -58.717881 -27.455829, -58.717070 -27.456012, -58.714506 -27.456370, -58.710985 -27.457082, -58.707235 -27.458011, -58.704927 -27.457773, -58.704306 -27.457628, -58.701261 -27.456555, -58.697225 -27.456704, -58.693787 -27.456408, -58.690031 -27.456624)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = '110'),
        'Ida: 17 de Agosto ↔ Galvan', 'B', 0,
        st_geomfromtext('LINESTRING(-58.781296 -27.490500, -58.787326 -27.489627, -58.789549 -27.489234, -58.792416 -27.488490, -58.793952 -27.488204, -58.797693 -27.487710, -58.797901 -27.489207, -58.799785 -27.489223, -58.799618 -27.491386, -58.801803 -27.491547, -58.805255 -27.489854, -58.807990 -27.489421, -58.807447 -27.486455, -58.810411 -27.486993, -58.811144 -27.487184, -58.811671 -27.487175, -58.816098 -27.486799, -58.816323 -27.486581, -58.820798 -27.486191, -58.822321 -27.485971, -58.823137 -27.486484, -58.820876 -27.489410, -58.819899 -27.491182, -58.818323 -27.493746, -58.815281 -27.498222, -58.821947 -27.501229, -58.824509 -27.499515, -58.825519 -27.499365, -58.825245 -27.497493, -58.827388 -27.497212, -58.830603 -27.496669, -58.833964 -27.495985, -58.838074 -27.495450, -58.838064 -27.493271, -58.840828 -27.493209, -58.840900 -27.493398, -58.851433 -27.491432, -58.851725 -27.487945)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = '110'),
        'Ida: Santa Catalina ↔ Puerto', 'C SANTA CATALINA', 0,
        st_geomfromtext('LINESTRING(-58.838148 -27.461665, -58.841193 -27.461455, -58.841587 -27.466068, -58.839077 -27.466252, -58.839600 -27.474106, -58.844745 -27.473664, -58.844862 -27.474839, -58.844310 -27.474910, -58.845644 -27.484566, -58.835319 -27.485745, -58.834408 -27.485799, -58.833998 -27.485751, -58.831122 -27.484849, -58.831259 -27.486170, -58.830888 -27.486772, -58.831009 -27.490051, -58.831269 -27.490675, -58.829697 -27.491770, -58.824440 -27.492576, -58.826160 -27.502260, -58.826208 -27.504826, -58.826586 -27.509584, -58.816054 -27.508429, -58.810601 -27.507736, -58.810244 -27.509629, -58.809681 -27.511130, -58.809160 -27.512027, -58.802101 -27.518530, -58.801587 -27.519075, -58.799778 -27.521988, -58.799932 -27.522456, -58.800254 -27.522717, -58.800689 -27.522726, -58.800776 -27.522976, -58.802372 -27.522765, -58.803131 -27.526430, -58.805556 -27.526104, -58.805097 -27.523771, -58.806694 -27.523517, -58.806419 -27.521982, -58.817630 -27.520371, -58.818597 -27.525602, -58.818347 -27.525647)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = '110'),
        'Ida: Cementerio ↔ B° Molina Punta', 'A', 0,
        st_geomfromtext('LINESTRING(-58.852005 -27.488271, -58.852047 -27.488518, -58.851790 -27.488557, -58.851697 -27.488410, -58.851743 -27.487960, -58.845902 -27.485524, -58.845665 -27.485303, -58.844383 -27.485468, -58.844289 -27.484713, -58.835208 -27.485742, -58.834148 -27.485805, -58.831240 -27.485001, -58.831283 -27.486131, -58.830885 -27.486723, -58.830977 -27.489982, -58.831272 -27.490606, -58.831220 -27.490721, -58.829666 -27.491779, -58.826207 -27.492283, -58.826097 -27.492156, -58.824987 -27.484169, -58.825019 -27.484028, -58.825736 -27.483134, -58.824862 -27.482772, -58.822885 -27.482152, -58.815524 -27.483028, -58.814774 -27.478615, -58.812683 -27.471279, -58.812575 -27.471239, -58.803473 -27.473413, -58.798639 -27.474906, -58.793155 -27.475990, -58.788644 -27.476683, -58.788518 -27.476590, -58.786914 -27.466017, -58.774799 -27.462965, -58.774751 -27.462842, -58.775514 -27.460345, -58.778523 -27.452320, -58.778519 -27.451654, -58.780403 -27.446705, -58.778416 -27.446052, -58.778941 -27.445546, -58.779736 -27.443314, -58.783739 -27.444437)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = '110'),
        'Vuelta: Puerto ↔ Santa Catalina', 'C SANTA CATALINA', 1,
        st_geomfromtext('LINESTRING(-58.818347 -27.525647, -58.817391 -27.520431, -58.807256 -27.522014, -58.808229 -27.527144, -58.803336 -27.527907, -58.802626 -27.524298, -58.801053 -27.524535, -58.800776 -27.522976, -58.800467 -27.523025, -58.799756 -27.522463, -58.799489 -27.522436, -58.799411 -27.522213, -58.801628 -27.518920, -58.808946 -27.512143, -58.809650 -27.511040, -58.809883 -27.510420, -58.810223 -27.509356, -58.810530 -27.507691, -58.817830 -27.508610, -58.826505 -27.509535, -58.826125 -27.504454, -58.826091 -27.502233, -58.825248 -27.497507, -58.827072 -27.497251, -58.826150 -27.492221, -58.829669 -27.491653, -58.831148 -27.490618, -58.830867 -27.490032, -58.830754 -27.486822, -58.831172 -27.486107, -58.831135 -27.485462, -58.834236 -27.486380, -58.835295 -27.486302, -58.835223 -27.485640, -58.844316 -27.484631, -58.843027 -27.475078, -58.841189 -27.475285, -58.840984 -27.472878, -58.838665 -27.473132, -58.837510 -27.461810, -58.837741 -27.461700, -58.838148 -27.461665)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = '110'),
        'Vuelta: Galvan ↔ 17 de Agosto', 'B', 1,
        st_geomfromtext('LINESTRING(-58.851755 -27.487949, -58.851480 -27.491533, -58.840924 -27.493424, -58.840855 -27.493212, -58.837992 -27.493322, -58.838036 -27.492924, -58.824819 -27.494721, -58.825646 -27.499385, -58.824515 -27.499534, -58.822816 -27.500726, -58.821949 -27.501240, -58.816432 -27.498765, -58.816164 -27.499134, -58.814603 -27.498892, -58.817051 -27.495439, -58.818739 -27.492876, -58.820740 -27.489418, -58.824219 -27.485061, -58.823204 -27.484483, -58.815900 -27.485091, -58.816188 -27.486896, -58.811182 -27.487300, -58.807549 -27.486600, -58.808305 -27.490565, -58.805506 -27.491011, -58.803820 -27.491822, -58.802611 -27.492923, -58.799468 -27.492668, -58.799874 -27.489097, -58.799379 -27.487612, -58.793670 -27.488389, -58.792471 -27.488592, -58.789620 -27.489364, -58.781271 -27.490630)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'corrientes-capital' and l.code = '110'),
        'Vuelta: B° Molina Punta ↔ Cementerio', 'A', 1,
        st_geomfromtext('LINESTRING(-58.783739 -27.444437, -58.781796 -27.449243, -58.778615 -27.457540, -58.778822 -27.457756, -58.778806 -27.458108, -58.778605 -27.458438, -58.778283 -27.458545, -58.777399 -27.460707, -58.775547 -27.460548, -58.774813 -27.462884, -58.786991 -27.465973, -58.788574 -27.476533, -58.788715 -27.476615, -58.792416 -27.476043, -58.798605 -27.474838, -58.803345 -27.473411, -58.812644 -27.471208, -58.812782 -27.471262, -58.814832 -27.478613, -58.815589 -27.482985, -58.823062 -27.482070, -58.825462 -27.481893, -58.826365 -27.482303, -58.826416 -27.482365, -58.825041 -27.484092, -58.826217 -27.492161, -58.829672 -27.491644, -58.831137 -27.490622, -58.830863 -27.490052, -58.830753 -27.486743, -58.831178 -27.486107, -58.831152 -27.485463, -58.834264 -27.486393, -58.835304 -27.486295, -58.835212 -27.485670, -58.844306 -27.484605, -58.843000 -27.475044, -58.841215 -27.475247, -58.841165 -27.475204, -58.840769 -27.470564, -58.838412 -27.470774, -58.837488 -27.461837, -58.837735 -27.461685, -58.841251 -27.461439, -58.842155 -27.473900, -58.844749 -27.473673, -58.844839 -27.474818, -58.844309 -27.474877, -58.845620 -27.484462, -58.846919 -27.484296, -58.847615 -27.484003, -58.849419 -27.482912, -58.849628 -27.483031, -58.850163 -27.484551, -58.850799 -27.487488, -58.851920 -27.488019, -58.851995 -27.488254)', 4326), true)
on conflict (line_id, coalesce(branch, ''), direction) do update set
    name = excluded.name,
    geom = excluded.geom,
    is_active = true;

commit;

-- ====================================================================
-- DIAGNÓSTICO DE LA IMPORTACIÓN (solo informativo)
-- ====================================================================
--
-- Filas descartadas: ninguna.
--
-- Advertencias de datos: ninguna.
