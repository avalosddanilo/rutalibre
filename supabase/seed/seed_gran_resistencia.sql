-- ====================================================================
-- RUTA LIBRE — Carga de datos reales del Gran Resistencia
--
-- GENERADO AUTOMÁTICAMENTE por tools/osm_import.dart.
-- No editar a mano: se regenera con
--   dart run tools/osm_import.dart
--
-- Fuente: OpenStreetMap vía Overpass API.
-- Los datos de OSM están bajo ODbL: la app DEBE mantener
-- visible el crédito "© OpenStreetMap contributors".
--
-- Fecha de extracción: 2026-08-06T18:25:30.355673Z
-- Líneas: 22 | Recorridos: 73 | Paradas: 1474
--
-- REQUIERE la migración 0003 aplicada.
--
-- OJO: borra los recorridos SIN origen OSM de estas redes
-- (los del seed de desarrollo) para que no queden trazados
-- mock mezclados con los reales. Eso arrastra por cascada los
-- horarios que colgaran de ellos.
-- ====================================================================

begin;

-- ------------------------------------------------------------
-- 0. Fuera lo que no vino de OSM en estas redes
-- ------------------------------------------------------------
delete from public.route_variants rv
 using public.lines l, public.networks n
 where rv.line_id = l.id
   and l.network_id = n.id
   and rv.osm_relation_id is null
   and n.code in ('gran-resistencia', 'interurbano-chaco', 'interurbano-chaco-corrientes');

-- ------------------------------------------------------------
-- 1. Líneas (22)
-- ------------------------------------------------------------
insert into public.lines (network_id, code, name, destinations, color_hex, sort_order, is_active)
values ((select id from public.networks where code = 'gran-resistencia'),
        '2', 'Carpincho Macho ↔ Villa Prosperidad', array['Carpincho Macho', 'Villa Prosperidad']::text[],
        '#388E3C', 200, true)
on conflict (network_id, code) do update set
    name = excluded.name,
    destinations = excluded.destinations,
    color_hex = excluded.color_hex,
    sort_order = excluded.sort_order,
    is_active = true;
insert into public.lines (network_id, code, name, destinations, color_hex, sort_order, is_active)
values ((select id from public.networks where code = 'gran-resistencia'),
        '3', 'Vial ↔ Los Troncos / Monte Alto y 1 más', array['Vial', 'Los Troncos', 'Monte Alto', 'Shopping Sarmiento']::text[],
        '#F57C00', 300, true)
on conflict (network_id, code) do update set
    name = excluded.name,
    destinations = excluded.destinations,
    color_hex = excluded.color_hex,
    sort_order = excluded.sort_order,
    is_active = true;
insert into public.lines (network_id, code, name, destinations, color_hex, sort_order, is_active)
values ((select id from public.networks where code = 'gran-resistencia'),
        '5', 'Barrio UOM ↔ Villa Luisa / Villa Chica y 1 más', array['Barrio UOM', 'Villa Luisa', 'Villa Chica', 'Bariro UOM']::text[],
        '#00838F', 500, true)
on conflict (network_id, code) do update set
    name = excluded.name,
    destinations = excluded.destinations,
    color_hex = excluded.color_hex,
    sort_order = excluded.sort_order,
    is_active = true;
insert into public.lines (network_id, code, name, destinations, color_hex, sort_order, is_active)
values ((select id from public.networks where code = 'gran-resistencia'),
        '8', 'Asentamiento 29 de Agosto ↔ Barrio UOM / Barberán y 2 más', array['Asentamiento 29 de Agosto', 'Barrio UOM', 'Barberán', 'Barrio Víctor Balussi', 'Barrio Víctor Valussi']::text[],
        '#455A64', 800, true)
on conflict (network_id, code) do update set
    name = excluded.name,
    destinations = excluded.destinations,
    color_hex = excluded.color_hex,
    sort_order = excluded.sort_order,
    is_active = true;
insert into public.lines (network_id, code, name, destinations, color_hex, sort_order, is_active)
values ((select id from public.networks where code = 'gran-resistencia'),
        '9', 'Hipermercado Libertad ↔ Barrio 17 de Octubre y 3 más', array['Hipermercado Libertad', 'Barrio 17 de Octubre', 'Hiper Libertad', 'Villa Don Alberto', 'Villa Don Andrés']::text[],
        '#AFB42B', 900, true)
on conflict (network_id, code) do update set
    name = excluded.name,
    destinations = excluded.destinations,
    color_hex = excluded.color_hex,
    sort_order = excluded.sort_order,
    is_active = true;
insert into public.lines (network_id, code, name, destinations, color_hex, sort_order, is_active)
values ((select id from public.networks where code = 'gran-resistencia'),
        '12', 'Barrio Don Bosco ↔ Don Santiago / Parque Autódromo y 2 más', array['Barrio Don Bosco', 'Don Santiago', 'Parque Autódromo', 'Rotonda Villa Monona', 'Villa Monona']::text[],
        '#1976D2', 1200, true)
on conflict (network_id, code) do update set
    name = excluded.name,
    destinations = excluded.destinations,
    color_hex = excluded.color_hex,
    sort_order = excluded.sort_order,
    is_active = true;
insert into public.lines (network_id, code, name, destinations, color_hex, sort_order, is_active)
values ((select id from public.networks where code = 'gran-resistencia'),
        '101', 'Barranqueras ↔ Barrio Santa Inés', array['Barranqueras', 'Barrio Santa Inés']::text[],
        '#388E3C', 10100, true)
on conflict (network_id, code) do update set
    name = excluded.name,
    destinations = excluded.destinations,
    color_hex = excluded.color_hex,
    sort_order = excluded.sort_order,
    is_active = true;
insert into public.lines (network_id, code, name, destinations, color_hex, sort_order, is_active)
values ((select id from public.networks where code = 'gran-resistencia'),
        '104', 'Barrio 200 Viviendas ↔ Barrio Jorge Newbery', array['Barrio 200 Viviendas', 'Barrio Jorge Newbery']::text[],
        '#00838F', 10400, true)
on conflict (network_id, code) do update set
    name = excluded.name,
    destinations = excluded.destinations,
    color_hex = excluded.color_hex,
    sort_order = excluded.sort_order,
    is_active = true;
insert into public.lines (network_id, code, name, destinations, color_hex, sort_order, is_active)
values ((select id from public.networks where code = 'gran-resistencia'),
        '106', 'Barrio Perón ↔ 200 Viviendas / Puerto Vilelas y 1 más', array['Barrio Perón', '200 Viviendas', 'Puerto Vilelas', 'Barrio San Antonio']::text[],
        '#5D4037', 10600, true)
on conflict (network_id, code) do update set
    name = excluded.name,
    destinations = excluded.destinations,
    color_hex = excluded.color_hex,
    sort_order = excluded.sort_order,
    is_active = true;
insert into public.lines (network_id, code, name, destinations, color_hex, sort_order, is_active)
values ((select id from public.networks where code = 'gran-resistencia'),
        '107', 'Resistencia Centro ↔ Cementerio Fontana y 1 más', array['Resistencia Centro', 'Cementerio Fontana', 'San Pedro (Fontana)']::text[],
        '#455A64', 10700, true)
on conflict (network_id, code) do update set
    name = excluded.name,
    destinations = excluded.destinations,
    color_hex = excluded.color_hex,
    sort_order = excluded.sort_order,
    is_active = true;
insert into public.lines (network_id, code, name, destinations, color_hex, sort_order, is_active)
values ((select id from public.networks where code = 'gran-resistencia'),
        '110', 'La Toma ↔ Los Cisnes', array['La Toma', 'Los Cisnes']::text[],
        '#D32F2F', 11000, true)
on conflict (network_id, code) do update set
    name = excluded.name,
    destinations = excluded.destinations,
    color_hex = excluded.color_hex,
    sort_order = excluded.sort_order,
    is_active = true;
insert into public.lines (network_id, code, name, destinations, color_hex, sort_order, is_active)
values ((select id from public.networks where code = 'gran-resistencia'),
        '111', 'Cementerio Fontana ↔ Mujeres Argentinas', array['Cementerio Fontana', 'Mujeres Argentinas']::text[],
        '#1976D2', 11100, true)
on conflict (network_id, code) do update set
    name = excluded.name,
    destinations = excluded.destinations,
    color_hex = excluded.color_hex,
    sort_order = excluded.sort_order,
    is_active = true;
insert into public.lines (network_id, code, name, destinations, color_hex, sort_order, is_active)
values ((select id from public.networks where code = 'gran-resistencia'),
        '203', 'Barranqueras ↔ Puerto Vilelas', array['Barranqueras', 'Puerto Vilelas']::text[],
        '#00838F', 20300, true)
on conflict (network_id, code) do update set
    name = excluded.name,
    destinations = excluded.destinations,
    color_hex = excluded.color_hex,
    sort_order = excluded.sort_order,
    is_active = true;
insert into public.lines (network_id, code, name, destinations, color_hex, sort_order, is_active)
values ((select id from public.networks where code = 'gran-resistencia'),
        '204', 'Barranqueras ↔ Fontana', array['Barranqueras', 'Fontana']::text[],
        '#C2185B', 20400, true)
on conflict (network_id, code) do update set
    name = excluded.name,
    destinations = excluded.destinations,
    color_hex = excluded.color_hex,
    sort_order = excluded.sort_order,
    is_active = true;
insert into public.lines (network_id, code, name, destinations, color_hex, sort_order, is_active)
values ((select id from public.networks where code = 'gran-resistencia'),
        '205', 'Fontana ↔ Resistencia', array['Fontana', 'Resistencia']::text[],
        '#5D4037', 20500, true)
on conflict (network_id, code) do update set
    name = excluded.name,
    destinations = excluded.destinations,
    color_hex = excluded.color_hex,
    sort_order = excluded.sort_order,
    is_active = true;
insert into public.lines (network_id, code, name, destinations, color_hex, sort_order, is_active)
values ((select id from public.networks where code = 'gran-resistencia'),
        '206', 'Barranqueras ↔ Resistencia', array['Barranqueras', 'Resistencia']::text[],
        '#455A64', 20600, true)
on conflict (network_id, code) do update set
    name = excluded.name,
    destinations = excluded.destinations,
    color_hex = excluded.color_hex,
    sort_order = excluded.sort_order,
    is_active = true;
insert into public.lines (network_id, code, name, destinations, color_hex, sort_order, is_active)
values ((select id from public.networks where code = 'gran-resistencia'),
        '207', 'Barranqueras ↔ Fontana', array['Barranqueras', 'Fontana']::text[],
        '#AFB42B', 20700, true)
on conflict (network_id, code) do update set
    name = excluded.name,
    destinations = excluded.destinations,
    color_hex = excluded.color_hex,
    sort_order = excluded.sort_order,
    is_active = true;
insert into public.lines (network_id, code, name, destinations, color_hex, sort_order, is_active)
values ((select id from public.networks where code = 'interurbano-chaco'),
        'RES-CB', 'Colonia Benítez', array['Colonia Benítez']::text[],
        '#512DA8', 900082, true)
on conflict (network_id, code) do update set
    name = excluded.name,
    destinations = excluded.destinations,
    color_hex = excluded.color_hex,
    sort_order = excluded.sort_order,
    is_active = true;
insert into public.lines (network_id, code, name, destinations, color_hex, sort_order, is_active)
values ((select id from public.networks where code = 'interurbano-chaco'),
        'Tirol', 'Resistencia ↔ Puerto Tirol / Puerto Tirol Ramal B', array['Resistencia', 'Puerto Tirol', 'Puerto Tirol Ramal B']::text[],
        '#0288D1', 900084, true)
on conflict (network_id, code) do update set
    name = excluded.name,
    destinations = excluded.destinations,
    color_hex = excluded.color_hex,
    sort_order = excluded.sort_order,
    is_active = true;
insert into public.lines (network_id, code, name, destinations, color_hex, sort_order, is_active)
values ((select id from public.networks where code = 'interurbano-chaco-corrientes'),
        '904A', 'Chaco ↔ Corrientes por el Campus de la UNNE', array['904', 'Campus UNNE', 'Terminal de Ómnibus Resistencia', 'Campus Corrientes']::text[],
        '#7B1FA2', 90401, true)
on conflict (network_id, code) do update set
    name = excluded.name,
    destinations = excluded.destinations,
    color_hex = excluded.color_hex,
    sort_order = excluded.sort_order,
    is_active = true;
insert into public.lines (network_id, code, name, destinations, color_hex, sort_order, is_active)
values ((select id from public.networks where code = 'interurbano-chaco-corrientes'),
        '904B', 'Chaco ↔ Corrientes por Avenida Sarmiento', array['Sarmiento', 'Avenida Sarmiento', 'directo', 'Chaco - Corrientes directo']::text[],
        '#00838F', 90402, true)
on conflict (network_id, code) do update set
    name = excluded.name,
    destinations = excluded.destinations,
    color_hex = excluded.color_hex,
    sort_order = excluded.sort_order,
    is_active = true;
insert into public.lines (network_id, code, name, destinations, color_hex, sort_order, is_active)
values ((select id from public.networks where code = 'interurbano-chaco-corrientes'),
        '904C', 'Chaco ↔ Corrientes por Barranqueras', array['Barranqueras', 'Chaco - Corrientes por Barranqueras']::text[],
        '#C2185B', 90403, true)
on conflict (network_id, code) do update set
    name = excluded.name,
    destinations = excluded.destinations,
    color_hex = excluded.color_hex,
    sort_order = excluded.sort_order,
    is_active = true;

-- ------------------------------------------------------------
-- 2. Paradas (1474)
-- ------------------------------------------------------------
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (355039799, 'Avenida General San Martín y Avenida Laprida', 'Parada C03253',
        st_setsrid(st_point(-58.936054, -27.482671), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (1191929295, 'Alberdi', null,
        st_setsrid(st_point(-58.991352, -27.454688), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (1203082810, 'Avenida Belgrano y Miguel Cané', 'Parada C00652',
        st_setsrid(st_point(-59.006758, -27.461562), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (1203470815, 'La Rioja y Sicas', 'Parada C03121',
        st_setsrid(st_point(-58.997233, -27.432190), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (1209331517, 'Avenida Brigadier General Juan Manuel de Rosas y La Rioja', 'Parada C07700',
        st_setsrid(st_point(-59.002722, -27.427350), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (1210007511, 'Avenida Mac Lean y Luis Vernet', 'Parada C00019',
        st_setsrid(st_point(-59.019850, -27.455433), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (1212726589, 'Soldado Aguilera y Avenida Chaco', 'Parada C01590',
        st_setsrid(st_point(-58.989886, -27.480098), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (1217510893, 'Avenida Islas Malvinas y Avenida de la Democracia', 'Parada C02344',
        st_setsrid(st_point(-59.028642, -27.451970), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (1220129198, 'Gobernador Deolindo Felipe Bittel y La Cangayé', 'Parada C00577',
        st_setsrid(st_point(-58.966862, -27.415425), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (1224283140, 'Diagonal Eva Perón y Avenida Laprida', 'Parada C03503',
        st_setsrid(st_point(-58.936943, -27.482872), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (1225778827, 'Avenida Maipú y Defensas de Barranqueras', 'Parada C07250',
        st_setsrid(st_point(-58.910267, -27.467701), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (1226685444, 'Avenida Libertador General San Martín y Avenida Juan José Castelli', 'Parada C01821',
        st_setsrid(st_point(-58.942363, -27.502842), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (1541569015, 'Plaza 9 de Julio', 'Parada C01768',
        st_setsrid(st_point(-58.994574, -27.450699), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (1589504283, 'Necochea 50', 'Parada C00119',
        st_setsrid(st_point(-58.989567, -27.449164), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (1589504365, 'Santiago del Estero y Vedia', 'Parada C01278',
        st_setsrid(st_point(-58.991530, -27.452773), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (1589504388, 'Avenida Alberdi y Santiago del Estero', 'Parada C02328',
        st_setsrid(st_point(-58.989989, -27.453937), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (1589583902, 'Avenida Lavalle y Avenida de los Inmigrantes', null,
        st_setsrid(st_point(-58.983989, -27.440548), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (1605949225, 'Italia y Paraguay', 'Parada C07789',
        st_setsrid(st_point(-58.977953, -27.451382), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (1605949296, 'Italia e Yrigoyen', 'Parada C06020',
        st_setsrid(st_point(-58.981305, -27.454432), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (1728971799, 'Chaco - Corrientes (Sarmiento, Barranqueras y Campus).', 'Parada C03022',
        st_setsrid(st_point(-58.985006, -27.462627), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (1741501481, 'Obligado y Sáenz Peña', 'Parada C02013',
        st_setsrid(st_point(-58.986761, -27.455734), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (1741501485, 'Obligado y San Martín', 'Parada C03055',
        st_setsrid(st_point(-58.985079, -27.457123), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (1804502952, 'Juan B. Justo y Arturo Frondizi', null,
        st_setsrid(st_point(-58.986852, -27.452483), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (1804502955, 'Alberdi 351', 'Parada C02502',
        st_setsrid(st_point(-58.989411, -27.453958), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (1804502956, 'Avenida Alberdi y Ameghino', 'Parada C02266',
        st_setsrid(st_point(-58.990029, -27.454587), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (1804601348, 'Avenida San Martín y Juan B. Justo', null,
        st_setsrid(st_point(-58.983356, -27.455777), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (1941869005, 'Bermejo', null,
        st_setsrid(st_point(-58.999654, -27.323729), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (1941871514, 'Bermejo', null,
        st_setsrid(st_point(-59.002075, -27.336795), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (1941872595, 'Bermejo', null,
        st_setsrid(st_point(-59.001861, -27.336891), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (1941873678, 'Bermejo', null,
        st_setsrid(st_point(-59.000820, -27.327474), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (2037047388, 'Línea 8 y 104', 'Parada C02337',
        st_setsrid(st_point(-59.015488, -27.444989), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (2037049616, 'Línea 8 y 104', 'Parada C02260',
        st_setsrid(st_point(-59.011989, -27.448019), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (2037050563, 'Línea 8', 'Parada C07049',
        st_setsrid(st_point(-59.004371, -27.441640), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (2037052871, 'Línea 8', null,
        st_setsrid(st_point(-59.001882, -27.442249), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (2045268306, 'Bermejo', null,
        st_setsrid(st_point(-58.992724, -27.445818), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (2215342454, '9 de Julio 850', 'Parada C00041',
        st_setsrid(st_point(-58.979015, -27.457938), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (2226214174, 'Avenida 9 de Julio y Avenida Chaco', 'Parada C01773',
        st_setsrid(st_point(-58.972437, -27.463819), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (2274623288, 'Avenida Sarmiento y Avenida Laprida', 'Parada C07742',
        st_setsrid(st_point(-58.979027, -27.444548), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (2286203409, 'Monteagudo y Avenida Padre Rissione', null,
        st_setsrid(st_point(-58.967034, -27.443263), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (2315898138, 'Avenida Sarmiento y Ecuador', 'Parada C07003',
        st_setsrid(st_point(-58.975725, -27.441259), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (2315898140, 'Sarmiento y América', 'Parada C01310',
        st_setsrid(st_point(-58.977187, -27.442595), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (2315898739, '108A', null,
        st_setsrid(st_point(-58.840756, -27.476655), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (2340703626, '110 A y  105', null,
        st_setsrid(st_point(-58.811306, -27.471610), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (2341271051, 'Acceso a Puerto Tirol y Carlos Gardel', null,
        st_setsrid(st_point(-59.082434, -27.374206), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (2341271052, 'Autovía Nicolás Avellaneda y Gobernador Anselmo Zoilo Ducca', null,
        st_setsrid(st_point(-59.055043, -27.369080), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (2341272241, 'Acceso a Puerto Tirol', null,
        st_setsrid(st_point(-59.068337, -27.365746), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (2350127607, 'Hernandarias y Felipe Molina', 'Parada C01764',
        st_setsrid(st_point(-59.002407, -27.452837), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (2374450976, 'Sabín y Fortín Chilcas', 'Parada C00585',
        st_setsrid(st_point(-58.980512, -27.431996), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (2377499679, 'Avenida Alberdi y Avenida Islas Malvinas', 'Parada C00604',
        st_setsrid(st_point(-59.007837, -27.470179), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (2377596077, 'Avenida Alberdi y Ricardo Rojas', 'Parada C00524',
        st_setsrid(st_point(-59.004482, -27.467316), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (2380076720, '25 de Mayo y Brignole', 'Parada C00111',
        st_setsrid(st_point(-59.005807, -27.434775), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (2380406967, 'Avenida Juan José Castelli e Ingeniero Augusto Schur', 'Parada C06012',
        st_setsrid(st_point(-58.972781, -27.475935), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (2383938357, 'Avenida Islas Malvinas y Avenida Belgrano', 'Parada C01756',
        st_setsrid(st_point(-59.012034, -27.466679), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (2385653920, 'Avenida Carmen C. Viuda de Ross', 'Parada C07010',
        st_setsrid(st_point(-58.956091, -27.464345), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (2393442531, 'Avenida Mac Lean y La Pampa', 'Parada C00024',
        st_setsrid(st_point(-59.011869, -27.448274), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (2396794433, 'Avenida Carlos López Piacentini y Avenida Chaco', 'Parada C03062',
        st_setsrid(st_point(-58.984171, -27.474256), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (2398666781, 'Avenida Chaco y Seitor', 'Parada C03016',
        st_setsrid(st_point(-58.984927, -27.475343), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (2398804688, '104 y 8', 'Parada C02256',
        st_setsrid(st_point(-59.019043, -27.448155), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (2406297012, 'Rotonda Ruta 11 y 16 (ida)', null,
        st_setsrid(st_point(-59.002697, -27.411624), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (2411275649, 'Acceso a Puerto Tirol y Autovía Nicolás Avellaneda', null,
        st_setsrid(st_point(-59.063230, -27.360886), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (2419390740, 'Avenida Chacabuco y Pje. Sarmiento', null,
        st_setsrid(st_point(-58.814716, -27.478054), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (2497972844, 'Avenida de la Democracia y Catamarca', 'Parada C07254',
        st_setsrid(st_point(-59.007225, -27.420859), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (2503475485, 'Avenida Édison y Martín Goitía', 'Parada C01506',
        st_setsrid(st_point(-58.982539, -27.480120), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (2560847634, 'Avenida Arturo Jauretche y Maipú', 'Parada C07747',
        st_setsrid(st_point(-59.015651, -27.454577), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (2673402389, 'Deán Funes y Carlos Tejedor', 'Parada C02257',
        st_setsrid(st_point(-59.017229, -27.446584), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (2680328508, 'Fray Bertaca y Domingo Cubells', 'Parada C02253',
        st_setsrid(st_point(-59.023352, -27.451987), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (2680328524, 'Fray Bertaca y Cristófani', 'Parada C02252',
        st_setsrid(st_point(-59.024830, -27.453329), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (2703455233, 'Pago de Areco y Soldado Aguilera', 'Parada C01593',
        st_setsrid(st_point(-58.988825, -27.485395), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (2703511768, 'Soldado Aguilera y Adelina Del Carril', null,
        st_setsrid(st_point(-58.989313, -27.484323), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (2711345361, 'Avenida Lonardi y Eva Perón', 'Parada C07018',
        st_setsrid(st_point(-58.950898, -27.464231), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (2711549005, 'Victoria Ocampo y Eva Perón', 'Parada C07762',
        st_setsrid(st_point(-58.949036, -27.464376), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (2715020774, 'Ángel D''Ambra y Aristóbulo de Valle', 'Parada C06761',
        st_setsrid(st_point(-58.954924, -27.477227), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (2724209578, 'Diagonal Eva Perón y Rotonda de Villa Monona', 'Parada C03256',
        st_setsrid(st_point(-58.950241, -27.482905), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (2732813674, 'Rosa Guarú y Avenida Agrimensor Seelstrang', 'Parada C07013',
        st_setsrid(st_point(-58.947736, -27.467242), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (2732813693, 'Avenida Agrimensor Seelstrang y Viento Norte', null,
        st_setsrid(st_point(-58.948709, -27.468366), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (2743540008, 'José Mármol y Marcelino Castelán', null,
        st_setsrid(st_point(-58.970284, -27.482661), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (2815692064, 'Colectora Tauguinas (Shell)', 'Parada C01334',
        st_setsrid(st_point(-58.946077, -27.425956), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (2886285981, 'Avenida 25 de Mayo y Chubut', null,
        st_setsrid(st_point(-59.020649, -27.421089), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (2900059988, 'Avenida Carlos María de Alvear y Bahía Blanca', 'Parada C01537',
        st_setsrid(st_point(-59.028988, -27.426382), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (2984913221, 'Plazoleta Ecológica', null,
        st_setsrid(st_point(-58.996778, -27.407432), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (3042176957, 'Juan Facundo Quiroga y Gobernador Rolando Tauguinas', 'Parada C01335',
        st_setsrid(st_point(-58.941133, -27.427838), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (3052483925, 'Avenida Paraguay y Emilio R. Román', null,
        st_setsrid(st_point(-58.960016, -27.467190), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (3052515445, 'Emilio R. Román y Almirante Brown', null,
        st_setsrid(st_point(-58.962270, -27.469276), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (3054594660, 'Avenida Carlos María de Alvear y Fray Capelli', 'Parada C00027',
        st_setsrid(st_point(-59.006461, -27.446285), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (3054594661, 'Alvear y Klein', 'Parada C02262',
        st_setsrid(st_point(-59.005533, -27.447118), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (3054594662, 'Alvear y Padre Cerqueira (ida)', 'Parada C01575',
        st_setsrid(st_point(-59.003682, -27.448746), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (3054594663, 'Alvear y San Roque (ida)', 'Parada C00030',
        st_setsrid(st_point(-59.001808, -27.450402), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (3054594664, 'Alvear y Cangallo (ida)', 'Parada C00031',
        st_setsrid(st_point(-58.999922, -27.452019), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (3054594665, 'Avenida Carlos María de Alvear y Avenida Belgrano', 'Parada C00032',
        st_setsrid(st_point(-58.998182, -27.453533), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (3077546539, 'Avenida Carlos María de Alvear y Fray Capelli', 'Parada C02332',
        st_setsrid(st_point(-59.006092, -27.446299), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (3077546540, 'Avenida Carlos María de Alvear y Misionero Klein', 'Parada C01525',
        st_setsrid(st_point(-59.005134, -27.447146), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (3134456377, 'José Mármol y Tatané', 'Parada C02296',
        st_setsrid(st_point(-58.954837, -27.496576), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (3238657395, 'Avenida General San Martín y Avenida Maipú', 'Parada C00186',
        st_setsrid(st_point(-58.915157, -27.463921), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (3238657397, 'Avenida General San Martín y Avenida Maipú', 'Parada C00241',
        st_setsrid(st_point(-58.915017, -27.463958), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (3266477240, 'Bermejo', null,
        st_setsrid(st_point(-58.946789, -27.332505), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (3312911975, 'Avenida Libertador General San Martín y Avenida Juan José Castelli', 'Parada C01795',
        st_setsrid(st_point(-58.942567, -27.503545), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (3317564876, 'Juan Manuel Bordeau y Avia Terai', 'Parada C07777',
        st_setsrid(st_point(-58.998536, -27.396196), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (3317564882, 'Juan Manuel Bordeau y Campo Largo', null,
        st_setsrid(st_point(-58.999546, -27.397106), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (3359003184, 'Avenida Diagonal Las Piedras y Fray Mocho', 'Parada C00239',
        st_setsrid(st_point(-58.916500, -27.472807), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (3481605614, 'Padre Cerqueira y Alvear', 'Parada C01048',
        st_setsrid(st_point(-59.003556, -27.448899), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (4116855112, '25 de Mayo y Roberto Mora', 'Parada C01607',
        st_setsrid(st_point(-58.998012, -27.440787), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (4116855114, '25 de Mayo y San Buenaventura del Monte Alto', 'Parada C00138',
        st_setsrid(st_point(-58.994378, -27.443987), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (4116855116, 'Cataratas del Iguazú y Leo Parzianello', 'Parada C00276',
        st_setsrid(st_point(-59.036713, -27.447950), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (4116855117, 'Cataratas del Iguazú y Martín Lestani', 'Parada C00157',
        st_setsrid(st_point(-59.038166, -27.449477), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (4116855118, 'Martín Lestani y Sierras de Córdoba', 'Parada C00158',
        st_setsrid(st_point(-59.036692, -27.451144), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (4456305995, '108 y 104A', null,
        st_setsrid(st_point(-58.838408, -27.470935), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (4456311189, '104', null,
        st_setsrid(st_point(-58.838239, -27.469441), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (4525078801, 'Parada 106 y 108A', null,
        st_setsrid(st_point(-58.839120, -27.461582), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (4556866231, 'Gobernador Deolindo Felipe Bittel y Autovía Nicolás Avellaneda', null,
        st_setsrid(st_point(-58.970088, -27.413700), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (4558623651, 'Avenida de la Democracia y Autovía Nicolás Avellaneda', 'Parada C07267',
        st_setsrid(st_point(-59.001925, -27.410956), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (4573730535, 'Varias linas', null,
        st_setsrid(st_point(-58.838052, -27.467517), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (4592648165, 'Gobernador Deolindo Felipe Bittel y Autovía Nicolás Avellaneda', null,
        st_setsrid(st_point(-58.969604, -27.413857), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (4595625753, 'Avenida 25 de Mayo y Acceso Norte a Ruta Nacional 11', 'Parada C00198',
        st_setsrid(st_point(-59.009688, -27.431016), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (4603393591, 'Avenida de la Democracia y Primero de Mayo', null,
        st_setsrid(st_point(-59.020657, -27.443153), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (4645954489, 'Yrigoyen e Italia', 'Parada C02322',
        st_setsrid(st_point(-58.981069, -27.454310), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (4649774613, '104 A', null,
        st_setsrid(st_point(-58.842051, -27.473885), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (4649774618, '104 A 104 B 104 C', null,
        st_setsrid(st_point(-58.837812, -27.465190), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (4654994144, '104 B', null,
        st_setsrid(st_point(-58.848100, -27.474439), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (4654994160, '104 B', null,
        st_setsrid(st_point(-58.841813, -27.468194), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (4690768631, 'Luisa Dora de Galíndez', null,
        st_setsrid(st_point(-58.985873, -27.407058), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (4917303821, 'Nicolás Rojas Acosta y 9 de Julio', 'Parada C00043',
        st_setsrid(st_point(-58.975663, -27.460378), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5002387598, '110 A', null,
        st_setsrid(st_point(-58.844520, -27.474937), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5045493903, 'Chaco Corrientes', null,
        st_setsrid(st_point(-58.842072, -27.471722), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5045493904, 'Chaco Corrientes', null,
        st_setsrid(st_point(-58.841776, -27.467267), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5193816343, 'Doctor Evaristo Ramírez y Arturo Lestani', null,
        st_setsrid(st_point(-58.985016, -27.468544), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5193846665, 'Doctor Evaristo Ramírez y Avenida Carlos López Piacentini', 'Parada C03301',
        st_setsrid(st_point(-58.986783, -27.468800), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5294340532, 'General Vedia y Avenida 25 de Mayo', null,
        st_setsrid(st_point(-58.988460, -27.449739), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5337560205, '25 de Mayo y Posadas', 'Parada C00136',
        st_setsrid(st_point(-58.991588, -27.446487), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5337560214, 'Bittel Km 15,3 (Cetrogar)', 'Parada C00575',
        st_setsrid(st_point(-58.971336, -27.413105), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5337560218, 'Rapazzioli de Bernal y Antequeras', null,
        st_setsrid(st_point(-58.986176, -27.405244), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5337560220, 'Bittel Km 15,6 (Musimundo)', 'Parada C00665',
        st_setsrid(st_point(-58.984023, -27.407975), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5340694062, 'Julio A. Roca 150', null,
        st_setsrid(st_point(-58.988920, -27.450655), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5340694064, 'Alberdi 150', 'Parada C07795',
        st_setsrid(st_point(-58.988065, -27.452398), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5340694067, 'Sabín y Las Azucenas', null,
        st_setsrid(st_point(-58.976994, -27.423925), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5340694070, 'Sabín y Martina', 'Parada C00681',
        st_setsrid(st_point(-58.975983, -27.422615), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5342771436, 'Ávalos y Lavalle', 'Parada C00588',
        st_setsrid(st_point(-58.986478, -27.438241), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5342771445, 'Sabín e Irupé', 'Parada C00582',
        st_setsrid(st_point(-58.978245, -27.426384), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5345412735, 'Avenida de los Inmigrantes y Nueva Pompeya', 'Parada C00550',
        st_setsrid(st_point(-58.980074, -27.433752), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5349662688, 'Inmigrantes y Ecuador (Domo del Centenario)', null,
        st_setsrid(st_point(-58.980976, -27.438487), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5349662692, '25 de Mayo y Liniers', 'Parada C07252',
        st_setsrid(st_point(-58.989752, -27.448119), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5349662693, 'Marcelo T. de Alvear 250 (Monseñor de Carlo)', 'Parada C07802',
        st_setsrid(st_point(-58.987744, -27.448385), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5354428124, 'Machicote de Díaz y Azurduy', 'Parada C00670',
        st_setsrid(st_point(-58.984174, -27.402531), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5354428126, 'Club de Vialidad Provincial', 'Parada C00587',
        st_setsrid(st_point(-58.982718, -27.436182), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5354500949, 'Julio A. Roca y Necochea', 'Parada C00594',
        st_setsrid(st_point(-58.990176, -27.449552), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5354500951, 'Julio A. Roca y Belgrano', 'Parada C00593',
        st_setsrid(st_point(-58.991967, -27.447962), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5354500953, 'Julio A. Roca y Cangallo', 'Parada C00592',
        st_setsrid(st_point(-58.993688, -27.446442), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5354500954, 'Ávalos 50', 'Parada C00542',
        st_setsrid(st_point(-58.993032, -27.444582), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5354500955, 'Ávalos 50', null,
        st_setsrid(st_point(-58.993287, -27.444312), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5354500956, 'Ávalos y Rivadavia', 'Parada C00589',
        st_setsrid(st_point(-58.989244, -27.440717), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5354500957, 'Ávalos y Corrientes', 'Parada C00590',
        st_setsrid(st_point(-58.991012, -27.442305), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5354500959, 'Inmigrantes y Fortín Chilcas', 'Parada C00551',
        st_setsrid(st_point(-58.980367, -27.432480), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5354500972, 'Sabín y Fortín Lapacho', 'Parada C00584',
        st_setsrid(st_point(-58.979353, -27.429153), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5354500973, 'Sabín y Charata (Alto Sabín)', 'Parada C00580',
        st_setsrid(st_point(-58.971966, -27.418271), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5354500975, 'Sabín y Tenev', 'Parada C00579',
        st_setsrid(st_point(-58.969591, -27.416137), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5355167640, 'Ávalos y Rivadavia', 'Parada C00544',
        st_setsrid(st_point(-58.989316, -27.441239), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5355167643, 'Inmigrantes y Fortín Lavalle', null,
        st_setsrid(st_point(-58.979445, -27.434524), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5355167648, 'Inmigrantes y Lavalle', 'Parada C00548',
        st_setsrid(st_point(-58.983559, -27.440811), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5361852916, 'Mitre y Corrientes', 'Parada C07816',
        st_setsrid(st_point(-58.984707, -27.447843), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5361852918, 'Rivadavia y Mitre', null,
        st_setsrid(st_point(-58.983282, -27.446383), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5361854528, 'Rivadavia y Remedios de Escalada', 'Parada C03052',
        st_setsrid(st_point(-58.985022, -27.444839), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5361854530, 'Rivadavia y Ávalos', 'Parada C03133',
        st_setsrid(st_point(-58.989533, -27.440828), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5361854532, 'Rivadavia y Concepción del Bermejo', 'Parada C03132',
        st_setsrid(st_point(-58.991244, -27.439316), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5361854534, 'Rivadavia y La Cangayé', 'Parada C03131',
        st_setsrid(st_point(-58.993164, -27.437602), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5361854536, 'Rivadavia y Raúl B. Díaz', 'Parada C03130',
        st_setsrid(st_point(-58.994931, -27.436035), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5361854538, 'Rivadavia y Ameri', 'Parada C03129',
        st_setsrid(st_point(-58.997301, -27.433894), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5372434722, 'Pasaje Crisanto Domínguez y De Morgan', 'Parada C00674',
        st_setsrid(st_point(-58.978088, -27.402466), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5372434724, 'Azurduy y Pasaje Crisanto Domínguez', 'Parada C00672',
        st_setsrid(st_point(-58.981209, -27.405029), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5377854736, 'Seminario', null,
        st_setsrid(st_point(-59.010534, -27.431265), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5377854740, 'Frondizi y General Obligado', 'Parada C07815',
        st_setsrid(st_point(-58.988015, -27.454163), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5379591769, 'Sarmiento y Montaner', null,
        st_setsrid(st_point(-58.969752, -27.436250), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5384964512, 'Hernandarias y Mendoza', 'Parada C01765',
        st_setsrid(st_point(-58.999662, -27.450529), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5389795606, 'Ameghino y Sáenz Peña', 'Parada C03025',
        st_setsrid(st_point(-58.987192, -27.456634), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5389795608, 'San Martín 150', 'Parada C02268',
        st_setsrid(st_point(-58.983549, -27.456155), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5389795618, '25 de Mayo y Mansilla', 'Parada C00113',
        st_setsrid(st_point(-59.002909, -27.436719), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5393038581, 'Alberdi 130 (vuelta)', null,
        st_setsrid(st_point(-58.987740, -27.452112), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5393038585, '25 de Mayo y Necochea', 'Parada C01604',
        st_setsrid(st_point(-58.989335, -27.448772), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5393038587, '25 de Mayo y Cangallo', 'Parada C00117',
        st_setsrid(st_point(-58.992826, -27.445667), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5393038589, '25 de Mayo y Pío XII', 'Parada C00116',
        st_setsrid(st_point(-58.995570, -27.443212), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5393038591, '25 de Mayo y Lucio Salvadores', 'Parada C00223',
        st_setsrid(st_point(-59.019347, -27.422121), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5393038595, '25 de Mayo y San Juan', 'Parada C00221',
        st_setsrid(st_point(-59.024696, -27.417378), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5393825158, 'Alberdi 160', null,
        st_setsrid(st_point(-58.987764, -27.452412), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5395727291, 'Rosas y Bittel', 'Parada C00679',
        st_setsrid(st_point(-58.981908, -27.408051), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5395727293, 'De Morgan y Rosas', 'Parada C00676',
        st_setsrid(st_point(-58.976923, -27.403410), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5395727295, 'Machicote y Rogiolo', 'Parada C00669',
        st_setsrid(st_point(-58.985031, -27.403298), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5395727298, 'Machicote y Waisman', 'Parada C00668',
        st_setsrid(st_point(-58.985880, -27.404038), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5395727300, 'Salta y Alberdi', 'Parada C00121',
        st_setsrid(st_point(-58.989317, -27.453373), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5395727302, 'Salta y Vedia', 'Parada C00120',
        st_setsrid(st_point(-58.991066, -27.451816), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5395727304, 'Salta y Dónovan', 'Parada C01769',
        st_setsrid(st_point(-58.992752, -27.450326), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5395727306, 'Salta y Echeverría', 'Parada C02011',
        st_setsrid(st_point(-58.994518, -27.448747), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5395727308, 'Salta y Hernandarias', 'Parada C01053',
        st_setsrid(st_point(-58.996464, -27.447025), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5395727310, 'Salta y Pío XII', 'Parada C01052',
        st_setsrid(st_point(-58.998181, -27.445494), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5395727312, 'Salta y Padre Sena', 'Parada C07037',
        st_setsrid(st_point(-59.000115, -27.443792), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5401078638, 'Alberdi y Jujuy', 'Parada C00596',
        st_setsrid(st_point(-58.991712, -27.455665), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5401746653, 'Yrigoyen y López y Planes', 'Parada C02323',
        st_setsrid(st_point(-58.982816, -27.452748), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5415318321, 'Chaco - Corrientes', null,
        st_setsrid(st_point(-58.845541, -27.474418), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5423025709, 'Sarmiento y Paraguay', 'Parada C00124',
        st_setsrid(st_point(-58.982261, -27.447471), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5423025718, '9 de Julio y Colón', 'Parada C00039',
        st_setsrid(st_point(-58.983230, -27.454187), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5423025822, '9 de Julio y Urquiza', 'Parada C01777',
        st_setsrid(st_point(-58.965196, -27.470182), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5423025824, '9 de Julio y Julio E. Acosta', 'Parada C01771',
        st_setsrid(st_point(-58.976060, -27.460551), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5423025879, '25 de Mayo y Falcón', 'Parada C00140',
        st_setsrid(st_point(-59.000585, -27.438478), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5423025881, '25 de Mayo y Algarrobo', 'Parada C00220',
        st_setsrid(st_point(-59.027295, -27.415095), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5423025887, '25 de Mayo 4550', null,
        st_setsrid(st_point(-59.028406, -27.414131), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5423025888, 'Avenida 25 de Mayo y Bolivia', 'Parada C00207',
        st_setsrid(st_point(-59.032002, -27.410882), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5426465582, 'San Martín 50', 'Parada C01261',
        st_setsrid(st_point(-58.982574, -27.455560), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5432236583, 'Avenida de la Democracia y Acceso a Aeropuerto de Resistencia', 'Parada C00149',
        st_setsrid(st_point(-59.021876, -27.444300), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5432259053, 'Ushuaia y Avenida Mac Lean', 'Parada C01250',
        st_setsrid(st_point(-59.029608, -27.463810), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5432400543, 'Álvarez Jonte y Avenida Marconi', 'Parada C07744',
        st_setsrid(st_point(-59.017430, -27.448849), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5438692442, 'Avenida Juan José Castelli y Rotonda Las Heras y Castelli', 'Parada C01581',
        st_setsrid(st_point(-58.986786, -27.463625), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5443961811, 'Avenida General Mosconi y Rotonda Gaboto - 9 de Julio - General Mosconi', 'Parada C01791',
        st_setsrid(st_point(-58.937427, -27.496672), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5654724052, 'Parada Chaco-Corrientes', null,
        st_setsrid(st_point(-58.840438, -27.475498), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (5873323260, 'Terminal de colectivos', null,
        st_setsrid(st_point(-59.022141, -27.456860), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (6154043773, '9 de Julio y Lisandro de la Torre', 'Parada C00042',
        st_setsrid(st_point(-58.976947, -27.459763), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (6154084691, '9 de Julio 3170', 'Parada C01780',
        st_setsrid(st_point(-58.958347, -27.476262), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (8489597365, 'Parada 105 110', null,
        st_setsrid(st_point(-58.780487, -27.464412), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (8954694119, 'Terminal de la línea 110', null,
        st_setsrid(st_point(-58.838385, -27.461656), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (8954694120, 'Parada Corrientes-Chaco', null,
        st_setsrid(st_point(-58.840907, -27.461365), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (9015653273, 'Avenida de la Democracia y Catamarca', 'Parada C07254',
        st_setsrid(st_point(-59.007773, -27.420658), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (9017890943, 'Avenida de la Democracia y Santa Sylvina', 'Parada C07259',
        st_setsrid(st_point(-58.998246, -27.400434), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (9428070121, 'Avenida 25 de Mayo y Julio Argentino Roca', 'Parada C00110',
        st_setsrid(st_point(-59.007601, -27.433999), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (9548014987, 'Avenida Sabín y Villa Ángela', 'Parada C00557',
        st_setsrid(st_point(-58.970551, -27.417323), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (9569868044, 'Belgrano y García Merou', null,
        st_setsrid(st_point(-58.998847, -27.454523), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (9569922716, 'Italia y Ayacucho', 'Parada C01275',
        st_setsrid(st_point(-58.978605, -27.451725), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (9571133081, 'Calle 3 y Jujuy', 'Parada C01049',
        st_setsrid(st_point(-59.001702, -27.447299), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (9571133082, 'Calle 3 y Libertad (Ida)', 'Parada C01047',
        st_setsrid(st_point(-59.004646, -27.449846), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (9571133083, 'Pío XII y Santiago del Estero', 'Parada C01051',
        st_setsrid(st_point(-58.998896, -27.446511), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (9571133084, 'Pío XII y Salta', 'Parada C01052',
        st_setsrid(st_point(-58.998017, -27.445722), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (9574060025, 'Calle 3 y Libertad (Vuelta)', 'Parada C01033',
        st_setsrid(st_point(-59.004553, -27.449654), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (9574100730, 'Frita''s', 'Parada C00063',
        st_setsrid(st_point(-58.981870, -27.455140), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (9574100733, 'PAMI', 'Parada C07799',
        st_setsrid(st_point(-58.985076, -27.452261), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (9574158673, 'Perón y Calle 3', null,
        st_setsrid(st_point(-58.997999, -27.444004), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (9574158675, 'Marcelo T. de Alvear y Ávalos', null,
        st_setsrid(st_point(-58.992404, -27.444213), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (9574158677, '25 de Mayo y Formosa', 'Parada C00137',
        st_setsrid(st_point(-58.992422, -27.445738), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (9580867795, 'Shopping Sarmiento', 'Parada C01331',
        st_setsrid(st_point(-58.965280, -27.432259), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (9581655136, 'Padre Cerqueira y Alvear (Vuelta)', 'Parada C01032',
        st_setsrid(st_point(-59.003322, -27.448578), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (9588873700, '25 de Mayo y San Roque', 'Parada C01656',
        st_setsrid(st_point(-58.994742, -27.443990), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (9592863285, 'Alvear y San Roque (vuelta)', 'Parada C01523',
        st_setsrid(st_point(-59.001439, -27.450422), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (9592889151, 'Obligado y Miguel Delfino', 'Parada C02277',
        st_setsrid(st_point(-58.969473, -27.470981), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (9592889153, 'Ameghino y Miguel Delfino', 'Parada C02311',
        st_setsrid(st_point(-58.969977, -27.471889), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (9598435807, 'Avenida Hernandarias y Felipe Molina', 'Parada C02041',
        st_setsrid(st_point(-59.002369, -27.452476), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (9608017372, 'Alvear y Cangallo (vuelta)', 'Parada C01522',
        st_setsrid(st_point(-58.999404, -27.452033), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (9610020118, 'Alvear y Vedia', 'Parada C01520',
        st_setsrid(st_point(-58.995073, -27.455946), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (9622429848, 'Rotonda Ruta 11 y 16 (vuelta)', 'Parada C07257',
        st_setsrid(st_point(-59.001576, -27.412082), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (9622477371, 'Vialidad Provincial', 'Parada C06772',
        st_setsrid(st_point(-59.009646, -27.432204), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (9630273766, 'Avenida Carlos María de Alvear y General Mansilla', 'Parada C01527',
        st_setsrid(st_point(-59.009842, -27.443290), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (9630447877, 'Jujuy y Belgrano', 'Parada C00074',
        st_setsrid(st_point(-58.995927, -27.452081), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (9632222794, '25 de Mayo y Lapacho', 'Parada C01643',
        st_setsrid(st_point(-59.029032, -27.413533), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (9635248369, 'Avenida Hernandarias y Jujuy', 'Parada C01835',
        st_setsrid(st_point(-58.998834, -27.449779), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (9641559167, 'Avenida 25 de Mayo y Avenida Mac Lean', null,
        st_setsrid(st_point(-59.001180, -27.438293), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (9650545925, 'Santiago del Estero y Belgrano', 'Parada C01279',
        st_setsrid(st_point(-58.994161, -27.450457), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (9654655365, 'Alvear y Necochea (ida)', 'Parada C00033',
        st_setsrid(st_point(-58.996430, -27.455171), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (9661999750, 'Ruta 11 Km 1007', 'Parada C06757',
        st_setsrid(st_point(-59.005675, -27.418250), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (9664332009, 'Parada de colectivo', null,
        st_setsrid(st_point(-58.808435, -27.472279), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (9670766766, 'Ruta Nacional 16 y Puente General Belgrano', null,
        st_setsrid(st_point(-58.869712, -27.461546), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (9670766767, 'Ruta Nacional 16 y Puente General Belgrano', null,
        st_setsrid(st_point(-58.869785, -27.461706), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (9693510645, 'Juan B. Justo y Juan de Dios Mena', 'Parada C02273',
        st_setsrid(st_point(-58.979410, -27.459075), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (9707992257, 'Avenida Italia y Avenida Laprida', 'Parada C01274',
        st_setsrid(st_point(-58.974938, -27.448454), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (9923697695, 'Avenida 25 de Mayo 551', 'Parada C01657',
        st_setsrid(st_point(-58.991441, -27.446893), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (9923702850, 'Avenida 25 de Mayo y Avenida Belgrano', 'Parada C00118',
        st_setsrid(st_point(-58.991199, -27.447124), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (9948365768, 'Don Santiago', 'Parada C06750',
        st_setsrid(st_point(-58.990538, -27.399351), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (10002974639, 'Avenida de la Democracia', 'Parada C06756',
        st_setsrid(st_point(-59.003932, -27.414721), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (10008701031, 'Avenida de la Democracia', 'Parada C07256',
        st_setsrid(st_point(-59.003104, -27.415029), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (10013893076, 'Avenida de la Democracia y Avenida Lavalle', 'Parada C07255',
        st_setsrid(st_point(-59.006001, -27.419704), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (10013893080, 'Avenida 25 de Mayo y Avenida de la Democracia', 'Parada C00228',
        st_setsrid(st_point(-59.009741, -27.431708), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (10055961687, 'Avenida Alberdi y Franklin', 'Parada C02265',
        st_setsrid(st_point(-58.991781, -27.456033), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (10082219830, 'Casino Gala', 'Parada C00071',
        st_setsrid(st_point(-58.990805, -27.450263), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (10096123274, 'Avenida 25 de Mayo y Fray Rossi', 'Parada C00114',
        st_setsrid(st_point(-59.000274, -27.439181), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (10096175373, 'Avenida de la Democracia y Eduardo Gerónimo Orcola', 'Parada C06754',
        st_setsrid(st_point(-59.000437, -27.405658), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (10099186304, 'Avenida de la Democracia y Cacique Vahenolec', 'Parada C06759',
        st_setsrid(st_point(-59.010571, -27.428432), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (10100951965, 'Avenida 25 de Mayo y La Cangayé', 'Parada C00139',
        st_setsrid(st_point(-58.997157, -27.441530), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (10100979100, '25 de Mayo y Andreani', 'Parada C00142',
        st_setsrid(st_point(-59.003358, -27.436035), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (10100981309, '25 de Mayo y Etcheverrigaray', 'Parada C00143',
        st_setsrid(st_point(-59.005059, -27.434769), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (10101015843, 'Avenida de la Democracia y Avenida Lavalle', null,
        st_setsrid(st_point(-59.005413, -27.419355), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (10101021829, 'Barrio Toba', 'Parada C07253',
        st_setsrid(st_point(-59.009642, -27.428041), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (10101022555, 'Avenida de la Democracia', null,
        st_setsrid(st_point(-59.008352, -27.422399), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (10103521481, 'Padre Cerqueira y Carlos Gardel', 'Parada C01316',
        st_setsrid(st_point(-59.008433, -27.453208), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (10103584646, 'Padre Cerqueira y La Pampa', 'Parada C01045',
        st_setsrid(st_point(-59.007366, -27.452291), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (10117294508, 'Avenida de la Democracia y Ciervo Petiso', null,
        st_setsrid(st_point(-59.000441, -27.408432), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (10117300751, 'Centro de Salud Barrio Cristo Rey', 'Parada C06773',
        st_setsrid(st_point(-58.999994, -27.407255), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (10119893798, 'Fray Bertaca y Falucho', 'Parada C02339',
        st_setsrid(st_point(-59.019328, -27.448246), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (10126914527, 'Avenida de la Democracia y Avenida 25 de Mayo', 'Parada C00227',
        st_setsrid(st_point(-59.010898, -27.429984), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (10127025923, 'Ameghino y Avenida Las Heras', 'Parada C02319',
        st_setsrid(st_point(-58.982596, -27.460693), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (10132364564, 'Avenida 25 de Mayo y Julio Argentino Roca', 'Parada C01661',
        st_setsrid(st_point(-59.007175, -27.434029), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (10140079710, 'Perón y Pío XII', null,
        st_setsrid(st_point(-58.996991, -27.444883), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (10140159295, 'Remedios de Escalada y 25', 'Parada C00070',
        st_setsrid(st_point(-58.988994, -27.448632), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (10177204353, 'Padre Cerqueira y Avenida Moreno', 'Parada C01050',
        st_setsrid(st_point(-59.001026, -27.446530), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (10177227264, 'López y Planes 250', null,
        st_setsrid(st_point(-58.981569, -27.451538), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (10177233586, 'Don Bosco y Avenida Sarmiento', null,
        st_setsrid(st_point(-58.983565, -27.448972), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (10281373203, 'Avenida General Mosconi y Avenida Juan José Castelli', 'Parada C01794',
        st_setsrid(st_point(-58.942586, -27.501717), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (10608286601, 'Pasaje Vecinal A. González Balcarce y Juan B. Azopardo', 'Parada C02336',
        st_setsrid(st_point(-59.014391, -27.445904), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (10695768687, 'Avenida Independencia y San Martín', null,
        st_setsrid(st_point(-59.086935, -27.374635), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (10695768689, 'Avenida 25 de Mayo y Padre Sena', 'Parada C01655',
        st_setsrid(st_point(-58.997588, -27.441504), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (10697137885, 'Gobernador Anselmo Zoilo Ducca y Autovía Nicolás Avellaneda', null,
        st_setsrid(st_point(-59.004485, -27.409623), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (10697895419, 'Avenida Independencia y 9 de Julio', null,
        st_setsrid(st_point(-59.087396, -27.373611), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (10697895420, 'Acceso a Puerto Tirol y Carlos Gardel', null,
        st_setsrid(st_point(-59.082338, -27.374035), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (10697951147, 'Avenida Antonio Címbaro Canella y Avenida Independencia', null,
        st_setsrid(st_point(-59.087807, -27.373480), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (10698064411, 'Puerto Velaz y Margarita Belén', null,
        st_setsrid(st_point(-58.990491, -27.399501), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (10724102115, 'Moreno y Santa María de Oro', null,
        st_setsrid(st_point(-58.991879, -27.454136), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (10742437458, 'Avenida 9 de Julio y Aliso', 'Parada C01016',
        st_setsrid(st_point(-58.952230, -27.481310), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (10772099263, 'Avenida de la Democracia y Falucho', null,
        st_setsrid(st_point(-59.023379, -27.445520), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (10776228012, 'General Belgrano y Avenida Maipú', 'Parada C00184',
        st_setsrid(st_point(-58.910226, -27.468461), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (10788479384, 'General Obligado y Arturo Frondizi', 'Parada C02267',
        st_setsrid(st_point(-58.988442, -27.454137), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (10788568329, 'Avenida Carlos María de Alvear y Avenida Alberdi', 'Parada C01577',
        st_setsrid(st_point(-58.993886, -27.457227), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (10788568330, 'Avenida Alberdi y Cervantes', 'Parada C00531',
        st_setsrid(st_point(-58.992630, -27.456791), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (10788568331, 'Avenida San Martín y General Obligado', 'Parada C02269',
        st_setsrid(st_point(-58.984654, -27.457156), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (10788568332, 'Roque Sáenz Peña y Juan B. Justo', 'Parada C00038',
        st_setsrid(st_point(-58.984910, -27.454486), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (10790412472, 'Avenida Sarmiento y Gobernador Rolando Tauguinas', null,
        st_setsrid(st_point(-58.956848, -27.422360), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (10837232580, 'Avenida Maipú y General Belgrano', 'Parada C00243',
        st_setsrid(st_point(-58.910384, -27.467754), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (10880100961, 'Av. Soberanía y Urquiza', 'Parada C00617',
        st_setsrid(st_point(-58.986490, -27.489359), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (10922678839, 'Rivadavia y Posadas', 'Parada C03134',
        st_setsrid(st_point(-58.987677, -27.442564), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (10925258013, 'López y Planes y Almirante Brown', null,
        st_setsrid(st_point(-58.982222, -27.452090), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11019050480, 'Belgrano', null,
        st_setsrid(st_point(-58.994814, -27.451639), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11342019228, 'Avenida Hernandarias y Carlos Gardel', 'Parada C02043',
        st_setsrid(st_point(-59.005652, -27.455435), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11499855680, 'Avenida Mac Lean y Marcos Paz', 'Parada C00022',
        st_setsrid(st_point(-59.014122, -27.450294), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11499855681, 'Avenida Mac Lean y Carlos Gardel', 'Parada C00023',
        st_setsrid(st_point(-59.013012, -27.449298), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11499855682, 'Avenida Mac Lean y Felipe Molina', 'Parada C00025',
        st_setsrid(st_point(-59.009690, -27.446339), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11499855690, 'Avenida Carlos María de Alvear y Padre Sena', 'Parada C00028',
        st_setsrid(st_point(-59.004639, -27.447828), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11499855691, 'Avenida Carlos María de Alvear y Pío XII', 'Parada C00029',
        st_setsrid(st_point(-59.002724, -27.449517), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11499855693, 'Avenida Carlos María de Alvear y Santa María de Oro', 'Parada C00034',
        st_setsrid(st_point(-58.994718, -27.456578), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11499855694, 'Avenida 9 de Julio y San Lorenzo', 'Parada C00040',
        st_setsrid(st_point(-58.980587, -27.456457), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11499855696, 'Avenida Nicolás Rojas Acosta y Almirante Brown', 'Parada C00044',
        st_setsrid(st_point(-58.974168, -27.459229), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11499855697, 'Avenida Nicolás Rojas Acosta y Ayacucho', 'Parada C00045',
        st_setsrid(st_point(-58.972422, -27.457645), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11499855698, 'Avenida Nicolás Rojas Acosta y Saavedra', 'Parada C00046',
        st_setsrid(st_point(-58.970684, -27.456008), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11499855699, 'Avenida Nicolás Rojas Acosta y Avenida Laprida', 'Parada C00047',
        st_setsrid(st_point(-58.968764, -27.454288), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11499855700, 'Avenida Nicolás Rojas Acosta y Juan Ramón Lestani', 'Parada C00048',
        st_setsrid(st_point(-58.967055, -27.452760), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11499855701, 'Avenida Nicolás Rojas Acosta y León Zorrilla', 'Parada C00054',
        st_setsrid(st_point(-58.964621, -27.450591), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11499913952, 'Pasaje Laguna del Desierto y Tatú Carreta', 'Parada C00001',
        st_setsrid(st_point(-59.047252, -27.455475), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11499913953, 'Pasaje Laguna del Desierto y Tapir', 'Parada C00002',
        st_setsrid(st_point(-59.048390, -27.456501), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11499913954, 'Tapir y Laguna del Desierto', 'Parada C00003',
        st_setsrid(st_point(-59.048167, -27.457022), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11499913955, 'Laguna del Desierto y Tatú Carreta', 'Parada C00004',
        st_setsrid(st_point(-59.046769, -27.456004), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11499913956, 'Tatú Carreta y Villa Carlos Paz', 'Parada C00005',
        st_setsrid(st_point(-59.045253, -27.457120), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11499913957, 'Tatú Carreta e Isla del Cerrito', 'Parada C00006',
        st_setsrid(st_point(-59.042641, -27.459435), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11499913960, 'Avenida de la Democracia y Ushuaia', 'Parada C00011',
        st_setsrid(st_point(-59.036252, -27.458164), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11499913961, 'Ushuaia e Isaías', 'Parada C00012',
        st_setsrid(st_point(-59.034930, -27.459130), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11499913962, 'Ushuaia y General Fotheringam', 'Parada C00013',
        st_setsrid(st_point(-59.032431, -27.461349), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11499913963, 'Ushuaia y General Uriburu', 'Parada C00014',
        st_setsrid(st_point(-59.030947, -27.462632), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11499913964, 'Avenida Mac Lean y Montevideo', 'Parada C00016',
        st_setsrid(st_point(-59.025034, -27.460068), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11499913965, 'Avenida Mac Lean y Avenida Bogotá', 'Parada C00017',
        st_setsrid(st_point(-59.023197, -27.458428), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11499913966, 'Avenida Mac Lean y Dos de Abril de 1982', 'Parada C00018',
        st_setsrid(st_point(-59.021122, -27.456569), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11499913967, 'Avenida Mac Lean y Domingo Matheu', 'Parada C00020',
        st_setsrid(st_point(-59.017038, -27.452910), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11499913968, 'Avenida Mac Lean y Avenida Marconi', 'Parada C00021',
        st_setsrid(st_point(-59.015311, -27.451345), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11502929839, 'Tatú Carreta y Cataratas del Iguazú', 'Parada C00097',
        st_setsrid(st_point(-59.045837, -27.456602), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11502929840, 'Tatú Carreta y Sierras de Córdoba', 'Parada C00096',
        st_setsrid(st_point(-59.044095, -27.458146), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11502929845, 'Ushuaia e Isaías', 'Parada C00093',
        st_setsrid(st_point(-59.034751, -27.459295), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11502929846, 'Ushuaia y General Fotheringam', 'Parada C00092',
        st_setsrid(st_point(-59.032186, -27.461552), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11502929847, 'Ushuaia y General Uriburu', 'Parada C00091',
        st_setsrid(st_point(-59.030716, -27.462835), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11502929848, 'Avenida Mac Lean y Ushuaia', 'Parada C00090',
        st_setsrid(st_point(-59.029168, -27.463779), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11502929849, 'Avenida Mac Lean y Montevideo', 'Parada C00089',
        st_setsrid(st_point(-59.024809, -27.459866), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11502929850, 'Avenida Mac Lean y Avenida Bogotá', 'Parada C00088',
        st_setsrid(st_point(-59.022973, -27.458050), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11502929851, 'Avenida Mac Lean y Avenida Islas Malvinas', 'Parada C00087',
        st_setsrid(st_point(-59.022212, -27.457365), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11502929853, 'Avenida Mac Lean y Domingo Cubells', 'Parada C00086',
        st_setsrid(st_point(-59.019555, -27.454979), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11502929854, 'Avenida Mac Lean y Belén', 'Parada C00085',
        st_setsrid(st_point(-59.017788, -27.453390), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11502929857, 'Avenida Mac Lean y Avenida Marconi', 'Parada C00084',
        st_setsrid(st_point(-59.015110, -27.450967), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11502929858, 'Avenida Mac Lean y Lima', 'Parada C00083',
        st_setsrid(st_point(-59.012530, -27.448687), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11502929860, 'Avenida Mac Lean y Los Andes', 'Parada C02334',
        st_setsrid(st_point(-59.010156, -27.446565), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11502929861, 'Avenida Mac Lean y Libertad', 'Parada C00081',
        st_setsrid(st_point(-59.009216, -27.445719), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11502929862, 'Avenida Mac Lean y Mendoza', 'Parada C00080',
        st_setsrid(st_point(-59.006954, -27.443666), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11502929863, 'Jujuy y Fray Rossi', 'Parada C00079',
        st_setsrid(st_point(-59.005116, -27.443997), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11502929864, 'Jujuy y Misionero Klein', 'Parada C00078',
        st_setsrid(st_point(-59.003309, -27.445606), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11502929866, 'Jujuy y San Roque', 'Parada C00076',
        st_setsrid(st_point(-58.999617, -27.448866), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11502929867, 'Jujuy y Cangallo', 'Parada C00075',
        st_setsrid(st_point(-58.997713, -27.450554), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11502929868, 'Avenida 9 de Julio y López y Planes', 'Parada C00064',
        st_setsrid(st_point(-58.983683, -27.453563), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11502937469, 'Avenida 9 de Julio y Avenida Las Heras', 'Parada C00061',
        st_setsrid(st_point(-58.979089, -27.457639), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11502937472, 'Avenida Nicolás Rojas Acosta y Ayacucho', 'Parada C00057',
        st_setsrid(st_point(-58.972320, -27.457432), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11502937473, 'Avenida Nicolás Rojas Acosta y Sargento Cabral', 'Parada C00056',
        st_setsrid(st_point(-58.967785, -27.453288), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11502937474, 'Alice Le Saige y Avenida Nicolás Rojas Acosta', 'Parada C00055',
        st_setsrid(st_point(-58.965182, -27.451208), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11502937475, 'Alice Le Saige y Ramón Vázquez', 'Parada C0050',
        st_setsrid(st_point(-58.964375, -27.451918), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11505958837, 'Sierras de Córdoba y Tatú Carreta', 'Parada C00183',
        st_setsrid(st_point(-59.044106, -27.457930), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11505958838, 'Oso Hormiguero y Sierras de Córdoba', 'Parada C00182',
        st_setsrid(st_point(-59.043394, -27.456996), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11505958839, 'Pasaje Villa Carlos Paz y Oso Hormiguero', 'Parada C00181',
        st_setsrid(st_point(-59.044564, -27.455588), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11505958840, 'Ushuaia y Pasaje Villa Carlos Paz', 'Parada C00180',
        st_setsrid(st_point(-59.041648, -27.453130), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11505958841, 'Enrique Kistermacher y Villa Carlos Paz', 'Parada C00179',
        st_setsrid(st_point(-59.038499, -27.451670), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11505958842, 'Enrique Kistermacher y Sierras de Córdoba', 'Parada C00178',
        st_setsrid(st_point(-59.037650, -27.452425), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11505958843, 'Isla del Cerrito y Enrique Kistermacher', 'Parada C00177',
        st_setsrid(st_point(-59.035910, -27.453775), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11505958844, 'Martín Lestani e Isla del Cerrito', 'Parada C00159',
        st_setsrid(st_point(-59.034856, -27.452620), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11505958846, 'Cataratas del Iguazú y Avenida Islas Malvinas', 'Parada C00155',
        st_setsrid(st_point(-59.035046, -27.446612), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11505958847, 'Avenida Islas Malvinas y Villa Carlos Paz', 'Parada C06520',
        st_setsrid(st_point(-59.033414, -27.447629), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11505958848, 'Avenida Islas Malvinas y San Carlos de Bariloche', 'Parada C06519',
        st_setsrid(st_point(-59.031743, -27.449113), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11505958849, 'República de Israel y Río Guaycurú', 'Parada C00150',
        st_setsrid(st_point(-59.025816, -27.447835), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11505958850, 'Avenida de la Democracia y Teniente Mayor Origone', 'Parada C00148',
        st_setsrid(st_point(-59.019179, -27.441885), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11505958851, 'Avenida de la Democracia y Comandante Fontana', 'Parada C00147',
        st_setsrid(st_point(-59.017770, -27.440605), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11505958852, 'Avenida de la Democracia y García Merou', 'Parada C00146',
        st_setsrid(st_point(-59.016038, -27.439079), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11505958855, 'Avenida de la Democracia y Avenida 25 de Mayo', 'Parada C00145',
        st_setsrid(st_point(-59.010902, -27.431444), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11505958856, 'Avenida 25 de Mayo y República de Israel', 'Parada C00144',
        st_setsrid(st_point(-59.008837, -27.432910), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11505958861, 'Acceso Norte a Ruta Nacional 11 y Avenida 25 de Mayo', 'Parada C00199',
        st_setsrid(st_point(-59.009728, -27.430636), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11505958868, 'Avenida 25 de Mayo y General Mansilla', 'Parada C00141',
        st_setsrid(st_point(-59.002522, -27.436859), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11505989072, 'Avenida Sarmiento y Córdoba', 'Parada C01341',
        st_setsrid(st_point(-58.980279, -27.445466), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11505989074, 'Avenida Sarmiento y Corrientes', 'Parada C01342',
        st_setsrid(st_point(-58.983752, -27.448584), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11505989075, 'Avenida Sarmiento y Avenida Rivadavia', 'Parada C07743',
        st_setsrid(st_point(-58.982005, -27.447012), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11505989076, 'Sargento Cabral y Avenida Sarmiento', 'Parada C07741',
        st_setsrid(st_point(-58.978310, -27.444142), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11505989077, 'Sargento Cabral y López y Planes', 'Parada C07740',
        st_setsrid(st_point(-58.975762, -27.446420), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11505989078, 'Sargento Cabral y French', 'Parada C07739',
        st_setsrid(st_point(-58.974844, -27.447225), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11505989079, 'Sargento Cabral y José Hernández', 'Parada C07733',
        st_setsrid(st_point(-58.972261, -27.449496), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11505989086, 'Fray Luis Beltrán y Alice Le Saige', 'Parada C00292',
        st_setsrid(st_point(-58.963504, -27.452589), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11508368322, 'Avenida Nicolás Rojas Acosta y Alice Le Saige', 'Parada C00049',
        st_setsrid(st_point(-58.965361, -27.451238), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11508368323, 'Avenida Laprida y Padre Distorto', 'Parada C00133',
        st_setsrid(st_point(-58.969757, -27.453304), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11508368324, 'Avenida Laprida y Avenida Vélez Sarsfield', 'Parada C00132',
        st_setsrid(st_point(-58.972718, -27.450966), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11508368325, 'José Hernández y Sargento Cabral', 'Parada C00131',
        st_setsrid(st_point(-58.972203, -27.449251), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11508368326, 'Juan Ramón Lestani y Monteagudo', 'Parada C00130',
        st_setsrid(st_point(-58.972565, -27.447714), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11508368327, 'Juan Ramón Lestani y Avenida Italia', 'Parada C00129',
        st_setsrid(st_point(-58.973454, -27.446927), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11508368328, 'Juan Ramón Lestani y Pellegrini', 'Parada C00128',
        st_setsrid(st_point(-58.976030, -27.444640), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11508368329, 'Juan Ramón Lestani y Avenida Sarmiento', 'Parada C00127',
        st_setsrid(st_point(-58.977493, -27.443331), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11508368331, 'Avenida Sarmiento y Córdoba', 'Parada C00125',
        st_setsrid(st_point(-58.980487, -27.445824), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11508368335, 'Avenida 25 de Mayo y General Fotheringam', 'Parada C00112',
        st_setsrid(st_point(-59.003703, -27.435951), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11508368351, 'Avenida de la Democracia y Avenida Carlos María de Alvear', 'Parada C00109',
        st_setsrid(st_point(-59.014873, -27.439023), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11508368352, 'Avenida de la Democracia y Jericó', 'Parada C00106',
        st_setsrid(st_point(-59.023800, -27.446990), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11508368353, 'República de Israel y Avenida Islas Malvinas', 'Parada C00104',
        st_setsrid(st_point(-59.029723, -27.451314), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11508368354, 'Avenida Islas Malvinas e Isla del Cerrito', 'Parada C00105',
        st_setsrid(st_point(-59.031430, -27.449503), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11508368355, 'Avenida Islas Malvinas y Sierras de Córdoba', 'Parada C00103',
        st_setsrid(st_point(-59.033088, -27.448021), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11508368356, 'Avenida Islas Malvinas y Cataratas del Iguazú', 'Parada C00102',
        st_setsrid(st_point(-59.034748, -27.446536), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11508368359, 'Cataratas del Iguazú y Donato Geraldi', 'Parada C00277',
        st_setsrid(st_point(-59.035934, -27.447408), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11508368361, 'Cataratas del Iguazú y Luis De las Casas', 'Parada C0101',
        st_setsrid(st_point(-59.037449, -27.448992), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11508368363, 'Martín Lestani y Sierras de Córdoba', 'Parada C00099',
        st_setsrid(st_point(-59.036324, -27.451309), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11508368364, 'Isla del Cerrito y Martín Lestani', 'Parada C00170',
        st_setsrid(st_point(-59.034874, -27.452846), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11508368365, 'Enrique Kistermacher e Isla del Cerrito', 'Parada C00169',
        st_setsrid(st_point(-59.036116, -27.453789), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11508368366, 'Enrique Kistermacher y Sierras de Córdoba', 'Parada C00168',
        st_setsrid(st_point(-59.037937, -27.452170), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11508368367, 'Villa Carlos Paz y Enrique Kistermacher', 'Parada C00166',
        st_setsrid(st_point(-59.038863, -27.451554), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11508368368, 'Pasaje Villa Carlos Paz y Ushuaia', 'Parada C00166',
        st_setsrid(st_point(-59.041916, -27.453190), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11508412569, 'Oso Hormiguero y Pasaje Villa Carlos Paz', 'Parada C00165',
        st_setsrid(st_point(-59.044655, -27.455873), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11508412572, 'Sierras de Córdoba y Oso Hormiguero', 'Parada C00164',
        st_setsrid(st_point(-59.043461, -27.457348), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11510859293, 'Cataratas del Iguazú y Donato Geraldi', 'Parada C00275',
        st_setsrid(st_point(-59.035745, -27.447239), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11510859294, 'Mar del Plata y Avenida Islas Malvinas', 'Parada C00154',
        st_setsrid(st_point(-59.035452, -27.445629), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11510859295, 'Mar del Plata y Río Teuco', 'Parada C00153',
        st_setsrid(st_point(-59.033340, -27.443730), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11510859308, 'Río Guaycurú y Laguna del Desierto', 'Parada C00152',
        st_setsrid(st_point(-59.031494, -27.443059), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11510859309, 'Río Guaycurú y San Carlos de Bariloche', 'Parada C00151',
        st_setsrid(st_point(-59.028207, -27.445962), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11510859310, 'Avenida 9 de Julio y San Lorenzo', 'Parada C00062',
        st_setsrid(st_point(-58.980142, -27.456715), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11510859311, 'Avenida Nicolás Rojas Acosta y Avenida Paraguay', 'Parada C00058',
        st_setsrid(st_point(-58.971319, -27.456474), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11510859312, 'Avenida Nicolás Rojas Acosta y Córdoba', 'Parada C00057',
        st_setsrid(st_point(-58.969649, -27.454976), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11563981251, 'Avenida de la Democracia y Tres Carabelas', 'Parada C00108',
        st_setsrid(st_point(-59.018999, -27.442682), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11563981252, 'Avenida de la Democracia y Falucho', 'Parada C00107',
        st_setsrid(st_point(-59.022911, -27.446195), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11563981253, 'Río Guaycurú y República de Israel', 'Parada C00176',
        st_setsrid(st_point(-59.026097, -27.447852), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11563981254, 'Río Guaycurú y San Carlos de Bariloche', 'Parada C00175',
        st_setsrid(st_point(-59.028491, -27.445708), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11563981255, 'Río Guaycurú y Cataratas del Iguazú', 'Parada C00174',
        st_setsrid(st_point(-59.030945, -27.443556), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11563981256, 'Río Guaycurú y Laguna del Desierto', 'Parada C00173',
        st_setsrid(st_point(-59.031684, -27.442885), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11563981257, 'Mar del Plata y Río Teuco', 'Parada C00172',
        st_setsrid(st_point(-59.033529, -27.443898), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11563981258, 'Avenida Islas Malvinas y Mar del Plata', 'Parada C00171',
        st_setsrid(st_point(-59.035451, -27.445794), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11568879564, 'Isaías y Ushuaia', 'Parada C01343',
        st_setsrid(st_point(-59.034729, -27.459059), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11568879565, 'Isaías y Quito', 'Parada C01324',
        st_setsrid(st_point(-59.031947, -27.456601), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11568879566, 'Isaías y Brasilia', 'Parada C01323',
        st_setsrid(st_point(-59.029394, -27.454315), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11568879567, 'Avenida Islas Malvinas y Jeremías', 'Parada C07056',
        st_setsrid(st_point(-59.027184, -27.453395), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11568883369, 'Dos de Abril de 1982 y Avenida Mac Lean', 'Parada C02053',
        st_setsrid(st_point(-59.020856, -27.456582), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11568883370, 'Dos de Abril de 1982 y Soldado Almonacid', 'Parada C02052',
        st_setsrid(st_point(-59.019421, -27.457915), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11568883371, 'Dos de Abril de 1982 y María Sáenz de Vernet', 'Parada C07711',
        st_setsrid(st_point(-59.017991, -27.459374), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11568883372, 'Misionero Klein y Luis Vernet', 'Parada C07713',
        st_setsrid(st_point(-59.016816, -27.457562), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11568883373, 'López Vicuña y Capitán Pedro Giachino', 'Parada C02047',
        st_setsrid(st_point(-59.013507, -27.458120), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11568883374, 'Capitán Pedro Giachino y Luis Vernet', 'Parada C02004',
        st_setsrid(st_point(-59.014754, -27.459436), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11568883375, 'Monseñor Alumni y Capitán Pedro Giachino', 'Parada C07716',
        st_setsrid(st_point(-59.016263, -27.460945), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11568883376, 'Avenida Hernandarias y Jorge Rafael Obligado', 'Parada C01838',
        st_setsrid(st_point(-59.013885, -27.462872), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11568883377, 'Avenida Hernandarias y Ricardo Rojas', 'Parada C01837',
        st_setsrid(st_point(-59.011525, -27.460773), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11568883378, 'Avenida Hernandarias y Miguel Cané', 'Parada C01836',
        st_setsrid(st_point(-59.009639, -27.459077), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11568883379, 'Avenida Hernandarias y Avenida Marconi', 'Parada C02044',
        st_setsrid(st_point(-59.007797, -27.457431), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11568883380, 'Carlos Gardel y Avenida Hernandarias', 'Parada C01315',
        st_setsrid(st_point(-59.005550, -27.455701), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11568883381, 'Avenida Belgrano y Carlos Gardel', 'Parada C00685',
        st_setsrid(st_point(-59.002849, -27.457884), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11568883382, 'Avenida Belgrano y Nicolás Roldán', 'Parada C00684',
        st_setsrid(st_point(-59.001213, -27.456419), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11568883383, 'Avenida Belgrano y Felipe Molina', 'Parada C00683',
        st_setsrid(st_point(-58.999565, -27.454952), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11568883385, 'Avenida Belgrano y Jujuy', 'Parada C00682',
        st_setsrid(st_point(-58.996037, -27.451784), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11568883386, 'Avenida Italia e Hipólito Yrigoyen', 'Parada C01276',
        st_setsrid(st_point(-58.981108, -27.454029), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11568883388, 'Avenida Italia y Córdoba', 'Parada C01313',
        st_setsrid(st_point(-58.975899, -27.449365), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11568883392, 'Avenida Sarmiento y Mauricio Feldman', 'Parada C01309',
        st_setsrid(st_point(-58.973044, -27.438919), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11568883393, 'Avenida Padre Rissione y Avenida Sarmiento', 'Parada C07729',
        st_setsrid(st_point(-58.972080, -27.438434), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11568883394, 'Avenida Padre Rissione y Pellegrini', 'Parada C07728',
        st_setsrid(st_point(-58.970360, -27.439948), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11568883395, 'Avenida Padre Rissione y French', 'Parada C07727',
        st_setsrid(st_point(-58.968982, -27.441147), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11568883396, 'Avenida Italia y Rotonda Italia y Rissione', 'Parada C07726',
        st_setsrid(st_point(-58.967670, -27.441943), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11568883397, 'Avenida Italia y Estefanía Zelaya de González', 'Parada C07725',
        st_setsrid(st_point(-58.966397, -27.440805), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11568883398, 'Avenida Italia y Celmira Gonzevat de Cabral', 'Parada C07724',
        st_setsrid(st_point(-58.964396, -27.439016), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11568883399, 'Avenida Italia y Australia', 'Parada C07723',
        st_setsrid(st_point(-58.963533, -27.438244), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11568883400, 'Avenida Italia y Canadá', 'Parada C07722',
        st_setsrid(st_point(-58.962574, -27.437405), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11568883401, 'Avenida Italia y Suiza', 'Parada C07721',
        st_setsrid(st_point(-58.961199, -27.436177), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11568883402, 'Combate de la Vuelta de Obligado y Avenida Sarmiento', 'Parada C01331',
        st_setsrid(st_point(-58.964956, -27.432106), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11571486260, 'Avenida Rivadavia y Santiago de Liniers', 'Parada C03030',
        st_setsrid(st_point(-58.985432, -27.444169), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11572819643, 'Avenida Sarmiento y México', 'Parada C01330',
        st_setsrid(st_point(-58.968918, -27.435441), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11572819644, 'Avenida Sarmiento y Rodolfo Gabardini', 'Parada C01329',
        st_setsrid(st_point(-58.973215, -27.439295), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11572819645, 'Avenida Sarmiento y Alice Le Saige', 'Parada C07004',
        st_setsrid(st_point(-58.976041, -27.441827), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11572819646, 'Doctor Alfredo Reggiardo y Avenida Sarmiento', 'Parada C07720',
        st_setsrid(st_point(-58.976616, -27.442584), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11572819647, 'Doctor Alfredo Reggiardo y Pellegrini', 'Parada C07719',
        st_setsrid(st_point(-58.974903, -27.444115), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11572819648, 'Doctor Alfredo Reggiardo y Avenida Italia', 'Parada C07718',
        st_setsrid(st_point(-58.972230, -27.446491), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11572819649, 'Monteagudo y Sargento Cabral', 'Parada C01303',
        st_setsrid(st_point(-58.973427, -27.448814), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11572819650, 'Avenida Italia y Avenida Laprida', 'Parada C01263',
        st_setsrid(st_point(-58.975315, -27.448974), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11572819651, 'Avenida Italia y Don Bosco', 'Parada C01262',
        st_setsrid(st_point(-58.979656, -27.452885), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11572819652, 'Avenida Belgrano y Mendoza', 'Parada C01257',
        st_setsrid(st_point(-58.997123, -27.452922), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11572819653, 'Avenida Belgrano y Avenida Carlos María de Alvear', 'Parada C00658',
        st_setsrid(st_point(-58.998136, -27.453831), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11572819654, 'Avenida Belgrano y Felipe Molina', 'Parada C00657',
        st_setsrid(st_point(-58.999699, -27.455230), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11572819655, 'Avenida Belgrano y Nicolás Roldán', 'Parada C00656',
        st_setsrid(st_point(-59.001338, -27.456688), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11572819657, 'Avenida Hernandarias y Carlos Gardel', 'Parada C01762',
        st_setsrid(st_point(-59.005728, -27.455729), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11572819658, 'Avenida Hernandarias y Avenida Marconi', 'Parada C01761',
        st_setsrid(st_point(-59.008050, -27.457811), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11572819659, 'Avenida Hernandarias y Martín Coronado', 'Parada C01760',
        st_setsrid(st_point(-59.010756, -27.460240), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11572819660, 'Avenida Hernandarias y Alfredo Veiravé', 'Parada C01759',
        st_setsrid(st_point(-59.012954, -27.462211), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11572819661, 'Capitán Pedro Giachino y Dos de Abril de 1982', 'Parada C02049',
        st_setsrid(st_point(-59.016098, -27.460638), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11572819664, 'Misionero Klein y López Vicuña', 'Parada C07714',
        st_setsrid(st_point(-59.015598, -27.456484), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11572819665, 'María Sáenz de Vernet y Luis Vernet', 'Parada C07712',
        st_setsrid(st_point(-59.016430, -27.458426), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11572819666, 'Dos de Abril de 1982 y María Sáenz de Vernet', 'Parada C07710',
        st_setsrid(st_point(-59.018275, -27.459255), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11572819667, 'Dos de Abril de 1982 y Soldado Almonacid', 'Parada C07709',
        st_setsrid(st_point(-59.019552, -27.457738), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11572819668, 'Cristófani y Avenida Mac Lean', 'Parada C07708',
        st_setsrid(st_point(-59.021236, -27.456356), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11572838469, 'Fray Bertaca y Avenida Islas Malvinas', 'Parada C01322',
        st_setsrid(st_point(-59.025892, -27.454248), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11572838470, 'Isaías y Montevideo', 'Parada C01290',
        st_setsrid(st_point(-59.030559, -27.455346), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11572838471, 'Isaías y Quito', 'Parada C01289',
        st_setsrid(st_point(-59.032221, -27.456839), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11576284064, 'Fray Bertaca y Francisco Ptak', 'Parada C02343',
        st_setsrid(st_point(-59.025469, -27.453866), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11576284065, 'Cristófani y General Mansilla', 'Parada C07749',
        st_setsrid(st_point(-59.022630, -27.455130), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11576284066, 'Juan José Paso y Avenida Mac Lean', 'Parada C07747',
        st_setsrid(st_point(-59.018084, -27.454067), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11576284067, 'Avenida Arturo Jauretche y Manuel Alberti', 'Parada C01319',
        st_setsrid(st_point(-59.014986, -27.452298), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11576284068, 'Carlos Tejedor y Pasaje Vecinal Miguel Soler', 'Parada C07745',
        st_setsrid(st_point(-59.014775, -27.447466), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11576335869, 'Juan B. Azopardo y Pasaje Vecinal M. Rodríguez', 'Parada C02335',
        st_setsrid(st_point(-59.013011, -27.447014), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11576335870, 'Carlos Gardel y Fray Rossi', 'Parada C01317',
        st_setsrid(st_point(-59.011896, -27.450063), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11576335872, 'Avenida Belgrano y Comandante Fontana', 'Parada C01281',
        st_setsrid(st_point(-59.000373, -27.455680), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11576335873, 'Avenida Belgrano y Mendoza', 'Parada C01280',
        st_setsrid(st_point(-58.996852, -27.452537), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11576335874, 'Avenida Italia y Juan Ramón Lestani', 'Parada C01312',
        st_setsrid(st_point(-58.973188, -27.446916), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11576335875, 'Avenida Italia y Alice Le Saige', 'Parada C01273',
        st_setsrid(st_point(-58.971496, -27.445397), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11576335876, 'Avenida Italia y Asunción', 'Parada C07730',
        st_setsrid(st_point(-58.969816, -27.443862), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11580325112, 'Monteagudo y Rita Agote de Sustaita', 'Parada C01305',
        st_setsrid(st_point(-58.966446, -27.442565), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11580325113, 'Monteagudo y Asunción', 'Parada C01304',
        st_setsrid(st_point(-58.969111, -27.444944), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11580325114, 'Avenida Belgrano y Comandante Fontana', 'Parada C01256',
        st_setsrid(st_point(-59.000529, -27.455969), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11580325117, 'Carlos Gardel y Fray Rossi', 'Parada C01298',
        st_setsrid(st_point(-59.012167, -27.449821), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11580325118, 'Carlos Tejedor y Pasaje Vecinal I. Álvarez Toma', 'Parada C01297',
        st_setsrid(st_point(-59.014444, -27.447456), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11580325120, 'Avenida Marconi y Álvarez Jonte', 'Parada C01296',
        st_setsrid(st_point(-59.017474, -27.449058), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11580325121, 'Avenida Arturo Jauretche y Miguel de Azcuénaga', 'Parada C01295',
        st_setsrid(st_point(-59.014845, -27.451834), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11580325122, 'Avenida Arturo Jauretche y 20 de Junio', 'Parada C01294',
        st_setsrid(st_point(-59.014971, -27.453147), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11580325123, 'Avenida Arturo Jauretche y Martín de Álzaga', 'Parada C01293',
        st_setsrid(st_point(-59.015656, -27.454735), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11580325126, 'Juan José Paso y Tierra del Fuego', 'Parada C07746',
        st_setsrid(st_point(-59.017280, -27.456271), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11580325127, 'Avenida Islas Malvinas y Fray Bertaca', 'Parada C02251',
        st_setsrid(st_point(-59.026230, -27.454152), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11586752338, 'Avenida Islas Malvinas y Avenida Mac Lean', 'Parada C03269',
        st_setsrid(st_point(-59.022078, -27.457768), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11586752339, 'Avenida Islas Malvinas y María Sáenz de Vernet', 'Parada C02051',
        st_setsrid(st_point(-59.019088, -27.460416), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11586752341, 'Avenida Islas Malvinas y Echeverría', 'Parada C01757',
        st_setsrid(st_point(-59.013634, -27.465299), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11586752342, 'Avenida Belgrano y Julio Cortázar', 'Parada C01283',
        st_setsrid(st_point(-59.011413, -27.465584), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11586752343, 'Avenida Belgrano y Lavardén', 'Parada C02584',
        st_setsrid(st_point(-59.009671, -27.464018), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11586752344, 'Avenida Belgrano y Enrique Larreta', 'Parada C02583',
        st_setsrid(st_point(-59.008316, -27.462815), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11586752345, 'Avenida Belgrano y Falucho', 'Parada C00687',
        st_setsrid(st_point(-59.005958, -27.460691), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11586752346, 'Avenida Alberdi y Avenida Marconi', 'Parada C00600',
        st_setsrid(st_point(-59.000653, -27.463743), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11586752347, 'Avenida Alberdi y Nicolás Roldán', 'Parada C02529',
        st_setsrid(st_point(-58.996785, -27.460271), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11586752348, 'Avenida Alberdi y Carlos Gardel', 'Parada C02530',
        st_setsrid(st_point(-58.998460, -27.461765), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11586752349, 'Avenida Alberdi y Felipe Molina', 'Parada C00597',
        st_setsrid(st_point(-58.995222, -27.458842), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11586752350, 'Avenida Alberdi y Avenida Juan José Castelli', 'Parada C02330',
        st_setsrid(st_point(-58.993348, -27.457194), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11586752354, 'Avenida Sarmiento y Manuel Lisandro Peralta', 'Parada C01270',
        st_setsrid(st_point(-58.971282, -27.437336), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11586752355, 'Avenida Sarmiento y Aldo Boglietti', 'Parada C01340',
        st_setsrid(st_point(-58.969606, -27.435829), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11586752723, 'Avenida Sarmiento', 'Parada C01269',
        st_setsrid(st_point(-58.967797, -27.434208), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11586752728, 'Avenida Sarmiento y Combate de la Vuelta de Obligado', 'Parada C01339',
        st_setsrid(st_point(-58.964986, -27.431733), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11586752729, 'Gobernador Rolando Tauguinas y Avenida Sarmiento', 'Parada C01338',
        st_setsrid(st_point(-58.956610, -27.422746), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11590192509, 'Gobernador Rolando Tauguinas y Autovía Nicolás Avellaneda', 'Parada C01333',
        st_setsrid(st_point(-58.951360, -27.423801), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11590192510, 'Avenida Sarmiento y Gobernador Rolando Tauguinas', 'Parada C01332',
        st_setsrid(st_point(-58.957731, -27.423001), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11590192515, 'Avenida Alberdi y Avenida Carlos María de Alvear', 'Parada C00530',
        st_setsrid(st_point(-58.993717, -27.457692), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11590192516, 'Avenida Alberdi y Carlos Boggio', 'Parada C00529',
        st_setsrid(st_point(-58.995478, -27.459257), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11590192517, 'Avenida Alberdi y Carlos Dodero', 'Parada C00528',
        st_setsrid(st_point(-58.997339, -27.460930), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11590192518, 'Avenida Alberdi y Seitor', 'Parada C00527',
        st_setsrid(st_point(-58.999152, -27.462544), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11590192519, 'Avenida Marconi y Avenida Alberdi', 'Parada C07736',
        st_setsrid(st_point(-59.000968, -27.463829), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11590192520, 'Avenida Marconi y Santa María de Oro', 'Parada C07735',
        st_setsrid(st_point(-59.001847, -27.463036), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11590192521, 'Avenida Belgrano y Avenida Marconi', 'Parada C07734',
        st_setsrid(st_point(-59.005298, -27.460261), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11590192522, 'Avenida Belgrano y Enrique Larreta', 'Parada C00651',
        st_setsrid(st_point(-59.008443, -27.463074), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11590192523, 'Avenida Belgrano y Pedro Freschi', 'Parada C00650',
        st_setsrid(st_point(-59.009776, -27.464263), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11590192524, 'Avenida Belgrano y Julio Cortázar', 'Parada C01254',
        st_setsrid(st_point(-59.011510, -27.465823), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11591414372, 'Avenida Soberanía Nacional y Avenida España', 'Parada C02558',
        st_setsrid(st_point(-58.972255, -27.502227), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11591414373, 'Avenida Arribálzaga y Avenida Soberanía Nacional', 'Parada C03076',
        st_setsrid(st_point(-58.979042, -27.495707), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11591414374, 'Avenida Arribálzaga y Fortín Los Pozos', 'Parada C07042',
        st_setsrid(st_point(-58.977521, -27.494345), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11591414375, 'Fortín Aguilar y Avenida Arribálzaga', 'Parada C03073',
        st_setsrid(st_point(-58.976498, -27.493093), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11591414376, 'Fortín Aguilar y Luis O. Gusberti', 'Parada C03072',
        st_setsrid(st_point(-58.977396, -27.492303), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11591414377, 'Fortín Aguilar y Roger Balet', 'Parada C03071',
        st_setsrid(st_point(-58.978226, -27.491563), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11591414378, 'Fortín Aguilar y Tránsito Cocomarola', 'Parada C03070',
        st_setsrid(st_point(-58.980115, -27.489871), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11591414380, 'Marcos Briolini y Fortín Aguilar', 'Parada C03069',
        st_setsrid(st_point(-58.981361, -27.488946), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11591414384, 'Marcos Briolini y Fortín Los Pozos', 'Parada C03068',
        st_setsrid(st_point(-58.982769, -27.490210), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11591414385, 'Avenida Soberanía Nacional y Capataz Codutti', 'Parada C00618',
        st_setsrid(st_point(-58.985077, -27.490757), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11591414387, 'Avenida Soberanía Nacional y Miguel Z. Delfino', 'Parada C00616',
        st_setsrid(st_point(-58.988354, -27.487850), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11591414390, 'Soldado Aguilera y Adelina Del Carril', 'Parada C01592',
        st_setsrid(st_point(-58.989406, -27.483078), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11591414391, 'Soldado Aguilera y Don Segundo Sombra', 'Parada C03150',
        st_setsrid(st_point(-58.989561, -27.482125), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11591414392, 'Soldado Aguilera y Avenida Chaco', 'Parada C00612',
        st_setsrid(st_point(-58.989785, -27.480751), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11591414393, 'Avenida Chaco y Soldado Aguilera', 'Parada C03066',
        st_setsrid(st_point(-58.989824, -27.479631), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11591414394, 'Avenida Chaco y Fortín Warnes', 'Parada C03065',
        st_setsrid(st_point(-58.987347, -27.477410), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11591414395, 'Avenida Édison y Julio Tort', 'Parada C01588',
        st_setsrid(st_point(-58.987577, -27.475785), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11591414396, 'Avenida Édison y Gobernador Gabriel Carrasco', 'Parada C01587',
        st_setsrid(st_point(-58.989479, -27.474106), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11591414397, 'Avenida Édison y Thomas Jefferson', 'Parada C01586',
        st_setsrid(st_point(-58.991210, -27.472572), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11591414398, 'Los Hacheros y Pasaje Édison', 'Parada C03302',
        st_setsrid(st_point(-58.991791, -27.471590), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11591414399, 'Doctor Evaristo Ramírez y Pasaje José María Toledo', 'Parada C07707',
        st_setsrid(st_point(-58.988781, -27.469049), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11591414400, 'Doctor Evaristo Ramírez y Arturo Lestani', 'Parada C03300',
        st_setsrid(st_point(-58.985304, -27.468631), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11591414401, 'Avenida Juan José Castelli y Doctor Evaristo Ramírez', 'Parada C03299',
        st_setsrid(st_point(-58.982732, -27.467204), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11591414402, 'Avenida Juan José Castelli', 'Parada C03298',
        st_setsrid(st_point(-58.984793, -27.465385), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11591414403, 'Avenida Las Heras y Cervantes', 'Parada C07706',
        st_setsrid(st_point(-58.985984, -27.463211), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11591414404, 'Avenida Las Heras y Franklin', 'Parada C03056',
        st_setsrid(st_point(-58.984506, -27.461889), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11591414406, 'Avenida Lavalle y Santiago de Liniers', 'Parada C03031',
        st_setsrid(st_point(-58.983235, -27.441658), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11591414407, 'Avenida Lavalle y Posadas', 'Parada C00546',
        st_setsrid(st_point(-58.984993, -27.440071), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11591414409, 'Avenida Lavalle y Concepción del Bermejo', 'Parada C03049',
        st_setsrid(st_point(-58.988424, -27.436776), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11591414410, 'Avenida Lavalle y La Cangayé', 'Parada C03048',
        st_setsrid(st_point(-58.990380, -27.435042), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11591414411, 'Avenida Lavalle y Raúl B. Díaz', 'Parada C03047',
        st_setsrid(st_point(-58.992124, -27.433499), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11591414412, 'Avenida Lavalle y Coronel Falcón', 'Parada C03046',
        st_setsrid(st_point(-58.993863, -27.431951), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11591414413, 'Avenida Lavalle y Sicas', 'Parada C03045',
        st_setsrid(st_point(-58.995760, -27.430276), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11591414414, 'Agustín Andreani y Avenida Lavalle', 'Parada C03296',
        st_setsrid(st_point(-58.996581, -27.429766), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11591414415, 'Agustín Andreani y La Rioja', 'Parada C03122',
        st_setsrid(st_point(-58.998418, -27.431405), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11591414416, 'Pasaje Palamedi y Juan XXIII', 'Parada C03295',
        st_setsrid(st_point(-59.000250, -27.431704), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11591414417, 'Pasaje Palamedi e Irene B. de Etcheverrigaray', 'Parada C07704',
        st_setsrid(st_point(-59.000848, -27.431179), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11591414418, 'La Rioja e Irene B. de Etcheverrigaray', 'Parada C07703',
        st_setsrid(st_point(-58.999876, -27.429844), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11591414419, 'La Rioja y Ramón de las Mercedes Tissera', 'Parada C07702',
        st_setsrid(st_point(-59.001127, -27.428757), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11591414420, 'La Rioja y Nazareno Rosciani', 'Parada C07701',
        st_setsrid(st_point(-59.001926, -27.428061), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11594605667, 'Avenida Lavalle y Avenida Brigadier General Juan Manuel de Rosas', 'Parada C03041',
        st_setsrid(st_point(-59.000693, -27.425848), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11594605668, 'Avenida Lavalle y Ramón de las Mercedes Tissera', 'Parada C03040',
        st_setsrid(st_point(-58.999364, -27.427027), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11594616769, 'Avenida Lavalle e Irene B. de Etcheverrigaray', 'Parada C03039',
        st_setsrid(st_point(-58.997825, -27.428393), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11594616770, 'Avenida Lavalle y Sicas', 'Parada C03038',
        st_setsrid(st_point(-58.995446, -27.430442), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11594616771, 'Avenida Lavalle y Coronel Falcón', 'Parada C03037',
        st_setsrid(st_point(-58.993576, -27.432094), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11594616772, 'Avenida Lavalle y Raúl B. Díaz', 'Parada C03036',
        st_setsrid(st_point(-58.991772, -27.433703), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11594616773, 'Avenida Lavalle y La Cangayé', 'Parada C03035',
        st_setsrid(st_point(-58.990082, -27.435214), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11594616774, 'Avenida Lavalle y Concepción del Bermejo', 'Parada C03034',
        st_setsrid(st_point(-58.988164, -27.436906), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11594616775, 'Avenida Lavalle y Avenida Ávalos', 'Parada C03033',
        st_setsrid(st_point(-58.986165, -27.438686), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11594616777, 'Avenida Lavalle y Remedios de Escalada', 'Parada C03083',
        st_setsrid(st_point(-58.981840, -27.442545), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11594616778, 'Avenida Lavalle y Bartolomé Mitre', 'Parada C03082',
        st_setsrid(st_point(-58.980426, -27.443793), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11594616779, 'Avenida Sarmiento y Don Bosco', 'Parada C00067',
        st_setsrid(st_point(-58.983701, -27.448701), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11594616780, 'Ameghino y Avenida San Martín', 'Parada C03024',
        st_setsrid(st_point(-58.985400, -27.458267), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11594616781, 'Ameghino y San Lorenzo', 'Parada C03023',
        st_setsrid(st_point(-58.983664, -27.459837), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11594616785, 'Doctor Evaristo Ramírez y Avenida Juan José Castelli', 'Parada C03080',
        st_setsrid(st_point(-58.982718, -27.467545), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11594616787, 'Avenida Carlos López Piacentini y Doctor Evaristo Ramírez', 'Parada C03019',
        st_setsrid(st_point(-58.986900, -27.469055), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11594616788, 'Avenida Édison y Gobernador Gabriel Carrasco', 'Parada C03077',
        st_setsrid(st_point(-58.989080, -27.474277), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11594616789, 'Avenida Édison y Ernesto Duvivier', 'Parada C01509',
        st_setsrid(st_point(-58.988222, -27.475043), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11594616790, 'Avenida Chaco y Avenida Édison', 'Parada C03015',
        st_setsrid(st_point(-58.986564, -27.476886), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11594616791, 'Avenida Chaco y Favio Cáceres', 'Parada C03014',
        st_setsrid(st_point(-58.987473, -27.477686), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11594616792, 'Avenida Chaco y Fortín Alvarado', 'Parada C03013',
        st_setsrid(st_point(-58.988272, -27.478407), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11594616793, 'Soldado Aguilera y Avenida Chaco', 'Parada C03012',
        st_setsrid(st_point(-58.989837, -27.479972), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11594616794, 'Soldado Aguilera y Don Segundo Sombra', 'Parada C03011',
        st_setsrid(st_point(-58.989469, -27.482262), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11594616795, 'Soldado Aguilera y Adelina Del Carril', 'Parada C03010',
        st_setsrid(st_point(-58.989278, -27.483446), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11594616797, 'Avenida Soberanía Nacional y Pago de Areco', 'Parada C00512',
        st_setsrid(st_point(-58.989758, -27.486612), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11594616798, 'Avenida Soberanía Nacional y Miguel Z. Delfino', 'Parada C00511',
        st_setsrid(st_point(-58.988072, -27.488102), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11594616799, 'Avenida Soberanía Nacional y Avenida Urquiza', 'Parada C00510',
        st_setsrid(st_point(-58.986258, -27.489707), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11594616800, 'Marcos Briolini y Avenida Soberanía Nacional', 'Parada C03067',
        st_setsrid(st_point(-58.983992, -27.491329), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11594616801, 'Marcos Briolini y Fortín Los Pozos', 'Parada C03008',
        st_setsrid(st_point(-58.982541, -27.490009), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11594616802, 'Fortín Aguilar y Marcos Briolini', 'Parada C03007',
        st_setsrid(st_point(-58.981156, -27.488960), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11594616803, 'Fortín Aguilar y Tránsito Cocomarola', 'Parada C03006',
        st_setsrid(st_point(-58.979860, -27.490094), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11594616804, 'Fortín Aguilar y Roger Balet', 'Parada C03005',
        st_setsrid(st_point(-58.978045, -27.491725), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11594616805, 'Fortín Aguilar y Luis O. Gusberti', 'Parada C03004',
        st_setsrid(st_point(-58.977138, -27.492518), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11594616806, 'Avenida Arribálzaga y Fortín Aguilar', 'Parada C03003',
        st_setsrid(st_point(-58.976404, -27.493341), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11594616807, 'Avenida Arribálzaga y Fortín Tapenagá', 'Parada C03001',
        st_setsrid(st_point(-58.978232, -27.494995), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11594616808, 'Avenida Soberanía Nacional y Avenida Arribálzaga', 'Parada C03000',
        st_setsrid(st_point(-58.979095, -27.496042), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11594616809, 'Avenida Soberanía Nacional y Avenida España', 'Parada C03265',
        st_setsrid(st_point(-58.972266, -27.502108), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11596427200, 'Fortín Aguilar y Bibiano Meza', 'Parada C07044',
        st_setsrid(st_point(-58.978848, -27.490998), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11596427201, 'Avenida Chaco y Fortín Alvarado', 'Parada C01587',
        st_setsrid(st_point(-58.988019, -27.478023), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11596427202, 'Lisandro de la Torre y Fortín Warnes', 'Parada C03147',
        st_setsrid(st_point(-58.992013, -27.473643), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11596427203, 'Lisandro de la Torre y Fortín Loma Negra', 'Parada C03146',
        st_setsrid(st_point(-58.993715, -27.475192), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11596427205, 'Fortín Rivadavia y Los Hacheros', 'Parada C03145',
        st_setsrid(st_point(-58.995670, -27.474965), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11596427206, 'Fortín Rivadavia y Avenida Las Heras', 'Parada C03143',
        st_setsrid(st_point(-58.997399, -27.473441), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11596427207, 'Avenida San Martín y Fortín Rivadavia', 'Parada C03142',
        st_setsrid(st_point(-58.999921, -27.470896), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11596427208, 'Avenida San Martín y Seitor', 'Parada C03139',
        st_setsrid(st_point(-58.994554, -27.466086), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11596427209, 'Avenida San Martín y Carlos Dodero', 'Parada C03138',
        st_setsrid(st_point(-58.992718, -27.464443), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11596427210, 'Avenida San Martín y Carlos Boggio', 'Parada C03137',
        st_setsrid(st_point(-58.990877, -27.462793), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11596427211, 'Avenida San Martín y Avenida Juan José Castelli', 'Parada C03136',
        st_setsrid(st_point(-58.988955, -27.461067), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11596427212, 'Avenida San Martín y Franklin', 'Parada C01260',
        st_setsrid(st_point(-58.987231, -27.459538), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11596427213, 'Avenida Rivadavia y Avenida Wilde', 'Parada C03051',
        st_setsrid(st_point(-58.986791, -27.443196), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11596427215, 'Pasaje Palamedi y Agustín Andreani', 'Parada C03123',
        st_setsrid(st_point(-58.999609, -27.432267), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11596427216, 'Irene B. de Etcheverrigaray y Pasaje Palamedi', 'Parada C03124',
        st_setsrid(st_point(-59.000852, -27.430931), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11596427217, 'Irene B. de Etcheverrigaray y La Rioja', 'Parada C03125',
        st_setsrid(st_point(-58.999888, -27.430063), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11596427218, 'La Rioja y Ramón de las Mercedes Tissera', 'Parada C03126',
        st_setsrid(st_point(-59.000822, -27.429018), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11596427219, 'La Rioja y Nazareno Rosciani', 'Parada C03127',
        st_setsrid(st_point(-59.001694, -27.428264), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11596427220, 'La Rioja y Avenida Brigadier General Juan Manuel de Rosas', 'Parada C03128',
        st_setsrid(st_point(-59.002601, -27.427455), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11602247208, 'Avenida Rivadavia y Raúl B. Díaz', 'Parada C03119',
        st_setsrid(st_point(-58.994497, -27.436187), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11602247209, 'Avenida Rivadavia y La Cangayé', 'Parada C03118',
        st_setsrid(st_point(-58.992794, -27.437707), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11602247210, 'Avenida Rivadavia y Concepción del Bermejo', 'Parada C03117',
        st_setsrid(st_point(-58.990866, -27.439430), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11602247211, 'Avenida Rivadavia y Avenida Ávalos', 'Parada C03116',
        st_setsrid(st_point(-58.988939, -27.441116), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11602247212, 'Avenida Rivadavia y Posadas', 'Parada C03050',
        st_setsrid(st_point(-58.987221, -27.442649), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11602247214, 'Avenida Rivadavia y Remedios de Escalada', 'Parada C03029',
        st_setsrid(st_point(-58.984578, -27.445006), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11602247215, 'Bartolomé Mitre y Avenida Rivadavia', 'Parada C03028',
        st_setsrid(st_point(-58.982830, -27.446238), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11602247216, 'Avenida Sarmiento y Saavedra', 'Parada C03027',
        st_setsrid(st_point(-58.981380, -27.446619), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11602247217, 'Avenida San Martín y Ameghino', 'Parada C03115',
        st_setsrid(st_point(-58.985715, -27.458306), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11602247218, 'Avenida San Martín y Franklin', 'Parada C03114',
        st_setsrid(st_point(-58.987476, -27.459885), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11602247219, 'Avenida San Martín y Avenida Juan José Castelli', 'Parada C03113',
        st_setsrid(st_point(-58.989427, -27.461640), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11602247220, 'Avenida San Martín y Carlos Boggio', 'Parada C03112',
        st_setsrid(st_point(-58.991114, -27.463168), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11602247221, 'Avenida San Martín y Carlos Dodero', 'Parada C03111',
        st_setsrid(st_point(-58.992997, -27.464829), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11602247222, 'Avenida San Martín y José María Toledo', 'Parada C03110',
        st_setsrid(st_point(-58.993943, -27.465680), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11602247223, 'Avenida San Martín y Avenida Édison', 'Parada C03109',
        st_setsrid(st_point(-58.996555, -27.468030), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11602247224, 'Avenida San Martín y Fortín Alvarado', 'Parada C03108',
        st_setsrid(st_point(-58.998261, -27.469570), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11602247225, 'Fortín Rivadavia y Avenida San Martín', 'Parada C03107',
        st_setsrid(st_point(-58.999865, -27.471266), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11602247226, 'Fortín Rivadavia y Avenida Las Heras', 'Parada C03106',
        st_setsrid(st_point(-58.997085, -27.473722), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11602247228, 'Fortín Rivadavia y Los Hacheros', 'Parada C03105',
        st_setsrid(st_point(-58.995276, -27.475313), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11602247229, 'Lisandro de la Torre y Fortín Loma Negra', 'Parada C03103',
        st_setsrid(st_point(-58.993478, -27.474812), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11602247230, 'Lisandro de la Torre y Fortín Warnes', 'Parada C03102',
        st_setsrid(st_point(-58.991784, -27.473267), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11602247231, 'Avenida Édison y Julio E. Acosta', 'Parada C03101',
        st_setsrid(st_point(-58.990286, -27.473223), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11602247232, 'Pago de Areco y Soldado Aguilera', 'Parada C03100',
        st_setsrid(st_point(-58.989040, -27.485700), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11602247233, 'Avenida Soberanía Nacional y Marcos Briolini', 'Parada C00509',
        st_setsrid(st_point(-58.984343, -27.491409), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11602247234, 'Marcos Briolini y Fortín Tapenagá', 'Parada C00508',
        st_setsrid(st_point(-58.983182, -27.490588), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11602247236, 'Avenida Arribálzaga y Pasaje Fortín Aguilar', 'Parada C3002',
        st_setsrid(st_point(-58.977092, -27.493952), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11616169066, 'Avenida Lavalle y Posadas', 'Parada C03032',
        st_setsrid(st_point(-58.984522, -27.440154), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11616169067, 'Santiago de Liniers y Avenida Lavalle', 'Parada C3031',
        st_setsrid(st_point(-58.983214, -27.441973), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11616169068, 'Avenida Las Heras y Rotonda Las Heras y Castelli', 'Parada C01515',
        st_setsrid(st_point(-58.986659, -27.464087), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11616172969, 'Avenida Carlos López Piacentini y Avenida Las Heras', 'Parada C03021',
        st_setsrid(st_point(-58.987994, -27.465473), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11616172970, 'Avenida Carlos López Piacentini y Juan de Dios Mena', 'Parada C03020',
        st_setsrid(st_point(-58.987144, -27.467399), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11616172972, 'Avenida Carlos López Piacentini y Doctor Miguel María Giménez', 'Parada C03018',
        st_setsrid(st_point(-58.986582, -27.471211), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11616172973, 'Avenida Carlos López Piacentini y Julio Tort', 'Parada C03017',
        st_setsrid(st_point(-58.984561, -27.473598), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11616172977, 'Avenida Chaco y Avenida Carlos López Piacentini', 'Parada C07047',
        st_setsrid(st_point(-58.983974, -27.474501), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11619110798, 'Avenida Chaco y Avenida Édison', 'Parada C03064',
        st_setsrid(st_point(-58.986370, -27.476472), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11619110800, 'Avenida Carlos López Piacentini y Ernesto Duvivier', 'Parada C03060',
        st_setsrid(st_point(-58.986022, -27.472632), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11619110801, 'Avenida Carlos López Piacentini y Doctor Miguel María Giménez', 'Parada C03059',
        st_setsrid(st_point(-58.986908, -27.470884), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11619110802, 'Avenida Carlos López Piacentini y Doctor Evaristo Ramírez', 'Parada C03058',
        st_setsrid(st_point(-58.987232, -27.468725), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11619110805, 'Posadas y Avenida Rivadavia', 'Parada C03050',
        st_setsrid(st_point(-58.987179, -27.442344), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11622193174, 'Pago de Areco y Avenida Soberanía Nacional', 'Parada C00615',
        st_setsrid(st_point(-58.989566, -27.486165), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11622193175, 'Avenida Chaco y Avenida Carlos López Piacentini', 'Parada C06007',
        st_setsrid(st_point(-58.983672, -27.474033), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11622193176, 'Avenida Chaco y Carlos Boggio', 'Parada C06006',
        st_setsrid(st_point(-58.980930, -27.471589), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11622193177, 'Avenida Chaco y Avenida Rodríguez Peña', 'Parada C06005',
        st_setsrid(st_point(-58.976641, -27.467845), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11622193178, 'Avenida Chaco y General Obligado', 'Parada C06004',
        st_setsrid(st_point(-58.974626, -27.466036), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11622193179, 'Juan B. Justo y Avenida Chaco', 'Parada C06030',
        st_setsrid(st_point(-58.973265, -27.464480), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11622193180, 'Juan B. Justo y Ernesto Duvivier', 'Parada C06003',
        st_setsrid(st_point(-58.975161, -27.462797), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11622193181, 'Juan B. Justo y Lisandro de la Torre', 'Parada C06002',
        st_setsrid(st_point(-58.977781, -27.460469), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11622193183, 'Avenida Carlos María de Alvear y General Vedia', 'Parada C01576',
        st_setsrid(st_point(-58.995589, -27.455817), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11622193184, 'Avenida Carlos María de Alvear y General Dónovan', 'Parada C06001',
        st_setsrid(st_point(-58.997314, -27.454274), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11622193185, 'Avenida Carlos María de Alvear y General Uriburu', 'Parada C01074',
        st_setsrid(st_point(-59.009086, -27.443870), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11622193186, 'Guaycurú y Toba', 'Parada C01073',
        st_setsrid(st_point(-59.012217, -27.441515), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11622193187, 'Isabel la Católica y Leopoldo Martín', 'Parada C01072',
        st_setsrid(st_point(-59.016399, -27.443256), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11622193190, 'Fray Bertaca y Jericó', 'Parada C02255',
        st_setsrid(st_point(-59.020792, -27.449664), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11622193193, 'Avenida de la Democracia y Avenida Islas Malvinas', 'Parada C01071',
        st_setsrid(st_point(-59.029278, -27.451915), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11622193194, 'Avenida de la Democracia y Montevideo', 'Parada C01070',
        st_setsrid(st_point(-59.031802, -27.454206), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11622193195, 'Avenida de la Democracia y Panamá', 'Parada C01069',
        st_setsrid(st_point(-59.035090, -27.457163), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11622193196, 'Avenida de la Democracia y Ushuaia', 'Parada C00094',
        st_setsrid(st_point(-59.035981, -27.457927), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11626627888, 'Fray Bertaca y Juan Godoy', 'Parada C02342',
        st_setsrid(st_point(-59.023896, -27.452447), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11626627891, 'Isabel la Católica y Deán Funes', 'Parada C06027',
        st_setsrid(st_point(-59.017110, -27.446179), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11626627892, 'Isabel la Católica y Fray Pérez de Marchena', 'Parada C06026',
        st_setsrid(st_point(-59.017087, -27.443725), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11626627893, 'La Rábida e Isabel la Católica', 'Parada C06025',
        st_setsrid(st_point(-59.016355, -27.441745), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11626627894, 'Carlos Campia y Toba', 'Parada C06024',
        st_setsrid(st_point(-59.013590, -27.440730), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11626627895, 'Avenida Carlos María de Alvear y Fray Bertaca', 'Parada C01528',
        st_setsrid(st_point(-59.011334, -27.441692), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11626627897, 'Avenida Carlos María de Alvear y Fray Rossi', 'Parada C01526',
        st_setsrid(st_point(-59.006924, -27.445598), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11626627900, 'Avenida Carlos María de Alvear y Avenida Belgrano', 'Parada C01521',
        st_setsrid(st_point(-58.997657, -27.453649), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11626627901, 'Avenida Carlos María de Alvear y Necochea', 'Parada C02331',
        st_setsrid(st_point(-58.995900, -27.455231), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11626627902, 'Arturo Umberto Illia y Avenida San Martín', 'Parada C06019',
        st_setsrid(st_point(-58.983650, -27.456788), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11626627903, 'Arturo Umberto Illia y Juan de Dios Mena', 'Parada C06018',
        st_setsrid(st_point(-58.980071, -27.459962), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11626627904, 'Arturo Umberto Illia y Gobernador Gabriel Carrasco', 'Parada C06017',
        st_setsrid(st_point(-58.976572, -27.463066), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11626627905, 'Arturo Umberto Illia y Julio Tort', 'Parada C07620',
        st_setsrid(st_point(-58.974850, -27.464594), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11626627906, 'Avenida Chaco y General Obligado', 'Parada C06016',
        st_setsrid(st_point(-58.974888, -27.466358), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11626627907, 'Avenida Chaco y Franklin', 'Parada C06015',
        st_setsrid(st_point(-58.977362, -27.468578), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11626627908, 'Avenida Juan José Castelli e Ingeniero Luis Fousal', 'Parada C06014',
        st_setsrid(st_point(-58.978536, -27.470831), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11626627909, 'Avenida Juan José Castelli y Martín Goitía', 'Parada C06013',
        st_setsrid(st_point(-58.975448, -27.473585), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11626627910, 'Avenida Urquiza y Carlos Boggio', 'Parada C06011',
        st_setsrid(st_point(-58.973981, -27.478349), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11626627911, 'Avenida Urquiza y José María Toledo', 'Parada C06010',
        st_setsrid(st_point(-58.976794, -27.480896), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11626627912, 'Avenida Urquiza y Avenida Édison', 'Parada C06009',
        st_setsrid(st_point(-58.979368, -27.483226), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11626627913, 'Avenida Urquiza y Fortín Loma Negra', 'Parada C01503',
        st_setsrid(st_point(-58.981701, -27.485330), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11626627914, 'Avenida Urquiza y Fortín Aguilar', 'Parada C06008',
        st_setsrid(st_point(-58.983599, -27.487019), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11629375270, 'Avenida Urquiza y Fortín Aguilar', 'Parada C07770',
        st_setsrid(st_point(-58.983440, -27.486745), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11629375271, 'Avenida Urquiza y Fortín Loma Negra', 'Parada C07769',
        st_setsrid(st_point(-58.981556, -27.485072), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11629375272, 'Avenida Urquiza y Avenida Édison', 'Parada C07768',
        st_setsrid(st_point(-58.979115, -27.482861), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11629375273, 'Avenida Urquiza y José María Toledo', 'Parada C07767',
        st_setsrid(st_point(-58.976591, -27.480582), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11629375274, 'Avenida Urquiza y Carlos Boggio', 'Parada C07765',
        st_setsrid(st_point(-58.973737, -27.478017), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11629375275, 'Avenida Juan José Castelli e Ingeniero Augusto Schur', 'Parada C06252',
        st_setsrid(st_point(-58.973198, -27.475679), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11629375276, 'Avenida Juan José Castelli y Martín Goitía', 'Parada C06251',
        st_setsrid(st_point(-58.975769, -27.473405), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11629375277, 'Avenida Juan José Castelli y Ángel Busto', 'Parada C06250',
        st_setsrid(st_point(-58.978353, -27.471090), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11640593139, 'Avenida Chaco y Ameghino', 'Parada C02314',
        st_setsrid(st_point(-58.975703, -27.467099), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11640593140, 'Avenida Chaco y Avenida Juan José Castelli', 'Parada C06514',
        st_setsrid(st_point(-58.979397, -27.470391), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11640593142, 'Avenida Chaco y Carlos Dodero', 'Parada C06512',
        st_setsrid(st_point(-58.983031, -27.473650), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11640593143, 'Soldado Aguilera y Don Segundo Sombra', 'Parada C00514',
        st_setsrid(st_point(-58.989637, -27.481214), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11645131358, 'Avenida Juan José Castelli y Tránsito Cocomarola', 'Parada C02306',
        st_setsrid(st_point(-58.968571, -27.479665), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11645131359, 'Deán Funes e Isabel la Católica', 'Parada C02338',
        st_setsrid(st_point(-59.016848, -27.446140), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11645131362, 'Avenida Mac Lean y Lautaro', 'Parada C07051',
        st_setsrid(st_point(-59.008570, -27.445110), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11645131363, 'Avenida Mac Lean y Jujuy', 'Parada C07050',
        st_setsrid(st_point(-59.006106, -27.442907), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11645131365, 'Santiago del Estero y Misionero Klein', 'Parada C06517',
        st_setsrid(st_point(-59.001539, -27.443986), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11645131367, 'Santiago del Estero y Cangallo', 'Parada C02038',
        st_setsrid(st_point(-58.995957, -27.448910), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11645131368, 'Marcelino Castelán y Carlos Boggio', 'Parada C06263',
        st_setsrid(st_point(-58.969828, -27.482005), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11645192669, 'Marcelino Castelán y Pasaje Carlos Dodero', 'Parada C06262',
        st_setsrid(st_point(-58.972130, -27.484086), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11645192670, 'Marcelino Castelán y Fortín Cardozo', 'Parada C06261',
        st_setsrid(st_point(-58.973935, -27.485698), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11645192671, 'Fortín Piris y Marcelino Castelán', 'Parada C06260',
        st_setsrid(st_point(-58.976577, -27.487639), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11645192672, 'Doctor Antonio de Grandi y Fortín Piris', 'Parada C06259',
        st_setsrid(st_point(-58.977926, -27.486694), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11645192673, 'Fortín Rivadavia y Doctor Antonio de Grandi', 'Parada C06258',
        st_setsrid(st_point(-58.979743, -27.488561), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11645192674, 'Bibiano Meza y Fortín Rivadavia', 'Parada C06508',
        st_setsrid(st_point(-58.978171, -27.490182), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11645192675, 'Fortín Los Pozos y Bibiano Meza', 'Parada C06507',
        st_setsrid(st_point(-58.980265, -27.492232), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11645192676, 'Fortín Los Pozos y Roger Balet', 'Parada C07043',
        st_setsrid(st_point(-58.979359, -27.493024), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11645192677, 'Fortín Los Pozos y Luis O. Gusberti', 'Parada 06506',
        st_setsrid(st_point(-58.978492, -27.493792), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11648852773, 'Marcelino Castelán y Avenida Édison', 'Parada C06256',
        st_setsrid(st_point(-58.974988, -27.486633), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11648852774, 'Avenida Arribálzaga y Fortín Tapenagá', 'Parada C03075',
        st_setsrid(st_point(-58.978004, -27.494788), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11648852775, 'Avenida Arribálzaga y Pasaje Fortín Aguilar', 'Parada C06257',
        st_setsrid(st_point(-58.976812, -27.493701), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11648852776, 'Avenida Arribálzaga y Fortín Rivadavia', 'Parada C07041',
        st_setsrid(st_point(-58.975184, -27.492237), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11648852777, 'Avenida Édison y Avenida Arribálzaga', 'Parada C06504',
        st_setsrid(st_point(-58.972325, -27.489250), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11648852778, 'Avenida Édison y Roger Balet', 'Parada C07040',
        st_setsrid(st_point(-58.973990, -27.487811), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11648852779, 'Marcelino Castelán y Carlos Dodero', 'Parada C06255',
        st_setsrid(st_point(-58.971331, -27.483364), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11648852780, 'Marcelino Castelán y Carlos Boggio', 'Parada C06254',
        st_setsrid(st_point(-58.969470, -27.481697), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11648852781, 'Avenida Juan José Castelli y Doctor Antonio de Grandi', 'Parada C06253',
        st_setsrid(st_point(-58.969663, -27.478793), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11648852782, 'Avenida Chaco y Cervantes', 'Parada C06005',
        st_setsrid(st_point(-58.978046, -27.469105), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11648852784, 'General Obligado y Avenida Las Heras', 'Parada C02271',
        st_setsrid(st_point(-58.982268, -27.459545), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11648852785, 'General Obligado y San Lorenzo', 'Parada C02270',
        st_setsrid(st_point(-58.983196, -27.458712), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11648852786, 'Avenida Mac Lean y Salta', 'Parada C07036',
        st_setsrid(st_point(-59.003606, -27.440864), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11648852787, 'Avenida Mac Lean y Jujuy', 'Parada C07035',
        st_setsrid(st_point(-59.006268, -27.443250), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11648852788, 'Avenida Mac Lean y Avenida Carlos María de Alvear', 'Parada C00026',
        st_setsrid(st_point(-59.008143, -27.444950), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11648852789, 'Avenida Mac Lean y Libertad', 'Parada C06501',
        st_setsrid(st_point(-59.009198, -27.445883), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11648852790, 'Avenida Mac Lean y Los Andes', 'Parada C02261',
        st_setsrid(st_point(-59.010237, -27.446830), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11652450384, 'Fray Bertaca y Hermanos Boronat', 'Parada C06028',
        st_setsrid(st_point(-59.022041, -27.450780), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11652450385, 'Fray Bertaca y Jericó', 'Parada C02340',
        st_setsrid(st_point(-59.020500, -27.449407), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11652450386, 'Avenida Mac Lean y Libertador', 'Parada C07052',
        st_setsrid(st_point(-59.010940, -27.447268), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11652450387, 'Avenida Chaco y Pasaje Carlos Boggio', 'Parada C07048',
        st_setsrid(st_point(-58.981235, -27.472059), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11652450388, 'Avenida Édison y Avenida Chaco', 'Parada C01508',
        st_setsrid(st_point(-58.986315, -27.476774), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11652450389, 'Avenida Édison y Avenida Urquiza', 'Parada C07046',
        st_setsrid(st_point(-58.979107, -27.483149), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11652450391, 'Avenida Édison y Doctor Antonio de Grandi', 'Parada C06510',
        st_setsrid(st_point(-58.976573, -27.485415), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11652450392, 'Marcelino Castelán y Fortín Piris', 'Parada C06509',
        st_setsrid(st_point(-58.976658, -27.487898), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11652450393, 'Fortín Rivadavia y Marcelino Castelán', 'Parada C07045',
        st_setsrid(st_point(-58.978440, -27.489715), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11652450394, 'Bibiano Meza y Fortín Aguilar', 'Parada C07044',
        st_setsrid(st_point(-58.979080, -27.491003), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11655881335, 'Avenida Édison y Marcelino Castelán', 'Parada C07039',
        st_setsrid(st_point(-58.975399, -27.486566), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11655881336, 'Avenida Édison y Capataz Codutti', 'Parada C00623',
        st_setsrid(st_point(-58.978047, -27.484244), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11655881337, 'Avenida Édison y Avenida Urquiza', 'Parada C07038',
        st_setsrid(st_point(-58.979461, -27.482985), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11655881338, 'Avenida Édison y Martín Goitía', 'Parada C06503',
        st_setsrid(st_point(-58.982886, -27.479969), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11655881339, 'Avenida Las Heras y Arturo Umberto Illia', 'Parada C02272',
        st_setsrid(st_point(-58.981277, -27.459238), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11655881340, 'Fray Bertaca y Hermanos Boronat', 'Parada C02254',
        st_setsrid(st_point(-59.022432, -27.451129), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11663408371, 'Uruguay y Pasaje Santiago del Estero', 'Parada C01631',
        st_setsrid(st_point(-59.039433, -27.411599), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11663408372, 'Uruguay y Pasaje Santiago del Estero', 'Parada C01683',
        st_setsrid(st_point(-59.039289, -27.411470), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11664987748, 'Capataz Codutti y Avenida Juan José Castelli', 'Parada C07758',
        st_setsrid(st_point(-58.970493, -27.478251), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11664987749, 'Ángela C. de Bouvier y José Mármol', 'Parada C07757',
        st_setsrid(st_point(-58.973967, -27.479833), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11664987750, 'Ángela C. de Bouvier y José María Toledo', 'Parada C00626',
        st_setsrid(st_point(-58.975965, -27.481632), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11664987751, 'Ángela C. de Bouvier y Carlos Hardy', 'Parada C00625',
        st_setsrid(st_point(-58.977606, -27.483087), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11664987752, 'Capataz Codutti y Avenida Édison', 'Parada C00623',
        st_setsrid(st_point(-58.978039, -27.484456), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11664987753, 'Capataz Codutti y Fortín Piris', 'Parada C07756',
        st_setsrid(st_point(-58.979059, -27.485611), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11664987754, 'Capataz Codutti y Fortín Loma Negra', 'Parada C07754',
        st_setsrid(st_point(-58.980214, -27.486667), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11664987756, 'Capataz Codutti y Fortín Los Pozos', 'Parada C07750',
        st_setsrid(st_point(-58.983491, -27.489597), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11664987757, 'Capataz Codutti y Fortín Aguilar', 'Parada C07752',
        st_setsrid(st_point(-58.982085, -27.488344), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11664987758, 'Avenida Chaco y Fortín Los Pozos', 'Parada C00610',
        st_setsrid(st_point(-58.991906, -27.481675), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11664987759, 'Avenida Soberanía Nacional y Avenida Chaco', 'Parada C00609',
        st_setsrid(st_point(-58.993823, -27.482846), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11664987760, 'Avenida Soberanía Nacional y Lisandro de la Torre', 'Parada C00608',
        st_setsrid(st_point(-58.998311, -27.478868), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11664987761, 'Avenida Soberanía Nacional y Avenida Las Heras', 'Parada C00607',
        st_setsrid(st_point(-59.000950, -27.476528), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11664987762, 'Avenida Soberanía Nacional y Avenida San Martín', 'Parada C00606',
        st_setsrid(st_point(-59.003745, -27.474025), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11664987763, 'Avenida Soberanía Nacional y José María Paz', 'Parada C00605',
        st_setsrid(st_point(-59.006389, -27.471703), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11664987764, 'Avenida Alberdi y Rafael Obligado', 'Parada C02532',
        st_setsrid(st_point(-59.006124, -27.468650), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11664987765, 'Avenida Alberdi y Enrique Larreta', 'Parada C00602',
        st_setsrid(st_point(-59.003916, -27.466664), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11664987766, 'Avenida Alberdi y Miguel Cané', 'Parada C00601',
        st_setsrid(st_point(-59.002232, -27.465143), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11664987768, 'Avenida Ávalos y Marcelo Torcuato de Alvear', 'Parada C00591',
        st_setsrid(st_point(-58.992624, -27.443815), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11665004169, 'Avenida Sabín y Nueva Pompeya', 'Parada C00586',
        st_setsrid(st_point(-58.981357, -27.433253), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11665004170, 'Avenida Sabín y Fortín Arenales', 'Parada C00583',
        st_setsrid(st_point(-58.978749, -27.427791), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11665004171, 'Avenida Sabín y Calle 9', 'Parada C00581',
        st_setsrid(st_point(-58.976493, -27.423304), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11665004173, 'Gobernador Deolindo Felipe Bittel y Autovía Nicolás Avellaneda', 'Parada C00578',
        st_setsrid(st_point(-58.965510, -27.416132), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11665004175, 'Avenida Coronel Falcón y Gobernador Deolindo Felipe Bittel', 'Parada C00574',
        st_setsrid(st_point(-58.971957, -27.412575), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11665004176, 'Avenida Coronel Falcón y El Pintado', 'Parada C00573',
        st_setsrid(st_point(-58.970844, -27.411440), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11665004177, 'Avenida Coronel Falcón y Nueva Pompeya', 'Parada C00572',
        st_setsrid(st_point(-58.970148, -27.410812), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11665004178, 'Napenay y José Ameri', 'Parada C00571',
        st_setsrid(st_point(-58.971034, -27.409474), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11665004179, 'Juan XXIII y Napenay', 'Parada C00570',
        st_setsrid(st_point(-58.973790, -27.406842), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11665004180, 'Juan XXIII y Doctor Juan Diego De Morgan', 'Parada C00569',
        st_setsrid(st_point(-58.972600, -27.405773), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11665004181, 'Doctor Lázaro Maderna y Juan XXIII', 'Parada C00568',
        st_setsrid(st_point(-58.971477, -27.405003), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11665004182, 'Avenida Coronel Falcón y Doctor Lázaro Maderna', 'Parada C00566',
        st_setsrid(st_point(-58.967436, -27.408347), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11665004183, 'Avenida Coronel Falcón y Avenida Doctor Antonio Álvarez Lottero', 'Parada C05565',
        st_setsrid(st_point(-58.965057, -27.406217), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11665004184, 'Avenida Coronel Falcón y Martina Silva de Gurruchaga', 'Parada C07787',
        st_setsrid(st_point(-58.963840, -27.405125), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11665004185, 'Benjamín Zorrilla y Martina Silva de Gurruchaga', 'Parada C00564',
        st_setsrid(st_point(-58.963135, -27.406288), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11665004186, 'La Cangayé y Avenida Doctor Antonio Álvarez Lottero', 'Parada C00563',
        st_setsrid(st_point(-58.961339, -27.410101), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11665004187, 'La Cangayé y Doctor Mauricio Jajam', 'Parada C00562',
        st_setsrid(st_point(-58.962829, -27.411458), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11665004188, 'La Cangayé y Doctor Juan Diego De Morgan', 'Parada C05561',
        st_setsrid(st_point(-58.964832, -27.413248), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11665004189, 'Gobernador Deolindo Felipe Bittel y Rotonda Nicolás Avellaneda y Sabín', 'Parada C05560',
        st_setsrid(st_point(-58.968367, -27.414496), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11665004190, 'Gobernador Deolindo Felipe Bittel y Autovía Nicolás Avellaneda', 'Parada C00559',
        st_setsrid(st_point(-58.970406, -27.413474), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11668801259, 'Avenida Sabín y Las Orquídeas', 'Parada C00555',
        st_setsrid(st_point(-58.976628, -27.423593), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11668801260, 'Avenida Sabín y Calle 1', 'Parada C00554',
        st_setsrid(st_point(-58.978263, -27.426850), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11668801261, 'Avenida Sabín y Fortín Lapacho', 'Parada C00552',
        st_setsrid(st_point(-58.979354, -27.429538), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11668801263, 'Avenida de los Inmigrantes y San Juan', 'Parada C00549',
        st_setsrid(st_point(-58.981893, -27.439240), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11668801264, 'Avenida Ávalos y Avenida Lavalle', 'Parada C00545',
        st_setsrid(st_point(-58.986674, -27.438819), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11668801265, 'Avenida Ávalos y Corrientes', 'Parada C00543',
        st_setsrid(st_point(-58.991044, -27.442738), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11668801266, 'Avenida Alberdi y Avenida Édison', 'Parada C00526',
        st_setsrid(st_point(-59.000951, -27.464155), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11668801267, 'Avenida Alberdi y Fortín Los Pozos', 'Parada C00523',
        st_setsrid(st_point(-59.006248, -27.468900), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11668801268, 'Avenida Soberanía Nacional y Avenida Alberdi', 'Parada C00522',
        st_setsrid(st_point(-59.007739, -27.470499), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11668814569, 'Avenida Soberanía Nacional y José María Paz', 'Parada C00521',
        st_setsrid(st_point(-59.006008, -27.472036), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11668814570, 'Avenida Soberanía Nacional y Avenida San Martín', 'Parada C00520',
        st_setsrid(st_point(-59.003342, -27.474388), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11668814571, 'Avenida Soberanía Nacional y Avenida Las Heras', 'Parada C00519',
        st_setsrid(st_point(-59.000580, -27.476858), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11668814572, 'Avenida Soberanía Nacional y Lisandro de la Torre', 'Parada C00518',
        st_setsrid(st_point(-58.997925, -27.479212), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11668814573, 'Avenida Chaco y Avenida Soberanía Nacional', 'Parada C00517',
        st_setsrid(st_point(-58.993511, -27.482918), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11668814574, 'Avenida Chaco y Pasaje Bagual', 'Parada C00516',
        st_setsrid(st_point(-58.991757, -27.481356), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11668814575, 'Capataz Codutti y Avenida Soberanía Nacional', 'Parada C07761',
        st_setsrid(st_point(-58.984690, -27.490667), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11668814576, 'Capataz Codutti y Fortín Los Pozos', 'Parada C07751',
        st_setsrid(st_point(-58.983229, -27.489365), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11668814577, 'Capataz Codutti y Fortín Aguilar', 'Parada C07753',
        st_setsrid(st_point(-58.981851, -27.488126), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11668814578, 'Capataz Codutti y Pasaje Fortín Loma Negra', 'Parada C07755',
        st_setsrid(st_point(-58.980480, -27.486912), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11668814579, 'Capataz Codutti y Fortín Piris', 'Parada C00622',
        st_setsrid(st_point(-58.979011, -27.485324), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11668814580, 'Capataz Codutti y Avenida Édison', 'Parada C00502',
        st_setsrid(st_point(-58.977445, -27.484477), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11668814581, 'Capataz Codutti y Fortín Cardozo', 'Parada C00501',
        st_setsrid(st_point(-58.976136, -27.483299), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11668814582, 'Capataz Codutti y José María Toledo', 'Parada C00500',
        st_setsrid(st_point(-58.974808, -27.482121), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11668814583, 'Capataz Codutti y José Mármol', 'Parada C07760',
        st_setsrid(st_point(-58.972804, -27.480332), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11668814584, 'Doctor Antonio de Grandi y Carlos Boggio', 'Parada C07759',
        st_setsrid(st_point(-58.971102, -27.480334), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11672169200, 'Avenida Alberdi y Fortín Alvarado', 'Parada C00525',
        st_setsrid(st_point(-59.002601, -27.465638), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11672169202, 'Haití y Avenida Alberdi', 'Parada C00643',
        st_setsrid(st_point(-59.013241, -27.475372), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11672169203, 'Haití y Roque Sáenz Peña', 'Parada C00641',
        st_setsrid(st_point(-59.010694, -27.477670), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11672169204, 'Avenida San Martín y Haití', 'Parada C00640',
        st_setsrid(st_point(-59.008936, -27.478999), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11672169205, 'Avenida San Martín y Guatemala', 'Parada C00638',
        st_setsrid(st_point(-59.007090, -27.477332), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11672169206, 'Honduras y Avenida San Martín', 'Parada C00638',
        st_setsrid(st_point(-59.005989, -27.476725), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11672169207, 'Honduras y Pasaje Arbo y Blanco', 'Parada C00637',
        st_setsrid(st_point(-59.004670, -27.477904), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11672169208, 'Honduras y Avenida Las Heras', 'Parada C00636',
        st_setsrid(st_point(-59.003267, -27.479180), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11672169209, 'Honduras y Los Hacheros', 'Parada C00635',
        st_setsrid(st_point(-59.001546, -27.480708), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11672169210, 'Honduras y Lisandro de la Torre', 'Parada C00634',
        st_setsrid(st_point(-59.000625, -27.481527), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11672169211, 'Honduras y Julio E. Acosta', 'Parada C00633',
        st_setsrid(st_point(-58.999743, -27.482310), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11672169212, 'Honduras y Ernesto Duvivier', 'Parada C00632',
        st_setsrid(st_point(-58.998001, -27.483856), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11672169213, 'Avenida Chaco y Honduras', 'Parada C00631',
        st_setsrid(st_point(-58.996346, -27.485548), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11672169214, 'Avenida Chaco y Guatemala', 'Parada C00630',
        st_setsrid(st_point(-58.997308, -27.486410), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11672169215, 'Haití y Avenida Chaco', 'Parada C00629',
        st_setsrid(st_point(-58.999239, -27.487839), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11672169216, 'Haití y Ernesto Duvivier', 'Parada C00628',
        st_setsrid(st_point(-59.001141, -27.486153), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11672169217, 'Haití y Lisandro de la Torre', 'Parada C00627',
        st_setsrid(st_point(-59.003529, -27.484051), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11676373679, 'Haití y Gobernador Gabriel Carrasco', 'Parada C00705',
        st_setsrid(st_point(-59.001750, -27.485624), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11676373680, 'Haití y Ernesto Duvivier', 'Parada C00704',
        st_setsrid(st_point(-59.000872, -27.486392), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11676373681, 'Haití y Pasaje Julio Tort', 'Parada C00703',
        st_setsrid(st_point(-58.999731, -27.487400), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11676373682, 'Avenida Chaco y Guatemala', 'Parada C00702',
        st_setsrid(st_point(-58.997012, -27.486145), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11676373683, 'Honduras y Avenida Chaco', 'Parada C00701',
        st_setsrid(st_point(-58.996354, -27.485319), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11676373684, 'Honduras y Ernesto Duvivier', 'Parada C00700',
        st_setsrid(st_point(-58.998295, -27.483595), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11676373685, 'Honduras y Julio E. Acosta', 'Parada C00699',
        st_setsrid(st_point(-58.999996, -27.482085), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11676373686, 'Honduras y Lisandro de la Torre', 'Parada C00698',
        st_setsrid(st_point(-59.000892, -27.481289), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11676373687, 'Honduras y Los Hacheros', 'Parada C03501',
        st_setsrid(st_point(-59.001831, -27.480456), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11676373691, 'Avenida San Martín y Guatemala', 'Parada C00696',
        st_setsrid(st_point(-59.007282, -27.477646), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11676373692, 'Haití y Avenida San Martín', 'Parada C00695',
        st_setsrid(st_point(-59.009203, -27.479013), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11676373693, 'Haití y Roque Sáenz Peña', 'Parada C00694',
        st_setsrid(st_point(-59.010926, -27.477464), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11676373694, 'Avenida Alberdi y Caracas', 'Parada C01846',
        st_setsrid(st_point(-59.013223, -27.475011), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11676373695, 'Avenida Alberdi y Honduras', 'Parada C02534',
        st_setsrid(st_point(-59.010415, -27.472500), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11676373696, 'Avenida Alberdi y Avenida Nicaragua', 'Parada C02533',
        st_setsrid(st_point(-59.008962, -27.471201), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11676373701, 'Avenida Brigadier General Juan Manuel de Rosas y Napenay', 'Parada C00627',
        st_setsrid(st_point(-58.976854, -27.404021), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11676373702, 'Pasaje Crisanto Domínguez y Pampa del Indio', 'Parada C00673',
        st_setsrid(st_point(-58.980435, -27.404469), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11676373703, 'Avenida Juana Azurduy y Pasaje Rene James Sotelo', 'Parada C00671',
        st_setsrid(st_point(-58.982832, -27.403565), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11676373705, 'Heraclio Pérez y Lidia Angélica Rapazzioli de Bernal', 'Parada C00667',
        st_setsrid(st_point(-58.986611, -27.404602), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11676373706, 'Luisa Dora Cardozo de Galíndez y Antequeras', 'Parada C00666',
        st_setsrid(st_point(-58.986857, -27.406256), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11676373708, 'Gobernador Deolindo Felipe Bittel y Avenida Coronel Falcón', 'Parada C00662',
        st_setsrid(st_point(-58.971858, -27.412884), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11681428573, 'Avenida Justo P. Farías y Rotonda de Villa Monona', 'Parada C06762',
        st_setsrid(st_point(-58.950322, -27.482718), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11681428574, 'Juan Manuel Rossi e Ildefonso Pérez', 'Parada C06762',
        st_setsrid(st_point(-58.951335, -27.475154), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11681428575, 'Avenida 9 de Julio y Pasaje Sargento Discépolo', 'Parada C01779',
        st_setsrid(st_point(-58.961873, -27.473068), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11681428576, 'Avenida 9 de Julio y Miguel Z. Delfino', 'Parada C01776',
        st_setsrid(st_point(-58.966892, -27.468613), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11681428577, 'Avenida 9 de Julio y José Noveri', 'Parada C01775',
        st_setsrid(st_point(-58.968581, -27.467107), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11681428578, 'Avenida 9 de Julio y Avenida Vélez Sarsfield', 'Parada C02014',
        st_setsrid(st_point(-58.979675, -27.457270), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11681428579, 'Avenida 25 de Mayo y Padre Cerqueira', 'Parada C01603',
        st_setsrid(st_point(-58.996551, -27.442290), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11681428580, 'Avenida 25 de Mayo y General Uriburu', 'Parada C01602',
        st_setsrid(st_point(-59.001991, -27.437468), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11681428582, 'Avenida de la Democracia y Pasaje Santa Fe', 'Parada C06758',
        st_setsrid(st_point(-59.010023, -27.425826), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11681428583, 'Avenida de la Democracia', 'Parada C06755',
        st_setsrid(st_point(-59.001500, -27.408658), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11681428598, 'Avenida de la Democracia y Juan Manuel Fangio', 'Parada C06753',
        st_setsrid(st_point(-58.999373, -27.403197), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11681428599, 'Santa Sylvina y Avenida de la Democracia', 'Parada C06752',
        st_setsrid(st_point(-58.997242, -27.400755), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11681428600, 'Machagai y Santa Sylvina', 'Parada C07260',
        st_setsrid(st_point(-58.994281, -27.401535), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11681428601, 'Machagai y Villa Ángela', 'Parada C06751',
        st_setsrid(st_point(-58.993342, -27.399164), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11690772550, 'Machagai y Villa Ángela', 'Parada C06778',
        st_setsrid(st_point(-58.993463, -27.399469), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11690772552, 'Santa Sylvina y Machagai', 'Parada C06777',
        st_setsrid(st_point(-58.994465, -27.401623), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11690772553, 'Avenida de la Democracia y Santa Sylvina', 'Parada C06776',
        st_setsrid(st_point(-58.997584, -27.400809), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11690772554, 'Avenida de la Democracia y Avenida Antonio Martina', 'Parada C06775',
        st_setsrid(st_point(-58.998171, -27.402315), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11690772555, 'Eduardo Gerónimo Orcola y Avenida de la Democracia', 'Parada C06774',
        st_setsrid(st_point(-58.999619, -27.406049), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11690772562, 'Avenida 25 de Mayo y Fray Bertaca', 'Parada C01660',
        st_setsrid(st_point(-59.004077, -27.435497), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11690772563, 'Avenida 9 de Julio y Avenida Nicolás Rojas Acosta', 'Parada C06770',
        st_setsrid(st_point(-58.975615, -27.460718), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11690772564, 'Avenida 9 de Julio y Avenida Chaco', 'Parada C00195',
        st_setsrid(st_point(-58.972003, -27.463948), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11690772565, 'Avenida 9 de Julio y José Noveri', 'Parada C01024',
        st_setsrid(st_point(-58.968275, -27.467247), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11690772566, 'Avenida 9 de Julio y Avenida Urquiza', 'Parada C01022',
        st_setsrid(st_point(-58.964869, -27.470270), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11690772568, 'Avenida 9 de Julio y Avenida Agrimensor Seelstrang', 'Parada C06769',
        st_setsrid(st_point(-58.957663, -27.476667), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11690806169, 'Avenida 9 de Julio y Avenida Luis Ángel Firpo', 'Parada C01017',
        st_setsrid(st_point(-58.953986, -27.479897), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11690806214, 'Avenida Agrimensor Seelstrang y Avenida Lonardi', 'Parada C07012',
        st_setsrid(st_point(-58.949038, -27.468733), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11693836915, 'Avenida Laprida y Avenida Intendente Borrini', 'Parada C06790',
        st_setsrid(st_point(-58.964842, -27.457607), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11693836916, 'Avenida Laprida y San Bartolomé', 'Parada C06789',
        st_setsrid(st_point(-58.963499, -27.458798), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11693836917, 'José Noveri y Avenida Laprida', 'Parada C06788',
        st_setsrid(st_point(-58.961407, -27.460884), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11693836918, 'Ayacucho y José Noveri', 'Parada C06787',
        st_setsrid(st_point(-58.965116, -27.463947), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11693836919, 'José Alsina e Hipólito Yrigoyen', 'Parada C06786',
        st_setsrid(st_point(-58.968551, -27.465747), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11693836922, 'Taco Pozo y Los Crisantemos', 'Parada C06784',
        st_setsrid(st_point(-58.996611, -27.407160), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11693836923, 'El Sauzalito y Machagai', 'Parada C07774',
        st_setsrid(st_point(-58.992959, -27.397624), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11693836924, 'Avenida de la Democracia y Pasaje Marcelo Torcuato de Alvear', 'Parada C07253',
        st_setsrid(st_point(-59.010268, -27.427246), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11693836925, 'Eduardo Gerónimo Orcola y Avenida de la Democracia', 'Parada C06785',
        st_setsrid(st_point(-58.999353, -27.405928), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11693836926, 'Taco Pozo y Avenida Antonio Martina', 'Parada C06783',
        st_setsrid(st_point(-58.994784, -27.405390), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11693836927, 'Taco Pozo y General Pinedo', 'Parada C07775',
        st_setsrid(st_point(-58.992410, -27.403256), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11693836929, 'Juan Manuel Bordeau y Campo Largo', 'Parada C06780',
        st_setsrid(st_point(-58.999390, -27.396784), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11697291992, 'Santa Sylvina y Machagai', 'Parada C07778',
        st_setsrid(st_point(-58.994149, -27.401719), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11697291993, 'Taco Pozo y General Pinedo', 'Parada C07776',
        st_setsrid(st_point(-58.992676, -27.403491), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11697291994, 'Taco Pozo y Avenida Antonio Martina', 'Parada C06796',
        st_setsrid(st_point(-58.995036, -27.405658), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11697291995, 'Los Crisantemos y Taco Pozo', 'Parada C06795',
        st_setsrid(st_point(-58.997093, -27.407355), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11697291996, 'José Noveri y Avenida 9 de Julio', 'Parada C06794',
        st_setsrid(st_point(-58.968211, -27.466989), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11697291997, 'José Noveri y Ayacucho', 'Parada C06793',
        st_setsrid(st_point(-58.964822, -27.463942), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11697291998, 'Avenida Laprida y José Noveri', 'Parada C06792',
        st_setsrid(st_point(-58.961396, -27.460665), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11697291999, 'San Pedro y San Bartolomé', 'Parada C06791',
        st_setsrid(st_point(-58.963214, -27.458156), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11700999641, 'Misionero Klein y Falucho', 'Parada C01348',
        st_setsrid(st_point(-59.013236, -27.454353), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11700999642, 'Avenida Marconi y Padre Sena', 'Parada C01348',
        st_setsrid(st_point(-59.011475, -27.454454), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11700999643, 'Padre Cerqueira y Avenida Marconi', 'Parada C01037',
        st_setsrid(st_point(-59.010541, -27.455077), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11700999645, 'Padre Cerqueira y La Pampa', 'Parada C01035',
        st_setsrid(st_point(-59.007175, -27.452060), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11700999646, 'Padre Cerqueira y Los Andes', 'Parada C01034',
        st_setsrid(st_point(-59.005572, -27.450611), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11700999647, 'Padre Cerqueira y Jujuy', 'Parada C01031',
        st_setsrid(st_point(-59.001467, -27.446967), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11700999648, 'Padre Cerqueira y Santiago del Estero', 'Parada C01030',
        st_setsrid(st_point(-58.999680, -27.445328), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11700999649, 'Juan Domingo Perón y San Roque', 'Parada C01028',
        st_setsrid(st_point(-58.996138, -27.445709), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11700999650, 'Avenida Hernandarias y Julio Argentino Roca', 'Parada C01054',
        st_setsrid(st_point(-58.994371, -27.445396), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11700999651, 'Avenida 9 de Julio y Lisandro de la Torre', 'Parada C00197',
        st_setsrid(st_point(-58.976472, -27.459974), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11700999652, 'Avenida 9 de Julio y Ernesto Duvivier', 'Parada C00196',
        st_setsrid(st_point(-58.973973, -27.462184), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11700999653, 'Avenida 9 de Julio e Inspector Patiño', 'Parada C01025',
        st_setsrid(st_point(-58.969959, -27.465754), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11700999654, 'Avenida 9 de Julio y Miguel Z. Delfino', 'Parada C01023',
        st_setsrid(st_point(-58.966546, -27.468772), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11700999655, 'Avenida 9 de Julio y Carlos Corsi', 'Parada C01021',
        st_setsrid(st_point(-58.963108, -27.471825), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11700999656, 'Avenida 9 de Julio y García Pulido', 'Parada C01019',
        st_setsrid(st_point(-58.960748, -27.473916), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11700999657, 'Avenida 9 de Julio y Ángel D''Ambra', 'Parada C01018',
        st_setsrid(st_point(-58.955823, -27.478268), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11700999659, 'Diagonal Eva Perón y Amadeo Sabattini', 'Parada C01015',
        st_setsrid(st_point(-58.948364, -27.482928), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11700999660, 'Diagonal Eva Perón y Brasil', 'Parada C01014',
        st_setsrid(st_point(-58.946264, -27.482917), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11700999661, 'Diagonal Eva Perón y Ayacucho', 'Parada C01013',
        st_setsrid(st_point(-58.943487, -27.482904), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11700999662, 'Diagonal Eva Perón y Chile', 'Parada C01012',
        st_setsrid(st_point(-58.941087, -27.482892), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11700999663, 'Diagonal Eva Perón y Córdoba', 'Parada C01011',
        st_setsrid(st_point(-58.938403, -27.482879), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11700999664, 'Avenida Laprida y Joaquín Víctor González', 'Parada C01010',
        st_setsrid(st_point(-58.935067, -27.483817), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11700999665, 'Avenida Laprida y Miguel Cané', 'Parada C01009',
        st_setsrid(st_point(-58.933348, -27.485384), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11700999666, 'Fray Mocho y Avenida Laprida', 'Parada C01008',
        st_setsrid(st_point(-58.931605, -27.486672), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11700999667, 'Fray Mocho y Sargento Cabral', 'Parada C01007',
        st_setsrid(st_point(-58.930615, -27.485767), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11700999668, 'Fray Mocho y Los Colonizadores', 'Parada C01006',
        st_setsrid(st_point(-58.928772, -27.484131), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11701006569, 'León Zorrilla y Fray Mocho', 'Parada C01005',
        st_setsrid(st_point(-58.927066, -27.482837), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11701006570, 'León Zorrilla y General Belgrano', 'Parada C01004',
        st_setsrid(st_point(-58.925313, -27.484385), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11701006571, 'Avenida Sebastián Gaboto y Capitán Solari', 'Parada C01000',
        st_setsrid(st_point(-58.927979, -27.488224), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11703735580, 'General Belgrano y Juan Ramón Lestani', 'Parada C01064',
        st_setsrid(st_point(-58.927813, -27.486438), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11703735581, 'General Belgrano y Alice Le Saige', 'Parada C01063',
        st_setsrid(st_point(-58.926198, -27.484918), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11703735582, 'León Zorrilla y General Belgrano', 'Parada C01062',
        st_setsrid(st_point(-58.925565, -27.484150), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11703735583, 'Fray Mocho y León Zorrilla', 'Parada C00284',
        st_setsrid(st_point(-58.927307, -27.482826), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11703735584, 'Fray Mocho y Los Colonizadores', 'Parada C00283',
        st_setsrid(st_point(-58.929000, -27.484334), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11703735585, 'Fray Mocho y Sargento Cabral', 'Parada C00282',
        st_setsrid(st_point(-58.930983, -27.486107), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11703735586, 'Avenida Laprida y Fray Mocho', 'Parada C01058',
        st_setsrid(st_point(-58.932012, -27.486720), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11703735587, 'Avenida Laprida y Fray Mamerto Esquiú', 'Parada C01057',
        st_setsrid(st_point(-58.932848, -27.485950), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11703735588, 'Avenida Laprida y Dos de Febrero', 'Parada C01056',
        st_setsrid(st_point(-58.934524, -27.484454), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11703735589, 'Diagonal Eva Perón y Avenida General San Martín', 'Parada C00231',
        st_setsrid(st_point(-58.936723, -27.482978), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11703735591, 'Diagonal Eva Perón y Avenida Paraguay', 'Parada C02507',
        st_setsrid(st_point(-58.942673, -27.482981), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11703735592, 'Diagonal Eva Perón y Ayacucho', 'Parada C02506',
        st_setsrid(st_point(-58.943740, -27.482976), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11703735593, 'Diagonal Eva Perón y Almirante Brown', 'Parada C02505',
        st_setsrid(st_point(-58.947287, -27.482992), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11703735594, 'Diagonal Eva Perón e Hipólito Yrigoyen', 'Parada C02504',
        st_setsrid(st_point(-58.948974, -27.482997), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11703735595, 'Avenida 9 de Julio y Avenida España', 'Parada C02503',
        st_setsrid(st_point(-58.950904, -27.482801), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11703735596, 'Avenida 9 de Julio y Aliso', 'Parada C01783',
        st_setsrid(st_point(-58.952650, -27.481248), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11703735597, 'Avenida 9 de Julio y Avenida Luis Ángel Firpo', 'Parada C01782',
        st_setsrid(st_point(-58.954529, -27.479560), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11703735598, 'Avenida 9 de Julio y Ángel D''Ambra', 'Parada C01781',
        st_setsrid(st_point(-58.956409, -27.477918), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11703735599, 'Avenida 9 de Julio y Capataz Codutti', 'Parada C01778',
        st_setsrid(st_point(-58.963446, -27.471664), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11703735600, 'Avenida 9 de Julio e Inspector Patiño', 'Parada C01774',
        st_setsrid(st_point(-58.970258, -27.465610), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11703735601, 'Avenida 9 de Julio y Ernesto Duvivier', 'Parada C01772',
        st_setsrid(st_point(-58.974264, -27.462079), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11703735602, 'Avenida Hernandarias y Julio Argentino Roca', 'Parada C01053',
        st_setsrid(st_point(-58.994530, -27.445853), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11703735604, 'Padre Cerqueira y Los Andes', 'Parada C01046',
        st_setsrid(st_point(-59.005770, -27.450790), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11703735607, 'Padre Cerqueira y Dos de Febrero', 'Parada C01043',
        st_setsrid(st_point(-59.010160, -27.454734), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11703735608, 'Padre Sena y Avenida Marconi', 'Parada C01039',
        st_setsrid(st_point(-59.011778, -27.454529), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11716558593, 'Avenida de la Democracia y Hermanos Boronat', 'Parada C02345',
        st_setsrid(st_point(-59.025425, -27.448453), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11716558594, 'Avenida Carlos María de Alvear y Avenida Mac Lean', 'Parada C02333',
        st_setsrid(st_point(-59.007798, -27.444830), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11716558597, 'Hipólito Yrigoyen y José Hernández', 'Parada C02321',
        st_setsrid(st_point(-58.979337, -27.455903), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11716558598, 'Avenida Las Heras y Avenida 9 de Julio', 'Parada C02320',
        st_setsrid(st_point(-58.979550, -27.457708), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11716558599, 'Ameghino y Los Hacheros', 'Parada C02318',
        st_setsrid(st_point(-58.980908, -27.462289), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11716558600, 'Ameghino y Lisandro de la Torre', 'Parada C02317',
        st_setsrid(st_point(-58.980009, -27.463087), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11716558601, 'Ameghino y Julio E. Acosta', 'Parada C02316',
        st_setsrid(st_point(-58.979152, -27.463839), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11716558602, 'Ameghino y Ernesto Duvivier', 'Parada C02315',
        st_setsrid(st_point(-58.977450, -27.465348), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11716558603, 'Ameghino y Avenida Chaco', 'Parada C02314',
        st_setsrid(st_point(-58.975474, -27.467084), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11716558604, 'Ameghino y Silvano Dante', 'Parada C02313',
        st_setsrid(st_point(-58.973458, -27.468884), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11716558605, 'Ameghino y Martín Goitía', 'Parada C02312',
        st_setsrid(st_point(-58.971786, -27.470379), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11716558606, 'Ameghino y Avenida Urquiza', 'Parada C02310',
        st_setsrid(st_point(-58.968323, -27.473459), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11716558607, 'Ameghino y Capataz Codutti', 'Parada C02309',
        st_setsrid(st_point(-58.966577, -27.474995), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11716558608, 'Tránsito Cocomarola y Ameghino', 'Parada C02308',
        st_setsrid(st_point(-58.965224, -27.476342), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11716558609, 'Tránsito Cocomarola y Franklin', 'Parada C02307',
        st_setsrid(st_point(-58.966846, -27.477794), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11716558610, 'Avenida Juan José Castelli y Bibiano Meza', 'Parada C02305',
        st_setsrid(st_point(-58.967118, -27.480954), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11716558611, 'Avenida Juan José Castelli y Luis O. Gusberti', 'Parada C02304',
        st_setsrid(st_point(-58.965631, -27.482291), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11716558612, 'Avenida Juan José Castelli y Calle 26', 'Parada C02303',
        st_setsrid(st_point(-58.963951, -27.483777), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11716558615, 'Avenida Juan José Castelli y Calle 29', 'Parada C02302',
        st_setsrid(st_point(-58.961476, -27.485980), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11716558616, 'Avenida Juan José Castelli y Calle 31', 'Parada C04009',
        st_setsrid(st_point(-58.959565, -27.487663), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11716558617, 'Avenida Juan José Castelli y Avenida España', 'Parada C02301',
        st_setsrid(st_point(-58.957572, -27.489427), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11716558618, 'Avenida Juan José Castelli y Yatay', 'Parada C02300',
        st_setsrid(st_point(-58.955572, -27.491174), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11716558619, 'Avenida Juan José Castelli y Lapacho', 'Parada C02299',
        st_setsrid(st_point(-58.953850, -27.492708), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11716558621, 'Tatané y Marcos Briolini', 'Parada C02521',
        st_setsrid(st_point(-58.953280, -27.495074), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11716558623, 'Ceibo y José Mármol', 'Parada C02295',
        st_setsrid(st_point(-58.954134, -27.497370), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11724812641, 'Avenida José María Toledo y Ceibo', 'Parada C02294',
        st_setsrid(st_point(-58.955936, -27.498811), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11724812642, 'Avenida José María Toledo y Algarrobo', 'Parada C02293',
        st_setsrid(st_point(-58.957658, -27.497284), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11724812643, 'Avenida José María Toledo y Timbó', 'Parada C02544',
        st_setsrid(st_point(-58.959369, -27.495771), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11724812644, 'Avenida José María Toledo y Yatay', 'Parada C02291',
        st_setsrid(st_point(-58.960543, -27.494730), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11724812645, 'Sauce y Avenida José María Toledo', 'Parada C02290',
        st_setsrid(st_point(-58.961104, -27.493913), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11724812646, 'Sauce y José Mármol', 'Parada C02289',
        st_setsrid(st_point(-58.959588, -27.492549), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11724812647, 'Sauce y Carlos Boggio', 'Parada C02288',
        st_setsrid(st_point(-58.958637, -27.491685), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11724812648, 'Avenida Juan José Castelli y Avenida España', 'Parada C02287',
        st_setsrid(st_point(-58.957941, -27.489188), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11724812650, 'Avenida Juan José Castelli y Calle 26', 'Parada C02285',
        st_setsrid(st_point(-58.964210, -27.483638), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11724812651, 'Avenida Juan José Castelli y Luis O. Gusberti', 'Parada C02284',
        st_setsrid(st_point(-58.965911, -27.482141), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11724812652, 'Avenida Juan José Castelli y Bibiano Meza', 'Parada C02283',
        st_setsrid(st_point(-58.967453, -27.480772), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11724812653, 'Tránsito Cocomarola y Avenida Juan José Castelli', 'Parada C02282',
        st_setsrid(st_point(-58.968614, -27.479393), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11724812654, 'Tránsito Cocomarola y Franklin', 'Parada C02284',
        st_setsrid(st_point(-58.966672, -27.477639), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11724812655, 'General Obligado y Tránsito Cocomarola', 'Parada C02280',
        st_setsrid(st_point(-58.964387, -27.475415), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11724812656, 'General Obligado y Capataz Codutti', 'Parada C02279',
        st_setsrid(st_point(-58.965997, -27.473987), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11724812657, 'General Obligado y Avenida Urquiza', 'Parada C02278',
        st_setsrid(st_point(-58.967718, -27.472459), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11724812658, 'General Obligado y Martín Goitía', 'Parada C02276',
        st_setsrid(st_point(-58.971154, -27.469414), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11724812659, 'General Obligado y Silvano Dante', 'Parada C02575',
        st_setsrid(st_point(-58.972875, -27.467880), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11724812660, 'Avenida Chaco y Arturo Umberto Illia', 'Parada C02274',
        st_setsrid(st_point(-58.973807, -27.465296), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11724812666, 'Avenida de la Democracia y Primero de Mayo', 'Parada C02250',
        st_setsrid(st_point(-59.020339, -27.442928), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11731162771, 'Avenida Libertador General San Martín y Facundo Quiroga', 'Parada C01797',
        st_setsrid(st_point(-58.942331, -27.508039), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11731162772, 'Avellaneda', 'Parada C01807',
        st_setsrid(st_point(-58.924079, -27.535586), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11731162773, 'Belgrano y Almafuerte', 'Parada C01805',
        st_setsrid(st_point(-58.931305, -27.529187), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11731162774, 'Parada C01832', null,
        st_setsrid(st_point(-58.933939, -27.526881), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11731162779, 'Cristóbal Colón y Avenida Libertador General San Martín', 'Parada C01803',
        st_setsrid(st_point(-58.938308, -27.522939), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11731162780, 'Las Malvinas y Avenida Libertador General San Martín', 'Parada C01804',
        st_setsrid(st_point(-58.939528, -27.521886), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11731162781, 'Avenida Libertador General San Martín y Resistencia', 'Parada C01802',
        st_setsrid(st_point(-58.941880, -27.518000), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11731162782, 'Avenida Libertador General San Martín y Santa Rosa', 'Parada C01801',
        st_setsrid(st_point(-58.941902, -27.515631), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11731162783, 'Avenida Libertador General San Martín y Ayacucho', 'Parada C01799',
        st_setsrid(st_point(-58.942191, -27.510696), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11731162784, 'Avenida Libertador General San Martín y Rosario', 'Parada C01798',
        st_setsrid(st_point(-58.942273, -27.509148), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11731162785, 'Avenida Libertador General San Martín y Mendoza', 'Parada C01796',
        st_setsrid(st_point(-58.942425, -27.506251), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11731162786, 'Avenida General Mosconi', 'Parada C01793',
        st_setsrid(st_point(-58.940427, -27.499423), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11731162787, 'Avenida General Mosconi', 'Parada C01792',
        st_setsrid(st_point(-58.938557, -27.497746), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11731162788, 'Avenida 9 de Julio y Fray Mamerto Esquiú', 'Parada C01790',
        st_setsrid(st_point(-58.939722, -27.492652), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11731162789, 'Avenida 9 de Julio y Dos de Febrero', 'Parada C01789',
        st_setsrid(st_point(-58.941731, -27.490875), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11731162790, 'Avenida 9 de Julio y Avenida General San Martín', 'Parada C01788',
        st_setsrid(st_point(-58.943571, -27.489250), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11731162791, 'Avenida 9 de Julio y Guido Spano', 'Parada C01787',
        st_setsrid(st_point(-58.945314, -27.487698), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11731162792, 'Avenida 9 de Julio y Bolivia', 'Parada C01786',
        st_setsrid(st_point(-58.947038, -27.486174), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11731162793, 'Avenida 9 de Julio y Yatay', 'Parada C01785',
        st_setsrid(st_point(-58.948815, -27.484611), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11731162794, 'Avenida 9 de Julio y Rotonda de Villa Monona', 'Parada C01784',
        st_setsrid(st_point(-58.950005, -27.483547), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11731162795, 'General Obligado y José María Paz', 'Parada C00122',
        st_setsrid(st_point(-58.987474, -27.454926), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11731162796, 'Avenida Moreno y Echeverría', 'Parada C01767',
        st_setsrid(st_point(-58.996235, -27.450206), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11731162797, 'Avenida Hernandarias y Horacio Quiroga', 'Parada C01758',
        st_setsrid(st_point(-59.014669, -27.463735), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11731162798, 'Avenida Islas Malvinas y General Dónovan', 'Parada C01755',
        st_setsrid(st_point(-59.011254, -27.467370), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11731162799, 'Avenida Islas Malvinas y General Vedia', 'Parada C01754',
        st_setsrid(st_point(-59.009530, -27.468895), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11731162801, 'Avenida Alberdi y Honduras', 'Parada C01752',
        st_setsrid(st_point(-59.010613, -27.472821), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11731162802, 'Avenida Alberdi y Cuba', 'Parada C01751',
        st_setsrid(st_point(-59.012619, -27.474610), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11731162803, 'Avenida Alberdi y Haití', 'Parada C00643',
        st_setsrid(st_point(-59.013414, -27.475320), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11734233712, 'Avenida General Mosconi y Rotonda Gaboto - 9 de Julio - General Mosconi', 'Parada C01824',
        st_setsrid(st_point(-58.937304, -27.496855), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11734233713, 'Avenida Alberdi y Quito', 'Parada C02535',
        st_setsrid(st_point(-59.012151, -27.474053), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11734233716, 'General Vedia y Jorge Luis Borges', 'Parada C01843',
        st_setsrid(st_point(-59.008486, -27.467716), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11734233717, 'Jorge Luis Borges y Avenida Alberdi', 'Parada C01844',
        st_setsrid(st_point(-59.006749, -27.468915), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11734233718, 'Avenida Islas Malvinas y General Vedia', 'Parada C01842',
        st_setsrid(st_point(-59.009783, -27.468672), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11734233719, 'Avenida Islas Malvinas y General Dónovan', 'Parada C01841',
        st_setsrid(st_point(-59.011518, -27.467135), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11734233720, 'Avenida Islas Malvinas y Avenida Belgrano', 'Parada C01840',
        st_setsrid(st_point(-59.012422, -27.466340), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11734233721, 'Avenida Islas Malvinas y Cangallo', 'Parada C01839',
        st_setsrid(st_point(-59.014171, -27.464813), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11734233723, 'Avenida Hernandarias y Nicolás Roldán', 'Parada C02042',
        st_setsrid(st_point(-59.003907, -27.453927), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11734233725, 'Avenida Hernandarias y Mendoza', 'Parada C02040',
        st_setsrid(st_point(-58.999625, -27.450100), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11734233727, 'Jujuy y Echeverría', 'Parada C01834',
        st_setsrid(st_point(-58.996865, -27.451302), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11734233728, 'Necochea y Jujuy', 'Parada C00073',
        st_setsrid(st_point(-58.994218, -27.453388), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11734233729, 'Necochea y Santiago del Estero', 'Parada C00072',
        st_setsrid(st_point(-58.992355, -27.451738), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11734233731, 'Avenida 9 de Julio y Rotonda de Villa Monona', 'Parada C01831',
        st_setsrid(st_point(-58.950204, -27.483226), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11734233732, 'Avenida 9 de Julio y Brasil', 'Parada C01830',
        st_setsrid(st_point(-58.948445, -27.484820), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11734233733, 'Avenida 9 de Julio y Bolivia', 'Parada C01829',
        st_setsrid(st_point(-58.946717, -27.486352), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11734233734, 'Avenida 9 de Julio y Guido Spano', 'Parada C01828',
        st_setsrid(st_point(-58.944986, -27.487885), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11734233735, 'Avenida 9 de Julio y Avenida General San Martín', 'Parada C01827',
        st_setsrid(st_point(-58.943205, -27.489472), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11734233736, 'Avenida 9 de Julio y Dos de Febrero', 'Parada C01826',
        st_setsrid(st_point(-58.941403, -27.491060), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11734233737, 'Avenida 9 de Julio y Fray Mamerto Esquiú', 'Parada C01825',
        st_setsrid(st_point(-58.939942, -27.492455), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11734233738, 'Avenida General Mosconi', 'Parada C01823',
        st_setsrid(st_point(-58.938536, -27.497954), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11734233739, 'Avenida General Mosconi', 'Parada C01822',
        st_setsrid(st_point(-58.940552, -27.499769), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11734233741, 'Avenida Libertador General San Martín y Mendoza', 'Parada C01819',
        st_setsrid(st_point(-58.942332, -27.506457), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11734233742, 'Avenida Libertador General San Martín y Facundo Quiroga', 'Parada C01818',
        st_setsrid(st_point(-58.942232, -27.508248), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11734233743, 'Avenida Libertador General San Martín y Estanislao López', 'Parada C01817',
        st_setsrid(st_point(-58.942162, -27.509500), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11734233744, 'Avenida Libertador General San Martín y Ayacucho', 'Parada C01816',
        st_setsrid(st_point(-58.942088, -27.510820), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11734233745, 'Avenida Libertador General San Martín y Santa Lucía', 'Parada C01815',
        st_setsrid(st_point(-58.941922, -27.513755), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11734233746, 'Avenida Libertador General San Martín y Moisés Levenshon', 'Parada C01814',
        st_setsrid(st_point(-58.941780, -27.516053), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11734233747, 'Avenida Libertador General San Martín y Avenida Soberanía Nacional', 'Parada C01813',
        st_setsrid(st_point(-58.941447, -27.519347), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11734233748, 'Las Malvinas y Avenida Libertador General San Martín', 'Parada C01812',
        st_setsrid(st_point(-58.939330, -27.522061), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11734233749, 'Cristóbal Colón y Avenida Libertador General San Martín', 'Parada C01811',
        st_setsrid(st_point(-58.938013, -27.523196), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11734233750, 'Parada C01833', null,
        st_setsrid(st_point(-58.933322, -27.527432), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11734233751, 'Belgrano y Almafuerte', 'Parada C01810',
        st_setsrid(st_point(-58.930839, -27.529583), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11734233752, 'Parada C01806', null,
        st_setsrid(st_point(-58.927081, -27.532944), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11734233753, 'Avellaneda', 'Parada C01808',
        st_setsrid(st_point(-58.923958, -27.535692), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11741246869, 'Avenida Belgrano y Horacio Quiroga', 'Parada C02585',
        st_setsrid(st_point(-59.011788, -27.465921), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11741246870, 'Avenida Belgrano y Miguel Cané', 'Parada C02582',
        st_setsrid(st_point(-59.006736, -27.461370), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11741246871, 'Avenida Belgrano y Pasaje Tambor de Tacuarí', 'Parada C02581',
        st_setsrid(st_point(-59.005587, -27.460355), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11741246872, 'Avenida Marconi y Cangallo', 'Parada C02590',
        st_setsrid(st_point(-59.007154, -27.458438), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11741246873, 'Avenida España y Rotonda de Villa Monona', 'Parada C02579',
        st_setsrid(st_point(-58.950787, -27.483145), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11741246874, 'Avenida España y Arturo Umberto Illia', 'Parada C02578',
        st_setsrid(st_point(-58.952500, -27.484684), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11741246875, 'Avenida España y Ameghino', 'Parada C02577',
        st_setsrid(st_point(-58.954144, -27.486143), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11741246876, 'Avenida España y Franklin', 'Parada C02576',
        st_setsrid(st_point(-58.956101, -27.487905), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11741246877, 'Sauce y Avenida Juan José Castelli', 'Parada C02575',
        st_setsrid(st_point(-58.957022, -27.490235), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11741246878, 'Sauce y Carlos Boggio', 'Parada C02573',
        st_setsrid(st_point(-58.958845, -27.491873), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11741246879, 'Sauce y José Mármol', 'Parada C02572',
        st_setsrid(st_point(-58.959778, -27.492720), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11741246880, 'Avenida José María Toledo y Sauce', 'Parada C00264',
        st_setsrid(st_point(-58.961115, -27.494102), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11741246881, 'Avenida José María Toledo y Yatay', 'Parada C02570',
        st_setsrid(st_point(-58.960268, -27.494844), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11741246883, 'Avenida José María Toledo y Algarrobo', 'Parada C02568',
        st_setsrid(st_point(-58.957363, -27.497407), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11741246884, 'Avenida José María Toledo y Ceibo', 'Parada C02567',
        st_setsrid(st_point(-58.955667, -27.498926), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11741246885, 'Avenida Nicolás Rojas Acosta y Avenida Édison', 'Parada C02566',
        st_setsrid(st_point(-58.957803, -27.502226), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11741246887, 'Avenida Nicolás Rojas Acosta y Fortín Alvarado', 'Parada C02565',
        st_setsrid(st_point(-58.959355, -27.503618), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11741246888, 'Avenida Nicolás Rojas Acosta y Fortín Aguilar', 'Parada C02564',
        st_setsrid(st_point(-58.962442, -27.506353), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11741246889, 'Avenida Nicolás Rojas Acosta y Fortín Los Pozos', 'Parada C02563',
        st_setsrid(st_point(-58.963358, -27.507169), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11741246890, 'Avenida Soberanía Nacional y Avenida Nicolás Rojas Acosta', 'Parada C02561',
        st_setsrid(st_point(-58.965077, -27.508483), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11741246891, 'Avenida Soberanía Nacional y Algarrobo', 'Parada C02560',
        st_setsrid(st_point(-58.968025, -27.505871), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11741246892, 'Avenida Soberanía Nacional y Yatay', 'Parada C02559',
        st_setsrid(st_point(-58.970326, -27.503833), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11741246893, 'Avenida Soberanía Nacional y Avenida España', 'Parada C02558',
        st_setsrid(st_point(-58.972032, -27.502322), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11741845569, 'Avenida Soberanía Nacional y Avenida España', 'Parada C02557',
        st_setsrid(st_point(-58.971921, -27.502420), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11741845570, 'Avenida Soberanía Nacional y Yatay', 'Parada C02556',
        st_setsrid(st_point(-58.970495, -27.503683), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11741845571, 'Avenida Soberanía Nacional y Algarrobo', 'Parada C02555',
        st_setsrid(st_point(-58.967790, -27.506079), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11741845572, 'Avenida Nicolás Rojas Acosta y Avenida Soberanía Nacional', 'Parada C02552',
        st_setsrid(st_point(-58.964754, -27.508413), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11741845573, 'Avenida Nicolás Rojas Acosta y Fortín Tapenagá', 'Parada C02551',
        st_setsrid(st_point(-58.963910, -27.507661), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11741845574, 'Avenida Nicolás Rojas Acosta y Fortín Aguilar', 'Parada C02549',
        st_setsrid(st_point(-58.962221, -27.506156), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11741845575, 'Avenida Nicolás Rojas Acosta y Fortín Alvarado', 'Parada C02548',
        st_setsrid(st_point(-58.959109, -27.503397), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11741845576, 'Avenida Nicolás Rojas Acosta y Avenida Édison', 'Parada C02547',
        st_setsrid(st_point(-58.957541, -27.501976), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11741845578, 'Avenida España y Avenida Juan José Castelli', 'Parada C03259',
        st_setsrid(st_point(-58.957661, -27.489150), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11741845579, 'Avenida España y Franklin', 'Parada C02538',
        st_setsrid(st_point(-58.955990, -27.487645), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11741845580, 'Avenida España y Avenida Rodríguez Peña', 'Parada C03258',
        st_setsrid(st_point(-58.954779, -27.486556), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11741845581, 'Avenida España y Arturo Umberto Illia', 'Parada C03257',
        st_setsrid(st_point(-58.952329, -27.484366), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11741845582, 'Avenida Hernandarias y Dos de Febrero', 'Parada C02008',
        st_setsrid(st_point(-59.007361, -27.457196), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11741845583, 'Avenida Marconi y Cangallo', 'Parada C01346',
        st_setsrid(st_point(-59.006789, -27.458592), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11741845584, 'Avenida Belgrano y Falucho', 'Parada C00653',
        st_setsrid(st_point(-59.006101, -27.460971), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11742296360, 'Tatané y Avenida 9 de Julio', 'Parada C02525',
        st_setsrid(st_point(-58.945296, -27.487919), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11742296361, 'Avenida Alberdi y Ricardo Rojas', 'Parada C02531',
        st_setsrid(st_point(-59.004610, -27.467289), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11742296362, 'Avenida General San Martín y Saavedra', 'Parada C02528',
        st_setsrid(st_point(-58.938116, -27.484604), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11742296363, 'Avenida General San Martín y Paraguay', 'Parada C02527',
        st_setsrid(st_point(-58.939520, -27.485802), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11742296364, 'Avenida General San Martín y Almirante Brown', 'Parada C02526',
        st_setsrid(st_point(-58.941567, -27.487634), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11742296365, 'Tatané y Arturo Umberto Illia', 'Parada C02524',
        st_setsrid(st_point(-58.947036, -27.489491), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11742296366, 'Tatané y Ameghino', 'Parada C02523',
        st_setsrid(st_point(-58.948719, -27.491007), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11742296367, 'Tatané y Franklin', 'Parada C00274',
        st_setsrid(st_point(-58.950676, -27.492741), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11742296368, 'Tatané y Avenida Juan José Castelli', 'Parada C02298',
        st_setsrid(st_point(-58.952398, -27.494284), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11742321769, 'Ceibo y Carlos Dodero', 'Parada C02519',
        st_setsrid(st_point(-58.954951, -27.498113), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745080343, 'Avenida José María Toledo y Ceibo', 'Parada C02546',
        st_setsrid(st_point(-58.956250, -27.498539), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745080344, 'Algarrobo y Carlos Dodero', 'Parada C02518',
        st_setsrid(st_point(-58.956512, -27.496447), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745080345, 'Tatané y José Mármol', 'Parada C02517',
        st_setsrid(st_point(-58.954783, -27.496422), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745080346, 'Tatané y Marcos Briolini', 'Parada C02516',
        st_setsrid(st_point(-58.953038, -27.494858), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745080347, 'Tatané y Avenida Juan José Castelli', 'Parada C02515',
        st_setsrid(st_point(-58.952115, -27.494040), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745080348, 'Tatané y Franklin', 'Parada C02514',
        st_setsrid(st_point(-58.950389, -27.492484), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745080349, 'Tatané y Avenida Rodríguez Peña', 'Parada C02513',
        st_setsrid(st_point(-58.949199, -27.491421), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745080350, 'Tatané y General Obligado', 'Parada C02512',
        st_setsrid(st_point(-58.947604, -27.490000), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745080351, 'Tatané y Juan B. Justo', 'Parada C02511',
        st_setsrid(st_point(-58.945916, -27.488480), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745080352, 'Guido Spano e Hipólito Yrigoyen', 'Parada C02510',
        st_setsrid(st_point(-58.944134, -27.486851), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745080353, 'Guido Spano y Pirovano', 'Parada C02509',
        st_setsrid(st_point(-58.942479, -27.485377), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745381382, 'Misiones y Avenida 25 de Mayo', 'Parada C01548',
        st_setsrid(st_point(-59.040198, -27.403740), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745381383, 'Misiones y Juan Domingo Perón', 'Parada C01612',
        st_setsrid(st_point(-59.041715, -27.405097), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745381384, 'Misiones y Pasaje Salta Bis', 'Parada C07619',
        st_setsrid(st_point(-59.043333, -27.406544), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745381385, 'Misiones y Pasaje Moreno', 'Parada C01545',
        st_setsrid(st_point(-59.045094, -27.408117), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745381386, 'Misiones y Pasaje Mendoza', 'Parada C07618',
        st_setsrid(st_point(-59.046817, -27.409662), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745381387, 'Misiones y Felipe Molina', 'Parada C01544',
        st_setsrid(st_point(-59.048730, -27.411373), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745381388, 'San Luis y Diagonal Juan Bautista Cabral', 'Parada C01543',
        st_setsrid(st_point(-59.049509, -27.413024), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745381389, 'Diagonal Juan Bautista Cabral y Brasil', 'Parada C01541',
        st_setsrid(st_point(-59.040426, -27.416840), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745381390, 'Avenida Carlos María de Alvear y Avenida Augusto Rey', 'Parada C01540',
        st_setsrid(st_point(-59.037578, -27.418607), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745381391, 'Avenida Carlos María de Alvear y Domingo Faustino Sarmiento', 'Parada C01534',
        st_setsrid(st_point(-59.034873, -27.420985), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745381392, 'Avenida Carlos María de Alvear y Avenida Güemes', 'Parada C01538',
        st_setsrid(st_point(-59.030448, -27.424897), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745381394, 'Avenida Carlos María de Alvear y Neuquén', 'Parada C01536',
        st_setsrid(st_point(-59.026970, -27.427981), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745381395, 'Avenida Carlos María de Alvear y Almirante Brown', 'Parada C01535',
        st_setsrid(st_point(-59.025101, -27.429636), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745381396, 'Avenida Carlos María de Alvear y Lago Nahuel Huapi', 'Parada C07617',
        st_setsrid(st_point(-59.023257, -27.431255), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745381397, 'Avenida Carlos María de Alvear y Mar del Plata', 'Parada C01533',
        st_setsrid(st_point(-59.021101, -27.433161), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745381398, 'Avenida Carlos María de Alvear y Villa Carlos Paz', 'Parada C07616',
        st_setsrid(st_point(-59.019437, -27.434659), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745381399, 'Avenida Carlos María de Alvear y San Carlos de Bariloche', 'Parada C07615',
        st_setsrid(st_point(-59.017736, -27.436129), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745381400, 'Avenida Carlos María de Alvear y Paso de la Patria', 'Parada C07614',
        st_setsrid(st_point(-59.016006, -27.437703), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745381402, 'Avenida 25 de Mayo y General Uriburu', 'Parada C01609',
        st_setsrid(st_point(-59.001675, -27.437619), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745381403, 'Avenida 25 de Mayo y Padre Cerqueira', 'Parada C01606',
        st_setsrid(st_point(-58.996215, -27.442464), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745381404, 'Avenida 25 de Mayo y República de Israel', 'Parada C00229',
        st_setsrid(st_point(-59.009118, -27.432725), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745381405, 'Avenida Carlos María de Alvear y República de Israel', 'Parada C01601',
        st_setsrid(st_point(-59.015522, -27.438232), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745381406, 'Avenida Carlos María de Alvear e Isla del Cerrito', 'Parada C01569',
        st_setsrid(st_point(-59.017196, -27.436771), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745381408, 'Avenida Carlos María de Alvear y Sierras de Córdoba', 'Parada C01568',
        st_setsrid(st_point(-59.019118, -27.435080), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745381409, 'Avenida Carlos María de Alvear y Mar del Plata', 'Parada C01567',
        st_setsrid(st_point(-59.021438, -27.433005), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745381410, 'Avenida Carlos María de Alvear y Lago Nahuel Huapi', 'Parada C01600',
        st_setsrid(st_point(-59.023589, -27.431089), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745381411, 'Avenida Carlos María de Alvear y Almirante Brown', 'Parada C01566',
        st_setsrid(st_point(-59.025519, -27.429362), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745381412, 'Avenida Carlos María de Alvear y Neuquén', 'Parada C01565',
        st_setsrid(st_point(-59.027322, -27.427777), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745381414, 'Avenida Carlos María de Alvear y Avenida Güemes', 'Parada C01563',
        st_setsrid(st_point(-59.030733, -27.424737), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745381415, 'Avenida Carlos María de Alvear y Pasaje Carlos M. de Alvear', 'Parada C01562',
        st_setsrid(st_point(-59.032424, -27.423242), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745381416, 'Avenida Carlos María de Alvear y Domingo Faustino Sarmiento', 'Parada C01561',
        st_setsrid(st_point(-59.035167, -27.420822), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745381417, 'Avenida Carlos María de Alvear y Avenida Augusto Rey', 'Parada C01560',
        st_setsrid(st_point(-59.037933, -27.418395), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745381418, 'Brasil y Diagonal Juan Bautista Cabral', 'Parada C01628',
        st_setsrid(st_point(-59.040684, -27.416948), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745381419, 'Diagonal Hartenek y Brasil', 'Parada C07613',
        st_setsrid(st_point(-59.041521, -27.417683), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745381420, 'Diagonal Hartenek y Uruguay', 'Parada C07612',
        st_setsrid(st_point(-59.044598, -27.416346), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745381421, 'Diagonal Hartenek y Cacuí', 'Parada C07611',
        st_setsrid(st_point(-59.047058, -27.415279), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745381422, 'Diagonal Hartenek y Pasaje Quebracho', 'Parada C07610',
        st_setsrid(st_point(-59.049790, -27.414065), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745381423, 'San Luis y Diagonal Juan Bautista Cabral', 'Parada C07609',
        st_setsrid(st_point(-59.049103, -27.412736), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745381424, 'Misiones y Pasaje Mendoza', 'Parada C01599',
        st_setsrid(st_point(-59.046611, -27.409478), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745381425, 'Misiones y Pasaje Moreno', 'Parada C01554',
        st_setsrid(st_point(-59.044905, -27.407946), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745381426, 'Misiones y Pasaje Santiago del Estero', 'Parada C01553',
        st_setsrid(st_point(-59.044066, -27.407195), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745381427, 'Misiones y Pasaje Salta', 'Parada C01552',
        st_setsrid(st_point(-59.042781, -27.406050), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745381433, 'Misiones y Juan Domingo Perón', 'Parada C01597',
        st_setsrid(st_point(-59.041541, -27.404941), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745381434, 'Avenida 25 de Mayo y Misiones', 'Parada C01551',
        st_setsrid(st_point(-59.040206, -27.403519), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745381435, 'Avenida 25 de Mayo y Tierra del Fuego', 'Parada C07604',
        st_setsrid(st_point(-59.042402, -27.401558), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843007, 'Carlos Gardel y Formosa', 'Parada C01697',
        st_setsrid(st_point(-59.053706, -27.413791), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843008, 'Carlos Gardel y Formosa', 'Parada C01617',
        st_setsrid(st_point(-59.053858, -27.413656), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843009, 'Misiones y Carlos Gardel', 'Parada C01696',
        st_setsrid(st_point(-59.052644, -27.414517), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843010, 'Lima y Quebracho', 'Parada C01694',
        st_setsrid(st_point(-59.050244, -27.415451), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843011, 'Lima y Avenida Cacuí', 'Parada C01693',
        st_setsrid(st_point(-59.049297, -27.416290), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843012, 'Uruguay y Lima', 'Parada C01692',
        st_setsrid(st_point(-59.046532, -27.418349), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843013, 'Brasil y Comandante Fontana', 'Parada C01689',
        st_setsrid(st_point(-59.042347, -27.418674), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843014, 'Brasil y Pasaje Carlos M. de Alvear', 'Parada C01687',
        st_setsrid(st_point(-59.040885, -27.417291), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843015, 'Brasil y Diagonal Juan Bautista Cabral', 'Parada C01686',
        st_setsrid(st_point(-59.040502, -27.416640), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843016, 'Uruguay y Mendoza', 'Parada C01684',
        st_setsrid(st_point(-59.040949, -27.412949), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843017, 'Santiago del Estero y Perú', 'Parada C01682',
        st_setsrid(st_point(-59.037694, -27.412224), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843018, 'Brasil y Santiago del Estero', 'Parada C01681',
        st_setsrid(st_point(-59.036530, -27.413057), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843019, 'Brasil y Salta', 'Parada C01680',
        st_setsrid(st_point(-59.035620, -27.412242), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843022, 'Brasil y Pasaje Julio Argentino Roca', 'Parada C01679',
        st_setsrid(st_point(-59.034053, -27.410838), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843023, 'Avenida 25 de Mayo y Brasil', 'Parada C01678',
        st_setsrid(st_point(-59.032903, -27.409939), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843025, 'Avenida Augusto Rey y Avenida 25 de Mayo', 'Parada C03274',
        st_setsrid(st_point(-59.030649, -27.412201), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843026, 'Juan Domingo Perón y Avenida Augusto Rey', 'Parada C01672',
        st_setsrid(st_point(-59.032413, -27.414010), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843027, 'Avenida 25 de Mayo y Lapacho', 'Parada C00205',
        st_setsrid(st_point(-59.028691, -27.413622), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843029, 'San Juan y Pasaje 25 de Mayo', 'Parada C01669',
        st_setsrid(st_point(-59.025186, -27.418021), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843030, 'Diagonal Salta y San Juan', 'Parada C01668',
        st_setsrid(st_point(-59.027372, -27.420720), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843031, 'Santiago del Estero y Avenida Güemes', 'Parada C01667',
        st_setsrid(st_point(-59.026904, -27.421809), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843032, 'Santiago del Estero y Pasaje Chubut', 'Parada C01666',
        st_setsrid(st_point(-59.024898, -27.423600), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843033, 'Lucio Salvadores y Santiago del Estero', 'Parada C01665',
        st_setsrid(st_point(-59.022658, -27.425371), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843034, 'Lucio Salvadores y Salta', 'Parada C01664',
        st_setsrid(st_point(-59.021549, -27.424386), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843035, 'Lucio Salvadores y Julio Argentino Roca', 'Parada C01663',
        st_setsrid(st_point(-59.019844, -27.422872), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843036, 'Avenida 25 de Mayo y Calle N°3', 'Parada C00212',
        st_setsrid(st_point(-59.018829, -27.422387), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843038, 'Avenida 25 de Mayo y Rioja', 'Parada C00201',
        st_setsrid(st_point(-59.017041, -27.423983), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843039, 'Avenida 25 de Mayo y Armando Anello', 'Parada C00200',
        st_setsrid(st_point(-59.014247, -27.426452), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843040, 'Avenida 25 de Mayo y Mario Nestoroff', 'Parada C01662',
        st_setsrid(st_point(-59.013366, -27.427231), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843041, 'Avenida 25 de Mayo y Avenida de la Democracia', 'Parada C07025',
        st_setsrid(st_point(-59.011160, -27.429204), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843042, 'Avenida 25 de Mayo y Pío XII', 'Parada C01659',
        st_setsrid(st_point(-58.995257, -27.443319), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843043, 'Avenida 25 de Mayo y Avenida Belgrano', 'Parada C01605',
        st_setsrid(st_point(-58.990636, -27.447400), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843044, 'Lima y Avenida Cacuí', 'Parada C01621',
        st_setsrid(st_point(-59.049609, -27.416013), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843046, 'Avenida 25 de Mayo y Cataratas del Iguazú', 'Parada C01653',
        st_setsrid(st_point(-59.013777, -27.427015), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843047, 'Avenida 25 de Mayo y María Moisán', 'Parada C00225',
        st_setsrid(st_point(-59.015789, -27.425223), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843048, 'Avenida 25 de Mayo y Rioja', 'Parada C00224',
        st_setsrid(st_point(-59.017362, -27.423841), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843051, 'Lucio Salvadores y Julio Argentino Roca', 'Parada C01651',
        st_setsrid(st_point(-59.020124, -27.423120), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843052, 'Lucio Salvadores y Salta', 'Parada C01650',
        st_setsrid(st_point(-59.021781, -27.424592), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843054, 'Santiago del Estero y Lucio Salvadores', 'Parada C01649',
        st_setsrid(st_point(-59.022902, -27.425375), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843055, 'Santiago del Estero y Pasaje Chubut Bis', 'Parada C01648',
        st_setsrid(st_point(-59.024512, -27.423941), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843056, 'Santiago del Estero y Bahía Blanca', 'Parada C01647',
        st_setsrid(st_point(-59.025392, -27.423160), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843067, 'Diagonal Salta y Avenida Güemes', 'Parada C01646',
        st_setsrid(st_point(-59.026907, -27.421320), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843068, 'San Juan y Diagonal Salta', 'Parada C01645',
        st_setsrid(st_point(-59.027303, -27.420452), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843169, 'San Juan y Julio Argentino Roca', 'Parada C01644',
        st_setsrid(st_point(-59.025518, -27.418307), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843170, 'Avenida 25 de Mayo y Timbó', 'Parada C07005',
        st_setsrid(st_point(-59.025682, -27.416452), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843172, 'Lapacho y Juan Domingo Perón', 'Parada C01671',
        st_setsrid(st_point(-59.031091, -27.414872), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843173, 'Lapacho y Pasaje Salta', 'Parada C01642',
        st_setsrid(st_point(-59.032367, -27.416014), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843175, 'Avenida Augusto Rey y Santiago del Estero', 'Parada C01673',
        st_setsrid(st_point(-59.034208, -27.415226), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843176, 'Avenida 25 de Mayo y Avenida Augusto Rey', 'Parada C00218',
        st_setsrid(st_point(-59.030696, -27.411902), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843178, 'Brasil y Avenida 25 de Mayo', 'Parada C01636',
        st_setsrid(st_point(-59.033080, -27.409966), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843179, 'Brasil y Pasaje Julio Argentino Roca', 'Parada C01635',
        st_setsrid(st_point(-59.034268, -27.411031), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843180, 'Brasil y Salta', 'Parada C01634',
        st_setsrid(st_point(-59.035848, -27.412446), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843181, 'Santiago del Estero y Brasil', 'Parada C01633',
        st_setsrid(st_point(-59.036769, -27.413054), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843182, 'Santiago del Estero y Perú', 'Parada C01632',
        st_setsrid(st_point(-59.038004, -27.411949), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843183, 'Uruguay y Mendoza', 'Parada C01630',
        st_setsrid(st_point(-59.041205, -27.413177), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843184, 'Brasil y Pasaje Carlos M. de Alvear', 'Parada C01627',
        st_setsrid(st_point(-59.041001, -27.417479), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843185, 'Brasil y Felipe Molina', 'Parada C01626',
        st_setsrid(st_point(-59.041697, -27.418098), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843186, 'Brasil y Comandante Fontana', 'Parada C01625',
        st_setsrid(st_point(-59.042556, -27.418858), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843187, 'Uruguay y Nicolás Roldán', 'Parada C01623',
        st_setsrid(st_point(-59.045735, -27.417636), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843188, 'Lima y Uruguay', 'Parada C01622',
        st_setsrid(st_point(-59.046921, -27.418393), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843189, 'Misiones y Lima', 'Parada C01619',
        st_setsrid(st_point(-59.052096, -27.414015), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843190, 'Carlos Gardel y Misiones', 'Parada C01618',
        st_setsrid(st_point(-59.052893, -27.414520), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843191, 'Lima y Pasaje Quebracho', 'Parada C01620',
        st_setsrid(st_point(-59.050459, -27.415261), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11745843192, 'Carlos Gardel y Aromos', 'Parada C01616',
        st_setsrid(st_point(-59.054309, -27.413255), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748061216, 'Avenida Maipú y Pasaje Maipú', 'Parada C00242',
        st_setsrid(st_point(-58.912336, -27.465864), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748061217, 'Avenida Maipú y Avenida General San Martín', 'Parada C00241',
        st_setsrid(st_point(-58.914165, -27.464232), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748061218, 'Avenida General San Martín y E. Garrido', 'Parada C03293',
        st_setsrid(st_point(-58.919347, -27.467799), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748061219, 'Avenida General San Martín y Avenida Diagonal Las Piedras', 'Parada C00237',
        st_setsrid(st_point(-58.922144, -27.470321), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748061220, 'Avenida General San Martín y Misiones', 'Parada C00236',
        st_setsrid(st_point(-58.923988, -27.471986), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748061221, 'Avenida General San Martín y San Juan', 'Parada C02024',
        st_setsrid(st_point(-58.926544, -27.474283), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748061223, 'Avenida General San Martín y Alice Le Saige', 'Parada C00233',
        st_setsrid(st_point(-58.932560, -27.479680), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748061224, 'Avenida General San Martín y Sargento Cabral', 'Parada C00232',
        st_setsrid(st_point(-58.935288, -27.482128), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748061225, 'Avenida Hernandarias y Salta', 'Parada C02010',
        st_setsrid(st_point(-58.996237, -27.447396), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748061227, 'Capitán Pedro Giachino y Avenida Marconi', 'Parada C02007',
        st_setsrid(st_point(-59.010533, -27.455660), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748061229, 'Capitán Pedro Giachino e Inmaculada Concepción', 'Parada C02006',
        st_setsrid(st_point(-59.012277, -27.457220), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748061230, 'Capitán Pedro Giachino y Padre Tomás García', 'Parada C02005',
        st_setsrid(st_point(-59.013968, -27.458732), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748061232, 'Avenida Islas Malvinas y Capitán Pedro Giachino', 'Parada C02002',
        st_setsrid(st_point(-59.017619, -27.461724), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748061233, 'Avenida Islas Malvinas y María Sáenz de Vernet', 'Parada C02001',
        st_setsrid(st_point(-59.019391, -27.460143), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748061234, 'Avenida Islas Malvinas y Avenida Mac Lean', 'Parada C02000',
        st_setsrid(st_point(-59.021957, -27.457871), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748061236, 'Capitán Pedro Giachino y López Vicuña', 'Parada C02047',
        st_setsrid(st_point(-59.013257, -27.458097), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748061237, 'Capitán Pedro Giachino e Inmaculada Concepción', 'Parada C02046',
        st_setsrid(st_point(-59.012057, -27.457023), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748061238, 'Avenida Marconi y Capitán Pedro Giachino', 'Parada C02045',
        st_setsrid(st_point(-59.010238, -27.455551), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748061239, 'Avenida Hernandarias y Jujuy', 'Parada C02040',
        st_setsrid(st_point(-58.998762, -27.449316), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748061241, 'Avenida General San Martín y Sargento Cabral', 'Parada C00194',
        st_setsrid(st_point(-58.935091, -27.481819), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748061242, 'Avenida General San Martín y Alice Le Saige', 'Parada C00193',
        st_setsrid(st_point(-58.932451, -27.479451), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748061243, 'Avenida General San Martín y Asunción', 'Parada C00192',
        st_setsrid(st_point(-58.930836, -27.478004), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748061246, 'Avenida General San Martín y Misiones', 'Parada C02034',
        st_setsrid(st_point(-58.923874, -27.471750), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748061247, 'Avenida Diagonal Las Piedras y Avenida General San Martín', 'Parada 00247',
        st_setsrid(st_point(-58.921665, -27.470236), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748061248, 'Avenida Diagonal Las Piedras y Fray Mamerto Esquiú', 'Parada C00245',
        st_setsrid(st_point(-58.917392, -27.472281), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748061249, 'General Belgrano y Avenida Diagonal Las Piedras', 'Parada C00244',
        st_setsrid(st_point(-58.912287, -27.471650), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748190364, 'Alfonsina Storni', 'Parada C07603',
        st_setsrid(st_point(-58.948822, -27.460926), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748190365, 'Alfonsina Storni y Alicia Moreau de Justo', 'Parada C07015',
        st_setsrid(st_point(-58.948827, -27.462802), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748190367, 'Eva Perón y Avenida Lonardi', 'Parada C07017',
        st_setsrid(st_point(-58.950048, -27.465081), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748190368, 'Avenida Carmen C. Viuda de Ross y Avenida Lonardi', 'Parada C07011',
        st_setsrid(st_point(-58.952356, -27.463122), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748231669, 'Emilio R. Román y Ayacucho', 'Parada C07009',
        st_setsrid(st_point(-58.960755, -27.467993), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748231670, 'Emilio R. Román e Hipólito Yrigoyen', 'Parada C07008',
        st_setsrid(st_point(-58.963347, -27.470313), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748231673, 'Avenida 25 de Mayo y Almirante Brown', 'Parada C07007',
        st_setsrid(st_point(-59.018238, -27.423060), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748231674, 'Avenida 25 de Mayo y Chubut', 'Parada C00222',
        st_setsrid(st_point(-59.020917, -27.420679), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748231675, 'Avenida 25 de Mayo y Bahía Blanca', 'Parada C07006',
        st_setsrid(st_point(-59.021770, -27.419923), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748231680, 'Avenida Güemes y Pasaje Santiago del Estero', 'Parada C07002',
        st_setsrid(st_point(-59.027769, -27.422256), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748231681, 'Avenida Güemes y Avenida Carlos María de Alvear', 'Parada C07001',
        st_setsrid(st_point(-59.030761, -27.424970), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748231682, 'Avenida Güemes y Nicolás Roldán', 'Parada C07000',
        st_setsrid(st_point(-59.034142, -27.427998), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748231683, 'Avenida Güemes y Dos de Febrero', 'Parada C07033',
        st_setsrid(st_point(-59.037432, -27.430947), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748231693, 'Avenida Güemes y Nicolás Roldán', 'Parada C07032',
        st_setsrid(st_point(-59.033850, -27.427737), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748231694, 'Avenida Güemes y Avenida Carlos María de Alvear', 'Parada C07031',
        st_setsrid(st_point(-59.030356, -27.424598), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748231695, 'Avenida Güemes y Pasaje Santiago del Estero', 'Parada C07030',
        st_setsrid(st_point(-59.027563, -27.422069), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748231696, 'Avenida 25 de Mayo y Lapacho', 'Parada C07027',
        st_setsrid(st_point(-59.029122, -27.412913), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748231697, 'Santa Fe y Corrientes', 'Parada C07028',
        st_setsrid(st_point(-59.027365, -27.411540), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748231698, 'Santa Fe y Pasaje Santa Fe', 'Parada C07029',
        st_setsrid(st_point(-59.025525, -27.413423), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748231699, 'Avenida 25 de Mayo y Timbó', 'Parada C07005',
        st_setsrid(st_point(-59.025404, -27.416561), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748231700, 'Avenida 25 de Mayo y San Juan', 'Parada C00203',
        st_setsrid(st_point(-59.024377, -27.417465), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748231701, 'Avenida 25 de Mayo y Calle N°6', 'Parada C00202',
        st_setsrid(st_point(-59.021459, -27.420056), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748231702, 'Avenida 25 de Mayo y Calle N°2', 'Parada C07026',
        st_setsrid(st_point(-59.017900, -27.423213), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748231703, 'Avenida 9 de Julio y Avenida Nicolás Rojas Acosta', 'Parada C07024',
        st_setsrid(st_point(-58.975450, -27.460868), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748231704, 'Avenida Carmen C. Viuda de Ross y Avenida 9 de Julio', 'Parada C07023',
        st_setsrid(st_point(-58.964833, -27.470096), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748231705, 'Avenida Carmen C. Viuda de Ross y Ayacucho', 'Parada C07022',
        st_setsrid(st_point(-58.961370, -27.466993), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748231706, 'Avenida Carmen C. Viuda de Ross', 'Parada C07021',
        st_setsrid(st_point(-58.959151, -27.464993), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748231707, 'Avenida Carmen C. Viuda de Ross', 'Parada C07020',
        st_setsrid(st_point(-58.955315, -27.464256), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748231715, 'Avenida Lonardi y Avenida Carmen C. Viuda de Ross', 'Parada C07019',
        st_setsrid(st_point(-58.952121, -27.463069), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748231717, 'Victoria Ocampo y Rosa Guarú', 'Parada C07014',
        st_setsrid(st_point(-58.947900, -27.464869), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748231718, 'Alfonsina Storni y Eva Perón', 'Parada C07016',
        st_setsrid(st_point(-58.948830, -27.463904), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748231719, 'Alfonsina Storni y Alicia Moreau de Justo', 'Parada C07764',
        st_setsrid(st_point(-58.948827, -27.462559), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748231720, 'Alfonsina Storni', 'Parada C07763',
        st_setsrid(st_point(-58.948929, -27.460748), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748727232, 'Avenida Libertador General San Martín y Santa Lucía', 'Parada C01800',
        st_setsrid(st_point(-58.942047, -27.513430), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748727233, 'Avenida Juan José Castelli y Avenida Nicolás Rojas Acosta', 'Parada C00271',
        st_setsrid(st_point(-58.950729, -27.495596), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748727235, 'Algarrobo y José Mármol', 'Parada C00269',
        st_setsrid(st_point(-58.955856, -27.495840), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748727236, 'Algarrobo y Avenida José María Toledo', 'Parada C00268',
        st_setsrid(st_point(-58.957647, -27.497462), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748727237, 'Carlos Hardy y Algarrobo', 'Parada C00267',
        st_setsrid(st_point(-58.959260, -27.498726), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748727238, 'Carlos Hardy y Timbó', 'Parada C00266',
        st_setsrid(st_point(-58.960929, -27.497250), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748727239, 'Sauce y Carlos Hardy', 'Parada C00265',
        st_setsrid(st_point(-58.962776, -27.495407), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748727240, 'Algarrobo y Avenida José María Toledo', 'Parada C00262',
        st_setsrid(st_point(-58.957333, -27.497189), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748727241, 'Avenida 9 de Julio y Carriego', 'Parada C00261',
        st_setsrid(st_point(-58.937752, -27.494290), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748727242, 'Almirante Brown y Avenida Sebastián Gaboto', 'Parada C00260',
        st_setsrid(st_point(-58.934439, -27.493755), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748727243, 'Almirante Brown y Güiraldes', 'Parada C00259',
        st_setsrid(st_point(-58.936162, -27.492227), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748727244, 'Almirante Brown y Fray Mamerto Esquiú', 'Parada C00258',
        st_setsrid(st_point(-58.938040, -27.490562), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748727245, 'Miguel Cané y Pirovano', 'Parada C00257',
        st_setsrid(st_point(-58.937723, -27.489074), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748727246, 'Miguel Cané y Paraguay', 'Parada C00256',
        st_setsrid(st_point(-58.936004, -27.487522), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748727247, 'Fray Mocho y León Zorrilla', 'Parada C00255',
        st_setsrid(st_point(-58.927026, -27.482567), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748727248, 'Asunción y Fray Mocho', 'Parada C00254',
        st_setsrid(st_point(-58.926501, -27.481785), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748727249, 'Asunción y Miguel Cané', 'Parada C00253',
        st_setsrid(st_point(-58.928263, -27.480234), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748727250, 'Asunción y Joaquín Víctor González', 'Parada C00252',
        st_setsrid(st_point(-58.930018, -27.478679), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748727251, 'Don Orione y Asunción', 'Parada C00251',
        st_setsrid(st_point(-58.931662, -27.477201), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748727252, 'Avenida Padre Rissione y Don Orione', 'Parada C00250',
        st_setsrid(st_point(-58.930159, -27.475657), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748727253, 'Chile y Avenida Padre Rissione', 'Parada C00249',
        st_setsrid(st_point(-58.931615, -27.474103), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748727254, 'Pasteur y Chile', 'Parada C00248',
        st_setsrid(st_point(-58.930746, -27.473606), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748727255, 'Avenida General San Martín y Pasteur', 'Parada C00191',
        st_setsrid(st_point(-58.927985, -27.475443), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748727256, 'Avenida General San Martín y Aconquija', 'Parada C00190',
        st_setsrid(st_point(-58.925581, -27.473282), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11748727257, 'Avenida Diagonal Las Piedras y Dos de Febrero', 'Parada C00246',
        st_setsrid(st_point(-58.919091, -27.471483), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11749241726, 'Avenida Maipú y Avenida General San Martín', 'Parada C05566',
        st_setsrid(st_point(-58.914374, -27.464014), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11749241727, 'Avenida Maipú y Pasaje Maipú', 'Parada C00185',
        st_setsrid(st_point(-58.912608, -27.465621), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11749241728, 'Avenida Diagonal Las Piedras y Dos de Febrero', 'Parada C00238',
        st_setsrid(st_point(-58.919515, -27.471368), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11749241729, 'Pasteur y Avenida General San Martín', 'Parada C00291',
        st_setsrid(st_point(-58.928484, -27.475586), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11749241730, 'Pasteur y Guido Spano', 'Parada C00290',
        st_setsrid(st_point(-58.930185, -27.474095), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11749241731, 'Avenida Padre Rissione y Chile', 'Parada C00289',
        st_setsrid(st_point(-58.931649, -27.474343), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11749241732, 'Avenida Padre Rissione y Don Orione', 'Parada C00288',
        st_setsrid(st_point(-58.929887, -27.475895), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11749241733, 'Asunción y Avenida General San Martín', 'Parada C00287',
        st_setsrid(st_point(-58.930630, -27.478126), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11749241734, 'Asunción y Joaquín Víctor González', 'Parada C00286',
        st_setsrid(st_point(-58.929755, -27.478912), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11749241735, 'Asunción y Miguel Cané', 'Parada C00285',
        st_setsrid(st_point(-58.927905, -27.480546), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11749241736, 'Miguel Cané y Avenida Laprida', 'Parada C00281',
        st_setsrid(st_point(-58.933668, -27.485419), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11749241737, 'Miguel Cané y Paraguay', 'Parada C00280',
        st_setsrid(st_point(-58.936275, -27.487765), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11749241738, 'Ayacucho y Dos de Febrero', 'Parada C07773',
        st_setsrid(st_point(-58.938000, -27.487531), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11749241739, 'Ayacucho y Guido Spano', 'Parada C07772',
        st_setsrid(st_point(-58.941772, -27.484534), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11749241743, 'Parada C01809', null,
        st_setsrid(st_point(-58.927381, -27.532680), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11749262544, 'Avenida General San Martín y Pasteur', 'Parada C00235',
        st_setsrid(st_point(-58.928341, -27.475904), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11749262546, 'Avenida 25 de Mayo y Brasil', 'Parada C00216',
        st_setsrid(st_point(-59.033117, -27.409753), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11749262547, 'Avenida 25 de Mayo y Venezuela', 'Parada C00215',
        st_setsrid(st_point(-59.036152, -27.407080), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11749262548, 'Avenida 25 de Mayo y Avenida Italia', 'Parada C00214',
        st_setsrid(st_point(-59.037883, -27.405568), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750237002, 'Misiones y Pasaje Salta', 'Parada C01547',
        st_setsrid(st_point(-59.042931, -27.406184), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750237003, 'Misiones y Pasaje Santiago del Estero', 'Parada C01546',
        st_setsrid(st_point(-59.044259, -27.407367), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750237004, 'Misiones y García Merou', 'Parada C01550',
        st_setsrid(st_point(-59.047796, -27.410534), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750237005, 'Diagonal Juan Bautista Cabral y San Luis', 'Parada C01543',
        st_setsrid(st_point(-59.049084, -27.413020), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750237006, 'Avenida Carlos María de Alvear y Pasaje Carlos M. de Alvear', 'Parada C01539',
        st_setsrid(st_point(-59.032007, -27.423509), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750237008, 'Avenida Carlos María de Alvear y Cataratas del Iguazú', 'Parada C01532',
        st_setsrid(st_point(-59.020324, -27.433848), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750237009, 'Avenida Carlos María de Alvear y Sierras de Córdoba', 'Parada C01531',
        st_setsrid(st_point(-59.018548, -27.435428), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750237010, 'Avenida Carlos María de Alvear e Isla del Cerrito', 'Parada C01530',
        st_setsrid(st_point(-59.016840, -27.436940), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750237011, 'Avenida Carlos María de Alvear y Carlos Campia', 'Parada C01529',
        st_setsrid(st_point(-59.013052, -27.440161), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750237012, 'Avenida Juan José Castelli y Avenida Alberdi', 'Parada C01519',
        st_setsrid(st_point(-58.993280, -27.457556), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750237013, 'Avenida Juan José Castelli y José María Paz', 'Parada C01518',
        st_setsrid(st_point(-58.991533, -27.459091), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750237014, 'Avenida Juan José Castelli y Colón', 'Parada C01517',
        st_setsrid(st_point(-58.989832, -27.460600), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750237015, 'Avenida Juan José Castelli y Arbo y Blanco', 'Parada C01516',
        st_setsrid(st_point(-58.988021, -27.462204), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750237016, 'Avenida Las Heras y Avenida Carlos López Piacentini', 'Parada C01514',
        st_setsrid(st_point(-58.988405, -27.465652), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750237021, 'Avenida Las Heras y Carlos Dodero', 'Parada C01513',
        st_setsrid(st_point(-58.990154, -27.467211), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750237022, 'Avenida Las Heras y Seitor', 'Parada C01512',
        st_setsrid(st_point(-58.992021, -27.468881), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750237023, 'Avenida Édison y Juan de Dios Mena', 'Parada C01511',
        st_setsrid(st_point(-58.992622, -27.471139), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750237024, 'Avenida Édison y Lisandro de la Torre', 'Parada C01510',
        st_setsrid(st_point(-58.990827, -27.472746), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750237025, 'Avenida Édison y Silvano Dante', 'Parada C01507',
        st_setsrid(st_point(-58.984324, -27.478537), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750237026, 'Avenida Édison y Miguel Z. Delfino', 'Parada C01505',
        st_setsrid(st_point(-58.980848, -27.481631), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750237027, 'Avenida Urquiza y Fortín Warnes', 'Parada C01504',
        st_setsrid(st_point(-58.980152, -27.483943), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750237028, 'Avenida Urquiza y Pasaje Fortín Rivadavia', 'Parada C01502',
        st_setsrid(st_point(-58.983110, -27.486583), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750237029, 'Avenida Urquiza y Fortín Los Pozos', 'Parada C01501',
        st_setsrid(st_point(-58.985006, -27.488271), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750237034, 'Avenida Édison y Avenida Chaco', 'Parada C03303',
        st_setsrid(st_point(-58.986685, -27.476576), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750237035, 'Avenida Édison y Juan de Dios Mena', 'Parada C01585',
        st_setsrid(st_point(-58.992976, -27.471011), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750237036, 'Avenida Las Heras y Seitor', 'Parada C01584',
        st_setsrid(st_point(-58.991932, -27.468474), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750237041, 'Avenida Las Heras y Carlos Dodero', 'Parada C01583',
        st_setsrid(st_point(-58.990066, -27.466802), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750237042, 'Avenida Las Heras y Avenida Carlos López Piacentini', 'Parada C01582',
        st_setsrid(st_point(-58.988137, -27.465105), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750237043, 'Avenida Juan José Castelli y Arbo y Blanco', 'Parada C01580',
        st_setsrid(st_point(-58.988550, -27.462035), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750237044, 'Avenida Juan José Castelli y Colón', 'Parada C01579',
        st_setsrid(st_point(-58.990321, -27.460475), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750237045, 'Avenida Juan José Castelli y José María Paz', 'Parada C01578',
        st_setsrid(st_point(-58.992048, -27.458954), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750237048, 'Avenida Carlos María de Alvear y Fray Rossi', 'Parada C01573',
        st_setsrid(st_point(-59.007266, -27.445488), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750237049, 'Avenida Carlos María de Alvear y Avenida Mac Lean', 'Parada C01572',
        st_setsrid(st_point(-59.008311, -27.444577), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750237050, 'Avenida Carlos María de Alvear y General Fotheringam', 'Parada C01571',
        st_setsrid(st_point(-59.010924, -27.442253), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750237051, 'Avenida Carlos María de Alvear y Carlos Campia', 'Parada C01570',
        st_setsrid(st_point(-59.013232, -27.440190), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750237052, 'Diagonal Juan Bautista Cabral y Brasil', 'Parada C01559',
        st_setsrid(st_point(-59.040729, -27.416773), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750237055, 'Diagonal Juan Bautista Cabral y Pasaje Buenos Aires', 'Parada C01558',
        st_setsrid(st_point(-59.044966, -27.414931), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750237057, 'Misiones y Felipe Molina', 'Parada C01556',
        st_setsrid(st_point(-59.048606, -27.411261), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750237058, 'Misiones y García Merou', 'Parada C01555',
        st_setsrid(st_point(-59.047697, -27.410446), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750237059, 'Avenida 25 de Mayo y Artigas', 'Parada C00211',
        st_setsrid(st_point(-59.040478, -27.403277), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750237060, 'Avenida 25 de Mayo y Avenida Cacuí', 'Parada C00210',
        st_setsrid(st_point(-59.037613, -27.405803), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750237061, 'Avenida 25 de Mayo y Venezuela', 'Parada C00209',
        st_setsrid(st_point(-59.035872, -27.407326), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750237063, 'Avenida 25 de Mayo y Chile', 'Parada C00208',
        st_setsrid(st_point(-59.033771, -27.409196), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750237064, 'Avenida 25 de Mayo y Avenida Augusto Rey', 'Parada C00206',
        st_setsrid(st_point(-59.030427, -27.412091), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750237065, 'Avenida 9 de Julio y Agrimensor Agustín Foster', 'Parada C01019',
        st_setsrid(st_point(-58.958494, -27.475924), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750237066, 'Avenida General San Martín y Misiones', 'Parada C00189',
        st_setsrid(st_point(-58.923447, -27.471368), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750717853, 'La Tigra y Capitán Solari', 'Parada C07781',
        st_setsrid(st_point(-58.989347, -27.399288), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750717854, 'Avenida Juana Azurduy y Taco Pozo', 'Parada C07779',
        st_setsrid(st_point(-58.987907, -27.399063), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750717855, 'Avenida Juana Azurduy y Ciervo Petiso', 'Parada C07780',
        st_setsrid(st_point(-58.989654, -27.397491), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750717856, 'Avenida de la Democracia y Avenida Antonio Martina', 'Parada C06775',
        st_setsrid(st_point(-58.998439, -27.402944), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750717857, 'Avenida de la Democracia y Juan Manuel Fangio', 'Parada C07258',
        st_setsrid(st_point(-58.998815, -27.403976), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750717858, 'Avenida de la Democracia y Eduardo Gerónimo Orcola', 'Parada C07266',
        st_setsrid(st_point(-58.999429, -27.405552), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750717859, 'Diagonal Eva Perón y Saavedra', 'Parada C03254',
        st_setsrid(st_point(-58.940116, -27.482886), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750717860, 'Avenida General San Martín y Juan Ramón Lestani', 'Parada C03252',
        st_setsrid(st_point(-58.934108, -27.480936), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750717861, 'Avenida General San Martín y San Luis', 'Parada C07251',
        st_setsrid(st_point(-58.927412, -27.474930), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750717862, 'Avenida General San Martín y Avenida Diagonal Las Piedras', 'Parada C00188',
        st_setsrid(st_point(-58.921898, -27.469973), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750717863, 'Avenida General San Martín y Estanislao del Campo', 'Parada C03250',
        st_setsrid(st_point(-58.918230, -27.466684), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750717864, 'Avenida General San Martín y San Luis', 'Parada C07272',
        st_setsrid(st_point(-58.927571, -27.475227), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750717865, 'Avenida General San Martín y Juan Ramón Lestani', 'Parada C07271',
        st_setsrid(st_point(-58.934279, -27.481213), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750717866, 'Avenida 25 de Mayo y Fray Bertaca', 'Parada C01654',
        st_setsrid(st_point(-59.004388, -27.435393), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750717867, 'Avenida Juana Azurduy y Ciervo Petiso', 'Parada C07784',
        st_setsrid(st_point(-58.989320, -27.397650), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750717868, 'Taco Pozo y Avenida Juana Azurduy', 'Parada C07783',
        st_setsrid(st_point(-58.987885, -27.399233), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750745069, 'La Tigra y Capitán Solari', 'Parada C07782',
        st_setsrid(st_point(-58.989640, -27.399036), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750809185, 'Avenida General San Martín y Avenida Padre Rissione', 'Parada C03292',
        st_setsrid(st_point(-58.929244, -27.476704), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750809186, 'Avenida General San Martín y Asunción', 'Parada C02023',
        st_setsrid(st_point(-58.930958, -27.478237), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750809189, 'Avenida Soberanía Nacional y Pago de Areco', 'Parada C03284',
        st_setsrid(st_point(-58.989973, -27.486269), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750809190, 'Avenida Islas Malvinas y Avenida Alberdi', 'Parada C03283',
        st_setsrid(st_point(-59.008080, -27.470194), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750809191, 'Avenida Islas Malvinas y Avenida Hernandarias', 'Parada C03282',
        st_setsrid(st_point(-59.015409, -27.463704), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750809192, 'Avenida Islas Malvinas y Avenida Mac Lean', 'Parada C03281',
        st_setsrid(st_point(-59.022553, -27.457361), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750809195, 'Avenida Augusto Rey y Avenida Carlos María de Alvear', 'Parada C03278',
        st_setsrid(st_point(-59.037639, -27.418266), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750809196, 'Avenida 25 de Mayo y Chile', 'Parada C03277',
        st_setsrid(st_point(-59.033605, -27.409338), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750809198, 'Avenida 25 de Mayo y Misiones', 'Parada C03276',
        st_setsrid(st_point(-59.039933, -27.403761), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750809200, 'Avenida Augusto Rey y Santiago del Estero', 'Parada C03273',
        st_setsrid(st_point(-59.034464, -27.415608), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750809201, 'Avenida de la Democracia y Avenida Marconi', 'Parada C03270',
        st_setsrid(st_point(-59.022059, -27.445433), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750809202, 'Avenida Islas Malvinas y Capitán Pedro Giachino', 'Parada C03269',
        st_setsrid(st_point(-59.017325, -27.461986), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750809203, 'Avenida Islas Malvinas y Avenida Hernandarias', 'Parada C03268',
        st_setsrid(st_point(-59.014907, -27.464156), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750809204, 'Avenida Soberanía Nacional y Avenida Chaco', 'Parada C03267',
        st_setsrid(st_point(-58.993333, -27.483295), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750809205, 'Avenida Juan José Castelli y Capataz Codutti', 'Parada C07790',
        st_setsrid(st_point(-58.970186, -27.478231), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750809206, 'Diagonal Eva Perón y Pirovano', 'Parada C03255',
        st_setsrid(st_point(-58.945150, -27.482912), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (11750809207, 'Avenida General San Martín y Avenida Padre Rissione', 'Parada C03251',
        st_setsrid(st_point(-58.928945, -27.476314), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (12112457212, 'Casa de las Culturas', 'Parada C07792',
        st_setsrid(st_point(-58.986070, -27.449892), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (12113205579, 'Fortín Tapenagá y Miguel Z. Delfino', 'Parada C07876',
        st_setsrid(st_point(-58.987360, -27.487021), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (12120184002, 'Casa de Gobierno', 'Parada C07791',
        st_setsrid(st_point(-58.987045, -27.449915), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (12144077502, 'Necochea y Salta', 'Parada C00072',
        st_setsrid(st_point(-58.991573, -27.451017), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (12144077505, 'Correo', 'Parada C07800',
        st_setsrid(st_point(-58.985459, -27.450516), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (12144077507, 'Avenida 9 de Julio y José María Paz', 'Parada C07798',
        st_setsrid(st_point(-58.984957, -27.452593), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (12144077508, 'Juan de la Cruz Navarro y Ruta Nacional 11', 'Parada C00008',
        st_setsrid(st_point(-59.054750, -27.474387), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (12146079713, 'Avenida Sarmiento y Don Bosco', 'Parada C07808',
        st_setsrid(st_point(-58.983994, -27.448965), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (12146079714, 'Julio Argentino Roca y Santa María de Oro', 'Parada C07794',
        st_setsrid(st_point(-58.987926, -27.451473), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (12146079715, 'Avenida 25 de Mayo y Santa María de Oro', 'Parada C07793',
        st_setsrid(st_point(-58.987577, -27.450244), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (12146079716, 'Avenida Sarmiento y Marcelo Torcuato de Alvear', 'Parada C07801',
        st_setsrid(st_point(-58.985541, -27.450172), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (12150561832, 'Avenida Belgrano y Carlos Gardel', 'Parada C07913',
        st_setsrid(st_point(-59.002962, -27.458148), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (12150561833, 'Avenida Hernandarias y Primero de Mayo', 'Parada C07811',
        st_setsrid(st_point(-59.006609, -27.456517), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (12150561834, 'Primero de Mayo y Echeverría', 'Parada C07812',
        st_setsrid(st_point(-59.004769, -27.457901), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (12150561835, 'Juan B. Justo y Roque Sáenz Peña', 'Parada C07805',
        st_setsrid(st_point(-58.984919, -27.454130), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (12150561836, 'Santiago del Estero y Necochea', 'Parada C07807',
        st_setsrid(st_point(-58.992418, -27.452054), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (12150561837, 'Santa María de Oro y Santiago del Estero', 'Parada C07804',
        st_setsrid(st_point(-58.990730, -27.453328), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (12150561838, 'Santa María de Oro y Julio Argentino Roca', 'Parada C07803',
        st_setsrid(st_point(-58.989033, -27.451814), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (12151464203, 'Avenida Marconi y Avenida Hernandarias', 'Parada C07813',
        st_setsrid(st_point(-59.008168, -27.457540), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (12151464204, 'Salta y Santa María de Oro', 'Parada C02327',
        st_setsrid(st_point(-58.990184, -27.452517), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (12151464205, 'Avenida Belgrano y Salta', 'Parada C013012',
        st_setsrid(st_point(-58.993575, -27.449765), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (12155249141, 'Arturo Frondizi y Juan B. Justo', 'Parada C07797',
        st_setsrid(st_point(-58.986310, -27.452535), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (12155249142, 'Ameghino y Arturo Frondizi', 'Parada C07814',
        st_setsrid(st_point(-58.988903, -27.455183), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (12234899800, 'Santiago del Estero y Necochea', 'Parada C00072',
        st_setsrid(st_point(-58.992719, -27.451794), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (12261001798, 'Avenida 9 de Julio y Avenida Italia', 'Parada C07806',
        st_setsrid(st_point(-58.982334, -27.454913), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (12261001799, 'Avenida 9 de Julio y Roque Sáenz Peña', 'Parada C07834',
        st_setsrid(st_point(-58.984109, -27.453338), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;
insert into public.stops (osm_node_id, name, description, geom, is_active)
values (13173603252, 'Avenida Rivadavia y San Buenaventura del Monte Alto', null,
        st_setsrid(st_point(-58.990413, -27.440040), 4326)::geography, true)
on conflict (osm_node_id) do update set
    name = excluded.name,
    description = excluded.description,
    geom = excluded.geom,
    is_active = true;

-- ------------------------------------------------------------
-- 3. Recorridos con su trazado (73)
-- ------------------------------------------------------------
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '5'),
        'Ida: UOM → Villa Luisa', 'A', 0,
        st_geomfromtext('LINESTRING(-58.972118 -27.502245, -58.979256 -27.495895, -58.976314 -27.493259, -58.979860 -27.490094, -58.981267 -27.488862, -58.984215 -27.491521, -58.989911 -27.486477, -58.988945 -27.485628, -58.989860 -27.479829, -58.986410 -27.476688, -58.989210 -27.474173, -58.986500 -27.471771, -58.986921 -27.468909, -58.983897 -27.468550, -58.982533 -27.467382, -58.982521 -27.467300, -58.986235 -27.463979, -58.986271 -27.463739, -58.983177 -27.460971, -58.982287 -27.461737, -58.981907 -27.461408, -58.989071 -27.455035, -58.984745 -27.451139, -58.985587 -27.450399, -58.978463 -27.444002, -58.979411 -27.443171, -58.980266 -27.443936, -59.000829 -27.425685, -59.002722 -27.427350)', 4326),
        4578434, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '5'),
        'Vuelta: Villa Luisa → Bariro UOM', 'A', 1,
        st_geomfromtext('LINESTRING(-59.002722 -27.427350, -58.999760 -27.429946, -59.000989 -27.431055, -58.999483 -27.432377, -58.996424 -27.429629, -58.986674 -27.438344, -58.986630 -27.438401, -58.986730 -27.438535, -58.980443 -27.444102, -58.988299 -27.451144, -58.980379 -27.458175, -58.986215 -27.463418, -58.986671 -27.463690, -58.986624 -27.463881, -58.986345 -27.464015, -58.982601 -27.467317, -58.983978 -27.468467, -58.988955 -27.469079, -58.992051 -27.471822, -58.986547 -27.476696, -58.989953 -27.479757, -58.988982 -27.485654, -58.989911 -27.486477, -58.984215 -27.491521, -58.981267 -27.488862, -58.979860 -27.490094, -58.976314 -27.493259, -58.979256 -27.495895, -58.972604 -27.501821, -58.972741 -27.501914, -58.972717 -27.502073, -58.972420 -27.502285, -58.972330 -27.502288, -58.972204 -27.502158)', 4326),
        4578435, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '5'),
        'Ida: Barrio UOM → Villa Chica', 'B', 0,
        st_geomfromtext('LINESTRING(-58.972118 -27.502245, -58.979256 -27.495895, -58.976314 -27.493259, -58.979860 -27.490094, -58.981267 -27.488862, -58.984215 -27.491521, -58.989911 -27.486477, -58.988945 -27.485628, -58.989860 -27.479829, -58.986564 -27.476886, -58.986436 -27.476653, -58.991004 -27.472590, -58.994641 -27.475864, -59.000005 -27.471137, -58.985534 -27.458140, -58.989071 -27.455035, -58.984745 -27.451139, -58.985587 -27.450399, -58.981214 -27.446471, -58.982151 -27.445628, -58.983005 -27.446396, -58.997307 -27.433735, -58.997374 -27.433556, -58.996567 -27.432781, -58.998235 -27.431250, -58.999483 -27.432377, -59.000989 -27.431055, -58.999760 -27.429946, -59.002722 -27.427350)', 4326),
        4578459, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '5'),
        'Vuelta: Villa Chica → Barrio UOM', 'B', 1,
        st_geomfromtext('LINESTRING(-59.002722 -27.427350, -58.999760 -27.429946, -59.000989 -27.431055, -58.999483 -27.432377, -58.998235 -27.431250, -58.996567 -27.432781, -58.997527 -27.433699, -58.983104 -27.446484, -58.988299 -27.451144, -58.987434 -27.451907, -58.989166 -27.453438, -58.984776 -27.457320, -59.000111 -27.471050, -58.994537 -27.475944, -58.991020 -27.472739, -58.986547 -27.476696, -58.989953 -27.479757, -58.988982 -27.485654, -58.989911 -27.486477, -58.984215 -27.491521, -58.981267 -27.488862, -58.979860 -27.490094, -58.976314 -27.493259, -58.979256 -27.495895, -58.972604 -27.501821, -58.972741 -27.501914, -58.972717 -27.502073, -58.972420 -27.502285, -58.972330 -27.502288, -58.972204 -27.502158)', 4326),
        4578460, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '5'),
        'Ida: Barrio UOM → Villa Luisa', 'C', 0,
        st_geomfromtext('LINESTRING(-58.972118 -27.502245, -58.979256 -27.495895, -58.976314 -27.493259, -58.979860 -27.490094, -58.981267 -27.488862, -58.984215 -27.491521, -58.989911 -27.486477, -58.988945 -27.485628, -58.989860 -27.479829, -58.983844 -27.474389, -58.983862 -27.474208, -58.986447 -27.471903, -58.987361 -27.466037, -58.988099 -27.465371, -58.986487 -27.463935, -58.986333 -27.463882, -58.986271 -27.463739, -58.983177 -27.460971, -58.982287 -27.461737, -58.981907 -27.461408, -58.989071 -27.455035, -58.984745 -27.451139, -58.985587 -27.450399, -58.981214 -27.446471, -58.982151 -27.445628, -58.983005 -27.446396, -58.985568 -27.444097, -58.982845 -27.441631, -58.996368 -27.429624, -58.997079 -27.429075, -59.000829 -27.425685, -59.002722 -27.427350)', 4326),
        4580355, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '5'),
        'Vuelta: Villa Luisa → Barrio UOM', 'C', 1,
        st_geomfromtext('LINESTRING(-59.002722 -27.427350, -58.999760 -27.429946, -59.000989 -27.431055, -59.000148 -27.431793, -59.001994 -27.433452, -59.001357 -27.434036, -58.996424 -27.429629, -58.986674 -27.438344, -58.986630 -27.438401, -58.986730 -27.438535, -58.984841 -27.440224, -58.987467 -27.442598, -58.983104 -27.446484, -58.988299 -27.451144, -58.987434 -27.451907, -58.989166 -27.453438, -58.982090 -27.459700, -58.986215 -27.463418, -58.986632 -27.463631, -58.986675 -27.463806, -58.988436 -27.465328, -58.988402 -27.465462, -58.987631 -27.466137, -58.986736 -27.471958, -58.984035 -27.474376, -58.989953 -27.479757, -58.988982 -27.485654, -58.989911 -27.486477, -58.984215 -27.491521, -58.981267 -27.488862, -58.979860 -27.490094, -58.976314 -27.493259, -58.979256 -27.495895, -58.972604 -27.501821, -58.972741 -27.501914, -58.972717 -27.502073, -58.972420 -27.502285, -58.972330 -27.502288, -58.972204 -27.502158)', 4326),
        4580356, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '8'),
        'Ida: Asentamiento 29 de Agosto → Barrio Víctor Balussi', 'A', 0,
        st_geomfromtext('LINESTRING(-59.036693 -27.457563, -59.036938 -27.457778, -59.036936 -27.458007, -59.036766 -27.458206, -59.036433 -27.458303, -59.034945 -27.457047, -59.029156 -27.451807, -59.028972 -27.451876, -59.027778 -27.452929, -59.025990 -27.454337, -59.017111 -27.446389, -59.017098 -27.443910, -59.016347 -27.443203, -59.016353 -27.443134, -59.014083 -27.443153, -59.011994 -27.441302, -58.995402 -27.455982, -58.995307 -27.455897, -58.993504 -27.457498, -58.987350 -27.451981, -58.973087 -27.464639, -58.979035 -27.470001, -58.979264 -27.470183, -58.979383 -27.470188, -58.983002 -27.473413, -58.989953 -27.479757, -58.988982 -27.485654, -58.989911 -27.486477, -58.986439 -27.489547)', 4326),
        4600305, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '8'),
        'Vuelta: Barrio Víctor Valussi → Asentamiento 29 de Agosto', 'A', 1,
        st_geomfromtext('LINESTRING(-58.986439 -27.489547, -58.972022 -27.476613, -58.979206 -27.470233, -58.973887 -27.465450, -58.983835 -27.456623, -58.981194 -27.454255, -58.986512 -27.449551, -58.988299 -27.451144, -58.987434 -27.451907, -58.993521 -27.457344, -58.999790 -27.451759, -59.000434 -27.451231, -59.000935 -27.450970, -59.012984 -27.440220, -59.014735 -27.441700, -59.016559 -27.441744, -59.016505 -27.443102, -59.017277 -27.443906, -59.017103 -27.444015, -59.017111 -27.446389, -59.025990 -27.454337, -59.028836 -27.451799, -59.028898 -27.451573, -59.028743 -27.451423, -59.028721 -27.451170, -59.028974 -27.450955, -59.029274 -27.450911, -59.036693 -27.457563)', 4326),
        4600306, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '9'),
        'Ida: Barrio 17 de Octubre → Hipermercado Libertad', 'A', 0,
        st_geomfromtext('LINESTRING(-58.969516 -27.478922, -58.971242 -27.480462, -58.972098 -27.479690, -58.977528 -27.484553, -58.977841 -27.484279, -58.979101 -27.485405, -58.978968 -27.485529, -58.984931 -27.490886, -58.989911 -27.486477, -58.988945 -27.485628, -58.989883 -27.479688, -58.993620 -27.483015, -59.007884 -27.470369, -58.987430 -27.452046, -58.987350 -27.451981, -58.986515 -27.452719, -58.984745 -27.451139, -58.986512 -27.449551, -58.987388 -27.450316, -58.993449 -27.444901, -58.986543 -27.438704, -58.983894 -27.441065, -58.979779 -27.437244, -58.979199 -27.436354, -58.979232 -27.435350, -58.979502 -27.434537, -58.980013 -27.433849, -58.980372 -27.433176, -58.980450 -27.432691, -58.980398 -27.432129, -58.977493 -27.425016, -58.976985 -27.424093, -58.976556 -27.423497, -58.976616 -27.423451, -58.975769 -27.422444, -58.975702 -27.422507, -58.973602 -27.419971, -58.969465 -27.416204, -58.969018 -27.415599, -58.968735 -27.415432, -58.968344 -27.415327, -58.968209 -27.415172, -58.968203 -27.414970, -58.968429 -27.414696, -58.969494 -27.414431, -58.970870 -27.413727, -58.970645 -27.413408, -58.970406 -27.413474)', 4326),
        4717752, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '9'),
        'Vuelta: Hipermercado Libertad → Barrio 17 de Octubre', 'A', 1,
        st_geomfromtext('LINESTRING(-58.970695 -27.413445, -58.970529 -27.413415, -58.969604 -27.413857, -58.967033 -27.415237, -58.961224 -27.409988, -58.964217 -27.407265, -58.962476 -27.405698, -58.963484 -27.404793, -58.967555 -27.408470, -58.971600 -27.404894, -58.973896 -27.406934, -58.969845 -27.410538, -58.972230 -27.412692, -58.970695 -27.413445, -58.970529 -27.413415, -58.969604 -27.413857, -58.967223 -27.415087, -58.966862 -27.415425, -58.965042 -27.416374, -58.965199 -27.416641, -58.967787 -27.415294, -58.968495 -27.414660, -58.968932 -27.414565, -58.969161 -27.414663, -58.969278 -27.414870, -58.969170 -27.415248, -58.969195 -27.415549, -58.969431 -27.416055, -58.973557 -27.419800, -58.977067 -27.424044, -58.977430 -27.424663, -58.978127 -27.426281, -58.980587 -27.432447, -58.981016 -27.433038, -58.982097 -27.433606, -58.982293 -27.433813, -58.982214 -27.435748, -58.982325 -27.436060, -58.982578 -27.436213, -58.984096 -27.436459, -58.984747 -27.436734, -58.994565 -27.445571, -58.990015 -27.449634, -58.991737 -27.451161, -58.989166 -27.453438, -59.007970 -27.470293, -58.993522 -27.483128, -58.989926 -27.479893, -58.988982 -27.485654, -58.989911 -27.486477, -58.984931 -27.490886, -58.978968 -27.485529, -58.979101 -27.485405, -58.977841 -27.484279, -58.978394 -27.483788, -58.971259 -27.477400, -58.969516 -27.478922)', 4326),
        4717753, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '9'),
        'Ida: Villa Don Andrés → Hiper Libertad', 'B', 0,
        st_geomfromtext('LINESTRING(-59.003591 -27.483954, -58.999074 -27.487988, -58.996220 -27.485437, -59.005259 -27.477390, -59.006163 -27.476490, -59.009073 -27.479119, -59.013355 -27.475267, -59.012215 -27.474250, -59.014868 -27.471886, -59.011429 -27.468814, -59.008755 -27.471162, -58.987430 -27.452046, -58.987350 -27.451981, -58.986515 -27.452719, -58.984745 -27.451139, -58.986512 -27.449551, -58.987388 -27.450316, -58.993449 -27.444901, -58.986543 -27.438704, -58.983894 -27.441065, -58.979850 -27.437330, -58.979199 -27.436354, -58.979232 -27.435350, -58.979502 -27.434537, -58.980013 -27.433849, -58.980372 -27.433176, -58.980450 -27.432691, -58.980398 -27.432129, -58.977493 -27.425016, -58.976985 -27.424093, -58.976556 -27.423497, -58.973602 -27.419971, -58.969465 -27.416204, -58.969018 -27.415599, -58.968735 -27.415432, -58.968344 -27.415327, -58.968187 -27.415103, -58.968232 -27.414911, -58.968429 -27.414696, -58.969494 -27.414431, -58.970870 -27.413727, -58.970695 -27.413445, -58.972139 -27.412741, -58.969786 -27.410592, -58.977009 -27.404161, -58.976471 -27.403673, -58.976592 -27.403646, -58.978061 -27.402335, -58.981048 -27.405019, -58.984056 -27.402339, -58.986725 -27.404701, -58.986011 -27.405331, -58.986960 -27.406165, -58.984904 -27.408071, -58.983633 -27.408064, -58.981902 -27.408259, -58.979770 -27.406258)', 4326),
        4717754, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '9'),
        'Vuelta: Hipermercado Libertad → Villa Don Alberto', 'B', 1,
        st_geomfromtext('LINESTRING(-58.979824 -27.406211, -58.982027 -27.408230, -58.983633 -27.408064, -58.984904 -27.408071, -58.986960 -27.406165, -58.986011 -27.405331, -58.986725 -27.404701, -58.984137 -27.402413, -58.981114 -27.405079, -58.978061 -27.402335, -58.976592 -27.403646, -58.976471 -27.403673, -58.977009 -27.404161, -58.969845 -27.410538, -58.972230 -27.412692, -58.970695 -27.413445, -58.970529 -27.413415, -58.969604 -27.413857, -58.967223 -27.415087, -58.966862 -27.415425, -58.965042 -27.416374, -58.965199 -27.416641, -58.967787 -27.415294, -58.968495 -27.414660, -58.968932 -27.414565, -58.969161 -27.414663, -58.969278 -27.414870, -58.969170 -27.415248, -58.969195 -27.415549, -58.969431 -27.416055, -58.973557 -27.419800, -58.977067 -27.424044, -58.977430 -27.424663, -58.978127 -27.426281, -58.980587 -27.432447, -58.981016 -27.433038, -58.982097 -27.433606, -58.982293 -27.433813, -58.982214 -27.435748, -58.982325 -27.436060, -58.982578 -27.436213, -58.984096 -27.436459, -58.984747 -27.436734, -58.994565 -27.445571, -58.987434 -27.451907, -59.007970 -27.470293, -59.008282 -27.470740, -59.008625 -27.471047, -59.008771 -27.471031, -59.013406 -27.475175, -59.008986 -27.479192, -59.006103 -27.476594, -58.996220 -27.485437, -58.999074 -27.487988, -59.001858 -27.485523, -59.001000 -27.484735, -59.001860 -27.483984, -59.002724 -27.484754)', 4326),
        4717755, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '12'),
        'Ida: Don Santiago → Rotonda Villa Monona', 'A', 0,
        st_geomfromtext('LINESTRING(-58.990638 -27.398399, -58.990352 -27.398857, -58.990626 -27.399590, -58.993196 -27.398794, -58.994332 -27.401662, -58.997523 -27.400659, -58.996662 -27.398510, -58.997420 -27.398263, -59.001325 -27.408170, -59.001553 -27.408931, -59.001419 -27.409407, -59.001650 -27.410487, -59.001840 -27.410844, -59.002601 -27.411787, -59.002706 -27.412284, -59.002715 -27.412902, -59.002925 -27.413378, -59.003592 -27.413988, -59.003900 -27.414981, -59.004806 -27.417076, -59.005997 -27.418814, -59.006346 -27.419582, -59.007149 -27.420362, -59.007886 -27.420733, -59.008482 -27.421357, -59.009073 -27.422139, -59.009525 -27.423192, -59.010312 -27.427488, -59.010934 -27.430409, -59.010711 -27.430686, -59.010426 -27.430739, -59.010125 -27.430699, -59.009832 -27.430803, -59.009776 -27.430995, -59.009841 -27.431418, -59.009666 -27.431904, -59.009280 -27.432547, -59.008598 -27.433270, -59.007601 -27.433999, -59.005099 -27.434994, -59.004237 -27.435489, -58.987440 -27.450362, -58.988299 -27.451144, -58.986515 -27.452719, -58.985684 -27.451977, -58.956047 -27.478234, -58.952255 -27.474834, -58.951045 -27.475274, -58.953384 -27.477393, -58.948898 -27.481387, -58.950363 -27.482759)', 4326),
        4764419, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '12'),
        'Vuelta: Villa Monona → Don Santiago', 'A', 1,
        st_geomfromtext('LINESTRING(-58.950605 -27.482886, -58.985516 -27.451965, -58.985590 -27.451893, -58.984745 -27.451139, -58.986512 -27.449551, -58.987388 -27.450316, -59.004166 -27.435421, -59.005117 -27.434878, -59.007159 -27.434090, -59.007881 -27.433697, -59.008393 -27.433341, -59.008934 -27.432805, -59.009584 -27.431853, -59.009734 -27.431395, -59.009664 -27.430776, -59.010102 -27.430178, -59.009163 -27.425004, -59.008641 -27.422775, -59.008161 -27.421885, -59.007844 -27.421481, -59.006332 -27.419990, -59.005182 -27.419046, -59.004397 -27.417943, -59.004042 -27.417261, -59.002888 -27.414127, -59.002967 -27.413636, -59.002705 -27.413252, -59.001993 -27.412567, -59.001707 -27.412132, -59.001601 -27.411717, -59.001618 -27.410854, -59.001335 -27.409511, -59.001142 -27.409006, -59.000649 -27.408702, -58.997523 -27.400659, -58.994332 -27.401662, -58.992757 -27.397687, -58.990638 -27.398399, -58.990352 -27.398857, -58.990626 -27.399590)', 4326),
        4764420, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '12'),
        'Ida: Parque Autódromo → Barrio Don Bosco', 'B', 0,
        st_geomfromtext('LINESTRING(-58.999497 -27.396886, -58.997898 -27.395453, -58.996751 -27.396548, -58.995995 -27.396790, -58.995953 -27.396697, -58.992757 -27.397687, -58.994332 -27.401662, -58.991726 -27.402474, -58.991678 -27.402576, -58.994927 -27.405519, -58.995228 -27.405904, -58.996961 -27.407468, -58.998443 -27.406200, -58.999555 -27.405873, -58.999390 -27.405454, -59.000163 -27.405206, -59.001522 -27.408720, -59.001553 -27.408931, -59.001419 -27.409407, -59.001680 -27.410571, -59.002601 -27.411787, -59.002706 -27.412284, -59.002715 -27.412902, -59.002996 -27.413499, -59.003592 -27.413988, -59.003900 -27.414981, -59.004806 -27.417076, -59.005997 -27.418814, -59.006445 -27.419701, -59.007274 -27.420452, -59.007886 -27.420733, -59.008828 -27.421754, -59.009073 -27.422139, -59.009525 -27.423192, -59.010312 -27.427488, -59.010934 -27.430409, -59.010854 -27.430567, -59.010546 -27.430728, -59.010125 -27.430699, -59.009832 -27.430803, -59.009776 -27.430995, -59.009841 -27.431418, -59.009666 -27.431904, -59.009280 -27.432547, -59.008598 -27.433270, -59.007601 -27.433999, -59.005099 -27.434994, -59.004237 -27.435489, -58.987440 -27.450362, -58.988299 -27.451144, -58.986515 -27.452719, -58.985684 -27.451977, -58.969321 -27.466442, -58.965831 -27.463323, -58.964968 -27.464073, -58.961280 -27.460770, -58.964993 -27.457469, -58.964517 -27.457013)', 4326),
        4764421, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '12'),
        'Vuelta: Barrio Don Bosco → Parque Autódromo', 'B', 1,
        st_geomfromtext('LINESTRING(-58.964517 -27.457013, -58.963116 -27.458244, -58.963620 -27.458687, -58.961280 -27.460770, -58.968386 -27.467149, -58.985516 -27.451965, -58.985590 -27.451893, -58.984745 -27.451139, -58.986512 -27.449551, -58.987388 -27.450316, -59.004166 -27.435421, -59.005117 -27.434878, -59.007159 -27.434090, -59.007881 -27.433697, -59.008393 -27.433341, -59.008934 -27.432805, -59.009584 -27.431853, -59.009734 -27.431395, -59.009664 -27.430776, -59.010102 -27.430178, -59.009163 -27.425004, -59.008641 -27.422775, -59.008161 -27.421885, -59.007844 -27.421481, -59.006332 -27.419990, -59.005182 -27.419046, -59.004397 -27.417943, -59.004042 -27.417261, -59.002888 -27.414127, -59.002967 -27.413636, -59.002705 -27.413252, -59.001993 -27.412567, -59.001670 -27.412041, -59.001601 -27.411717, -59.001618 -27.410854, -59.001335 -27.409511, -59.001142 -27.409006, -59.000649 -27.408702, -58.999555 -27.405873, -58.998443 -27.406200, -58.996961 -27.407468, -58.995228 -27.405904, -58.994927 -27.405519, -58.991678 -27.402576, -58.991726 -27.402474, -58.997523 -27.400659, -58.995674 -27.395938, -58.996438 -27.395731, -58.996697 -27.396408, -58.996867 -27.396381, -58.997898 -27.395453, -58.999497 -27.396886)', 4326),
        4764422, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '8'),
        'Ida: Asentamiento 29 de Agosto → Barrio UOM (ramal D)', 'D', 0,
        st_geomfromtext('LINESTRING(-59.036693 -27.457563, -59.036938 -27.457778, -59.036936 -27.458007, -59.036766 -27.458206, -59.036433 -27.458303, -59.034188 -27.456363, -59.032938 -27.457460, -59.027778 -27.452929, -59.025990 -27.454337, -59.015418 -27.444856, -59.011765 -27.448180, -59.003466 -27.440739, -58.989083 -27.453514, -58.987350 -27.451981, -58.983065 -27.455764, -58.984776 -27.457320, -58.981936 -27.459838, -58.980218 -27.458309, -58.973087 -27.464639, -58.979035 -27.470001, -58.979264 -27.470183, -58.979383 -27.470188, -58.983002 -27.473413, -58.986547 -27.476696, -58.977930 -27.484359, -58.972070 -27.489456, -58.977685 -27.494494)', 4326),
        4764431, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '8'),
        'Vuelta: Barrio UOM → Asentamiento 29 de Agosto (ramal D)', 'D', 1,
        st_geomfromtext('LINESTRING(-58.977685 -27.494494, -58.980337 -27.492168, -58.978048 -27.490063, -58.978556 -27.489613, -58.975217 -27.486606, -58.986410 -27.476688, -58.973887 -27.465450, -58.983835 -27.456623, -58.981194 -27.454255, -58.986512 -27.449551, -58.990872 -27.453450, -59.004446 -27.441410, -59.011826 -27.448065, -59.015418 -27.444856, -59.025990 -27.454337, -59.027778 -27.452929, -59.034869 -27.459186, -59.036107 -27.458035, -59.035815 -27.457679, -59.036009 -27.457371, -59.036148 -27.457286, -59.036373 -27.457280, -59.036693 -27.457563)', 4326),
        4764432, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '8'),
        'Ida: Asentamiento 29 de Agosto → Barrio UOM (ramal C)', 'C', 0,
        st_geomfromtext('LINESTRING(-59.036693 -27.457563, -59.036938 -27.457778, -59.036936 -27.458007, -59.036766 -27.458206, -59.036433 -27.458303, -59.034945 -27.457047, -59.029156 -27.451807, -59.028972 -27.451876, -59.027778 -27.452929, -59.025990 -27.454337, -59.015418 -27.444856, -59.011765 -27.448180, -59.003466 -27.440739, -58.989083 -27.453514, -58.987350 -27.451981, -58.983065 -27.455764, -58.984776 -27.457320, -58.981936 -27.459838, -58.980218 -27.458309, -58.979335 -27.459081, -58.978466 -27.458334, -58.972223 -27.463885, -58.979035 -27.470001, -58.979264 -27.470183, -58.979383 -27.470188, -58.967955 -27.480326, -58.975154 -27.486777, -58.972070 -27.489456, -58.979256 -27.495895)', 4326),
        4764433, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '8'),
        'Vuelta: Barrio UOM → Asentamiento 29 de Agosto (ramal C)', 'C', 1,
        st_geomfromtext('LINESTRING(-58.977685 -27.494494, -58.980337 -27.492168, -58.978048 -27.490063, -58.979867 -27.488452, -58.977785 -27.486573, -58.976471 -27.487737, -58.975284 -27.486667, -58.975154 -27.486777, -58.975088 -27.486721, -58.967886 -27.480268, -58.979206 -27.470233, -58.973887 -27.465450, -58.983835 -27.456623, -58.981194 -27.454255, -58.986512 -27.449551, -58.990872 -27.453450, -59.004446 -27.441410, -59.011826 -27.448065, -59.015418 -27.444856, -59.025990 -27.454337, -59.028836 -27.451799, -59.028898 -27.451573, -59.028743 -27.451423, -59.028721 -27.451170, -59.028974 -27.450955, -59.029274 -27.450911, -59.036693 -27.457563)', 4326),
        4764434, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '101'),
        'Ida', null, 0,
        st_geomfromtext('LINESTRING(-58.928109 -27.488341, -58.924574 -27.485064, -58.927184 -27.482708, -58.931747 -27.486798, -58.936209 -27.482764, -58.936943 -27.482872, -58.949683 -27.482934, -58.950605 -27.482886, -58.985516 -27.451965, -58.985590 -27.451893, -58.984745 -27.451139, -58.986512 -27.449551, -58.987388 -27.450316, -58.992604 -27.445661, -58.991747 -27.444895, -58.992780 -27.443957, -58.995435 -27.446338, -58.998112 -27.443940, -59.010654 -27.455179, -59.012494 -27.453545, -59.012510 -27.453683, -59.013337 -27.454446)', 4326),
        7948963, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '101'),
        'Vuelta: Barrio Santa Inés → Barranqueras', null, 1,
        st_geomfromtext('LINESTRING(-59.013337 -27.454446, -59.012498 -27.455174, -59.011663 -27.454427, -59.010732 -27.455249, -59.000639 -27.446207, -58.999718 -27.447117, -58.998003 -27.445580, -58.996102 -27.447274, -58.993532 -27.444967, -58.987440 -27.450362, -58.988299 -27.451144, -58.986515 -27.452719, -58.985684 -27.451977, -58.984717 -27.452795, -58.950587 -27.483121, -58.950469 -27.483159, -58.950299 -27.483055, -58.949654 -27.483000, -58.936332 -27.482975, -58.935271 -27.483792, -58.931838 -27.486878, -58.927184 -27.482708, -58.925453 -27.484257, -58.928019 -27.486617, -58.927102 -27.487426, -58.928109 -27.488341)', 4326),
        7948964, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '104'),
        'Vuelta: 200 Viviendas → Barrio Jorge Newbery', null, 1,
        st_geomfromtext('LINESTRING(-58.955758 -27.498847, -58.954035 -27.497279, -58.954897 -27.496524, -58.952237 -27.494150, -58.968742 -27.479511, -58.965139 -27.476265, -58.982788 -27.460617, -58.978422 -27.456706, -58.986512 -27.449551, -58.988299 -27.451144, -58.987434 -27.451907, -58.993521 -27.457344, -58.999790 -27.451759, -59.000434 -27.451231, -59.000935 -27.450970, -59.008034 -27.444617, -59.011826 -27.448065, -59.015418 -27.444856, -59.025990 -27.454337, -59.028836 -27.451799, -59.028898 -27.451573, -59.019141 -27.442803, -59.019681 -27.442331, -59.020010 -27.442630, -59.020145 -27.442502)', 4326),
        7952025, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '104'),
        'Ida: Barrio Jorge Newbery → Barrio 200 Viviendas', null, 0,
        st_geomfromtext('LINESTRING(-59.020010 -27.442630, -59.029878 -27.451457, -59.029825 -27.451711, -59.029691 -27.451874, -59.029358 -27.451986, -59.029156 -27.451807, -59.028972 -27.451876, -59.027778 -27.452929, -59.025990 -27.454337, -59.015418 -27.444856, -59.011765 -27.448180, -59.008008 -27.444835, -58.995402 -27.455982, -58.995307 -27.455897, -58.993504 -27.457498, -58.987350 -27.451981, -58.986515 -27.452719, -58.985684 -27.451977, -58.984717 -27.452795, -58.982224 -27.455011, -58.984776 -27.457320, -58.981936 -27.459838, -58.979364 -27.457538, -58.975875 -27.460629, -58.972223 -27.463885, -58.974777 -27.466169, -58.964293 -27.475500, -58.968811 -27.479566, -58.956900 -27.490126, -58.961262 -27.494078, -58.955830 -27.498902)', 4326),
        7952026, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '106'),
        'Vuelta: Puerto Vilelas → Barrio Perón', 'A', 1,
        st_geomfromtext('LINESTRING(-58.923864 -27.535775, -58.940237 -27.521249, -58.940946 -27.520344, -58.941513 -27.519173, -58.941760 -27.517030, -58.942510 -27.503163, -58.942226 -27.502523, -58.942171 -27.501722, -58.941730 -27.500937, -58.941314 -27.500439, -58.936903 -27.496475, -58.936019 -27.496070, -58.935880 -27.495760, -58.935958 -27.495524, -58.936088 -27.495400, -58.936447 -27.495318, -58.936856 -27.495088, -58.938582 -27.493583, -58.950139 -27.483295, -58.950313 -27.483082, -58.950312 -27.482907, -58.950605 -27.482886, -58.951544 -27.482063, -58.985516 -27.451965, -58.985590 -27.451893, -58.984745 -27.451139, -58.988229 -27.448015, -58.994362 -27.453517, -58.998928 -27.449467, -59.015115 -27.463967, -59.009675 -27.468767, -59.008297 -27.467549, -59.006580 -27.469058, -59.008060 -27.470376, -59.007977 -27.470459, -59.008282 -27.470740, -59.008690 -27.471105, -59.008771 -27.471031, -59.015037 -27.476633)', 4326),
        7962485, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '106'),
        'Ida: Barrio Perón → 200 Viviendas', 'C', 0,
        st_geomfromtext('LINESTRING(-59.014185 -27.476008, -58.987430 -27.452046, -58.987350 -27.451981, -58.986515 -27.452719, -58.985684 -27.451977, -58.954251 -27.479802, -58.950587 -27.483121, -58.950469 -27.483159, -58.950299 -27.483055, -58.949654 -27.483000, -58.943565 -27.482973, -58.941645 -27.484647, -58.954897 -27.496524, -58.955766 -27.495758, -58.957553 -27.497384, -58.955830 -27.498902)', 4326),
        7962486, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '107'),
        'Ida: Resistencia Centro → Cementerio Fontana', 'B', 0,
        st_geomfromtext('LINESTRING(-58.986512 -27.449551, -58.987388 -27.450316, -59.004166 -27.435421, -59.005117 -27.434878, -59.007463 -27.433947, -59.008393 -27.433341, -59.008934 -27.432805, -59.009584 -27.431853, -59.009734 -27.431395, -59.009664 -27.430776, -59.010102 -27.430178, -59.009972 -27.429480, -59.010124 -27.429300, -59.010430 -27.429224, -59.010635 -27.429292, -59.010760 -27.429521, -59.010882 -27.429453, -59.019059 -27.422175, -59.022779 -27.425478, -59.022902 -27.425375, -59.027089 -27.421640, -59.026848 -27.421422, -59.027445 -27.420619, -59.026477 -27.419542, -59.026210 -27.418932, -59.024466 -27.417385, -59.029183 -27.413180, -59.031273 -27.415034, -59.032547 -27.413893, -59.030478 -27.412048, -59.032975 -27.409873, -59.036648 -27.413163, -59.038918 -27.411140, -59.042505 -27.414335, -59.040248 -27.416346, -59.040349 -27.416391, -59.041281 -27.417912, -59.041622 -27.418032, -59.043348 -27.419555, -59.045619 -27.417526, -59.046751 -27.418543, -59.051975 -27.413904, -59.052770 -27.414632, -59.055277 -27.412390, -59.057090 -27.414039, -59.052093 -27.418501)', 4326),
        7964199, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '110'),
        'Vuelta: La Toma → Los Cisnes', null, 1,
        st_geomfromtext('LINESTRING(-58.910451 -27.467552, -58.910363 -27.467919, -58.910428 -27.468081, -58.910361 -27.468517, -58.910434 -27.468780, -58.912341 -27.471732, -58.915786 -27.472538, -58.916563 -27.472666, -58.921825 -27.470160, -58.922067 -27.470126, -58.935716 -27.482380, -58.936338 -27.482816, -58.936943 -27.482872, -58.946589 -27.482921, -58.950605 -27.482886, -58.985516 -27.451965, -58.985590 -27.451893, -58.984745 -27.451139, -58.986512 -27.449551, -58.990872 -27.453450, -58.997142 -27.447868, -59.007973 -27.457582, -59.010329 -27.455469, -59.017463 -27.461859, -59.024842 -27.455356)', 4326),
        7986997, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '110'),
        'Ida: Los Cisnes → La Toma', null, 0,
        st_geomfromtext('LINESTRING(-59.024842 -27.455356, -59.017463 -27.461859, -59.010408 -27.455548, -59.007954 -27.457728, -59.000816 -27.451307, -59.000547 -27.451181, -58.999706 -27.450498, -58.996102 -27.447274, -58.989083 -27.453514, -58.987350 -27.451981, -58.986515 -27.452719, -58.985684 -27.451977, -58.954251 -27.479802, -58.950636 -27.483080, -58.950469 -27.483159, -58.950299 -27.483055, -58.949654 -27.483000, -58.937085 -27.482958, -58.936153 -27.483004, -58.935872 -27.482653, -58.934161 -27.481106, -58.919246 -27.467706, -58.914875 -27.463867, -58.914242 -27.464164, -58.911281 -27.466806, -58.910451 -27.467552, -58.910363 -27.467919)', 4326),
        7986998, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '111'),
        'Ida: Cementerio Fontana → Mujeres Argentinas', null, 0,
        st_geomfromtext('LINESTRING(-59.037711 -27.431204, -59.026848 -27.421422, -59.027445 -27.420619, -59.026477 -27.419542, -59.026210 -27.418932, -59.024466 -27.417385, -59.027198 -27.414944, -59.025390 -27.413301, -59.027479 -27.411438, -59.029372 -27.413138, -59.010789 -27.429667, -59.010934 -27.430409, -59.010854 -27.430567, -59.010546 -27.430728, -59.010125 -27.430699, -59.009832 -27.430803, -59.009776 -27.430995, -59.009841 -27.431418, -59.009666 -27.431904, -59.009280 -27.432547, -59.008598 -27.433270, -59.007601 -27.433999, -59.005099 -27.434994, -59.004237 -27.435489, -58.987440 -27.450362, -58.988299 -27.451144, -58.986515 -27.452719, -58.985684 -27.451977, -58.964155 -27.471042, -58.959897 -27.467266, -58.960749 -27.466451, -58.958829 -27.464728, -58.953030 -27.463975, -58.952911 -27.463905, -58.952242 -27.462970, -58.951447 -27.463590, -58.951076 -27.463989, -58.950791 -27.464424, -58.950492 -27.465244, -58.950048 -27.465081, -58.948830 -27.464001, -58.948822 -27.460858, -58.949452 -27.460302, -58.949487 -27.460162)', 4326),
        7993008, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '107'),
        'Ida: Resistencia Centro → San Pedro (Fontana)', 'A', 0,
        st_geomfromtext('LINESTRING(-58.986512 -27.449551, -58.987388 -27.450316, -59.004166 -27.435421, -59.005117 -27.434878, -59.007463 -27.433947, -59.008393 -27.433341, -59.008934 -27.432805, -59.009584 -27.431853, -59.009734 -27.431395, -59.009664 -27.430776, -59.010102 -27.430178, -59.009972 -27.429480, -59.010124 -27.429300, -59.010360 -27.429214, -59.010544 -27.429248, -59.010738 -27.429427, -59.011022 -27.430791, -59.010887 -27.431578, -59.011443 -27.434611, -59.011596 -27.435087, -59.011820 -27.435470, -59.012309 -27.435964, -59.013697 -27.437171, -59.014352 -27.437590, -59.014921 -27.438163, -59.015177 -27.438326, -59.015360 -27.438290, -59.033128 -27.422509, -59.037707 -27.418494, -59.039211 -27.417263, -59.040583 -27.416773, -59.041209 -27.417817, -59.050059 -27.413942, -59.049586 -27.413072, -59.049300 -27.412920, -59.048665 -27.412328, -59.048595 -27.412180, -59.048707 -27.411881, -59.049097 -27.411690, -59.040079 -27.403633, -59.042653 -27.401334)', 4326),
        7997876, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '111'),
        'Vuelta: Mujeres Argentinas → Cementerio Fontana', null, 1,
        st_geomfromtext('LINESTRING(-58.949487 -27.460162, -58.949452 -27.460302, -58.948822 -27.460858, -58.948830 -27.464001, -58.949077 -27.464228, -58.948361 -27.464869, -58.947695 -27.464869, -58.947703 -27.465223, -58.948198 -27.465722, -58.948023 -27.466224, -58.948375 -27.466617, -58.947529 -27.467354, -58.949038 -27.468733, -58.949149 -27.468769, -58.950898 -27.464231, -58.951447 -27.463590, -58.952242 -27.462970, -58.952911 -27.463905, -58.953030 -27.463975, -58.958829 -27.464728, -58.964948 -27.470200, -58.985516 -27.451965, -58.985590 -27.451893, -58.984745 -27.451139, -58.986512 -27.449551, -58.987388 -27.450316, -59.004166 -27.435421, -59.005117 -27.434878, -59.007463 -27.433947, -59.008393 -27.433341, -59.008934 -27.432805, -59.009584 -27.431853, -59.009734 -27.431395, -59.009664 -27.430776, -59.010102 -27.430178, -59.009972 -27.429480, -59.010124 -27.429300, -59.010430 -27.429224, -59.010635 -27.429292, -59.010760 -27.429521, -59.010882 -27.429453, -59.027198 -27.414944, -59.025390 -27.413301, -59.027479 -27.411438, -59.029372 -27.413138, -59.024527 -27.417439, -59.026210 -27.418932, -59.026477 -27.419542, -59.027445 -27.420619, -59.026848 -27.421422, -59.037711 -27.431204)', 4326),
        7997877, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '106'),
        'Ida: Barrio Perón → Barrio San Antonio', 'B', 0,
        st_geomfromtext('LINESTRING(-59.015046 -27.476731, -59.007884 -27.470369, -59.012249 -27.466488, -59.005079 -27.460061, -59.007861 -27.457648, -59.000816 -27.451307, -59.000547 -27.451181, -58.999706 -27.450498, -58.997808 -27.448813, -58.995156 -27.451163, -58.993421 -27.449631, -58.989083 -27.453514, -58.987350 -27.451981, -58.986515 -27.452719, -58.985684 -27.451977, -58.950752 -27.482938, -58.957769 -27.489249, -58.957763 -27.489358, -58.956900 -27.490126, -58.961262 -27.494078, -58.954986 -27.499667, -58.957699 -27.502133, -58.964955 -27.508591, -58.972118 -27.502245)', 4326),
        8004650, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '106'),
        'Ida: Barrio Perón → Puerto Vilelas', 'A', 0,
        st_geomfromtext('LINESTRING(-59.014951 -27.476691, -59.007884 -27.470369, -59.015021 -27.464054, -59.000816 -27.451307, -59.000547 -27.451181, -58.999706 -27.450498, -58.997808 -27.448813, -58.995156 -27.451163, -58.993421 -27.449631, -58.989083 -27.453514, -58.987350 -27.451981, -58.986515 -27.452719, -58.985684 -27.451977, -58.954251 -27.479802, -58.950636 -27.483080, -58.950155 -27.483413, -58.938617 -27.493618, -58.937109 -27.495093, -58.936938 -27.495447, -58.936886 -27.495810, -58.937218 -27.496551, -58.942117 -27.500954, -58.942753 -27.502008, -58.943479 -27.502423, -58.943582 -27.502545, -58.943463 -27.502842, -58.942760 -27.503173, -58.942569 -27.503377, -58.941889 -27.515879, -58.941880 -27.518000, -58.941631 -27.519554, -58.941241 -27.520218, -58.940545 -27.520978, -58.923864 -27.535775)', 4326),
        8004651, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'interurbano-chaco-corrientes' and l.code = '904A'),
        'Ida: Terminal de Ómnibus Resistencia → Campus Corrientes', null, 0,
        st_geomfromtext('LINESTRING(-59.022818 -27.456854, -59.022016 -27.456842, -59.021808 -27.457005, -59.021645 -27.457037, -59.008008 -27.444835, -58.995402 -27.455982, -58.994360 -27.455043, -58.985426 -27.462989, -58.985112 -27.462711, -58.984707 -27.462064, -58.984478 -27.462144, -58.984829 -27.461988, -58.991707 -27.455888, -58.989083 -27.453514, -58.986490 -27.455814, -58.983934 -27.453494, -58.954251 -27.479802, -58.950636 -27.483080, -58.950469 -27.483159, -58.950299 -27.483055, -58.949654 -27.483000, -58.936121 -27.482983, -58.935872 -27.482653, -58.919246 -27.467706, -58.915017 -27.463958, -58.914629 -27.463814, -58.914483 -27.463486, -58.913793 -27.462576, -58.908290 -27.456989, -58.907643 -27.456488, -58.906686 -27.455977, -58.902281 -27.454150, -58.901708 -27.453827, -58.901156 -27.453370, -58.891783 -27.443854, -58.891335 -27.443521, -58.891063 -27.443410, -58.890813 -27.443404, -58.890448 -27.443589, -58.889433 -27.444295, -58.856061 -27.473689, -58.855304 -27.474242, -58.854571 -27.474505, -58.851651 -27.474948, -58.851040 -27.474984, -58.850612 -27.474807, -58.849907 -27.474221, -58.849496 -27.474162, -58.847779 -27.474482, -58.814706 -27.478629, -58.812699 -27.471231, -58.806056 -27.472787, -58.805321 -27.473036, -58.802674 -27.473693, -58.798270 -27.475018, -58.792660 -27.476069, -58.788544 -27.476719, -58.786938 -27.465993, -58.782616 -27.464932)', 4326),
        14438359, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'interurbano-chaco-corrientes' and l.code = '904A'),
        'Vuelta: Terminal de Ómnibus Resistencia → Campus Corrientes', null, 1,
        st_geomfromtext('LINESTRING(-58.782616 -27.464932, -58.780538 -27.464403, -58.780570 -27.464334, -58.787074 -27.465940, -58.787010 -27.466120, -58.787104 -27.466834, -58.788630 -27.476639, -58.792443 -27.476043, -58.798255 -27.474930, -58.804103 -27.473230, -58.812778 -27.471223, -58.814730 -27.478330, -58.845605 -27.474449, -58.846859 -27.474391, -58.849697 -27.474083, -58.850038 -27.474128, -58.852254 -27.474853, -58.854571 -27.474505, -58.855304 -27.474242, -58.856061 -27.473689, -58.887293 -27.446208, -58.889433 -27.444295, -58.890728 -27.442763, -58.890939 -27.442638, -58.891117 -27.442626, -58.891339 -27.442803, -58.891325 -27.443249, -58.891477 -27.443538, -58.901156 -27.453370, -58.901977 -27.454004, -58.906686 -27.455977, -58.907643 -27.456488, -58.908290 -27.456989, -58.913994 -27.462803, -58.914583 -27.463367, -58.914980 -27.463546, -58.915157 -27.463921, -58.936054 -27.482671, -58.936338 -27.482816, -58.936943 -27.482872, -58.949683 -27.482934, -58.950605 -27.482886, -58.975799 -27.460553, -58.979312 -27.463697, -58.982936 -27.460491, -58.986215 -27.463418, -58.986496 -27.463571, -58.997878 -27.453439, -59.000434 -27.451231, -59.000935 -27.450970, -59.008034 -27.444617, -59.022374 -27.457512, -59.022972 -27.457009, -59.022818 -27.456854)', 4326),
        14438360, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'interurbano-chaco-corrientes' and l.code = '904B'),
        'Vuelta: Chaco - Corrientes directo', null, 1,
        st_geomfromtext('LINESTRING(-58.985112 -27.462711, -58.984478 -27.462144, -58.984829 -27.461988, -58.991707 -27.455888, -58.989083 -27.453514, -58.986490 -27.455814, -58.981285 -27.451122, -58.983860 -27.448845, -58.961161 -27.428542, -58.960270 -27.427402, -58.959335 -27.424915, -58.958723 -27.423984, -58.958304 -27.423490, -58.957087 -27.422422, -58.956532 -27.422053, -58.955972 -27.421917, -58.955402 -27.422007, -58.954776 -27.422208, -58.949611 -27.424195, -58.946952 -27.425340, -58.942939 -27.426844, -58.929180 -27.432257, -58.925402 -27.433833, -58.918829 -27.436250, -58.916298 -27.436762, -58.913447 -27.436928, -58.909444 -27.436880, -58.904533 -27.436704, -58.902987 -27.436747, -58.901488 -27.436927, -58.900034 -27.437235, -58.898206 -27.437821, -58.896906 -27.438398, -58.895558 -27.439173, -58.894005 -27.440279, -58.892185 -27.441895, -58.891166 -27.443169, -58.890304 -27.443673, -58.889433 -27.444295, -58.856061 -27.473689, -58.855566 -27.474088, -58.854927 -27.474402, -58.854157 -27.474575, -58.851040 -27.474984, -58.850612 -27.474807, -58.849907 -27.474221, -58.849620 -27.474154, -58.847779 -27.474482, -58.841704 -27.475220, -58.841857 -27.476442, -58.839242 -27.476778, -58.839072 -27.475567, -58.838898 -27.475291, -58.837524 -27.461766)', 4326),
        14442057, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'interurbano-chaco-corrientes' and l.code = '904B'),
        'Ida: Chaco - Corrientes directo', null, 0,
        st_geomfromtext('LINESTRING(-58.837524 -27.461766, -58.841246 -27.461419, -58.842234 -27.474873, -58.845605 -27.474449, -58.846859 -27.474391, -58.849697 -27.474083, -58.850038 -27.474128, -58.852254 -27.474853, -58.854927 -27.474402, -58.855566 -27.474088, -58.856061 -27.473689, -58.887293 -27.446208, -58.889433 -27.444295, -58.890728 -27.442763, -58.891540 -27.442192, -58.894335 -27.439760, -58.895540 -27.438929, -58.896505 -27.438380, -58.897692 -27.437818, -58.899005 -27.437327, -58.900873 -27.436816, -58.902536 -27.436550, -58.903702 -27.436486, -58.909874 -27.436487, -58.914670 -27.436661, -58.916849 -27.436457, -58.919006 -27.435969, -58.921930 -27.434870, -58.927354 -27.432623, -58.930534 -27.431508, -58.941799 -27.427065, -58.946742 -27.424981, -58.949782 -27.423908, -58.954724 -27.421854, -58.955302 -27.421515, -58.955695 -27.420997, -58.956094 -27.420836, -58.956337 -27.420865, -58.956589 -27.421013, -58.956732 -27.421250, -58.956792 -27.421637, -58.956971 -27.421925, -58.958895 -27.423638, -58.959338 -27.424219, -58.959669 -27.424807, -58.960575 -27.427289, -58.961102 -27.428116, -58.961566 -27.428635, -58.983952 -27.448763, -58.986532 -27.446480, -58.991737 -27.451161, -58.989166 -27.453438, -58.992646 -27.456574, -58.985426 -27.462989)', 4326),
        14442058, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'interurbano-chaco-corrientes' and l.code = '904C'),
        'Vuelta: Chaco - Corrientes x Barranqueras', null, 1,
        st_geomfromtext('LINESTRING(-58.837524 -27.461766, -58.841246 -27.461419, -58.842234 -27.474873, -58.845605 -27.474449, -58.846859 -27.474391, -58.849697 -27.474083, -58.850038 -27.474128, -58.852254 -27.474853, -58.854927 -27.474402, -58.855566 -27.474088, -58.856061 -27.473689, -58.887293 -27.446208, -58.889433 -27.444295, -58.890728 -27.442763, -58.890939 -27.442638, -58.891117 -27.442626, -58.891339 -27.442803, -58.891325 -27.443249, -58.891477 -27.443538, -58.901156 -27.453370, -58.901977 -27.454004, -58.906686 -27.455977, -58.907643 -27.456488, -58.908290 -27.456989, -58.913994 -27.462803, -58.914583 -27.463367, -58.914980 -27.463546, -58.915157 -27.463921, -58.935716 -27.482380, -58.936338 -27.482816, -58.936943 -27.482872, -58.949683 -27.482934, -58.950605 -27.482886, -58.975799 -27.460553, -58.979312 -27.463697, -58.982936 -27.460491, -58.984707 -27.462064, -58.985611 -27.461288, -58.986461 -27.462049, -58.985426 -27.462989, -58.985112 -27.462711)', 4326),
        14447121, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'interurbano-chaco-corrientes' and l.code = '904C'),
        'Ida: Chaco - Corrientes x Barranqueras', null, 0,
        st_geomfromtext('LINESTRING(-58.985112 -27.462711, -58.979364 -27.457538, -58.950636 -27.483080, -58.950469 -27.483159, -58.950299 -27.483055, -58.949654 -27.483000, -58.936121 -27.482983, -58.935872 -27.482653, -58.919246 -27.467706, -58.915017 -27.463958, -58.914629 -27.463814, -58.914483 -27.463486, -58.913793 -27.462576, -58.908290 -27.456989, -58.907643 -27.456488, -58.906686 -27.455977, -58.902281 -27.454150, -58.901708 -27.453827, -58.901156 -27.453370, -58.891783 -27.443854, -58.891335 -27.443521, -58.891063 -27.443410, -58.890813 -27.443404, -58.890448 -27.443589, -58.889433 -27.444295, -58.856061 -27.473689, -58.855566 -27.474088, -58.854927 -27.474402, -58.854157 -27.474575, -58.851040 -27.474984, -58.850612 -27.474807, -58.849907 -27.474221, -58.849620 -27.474154, -58.847779 -27.474482, -58.841704 -27.475220, -58.841857 -27.476442, -58.839242 -27.476778, -58.839072 -27.475567, -58.838898 -27.475291, -58.837496 -27.461859)', 4326),
        14447122, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'interurbano-chaco' and l.code = 'RES-CB'),
        'Vuelta: Colonia Benítez', null, 1,
        st_geomfromtext('LINESTRING(-58.955946 -27.324301, -58.946641 -27.332571, -58.945761 -27.331786, -58.942962 -27.334261, -58.937606 -27.329482, -58.939365 -27.327927, -58.943010 -27.331180, -58.944050 -27.330260, -58.946641 -27.332571, -58.955946 -27.324301, -58.958855 -27.321866, -58.966075 -27.315468, -58.966258 -27.314861, -58.966430 -27.314686, -58.973982 -27.315736, -58.975824 -27.315927, -58.977245 -27.315963, -58.979367 -27.315845, -58.992781 -27.313574, -58.996090 -27.312779, -59.002086 -27.331684, -59.002383 -27.333240, -59.002383 -27.334790, -58.992266 -27.382932, -58.992073 -27.384587, -58.992144 -27.385965, -58.992353 -27.386942, -58.992988 -27.388640, -58.994694 -27.392321, -58.995540 -27.394791, -58.997763 -27.400465, -58.998229 -27.401315, -58.998819 -27.402766, -58.999205 -27.404103, -59.000466 -27.407342, -59.001419 -27.409407, -59.001680 -27.410571, -59.002629 -27.411855, -59.002715 -27.412902, -59.003233 -27.414018, -59.003704 -27.415510, -59.004290 -27.416936, -59.004677 -27.417652, -59.005346 -27.418619, -59.008515 -27.421910, -59.008857 -27.422429, -59.009131 -27.423040, -59.009460 -27.424370, -59.010128 -27.428077, -59.010581 -27.428709, -59.010934 -27.430409, -59.010711 -27.430686, -59.010426 -27.430739, -59.010125 -27.430699, -59.009832 -27.430803, -59.009776 -27.430995, -59.009841 -27.431418, -59.009666 -27.431904, -59.009280 -27.432547, -59.008598 -27.433270, -59.007601 -27.433999, -59.005099 -27.434994, -59.004237 -27.435489, -58.990961 -27.447244, -58.995240 -27.451089, -58.991727 -27.454204)', 4326),
        14449325, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'interurbano-chaco' and l.code = 'RES-CB'),
        'Ida: Colonia Benítez', null, 0,
        st_geomfromtext('LINESTRING(-58.991727 -27.454204, -58.990858 -27.454979, -58.991784 -27.455820, -58.996077 -27.451999, -58.994297 -27.450392, -58.996101 -27.448780, -58.992604 -27.445661, -59.004166 -27.435421, -59.005117 -27.434878, -59.007463 -27.433947, -59.008393 -27.433341, -59.008934 -27.432805, -59.009584 -27.431853, -59.009734 -27.431395, -59.009664 -27.430776, -59.010102 -27.430178, -59.009777 -27.428437, -59.009929 -27.427559, -59.009477 -27.424905, -59.009006 -27.422995, -59.008656 -27.422300, -59.008136 -27.421631, -59.005362 -27.418832, -59.004717 -27.417995, -59.004009 -27.416623, -59.002967 -27.413636, -59.002705 -27.413252, -59.001993 -27.412567, -59.001707 -27.412132, -59.001601 -27.411717, -59.001618 -27.410854, -59.001335 -27.409511, -58.999355 -27.404792, -58.998737 -27.402797, -58.997652 -27.400392, -58.995512 -27.395131, -58.995149 -27.393817, -58.994484 -27.392074, -58.994026 -27.391267, -58.993378 -27.389739, -58.992353 -27.386942, -58.992113 -27.385597, -58.992087 -27.384309, -58.992266 -27.382932, -59.002383 -27.334790, -59.002383 -27.333240, -59.002086 -27.331684, -58.996203 -27.313132, -58.995852 -27.312868, -58.992781 -27.313574, -58.979367 -27.315845, -58.977245 -27.315963, -58.975824 -27.315927, -58.973982 -27.315736, -58.966430 -27.314686, -58.966258 -27.314861, -58.966075 -27.315468, -58.958855 -27.321866, -58.955946 -27.324301)', 4326),
        14449326, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '106'),
        'Vuelta: Barrio San Antonio → Barrio Perón', 'B', 1,
        st_geomfromtext('LINESTRING(-58.972118 -27.502245, -58.964955 -27.508591, -58.954908 -27.499590, -58.961217 -27.494014, -58.956832 -27.490060, -58.957690 -27.489319, -58.950736 -27.483097, -58.950409 -27.483149, -58.950299 -27.483055, -58.950296 -27.482937, -58.950348 -27.482878, -58.950605 -27.482886, -58.951544 -27.482063, -58.985516 -27.451965, -58.985590 -27.451893, -58.984745 -27.451139, -58.988229 -27.448015, -58.994362 -27.453517, -58.998928 -27.449467, -59.007973 -27.457582, -59.008040 -27.457657, -59.005264 -27.460063, -59.012335 -27.466414, -59.009675 -27.468767, -59.008297 -27.467549, -59.006580 -27.469058, -59.008060 -27.470376, -59.008087 -27.470516, -59.008282 -27.470740, -59.008625 -27.471047, -59.008771 -27.471031, -59.015037 -27.476633)', 4326),
        14465855, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '106'),
        'Vuelta: 200 Viviendas → Barrio Perón', 'C', 1,
        st_geomfromtext('LINESTRING(-58.955758 -27.498847, -58.954035 -27.497279, -58.954897 -27.496524, -58.945185 -27.487819, -58.943462 -27.489351, -58.936422 -27.483076, -58.936121 -27.482983, -58.936105 -27.482816, -58.936209 -27.482764, -58.936943 -27.482872, -58.946589 -27.482921, -58.950605 -27.482886, -58.985516 -27.451965, -58.985590 -27.451893, -58.984745 -27.451139, -58.986512 -27.449551, -58.988299 -27.451144, -58.987434 -27.451907, -59.007970 -27.470293, -59.008060 -27.470376, -59.007977 -27.470459, -59.008282 -27.470740, -59.008690 -27.471105, -59.008771 -27.471031, -59.015037 -27.476633)', 4326),
        14468699, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'interurbano-chaco' and l.code = 'Tirol'),
        'Vuelta: Resistencia → Puerto Tirol', 'A', 1,
        st_geomfromtext('LINESTRING(-59.093244 -27.375398, -59.091689 -27.376860, -59.090690 -27.378317, -59.090127 -27.378951, -59.086360 -27.382382, -59.085274 -27.381381, -59.085948 -27.378777, -59.086385 -27.376475, -59.087234 -27.374149, -59.087229 -27.373891, -59.086820 -27.374084, -59.086368 -27.374152, -59.079806 -27.374096, -59.078566 -27.374010, -59.077774 -27.373765, -59.077009 -27.373304, -59.076584 -27.372956, -59.062956 -27.360807, -59.062715 -27.360718, -59.062437 -27.360820, -59.062297 -27.360944, -59.060627 -27.364450, -59.059763 -27.365548, -59.031375 -27.386275, -59.004190 -27.410429, -59.003021 -27.411630, -59.002706 -27.412284, -59.002715 -27.412902, -59.003233 -27.414018, -59.003704 -27.415510, -59.004413 -27.417192, -59.005346 -27.418619, -59.008382 -27.421744, -59.008753 -27.422248, -59.009131 -27.423040, -59.009460 -27.424370, -59.010128 -27.428077, -59.010581 -27.428709, -59.010934 -27.430409, -59.010711 -27.430686, -59.010426 -27.430739, -59.010125 -27.430699, -59.009832 -27.430803, -59.009776 -27.430995, -59.009841 -27.431418, -59.009666 -27.431904, -59.009280 -27.432547, -59.008598 -27.433270, -59.007601 -27.433999, -59.005099 -27.434994, -59.004237 -27.435489, -58.991810 -27.446492, -58.996092 -27.450335, -58.991727 -27.454204)', 4326),
        15060597, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'interurbano-chaco' and l.code = 'Tirol'),
        'Ida: Resistencia → Puerto Tirol', 'A', 0,
        st_geomfromtext('LINESTRING(-58.991727 -27.454204, -58.990858 -27.454979, -58.991784 -27.455820, -58.996077 -27.451999, -58.994297 -27.450392, -58.996101 -27.448780, -58.992604 -27.445661, -59.004166 -27.435421, -59.005117 -27.434878, -59.007463 -27.433947, -59.008393 -27.433341, -59.008934 -27.432805, -59.009584 -27.431853, -59.009734 -27.431395, -59.009664 -27.430776, -59.010079 -27.430281, -59.009777 -27.428437, -59.009929 -27.427559, -59.009477 -27.424905, -59.009006 -27.422995, -59.008656 -27.422300, -59.008136 -27.421631, -59.005362 -27.418832, -59.004717 -27.417995, -59.004009 -27.416623, -59.002967 -27.413636, -59.002705 -27.413252, -59.001993 -27.412567, -59.001707 -27.412132, -59.001601 -27.411717, -59.001663 -27.411426, -59.001914 -27.411260, -59.002778 -27.411330, -59.003173 -27.411155, -59.003827 -27.410370, -59.010953 -27.404051, -59.013736 -27.401372, -59.019414 -27.396509, -59.023672 -27.392710, -59.026210 -27.390267, -59.030355 -27.386658, -59.041213 -27.378756, -59.043082 -27.377237, -59.045937 -27.375117, -59.049946 -27.372381, -59.059102 -27.365702, -59.059629 -27.365170, -59.060283 -27.364209, -59.063014 -27.358396, -59.063153 -27.358235, -59.063328 -27.358190, -59.063453 -27.358334, -59.063421 -27.358538, -59.062666 -27.360164, -59.062666 -27.360509, -59.062847 -27.360734, -59.076584 -27.372956, -59.077009 -27.373304, -59.077774 -27.373765, -59.078566 -27.374010, -59.079246 -27.374080, -59.085867 -27.374156, -59.086820 -27.374084, -59.087435 -27.373780, -59.090034 -27.371449, -59.090976 -27.372242, -59.091921 -27.371350, -59.092902 -27.372193, -59.095647 -27.369761, -59.099941 -27.373610, -59.098275 -27.375065, -59.095989 -27.373001, -59.093244 -27.375398)', 4326),
        15060598, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'interurbano-chaco' and l.code = 'Tirol'),
        'Ida: Resistencia → Puerto Tirol Ramal B', 'B', 0,
        st_geomfromtext('LINESTRING(-58.991727 -27.454204, -58.990858 -27.454979, -58.991784 -27.455820, -58.996077 -27.451999, -58.994297 -27.450392, -58.996101 -27.448780, -58.992604 -27.445661, -59.004166 -27.435421, -59.005117 -27.434878, -59.007463 -27.433947, -59.008393 -27.433341, -59.008934 -27.432805, -59.009584 -27.431853, -59.009734 -27.431395, -59.009664 -27.430776, -59.010079 -27.430281, -59.009777 -27.428437, -59.009929 -27.427559, -59.009477 -27.424905, -59.009006 -27.422995, -59.008656 -27.422300, -59.008136 -27.421631, -59.005362 -27.418832, -59.004717 -27.417995, -59.004009 -27.416623, -59.002967 -27.413636, -59.002705 -27.413252, -59.001993 -27.412567, -59.001707 -27.412132, -59.001601 -27.411717, -59.001663 -27.411426, -59.001914 -27.411260, -59.002778 -27.411330, -59.003173 -27.411155, -59.003827 -27.410370, -59.010953 -27.404051, -59.013736 -27.401372, -59.019414 -27.396509, -59.023672 -27.392710, -59.026210 -27.390267, -59.030355 -27.386658, -59.041213 -27.378756, -59.043082 -27.377237, -59.045937 -27.375117, -59.049946 -27.372381, -59.059102 -27.365702, -59.059629 -27.365170, -59.060283 -27.364209, -59.063014 -27.358396, -59.063153 -27.358235, -59.063328 -27.358190, -59.063453 -27.358334, -59.063421 -27.358538, -59.062666 -27.360164, -59.062666 -27.360509, -59.062847 -27.360734, -59.076584 -27.372956, -59.077009 -27.373304, -59.077774 -27.373765, -59.078566 -27.374010, -59.079246 -27.374080, -59.085867 -27.374156, -59.086820 -27.374084, -59.087435 -27.373780, -59.088023 -27.373866, -59.091181 -27.373737, -59.091243 -27.373681, -59.090976 -27.372242, -59.091921 -27.371350, -59.092902 -27.372193, -59.095647 -27.369761, -59.099941 -27.373610, -59.098275 -27.375065, -59.095989 -27.373001, -59.093244 -27.375398)', 4326),
        15061595, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '206'),
        'Vuelta: Resistencia → Barranqueras', null, 1,
        st_geomfromtext('LINESTRING(-58.910061 -27.467820, -58.910451 -27.467552, -58.914242 -27.464164, -58.914454 -27.463922, -58.914613 -27.463549, -58.914860 -27.463475, -58.914980 -27.463546, -58.915157 -27.463921, -58.936054 -27.482671, -58.936338 -27.482816, -58.936943 -27.482872, -58.949683 -27.482934, -58.950605 -27.482886, -58.985516 -27.451965, -58.985590 -27.451893, -58.984745 -27.451139, -58.986512 -27.449551, -58.987388 -27.450316, -59.004166 -27.435421, -59.005117 -27.434878, -59.007159 -27.434090, -59.007881 -27.433697, -59.008393 -27.433341, -59.008934 -27.432805, -59.009584 -27.431853, -59.009734 -27.431395, -59.009664 -27.430776, -59.010102 -27.430178, -59.009163 -27.425004, -59.008641 -27.422775, -59.008161 -27.421885, -59.007844 -27.421481, -59.006332 -27.419990, -59.005182 -27.419046, -59.004397 -27.417943, -59.004042 -27.417261, -59.002888 -27.414127, -59.002967 -27.413636, -59.002705 -27.413252, -59.001993 -27.412567, -59.001707 -27.412132, -59.001601 -27.411717, -59.001618 -27.410854, -59.001335 -27.409511, -59.001142 -27.409006, -59.000649 -27.408702, -58.998368 -27.402752, -58.994583 -27.393243, -58.993566 -27.394036, -58.987803 -27.399156, -58.988626 -27.399917, -58.989706 -27.398979, -58.989920 -27.398935, -58.990063 -27.399522)', 4326),
        15540760, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '206'),
        'Ida: Resistencia → Barranqueras', null, 0,
        st_geomfromtext('LINESTRING(-58.990063 -27.399522, -58.989920 -27.398935, -58.989706 -27.398979, -58.988626 -27.399917, -58.987719 -27.399081, -58.994529 -27.393107, -58.994342 -27.392632, -58.994498 -27.392415, -58.994768 -27.392310, -58.995061 -27.392359, -59.001325 -27.408170, -59.001553 -27.408931, -59.001419 -27.409407, -59.001650 -27.410487, -59.001840 -27.410844, -59.002601 -27.411787, -59.002706 -27.412284, -59.002715 -27.412902, -59.002925 -27.413378, -59.003592 -27.413988, -59.003900 -27.414981, -59.004806 -27.417076, -59.005997 -27.418814, -59.006346 -27.419582, -59.007149 -27.420362, -59.007886 -27.420733, -59.008482 -27.421357, -59.009073 -27.422139, -59.009525 -27.423192, -59.010312 -27.427488, -59.010934 -27.430409, -59.010711 -27.430686, -59.010426 -27.430739, -59.010125 -27.430699, -59.009832 -27.430803, -59.009776 -27.430995, -59.009841 -27.431418, -59.009666 -27.431904, -59.009280 -27.432547, -59.008598 -27.433270, -59.007601 -27.433999, -59.005099 -27.434994, -59.004237 -27.435489, -58.987440 -27.450362, -58.988299 -27.451144, -58.986515 -27.452719, -58.985684 -27.451977, -58.950531 -27.483150, -58.950299 -27.483055, -58.949654 -27.483000, -58.937085 -27.482958, -58.936153 -27.483004, -58.935872 -27.482653, -58.934161 -27.481106, -58.919246 -27.467706, -58.914875 -27.463867, -58.914242 -27.464164, -58.911281 -27.466806, -58.910451 -27.467552, -58.910363 -27.467919)', 4326),
        15540761, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '2'),
        'Ida: Carpincho Macho → Villa Prosperidad (ramal A)', 'A', 0,
        st_geomfromtext('LINESTRING(-59.047175 -27.455419, -59.048570 -27.456660, -59.048043 -27.457145, -59.046643 -27.455888, -59.040719 -27.461140, -59.046449 -27.466294, -59.046236 -27.466484, -59.049479 -27.469282, -59.054957 -27.474183, -59.048893 -27.479721, -59.049338 -27.480134, -59.048512 -27.480870, -59.048036 -27.480457, -59.054957 -27.474183, -59.049479 -27.469282, -59.046236 -27.466484, -59.045877 -27.466796, -59.045715 -27.466687, -59.036107 -27.458035, -59.029404 -27.463992, -59.008008 -27.444835, -58.993594 -27.457579, -58.987350 -27.451981, -58.986515 -27.452719, -58.985684 -27.451977, -58.975802 -27.460695, -58.970613 -27.455941, -58.964537 -27.450522, -58.964521 -27.450409)', 4326),
        17000508, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '2'),
        'Vuelta: Villa Prosperidad → Carpincho Macho (ramal A)', 'A', 1,
        st_geomfromtext('LINESTRING(-58.964521 -27.450409, -58.964334 -27.450533, -58.964335 -27.450653, -58.962836 -27.451981, -58.963565 -27.452645, -58.965315 -27.451085, -58.975799 -27.460553, -58.985590 -27.451893, -58.984745 -27.451139, -58.988229 -27.448015, -58.994362 -27.453517, -59.006225 -27.443007, -59.023151 -27.458207, -59.023049 -27.458295, -59.029404 -27.463992, -59.036107 -27.458035, -59.035815 -27.457679, -59.035922 -27.457454, -59.036148 -27.457286, -59.036373 -27.457280, -59.040719 -27.461140, -59.047175 -27.455419)', 4326),
        17004625, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '2'),
        'Vuelta: Villa Prosperidad → Carpincho Macho (ramal B)', 'B', 1,
        st_geomfromtext('LINESTRING(-58.964521 -27.450409, -58.964334 -27.450533, -58.964335 -27.450653, -58.962836 -27.451981, -58.963565 -27.452645, -58.965315 -27.451085, -58.967917 -27.453400, -58.978588 -27.443897, -58.985695 -27.450301, -58.986512 -27.449551, -58.987388 -27.450316, -59.004166 -27.435421, -59.005117 -27.434878, -59.007463 -27.433947, -59.008393 -27.433341, -59.008934 -27.432805, -59.009584 -27.431853, -59.009734 -27.431395, -59.009664 -27.430776, -59.010102 -27.430178, -59.009972 -27.429480, -59.010124 -27.429300, -59.010360 -27.429214, -59.010635 -27.429292, -59.010760 -27.429521, -59.011022 -27.430791, -59.010887 -27.431578, -59.011443 -27.434611, -59.011596 -27.435087, -59.011820 -27.435470, -59.013697 -27.437171, -59.014352 -27.437590, -59.014921 -27.438163, -59.017906 -27.440719, -59.029503 -27.451118, -59.034807 -27.446389, -59.036969 -27.448325, -59.037232 -27.448586, -59.037406 -27.448950, -59.038182 -27.449654, -59.034738 -27.452725, -59.036021 -27.453874, -59.038749 -27.451452, -59.041133 -27.453592, -59.041745 -27.453043, -59.044766 -27.455771, -59.043234 -27.457144, -59.044223 -27.458033, -59.045951 -27.456501)', 4326),
        17009672, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '2'),
        'Ida: Carpincho Macho → Villa Prosperidad (ramal B)', 'B', 0,
        st_geomfromtext('LINESTRING(-59.047175 -27.455419, -59.048570 -27.456660, -59.048043 -27.457145, -59.046643 -27.455888, -59.044223 -27.458033, -59.043234 -27.457144, -59.044766 -27.455771, -59.041745 -27.453043, -59.041133 -27.453592, -59.038749 -27.451452, -59.036021 -27.453874, -59.034738 -27.452725, -59.038182 -27.449654, -59.037406 -27.448950, -59.037232 -27.448586, -59.036969 -27.448325, -59.034855 -27.446434, -59.029568 -27.451170, -59.029878 -27.451457, -59.029874 -27.451566, -59.029691 -27.451874, -59.029358 -27.451986, -59.014205 -27.438444, -59.013741 -27.437528, -59.011553 -27.435420, -59.011215 -27.434530, -59.010763 -27.431741, -59.010342 -27.431276, -59.010226 -27.430723, -59.010125 -27.430699, -59.009832 -27.430803, -59.009776 -27.430995, -59.009841 -27.431418, -59.009481 -27.432235, -59.009280 -27.432547, -59.008598 -27.433270, -59.007601 -27.433999, -59.005099 -27.434994, -59.004237 -27.435489, -58.987440 -27.450362, -58.988299 -27.451144, -58.986515 -27.452719, -58.984745 -27.451139, -58.985587 -27.450399, -58.977596 -27.443241, -58.971533 -27.448641, -58.973404 -27.450329, -58.972379 -27.451271, -58.972195 -27.451133, -58.972136 -27.451175, -58.968701 -27.454231, -58.964537 -27.450522)', 4326),
        17013197, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '2'),
        'Vuelta: Villa Prosperidad → Carpincho Macho (ramal C)', 'C', 1,
        st_geomfromtext('LINESTRING(-58.964521 -27.450409, -58.964334 -27.450533, -58.964335 -27.450653, -58.962836 -27.451981, -58.963565 -27.452645, -58.965315 -27.451085, -58.975799 -27.460553, -58.985590 -27.451893, -58.984745 -27.451139, -58.986512 -27.449551, -58.987388 -27.450316, -59.004166 -27.435421, -59.005117 -27.434878, -59.007463 -27.433947, -59.008393 -27.433341, -59.008934 -27.432805, -59.009584 -27.431853, -59.009734 -27.431395, -59.009664 -27.430776, -59.010102 -27.430178, -59.009972 -27.429480, -59.010124 -27.429300, -59.010360 -27.429214, -59.010635 -27.429292, -59.010760 -27.429521, -59.011022 -27.430791, -59.010887 -27.431578, -59.011443 -27.434611, -59.011596 -27.435087, -59.011820 -27.435470, -59.013697 -27.437171, -59.014352 -27.437590, -59.014921 -27.438163, -59.017906 -27.440719, -59.025968 -27.447968, -59.032030 -27.442577, -59.035593 -27.445761, -59.034855 -27.446434, -59.036969 -27.448325, -59.037232 -27.448586, -59.037406 -27.448950, -59.038182 -27.449654, -59.034738 -27.452725, -59.036021 -27.453874, -59.038749 -27.451452, -59.041133 -27.453592, -59.041745 -27.453043, -59.044766 -27.455771, -59.043234 -27.457144, -59.044223 -27.458033, -59.047175 -27.455419)', 4326),
        17017123, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '2'),
        'Ida: Carpincho Macho → Villa Prosperidad (ramal C)', 'C', 0,
        st_geomfromtext('LINESTRING(-59.047175 -27.455419, -59.048570 -27.456660, -59.048043 -27.457145, -59.046643 -27.455888, -59.044223 -27.458033, -59.043234 -27.457144, -59.044766 -27.455771, -59.041745 -27.453043, -59.041133 -27.453592, -59.038749 -27.451452, -59.036021 -27.453874, -59.034738 -27.452725, -59.038182 -27.449654, -59.037406 -27.448950, -59.037232 -27.448586, -59.036969 -27.448325, -59.034807 -27.446389, -59.035544 -27.445709, -59.032030 -27.442577, -59.025968 -27.447968, -59.027218 -27.449080, -59.026687 -27.449573, -59.014205 -27.438444, -59.013741 -27.437528, -59.011678 -27.435588, -59.011344 -27.434974, -59.011215 -27.434530, -59.010763 -27.431741, -59.010342 -27.431276, -59.010226 -27.430723, -59.010125 -27.430699, -59.009832 -27.430803, -59.009776 -27.430995, -59.009841 -27.431418, -59.009481 -27.432235, -59.009280 -27.432547, -59.008598 -27.433270, -59.007601 -27.433999, -59.005099 -27.434994, -59.004237 -27.435489, -58.987440 -27.450362, -58.988299 -27.451144, -58.986515 -27.452719, -58.985684 -27.451977, -58.975802 -27.460695, -58.970613 -27.455941, -58.964537 -27.450522, -58.964521 -27.450409)', 4326),
        17097018, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '3'),
        'Vuelta: Shopping Sarmiento → Barrio Vial', 'A', 1,
        st_geomfromtext('LINESTRING(-58.965110 -27.432016, -58.960815 -27.435818, -58.967825 -27.442082, -58.967928 -27.442083, -58.972296 -27.438245, -58.977209 -27.442711, -58.978061 -27.441965, -58.978549 -27.442398, -58.973332 -27.447042, -58.981279 -27.454181, -58.986512 -27.449551, -58.990872 -27.453450, -58.994394 -27.450311, -59.002963 -27.457992, -59.005710 -27.455541, -59.013972 -27.462954, -59.016353 -27.460866, -59.013405 -27.458230, -59.013507 -27.458120, -59.015488 -27.456386, -59.016980 -27.457707, -59.016302 -27.458306, -59.017569 -27.459491, -59.018209 -27.459314, -59.019270 -27.458352, -59.019465 -27.457815, -59.020997 -27.456457, -59.021236 -27.456356, -59.024772 -27.453238, -59.025990 -27.454337, -59.027778 -27.452929, -59.034869 -27.459186)', 4326),
        17126662, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '3'),
        'Ida: Vial → Shopping Sarmiento', 'A', 0,
        st_geomfromtext('LINESTRING(-59.034869 -27.459186, -59.027778 -27.452929, -59.025990 -27.454337, -59.024772 -27.453238, -59.021236 -27.456356, -59.020997 -27.456457, -59.019465 -27.457815, -59.019270 -27.458352, -59.018209 -27.459314, -59.017569 -27.459491, -59.016302 -27.458306, -59.016980 -27.457707, -59.015488 -27.456386, -59.013507 -27.458120, -59.013405 -27.458230, -59.016353 -27.460866, -59.013875 -27.463038, -59.006468 -27.456390, -59.003727 -27.458832, -58.993421 -27.449631, -58.989083 -27.453514, -58.987350 -27.451981, -58.982968 -27.455846, -58.975136 -27.448813, -58.974283 -27.449577, -58.971539 -27.447109, -58.976746 -27.442465, -58.965110 -27.432016)', 4326),
        17132593, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '3'),
        'Vuelta: Los Troncos → Vial', 'B', 1,
        st_geomfromtext('LINESTRING(-58.964438 -27.440756, -58.963609 -27.440026, -58.962755 -27.440780, -58.963594 -27.441510, -58.965295 -27.439995, -58.965337 -27.439877, -58.967825 -27.442082, -58.967945 -27.442115, -58.967988 -27.442249, -58.981279 -27.454181, -58.986512 -27.449551, -58.990872 -27.453450, -58.994394 -27.450311, -59.002963 -27.457992, -59.012024 -27.449949, -59.010915 -27.448951, -59.013069 -27.446970, -59.013939 -27.447751, -59.014325 -27.447452, -59.015749 -27.447490, -59.015808 -27.447384, -59.015941 -27.447381, -59.015969 -27.447559, -59.016104 -27.447692, -59.017567 -27.448975, -59.017696 -27.449006, -59.014725 -27.451712, -59.014979 -27.452024, -59.014991 -27.453852, -59.015615 -27.454497, -59.015656 -27.454681, -59.017758 -27.454689, -59.017759 -27.454348, -59.018310 -27.453856, -59.021118 -27.456381, -59.021236 -27.456356, -59.024772 -27.453238, -59.025990 -27.454337, -59.027778 -27.452929, -59.034869 -27.459186)', 4326),
        17137100, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '3'),
        'Ida: Vial → Los Troncos', 'B', 0,
        st_geomfromtext('LINESTRING(-59.034869 -27.459186, -59.027778 -27.452929, -59.025990 -27.454337, -59.024772 -27.453238, -59.021236 -27.456356, -59.020997 -27.456457, -59.019706 -27.455304, -59.018040 -27.456789, -59.017278 -27.456787, -59.017281 -27.456154, -59.015650 -27.456148, -59.015651 -27.454577, -59.014991 -27.453852, -59.014979 -27.452024, -59.014636 -27.451641, -59.017567 -27.448975, -59.015969 -27.447559, -59.015834 -27.447587, -59.015749 -27.447490, -59.014253 -27.447473, -59.012698 -27.448827, -59.012981 -27.449092, -59.008419 -27.453163, -59.010732 -27.455249, -59.007954 -27.457728, -59.006468 -27.456390, -59.003727 -27.458832, -58.993421 -27.449631, -58.989083 -27.453514, -58.987350 -27.451981, -58.982968 -27.455846, -58.975136 -27.448813, -58.974283 -27.449577, -58.964438 -27.440756)', 4326),
        17142462, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '3'),
        'Vuelta: Monte Alto → Vial', 'C', 1,
        st_geomfromtext('LINESTRING(-58.941133 -27.427838, -58.940823 -27.428110, -58.940702 -27.427999, -58.954770 -27.422461, -58.955085 -27.422439, -58.957185 -27.422828, -58.957481 -27.422971, -58.957833 -27.422701, -58.958895 -27.423638, -58.959338 -27.424219, -58.959669 -27.424807, -58.960575 -27.427289, -58.961102 -27.428116, -58.961566 -27.428635, -58.985605 -27.450227, -58.985695 -27.450301, -58.986512 -27.449551, -58.987540 -27.450451, -58.988299 -27.451144, -58.987434 -27.451907, -59.000773 -27.463853, -59.003315 -27.461548, -59.005171 -27.459982, -59.012335 -27.466414, -59.022374 -27.457512, -59.023151 -27.458207, -59.023049 -27.458295, -59.029404 -27.463992, -59.034869 -27.459186)', 4326),
        17152397, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '3'),
        'Ida: Barrio Vial → Monte Alto', 'C', 0,
        st_geomfromtext('LINESTRING(-59.034930 -27.459130, -59.029404 -27.463992, -59.022274 -27.457600, -59.012249 -27.466488, -59.005168 -27.460141, -59.003409 -27.461631, -59.000810 -27.464027, -58.987350 -27.451981, -58.986515 -27.452719, -58.984745 -27.451139, -58.985587 -27.450399, -58.961161 -27.428542, -58.960471 -27.427735, -58.960083 -27.427040, -58.959335 -27.424915, -58.959113 -27.424520, -58.958304 -27.423490, -58.957618 -27.422901, -58.957452 -27.422968, -58.957185 -27.422828, -58.955085 -27.422439, -58.954770 -27.422461, -58.941133 -27.427838)', 4326),
        17160581, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '8'),
        'Ida: Barberán → Barrio UOM', 'B', 0,
        st_geomfromtext('LINESTRING(-59.036693 -27.457563, -59.036938 -27.457778, -59.036936 -27.458007, -59.036766 -27.458206, -59.036433 -27.458303, -59.034945 -27.457047, -59.029156 -27.451807, -59.028972 -27.451876, -59.027778 -27.452929, -59.025990 -27.454337, -59.017111 -27.446389, -59.017098 -27.443910, -59.016347 -27.443203, -59.016353 -27.443134, -59.014083 -27.443153, -59.011994 -27.441302, -58.993594 -27.457579, -58.987350 -27.451981, -58.983065 -27.455764, -58.984776 -27.457320, -58.982969 -27.458924, -58.981936 -27.459838, -58.980218 -27.458309, -58.973087 -27.464639, -58.979035 -27.470001, -58.979264 -27.470183, -58.979383 -27.470188, -58.972157 -27.476607, -58.986302 -27.489280, -58.986519 -27.489478, -58.986558 -27.489639)', 4326),
        17220775, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '8'),
        'Vuelta: Barrio UOM → Barberán', 'B', 1,
        st_geomfromtext('LINESTRING(-58.986439 -27.489547, -58.989911 -27.486477, -58.988945 -27.485628, -58.989860 -27.479829, -58.973887 -27.465450, -58.983835 -27.456623, -58.981194 -27.454255, -58.986512 -27.449551, -58.988299 -27.451144, -58.987434 -27.451907, -58.993521 -27.457344, -58.999790 -27.451759, -59.000434 -27.451231, -59.000935 -27.450970, -59.012984 -27.440220, -59.014735 -27.441700, -59.016559 -27.441744, -59.016505 -27.443102, -59.017277 -27.443906, -59.017103 -27.444015, -59.017111 -27.446389, -59.025990 -27.454337, -59.028836 -27.451799, -59.028898 -27.451573, -59.028743 -27.451423, -59.028721 -27.451170, -59.028974 -27.450955, -59.029274 -27.450911, -59.036693 -27.457563)', 4326),
        17236756, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '107'),
        'Vuelta: San Pedro (Fontana) → Resistencia Centro', 'A', 1,
        st_geomfromtext('LINESTRING(-59.042653 -27.401334, -59.040079 -27.403633, -59.049097 -27.411690, -59.048707 -27.411881, -59.048595 -27.412180, -59.048665 -27.412328, -59.049300 -27.412920, -59.049586 -27.413072, -59.050059 -27.413942, -59.041209 -27.417817, -59.040614 -27.416824, -59.039239 -27.417297, -59.032247 -27.423396, -59.015468 -27.438279, -59.015342 -27.438464, -59.015482 -27.438599, -59.015510 -27.438837, -59.015239 -27.439101, -59.014945 -27.439085, -59.014205 -27.438444, -59.013741 -27.437528, -59.011553 -27.435420, -59.011215 -27.434530, -59.010763 -27.431741, -59.010342 -27.431276, -59.010226 -27.430723, -59.009930 -27.430739, -59.009788 -27.430912, -59.009841 -27.431418, -59.009666 -27.431904, -59.009280 -27.432547, -59.008598 -27.433270, -59.007601 -27.433999, -59.005099 -27.434994, -59.004237 -27.435489, -58.987440 -27.450362, -58.988299 -27.451144, -58.986515 -27.452719, -58.984745 -27.451139, -58.986512 -27.449551)', 4326),
        17363578, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '107'),
        'Vuelta: Cementerio Fontana → Resistencia Centro', 'B', 1,
        st_geomfromtext('LINESTRING(-59.047026 -27.422881, -59.057018 -27.413971, -59.055300 -27.412405, -59.055186 -27.412418, -59.052770 -27.414632, -59.051975 -27.413904, -59.046751 -27.418543, -59.045619 -27.417526, -59.043348 -27.419555, -59.041622 -27.418032, -59.041281 -27.417912, -59.040349 -27.416391, -59.040248 -27.416346, -59.042505 -27.414335, -59.038918 -27.411140, -59.036648 -27.413163, -59.032975 -27.409873, -59.030598 -27.411990, -59.034444 -27.415446, -59.033082 -27.416645, -59.029257 -27.413246, -59.024527 -27.417439, -59.026210 -27.418932, -59.026477 -27.419542, -59.027445 -27.420619, -59.026848 -27.421422, -59.027089 -27.421640, -59.022902 -27.425375, -59.022779 -27.425478, -59.019140 -27.422247, -59.010789 -27.429667, -59.010934 -27.430409, -59.010854 -27.430567, -59.010546 -27.430728, -59.010125 -27.430699, -59.009832 -27.430803, -59.009776 -27.430995, -59.009841 -27.431418, -59.009666 -27.431904, -59.009280 -27.432547, -59.008598 -27.433270, -59.007601 -27.433999, -59.005099 -27.434994, -59.004237 -27.435489, -58.987440 -27.450362, -58.988299 -27.451144, -58.986515 -27.452719, -58.984745 -27.451139, -58.986512 -27.449551)', 4326),
        17363998, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '203'),
        'Ida: Barranqueras → Puerto Vilelas', null, 0,
        st_geomfromtext('LINESTRING(-58.914819 -27.463878, -58.914242 -27.464164, -58.910451 -27.467552, -58.910410 -27.467665, -58.910358 -27.468431, -58.910434 -27.468780, -58.912341 -27.471732, -58.916563 -27.472666, -58.921825 -27.470160, -58.922067 -27.470126, -58.928310 -27.475734, -58.930917 -27.473461, -58.931765 -27.474241, -58.930038 -27.475766, -58.931836 -27.477356, -58.930888 -27.478175, -58.930729 -27.478036, -58.926324 -27.481939, -58.931747 -27.486798, -58.933486 -27.485254, -58.938717 -27.489949, -58.934282 -27.493895, -58.935144 -27.494671, -58.935892 -27.495136, -58.936232 -27.495192, -58.936743 -27.495027, -58.937443 -27.494553, -58.941520 -27.490959, -58.941576 -27.491007, -58.943462 -27.489351, -58.938766 -27.493505, -58.945185 -27.487819, -58.954897 -27.496524, -58.955766 -27.495758, -58.957470 -27.497312, -58.961217 -27.494014, -58.962894 -27.495511, -58.959160 -27.498814, -58.955766 -27.495758, -58.954897 -27.496524, -58.952284 -27.494182, -58.943486 -27.502023, -58.943409 -27.502278, -58.943554 -27.502471, -58.943571 -27.502688, -58.943463 -27.502842, -58.942760 -27.503173, -58.942569 -27.503377, -58.941889 -27.515879, -58.941880 -27.518000, -58.941631 -27.519554, -58.941382 -27.519991, -58.941035 -27.520478, -58.940545 -27.520978, -58.923864 -27.535775)', 4326),
        17367373, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '203'),
        'Vuelta: Puerto Vilelas → Barranqueras', null, 1,
        st_geomfromtext('LINESTRING(-58.923864 -27.535775, -58.940237 -27.521249, -58.940946 -27.520344, -58.941294 -27.519735, -58.941582 -27.518902, -58.941760 -27.517030, -58.942510 -27.503163, -58.942226 -27.502523, -58.942171 -27.501722, -58.941730 -27.500937, -58.941314 -27.500439, -58.936903 -27.496475, -58.936019 -27.496070, -58.935896 -27.495873, -58.935888 -27.495681, -58.936088 -27.495400, -58.936447 -27.495318, -58.936856 -27.495088, -58.938582 -27.493583, -58.947723 -27.485467, -58.950313 -27.483082, -58.949654 -27.483000, -58.943565 -27.482973, -58.939911 -27.486143, -58.939740 -27.485996, -58.937003 -27.488429, -58.933560 -27.485321, -58.931838 -27.486878, -58.926324 -27.481939, -58.930729 -27.478036, -58.929100 -27.476575, -58.931765 -27.474241, -58.930917 -27.473461, -58.928234 -27.475809, -58.922038 -27.470224, -58.916500 -27.472807, -58.912762 -27.471919, -58.912475 -27.471931, -58.910384 -27.468666, -58.910226 -27.468461, -58.909903 -27.468277, -58.909822 -27.468028, -58.909933 -27.467872, -58.910451 -27.467552, -58.914242 -27.464164, -58.914569 -27.463704)', 4326),
        17368281, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '204'),
        'Ida: Fontana → Barranqueras', null, 0,
        st_geomfromtext('LINESTRING(-59.042653 -27.401334, -59.032975 -27.409873, -59.030598 -27.411990, -59.030641 -27.412028, -59.030552 -27.412115, -59.010789 -27.429667, -59.010934 -27.430409, -59.010854 -27.430567, -59.010546 -27.430728, -59.010125 -27.430699, -59.009832 -27.430803, -59.009776 -27.430995, -59.009841 -27.431418, -59.009666 -27.431904, -59.009280 -27.432547, -59.008598 -27.433270, -59.007601 -27.433999, -59.005099 -27.434994, -59.004237 -27.435489, -58.987440 -27.450362, -58.988299 -27.451144, -58.986515 -27.452719, -58.985684 -27.451977, -58.984717 -27.452795, -58.950531 -27.483150, -58.950299 -27.483055, -58.949654 -27.483000, -58.937085 -27.482958, -58.936153 -27.483004, -58.935872 -27.482653, -58.934161 -27.481106, -58.919246 -27.467706, -58.914875 -27.463867, -58.914242 -27.464164, -58.911281 -27.466806, -58.910451 -27.467552, -58.910363 -27.467919)', 4326),
        17368288, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '205'),
        'Vuelta: Resistencia → Fontana', null, 1,
        st_geomfromtext('LINESTRING(-58.986439 -27.489547, -58.979199 -27.483069, -58.993587 -27.470305, -58.987327 -27.464674, -58.986487 -27.463935, -58.986333 -27.463882, -58.986289 -27.463682, -58.986577 -27.463511, -58.999790 -27.451759, -59.000434 -27.451231, -59.000935 -27.450970, -59.014605 -27.438797, -59.014398 -27.438612, -59.014406 -27.438433, -59.014517 -27.438280, -59.014786 -27.438152, -59.015177 -27.438326, -59.015360 -27.438290, -59.033128 -27.422509, -59.038842 -27.417544, -59.039316 -27.417213, -59.040583 -27.416773, -59.049300 -27.412920, -59.048665 -27.412328, -59.048595 -27.412180, -59.048707 -27.411881, -59.049097 -27.411690, -59.040079 -27.403633, -59.042653 -27.401334)', 4326),
        17369420, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '205'),
        'Ida: Fontana → Resistencia', null, 0,
        st_geomfromtext('LINESTRING(-59.043308 -27.400748, -59.040079 -27.403633, -59.049097 -27.411690, -59.048707 -27.411881, -59.048595 -27.412180, -59.048665 -27.412328, -59.049412 -27.412963, -59.040614 -27.416824, -59.039239 -27.417297, -59.032247 -27.423396, -59.015468 -27.438279, -59.015342 -27.438464, -59.015482 -27.438599, -59.015523 -27.438762, -59.015369 -27.439041, -59.015079 -27.439119, -59.014703 -27.438883, -58.986726 -27.463689, -58.986675 -27.463806, -58.988275 -27.465237, -58.988400 -27.465276, -58.988442 -27.465391, -58.993881 -27.470225, -58.986547 -27.476696, -58.989953 -27.479757, -58.988982 -27.485654, -58.989911 -27.486477, -58.986439 -27.489547)', 4326),
        17369421, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '204'),
        'Vuelta: Barranqueras → Fontana', null, 1,
        st_geomfromtext('LINESTRING(-58.910451 -27.467552, -58.910363 -27.467919, -58.910428 -27.468081, -58.910361 -27.468517, -58.910434 -27.468780, -58.912341 -27.471732, -58.915786 -27.472538, -58.916563 -27.472666, -58.921825 -27.470160, -58.922067 -27.470126, -58.935716 -27.482380, -58.936338 -27.482816, -58.936943 -27.482872, -58.946589 -27.482921, -58.950605 -27.482886, -58.985516 -27.451965, -58.985590 -27.451893, -58.984745 -27.451139, -58.986512 -27.449551, -58.987388 -27.450316, -59.004166 -27.435421, -59.005117 -27.434878, -59.007463 -27.433947, -59.008393 -27.433341, -59.008934 -27.432805, -59.009584 -27.431853, -59.009734 -27.431395, -59.009664 -27.430776, -59.010102 -27.430178, -59.009972 -27.429480, -59.010124 -27.429300, -59.010430 -27.429224, -59.010635 -27.429292, -59.010760 -27.429521, -59.010882 -27.429453, -59.029702 -27.412715, -59.032042 -27.410738, -59.042653 -27.401334)', 4326),
        17369422, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '207'),
        'Ida: Fontana → Barranqueras', null, 0,
        st_geomfromtext('LINESTRING(-59.041386 -27.402461, -59.030598 -27.411990, -59.037856 -27.418459, -59.015468 -27.438279, -59.015342 -27.438464, -59.029568 -27.451170, -59.029878 -27.451457, -59.029825 -27.451711, -59.029691 -27.451874, -59.029358 -27.451986, -59.029156 -27.451807, -59.028972 -27.451876, -59.027778 -27.452929, -59.025990 -27.454337, -58.989823 -27.486402, -58.988945 -27.485628, -58.985480 -27.488693, -58.972092 -27.476669, -58.957763 -27.489358, -58.950736 -27.483097, -58.950469 -27.483159, -58.950299 -27.483055, -58.949654 -27.483000, -58.937085 -27.482958, -58.936153 -27.483004, -58.935872 -27.482653, -58.934161 -27.481106, -58.919246 -27.467706, -58.914875 -27.463867)', 4326),
        17370233, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;
insert into public.route_variants (line_id, name, branch, direction, geom, osm_relation_id, is_active)
values ((select l.id from public.lines l join public.networks n on n.id = l.network_id
         where n.code = 'gran-resistencia' and l.code = '207'),
        'Vuelta: Barranqueras → Fontana', null, 1,
        st_geomfromtext('LINESTRING(-58.915024 -27.463716, -58.915157 -27.463921, -58.929167 -27.476515, -58.935716 -27.482380, -58.936338 -27.482816, -58.936943 -27.482872, -58.949683 -27.482934, -58.950581 -27.482869, -58.950752 -27.482938, -58.957769 -27.489249, -58.972085 -27.476557, -58.986519 -27.489478, -58.989911 -27.486477, -58.989823 -27.486402, -58.993620 -27.483015, -59.028898 -27.451719, -59.028898 -27.451573, -59.028434 -27.451141, -59.014398 -27.438612, -59.014406 -27.438433, -59.014623 -27.438196, -59.014786 -27.438152, -59.015177 -27.438326, -59.015360 -27.438290, -59.037707 -27.418494, -59.030478 -27.412048, -59.032042 -27.410738, -59.041386 -27.402461)', 4326),
        17370234, true)
on conflict (osm_relation_id) do update set
    line_id = excluded.line_id,
    name = excluded.name,
    branch = excluded.branch,
    direction = excluded.direction,
    geom = excluded.geom,
    is_active = true;

-- ------------------------------------------------------------
-- 4. Secuencia de paradas por recorrido (5287)
--    Se reemplaza entera: si en OSM sacaron una parada del
--    recorrido, acá también tiene que desaparecer.
-- ------------------------------------------------------------
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 4578434);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (11741246893::bigint, 1),
         (11594616808::bigint, 2),
         (11594616807::bigint, 3),
         (11591414374::bigint, 4),
         (11602247236::bigint, 5),
         (11594616806::bigint, 6),
         (11594616805::bigint, 7),
         (11594616804::bigint, 8),
         (11596427200::bigint, 9),
         (11594616803::bigint, 10),
         (11594616802::bigint, 11),
         (11594616801::bigint, 12),
         (11602247234::bigint, 13),
         (11594616800::bigint, 14),
         (11591414385::bigint, 15),
         (11594616799::bigint, 16),
         (10880100961::bigint, 17),
         (11594616798::bigint, 18),
         (11594616797::bigint, 19),
         (11622193174::bigint, 20),
         (11602247232::bigint, 21),
         (2703455233::bigint, 22),
         (11594616795::bigint, 23),
         (11591414390::bigint, 24),
         (11594616794::bigint, 25),
         (11640593143::bigint, 26),
         (11591414392::bigint, 27),
         (1212726589::bigint, 28),
         (11594616792::bigint, 29),
         (11594616791::bigint, 30),
         (11594616790::bigint, 31),
         (11619110798::bigint, 32),
         (11594616789::bigint, 33),
         (11594616788::bigint, 34),
         (11616172972::bigint, 35),
         (11594616787::bigint, 36),
         (11591414400::bigint, 37),
         (11594616785::bigint, 38),
         (11591414402::bigint, 39),
         (1728971799::bigint, 40),
         (10127025923::bigint, 41),
         (11594616781::bigint, 42),
         (11594616780::bigint, 43),
         (5389795606::bigint, 44),
         (12155249142::bigint, 45),
         (5377854740::bigint, 46),
         (12155249141::bigint, 47),
         (12144077505::bigint, 48),
         (12146079713::bigint, 49),
         (11594616779::bigint, 50),
         (5423025709::bigint, 51),
         (11602247216::bigint, 52),
         (11508368331::bigint, 53),
         (2274623288::bigint, 54),
         (11505989076::bigint, 55),
         (11594616778::bigint, 56),
         (11594616777::bigint, 57),
         (5355167648::bigint, 58),
         (1589583902::bigint, 59),
         (11616169066::bigint, 60),
         (11594616775::bigint, 61),
         (5342771436::bigint, 62),
         (11594616774::bigint, 63),
         (11594616773::bigint, 64),
         (11594616772::bigint, 65),
         (11594616771::bigint, 66),
         (11594616770::bigint, 67),
         (11594616769::bigint, 68),
         (11594605668::bigint, 69),
         (11594605667::bigint, 70),
         (1209331517::bigint, 71)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 4578434) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 4578435);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (1209331517::bigint, 1),
         (11591414420::bigint, 2),
         (11591414419::bigint, 3),
         (11596427218::bigint, 4),
         (11591414418::bigint, 5),
         (11596427216::bigint, 6),
         (11591414416::bigint, 7),
         (11596427215::bigint, 8),
         (11591414415::bigint, 9),
         (11591414414::bigint, 10),
         (11591414413::bigint, 11),
         (11591414412::bigint, 12),
         (11591414411::bigint, 13),
         (11591414410::bigint, 14),
         (11591414409::bigint, 15),
         (11668801264::bigint, 16),
         (11591414407::bigint, 17),
         (11591414406::bigint, 18),
         (11602247215::bigint, 19),
         (5361852918::bigint, 20),
         (5361852916::bigint, 21),
         (12120184002::bigint, 22),
         (12146079715::bigint, 23),
         (12146079714::bigint, 24),
         (5395727300::bigint, 25),
         (5340694064::bigint, 26),
         (1804502952::bigint, 27),
         (12150561835::bigint, 28),
         (1804601348::bigint, 29),
         (11648852784::bigint, 30),
         (11591414404::bigint, 31),
         (11591414403::bigint, 32),
         (5438692442::bigint, 33),
         (11616169068::bigint, 34),
         (11591414402::bigint, 35),
         (11591414401::bigint, 36),
         (5193816343::bigint, 37),
         (5193846665::bigint, 38),
         (11619110802::bigint, 39),
         (11591414399::bigint, 40),
         (11591414398::bigint, 41),
         (11591414397::bigint, 42),
         (11591414396::bigint, 43),
         (11591414395::bigint, 44),
         (11750237034::bigint, 45),
         (11591414394::bigint, 46),
         (11596427201::bigint, 47),
         (11591414393::bigint, 48),
         (1212726589::bigint, 49),
         (11591414392::bigint, 50),
         (11640593143::bigint, 51),
         (11591414391::bigint, 52),
         (11591414390::bigint, 53),
         (11594616795::bigint, 54),
         (2703511768::bigint, 55),
         (2703455233::bigint, 56),
         (11602247232::bigint, 57),
         (11622193174::bigint, 58),
         (11750809189::bigint, 59),
         (11594616797::bigint, 60),
         (11591414387::bigint, 61),
         (10880100961::bigint, 62),
         (11594616799::bigint, 63),
         (11591414385::bigint, 64),
         (11602247233::bigint, 65),
         (11602247234::bigint, 66),
         (11591414384::bigint, 67),
         (11591414380::bigint, 68),
         (11591414378::bigint, 69),
         (11652450394::bigint, 70),
         (11591414377::bigint, 71),
         (11591414376::bigint, 72),
         (11591414375::bigint, 73),
         (11648852775::bigint, 74),
         (11591414374::bigint, 75),
         (11648852774::bigint, 76),
         (11591414373::bigint, 77),
         (11591414372::bigint, 78)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 4578435) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 4578459);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (11741246893::bigint, 1),
         (11594616808::bigint, 2),
         (11594616807::bigint, 3),
         (11591414374::bigint, 4),
         (11602247236::bigint, 5),
         (11594616806::bigint, 6),
         (11594616805::bigint, 7),
         (11594616804::bigint, 8),
         (11596427200::bigint, 9),
         (11594616803::bigint, 10),
         (11594616802::bigint, 11),
         (11594616801::bigint, 12),
         (11602247234::bigint, 13),
         (11594616800::bigint, 14),
         (11591414385::bigint, 15),
         (11594616799::bigint, 16),
         (10880100961::bigint, 17),
         (11594616798::bigint, 18),
         (11594616797::bigint, 19),
         (11622193174::bigint, 20),
         (11602247232::bigint, 21),
         (2703455233::bigint, 22),
         (11594616795::bigint, 23),
         (11591414390::bigint, 24),
         (11594616794::bigint, 25),
         (11640593143::bigint, 26),
         (11591414392::bigint, 27),
         (1212726589::bigint, 28),
         (11594616792::bigint, 29),
         (11594616791::bigint, 30),
         (11594616790::bigint, 31),
         (11619110798::bigint, 32),
         (11594616789::bigint, 33),
         (11594616788::bigint, 34),
         (11602247231::bigint, 35),
         (11750237024::bigint, 36),
         (11591414397::bigint, 37),
         (11602247230::bigint, 38),
         (11602247229::bigint, 39),
         (11602247228::bigint, 40),
         (11596427205::bigint, 41),
         (11602247226::bigint, 42),
         (11596427206::bigint, 43),
         (11602247225::bigint, 44),
         (11602247224::bigint, 45),
         (11602247223::bigint, 46),
         (11602247222::bigint, 47),
         (11602247221::bigint, 48),
         (11602247220::bigint, 49),
         (11602247219::bigint, 50),
         (11602247218::bigint, 51),
         (11602247217::bigint, 52),
         (5389795606::bigint, 53),
         (12155249142::bigint, 54),
         (5377854740::bigint, 55),
         (12155249141::bigint, 56),
         (12144077505::bigint, 57),
         (12146079713::bigint, 58),
         (11594616779::bigint, 59),
         (5423025709::bigint, 60),
         (11602247216::bigint, 61),
         (11602247215::bigint, 62),
         (11602247214::bigint, 63),
         (11571486260::bigint, 64),
         (11602247212::bigint, 65),
         (11602247211::bigint, 66),
         (5354500956::bigint, 67),
         (11602247210::bigint, 68),
         (11602247209::bigint, 69),
         (11602247208::bigint, 70),
         (5361854538::bigint, 71),
         (1203470815::bigint, 72),
         (11591414415::bigint, 73),
         (11596427215::bigint, 74),
         (11591414416::bigint, 75),
         (11591414417::bigint, 76),
         (11596427217::bigint, 77),
         (11596427218::bigint, 78),
         (11591414419::bigint, 79),
         (11596427219::bigint, 80),
         (11596427220::bigint, 81)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 4578459) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 4578460);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (1209331517::bigint, 1),
         (11591414420::bigint, 2),
         (11591414419::bigint, 3),
         (11596427218::bigint, 4),
         (11591414418::bigint, 5),
         (11596427216::bigint, 6),
         (11591414416::bigint, 7),
         (11596427215::bigint, 8),
         (11591414415::bigint, 9),
         (1203470815::bigint, 10),
         (5361854538::bigint, 11),
         (5361854536::bigint, 12),
         (5361854534::bigint, 13),
         (5361854532::bigint, 14),
         (13173603252::bigint, 15),
         (5361854530::bigint, 16),
         (5355167640::bigint, 17),
         (10922678839::bigint, 18),
         (11596427213::bigint, 19),
         (5361854528::bigint, 20),
         (5361852918::bigint, 21),
         (5361852916::bigint, 22),
         (12120184002::bigint, 23),
         (12146079715::bigint, 24),
         (12146079714::bigint, 25),
         (5393038581::bigint, 26),
         (5340694064::bigint, 27),
         (5395727300::bigint, 28),
         (10788479384::bigint, 29),
         (11731162795::bigint, 30),
         (1741501481::bigint, 31),
         (1741501485::bigint, 32),
         (10788568331::bigint, 33),
         (11596427212::bigint, 34),
         (11596427211::bigint, 35),
         (11596427210::bigint, 36),
         (11596427209::bigint, 37),
         (11596427208::bigint, 38),
         (11596427207::bigint, 39),
         (11602247225::bigint, 40),
         (11596427206::bigint, 41),
         (11602247226::bigint, 42),
         (11596427205::bigint, 43),
         (11602247228::bigint, 44),
         (11596427203::bigint, 45),
         (11596427202::bigint, 46),
         (11591414396::bigint, 47),
         (11591414395::bigint, 48),
         (11750237034::bigint, 49),
         (11591414394::bigint, 50),
         (11596427201::bigint, 51),
         (11591414393::bigint, 52),
         (1212726589::bigint, 53),
         (11591414392::bigint, 54),
         (11640593143::bigint, 55),
         (11591414391::bigint, 56),
         (11591414390::bigint, 57),
         (11594616795::bigint, 58),
         (2703511768::bigint, 59),
         (2703455233::bigint, 60),
         (11602247232::bigint, 61),
         (11622193174::bigint, 62),
         (11750809189::bigint, 63),
         (11594616797::bigint, 64),
         (11591414387::bigint, 65),
         (10880100961::bigint, 66),
         (11594616799::bigint, 67),
         (11591414385::bigint, 68),
         (11602247233::bigint, 69),
         (11602247234::bigint, 70),
         (11591414384::bigint, 71),
         (11591414380::bigint, 72),
         (11591414378::bigint, 73),
         (11652450394::bigint, 74),
         (11591414377::bigint, 75),
         (11591414376::bigint, 76),
         (11591414375::bigint, 77),
         (11648852775::bigint, 78),
         (11591414374::bigint, 79),
         (11648852774::bigint, 80),
         (11591414373::bigint, 81),
         (11591414372::bigint, 82)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 4578460) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 4580355);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (11741246893::bigint, 1),
         (11594616808::bigint, 2),
         (11594616807::bigint, 3),
         (11591414374::bigint, 4),
         (11602247236::bigint, 5),
         (11594616806::bigint, 6),
         (11594616805::bigint, 7),
         (11594616804::bigint, 8),
         (11596427200::bigint, 9),
         (11594616803::bigint, 10),
         (11594616802::bigint, 11),
         (11594616801::bigint, 12),
         (11602247234::bigint, 13),
         (11594616800::bigint, 14),
         (11591414385::bigint, 15),
         (11594616799::bigint, 16),
         (10880100961::bigint, 17),
         (11594616798::bigint, 18),
         (11594616797::bigint, 19),
         (11622193174::bigint, 20),
         (11602247232::bigint, 21),
         (2703455233::bigint, 22),
         (11594616795::bigint, 23),
         (11591414390::bigint, 24),
         (11594616794::bigint, 25),
         (11640593143::bigint, 26),
         (11591414392::bigint, 27),
         (1212726589::bigint, 28),
         (11594616792::bigint, 29),
         (11594616791::bigint, 30),
         (11594616790::bigint, 31),
         (2398666781::bigint, 32),
         (11616172977::bigint, 33),
         (11616172973::bigint, 34),
         (11616172972::bigint, 35),
         (11594616787::bigint, 36),
         (11616172970::bigint, 37),
         (11616172969::bigint, 38),
         (11616169068::bigint, 39),
         (1728971799::bigint, 40),
         (10127025923::bigint, 41),
         (11594616781::bigint, 42),
         (11594616780::bigint, 43),
         (5389795606::bigint, 44),
         (12155249142::bigint, 45),
         (5377854740::bigint, 46),
         (12155249141::bigint, 47),
         (12144077505::bigint, 48),
         (12146079713::bigint, 49),
         (11594616779::bigint, 50),
         (5423025709::bigint, 51),
         (11602247216::bigint, 52),
         (11602247215::bigint, 53),
         (11602247214::bigint, 54),
         (11571486260::bigint, 55),
         (11616169067::bigint, 56),
         (5355167648::bigint, 57),
         (1589583902::bigint, 58),
         (11616169066::bigint, 59),
         (11594616775::bigint, 60),
         (5342771436::bigint, 61),
         (11594616774::bigint, 62),
         (11594616773::bigint, 63),
         (11594616772::bigint, 64),
         (11594616771::bigint, 65),
         (11594616770::bigint, 66),
         (11594616769::bigint, 67),
         (11594605668::bigint, 68),
         (11594605667::bigint, 69),
         (1209331517::bigint, 70)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 4580355) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 4580356);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (1209331517::bigint, 1),
         (11591414420::bigint, 2),
         (11591414419::bigint, 3),
         (11596427218::bigint, 4),
         (11591414418::bigint, 5),
         (11596427216::bigint, 6),
         (11591414416::bigint, 7),
         (11591414415::bigint, 8),
         (11591414414::bigint, 9),
         (11591414413::bigint, 10),
         (11591414412::bigint, 11),
         (11591414411::bigint, 12),
         (11591414410::bigint, 13),
         (11591414409::bigint, 14),
         (11668801264::bigint, 15),
         (11591414407::bigint, 16),
         (11619110805::bigint, 17),
         (10922678839::bigint, 18),
         (11596427213::bigint, 19),
         (5361854528::bigint, 20),
         (5361852918::bigint, 21),
         (5361852916::bigint, 22),
         (12120184002::bigint, 23),
         (12146079715::bigint, 24),
         (12146079714::bigint, 25),
         (5393038581::bigint, 26),
         (5340694064::bigint, 27),
         (5395727300::bigint, 28),
         (10788479384::bigint, 29),
         (11731162795::bigint, 30),
         (1741501481::bigint, 31),
         (1741501485::bigint, 32),
         (11648852785::bigint, 33),
         (11648852784::bigint, 34),
         (11591414404::bigint, 35),
         (11591414403::bigint, 36),
         (5438692442::bigint, 37),
         (11750237042::bigint, 38),
         (11750237016::bigint, 39),
         (11619110802::bigint, 40),
         (11619110801::bigint, 41),
         (11619110800::bigint, 42),
         (2396794433::bigint, 43),
         (11619110798::bigint, 44),
         (11591414394::bigint, 45),
         (11596427201::bigint, 46),
         (11591414393::bigint, 47),
         (1212726589::bigint, 48),
         (11591414392::bigint, 49),
         (11640593143::bigint, 50),
         (11591414391::bigint, 51),
         (11591414390::bigint, 52),
         (11594616795::bigint, 53),
         (2703511768::bigint, 54),
         (2703455233::bigint, 55),
         (11602247232::bigint, 56),
         (11622193174::bigint, 57),
         (11750809189::bigint, 58),
         (11594616797::bigint, 59),
         (11591414387::bigint, 60),
         (10880100961::bigint, 61),
         (11594616799::bigint, 62),
         (11591414385::bigint, 63),
         (11602247233::bigint, 64),
         (11602247234::bigint, 65),
         (11591414384::bigint, 66),
         (11591414380::bigint, 67),
         (11591414378::bigint, 68),
         (11652450394::bigint, 69),
         (11591414377::bigint, 70),
         (11591414376::bigint, 71),
         (11591414375::bigint, 72),
         (11648852775::bigint, 73),
         (11591414374::bigint, 74),
         (11648852774::bigint, 75),
         (11591414373::bigint, 76),
         (11591414372::bigint, 77)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 4580356) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 4600305);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (11499913960::bigint, 1),
         (11622193195::bigint, 2),
         (11622193194::bigint, 3),
         (11622193193::bigint, 4),
         (11568879567::bigint, 5),
         (11580325127::bigint, 6),
         (11576284064::bigint, 7),
         (2680328524::bigint, 8),
         (11626627888::bigint, 9),
         (2680328508::bigint, 10),
         (11655881340::bigint, 11),
         (11652450384::bigint, 12),
         (11622193190::bigint, 13),
         (11652450385::bigint, 14),
         (10119893798::bigint, 15),
         (2398804688::bigint, 16),
         (2673402389::bigint, 17),
         (11626627891::bigint, 18),
         (11622193187::bigint, 19),
         (11622193186::bigint, 20),
         (11750237050::bigint, 21),
         (9630273766::bigint, 22),
         (11622193185::bigint, 23),
         (11750237049::bigint, 24),
         (11648852788::bigint, 25),
         (11750237048::bigint, 26),
         (3054594660::bigint, 27),
         (3054594661::bigint, 28),
         (11499855690::bigint, 29),
         (3054594662::bigint, 30),
         (11499855691::bigint, 31),
         (3054594663::bigint, 32),
         (3054594664::bigint, 33),
         (3054594665::bigint, 34),
         (11622193184::bigint, 35),
         (9654655365::bigint, 36),
         (11622193183::bigint, 37),
         (11499855693::bigint, 38),
         (10788568329::bigint, 39),
         (11750237012::bigint, 40),
         (10788568330::bigint, 41),
         (10055961687::bigint, 42),
         (1804502956::bigint, 43),
         (1804502955::bigint, 44),
         (5393825158::bigint, 45),
         (1804502952::bigint, 46),
         (12150561835::bigint, 47),
         (1804601348::bigint, 48),
         (5389795608::bigint, 49),
         (10788568331::bigint, 50),
         (11648852784::bigint, 51),
         (11655881339::bigint, 52),
         (9693510645::bigint, 53),
         (11622193181::bigint, 54),
         (11622193180::bigint, 55),
         (11622193179::bigint, 56),
         (11724812660::bigint, 57),
         (11622193178::bigint, 58),
         (11626627906::bigint, 59),
         (11622193177::bigint, 60),
         (11626627907::bigint, 61),
         (11648852782::bigint, 62),
         (11622193176::bigint, 63),
         (11622193175::bigint, 64),
         (2396794433::bigint, 65),
         (11619110798::bigint, 66),
         (11591414394::bigint, 67),
         (11596427201::bigint, 68),
         (11591414393::bigint, 69),
         (1212726589::bigint, 70),
         (11591414392::bigint, 71),
         (11640593143::bigint, 72),
         (11591414391::bigint, 73),
         (11591414390::bigint, 74),
         (11594616795::bigint, 75),
         (2703511768::bigint, 76),
         (2703455233::bigint, 77),
         (11602247232::bigint, 78),
         (11622193174::bigint, 79),
         (11750809189::bigint, 80),
         (11594616797::bigint, 81),
         (11591414387::bigint, 82),
         (10880100961::bigint, 83)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 4600305) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 4600306);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (10880100961::bigint, 1),
         (11750237029::bigint, 2),
         (11626627914::bigint, 3),
         (11750237028::bigint, 4),
         (11626627913::bigint, 5),
         (11750237027::bigint, 6),
         (11626627912::bigint, 7),
         (11626627911::bigint, 8),
         (11626627910::bigint, 9),
         (2380406967::bigint, 10),
         (11626627909::bigint, 11),
         (11629375277::bigint, 12),
         (11648852782::bigint, 13),
         (11626627907::bigint, 14),
         (11622193177::bigint, 15),
         (11640593139::bigint, 16),
         (11626627906::bigint, 17),
         (11622193178::bigint, 18),
         (11724812660::bigint, 19),
         (11626627905::bigint, 20),
         (11626627904::bigint, 21),
         (11626627903::bigint, 22),
         (11626627902::bigint, 23),
         (5426465582::bigint, 24),
         (9574100730::bigint, 25),
         (1605949296::bigint, 26),
         (11568883386::bigint, 27),
         (5401746653::bigint, 28),
         (12144077505::bigint, 29),
         (12112457212::bigint, 30),
         (12120184002::bigint, 31),
         (12146079715::bigint, 32),
         (12146079714::bigint, 33),
         (5393038581::bigint, 34),
         (5340694064::bigint, 35),
         (5395727300::bigint, 36),
         (1589504388::bigint, 37),
         (5401078638::bigint, 38),
         (11586752350::bigint, 39),
         (9610020118::bigint, 40),
         (11626627901::bigint, 41),
         (11626627900::bigint, 42),
         (9608017372::bigint, 43),
         (9592863285::bigint, 44),
         (3481605614::bigint, 45),
         (3077546540::bigint, 46),
         (3077546539::bigint, 47),
         (11626627897::bigint, 48),
         (11716558594::bigint, 49),
         (9630273766::bigint, 50),
         (11626627895::bigint, 51),
         (11750237011::bigint, 52),
         (11626627894::bigint, 53),
         (11626627893::bigint, 54),
         (11626627892::bigint, 55),
         (11626627891::bigint, 56),
         (2673402389::bigint, 57),
         (2398804688::bigint, 58),
         (10119893798::bigint, 59),
         (11652450385::bigint, 60),
         (11622193190::bigint, 61),
         (11652450384::bigint, 62),
         (11655881340::bigint, 63),
         (2680328508::bigint, 64),
         (11626627888::bigint, 65),
         (2680328524::bigint, 66),
         (11576284064::bigint, 67),
         (11572838469::bigint, 68),
         (11568879567::bigint, 69),
         (1217510893::bigint, 70),
         (11508368353::bigint, 71)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 4600306) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 4717752);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (11648852781::bigint, 1),
         (11668814584::bigint, 2),
         (11668814583::bigint, 3),
         (11668814582::bigint, 4),
         (11668814581::bigint, 5),
         (11668814580::bigint, 6),
         (11655881336::bigint, 7),
         (11668814579::bigint, 8),
         (11664987754::bigint, 9),
         (11668814577::bigint, 10),
         (11668814576::bigint, 11),
         (11668814575::bigint, 12),
         (11594616799::bigint, 13),
         (10880100961::bigint, 14),
         (11594616798::bigint, 15),
         (11594616797::bigint, 16),
         (11622193174::bigint, 17),
         (11602247232::bigint, 18),
         (2703455233::bigint, 19),
         (11594616795::bigint, 20),
         (11591414390::bigint, 21),
         (11594616794::bigint, 22),
         (11640593143::bigint, 23),
         (11591414392::bigint, 24),
         (1212726589::bigint, 25),
         (11591414393::bigint, 26),
         (11668814574::bigint, 27),
         (11668814573::bigint, 28),
         (11668814572::bigint, 29),
         (11664987760::bigint, 30),
         (11668814571::bigint, 31),
         (11664987761::bigint, 32),
         (11668814570::bigint, 33),
         (11664987762::bigint, 34),
         (11668814569::bigint, 35),
         (11664987763::bigint, 36),
         (11668801268::bigint, 37),
         (11668801267::bigint, 38),
         (2377596077::bigint, 39),
         (11672169200::bigint, 40),
         (11668801266::bigint, 41),
         (11590192518::bigint, 42),
         (11590192517::bigint, 43),
         (11590192516::bigint, 44),
         (11590192515::bigint, 45),
         (11750237012::bigint, 46),
         (10788568330::bigint, 47),
         (10055961687::bigint, 48),
         (1804502956::bigint, 49),
         (1804502955::bigint, 50),
         (5377854740::bigint, 51),
         (5393825158::bigint, 52),
         (1804502952::bigint, 53),
         (12155249141::bigint, 54),
         (12144077505::bigint, 55),
         (12112457212::bigint, 56),
         (12120184002::bigint, 57),
         (12146079715::bigint, 58),
         (5349662693::bigint, 59),
         (10140159295::bigint, 60),
         (5349662692::bigint, 61),
         (11745843043::bigint, 62),
         (5337560205::bigint, 63),
         (9574158677::bigint, 64),
         (5354500954::bigint, 65),
         (9574158675::bigint, 66),
         (11668801265::bigint, 67),
         (5355167640::bigint, 68),
         (11602247211::bigint, 69),
         (11668801264::bigint, 70),
         (11591414407::bigint, 71),
         (5355167648::bigint, 72),
         (11668801263::bigint, 73),
         (5349662688::bigint, 74),
         (5355167643::bigint, 75),
         (5345412735::bigint, 76),
         (5354500959::bigint, 77),
         (11668801261::bigint, 78),
         (11668801260::bigint, 79),
         (11668801259::bigint, 80),
         (5340694070::bigint, 81),
         (9548014987::bigint, 82),
         (5354500975::bigint, 83),
         (11665004189::bigint, 84),
         (11665004190::bigint, 85)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 4717752) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 4717753);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (11665004190::bigint, 1),
         (4556866231::bigint, 2),
         (4592648165::bigint, 3),
         (11665004189::bigint, 4),
         (11665004188::bigint, 5),
         (11665004187::bigint, 6),
         (11665004186::bigint, 7),
         (11665004185::bigint, 8),
         (11665004184::bigint, 9),
         (11665004183::bigint, 10),
         (11665004182::bigint, 11),
         (11665004181::bigint, 12),
         (11665004180::bigint, 13),
         (11665004179::bigint, 14),
         (11665004178::bigint, 15),
         (11665004177::bigint, 16),
         (11665004176::bigint, 17),
         (11665004175::bigint, 18),
         (5337560214::bigint, 19),
         (1220129198::bigint, 20),
         (11665004173::bigint, 21),
         (5354500975::bigint, 22),
         (5354500973::bigint, 23),
         (5340694070::bigint, 24),
         (11665004171::bigint, 25),
         (5340694067::bigint, 26),
         (5342771445::bigint, 27),
         (11665004170::bigint, 28),
         (5354500972::bigint, 29),
         (2374450976::bigint, 30),
         (11665004169::bigint, 31),
         (5354428126::bigint, 32),
         (5342771436::bigint, 33),
         (5354500956::bigint, 34),
         (5354500957::bigint, 35),
         (11664987768::bigint, 36),
         (5354500955::bigint, 37),
         (11700999650::bigint, 38),
         (11703735602::bigint, 39),
         (5354500953::bigint, 40),
         (5354500951::bigint, 41),
         (5354500949::bigint, 42),
         (10082219830::bigint, 43),
         (12144077502::bigint, 44),
         (5395727302::bigint, 45),
         (12151464204::bigint, 46),
         (5395727300::bigint, 47),
         (5393038581::bigint, 48),
         (1589504388::bigint, 49),
         (5401078638::bigint, 50),
         (11586752350::bigint, 51),
         (10788568329::bigint, 52),
         (11586752349::bigint, 53),
         (11586752347::bigint, 54),
         (11586752348::bigint, 55),
         (11586752346::bigint, 56),
         (11664987766::bigint, 57),
         (11664987765::bigint, 58),
         (11742296361::bigint, 59),
         (11664987764::bigint, 60),
         (11734233717::bigint, 61),
         (2377499679::bigint, 62),
         (11664987763::bigint, 63),
         (11668814569::bigint, 64),
         (11664987762::bigint, 65),
         (11668814570::bigint, 66),
         (11664987761::bigint, 67),
         (11668814571::bigint, 68),
         (11664987760::bigint, 69),
         (11668814572::bigint, 70),
         (11664987759::bigint, 71),
         (11664987758::bigint, 72),
         (11594616793::bigint, 73),
         (11591414392::bigint, 74),
         (11640593143::bigint, 75),
         (11591414391::bigint, 76),
         (11591414390::bigint, 77),
         (11594616795::bigint, 78),
         (2703511768::bigint, 79),
         (2703455233::bigint, 80),
         (11602247232::bigint, 81),
         (11622193174::bigint, 82),
         (11750809189::bigint, 83),
         (11594616797::bigint, 84),
         (11591414387::bigint, 85),
         (10880100961::bigint, 86),
         (11594616799::bigint, 87),
         (11591414385::bigint, 88),
         (11664987756::bigint, 89),
         (11664987757::bigint, 90),
         (11668814578::bigint, 91),
         (11664987753::bigint, 92),
         (11664987752::bigint, 93),
         (11664987751::bigint, 94),
         (11664987750::bigint, 95),
         (11664987749::bigint, 96),
         (11664987748::bigint, 97),
         (11648852781::bigint, 98)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 4717753) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 4717754);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (11672169217::bigint, 1),
         (11676373679::bigint, 2),
         (11672169216::bigint, 3),
         (11676373681::bigint, 4),
         (11672169215::bigint, 5),
         (11672169214::bigint, 6),
         (11676373682::bigint, 7),
         (11672169213::bigint, 8),
         (11672169212::bigint, 9),
         (11676373684::bigint, 10),
         (11672169211::bigint, 11),
         (11672169210::bigint, 12),
         (11672169209::bigint, 13),
         (11672169208::bigint, 14),
         (11672169207::bigint, 15),
         (11672169206::bigint, 16),
         (11672169205::bigint, 17),
         (11672169204::bigint, 18),
         (11672169203::bigint, 19),
         (11672169202::bigint, 20),
         (11731162802::bigint, 21),
         (11734233713::bigint, 22),
         (11676373696::bigint, 23),
         (11668801268::bigint, 24),
         (11668801267::bigint, 25),
         (2377596077::bigint, 26),
         (11672169200::bigint, 27),
         (11668801266::bigint, 28),
         (11590192518::bigint, 29),
         (11590192517::bigint, 30),
         (11590192516::bigint, 31),
         (11590192515::bigint, 32),
         (11750237012::bigint, 33),
         (10788568330::bigint, 34),
         (10055961687::bigint, 35),
         (1804502956::bigint, 36),
         (1804502955::bigint, 37),
         (5393825158::bigint, 38),
         (1804502952::bigint, 39),
         (12155249141::bigint, 40),
         (12144077505::bigint, 41),
         (12112457212::bigint, 42),
         (12120184002::bigint, 43),
         (12146079715::bigint, 44),
         (5349662693::bigint, 45),
         (10140159295::bigint, 46),
         (5349662692::bigint, 47),
         (11745843043::bigint, 48),
         (5337560205::bigint, 49),
         (9574158677::bigint, 50),
         (5354500954::bigint, 51),
         (9574158675::bigint, 52),
         (11668801265::bigint, 53),
         (5355167640::bigint, 54),
         (11602247211::bigint, 55),
         (11668801264::bigint, 56),
         (11591414407::bigint, 57),
         (5355167648::bigint, 58),
         (11668801263::bigint, 59),
         (5349662688::bigint, 60),
         (5355167643::bigint, 61),
         (5345412735::bigint, 62),
         (5354500959::bigint, 63),
         (11668801261::bigint, 64),
         (11668801260::bigint, 65),
         (11668801259::bigint, 66),
         (5340694070::bigint, 67),
         (9548014987::bigint, 68),
         (5354500975::bigint, 69),
         (11665004189::bigint, 70),
         (5337560214::bigint, 71),
         (11676373708::bigint, 72),
         (11665004178::bigint, 73),
         (11665004179::bigint, 74),
         (11676373701::bigint, 75),
         (5395727293::bigint, 76),
         (5372434722::bigint, 77),
         (11676373702::bigint, 78),
         (5354428124::bigint, 79),
         (5395727295::bigint, 80),
         (5395727298::bigint, 81),
         (11676373705::bigint, 82),
         (5337560218::bigint, 83),
         (11676373706::bigint, 84),
         (4690768631::bigint, 85),
         (5337560220::bigint, 86)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 4717754) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 4717755);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (5395727291::bigint, 1),
         (5337560220::bigint, 2),
         (4690768631::bigint, 3),
         (11676373706::bigint, 4),
         (5337560218::bigint, 5),
         (11676373705::bigint, 6),
         (5395727298::bigint, 7),
         (5395727295::bigint, 8),
         (5354428124::bigint, 9),
         (11676373703::bigint, 10),
         (5372434724::bigint, 11),
         (11676373702::bigint, 12),
         (5372434722::bigint, 13),
         (5395727293::bigint, 14),
         (11676373701::bigint, 15),
         (11665004178::bigint, 16),
         (11665004177::bigint, 17),
         (11665004176::bigint, 18),
         (11676373708::bigint, 19),
         (5337560214::bigint, 20),
         (11665004190::bigint, 21),
         (4556866231::bigint, 22),
         (4592648165::bigint, 23),
         (11665004189::bigint, 24),
         (1220129198::bigint, 25),
         (11665004173::bigint, 26),
         (5354500975::bigint, 27),
         (5354500973::bigint, 28),
         (5340694070::bigint, 29),
         (11665004171::bigint, 30),
         (5340694067::bigint, 31),
         (5342771445::bigint, 32),
         (11665004170::bigint, 33),
         (5354500972::bigint, 34),
         (2374450976::bigint, 35),
         (11665004169::bigint, 36),
         (5354428126::bigint, 37),
         (5342771436::bigint, 38),
         (5354500956::bigint, 39),
         (5354500957::bigint, 40),
         (11664987768::bigint, 41),
         (5354500955::bigint, 42),
         (11700999650::bigint, 43),
         (11703735602::bigint, 44),
         (5354500953::bigint, 45),
         (5354500951::bigint, 46),
         (5354500949::bigint, 47),
         (5340694062::bigint, 48),
         (12146079714::bigint, 49),
         (5393038581::bigint, 50),
         (5340694064::bigint, 51),
         (5395727300::bigint, 52),
         (1589504388::bigint, 53),
         (5401078638::bigint, 54),
         (11586752350::bigint, 55),
         (10788568329::bigint, 56),
         (11586752349::bigint, 57),
         (11586752347::bigint, 58),
         (11586752348::bigint, 59),
         (11586752346::bigint, 60),
         (11664987766::bigint, 61),
         (11664987765::bigint, 62),
         (11742296361::bigint, 63),
         (11664987764::bigint, 64),
         (11734233717::bigint, 65),
         (2377499679::bigint, 66),
         (11676373696::bigint, 67),
         (11676373695::bigint, 68),
         (11734233713::bigint, 69),
         (11676373694::bigint, 70),
         (11672169202::bigint, 71),
         (11676373693::bigint, 72),
         (11676373692::bigint, 73),
         (11676373691::bigint, 74),
         (11672169206::bigint, 75),
         (11672169207::bigint, 76),
         (11672169208::bigint, 77),
         (11676373687::bigint, 78),
         (11676373686::bigint, 79),
         (11676373685::bigint, 80),
         (11676373684::bigint, 81),
         (11672169212::bigint, 82),
         (11676373683::bigint, 83),
         (11676373682::bigint, 84),
         (11672169214::bigint, 85),
         (11672169215::bigint, 86),
         (11676373681::bigint, 87),
         (11676373680::bigint, 88),
         (11676373679::bigint, 89)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 4717755) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 4764419);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (9948365768::bigint, 1),
         (11681428601::bigint, 2),
         (11681428600::bigint, 3),
         (11681428599::bigint, 4),
         (9017890943::bigint, 5),
         (11681428598::bigint, 6),
         (10096175373::bigint, 7),
         (11681428583::bigint, 8),
         (4558623651::bigint, 9),
         (2406297012::bigint, 10),
         (10002974639::bigint, 11),
         (9661999750::bigint, 12),
         (9015653273::bigint, 13),
         (11681428582::bigint, 14),
         (11693836924::bigint, 15),
         (10099186304::bigint, 16),
         (10126914527::bigint, 17),
         (10013893080::bigint, 18),
         (9622477371::bigint, 19),
         (11745381404::bigint, 20),
         (9428070121::bigint, 21),
         (2380076720::bigint, 22),
         (11750717866::bigint, 23),
         (11508368335::bigint, 24),
         (5389795618::bigint, 25),
         (11681428580::bigint, 26),
         (9641559167::bigint, 27),
         (10096123274::bigint, 28),
         (4116855112::bigint, 29),
         (10695768689::bigint, 30),
         (11681428579::bigint, 31),
         (5393038589::bigint, 32),
         (9588873700::bigint, 33),
         (5393038587::bigint, 34),
         (9923697695::bigint, 35),
         (9923702850::bigint, 36),
         (5393038585::bigint, 37),
         (10082219830::bigint, 38),
         (5294340532::bigint, 39),
         (12146079715::bigint, 40),
         (12146079714::bigint, 41),
         (1804502952::bigint, 42),
         (12155249141::bigint, 43),
         (12144077507::bigint, 44),
         (12261001799::bigint, 45),
         (5423025718::bigint, 46),
         (12261001798::bigint, 47),
         (11499855694::bigint, 48),
         (11681428578::bigint, 49),
         (2215342454::bigint, 50),
         (6154043773::bigint, 51),
         (5423025824::bigint, 52),
         (11703735601::bigint, 53),
         (2226214174::bigint, 54),
         (11703735600::bigint, 55),
         (11681428577::bigint, 56),
         (11681428576::bigint, 57),
         (5423025822::bigint, 58),
         (11703735599::bigint, 59),
         (11681428575::bigint, 60),
         (6154084691::bigint, 61),
         (11703735598::bigint, 62),
         (11700999657::bigint, 63),
         (2715020774::bigint, 64),
         (11681428574::bigint, 65),
         (11681428573::bigint, 66)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 4764419) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 4764420);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (10742437458::bigint, 1),
         (11690806169::bigint, 2),
         (11700999657::bigint, 3),
         (11690772568::bigint, 4),
         (11750237065::bigint, 5),
         (11700999656::bigint, 6),
         (11681428575::bigint, 7),
         (11700999655::bigint, 8),
         (11690772566::bigint, 9),
         (11700999654::bigint, 10),
         (11690772565::bigint, 11),
         (11700999653::bigint, 12),
         (11690772564::bigint, 13),
         (11700999652::bigint, 14),
         (11748231703::bigint, 15),
         (4917303821::bigint, 16),
         (11700999651::bigint, 17),
         (11502937469::bigint, 18),
         (11510859310::bigint, 19),
         (9574100730::bigint, 20),
         (11502929868::bigint, 21),
         (9574100733::bigint, 22),
         (12144077505::bigint, 23),
         (12112457212::bigint, 24),
         (12120184002::bigint, 25),
         (12146079715::bigint, 26),
         (10140159295::bigint, 27),
         (5349662692::bigint, 28),
         (11745843043::bigint, 29),
         (5337560205::bigint, 30),
         (9574158677::bigint, 31),
         (4116855114::bigint, 32),
         (11745843042::bigint, 33),
         (11745381403::bigint, 34),
         (10100951965::bigint, 35),
         (4116855112::bigint, 36),
         (5423025879::bigint, 37),
         (11745381402::bigint, 38),
         (11505958868::bigint, 39),
         (10100979100::bigint, 40),
         (11690772562::bigint, 41),
         (10100981309::bigint, 42),
         (10132364564::bigint, 43),
         (11505958856::bigint, 44),
         (9622477371::bigint, 45),
         (4595625753::bigint, 46),
         (11505958861::bigint, 47),
         (10101021829::bigint, 48),
         (10101022555::bigint, 49),
         (2497972844::bigint, 50),
         (10013893076::bigint, 51),
         (10101015843::bigint, 52),
         (10008701031::bigint, 53),
         (9622429848::bigint, 54),
         (10117294508::bigint, 55),
         (10117300751::bigint, 56),
         (11690772555::bigint, 57),
         (11750717858::bigint, 58),
         (11750717857::bigint, 59),
         (11750717856::bigint, 60),
         (11690772554::bigint, 61),
         (11690772553::bigint, 62),
         (11690772552::bigint, 63),
         (11690772550::bigint, 64),
         (9948365768::bigint, 65)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 4764420) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 4764421);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (3317564882::bigint, 1),
         (3317564876::bigint, 2),
         (11693836923::bigint, 3),
         (11681428601::bigint, 4),
         (11681428600::bigint, 5),
         (11693836927::bigint, 6),
         (11693836926::bigint, 7),
         (11693836922::bigint, 8),
         (11697291995::bigint, 9),
         (11693836925::bigint, 10),
         (11750717858::bigint, 11),
         (10096175373::bigint, 12),
         (11681428583::bigint, 13),
         (4558623651::bigint, 14),
         (2406297012::bigint, 15),
         (10002974639::bigint, 16),
         (9661999750::bigint, 17),
         (9015653273::bigint, 18),
         (11681428582::bigint, 19),
         (11693836924::bigint, 20),
         (10099186304::bigint, 21),
         (10126914527::bigint, 22),
         (10013893080::bigint, 23),
         (9622477371::bigint, 24),
         (11745381404::bigint, 25),
         (9428070121::bigint, 26),
         (2380076720::bigint, 27),
         (11750717866::bigint, 28),
         (11508368335::bigint, 29),
         (5389795618::bigint, 30),
         (11681428580::bigint, 31),
         (9641559167::bigint, 32),
         (10096123274::bigint, 33),
         (4116855112::bigint, 34),
         (10695768689::bigint, 35),
         (11681428579::bigint, 36),
         (5393038589::bigint, 37),
         (9588873700::bigint, 38),
         (5393038587::bigint, 39),
         (9923697695::bigint, 40),
         (9923702850::bigint, 41),
         (5393038585::bigint, 42),
         (10082219830::bigint, 43),
         (5294340532::bigint, 44),
         (12146079715::bigint, 45),
         (12146079714::bigint, 46),
         (1804502952::bigint, 47),
         (12155249141::bigint, 48),
         (12144077507::bigint, 49),
         (12261001799::bigint, 50),
         (5423025718::bigint, 51),
         (12261001798::bigint, 52),
         (11499855694::bigint, 53),
         (11681428578::bigint, 54),
         (2215342454::bigint, 55),
         (6154043773::bigint, 56),
         (5423025824::bigint, 57),
         (11703735601::bigint, 58),
         (2226214174::bigint, 59),
         (11703735600::bigint, 60),
         (11693836919::bigint, 61),
         (11693836918::bigint, 62),
         (11693836917::bigint, 63),
         (11693836916::bigint, 64),
         (11693836915::bigint, 65)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 4764421) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 4764422);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (11697291999::bigint, 1),
         (11693836916::bigint, 2),
         (11697291998::bigint, 3),
         (11697291997::bigint, 4),
         (11697291996::bigint, 5),
         (11700999653::bigint, 6),
         (11690772564::bigint, 7),
         (11700999652::bigint, 8),
         (11748231703::bigint, 9),
         (4917303821::bigint, 10),
         (11700999651::bigint, 11),
         (11502937469::bigint, 12),
         (11510859310::bigint, 13),
         (9574100730::bigint, 14),
         (11502929868::bigint, 15),
         (9574100733::bigint, 16),
         (12144077505::bigint, 17),
         (12112457212::bigint, 18),
         (12120184002::bigint, 19),
         (12146079715::bigint, 20),
         (10140159295::bigint, 21),
         (5349662692::bigint, 22),
         (11745843043::bigint, 23),
         (5337560205::bigint, 24),
         (9574158677::bigint, 25),
         (4116855114::bigint, 26),
         (11745843042::bigint, 27),
         (11745381403::bigint, 28),
         (10100951965::bigint, 29),
         (4116855112::bigint, 30),
         (5423025879::bigint, 31),
         (11745381402::bigint, 32),
         (11505958868::bigint, 33),
         (10100979100::bigint, 34),
         (11690772562::bigint, 35),
         (10100981309::bigint, 36),
         (10132364564::bigint, 37),
         (11505958856::bigint, 38),
         (9622477371::bigint, 39),
         (4595625753::bigint, 40),
         (11505958861::bigint, 41),
         (10101021829::bigint, 42),
         (10101022555::bigint, 43),
         (2497972844::bigint, 44),
         (10013893076::bigint, 45),
         (10101015843::bigint, 46),
         (10008701031::bigint, 47),
         (9622429848::bigint, 48),
         (10117294508::bigint, 49),
         (10117300751::bigint, 50),
         (11690772555::bigint, 51),
         (2984913221::bigint, 52),
         (11697291994::bigint, 53),
         (11697291993::bigint, 54),
         (11697291992::bigint, 55),
         (11681428599::bigint, 56),
         (3317564876::bigint, 57),
         (11693836929::bigint, 58)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 4764422) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 4764431);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (11499913960::bigint, 1),
         (11622193195::bigint, 2),
         (11572838471::bigint, 3),
         (11572838470::bigint, 4),
         (11568879566::bigint, 5),
         (11568879567::bigint, 6),
         (11580325127::bigint, 7),
         (11576284064::bigint, 8),
         (2680328524::bigint, 9),
         (11626627888::bigint, 10),
         (2680328508::bigint, 11),
         (11655881340::bigint, 12),
         (11652450384::bigint, 13),
         (11622193190::bigint, 14),
         (11652450385::bigint, 15),
         (10119893798::bigint, 16),
         (2398804688::bigint, 17),
         (2673402389::bigint, 18),
         (11645131359::bigint, 19),
         (2037047388::bigint, 20),
         (10608286601::bigint, 21),
         (11576335869::bigint, 22),
         (2037049616::bigint, 23),
         (11648852790::bigint, 24),
         (11499855682::bigint, 25),
         (11648852789::bigint, 26),
         (11648852788::bigint, 27),
         (11648852787::bigint, 28),
         (2037050563::bigint, 29),
         (11648852786::bigint, 30),
         (2037052871::bigint, 31),
         (5395727312::bigint, 32),
         (5395727310::bigint, 33),
         (5395727308::bigint, 34),
         (11748061225::bigint, 35),
         (5395727306::bigint, 36),
         (12151464205::bigint, 37),
         (5395727304::bigint, 38),
         (5395727302::bigint, 39),
         (12151464204::bigint, 40),
         (5395727300::bigint, 41),
         (5393825158::bigint, 42),
         (1804502952::bigint, 43),
         (12150561835::bigint, 44),
         (1804601348::bigint, 45),
         (5389795608::bigint, 46),
         (10788568331::bigint, 47),
         (11648852785::bigint, 48),
         (11648852784::bigint, 49),
         (11655881339::bigint, 50),
         (9693510645::bigint, 51),
         (11622193181::bigint, 52),
         (11622193180::bigint, 53),
         (11622193179::bigint, 54),
         (11724812660::bigint, 55),
         (11622193178::bigint, 56),
         (11626627906::bigint, 57),
         (11622193177::bigint, 58),
         (11626627907::bigint, 59),
         (11648852782::bigint, 60),
         (11622193176::bigint, 61),
         (11622193175::bigint, 62),
         (2396794433::bigint, 63),
         (11619110798::bigint, 64),
         (11594616790::bigint, 65),
         (11655881338::bigint, 66),
         (11655881337::bigint, 67),
         (11655881336::bigint, 68),
         (11655881335::bigint, 69),
         (11648852778::bigint, 70),
         (11648852777::bigint, 71),
         (11648852776::bigint, 72),
         (11594616806::bigint, 73),
         (11648852775::bigint, 74),
         (11591414374::bigint, 75)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 4764431) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 4764432);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (11591414374::bigint, 1),
         (11645192677::bigint, 2),
         (11645192676::bigint, 3),
         (11645192675::bigint, 4),
         (11652450394::bigint, 5),
         (11645192674::bigint, 6),
         (11652450393::bigint, 7),
         (11652450392::bigint, 8),
         (11648852773::bigint, 9),
         (11652450391::bigint, 10),
         (11668814580::bigint, 11),
         (11652450389::bigint, 12),
         (11750237026::bigint, 13),
         (2503475485::bigint, 14),
         (11750237025::bigint, 15),
         (11652450388::bigint, 16),
         (2398666781::bigint, 17),
         (11616172977::bigint, 18),
         (11640593142::bigint, 19),
         (11652450387::bigint, 20),
         (11640593140::bigint, 21),
         (11648852782::bigint, 22),
         (11626627907::bigint, 23),
         (11622193177::bigint, 24),
         (11640593139::bigint, 25),
         (11626627906::bigint, 26),
         (11622193178::bigint, 27),
         (11724812660::bigint, 28),
         (11626627905::bigint, 29),
         (11626627904::bigint, 30),
         (11626627903::bigint, 31),
         (11626627902::bigint, 32),
         (5426465582::bigint, 33),
         (9574100730::bigint, 34),
         (1605949296::bigint, 35),
         (11568883386::bigint, 36),
         (5401746653::bigint, 37),
         (12144077505::bigint, 38),
         (12112457212::bigint, 39),
         (12120184002::bigint, 40),
         (12146079715::bigint, 41),
         (12150561838::bigint, 42),
         (12150561837::bigint, 43),
         (1589504365::bigint, 44),
         (12150561836::bigint, 45),
         (12234899800::bigint, 46),
         (9650545925::bigint, 47),
         (11645131367::bigint, 48),
         (9571133083::bigint, 49),
         (11700999648::bigint, 50),
         (11645131365::bigint, 51),
         (2037050563::bigint, 52),
         (11645131363::bigint, 53),
         (11502929862::bigint, 54),
         (11750237049::bigint, 55),
         (11645131362::bigint, 56),
         (11502929861::bigint, 57),
         (11502929860::bigint, 58),
         (11652450386::bigint, 59),
         (2037049616::bigint, 60),
         (11576335869::bigint, 61),
         (10608286601::bigint, 62),
         (2037047388::bigint, 63),
         (11645131359::bigint, 64),
         (2673402389::bigint, 65),
         (2398804688::bigint, 66),
         (10119893798::bigint, 67),
         (11652450385::bigint, 68),
         (11622193190::bigint, 69),
         (11652450384::bigint, 70),
         (11655881340::bigint, 71),
         (2680328508::bigint, 72),
         (11626627888::bigint, 73),
         (2680328524::bigint, 74),
         (11576284064::bigint, 75),
         (11572838469::bigint, 76),
         (11568879567::bigint, 77),
         (11568879566::bigint, 78),
         (11572838470::bigint, 79),
         (11568879565::bigint, 80),
         (11568879564::bigint, 81),
         (11622193196::bigint, 82)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 4764432) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 4764433);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (11499913960::bigint, 1),
         (11622193195::bigint, 2),
         (11622193194::bigint, 3),
         (11622193193::bigint, 4),
         (11568879567::bigint, 5),
         (11580325127::bigint, 6),
         (11576284064::bigint, 7),
         (2680328524::bigint, 8),
         (11626627888::bigint, 9),
         (2680328508::bigint, 10),
         (11655881340::bigint, 11),
         (11652450384::bigint, 12),
         (11622193190::bigint, 13),
         (11652450385::bigint, 14),
         (10119893798::bigint, 15),
         (2398804688::bigint, 16),
         (2673402389::bigint, 17),
         (11645131359::bigint, 18),
         (2037047388::bigint, 19),
         (10608286601::bigint, 20),
         (11576335869::bigint, 21),
         (2037049616::bigint, 22),
         (11648852790::bigint, 23),
         (11499855682::bigint, 24),
         (11648852789::bigint, 25),
         (11648852788::bigint, 26),
         (11648852787::bigint, 27),
         (2037050563::bigint, 28),
         (11648852786::bigint, 29),
         (2037052871::bigint, 30),
         (5395727312::bigint, 31),
         (5395727310::bigint, 32),
         (5395727308::bigint, 33),
         (11748061225::bigint, 34),
         (5395727306::bigint, 35),
         (12151464205::bigint, 36),
         (5395727304::bigint, 37),
         (5395727302::bigint, 38),
         (12151464204::bigint, 39),
         (5395727300::bigint, 40),
         (5393825158::bigint, 41),
         (1804502952::bigint, 42),
         (12150561835::bigint, 43),
         (1804601348::bigint, 44),
         (5389795608::bigint, 45),
         (10788568331::bigint, 46),
         (11648852785::bigint, 47),
         (11648852784::bigint, 48),
         (11655881339::bigint, 49),
         (9693510645::bigint, 50),
         (6154043773::bigint, 51),
         (5423025824::bigint, 52),
         (11703735601::bigint, 53),
         (2226214174::bigint, 54),
         (11622193179::bigint, 55),
         (11724812660::bigint, 56),
         (11622193178::bigint, 57),
         (11626627906::bigint, 58),
         (11622193177::bigint, 59),
         (11626627907::bigint, 60),
         (11648852782::bigint, 61),
         (11640593140::bigint, 62),
         (11626627908::bigint, 63),
         (11629375276::bigint, 64),
         (11629375275::bigint, 65),
         (11664987748::bigint, 66),
         (11648852781::bigint, 67),
         (11648852780::bigint, 68),
         (11645131368::bigint, 69),
         (11648852779::bigint, 70),
         (11645192669::bigint, 71),
         (11645192670::bigint, 72),
         (11648852773::bigint, 73),
         (11648852778::bigint, 74),
         (11648852777::bigint, 75),
         (11648852776::bigint, 76),
         (11594616806::bigint, 77),
         (11648852775::bigint, 78),
         (11591414374::bigint, 79),
         (11648852774::bigint, 80),
         (11591414373::bigint, 81)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 4764433) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 4764434);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (11591414374::bigint, 1),
         (11645192677::bigint, 2),
         (11645192676::bigint, 3),
         (11645192675::bigint, 4),
         (11652450394::bigint, 5),
         (11645192674::bigint, 6),
         (11652450393::bigint, 7),
         (11645192673::bigint, 8),
         (11645192672::bigint, 9),
         (11645192671::bigint, 10),
         (11648852773::bigint, 11),
         (11645192670::bigint, 12),
         (11645192669::bigint, 13),
         (11648852779::bigint, 14),
         (2743540008::bigint, 15),
         (11645131368::bigint, 16),
         (11648852780::bigint, 17),
         (11645131358::bigint, 18),
         (11648852781::bigint, 19),
         (11750809205::bigint, 20),
         (2380406967::bigint, 21),
         (11626627909::bigint, 22),
         (11629375277::bigint, 23),
         (11648852782::bigint, 24),
         (11626627907::bigint, 25),
         (11622193177::bigint, 26),
         (11640593139::bigint, 27),
         (11626627906::bigint, 28),
         (11622193178::bigint, 29),
         (11724812660::bigint, 30),
         (11626627905::bigint, 31),
         (11626627904::bigint, 32),
         (11626627903::bigint, 33),
         (11626627902::bigint, 34),
         (5426465582::bigint, 35),
         (9574100730::bigint, 36),
         (1605949296::bigint, 37),
         (11568883386::bigint, 38),
         (5401746653::bigint, 39),
         (12144077505::bigint, 40),
         (12112457212::bigint, 41),
         (12120184002::bigint, 42),
         (12146079715::bigint, 43),
         (12150561838::bigint, 44),
         (12150561837::bigint, 45),
         (1589504365::bigint, 46),
         (12150561836::bigint, 47),
         (12234899800::bigint, 48),
         (9650545925::bigint, 49),
         (11645131367::bigint, 50),
         (9571133083::bigint, 51),
         (11700999648::bigint, 52),
         (11645131365::bigint, 53),
         (2037050563::bigint, 54),
         (11645131363::bigint, 55),
         (11502929862::bigint, 56),
         (11750237049::bigint, 57),
         (11645131362::bigint, 58),
         (11502929861::bigint, 59),
         (11502929860::bigint, 60),
         (11652450386::bigint, 61),
         (2037049616::bigint, 62),
         (11576335869::bigint, 63),
         (10608286601::bigint, 64),
         (2037047388::bigint, 65),
         (11645131359::bigint, 66),
         (2673402389::bigint, 67),
         (2398804688::bigint, 68),
         (10119893798::bigint, 69),
         (11652450385::bigint, 70),
         (11622193190::bigint, 71),
         (11652450384::bigint, 72),
         (11655881340::bigint, 73),
         (2680328508::bigint, 74),
         (11626627888::bigint, 75),
         (2680328524::bigint, 76),
         (11576284064::bigint, 77),
         (11572838469::bigint, 78),
         (11568879567::bigint, 79),
         (1217510893::bigint, 80),
         (11508368353::bigint, 81)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 4764434) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 7948963);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (11701006571::bigint, 1),
         (11701006570::bigint, 2),
         (11701006569::bigint, 3),
         (11700999668::bigint, 4),
         (11700999667::bigint, 5),
         (11703735585::bigint, 6),
         (11700999666::bigint, 7),
         (11700999665::bigint, 8),
         (11700999664::bigint, 9),
         (355039799::bigint, 10),
         (1224283140::bigint, 11),
         (11700999663::bigint, 12),
         (11750717859::bigint, 13),
         (11700999662::bigint, 14),
         (11700999661::bigint, 15),
         (11750809206::bigint, 16),
         (11700999660::bigint, 17),
         (11703735593::bigint, 18),
         (11700999659::bigint, 19),
         (11703735594::bigint, 20),
         (2724209578::bigint, 21),
         (10742437458::bigint, 22),
         (11690806169::bigint, 23),
         (11700999657::bigint, 24),
         (11690772568::bigint, 25),
         (11750237065::bigint, 26),
         (11700999656::bigint, 27),
         (11681428575::bigint, 28),
         (11700999655::bigint, 29),
         (11690772566::bigint, 30),
         (11700999654::bigint, 31),
         (11690772565::bigint, 32),
         (11700999653::bigint, 33),
         (11690772564::bigint, 34),
         (11700999652::bigint, 35),
         (11748231703::bigint, 36),
         (4917303821::bigint, 37),
         (11700999651::bigint, 38),
         (11502937469::bigint, 39),
         (11510859310::bigint, 40),
         (9574100730::bigint, 41),
         (11502929868::bigint, 42),
         (10925258013::bigint, 43),
         (9574100733::bigint, 44),
         (12144077505::bigint, 45),
         (12112457212::bigint, 46),
         (12120184002::bigint, 47),
         (12146079715::bigint, 48),
         (10140159295::bigint, 49),
         (5349662692::bigint, 50),
         (11745843043::bigint, 51),
         (5337560205::bigint, 52),
         (9574158677::bigint, 53),
         (9574158675::bigint, 54),
         (11664987768::bigint, 55),
         (5354500955::bigint, 56),
         (11700999650::bigint, 57),
         (11700999649::bigint, 58),
         (10140079710::bigint, 59),
         (9574158673::bigint, 60),
         (11700999648::bigint, 61),
         (10177204353::bigint, 62),
         (11700999647::bigint, 63),
         (9571133081::bigint, 64),
         (9581655136::bigint, 65),
         (3054594662::bigint, 66),
         (9574060025::bigint, 67),
         (11700999646::bigint, 68),
         (11700999645::bigint, 69),
         (10103521481::bigint, 70),
         (11703735607::bigint, 71),
         (11700999643::bigint, 72),
         (11700999642::bigint, 73),
         (11700999641::bigint, 74)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 7948963) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 7948964);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (11703735608::bigint, 1),
         (11700999643::bigint, 2),
         (11703735607::bigint, 3),
         (10103521481::bigint, 4),
         (10103584646::bigint, 5),
         (11703735604::bigint, 6),
         (9571133082::bigint, 7),
         (3481605614::bigint, 8),
         (9571133081::bigint, 9),
         (11700999647::bigint, 10),
         (10177204353::bigint, 11),
         (9571133083::bigint, 12),
         (9571133084::bigint, 13),
         (5395727308::bigint, 14),
         (11748061225::bigint, 15),
         (11703735602::bigint, 16),
         (5393038587::bigint, 17),
         (9923697695::bigint, 18),
         (9923702850::bigint, 19),
         (5393038585::bigint, 20),
         (1589504283::bigint, 21),
         (5294340532::bigint, 22),
         (12146079715::bigint, 23),
         (5340694062::bigint, 24),
         (12146079714::bigint, 25),
         (5395727300::bigint, 26),
         (1804502952::bigint, 27),
         (12155249141::bigint, 28),
         (12144077507::bigint, 29),
         (12261001799::bigint, 30),
         (5423025718::bigint, 31),
         (12261001798::bigint, 32),
         (11499855694::bigint, 33),
         (11681428578::bigint, 34),
         (2215342454::bigint, 35),
         (6154043773::bigint, 36),
         (5423025824::bigint, 37),
         (11703735601::bigint, 38),
         (2226214174::bigint, 39),
         (11703735600::bigint, 40),
         (11681428577::bigint, 41),
         (11681428576::bigint, 42),
         (5423025822::bigint, 43),
         (11703735599::bigint, 44),
         (11681428575::bigint, 45),
         (6154084691::bigint, 46),
         (11703735598::bigint, 47),
         (11703735597::bigint, 48),
         (11703735596::bigint, 49),
         (11703735595::bigint, 50),
         (11734233731::bigint, 51),
         (11703735594::bigint, 52),
         (11700999659::bigint, 53),
         (11703735593::bigint, 54),
         (11703735592::bigint, 55),
         (11703735591::bigint, 56),
         (11700999663::bigint, 57),
         (11703735589::bigint, 58),
         (11703735588::bigint, 59),
         (11749241736::bigint, 60),
         (11703735587::bigint, 61),
         (11703735586::bigint, 62),
         (11700999666::bigint, 63),
         (11703735585::bigint, 64),
         (11700999667::bigint, 65),
         (11703735584::bigint, 66),
         (11703735583::bigint, 67),
         (11703735582::bigint, 68),
         (11703735581::bigint, 69),
         (11703735580::bigint, 70),
         (11701006571::bigint, 71)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 7948964) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 7952025);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (11741246884::bigint, 1),
         (11742321769::bigint, 2),
         (11716558623::bigint, 3),
         (3134456377::bigint, 4),
         (11716558621::bigint, 5),
         (11742296368::bigint, 6),
         (11716558619::bigint, 7),
         (11716558618::bigint, 8),
         (11716558617::bigint, 9),
         (11724812648::bigint, 10),
         (11716558616::bigint, 11),
         (11716558615::bigint, 12),
         (11716558612::bigint, 13),
         (11716558611::bigint, 14),
         (11716558610::bigint, 15),
         (11645131358::bigint, 16),
         (11716558609::bigint, 17),
         (11716558608::bigint, 18),
         (11716558607::bigint, 19),
         (11716558606::bigint, 20),
         (9592889153::bigint, 21),
         (11716558605::bigint, 22),
         (11716558604::bigint, 23),
         (11716558603::bigint, 24),
         (11716558602::bigint, 25),
         (11716558601::bigint, 26),
         (11716558600::bigint, 27),
         (11716558599::bigint, 28),
         (10127025923::bigint, 29),
         (11655881339::bigint, 30),
         (11716558598::bigint, 31),
         (11716558597::bigint, 32),
         (4645954489::bigint, 33),
         (5401746653::bigint, 34),
         (12144077505::bigint, 35),
         (12112457212::bigint, 36),
         (12120184002::bigint, 37),
         (12146079715::bigint, 38),
         (12146079714::bigint, 39),
         (5393038581::bigint, 40),
         (5340694064::bigint, 41),
         (5395727300::bigint, 42),
         (1589504388::bigint, 43),
         (5401078638::bigint, 44),
         (11586752350::bigint, 45),
         (9610020118::bigint, 46),
         (11626627901::bigint, 47),
         (11626627900::bigint, 48),
         (9608017372::bigint, 49),
         (9592863285::bigint, 50),
         (3481605614::bigint, 51),
         (3077546540::bigint, 52),
         (3077546539::bigint, 53),
         (11626627897::bigint, 54),
         (11716558594::bigint, 55),
         (11750237049::bigint, 56),
         (11645131362::bigint, 57),
         (11502929861::bigint, 58),
         (11502929860::bigint, 59),
         (11652450386::bigint, 60),
         (2037049616::bigint, 61),
         (11576335869::bigint, 62),
         (10608286601::bigint, 63),
         (2037047388::bigint, 64),
         (11645131359::bigint, 65),
         (2673402389::bigint, 66),
         (2398804688::bigint, 67),
         (10119893798::bigint, 68),
         (11652450385::bigint, 69),
         (11622193190::bigint, 70),
         (11652450384::bigint, 71),
         (11655881340::bigint, 72),
         (2680328508::bigint, 73),
         (11626627888::bigint, 74),
         (2680328524::bigint, 75),
         (11576284064::bigint, 76),
         (11572838469::bigint, 77),
         (11568879567::bigint, 78),
         (1217510893::bigint, 79),
         (11716558593::bigint, 80),
         (11508368352::bigint, 81),
         (11563981252::bigint, 82),
         (11750809201::bigint, 83),
         (11563981251::bigint, 84)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 7952025) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 7952026);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (11724812666::bigint, 1),
         (4603393591::bigint, 2),
         (5432236583::bigint, 3),
         (10772099263::bigint, 4),
         (11505958849::bigint, 5),
         (11508368353::bigint, 6),
         (11622193193::bigint, 7),
         (11568879567::bigint, 8),
         (11580325127::bigint, 9),
         (11576284064::bigint, 10),
         (2680328524::bigint, 11),
         (11626627888::bigint, 12),
         (2680328508::bigint, 13),
         (11655881340::bigint, 14),
         (11652450384::bigint, 15),
         (11622193190::bigint, 16),
         (11652450385::bigint, 17),
         (10119893798::bigint, 18),
         (2398804688::bigint, 19),
         (2673402389::bigint, 20),
         (11645131359::bigint, 21),
         (2037047388::bigint, 22),
         (10608286601::bigint, 23),
         (11576335869::bigint, 24),
         (2037049616::bigint, 25),
         (11648852790::bigint, 26),
         (11499855682::bigint, 27),
         (11648852789::bigint, 28),
         (11648852788::bigint, 29),
         (11750237048::bigint, 30),
         (3054594660::bigint, 31),
         (3054594661::bigint, 32),
         (11499855690::bigint, 33),
         (3054594662::bigint, 34),
         (11499855691::bigint, 35),
         (3054594663::bigint, 36),
         (3054594664::bigint, 37),
         (3054594665::bigint, 38),
         (11622193184::bigint, 39),
         (9654655365::bigint, 40),
         (11622193183::bigint, 41),
         (11499855693::bigint, 42),
         (10788568329::bigint, 43),
         (11750237012::bigint, 44),
         (10788568330::bigint, 45),
         (10055961687::bigint, 46),
         (1804502956::bigint, 47),
         (1804502955::bigint, 48),
         (10788479384::bigint, 49),
         (5393825158::bigint, 50),
         (1804502952::bigint, 51),
         (12155249141::bigint, 52),
         (12144077507::bigint, 53),
         (12261001799::bigint, 54),
         (10788568332::bigint, 55),
         (5423025718::bigint, 56),
         (12261001798::bigint, 57),
         (1804601348::bigint, 58),
         (5389795608::bigint, 59),
         (10788568331::bigint, 60),
         (11648852785::bigint, 61),
         (11648852784::bigint, 62),
         (11655881339::bigint, 63),
         (11716558598::bigint, 64),
         (2215342454::bigint, 65),
         (6154043773::bigint, 66),
         (5423025824::bigint, 67),
         (11703735601::bigint, 68),
         (2226214174::bigint, 69),
         (11622193179::bigint, 70),
         (11724812660::bigint, 71),
         (11622193178::bigint, 72),
         (11626627906::bigint, 73),
         (11724812659::bigint, 74),
         (11724812658::bigint, 75),
         (9592889151::bigint, 76),
         (11724812657::bigint, 77),
         (11724812656::bigint, 78),
         (11724812655::bigint, 79),
         (11716558608::bigint, 80),
         (11724812654::bigint, 81),
         (11724812653::bigint, 82),
         (11724812652::bigint, 83),
         (11724812651::bigint, 84),
         (11724812650::bigint, 85),
         (11716558615::bigint, 86),
         (11716558616::bigint, 87),
         (11724812648::bigint, 88),
         (11716558617::bigint, 89),
         (11741246877::bigint, 90),
         (11724812647::bigint, 91),
         (11724812646::bigint, 92),
         (11724812645::bigint, 93),
         (11724812644::bigint, 94),
         (11724812643::bigint, 95),
         (11724812642::bigint, 96),
         (11745080343::bigint, 97),
         (11724812641::bigint, 98)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 7952026) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 7962485);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (11734233753::bigint, 1),
         (11734233752::bigint, 2),
         (11749241743::bigint, 3),
         (11734233751::bigint, 4),
         (11731162773::bigint, 5),
         (11734233750::bigint, 6),
         (11731162774::bigint, 7),
         (11734233749::bigint, 8),
         (11731162779::bigint, 9),
         (11734233748::bigint, 10),
         (11734233747::bigint, 11),
         (11734233746::bigint, 12),
         (11734233745::bigint, 13),
         (11734233744::bigint, 14),
         (11734233743::bigint, 15),
         (11734233742::bigint, 16),
         (11734233741::bigint, 17),
         (3312911975::bigint, 18),
         (1226685444::bigint, 19),
         (11734233739::bigint, 20),
         (11734233738::bigint, 21),
         (11734233712::bigint, 22),
         (11748727241::bigint, 23),
         (11731162788::bigint, 24),
         (11734233736::bigint, 25),
         (11734233735::bigint, 26),
         (11734233734::bigint, 27),
         (11734233733::bigint, 28),
         (11734233732::bigint, 29),
         (11734233731::bigint, 30),
         (11681428573::bigint, 31),
         (10742437458::bigint, 32),
         (11690806169::bigint, 33),
         (11700999657::bigint, 34),
         (11690772568::bigint, 35),
         (11750237065::bigint, 36),
         (11700999656::bigint, 37),
         (11681428575::bigint, 38),
         (11700999655::bigint, 39),
         (11690772566::bigint, 40),
         (11700999654::bigint, 41),
         (11690772565::bigint, 42),
         (11700999653::bigint, 43),
         (11690772564::bigint, 44),
         (11700999652::bigint, 45),
         (11748231703::bigint, 46),
         (4917303821::bigint, 47),
         (11700999651::bigint, 48),
         (11502937469::bigint, 49),
         (11510859310::bigint, 50),
         (9574100730::bigint, 51),
         (11502929868::bigint, 52),
         (9574100733::bigint, 53),
         (12144077505::bigint, 54),
         (12112457212::bigint, 55),
         (5349662693::bigint, 56),
         (10140159295::bigint, 57),
         (1589504283::bigint, 58),
         (5354500949::bigint, 59),
         (10082219830::bigint, 60),
         (12144077502::bigint, 61),
         (11734233729::bigint, 62),
         (11734233728::bigint, 63),
         (9630447877::bigint, 64),
         (11734233727::bigint, 65),
         (11502929867::bigint, 66),
         (9635248369::bigint, 67),
         (11748061239::bigint, 68),
         (11734233725::bigint, 69),
         (9598435807::bigint, 70),
         (11734233723::bigint, 71),
         (11342019228::bigint, 72),
         (11568883379::bigint, 73),
         (11568883378::bigint, 74),
         (11568883377::bigint, 75),
         (11568883376::bigint, 76),
         (11750809203::bigint, 77),
         (11734233721::bigint, 78),
         (11586752341::bigint, 79),
         (11734233720::bigint, 80),
         (2383938357::bigint, 81),
         (11734233719::bigint, 82),
         (11734233718::bigint, 83),
         (11734233716::bigint, 84),
         (11734233717::bigint, 85),
         (2377499679::bigint, 86),
         (11676373696::bigint, 87),
         (11676373695::bigint, 88),
         (11734233713::bigint, 89),
         (11676373694::bigint, 90)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 7962485) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 7962486);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (11731162803::bigint, 1),
         (11731162802::bigint, 2),
         (11731162801::bigint, 3),
         (11676373696::bigint, 4),
         (11668801268::bigint, 5),
         (11668801267::bigint, 6),
         (2377596077::bigint, 7),
         (11672169200::bigint, 8),
         (11668801266::bigint, 9),
         (11590192518::bigint, 10),
         (11590192517::bigint, 11),
         (11590192516::bigint, 12),
         (11590192515::bigint, 13),
         (11750237012::bigint, 14),
         (10788568330::bigint, 15),
         (10055961687::bigint, 16),
         (1804502956::bigint, 17),
         (1804502955::bigint, 18),
         (5393825158::bigint, 19),
         (1804502952::bigint, 20),
         (12155249141::bigint, 21),
         (12144077507::bigint, 22),
         (12261001799::bigint, 23),
         (5423025718::bigint, 24),
         (12261001798::bigint, 25),
         (11499855694::bigint, 26),
         (11681428578::bigint, 27),
         (2215342454::bigint, 28),
         (6154043773::bigint, 29),
         (5423025824::bigint, 30),
         (11703735601::bigint, 31),
         (2226214174::bigint, 32),
         (11703735600::bigint, 33),
         (11681428577::bigint, 34),
         (11681428576::bigint, 35),
         (5423025822::bigint, 36),
         (11703735599::bigint, 37),
         (11681428575::bigint, 38),
         (6154084691::bigint, 39),
         (11703735598::bigint, 40),
         (11703735597::bigint, 41),
         (11703735596::bigint, 42),
         (11703735595::bigint, 43),
         (11734233731::bigint, 44),
         (11703735594::bigint, 45),
         (11700999659::bigint, 46),
         (11703735593::bigint, 47),
         (11703735592::bigint, 48),
         (11749241739::bigint, 49),
         (11745080353::bigint, 50),
         (11745080352::bigint, 51),
         (11731162791::bigint, 52),
         (11745080351::bigint, 53),
         (11742296365::bigint, 54),
         (11745080350::bigint, 55),
         (11742296366::bigint, 56),
         (11745080349::bigint, 57),
         (11745080348::bigint, 58),
         (11742296367::bigint, 59),
         (11745080347::bigint, 60),
         (11745080346::bigint, 61),
         (11745080345::bigint, 62),
         (11748727235::bigint, 63),
         (11745080344::bigint, 64),
         (11748727240::bigint, 65),
         (11748727236::bigint, 66),
         (11745080343::bigint, 67),
         (11724812641::bigint, 68)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 7962486) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 7964199);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (12120184002::bigint, 1),
         (12146079715::bigint, 2),
         (10140159295::bigint, 3),
         (5349662692::bigint, 4),
         (11745843043::bigint, 5),
         (5337560205::bigint, 6),
         (9574158677::bigint, 7),
         (4116855114::bigint, 8),
         (11745843042::bigint, 9),
         (11745381403::bigint, 10),
         (10100951965::bigint, 11),
         (4116855112::bigint, 12),
         (5423025879::bigint, 13),
         (11745381402::bigint, 14),
         (11505958868::bigint, 15),
         (10100979100::bigint, 16),
         (11690772562::bigint, 17),
         (10100981309::bigint, 18),
         (10132364564::bigint, 19),
         (11505958856::bigint, 20),
         (9622477371::bigint, 21),
         (5377854736::bigint, 22),
         (4595625753::bigint, 23),
         (11505958861::bigint, 24),
         (11745843041::bigint, 25),
         (11745843040::bigint, 26),
         (11745843039::bigint, 27),
         (11745843038::bigint, 28),
         (11748231702::bigint, 29),
         (11745843036::bigint, 30),
         (5393038591::bigint, 31),
         (11745843035::bigint, 32),
         (11745843034::bigint, 33),
         (11745843033::bigint, 34),
         (11745843055::bigint, 35),
         (11745843032::bigint, 36),
         (11745843056::bigint, 37),
         (11745843031::bigint, 38),
         (11745843067::bigint, 39),
         (11745843030::bigint, 40),
         (11745843169::bigint, 41),
         (11745843029::bigint, 42),
         (5393038595::bigint, 43),
         (11748231699::bigint, 44),
         (5423025881::bigint, 45),
         (11745843027::bigint, 46),
         (11745843172::bigint, 47),
         (11745843026::bigint, 48),
         (11745843025::bigint, 49),
         (5423025888::bigint, 50),
         (11745843023::bigint, 51),
         (11745843022::bigint, 52),
         (11745843019::bigint, 53),
         (11745843018::bigint, 54),
         (11745843017::bigint, 55),
         (11745843182::bigint, 56),
         (11663408372::bigint, 57),
         (11745843016::bigint, 58),
         (11745843015::bigint, 59),
         (11745843014::bigint, 60),
         (11745843185::bigint, 61),
         (11745843013::bigint, 62),
         (11745843187::bigint, 63),
         (11745843012::bigint, 64),
         (11745843011::bigint, 65),
         (11745843044::bigint, 66),
         (11745843010::bigint, 67),
         (11745843189::bigint, 68),
         (11745843009::bigint, 69),
         (11745843007::bigint, 70),
         (11745843192::bigint, 71)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 7964199) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 7986997);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (10837232580::bigint, 1),
         (11748061249::bigint, 2),
         (11748061248::bigint, 3),
         (11748727257::bigint, 4),
         (11748061247::bigint, 5),
         (11750237066::bigint, 6),
         (11748061246::bigint, 7),
         (11748727256::bigint, 8),
         (11748061221::bigint, 9),
         (11750717861::bigint, 10),
         (11748727255::bigint, 11),
         (11749241729::bigint, 12),
         (11750809207::bigint, 13),
         (11748061243::bigint, 14),
         (11748061242::bigint, 15),
         (11750717860::bigint, 16),
         (11748061241::bigint, 17),
         (355039799::bigint, 18),
         (1224283140::bigint, 19),
         (11700999663::bigint, 20),
         (11750717859::bigint, 21),
         (11700999662::bigint, 22),
         (11700999661::bigint, 23),
         (11750809206::bigint, 24),
         (11700999660::bigint, 25),
         (11703735593::bigint, 26),
         (11700999659::bigint, 27),
         (11703735594::bigint, 28),
         (2724209578::bigint, 29),
         (10742437458::bigint, 30),
         (11690806169::bigint, 31),
         (11700999657::bigint, 32),
         (11690772568::bigint, 33),
         (11750237065::bigint, 34),
         (11700999656::bigint, 35),
         (11681428575::bigint, 36),
         (11700999655::bigint, 37),
         (11690772566::bigint, 38),
         (11700999654::bigint, 39),
         (11690772565::bigint, 40),
         (11700999653::bigint, 41),
         (11690772564::bigint, 42),
         (11700999652::bigint, 43),
         (11748231703::bigint, 44),
         (4917303821::bigint, 45),
         (11700999651::bigint, 46),
         (11502937469::bigint, 47),
         (11510859310::bigint, 48),
         (9574100730::bigint, 49),
         (11502929868::bigint, 50),
         (9574100733::bigint, 51),
         (12144077505::bigint, 52),
         (12112457212::bigint, 53),
         (12120184002::bigint, 54),
         (12146079715::bigint, 55),
         (12150561838::bigint, 56),
         (12150561837::bigint, 57),
         (1589504365::bigint, 58),
         (12150561836::bigint, 59),
         (12234899800::bigint, 60),
         (9650545925::bigint, 61),
         (11645131367::bigint, 62),
         (11748061239::bigint, 63),
         (11734233725::bigint, 64),
         (9598435807::bigint, 65),
         (11734233723::bigint, 66),
         (11342019228::bigint, 67),
         (11568883379::bigint, 68),
         (11748061238::bigint, 69),
         (11748061237::bigint, 70),
         (11748061236::bigint, 71),
         (11748061230::bigint, 72),
         (11568883374::bigint, 73),
         (11572819661::bigint, 74),
         (11750809202::bigint, 75),
         (11748061232::bigint, 76),
         (11586752339::bigint, 77),
         (11748061233::bigint, 78),
         (11748061234::bigint, 79),
         (11502929851::bigint, 80),
         (5873323260::bigint, 81)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 7986997) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 7986998);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (5873323260::bigint, 1),
         (11750809192::bigint, 2),
         (11586752338::bigint, 3),
         (11748061233::bigint, 4),
         (11586752339::bigint, 5),
         (11748061232::bigint, 6),
         (11750809202::bigint, 7),
         (11568883375::bigint, 8),
         (11568883374::bigint, 9),
         (11748061230::bigint, 10),
         (11748061236::bigint, 11),
         (11748061229::bigint, 12),
         (11748061227::bigint, 13),
         (12151464203::bigint, 14),
         (11741845582::bigint, 15),
         (12150561833::bigint, 16),
         (11572819657::bigint, 17),
         (2350127607::bigint, 18),
         (5384964512::bigint, 19),
         (9635248369::bigint, 20),
         (11748061225::bigint, 21),
         (5395727306::bigint, 22),
         (12151464205::bigint, 23),
         (5395727304::bigint, 24),
         (5395727302::bigint, 25),
         (12151464204::bigint, 26),
         (5395727300::bigint, 27),
         (5377854740::bigint, 28),
         (5393825158::bigint, 29),
         (1804502952::bigint, 30),
         (12155249141::bigint, 31),
         (12144077507::bigint, 32),
         (12261001799::bigint, 33),
         (5423025718::bigint, 34),
         (12261001798::bigint, 35),
         (11499855694::bigint, 36),
         (11681428578::bigint, 37),
         (2215342454::bigint, 38),
         (6154043773::bigint, 39),
         (5423025824::bigint, 40),
         (11703735601::bigint, 41),
         (2226214174::bigint, 42),
         (11703735600::bigint, 43),
         (11681428577::bigint, 44),
         (11681428576::bigint, 45),
         (5423025822::bigint, 46),
         (11703735599::bigint, 47),
         (11681428575::bigint, 48),
         (6154084691::bigint, 49),
         (11703735598::bigint, 50),
         (11703735597::bigint, 51),
         (11703735596::bigint, 52),
         (11703735595::bigint, 53),
         (11734233731::bigint, 54),
         (11703735594::bigint, 55),
         (11700999659::bigint, 56),
         (11703735593::bigint, 57),
         (11703735592::bigint, 58),
         (11703735591::bigint, 59),
         (11700999663::bigint, 60),
         (11703735589::bigint, 61),
         (11748061224::bigint, 62),
         (11750717865::bigint, 63),
         (11748061223::bigint, 64),
         (11750809186::bigint, 65),
         (11750809185::bigint, 66),
         (11749262544::bigint, 67),
         (11750717864::bigint, 68),
         (11748061221::bigint, 69),
         (11748061220::bigint, 70),
         (11748061219::bigint, 71),
         (11748061218::bigint, 72),
         (3238657397::bigint, 73),
         (11749241726::bigint, 74),
         (11749241727::bigint, 75),
         (10837232580::bigint, 76)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 7986998) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 7993008);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (11748231683::bigint, 1),
         (11748231682::bigint, 2),
         (11748231693::bigint, 3),
         (11748231681::bigint, 4),
         (11748231694::bigint, 5),
         (11748231680::bigint, 6),
         (11745843067::bigint, 7),
         (11745843030::bigint, 8),
         (11745843169::bigint, 9),
         (11745843029::bigint, 10),
         (5393038595::bigint, 11),
         (11748231699::bigint, 12),
         (5423025881::bigint, 13),
         (11748231698::bigint, 14),
         (11748231697::bigint, 15),
         (11748231696::bigint, 16),
         (9632222794::bigint, 17),
         (5423025887::bigint, 18),
         (11745843170::bigint, 19),
         (11748231675::bigint, 20),
         (11748231674::bigint, 21),
         (2886285981::bigint, 22),
         (5393038591::bigint, 23),
         (11748231673::bigint, 24),
         (11745843048::bigint, 25),
         (11745843047::bigint, 26),
         (11745843039::bigint, 27),
         (11745843046::bigint, 28),
         (10126914527::bigint, 29),
         (5377854736::bigint, 30),
         (10013893080::bigint, 31),
         (9622477371::bigint, 32),
         (11745381404::bigint, 33),
         (9428070121::bigint, 34),
         (2380076720::bigint, 35),
         (11750717866::bigint, 36),
         (11508368335::bigint, 37),
         (5389795618::bigint, 38),
         (11681428580::bigint, 39),
         (9641559167::bigint, 40),
         (10096123274::bigint, 41),
         (4116855112::bigint, 42),
         (10695768689::bigint, 43),
         (11681428579::bigint, 44),
         (5393038589::bigint, 45),
         (9588873700::bigint, 46),
         (5393038587::bigint, 47),
         (9923697695::bigint, 48),
         (9923702850::bigint, 49),
         (5393038585::bigint, 50),
         (5294340532::bigint, 51),
         (12146079715::bigint, 52),
         (12146079714::bigint, 53),
         (1804502952::bigint, 54),
         (12155249141::bigint, 55),
         (12144077507::bigint, 56),
         (12261001799::bigint, 57),
         (5423025718::bigint, 58),
         (12261001798::bigint, 59),
         (11499855694::bigint, 60),
         (11681428578::bigint, 61),
         (2215342454::bigint, 62),
         (6154043773::bigint, 63),
         (5423025824::bigint, 64),
         (11703735601::bigint, 65),
         (2226214174::bigint, 66),
         (11703735600::bigint, 67),
         (11681428577::bigint, 68),
         (11681428576::bigint, 69),
         (5423025822::bigint, 70),
         (11748231670::bigint, 71),
         (3052515445::bigint, 72),
         (11748231669::bigint, 73),
         (3052483925::bigint, 74),
         (11748231706::bigint, 75),
         (2385653920::bigint, 76),
         (11748231707::bigint, 77),
         (11748190368::bigint, 78),
         (2711345361::bigint, 79),
         (11748190367::bigint, 80),
         (2711549005::bigint, 81),
         (11748231718::bigint, 82),
         (11748190365::bigint, 83),
         (11748190364::bigint, 84)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 7993008) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 7997876);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (12120184002::bigint, 1),
         (12146079715::bigint, 2),
         (10140159295::bigint, 3),
         (5349662692::bigint, 4),
         (11745843043::bigint, 5),
         (5337560205::bigint, 6),
         (9574158677::bigint, 7),
         (4116855114::bigint, 8),
         (11745843042::bigint, 9),
         (11745381403::bigint, 10),
         (10100951965::bigint, 11),
         (4116855112::bigint, 12),
         (5423025879::bigint, 13),
         (11745381402::bigint, 14),
         (11505958868::bigint, 15),
         (10100979100::bigint, 16),
         (11690772562::bigint, 17),
         (10100981309::bigint, 18),
         (10132364564::bigint, 19),
         (11505958856::bigint, 20),
         (9622477371::bigint, 21),
         (4595625753::bigint, 22),
         (11505958861::bigint, 23),
         (10126914527::bigint, 24),
         (5377854736::bigint, 25),
         (11505958855::bigint, 26),
         (11745381405::bigint, 27),
         (11745381400::bigint, 28),
         (11750237010::bigint, 29),
         (11745381399::bigint, 30),
         (11750237009::bigint, 31),
         (11745381398::bigint, 32),
         (11750237008::bigint, 33),
         (11745381397::bigint, 34),
         (11745381396::bigint, 35),
         (11745381395::bigint, 36),
         (11745381411::bigint, 37),
         (11745381394::bigint, 38),
         (2900059988::bigint, 39),
         (11745381392::bigint, 40),
         (11750237006::bigint, 41),
         (11745381391::bigint, 42),
         (11745381390::bigint, 43),
         (11745381417::bigint, 44),
         (11745381389::bigint, 45),
         (11745843014::bigint, 46),
         (11745381419::bigint, 47),
         (11745381420::bigint, 48),
         (11745381421::bigint, 49),
         (11745381422::bigint, 50),
         (11745381388::bigint, 51),
         (11750237005::bigint, 52),
         (11745381387::bigint, 53),
         (11750237004::bigint, 54),
         (11745381386::bigint, 55),
         (11745381385::bigint, 56),
         (11750237003::bigint, 57),
         (11745381384::bigint, 58),
         (11750237002::bigint, 59),
         (11745381383::bigint, 60),
         (11745381382::bigint, 61),
         (11750237059::bigint, 62),
         (11745381435::bigint, 63)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 7997876) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 7997877);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (11748231720::bigint, 1),
         (11748231719::bigint, 2),
         (11748231718::bigint, 3),
         (2711549005::bigint, 4),
         (11748231717::bigint, 5),
         (2732813674::bigint, 6),
         (2732813693::bigint, 7),
         (11690806214::bigint, 8),
         (2711345361::bigint, 9),
         (11748231715::bigint, 10),
         (11748231707::bigint, 11),
         (2385653920::bigint, 12),
         (11748231706::bigint, 13),
         (11748231705::bigint, 14),
         (11748231704::bigint, 15),
         (11700999654::bigint, 16),
         (11690772565::bigint, 17),
         (11700999653::bigint, 18),
         (11690772564::bigint, 19),
         (11700999652::bigint, 20),
         (11748231703::bigint, 21),
         (4917303821::bigint, 22),
         (11700999651::bigint, 23),
         (11502937469::bigint, 24),
         (11510859310::bigint, 25),
         (9574100730::bigint, 26),
         (11502929868::bigint, 27),
         (9574100733::bigint, 28),
         (12144077505::bigint, 29),
         (12112457212::bigint, 30),
         (12120184002::bigint, 31),
         (12146079715::bigint, 32),
         (10140159295::bigint, 33),
         (5349662692::bigint, 34),
         (11745843043::bigint, 35),
         (5337560205::bigint, 36),
         (9574158677::bigint, 37),
         (4116855114::bigint, 38),
         (11745843042::bigint, 39),
         (11745381403::bigint, 40),
         (10100951965::bigint, 41),
         (4116855112::bigint, 42),
         (5423025879::bigint, 43),
         (11745381402::bigint, 44),
         (11505958868::bigint, 45),
         (10100979100::bigint, 46),
         (11690772562::bigint, 47),
         (10100981309::bigint, 48),
         (10132364564::bigint, 49),
         (11505958856::bigint, 50),
         (9622477371::bigint, 51),
         (4595625753::bigint, 52),
         (11505958861::bigint, 53),
         (11745843041::bigint, 54),
         (11745843040::bigint, 55),
         (11745843039::bigint, 56),
         (11745843038::bigint, 57),
         (11748231702::bigint, 58),
         (11745843036::bigint, 59),
         (11748231701::bigint, 60),
         (11748231700::bigint, 61),
         (11748231699::bigint, 62),
         (5423025881::bigint, 63),
         (11748231698::bigint, 64),
         (11748231697::bigint, 65),
         (11748231696::bigint, 66),
         (9632222794::bigint, 67),
         (5423025887::bigint, 68),
         (11745843170::bigint, 69),
         (5393038595::bigint, 70),
         (11745843029::bigint, 71),
         (11745843169::bigint, 72),
         (11745843068::bigint, 73),
         (11745843067::bigint, 74),
         (11748231695::bigint, 75),
         (11748231694::bigint, 76),
         (11745381414::bigint, 77),
         (11748231693::bigint, 78),
         (11748231682::bigint, 79),
         (11748231683::bigint, 80)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 7997877) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 8004650);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (11731162803::bigint, 1),
         (11731162802::bigint, 2),
         (11731162801::bigint, 3),
         (11676373696::bigint, 4),
         (11668801268::bigint, 5),
         (11750809190::bigint, 6),
         (11731162799::bigint, 7),
         (11731162798::bigint, 8),
         (2383938357::bigint, 9),
         (11734233720::bigint, 10),
         (11590192524::bigint, 11),
         (11590192523::bigint, 12),
         (11590192522::bigint, 13),
         (1203082810::bigint, 14),
         (11741845584::bigint, 15),
         (11590192521::bigint, 16),
         (11741845583::bigint, 17),
         (11741845582::bigint, 18),
         (12150561833::bigint, 19),
         (11572819657::bigint, 20),
         (2350127607::bigint, 21),
         (5384964512::bigint, 22),
         (9635248369::bigint, 23),
         (11731162796::bigint, 24),
         (1541569015::bigint, 25),
         (9650545925::bigint, 26),
         (12151464205::bigint, 27),
         (5395727304::bigint, 28),
         (5395727302::bigint, 29),
         (12151464204::bigint, 30),
         (5395727300::bigint, 31),
         (5393825158::bigint, 32),
         (1804502952::bigint, 33),
         (12155249141::bigint, 34),
         (12144077507::bigint, 35),
         (12261001799::bigint, 36),
         (5423025718::bigint, 37),
         (12261001798::bigint, 38),
         (11499855694::bigint, 39),
         (11681428578::bigint, 40),
         (2215342454::bigint, 41),
         (6154043773::bigint, 42),
         (5423025824::bigint, 43),
         (11703735601::bigint, 44),
         (2226214174::bigint, 45),
         (11703735600::bigint, 46),
         (11681428577::bigint, 47),
         (11681428576::bigint, 48),
         (5423025822::bigint, 49),
         (11703735599::bigint, 50),
         (11681428575::bigint, 51),
         (6154084691::bigint, 52),
         (11703735598::bigint, 53),
         (11703735597::bigint, 54),
         (11703735596::bigint, 55),
         (11703735595::bigint, 56),
         (11741845581::bigint, 57),
         (11741845580::bigint, 58),
         (11741845579::bigint, 59),
         (11741845578::bigint, 60),
         (11741246877::bigint, 61),
         (11724812647::bigint, 62),
         (11724812646::bigint, 63),
         (11724812645::bigint, 64),
         (11724812644::bigint, 65),
         (11724812643::bigint, 66),
         (11724812642::bigint, 67),
         (11745080343::bigint, 68),
         (11724812641::bigint, 69),
         (11741845576::bigint, 70),
         (11741845575::bigint, 71),
         (11741845574::bigint, 72),
         (11741246889::bigint, 73),
         (11741845573::bigint, 74),
         (11741845572::bigint, 75),
         (11741845571::bigint, 76),
         (11741246892::bigint, 77),
         (11741845569::bigint, 78),
         (11594616809::bigint, 79)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 8004650) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 8004651);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (11731162803::bigint, 1),
         (11731162802::bigint, 2),
         (11731162801::bigint, 3),
         (11676373696::bigint, 4),
         (11668801268::bigint, 5),
         (11750809190::bigint, 6),
         (11731162799::bigint, 7),
         (11731162798::bigint, 8),
         (2383938357::bigint, 9),
         (11734233720::bigint, 10),
         (11586752341::bigint, 11),
         (11734233721::bigint, 12),
         (11750809203::bigint, 13),
         (11731162797::bigint, 14),
         (11572819660::bigint, 15),
         (11572819659::bigint, 16),
         (11572819658::bigint, 17),
         (11741845582::bigint, 18),
         (12150561833::bigint, 19),
         (11572819657::bigint, 20),
         (2350127607::bigint, 21),
         (5384964512::bigint, 22),
         (9635248369::bigint, 23),
         (11731162796::bigint, 24),
         (1541569015::bigint, 25),
         (9650545925::bigint, 26),
         (12151464205::bigint, 27),
         (5395727304::bigint, 28),
         (5395727302::bigint, 29),
         (12151464204::bigint, 30),
         (5395727300::bigint, 31),
         (5393825158::bigint, 32),
         (1804502952::bigint, 33),
         (12155249141::bigint, 34),
         (12144077507::bigint, 35),
         (12261001799::bigint, 36),
         (5423025718::bigint, 37),
         (12261001798::bigint, 38),
         (11499855694::bigint, 39),
         (11681428578::bigint, 40),
         (2215342454::bigint, 41),
         (6154043773::bigint, 42),
         (5423025824::bigint, 43),
         (11703735601::bigint, 44),
         (2226214174::bigint, 45),
         (11703735600::bigint, 46),
         (11681428577::bigint, 47),
         (11681428576::bigint, 48),
         (5423025822::bigint, 49),
         (11703735599::bigint, 50),
         (11681428575::bigint, 51),
         (6154084691::bigint, 52),
         (11703735598::bigint, 53),
         (11703735597::bigint, 54),
         (11703735596::bigint, 55),
         (11703735595::bigint, 56),
         (11731162794::bigint, 57),
         (11731162793::bigint, 58),
         (11731162792::bigint, 59),
         (11731162791::bigint, 60),
         (11734233733::bigint, 61),
         (11734233732::bigint, 62),
         (11742296360::bigint, 63),
         (11731162790::bigint, 64),
         (11731162789::bigint, 65),
         (11734233737::bigint, 66),
         (5443961811::bigint, 67),
         (11731162787::bigint, 68),
         (11731162786::bigint, 69),
         (10281373203::bigint, 70),
         (3312911975::bigint, 71),
         (11731162785::bigint, 72),
         (11731162771::bigint, 73),
         (11731162784::bigint, 74),
         (11731162783::bigint, 75),
         (11748727232::bigint, 76),
         (11731162782::bigint, 77),
         (11731162781::bigint, 78),
         (11731162780::bigint, 79),
         (11731162779::bigint, 80),
         (11734233749::bigint, 81),
         (11731162774::bigint, 82),
         (11734233750::bigint, 83),
         (11731162773::bigint, 84),
         (11734233751::bigint, 85),
         (11749241743::bigint, 86),
         (11734233752::bigint, 87),
         (11731162772::bigint, 88)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 8004651) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 14438359);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (5873323260::bigint, 1),
         (11499913966::bigint, 2),
         (1210007511::bigint, 3),
         (11576284066::bigint, 4),
         (11499913967::bigint, 5),
         (11499913968::bigint, 6),
         (11499855680::bigint, 7),
         (11499855681::bigint, 8),
         (2393442531::bigint, 9),
         (11648852790::bigint, 10),
         (11499855682::bigint, 11),
         (11648852789::bigint, 12),
         (11648852788::bigint, 13),
         (11750237048::bigint, 14),
         (3054594660::bigint, 15),
         (3054594661::bigint, 16),
         (11499855690::bigint, 17),
         (3054594662::bigint, 18),
         (11499855691::bigint, 19),
         (3054594663::bigint, 20),
         (3054594664::bigint, 21),
         (3054594665::bigint, 22),
         (11622193184::bigint, 23),
         (9654655365::bigint, 24),
         (11622193183::bigint, 25),
         (9610020118::bigint, 26),
         (10788568330::bigint, 27),
         (1728971799::bigint, 28),
         (11596427212::bigint, 29),
         (1804502956::bigint, 30),
         (1804502955::bigint, 31),
         (10788479384::bigint, 32),
         (11731162795::bigint, 33),
         (1741501481::bigint, 34),
         (10788568332::bigint, 35),
         (5423025718::bigint, 36),
         (12261001798::bigint, 37),
         (11499855694::bigint, 38),
         (11681428578::bigint, 39),
         (2215342454::bigint, 40),
         (6154043773::bigint, 41),
         (5423025824::bigint, 42),
         (11703735601::bigint, 43),
         (2226214174::bigint, 44),
         (11703735600::bigint, 45),
         (11681428577::bigint, 46),
         (11681428576::bigint, 47),
         (5423025822::bigint, 48),
         (11703735599::bigint, 49),
         (11681428575::bigint, 50),
         (6154084691::bigint, 51),
         (11703735598::bigint, 52),
         (11703735597::bigint, 53),
         (11703735596::bigint, 54),
         (11703735595::bigint, 55),
         (11734233731::bigint, 56),
         (11703735594::bigint, 57),
         (11700999659::bigint, 58),
         (11703735593::bigint, 59),
         (11703735592::bigint, 60),
         (11703735591::bigint, 61),
         (11700999663::bigint, 62),
         (11703735589::bigint, 63),
         (11748061224::bigint, 64),
         (11750717865::bigint, 65),
         (11748061223::bigint, 66),
         (11750809186::bigint, 67),
         (11750809185::bigint, 68),
         (11749262544::bigint, 69),
         (11750717864::bigint, 70),
         (11748061221::bigint, 71),
         (11748061220::bigint, 72),
         (11748061219::bigint, 73),
         (11748061218::bigint, 74),
         (3238657397::bigint, 75),
         (9670766767::bigint, 76),
         (4654994144::bigint, 77),
         (5002387598::bigint, 78),
         (5654724052::bigint, 79),
         (2340703626::bigint, 80),
         (9664332009::bigint, 81)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 14438359) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 14438360);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (8489597365::bigint, 1),
         (9664332009::bigint, 2),
         (2419390740::bigint, 3),
         (5415318321::bigint, 4),
         (9670766766::bigint, 5),
         (3238657395::bigint, 6),
         (11750717863::bigint, 7),
         (11750717862::bigint, 8),
         (11750237066::bigint, 9),
         (11748061246::bigint, 10),
         (11748727256::bigint, 11),
         (11748061221::bigint, 12),
         (11750717861::bigint, 13),
         (11748727255::bigint, 14),
         (11749241729::bigint, 15),
         (11750809207::bigint, 16),
         (11748061243::bigint, 17),
         (11748061242::bigint, 18),
         (11750717860::bigint, 19),
         (11748061241::bigint, 20),
         (355039799::bigint, 21),
         (1224283140::bigint, 22),
         (11700999663::bigint, 23),
         (11750717859::bigint, 24),
         (11700999662::bigint, 25),
         (11700999661::bigint, 26),
         (11750809206::bigint, 27),
         (11700999660::bigint, 28),
         (11703735593::bigint, 29),
         (11700999659::bigint, 30),
         (11703735594::bigint, 31),
         (2724209578::bigint, 32),
         (10742437458::bigint, 33),
         (11690806169::bigint, 34),
         (11700999657::bigint, 35),
         (11690772568::bigint, 36),
         (11750237065::bigint, 37),
         (11700999656::bigint, 38),
         (11681428575::bigint, 39),
         (11700999655::bigint, 40),
         (11690772566::bigint, 41),
         (11700999654::bigint, 42),
         (11690772565::bigint, 43),
         (11700999653::bigint, 44),
         (11690772564::bigint, 45),
         (11700999652::bigint, 46),
         (11748231703::bigint, 47),
         (4917303821::bigint, 48),
         (5423025824::bigint, 49),
         (11716558601::bigint, 50),
         (11716558600::bigint, 51),
         (11716558599::bigint, 52),
         (10127025923::bigint, 53),
         (11591414404::bigint, 54),
         (11591414403::bigint, 55),
         (11750237015::bigint, 56),
         (11750237014::bigint, 57),
         (11750237013::bigint, 58),
         (11750237012::bigint, 59),
         (11586752350::bigint, 60),
         (9610020118::bigint, 61),
         (11626627901::bigint, 62),
         (11626627900::bigint, 63),
         (9608017372::bigint, 64),
         (9592863285::bigint, 65),
         (3481605614::bigint, 66),
         (3077546540::bigint, 67),
         (3077546539::bigint, 68),
         (11626627897::bigint, 69),
         (11716558594::bigint, 70),
         (11750237049::bigint, 71),
         (11645131362::bigint, 72),
         (11502929861::bigint, 73),
         (11502929860::bigint, 74),
         (11652450386::bigint, 75),
         (2037049616::bigint, 76),
         (11502929858::bigint, 77),
         (11502929857::bigint, 78),
         (11502929854::bigint, 79),
         (11502929853::bigint, 80),
         (11572819668::bigint, 81),
         (11502929851::bigint, 82)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 14438360) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 14442057);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (1728971799::bigint, 1),
         (11596427212::bigint, 2),
         (1804502956::bigint, 3),
         (1804502955::bigint, 4),
         (10788479384::bigint, 5),
         (11731162795::bigint, 6),
         (1741501481::bigint, 7),
         (10788568332::bigint, 8),
         (11502929868::bigint, 9),
         (5401746653::bigint, 10),
         (10925258013::bigint, 11),
         (10177227264::bigint, 12),
         (10177233586::bigint, 13),
         (5423025709::bigint, 14),
         (11602247216::bigint, 15),
         (11508368331::bigint, 16),
         (2274623288::bigint, 17),
         (11505989076::bigint, 18),
         (11508368329::bigint, 19),
         (2315898140::bigint, 20),
         (11572819645::bigint, 21),
         (11572819644::bigint, 22),
         (11568883393::bigint, 23),
         (5379591769::bigint, 24),
         (11572819643::bigint, 25),
         (9580867795::bigint, 26),
         (11568883402::bigint, 27),
         (11590192510::bigint, 28),
         (10790412472::bigint, 29),
         (2815692064::bigint, 30),
         (9670766767::bigint, 31),
         (4654994144::bigint, 32),
         (5002387598::bigint, 33),
         (2315898739::bigint, 34),
         (4456305995::bigint, 35),
         (4456311189::bigint, 36),
         (4573730535::bigint, 37),
         (4649774618::bigint, 38)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 14442057) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 14442058);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (8954694119::bigint, 1),
         (4525078801::bigint, 2),
         (8954694120::bigint, 3),
         (5045493904::bigint, 4),
         (4654994160::bigint, 5),
         (5045493903::bigint, 6),
         (4649774613::bigint, 7),
         (5415318321::bigint, 8),
         (9670766766::bigint, 9),
         (11586752728::bigint, 10),
         (11586752723::bigint, 11),
         (11586752355::bigint, 12),
         (11586752354::bigint, 13),
         (11568883392::bigint, 14),
         (2315898138::bigint, 15),
         (2315898140::bigint, 16),
         (2274623288::bigint, 17),
         (11505989072::bigint, 18),
         (11505989075::bigint, 19),
         (11505989074::bigint, 20),
         (5361852916::bigint, 21),
         (10140159295::bigint, 22),
         (1589504283::bigint, 23),
         (5354500949::bigint, 24),
         (10082219830::bigint, 25),
         (12144077502::bigint, 26),
         (5395727302::bigint, 27),
         (12151464204::bigint, 28),
         (5395727300::bigint, 29),
         (1589504388::bigint, 30),
         (5401078638::bigint, 31),
         (10788568330::bigint, 32)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 14442058) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 14447121);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (8954694119::bigint, 1),
         (4525078801::bigint, 2),
         (8954694120::bigint, 3),
         (5045493904::bigint, 4),
         (4654994160::bigint, 5),
         (5045493903::bigint, 6),
         (4649774613::bigint, 7),
         (5415318321::bigint, 8),
         (9670766766::bigint, 9),
         (3238657395::bigint, 10),
         (11750717863::bigint, 11),
         (11750717862::bigint, 12),
         (11750237066::bigint, 13),
         (11748061246::bigint, 14),
         (11748727256::bigint, 15),
         (11748061221::bigint, 16),
         (11750717861::bigint, 17),
         (11748727255::bigint, 18),
         (11749241729::bigint, 19),
         (11750809207::bigint, 20),
         (11748061243::bigint, 21),
         (11748061242::bigint, 22),
         (11750717860::bigint, 23),
         (11748061241::bigint, 24),
         (355039799::bigint, 25),
         (1224283140::bigint, 26),
         (11700999663::bigint, 27),
         (11750717859::bigint, 28),
         (11700999662::bigint, 29),
         (11700999661::bigint, 30),
         (11750809206::bigint, 31),
         (11700999660::bigint, 32),
         (11703735593::bigint, 33),
         (11700999659::bigint, 34),
         (11703735594::bigint, 35),
         (2724209578::bigint, 36),
         (10742437458::bigint, 37),
         (11690806169::bigint, 38),
         (11700999657::bigint, 39),
         (11690772568::bigint, 40),
         (11750237065::bigint, 41),
         (11700999656::bigint, 42),
         (11681428575::bigint, 43),
         (11700999655::bigint, 44),
         (11690772566::bigint, 45),
         (11700999654::bigint, 46),
         (11690772565::bigint, 47),
         (11700999653::bigint, 48),
         (11690772564::bigint, 49),
         (11700999652::bigint, 50),
         (11748231703::bigint, 51),
         (4917303821::bigint, 52),
         (5423025824::bigint, 53),
         (11716558601::bigint, 54),
         (11716558600::bigint, 55),
         (11716558599::bigint, 56),
         (10127025923::bigint, 57),
         (11591414404::bigint, 58),
         (1728971799::bigint, 59)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 14447121) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 14447122);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (1728971799::bigint, 1),
         (10127025923::bigint, 2),
         (11655881339::bigint, 3),
         (11716558598::bigint, 4),
         (2215342454::bigint, 5),
         (6154043773::bigint, 6),
         (5423025824::bigint, 7),
         (11703735601::bigint, 8),
         (2226214174::bigint, 9),
         (11703735600::bigint, 10),
         (11681428577::bigint, 11),
         (11681428576::bigint, 12),
         (5423025822::bigint, 13),
         (11703735599::bigint, 14),
         (11681428575::bigint, 15),
         (6154084691::bigint, 16),
         (11703735598::bigint, 17),
         (11703735597::bigint, 18),
         (11703735596::bigint, 19),
         (11703735595::bigint, 20),
         (11734233731::bigint, 21),
         (11703735594::bigint, 22),
         (11700999659::bigint, 23),
         (11703735593::bigint, 24),
         (11703735592::bigint, 25),
         (11703735591::bigint, 26),
         (11700999663::bigint, 27),
         (11703735589::bigint, 28),
         (11748061224::bigint, 29),
         (11750717865::bigint, 30),
         (11748061223::bigint, 31),
         (11750809186::bigint, 32),
         (11750809185::bigint, 33),
         (11749262544::bigint, 34),
         (11750717864::bigint, 35),
         (11748061221::bigint, 36),
         (11748061220::bigint, 37),
         (11748061219::bigint, 38),
         (11748061218::bigint, 39),
         (3238657397::bigint, 40),
         (9670766767::bigint, 41),
         (4654994144::bigint, 42),
         (5002387598::bigint, 43),
         (2315898739::bigint, 44),
         (4456305995::bigint, 45),
         (4456311189::bigint, 46),
         (4573730535::bigint, 47),
         (4649774618::bigint, 48)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 14447122) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 14449325);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (3266477240::bigint, 1),
         (1941869005::bigint, 2),
         (1941873678::bigint, 3),
         (1941871514::bigint, 4),
         (4558623651::bigint, 5),
         (2406297012::bigint, 6),
         (10099186304::bigint, 7),
         (10126914527::bigint, 8),
         (10013893080::bigint, 9),
         (9622477371::bigint, 10),
         (11745381404::bigint, 11),
         (9428070121::bigint, 12),
         (2380076720::bigint, 13),
         (11750717866::bigint, 14),
         (11508368335::bigint, 15),
         (5389795618::bigint, 16),
         (11681428580::bigint, 17),
         (9641559167::bigint, 18),
         (10096123274::bigint, 19),
         (4116855112::bigint, 20),
         (10695768689::bigint, 21),
         (11681428579::bigint, 22),
         (5393038589::bigint, 23),
         (9588873700::bigint, 24),
         (5393038587::bigint, 25),
         (9923697695::bigint, 26),
         (9923702850::bigint, 27),
         (5354500951::bigint, 28),
         (11019050480::bigint, 29),
         (10724102115::bigint, 30)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 14449325) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 14449326);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (10724102115::bigint, 1),
         (1191929295::bigint, 2),
         (5401078638::bigint, 3),
         (11734233728::bigint, 4),
         (9630447877::bigint, 5),
         (1541569015::bigint, 6),
         (9650545925::bigint, 7),
         (11645131367::bigint, 8),
         (2045268306::bigint, 9),
         (4116855114::bigint, 10),
         (11745843042::bigint, 11),
         (11745381403::bigint, 12),
         (10100951965::bigint, 13),
         (4116855112::bigint, 14),
         (5423025879::bigint, 15),
         (11745381402::bigint, 16),
         (11505958868::bigint, 17),
         (10100979100::bigint, 18),
         (11690772562::bigint, 19),
         (10100981309::bigint, 20),
         (10132364564::bigint, 21),
         (11505958856::bigint, 22),
         (9622477371::bigint, 23),
         (4595625753::bigint, 24),
         (11505958861::bigint, 25),
         (10101021829::bigint, 26),
         (2497972844::bigint, 27),
         (10013893076::bigint, 28),
         (9622429848::bigint, 29),
         (10117300751::bigint, 30),
         (11690772555::bigint, 31),
         (11750717858::bigint, 32),
         (11750717857::bigint, 33),
         (11690772553::bigint, 34),
         (1941872595::bigint, 35)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 14449326) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 14465855);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (11591414372::bigint, 1),
         (11741845570::bigint, 2),
         (11741246891::bigint, 3),
         (11741246890::bigint, 4),
         (11741845573::bigint, 5),
         (11741246889::bigint, 6),
         (11741246888::bigint, 7),
         (11741246887::bigint, 8),
         (11741246885::bigint, 9),
         (11741246884::bigint, 10),
         (11741246883::bigint, 11),
         (11724812643::bigint, 12),
         (11741246881::bigint, 13),
         (11741246880::bigint, 14),
         (11741246879::bigint, 15),
         (11741246878::bigint, 16),
         (11741246877::bigint, 17),
         (11716558617::bigint, 18),
         (11741246876::bigint, 19),
         (11741246875::bigint, 20),
         (11741246874::bigint, 21),
         (11741246873::bigint, 22),
         (11734233731::bigint, 23),
         (11681428573::bigint, 24),
         (10742437458::bigint, 25),
         (11690806169::bigint, 26),
         (11700999657::bigint, 27),
         (11690772568::bigint, 28),
         (11750237065::bigint, 29),
         (11700999656::bigint, 30),
         (11681428575::bigint, 31),
         (11700999655::bigint, 32),
         (11690772566::bigint, 33),
         (11700999654::bigint, 34),
         (11690772565::bigint, 35),
         (11700999653::bigint, 36),
         (11690772564::bigint, 37),
         (11700999652::bigint, 38),
         (11748231703::bigint, 39),
         (4917303821::bigint, 40),
         (11700999651::bigint, 41),
         (11502937469::bigint, 42),
         (11510859310::bigint, 43),
         (9574100730::bigint, 44),
         (11502929868::bigint, 45),
         (9574100733::bigint, 46),
         (12144077505::bigint, 47),
         (12112457212::bigint, 48),
         (5349662693::bigint, 49),
         (10140159295::bigint, 50),
         (1589504283::bigint, 51),
         (5354500949::bigint, 52),
         (10082219830::bigint, 53),
         (12144077502::bigint, 54),
         (11734233729::bigint, 55),
         (11734233728::bigint, 56),
         (9630447877::bigint, 57),
         (11734233727::bigint, 58),
         (11502929867::bigint, 59),
         (9635248369::bigint, 60),
         (11748061239::bigint, 61),
         (11734233725::bigint, 62),
         (9598435807::bigint, 63),
         (11734233723::bigint, 64),
         (11342019228::bigint, 65),
         (11568883379::bigint, 66),
         (11572819658::bigint, 67),
         (11741246872::bigint, 68),
         (11741246871::bigint, 69),
         (11586752345::bigint, 70),
         (11741246870::bigint, 71),
         (11586752344::bigint, 72),
         (11586752343::bigint, 73),
         (11586752342::bigint, 74),
         (11741246869::bigint, 75),
         (11734233720::bigint, 76),
         (2383938357::bigint, 77),
         (11734233719::bigint, 78),
         (11734233718::bigint, 79),
         (11734233716::bigint, 80),
         (11734233717::bigint, 81),
         (2377499679::bigint, 82),
         (11676373696::bigint, 83),
         (11676373695::bigint, 84),
         (11734233713::bigint, 85),
         (11676373694::bigint, 86)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 14465855) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 14468699);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (11741246884::bigint, 1),
         (11742321769::bigint, 2),
         (11716558623::bigint, 3),
         (3134456377::bigint, 4),
         (11716558621::bigint, 5),
         (11742296368::bigint, 6),
         (11742296367::bigint, 7),
         (11745080348::bigint, 8),
         (11745080349::bigint, 9),
         (11742296366::bigint, 10),
         (11745080350::bigint, 11),
         (11742296365::bigint, 12),
         (11745080351::bigint, 13),
         (11742296360::bigint, 14),
         (11731162790::bigint, 15),
         (11742296364::bigint, 16),
         (11742296363::bigint, 17),
         (11742296362::bigint, 18),
         (355039799::bigint, 19),
         (1224283140::bigint, 20),
         (11700999663::bigint, 21),
         (11750717859::bigint, 22),
         (11700999662::bigint, 23),
         (11700999661::bigint, 24),
         (11750809206::bigint, 25),
         (11700999660::bigint, 26),
         (11703735593::bigint, 27),
         (11700999659::bigint, 28),
         (11703735594::bigint, 29),
         (2724209578::bigint, 30),
         (10742437458::bigint, 31),
         (11690806169::bigint, 32),
         (11700999657::bigint, 33),
         (11690772568::bigint, 34),
         (11750237065::bigint, 35),
         (11700999656::bigint, 36),
         (11681428575::bigint, 37),
         (11700999655::bigint, 38),
         (11690772566::bigint, 39),
         (11700999654::bigint, 40),
         (11690772565::bigint, 41),
         (11700999653::bigint, 42),
         (11690772564::bigint, 43),
         (11700999652::bigint, 44),
         (11748231703::bigint, 45),
         (4917303821::bigint, 46),
         (11700999651::bigint, 47),
         (11502937469::bigint, 48),
         (11510859310::bigint, 49),
         (9574100730::bigint, 50),
         (11502929868::bigint, 51),
         (9574100733::bigint, 52),
         (12144077505::bigint, 53),
         (12112457212::bigint, 54),
         (12120184002::bigint, 55),
         (12146079715::bigint, 56),
         (12146079714::bigint, 57),
         (5393038581::bigint, 58),
         (5340694064::bigint, 59),
         (5395727300::bigint, 60),
         (1589504388::bigint, 61),
         (5401078638::bigint, 62),
         (11586752350::bigint, 63),
         (10788568329::bigint, 64),
         (11586752349::bigint, 65),
         (11586752347::bigint, 66),
         (11586752348::bigint, 67),
         (11586752346::bigint, 68),
         (11664987766::bigint, 69),
         (11664987765::bigint, 70),
         (11742296361::bigint, 71),
         (11664987764::bigint, 72),
         (11734233717::bigint, 73),
         (2377499679::bigint, 74),
         (11676373696::bigint, 75),
         (11676373695::bigint, 76),
         (11734233713::bigint, 77),
         (11676373694::bigint, 78)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 14468699) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 15060597);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (10695768687::bigint, 1),
         (10697951147::bigint, 2),
         (2341271051::bigint, 3),
         (2341272241::bigint, 4),
         (2341271052::bigint, 5),
         (10099186304::bigint, 6),
         (10126914527::bigint, 7),
         (10013893080::bigint, 8),
         (9622477371::bigint, 9),
         (11745381404::bigint, 10),
         (9428070121::bigint, 11),
         (2380076720::bigint, 12),
         (11750717866::bigint, 13),
         (11508368335::bigint, 14),
         (5389795618::bigint, 15),
         (11681428580::bigint, 16),
         (9641559167::bigint, 17),
         (10096123274::bigint, 18),
         (4116855112::bigint, 19),
         (10695768689::bigint, 20),
         (11681428579::bigint, 21),
         (5393038589::bigint, 22),
         (9588873700::bigint, 23),
         (5393038587::bigint, 24),
         (5395727306::bigint, 25),
         (11731162796::bigint, 26),
         (11019050480::bigint, 27),
         (10724102115::bigint, 28)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 15060597) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 15060598);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (10724102115::bigint, 1),
         (1191929295::bigint, 2),
         (5401078638::bigint, 3),
         (11734233728::bigint, 4),
         (9630447877::bigint, 5),
         (1541569015::bigint, 6),
         (9650545925::bigint, 7),
         (11645131367::bigint, 8),
         (2045268306::bigint, 9),
         (4116855114::bigint, 10),
         (11745843042::bigint, 11),
         (11745381403::bigint, 12),
         (10100951965::bigint, 13),
         (4116855112::bigint, 14),
         (5423025879::bigint, 15),
         (11745381402::bigint, 16),
         (11505958868::bigint, 17),
         (10100979100::bigint, 18),
         (11690772562::bigint, 19),
         (10100981309::bigint, 20),
         (10132364564::bigint, 21),
         (11505958856::bigint, 22),
         (9622477371::bigint, 23),
         (4595625753::bigint, 24),
         (11505958861::bigint, 25),
         (10101021829::bigint, 26),
         (2497972844::bigint, 27),
         (10013893076::bigint, 28),
         (9622429848::bigint, 29),
         (10697137885::bigint, 30),
         (2411275649::bigint, 31),
         (10697895420::bigint, 32),
         (10697895419::bigint, 33),
         (10697951147::bigint, 34)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 15060598) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 15061595);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (10724102115::bigint, 1),
         (1191929295::bigint, 2),
         (5401078638::bigint, 3),
         (11734233728::bigint, 4),
         (9630447877::bigint, 5),
         (1541569015::bigint, 6),
         (9650545925::bigint, 7),
         (11645131367::bigint, 8),
         (2045268306::bigint, 9),
         (4116855114::bigint, 10),
         (11745843042::bigint, 11),
         (11745381403::bigint, 12),
         (10100951965::bigint, 13),
         (4116855112::bigint, 14),
         (5423025879::bigint, 15),
         (11745381402::bigint, 16),
         (11505958868::bigint, 17),
         (10100979100::bigint, 18),
         (11690772562::bigint, 19),
         (10100981309::bigint, 20),
         (10132364564::bigint, 21),
         (11505958856::bigint, 22),
         (9622477371::bigint, 23),
         (4595625753::bigint, 24),
         (11505958861::bigint, 25),
         (10101021829::bigint, 26),
         (2497972844::bigint, 27),
         (10013893076::bigint, 28),
         (9622429848::bigint, 29),
         (10697137885::bigint, 30),
         (2411275649::bigint, 31),
         (10697895420::bigint, 32),
         (10697895419::bigint, 33)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 15061595) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 15540760);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (1225778827::bigint, 1),
         (11748061216::bigint, 2),
         (11748061217::bigint, 3),
         (3238657395::bigint, 4),
         (11750717863::bigint, 5),
         (11750717862::bigint, 6),
         (11750237066::bigint, 7),
         (11748061246::bigint, 8),
         (11748727256::bigint, 9),
         (11748061221::bigint, 10),
         (11750717861::bigint, 11),
         (11748727255::bigint, 12),
         (11749241729::bigint, 13),
         (11750809207::bigint, 14),
         (11748061243::bigint, 15),
         (11748061242::bigint, 16),
         (11750717860::bigint, 17),
         (11748061241::bigint, 18),
         (355039799::bigint, 19),
         (1224283140::bigint, 20),
         (11700999663::bigint, 21),
         (11750717859::bigint, 22),
         (11700999662::bigint, 23),
         (11700999661::bigint, 24),
         (11750809206::bigint, 25),
         (11700999660::bigint, 26),
         (11703735593::bigint, 27),
         (11700999659::bigint, 28),
         (11703735594::bigint, 29),
         (2724209578::bigint, 30),
         (10742437458::bigint, 31),
         (11690806169::bigint, 32),
         (11700999657::bigint, 33),
         (11690772568::bigint, 34),
         (11750237065::bigint, 35),
         (11700999656::bigint, 36),
         (11681428575::bigint, 37),
         (11700999655::bigint, 38),
         (11690772566::bigint, 39),
         (11700999654::bigint, 40),
         (11690772565::bigint, 41),
         (11700999653::bigint, 42),
         (11690772564::bigint, 43),
         (11700999652::bigint, 44),
         (11748231703::bigint, 45),
         (4917303821::bigint, 46),
         (11700999651::bigint, 47),
         (11502937469::bigint, 48),
         (11510859310::bigint, 49),
         (9574100730::bigint, 50),
         (11502929868::bigint, 51),
         (9574100733::bigint, 52),
         (12144077505::bigint, 53),
         (12112457212::bigint, 54),
         (12120184002::bigint, 55),
         (12146079715::bigint, 56),
         (10140159295::bigint, 57),
         (5349662692::bigint, 58),
         (11745843043::bigint, 59),
         (5337560205::bigint, 60),
         (9574158677::bigint, 61),
         (4116855114::bigint, 62),
         (11745843042::bigint, 63),
         (11745381403::bigint, 64),
         (10100951965::bigint, 65),
         (4116855112::bigint, 66),
         (5423025879::bigint, 67),
         (11745381402::bigint, 68),
         (11505958868::bigint, 69),
         (10100979100::bigint, 70),
         (11690772562::bigint, 71),
         (10100981309::bigint, 72),
         (10132364564::bigint, 73),
         (11505958856::bigint, 74),
         (9622477371::bigint, 75),
         (4595625753::bigint, 76),
         (11505958861::bigint, 77),
         (10101021829::bigint, 78),
         (10101022555::bigint, 79),
         (2497972844::bigint, 80),
         (10013893076::bigint, 81),
         (10101015843::bigint, 82),
         (10008701031::bigint, 83),
         (9622429848::bigint, 84),
         (10117294508::bigint, 85),
         (10117300751::bigint, 86),
         (11690772555::bigint, 87),
         (11750717858::bigint, 88),
         (11750717857::bigint, 89),
         (11750717856::bigint, 90),
         (11690772554::bigint, 91),
         (11690772553::bigint, 92),
         (11750717855::bigint, 93),
         (11750717854::bigint, 94),
         (11750717853::bigint, 95),
         (11750745069::bigint, 96),
         (10698064411::bigint, 97)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 15540760) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 15540761);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (10698064411::bigint, 1),
         (11750745069::bigint, 2),
         (11750717853::bigint, 3),
         (11750717868::bigint, 4),
         (11750717867::bigint, 5),
         (9017890943::bigint, 6),
         (11681428598::bigint, 7),
         (10096175373::bigint, 8),
         (11681428583::bigint, 9),
         (4558623651::bigint, 10),
         (2406297012::bigint, 11),
         (10002974639::bigint, 12),
         (9661999750::bigint, 13),
         (9015653273::bigint, 14),
         (11681428582::bigint, 15),
         (11693836924::bigint, 16),
         (10099186304::bigint, 17),
         (10126914527::bigint, 18),
         (10013893080::bigint, 19),
         (9622477371::bigint, 20),
         (11745381404::bigint, 21),
         (9428070121::bigint, 22),
         (2380076720::bigint, 23),
         (11750717866::bigint, 24),
         (11508368335::bigint, 25),
         (5389795618::bigint, 26),
         (11681428580::bigint, 27),
         (9641559167::bigint, 28),
         (5423025879::bigint, 29),
         (10096123274::bigint, 30),
         (4116855112::bigint, 31),
         (10695768689::bigint, 32),
         (11681428579::bigint, 33),
         (5393038589::bigint, 34),
         (9588873700::bigint, 35),
         (5393038587::bigint, 36),
         (9923697695::bigint, 37),
         (9923702850::bigint, 38),
         (5393038585::bigint, 39),
         (5294340532::bigint, 40),
         (12146079715::bigint, 41),
         (12146079714::bigint, 42),
         (1804502952::bigint, 43),
         (12155249141::bigint, 44),
         (12144077507::bigint, 45),
         (12261001799::bigint, 46),
         (5423025718::bigint, 47),
         (12261001798::bigint, 48),
         (11499855694::bigint, 49),
         (11681428578::bigint, 50),
         (2215342454::bigint, 51),
         (6154043773::bigint, 52),
         (5423025824::bigint, 53),
         (11703735601::bigint, 54),
         (2226214174::bigint, 55),
         (11703735600::bigint, 56),
         (11681428577::bigint, 57),
         (11681428576::bigint, 58),
         (5423025822::bigint, 59),
         (11703735599::bigint, 60),
         (11681428575::bigint, 61),
         (6154084691::bigint, 62),
         (11703735598::bigint, 63),
         (11703735597::bigint, 64),
         (11703735596::bigint, 65),
         (11703735595::bigint, 66),
         (11734233731::bigint, 67),
         (11703735594::bigint, 68),
         (11700999659::bigint, 69),
         (11703735593::bigint, 70),
         (11703735592::bigint, 71),
         (11703735591::bigint, 72),
         (11700999663::bigint, 73),
         (11703735589::bigint, 74),
         (11748061224::bigint, 75),
         (11750717865::bigint, 76),
         (11748061223::bigint, 77),
         (11750809186::bigint, 78),
         (11750809185::bigint, 79),
         (11749262544::bigint, 80),
         (11750717864::bigint, 81),
         (11748061221::bigint, 82),
         (11748061220::bigint, 83),
         (11748061219::bigint, 84),
         (11748061218::bigint, 85),
         (3238657397::bigint, 86),
         (11749241726::bigint, 87),
         (11749241727::bigint, 88),
         (10837232580::bigint, 89)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 15540761) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 17000508);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (11499913952::bigint, 1),
         (11499913953::bigint, 2),
         (11499913954::bigint, 3),
         (11499913955::bigint, 4),
         (11502929839::bigint, 5),
         (11499913956::bigint, 6),
         (11502929840::bigint, 7),
         (11499913957::bigint, 8),
         (12144077508::bigint, 9),
         (11499913960::bigint, 10),
         (11499913961::bigint, 11),
         (11499913962::bigint, 12),
         (11499913963::bigint, 13),
         (5432259053::bigint, 14),
         (11502929848::bigint, 15),
         (11499913964::bigint, 16),
         (11499913965::bigint, 17),
         (11499913966::bigint, 18),
         (1210007511::bigint, 19),
         (11576284066::bigint, 20),
         (11499913967::bigint, 21),
         (11499913968::bigint, 22),
         (11499855680::bigint, 23),
         (11499855681::bigint, 24),
         (2393442531::bigint, 25),
         (11648852790::bigint, 26),
         (11499855682::bigint, 27),
         (11648852789::bigint, 28),
         (11648852788::bigint, 29),
         (11750237048::bigint, 30),
         (3054594660::bigint, 31),
         (3054594661::bigint, 32),
         (11499855690::bigint, 33),
         (3054594662::bigint, 34),
         (11499855691::bigint, 35),
         (3054594663::bigint, 36),
         (3054594664::bigint, 37),
         (3054594665::bigint, 38),
         (11622193184::bigint, 39),
         (9654655365::bigint, 40),
         (11622193183::bigint, 41),
         (11499855693::bigint, 42),
         (10788568329::bigint, 43),
         (11590192515::bigint, 44),
         (11750237012::bigint, 45),
         (10788568330::bigint, 46),
         (10055961687::bigint, 47),
         (1804502956::bigint, 48),
         (1804502955::bigint, 49),
         (5393825158::bigint, 50),
         (1804502952::bigint, 51),
         (12155249141::bigint, 52),
         (12144077507::bigint, 53),
         (12261001799::bigint, 54),
         (5423025718::bigint, 55),
         (12261001798::bigint, 56),
         (11499855694::bigint, 57),
         (11681428578::bigint, 58),
         (2215342454::bigint, 59),
         (6154043773::bigint, 60),
         (5423025824::bigint, 61),
         (11690772563::bigint, 62),
         (11499855696::bigint, 63),
         (11499855697::bigint, 64),
         (11499855698::bigint, 65),
         (11499855699::bigint, 66),
         (11499855700::bigint, 67),
         (11508368322::bigint, 68),
         (11499855701::bigint, 69)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 17000508) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 17004625);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (11499855701::bigint, 1),
         (11505989086::bigint, 2),
         (11502937475::bigint, 3),
         (11502937474::bigint, 4),
         (11502937473::bigint, 5),
         (11510859312::bigint, 6),
         (11499855698::bigint, 7),
         (11510859311::bigint, 8),
         (11502937472::bigint, 9),
         (4917303821::bigint, 10),
         (11700999651::bigint, 11),
         (11502937469::bigint, 12),
         (11510859310::bigint, 13),
         (9574100730::bigint, 14),
         (11502929868::bigint, 15),
         (9574100733::bigint, 16),
         (12144077505::bigint, 17),
         (12112457212::bigint, 18),
         (5349662693::bigint, 19),
         (10140159295::bigint, 20),
         (1589504283::bigint, 21),
         (5354500949::bigint, 22),
         (10082219830::bigint, 23),
         (12144077502::bigint, 24),
         (11734233729::bigint, 25),
         (11734233728::bigint, 26),
         (9630447877::bigint, 27),
         (11734233727::bigint, 28),
         (11502929867::bigint, 29),
         (9635248369::bigint, 30),
         (11748061239::bigint, 31),
         (11502929866::bigint, 32),
         (9571133081::bigint, 33),
         (11502929864::bigint, 34),
         (11502929863::bigint, 35),
         (11645131363::bigint, 36),
         (11502929862::bigint, 37),
         (11750237049::bigint, 38),
         (11645131362::bigint, 39),
         (11502929861::bigint, 40),
         (11502929860::bigint, 41),
         (11652450386::bigint, 42),
         (2037049616::bigint, 43),
         (11502929858::bigint, 44),
         (11502929857::bigint, 45),
         (11502929854::bigint, 46),
         (11502929853::bigint, 47),
         (11572819668::bigint, 48),
         (11502929851::bigint, 49),
         (11502929850::bigint, 50),
         (11499913965::bigint, 51),
         (11502929849::bigint, 52),
         (11502929848::bigint, 53),
         (5432259053::bigint, 54),
         (11502929847::bigint, 55),
         (11502929846::bigint, 56),
         (11502929845::bigint, 57),
         (11622193196::bigint, 58),
         (11499913957::bigint, 59),
         (11502929840::bigint, 60),
         (11499913956::bigint, 61),
         (11502929839::bigint, 62)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 17004625) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 17009672);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (11499855701::bigint, 1),
         (11505989086::bigint, 2),
         (11502937475::bigint, 3),
         (11502937474::bigint, 4),
         (11502937473::bigint, 5),
         (11505989079::bigint, 6),
         (11505989078::bigint, 7),
         (11505989077::bigint, 8),
         (11505989076::bigint, 9),
         (2274623288::bigint, 10),
         (11505989072::bigint, 11),
         (11505989075::bigint, 12),
         (11505989074::bigint, 13),
         (12146079716::bigint, 14),
         (12112457212::bigint, 15),
         (12120184002::bigint, 16),
         (12146079715::bigint, 17),
         (10140159295::bigint, 18),
         (5349662692::bigint, 19),
         (11745843043::bigint, 20),
         (5337560205::bigint, 21),
         (9574158677::bigint, 22),
         (4116855114::bigint, 23),
         (11745843042::bigint, 24),
         (11745381403::bigint, 25),
         (10100951965::bigint, 26),
         (4116855112::bigint, 27),
         (5423025879::bigint, 28),
         (11745381402::bigint, 29),
         (11505958868::bigint, 30),
         (10100979100::bigint, 31),
         (11690772562::bigint, 32),
         (10100981309::bigint, 33),
         (10132364564::bigint, 34),
         (11505958856::bigint, 35),
         (9622477371::bigint, 36),
         (4595625753::bigint, 37),
         (11505958861::bigint, 38),
         (10126914527::bigint, 39),
         (11505958855::bigint, 40),
         (11505958852::bigint, 41),
         (11505958851::bigint, 42),
         (11505958850::bigint, 43),
         (11724812666::bigint, 44),
         (4603393591::bigint, 45),
         (5432236583::bigint, 46),
         (10772099263::bigint, 47),
         (11505958849::bigint, 48),
         (11508368354::bigint, 49),
         (11505958848::bigint, 50),
         (11508368355::bigint, 51),
         (11505958847::bigint, 52),
         (11508368356::bigint, 53),
         (11510859293::bigint, 54),
         (4116855116::bigint, 55),
         (11508368361::bigint, 56),
         (4116855117::bigint, 57),
         (4116855118::bigint, 58),
         (11508368363::bigint, 59),
         (11505958844::bigint, 60),
         (11505958843::bigint, 61),
         (11505958842::bigint, 62),
         (11508368366::bigint, 63),
         (11505958841::bigint, 64),
         (11505958840::bigint, 65),
         (11505958839::bigint, 66),
         (11505958838::bigint, 67),
         (11505958837::bigint, 68),
         (11499913956::bigint, 69),
         (11502929839::bigint, 70)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 17009672) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 17013197);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (11499913952::bigint, 1),
         (11499913953::bigint, 2),
         (11499913954::bigint, 3),
         (11499913955::bigint, 4),
         (11502929839::bigint, 5),
         (11499913956::bigint, 6),
         (11502929840::bigint, 7),
         (11508412572::bigint, 8),
         (11508412569::bigint, 9),
         (11508368368::bigint, 10),
         (11508368367::bigint, 11),
         (11508368366::bigint, 12),
         (11505958842::bigint, 13),
         (11508368365::bigint, 14),
         (11508368364::bigint, 15),
         (4116855118::bigint, 16),
         (4116855117::bigint, 17),
         (11508368361::bigint, 18),
         (4116855116::bigint, 19),
         (11508368359::bigint, 20),
         (11505958846::bigint, 21),
         (11508368355::bigint, 22),
         (11505958848::bigint, 23),
         (11508368354::bigint, 24),
         (11508368353::bigint, 25),
         (11622193193::bigint, 26),
         (11716558593::bigint, 27),
         (11508368352::bigint, 28),
         (11563981252::bigint, 29),
         (11750809201::bigint, 30),
         (11563981251::bigint, 31),
         (11508368351::bigint, 32),
         (10013893080::bigint, 33),
         (9622477371::bigint, 34),
         (11745381404::bigint, 35),
         (9428070121::bigint, 36),
         (2380076720::bigint, 37),
         (11750717866::bigint, 38),
         (11508368335::bigint, 39),
         (5389795618::bigint, 40),
         (11681428580::bigint, 41),
         (9641559167::bigint, 42),
         (10096123274::bigint, 43),
         (4116855112::bigint, 44),
         (10695768689::bigint, 45),
         (11681428579::bigint, 46),
         (5393038589::bigint, 47),
         (9588873700::bigint, 48),
         (5393038587::bigint, 49),
         (9923697695::bigint, 50),
         (9923702850::bigint, 51),
         (5393038585::bigint, 52),
         (5294340532::bigint, 53),
         (12146079715::bigint, 54),
         (12146079714::bigint, 55),
         (1804502952::bigint, 56),
         (12155249141::bigint, 57),
         (12144077505::bigint, 58),
         (12146079713::bigint, 59),
         (11594616779::bigint, 60),
         (5423025709::bigint, 61),
         (11602247216::bigint, 62),
         (11508368331::bigint, 63),
         (2274623288::bigint, 64),
         (11505989076::bigint, 65),
         (11508368329::bigint, 66),
         (11508368328::bigint, 67),
         (11508368327::bigint, 68),
         (11508368326::bigint, 69),
         (11508368325::bigint, 70),
         (11508368324::bigint, 71),
         (11508368323::bigint, 72),
         (11499855699::bigint, 73),
         (11499855700::bigint, 74),
         (11508368322::bigint, 75),
         (11499855701::bigint, 76)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 17013197) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 17017123);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (11499855701::bigint, 1),
         (11505989086::bigint, 2),
         (11502937475::bigint, 3),
         (11502937474::bigint, 4),
         (11502937473::bigint, 5),
         (11510859312::bigint, 6),
         (11499855698::bigint, 7),
         (11510859311::bigint, 8),
         (11502937472::bigint, 9),
         (4917303821::bigint, 10),
         (11700999651::bigint, 11),
         (11502937469::bigint, 12),
         (11510859310::bigint, 13),
         (9574100730::bigint, 14),
         (11502929868::bigint, 15),
         (9574100733::bigint, 16),
         (12144077505::bigint, 17),
         (12112457212::bigint, 18),
         (12120184002::bigint, 19),
         (12146079715::bigint, 20),
         (10140159295::bigint, 21),
         (5349662692::bigint, 22),
         (11745843043::bigint, 23),
         (5337560205::bigint, 24),
         (9574158677::bigint, 25),
         (4116855114::bigint, 26),
         (11745843042::bigint, 27),
         (11745381403::bigint, 28),
         (10100951965::bigint, 29),
         (4116855112::bigint, 30),
         (5423025879::bigint, 31),
         (11745381402::bigint, 32),
         (11505958868::bigint, 33),
         (10100979100::bigint, 34),
         (11690772562::bigint, 35),
         (10100981309::bigint, 36),
         (10132364564::bigint, 37),
         (11505958856::bigint, 38),
         (9622477371::bigint, 39),
         (4595625753::bigint, 40),
         (11505958861::bigint, 41),
         (10126914527::bigint, 42),
         (11505958855::bigint, 43),
         (11505958852::bigint, 44),
         (11505958851::bigint, 45),
         (11505958850::bigint, 46),
         (11724812666::bigint, 47),
         (4603393591::bigint, 48),
         (5432236583::bigint, 49),
         (10772099263::bigint, 50),
         (11505958849::bigint, 51),
         (11510859309::bigint, 52),
         (11563981255::bigint, 53),
         (11510859308::bigint, 54),
         (11510859295::bigint, 55),
         (11510859294::bigint, 56),
         (11505958846::bigint, 57),
         (11510859293::bigint, 58),
         (4116855116::bigint, 59),
         (11508368361::bigint, 60),
         (4116855117::bigint, 61),
         (4116855118::bigint, 62),
         (11508368363::bigint, 63),
         (11505958844::bigint, 64),
         (11505958843::bigint, 65),
         (11505958842::bigint, 66),
         (11508368366::bigint, 67),
         (11505958841::bigint, 68),
         (11505958840::bigint, 69),
         (11505958839::bigint, 70),
         (11505958838::bigint, 71),
         (11505958837::bigint, 72),
         (11499913956::bigint, 73),
         (11502929839::bigint, 74)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 17017123) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 17097018);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (11499913952::bigint, 1),
         (11499913953::bigint, 2),
         (11499913954::bigint, 3),
         (11499913955::bigint, 4),
         (11502929839::bigint, 5),
         (11499913956::bigint, 6),
         (11502929840::bigint, 7),
         (11508412572::bigint, 8),
         (11508412569::bigint, 9),
         (11508368368::bigint, 10),
         (11508368367::bigint, 11),
         (11508368366::bigint, 12),
         (11505958842::bigint, 13),
         (11508368365::bigint, 14),
         (11508368364::bigint, 15),
         (4116855118::bigint, 16),
         (4116855117::bigint, 17),
         (11508368361::bigint, 18),
         (4116855116::bigint, 19),
         (11508368359::bigint, 20),
         (11505958846::bigint, 21),
         (11563981258::bigint, 22),
         (11563981257::bigint, 23),
         (11563981256::bigint, 24),
         (11563981255::bigint, 25),
         (11563981254::bigint, 26),
         (11563981253::bigint, 27),
         (11716558593::bigint, 28),
         (11508368352::bigint, 29),
         (11563981252::bigint, 30),
         (11750809201::bigint, 31),
         (11563981251::bigint, 32),
         (11508368351::bigint, 33),
         (10013893080::bigint, 34),
         (9622477371::bigint, 35),
         (11745381404::bigint, 36),
         (9428070121::bigint, 37),
         (2380076720::bigint, 38),
         (11750717866::bigint, 39),
         (11508368335::bigint, 40),
         (5389795618::bigint, 41),
         (11681428580::bigint, 42),
         (9641559167::bigint, 43),
         (10096123274::bigint, 44),
         (4116855112::bigint, 45),
         (10695768689::bigint, 46),
         (11681428579::bigint, 47),
         (5393038589::bigint, 48),
         (9588873700::bigint, 49),
         (5393038587::bigint, 50),
         (9923697695::bigint, 51),
         (9923702850::bigint, 52),
         (5393038585::bigint, 53),
         (5294340532::bigint, 54),
         (12146079715::bigint, 55),
         (12146079714::bigint, 56),
         (1804502952::bigint, 57),
         (12155249141::bigint, 58),
         (12144077507::bigint, 59),
         (12261001799::bigint, 60),
         (5423025718::bigint, 61),
         (12261001798::bigint, 62),
         (11499855694::bigint, 63),
         (11681428578::bigint, 64),
         (2215342454::bigint, 65),
         (6154043773::bigint, 66),
         (5423025824::bigint, 67),
         (11690772563::bigint, 68),
         (11499855696::bigint, 69),
         (11499855697::bigint, 70),
         (11499855698::bigint, 71),
         (11499855699::bigint, 72),
         (11499855700::bigint, 73),
         (11508368322::bigint, 74),
         (11499855701::bigint, 75)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 17097018) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 17126662);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (11568883402::bigint, 1),
         (11568883401::bigint, 2),
         (11568883400::bigint, 3),
         (11568883399::bigint, 4),
         (11568883398::bigint, 5),
         (11568883397::bigint, 6),
         (11568883396::bigint, 7),
         (11568883395::bigint, 8),
         (11568883394::bigint, 9),
         (11568883393::bigint, 10),
         (11568883392::bigint, 11),
         (2315898138::bigint, 12),
         (2315898140::bigint, 13),
         (11508368329::bigint, 14),
         (11508368328::bigint, 15),
         (11508368327::bigint, 16),
         (9707992257::bigint, 17),
         (11568883388::bigint, 18),
         (9569922716::bigint, 19),
         (11568883386::bigint, 20),
         (5401746653::bigint, 21),
         (12144077505::bigint, 22),
         (12112457212::bigint, 23),
         (12120184002::bigint, 24),
         (12146079715::bigint, 25),
         (12150561838::bigint, 26),
         (12150561837::bigint, 27),
         (1589504365::bigint, 28),
         (12150561836::bigint, 29),
         (12234899800::bigint, 30),
         (9650545925::bigint, 31),
         (11568883385::bigint, 32),
         (11576335873::bigint, 33),
         (3054594665::bigint, 34),
         (11568883383::bigint, 35),
         (11576335872::bigint, 36),
         (11568883382::bigint, 37),
         (11568883381::bigint, 38),
         (11568883380::bigint, 39),
         (11568883379::bigint, 40),
         (11568883378::bigint, 41),
         (11568883377::bigint, 42),
         (11568883376::bigint, 43),
         (11568883375::bigint, 44),
         (11568883374::bigint, 45),
         (11748061230::bigint, 46),
         (11748061236::bigint, 47),
         (11572819664::bigint, 48),
         (11568883372::bigint, 49),
         (11572819665::bigint, 50),
         (11568883371::bigint, 51),
         (11568883370::bigint, 52),
         (11568883369::bigint, 53),
         (11572819668::bigint, 54),
         (11576284065::bigint, 55),
         (2680328524::bigint, 56),
         (11576284064::bigint, 57),
         (11572838469::bigint, 58),
         (11568879567::bigint, 59),
         (11568879566::bigint, 60),
         (11572838470::bigint, 61),
         (11568879565::bigint, 62),
         (11568879564::bigint, 63)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 17126662) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 17132593);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (11502929845::bigint, 1),
         (11572838471::bigint, 2),
         (11572838470::bigint, 3),
         (11568879566::bigint, 4),
         (11568879567::bigint, 5),
         (11580325127::bigint, 6),
         (11576284064::bigint, 7),
         (2680328524::bigint, 8),
         (11576284065::bigint, 9),
         (11572819668::bigint, 10),
         (11568883369::bigint, 11),
         (11572819667::bigint, 12),
         (11572819666::bigint, 13),
         (11572819665::bigint, 14),
         (11568883372::bigint, 15),
         (11572819664::bigint, 16),
         (11568883373::bigint, 17),
         (11748061230::bigint, 18),
         (11568883374::bigint, 19),
         (11572819661::bigint, 20),
         (11572819660::bigint, 21),
         (11572819659::bigint, 22),
         (11572819658::bigint, 23),
         (11741845582::bigint, 24),
         (12150561833::bigint, 25),
         (12150561834::bigint, 26),
         (12150561832::bigint, 27),
         (11572819655::bigint, 28),
         (11580325114::bigint, 29),
         (11572819654::bigint, 30),
         (9569868044::bigint, 31),
         (11572819653::bigint, 32),
         (11626627900::bigint, 33),
         (11572819652::bigint, 34),
         (9630447877::bigint, 35),
         (1541569015::bigint, 36),
         (9650545925::bigint, 37),
         (12151464205::bigint, 38),
         (5395727304::bigint, 39),
         (5395727302::bigint, 40),
         (12151464204::bigint, 41),
         (5395727300::bigint, 42),
         (5393825158::bigint, 43),
         (1804502952::bigint, 44),
         (12150561835::bigint, 45),
         (1804601348::bigint, 46),
         (5426465582::bigint, 47),
         (9574100730::bigint, 48),
         (1605949296::bigint, 49),
         (11572819651::bigint, 50),
         (1605949225::bigint, 51),
         (11572819650::bigint, 52),
         (11572819649::bigint, 53),
         (11572819648::bigint, 54),
         (11572819647::bigint, 55),
         (11572819646::bigint, 56),
         (11572819645::bigint, 57),
         (11572819644::bigint, 58),
         (11568883393::bigint, 59),
         (5379591769::bigint, 60),
         (11572819643::bigint, 61),
         (9580867795::bigint, 62),
         (11568883402::bigint, 63)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 17132593) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 17137100);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (11568883397::bigint, 1),
         (11568883396::bigint, 2),
         (11576335876::bigint, 3),
         (11576335875::bigint, 4),
         (11576335874::bigint, 5),
         (9707992257::bigint, 6),
         (11568883388::bigint, 7),
         (9569922716::bigint, 8),
         (11568883386::bigint, 9),
         (5401746653::bigint, 10),
         (12144077505::bigint, 11),
         (12112457212::bigint, 12),
         (12120184002::bigint, 13),
         (12146079715::bigint, 14),
         (12150561838::bigint, 15),
         (12150561837::bigint, 16),
         (1589504365::bigint, 17),
         (12150561836::bigint, 18),
         (12234899800::bigint, 19),
         (9650545925::bigint, 20),
         (11568883385::bigint, 21),
         (11576335873::bigint, 22),
         (3054594665::bigint, 23),
         (11568883383::bigint, 24),
         (11576335872::bigint, 25),
         (11568883382::bigint, 26),
         (11568883381::bigint, 27),
         (11568883380::bigint, 28),
         (10103521481::bigint, 29),
         (11576335870::bigint, 30),
         (2037049616::bigint, 31),
         (11576335869::bigint, 32),
         (11580325118::bigint, 33),
         (5432400543::bigint, 34),
         (11499913968::bigint, 35),
         (11580325121::bigint, 36),
         (11576284067::bigint, 37),
         (11580325122::bigint, 38),
         (2560847634::bigint, 39),
         (11576284066::bigint, 40),
         (11502929853::bigint, 41),
         (11572819668::bigint, 42),
         (11576284065::bigint, 43),
         (2680328524::bigint, 44),
         (11576284064::bigint, 45),
         (11572838469::bigint, 46),
         (11568879567::bigint, 47),
         (11568879566::bigint, 48),
         (11572838470::bigint, 49),
         (11568879565::bigint, 50),
         (11568879564::bigint, 51)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 17137100) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 17142462);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (11502929845::bigint, 1),
         (11572838471::bigint, 2),
         (11572838470::bigint, 3),
         (11568879566::bigint, 4),
         (11568879567::bigint, 5),
         (11580325127::bigint, 6),
         (11576284064::bigint, 7),
         (2680328524::bigint, 8),
         (11576284065::bigint, 9),
         (11572819668::bigint, 10),
         (11568883369::bigint, 11),
         (1210007511::bigint, 12),
         (11580325126::bigint, 13),
         (11580325123::bigint, 14),
         (11580325122::bigint, 15),
         (11576284067::bigint, 16),
         (11580325121::bigint, 17),
         (11502929857::bigint, 18),
         (11580325120::bigint, 19),
         (11576284068::bigint, 20),
         (11502929858::bigint, 21),
         (11499855681::bigint, 22),
         (11580325117::bigint, 23),
         (10103521481::bigint, 24),
         (11703735607::bigint, 25),
         (11700999643::bigint, 26),
         (11748061227::bigint, 27),
         (12151464203::bigint, 28),
         (11741845582::bigint, 29),
         (12150561833::bigint, 30),
         (12150561834::bigint, 31),
         (12150561832::bigint, 32),
         (11572819655::bigint, 33),
         (11580325114::bigint, 34),
         (11572819654::bigint, 35),
         (9569868044::bigint, 36),
         (11572819653::bigint, 37),
         (11626627900::bigint, 38),
         (11572819652::bigint, 39),
         (9630447877::bigint, 40),
         (1541569015::bigint, 41),
         (9650545925::bigint, 42),
         (12151464205::bigint, 43),
         (5395727304::bigint, 44),
         (5395727302::bigint, 45),
         (12151464204::bigint, 46),
         (5395727300::bigint, 47),
         (5393825158::bigint, 48),
         (1804502952::bigint, 49),
         (12150561835::bigint, 50),
         (1804601348::bigint, 51),
         (5426465582::bigint, 52),
         (9574100730::bigint, 53),
         (1605949296::bigint, 54),
         (11572819651::bigint, 55),
         (1605949225::bigint, 56),
         (11572819650::bigint, 57),
         (11572819649::bigint, 58),
         (11580325113::bigint, 59),
         (2286203409::bigint, 60),
         (11580325112::bigint, 61)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 17142462) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 17152397);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (3042176957::bigint, 1),
         (2815692064::bigint, 2),
         (11590192509::bigint, 3),
         (11586752729::bigint, 4),
         (11586752728::bigint, 5),
         (11586752723::bigint, 6),
         (11586752355::bigint, 7),
         (11586752354::bigint, 8),
         (11568883392::bigint, 9),
         (2315898138::bigint, 10),
         (2315898140::bigint, 11),
         (2274623288::bigint, 12),
         (11505989072::bigint, 13),
         (11505989075::bigint, 14),
         (11505989074::bigint, 15),
         (12146079716::bigint, 16),
         (12112457212::bigint, 17),
         (12120184002::bigint, 18),
         (12146079715::bigint, 19),
         (12146079714::bigint, 20),
         (5393038581::bigint, 21),
         (5340694064::bigint, 22),
         (5395727300::bigint, 23),
         (1589504388::bigint, 24),
         (5401078638::bigint, 25),
         (11586752350::bigint, 26),
         (10788568329::bigint, 27),
         (11586752349::bigint, 28),
         (11586752347::bigint, 29),
         (11586752348::bigint, 30),
         (11586752346::bigint, 31),
         (11741246871::bigint, 32),
         (11586752345::bigint, 33),
         (11741246870::bigint, 34),
         (11586752344::bigint, 35),
         (11586752343::bigint, 36),
         (11586752342::bigint, 37),
         (11741246869::bigint, 38),
         (11734233720::bigint, 39),
         (11586752341::bigint, 40),
         (11734233721::bigint, 41),
         (11750809203::bigint, 42),
         (11750809191::bigint, 43),
         (11750809202::bigint, 44),
         (11748061232::bigint, 45),
         (11586752339::bigint, 46),
         (11748061233::bigint, 47),
         (11748061234::bigint, 48),
         (11502929851::bigint, 49),
         (11502929850::bigint, 50),
         (11499913965::bigint, 51),
         (11502929849::bigint, 52),
         (11502929848::bigint, 53),
         (5432259053::bigint, 54),
         (11502929847::bigint, 55),
         (11502929846::bigint, 56),
         (11502929845::bigint, 57)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 17152397) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 17160581);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (11499913961::bigint, 1),
         (11499913962::bigint, 2),
         (11499913963::bigint, 3),
         (5432259053::bigint, 4),
         (11502929848::bigint, 5),
         (11499913964::bigint, 6),
         (11499913965::bigint, 7),
         (11586752338::bigint, 8),
         (11748061233::bigint, 9),
         (11586752339::bigint, 10),
         (11748061232::bigint, 11),
         (11750809202::bigint, 12),
         (11750809191::bigint, 13),
         (11750809203::bigint, 14),
         (11734233721::bigint, 15),
         (11586752341::bigint, 16),
         (11734233720::bigint, 17),
         (11590192524::bigint, 18),
         (11590192523::bigint, 19),
         (11590192522::bigint, 20),
         (1203082810::bigint, 21),
         (11741845584::bigint, 22),
         (11590192521::bigint, 23),
         (11590192520::bigint, 24),
         (11590192519::bigint, 25),
         (11590192518::bigint, 26),
         (11590192517::bigint, 27),
         (11590192516::bigint, 28),
         (11590192515::bigint, 29),
         (11750237012::bigint, 30),
         (10788568330::bigint, 31),
         (10055961687::bigint, 32),
         (1804502956::bigint, 33),
         (1804502955::bigint, 34),
         (5393825158::bigint, 35),
         (1804502952::bigint, 36),
         (12155249141::bigint, 37),
         (12144077505::bigint, 38),
         (12146079713::bigint, 39),
         (11594616779::bigint, 40),
         (5423025709::bigint, 41),
         (11602247216::bigint, 42),
         (11508368331::bigint, 43),
         (2274623288::bigint, 44),
         (11505989076::bigint, 45),
         (11508368329::bigint, 46),
         (2315898140::bigint, 47),
         (11572819645::bigint, 48),
         (11572819644::bigint, 49),
         (11568883393::bigint, 50),
         (5379591769::bigint, 51),
         (11572819643::bigint, 52),
         (9580867795::bigint, 53),
         (11568883402::bigint, 54),
         (11590192510::bigint, 55),
         (11586752729::bigint, 56),
         (11590192509::bigint, 57),
         (2815692064::bigint, 58),
         (3042176957::bigint, 59)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 17160581) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 17220775);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (11499913960::bigint, 1),
         (11622193195::bigint, 2),
         (11622193194::bigint, 3),
         (11622193193::bigint, 4),
         (11568879567::bigint, 5),
         (11580325127::bigint, 6),
         (11576284064::bigint, 7),
         (2680328524::bigint, 8),
         (11626627888::bigint, 9),
         (2680328508::bigint, 10),
         (11655881340::bigint, 11),
         (11652450384::bigint, 12),
         (11622193190::bigint, 13),
         (11652450385::bigint, 14),
         (10119893798::bigint, 15),
         (2398804688::bigint, 16),
         (2673402389::bigint, 17),
         (11626627891::bigint, 18),
         (11622193187::bigint, 19),
         (11622193186::bigint, 20),
         (11750237050::bigint, 21),
         (9630273766::bigint, 22),
         (11622193185::bigint, 23),
         (11750237049::bigint, 24),
         (11648852788::bigint, 25),
         (11750237048::bigint, 26),
         (3054594660::bigint, 27),
         (3054594661::bigint, 28),
         (11499855690::bigint, 29),
         (3054594662::bigint, 30),
         (11499855691::bigint, 31),
         (3054594663::bigint, 32),
         (3054594664::bigint, 33),
         (3054594665::bigint, 34),
         (11622193184::bigint, 35),
         (9654655365::bigint, 36),
         (11622193183::bigint, 37),
         (11499855693::bigint, 38),
         (10788568329::bigint, 39),
         (11590192515::bigint, 40),
         (11750237012::bigint, 41),
         (10788568330::bigint, 42),
         (10055961687::bigint, 43),
         (1804502956::bigint, 44),
         (1804502955::bigint, 45),
         (5393825158::bigint, 46),
         (1804502952::bigint, 47),
         (12150561835::bigint, 48),
         (1804601348::bigint, 49),
         (5389795608::bigint, 50),
         (10788568331::bigint, 51),
         (11648852785::bigint, 52),
         (11648852784::bigint, 53),
         (11655881339::bigint, 54),
         (9693510645::bigint, 55),
         (11622193181::bigint, 56),
         (11622193180::bigint, 57),
         (11622193179::bigint, 58),
         (11724812660::bigint, 59),
         (11622193178::bigint, 60),
         (11626627906::bigint, 61),
         (11622193177::bigint, 62),
         (11626627907::bigint, 63),
         (11648852782::bigint, 64),
         (11640593140::bigint, 65),
         (11626627908::bigint, 66),
         (11629375276::bigint, 67),
         (11629375275::bigint, 68),
         (11629375274::bigint, 69),
         (11629375273::bigint, 70),
         (11629375272::bigint, 71),
         (11629375271::bigint, 72),
         (11629375270::bigint, 73),
         (10880100961::bigint, 74)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 17220775) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 17236756);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (10880100961::bigint, 1),
         (11594616798::bigint, 2),
         (11594616797::bigint, 3),
         (11622193174::bigint, 4),
         (11602247232::bigint, 5),
         (2703455233::bigint, 6),
         (11594616795::bigint, 7),
         (11591414390::bigint, 8),
         (11594616794::bigint, 9),
         (11640593143::bigint, 10),
         (11591414392::bigint, 11),
         (1212726589::bigint, 12),
         (11594616792::bigint, 13),
         (11594616791::bigint, 14),
         (11594616790::bigint, 15),
         (2398666781::bigint, 16),
         (11616172977::bigint, 17),
         (11640593142::bigint, 18),
         (11652450387::bigint, 19),
         (11640593140::bigint, 20),
         (11648852782::bigint, 21),
         (11626627907::bigint, 22),
         (11622193177::bigint, 23),
         (11640593139::bigint, 24),
         (11626627906::bigint, 25),
         (11622193178::bigint, 26),
         (11724812660::bigint, 27),
         (11626627905::bigint, 28),
         (11626627904::bigint, 29),
         (11626627903::bigint, 30),
         (11626627902::bigint, 31),
         (5426465582::bigint, 32),
         (9574100730::bigint, 33),
         (1605949296::bigint, 34),
         (11568883386::bigint, 35),
         (5401746653::bigint, 36),
         (12144077505::bigint, 37),
         (12112457212::bigint, 38),
         (12120184002::bigint, 39),
         (12146079715::bigint, 40),
         (12146079714::bigint, 41),
         (5393038581::bigint, 42),
         (5340694064::bigint, 43),
         (5395727300::bigint, 44),
         (1589504388::bigint, 45),
         (5401078638::bigint, 46),
         (11586752350::bigint, 47),
         (9610020118::bigint, 48),
         (11626627901::bigint, 49),
         (11626627900::bigint, 50),
         (9608017372::bigint, 51),
         (9592863285::bigint, 52),
         (3481605614::bigint, 53),
         (3077546540::bigint, 54),
         (3077546539::bigint, 55),
         (11626627897::bigint, 56),
         (11716558594::bigint, 57),
         (9630273766::bigint, 58),
         (11626627895::bigint, 59),
         (11750237011::bigint, 60),
         (11626627894::bigint, 61),
         (11626627893::bigint, 62),
         (11626627892::bigint, 63),
         (11626627891::bigint, 64),
         (2673402389::bigint, 65),
         (2398804688::bigint, 66),
         (10119893798::bigint, 67),
         (11652450385::bigint, 68),
         (11622193190::bigint, 69),
         (11652450384::bigint, 70),
         (11655881340::bigint, 71),
         (2680328508::bigint, 72),
         (11626627888::bigint, 73),
         (2680328524::bigint, 74),
         (11576284064::bigint, 75),
         (11572838469::bigint, 76),
         (11568879567::bigint, 77),
         (1217510893::bigint, 78),
         (11508368353::bigint, 79)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 17236756) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 17363578);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (11745381435::bigint, 1),
         (11750237059::bigint, 2),
         (11745381434::bigint, 3),
         (11745381433::bigint, 4),
         (11745381427::bigint, 5),
         (11745381384::bigint, 6),
         (11745381426::bigint, 7),
         (11745381425::bigint, 8),
         (11745381424::bigint, 9),
         (11750237058::bigint, 10),
         (11750237057::bigint, 11),
         (11745381423::bigint, 12),
         (11745381388::bigint, 13),
         (11745381422::bigint, 14),
         (11745381421::bigint, 15),
         (11745381420::bigint, 16),
         (11745381419::bigint, 17),
         (11745843184::bigint, 18),
         (11745381418::bigint, 19),
         (11745381417::bigint, 20),
         (11745381390::bigint, 21),
         (11745381416::bigint, 22),
         (11745381415::bigint, 23),
         (11750237006::bigint, 24),
         (11745381414::bigint, 25),
         (2900059988::bigint, 26),
         (11745381412::bigint, 27),
         (11745381394::bigint, 28),
         (11745381411::bigint, 29),
         (11745381395::bigint, 30),
         (11745381410::bigint, 31),
         (11745381409::bigint, 32),
         (11745381408::bigint, 33),
         (11745381406::bigint, 34),
         (11745381405::bigint, 35),
         (11508368351::bigint, 36),
         (10013893080::bigint, 37),
         (9622477371::bigint, 38),
         (11745381404::bigint, 39),
         (9428070121::bigint, 40),
         (2380076720::bigint, 41),
         (11750717866::bigint, 42),
         (11508368335::bigint, 43),
         (5389795618::bigint, 44),
         (11681428580::bigint, 45),
         (9641559167::bigint, 46),
         (10096123274::bigint, 47),
         (4116855112::bigint, 48),
         (10695768689::bigint, 49),
         (11681428579::bigint, 50),
         (5393038589::bigint, 51),
         (9588873700::bigint, 52),
         (5393038587::bigint, 53),
         (9923697695::bigint, 54),
         (9923702850::bigint, 55),
         (5393038585::bigint, 56),
         (5294340532::bigint, 57),
         (12146079715::bigint, 58),
         (12146079714::bigint, 59),
         (1804502952::bigint, 60),
         (12155249141::bigint, 61),
         (12144077505::bigint, 62),
         (12112457212::bigint, 63)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 17363578) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 17363998);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (11745843192::bigint, 1),
         (11745843008::bigint, 2),
         (11745843190::bigint, 3),
         (11745843189::bigint, 4),
         (11745843191::bigint, 5),
         (11745843044::bigint, 6),
         (11745843011::bigint, 7),
         (11745843188::bigint, 8),
         (11745843187::bigint, 9),
         (11745843186::bigint, 10),
         (11745843185::bigint, 11),
         (11745843184::bigint, 12),
         (11745381418::bigint, 13),
         (11745843183::bigint, 14),
         (11663408371::bigint, 15),
         (11745843182::bigint, 16),
         (11745843017::bigint, 17),
         (11745843181::bigint, 18),
         (11745843180::bigint, 19),
         (11745843179::bigint, 20),
         (11745843178::bigint, 21),
         (5423025888::bigint, 22),
         (11745843176::bigint, 23),
         (11745843175::bigint, 24),
         (11750809200::bigint, 25),
         (11745843173::bigint, 26),
         (11745843172::bigint, 27),
         (9632222794::bigint, 28),
         (5423025887::bigint, 29),
         (5423025881::bigint, 30),
         (11745843170::bigint, 31),
         (5393038595::bigint, 32),
         (11745843029::bigint, 33),
         (11745843169::bigint, 34),
         (11745843068::bigint, 35),
         (11745843067::bigint, 36),
         (11745843031::bigint, 37),
         (11745843056::bigint, 38),
         (11745843032::bigint, 39),
         (11745843055::bigint, 40),
         (11745843054::bigint, 41),
         (11745843052::bigint, 42),
         (11745843051::bigint, 43),
         (5393038591::bigint, 44),
         (11748231673::bigint, 45),
         (11745843048::bigint, 46),
         (11745843047::bigint, 47),
         (11745843039::bigint, 48),
         (11745843046::bigint, 49),
         (10126914527::bigint, 50),
         (10013893080::bigint, 51),
         (9622477371::bigint, 52),
         (11745381404::bigint, 53),
         (9428070121::bigint, 54),
         (2380076720::bigint, 55),
         (11750717866::bigint, 56),
         (11508368335::bigint, 57),
         (5389795618::bigint, 58),
         (11681428580::bigint, 59),
         (9641559167::bigint, 60),
         (10096123274::bigint, 61),
         (4116855112::bigint, 62),
         (10695768689::bigint, 63),
         (11681428579::bigint, 64),
         (5393038589::bigint, 65),
         (9588873700::bigint, 66),
         (5393038587::bigint, 67),
         (9923697695::bigint, 68),
         (9923702850::bigint, 69),
         (5393038585::bigint, 70),
         (5294340532::bigint, 71),
         (12146079715::bigint, 72),
         (12146079714::bigint, 73),
         (1804502952::bigint, 74),
         (12155249141::bigint, 75),
         (12144077505::bigint, 76),
         (12112457212::bigint, 77)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 17363998) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 17367373);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (3238657397::bigint, 1),
         (11749241726::bigint, 2),
         (11749241727::bigint, 3),
         (10837232580::bigint, 4),
         (11748061249::bigint, 5),
         (11748061248::bigint, 6),
         (11748727257::bigint, 7),
         (11748061247::bigint, 8),
         (11750237066::bigint, 9),
         (11748061246::bigint, 10),
         (11748727256::bigint, 11),
         (11748061221::bigint, 12),
         (11750717861::bigint, 13),
         (11748727255::bigint, 14),
         (11749241729::bigint, 15),
         (11749241730::bigint, 16),
         (11748727254::bigint, 17),
         (11748727253::bigint, 18),
         (11748727252::bigint, 19),
         (11748727251::bigint, 20),
         (11750809186::bigint, 21),
         (11748727250::bigint, 22),
         (11748727249::bigint, 23),
         (11749241735::bigint, 24),
         (11748727248::bigint, 25),
         (11748727247::bigint, 26),
         (11700999668::bigint, 27),
         (11700999667::bigint, 28),
         (11703735585::bigint, 29),
         (11700999666::bigint, 30),
         (11700999665::bigint, 31),
         (11748727246::bigint, 32),
         (11748727245::bigint, 33),
         (11748727244::bigint, 34),
         (11748727243::bigint, 35),
         (11748727242::bigint, 36),
         (11748727241::bigint, 37),
         (11734233736::bigint, 38),
         (11734233735::bigint, 39),
         (11734233737::bigint, 40),
         (11731162790::bigint, 41),
         (11734233734::bigint, 42),
         (11745080351::bigint, 43),
         (11742296365::bigint, 44),
         (11745080350::bigint, 45),
         (11742296366::bigint, 46),
         (11745080349::bigint, 47),
         (11745080348::bigint, 48),
         (11742296367::bigint, 49),
         (11745080347::bigint, 50),
         (11745080346::bigint, 51),
         (11745080345::bigint, 52),
         (11748727235::bigint, 53),
         (11745080344::bigint, 54),
         (11748727240::bigint, 55),
         (11724812643::bigint, 56),
         (11741246881::bigint, 57),
         (11741246880::bigint, 58),
         (11748727239::bigint, 59),
         (11748727238::bigint, 60),
         (11748727237::bigint, 61),
         (11748727236::bigint, 62),
         (11748727233::bigint, 63),
         (3312911975::bigint, 64),
         (11731162785::bigint, 65),
         (11731162771::bigint, 66),
         (11731162784::bigint, 67),
         (11731162783::bigint, 68),
         (11748727232::bigint, 69),
         (11731162782::bigint, 70),
         (11731162781::bigint, 71),
         (11731162780::bigint, 72),
         (11731162779::bigint, 73),
         (11734233749::bigint, 74),
         (11731162774::bigint, 75),
         (11734233750::bigint, 76),
         (11731162773::bigint, 77),
         (11734233751::bigint, 78),
         (11749241743::bigint, 79),
         (11734233752::bigint, 80),
         (11731162772::bigint, 81)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 17367373) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 17368281);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (11734233753::bigint, 1),
         (11734233752::bigint, 2),
         (11749241743::bigint, 3),
         (11734233751::bigint, 4),
         (11731162773::bigint, 5),
         (11734233750::bigint, 6),
         (11731162774::bigint, 7),
         (11734233749::bigint, 8),
         (11731162779::bigint, 9),
         (11734233748::bigint, 10),
         (11734233747::bigint, 11),
         (11734233746::bigint, 12),
         (11734233745::bigint, 13),
         (11734233744::bigint, 14),
         (11734233743::bigint, 15),
         (11734233742::bigint, 16),
         (11734233741::bigint, 17),
         (3312911975::bigint, 18),
         (1226685444::bigint, 19),
         (11734233739::bigint, 20),
         (11734233738::bigint, 21),
         (11734233712::bigint, 22),
         (11748727241::bigint, 23),
         (11731162788::bigint, 24),
         (11734233736::bigint, 25),
         (11734233735::bigint, 26),
         (11734233734::bigint, 27),
         (11734233733::bigint, 28),
         (11734233732::bigint, 29),
         (11734233731::bigint, 30),
         (11703735594::bigint, 31),
         (11700999659::bigint, 32),
         (11703735593::bigint, 33),
         (11703735592::bigint, 34),
         (11749241739::bigint, 35),
         (11749241738::bigint, 36),
         (11749241737::bigint, 37),
         (11749241736::bigint, 38),
         (11703735587::bigint, 39),
         (11703735586::bigint, 40),
         (11700999666::bigint, 41),
         (11703735585::bigint, 42),
         (11700999667::bigint, 43),
         (11703735584::bigint, 44),
         (11703735583::bigint, 45),
         (11748727248::bigint, 46),
         (11749241735::bigint, 47),
         (11748727249::bigint, 48),
         (11749241734::bigint, 49),
         (11749241733::bigint, 50),
         (11750809185::bigint, 51),
         (11749241732::bigint, 52),
         (11749241731::bigint, 53),
         (11748727254::bigint, 54),
         (11749241730::bigint, 55),
         (11749241729::bigint, 56),
         (11750717864::bigint, 57),
         (11748061221::bigint, 58),
         (11748061220::bigint, 59),
         (11748061219::bigint, 60),
         (11749241728::bigint, 61),
         (3359003184::bigint, 62),
         (11748061249::bigint, 63),
         (10776228012::bigint, 64),
         (1225778827::bigint, 65),
         (11748061216::bigint, 66),
         (11748061217::bigint, 67)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 17368281) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 17368288);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (11745381435::bigint, 1),
         (11750237059::bigint, 2),
         (11745381434::bigint, 3),
         (11749262548::bigint, 4),
         (11749262547::bigint, 5),
         (11750237063::bigint, 6),
         (11749262546::bigint, 7),
         (5423025888::bigint, 8),
         (11745843176::bigint, 9),
         (9632222794::bigint, 10),
         (5423025887::bigint, 11),
         (5423025881::bigint, 12),
         (11745843170::bigint, 13),
         (5393038595::bigint, 14),
         (11748231675::bigint, 15),
         (11748231674::bigint, 16),
         (2886285981::bigint, 17),
         (5393038591::bigint, 18),
         (11748231673::bigint, 19),
         (11745843048::bigint, 20),
         (11745843047::bigint, 21),
         (11745843039::bigint, 22),
         (11745843046::bigint, 23),
         (10126914527::bigint, 24),
         (10013893080::bigint, 25),
         (9622477371::bigint, 26),
         (11745381404::bigint, 27),
         (9428070121::bigint, 28),
         (2380076720::bigint, 29),
         (11750717866::bigint, 30),
         (11508368335::bigint, 31),
         (5389795618::bigint, 32),
         (11681428580::bigint, 33),
         (9641559167::bigint, 34),
         (10096123274::bigint, 35),
         (4116855112::bigint, 36),
         (10695768689::bigint, 37),
         (11681428579::bigint, 38),
         (5393038589::bigint, 39),
         (9588873700::bigint, 40),
         (5393038587::bigint, 41),
         (9923697695::bigint, 42),
         (9923702850::bigint, 43),
         (5393038585::bigint, 44),
         (5294340532::bigint, 45),
         (12146079715::bigint, 46),
         (12146079714::bigint, 47),
         (1804502952::bigint, 48),
         (12155249141::bigint, 49),
         (12144077507::bigint, 50),
         (12261001799::bigint, 51),
         (5423025718::bigint, 52),
         (12261001798::bigint, 53),
         (11499855694::bigint, 54),
         (11681428578::bigint, 55),
         (2215342454::bigint, 56),
         (6154043773::bigint, 57),
         (5423025824::bigint, 58),
         (11703735601::bigint, 59),
         (2226214174::bigint, 60),
         (11703735600::bigint, 61),
         (11681428577::bigint, 62),
         (11681428576::bigint, 63),
         (5423025822::bigint, 64),
         (11703735599::bigint, 65),
         (11681428575::bigint, 66),
         (6154084691::bigint, 67),
         (11703735598::bigint, 68),
         (11703735597::bigint, 69),
         (11703735596::bigint, 70),
         (11703735595::bigint, 71),
         (11734233731::bigint, 72),
         (11703735594::bigint, 73),
         (11700999659::bigint, 74),
         (11703735593::bigint, 75),
         (11703735592::bigint, 76),
         (11703735591::bigint, 77),
         (11700999663::bigint, 78),
         (11703735589::bigint, 79),
         (11748061224::bigint, 80),
         (11750717865::bigint, 81),
         (11748061223::bigint, 82),
         (11750809186::bigint, 83),
         (11750809185::bigint, 84),
         (11749262544::bigint, 85),
         (11750717864::bigint, 86),
         (11748061221::bigint, 87),
         (11748061220::bigint, 88),
         (11748061219::bigint, 89),
         (11748061218::bigint, 90),
         (3238657397::bigint, 91),
         (11749241726::bigint, 92),
         (11749241727::bigint, 93),
         (10837232580::bigint, 94)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 17368288) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 17369420);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (10880100961::bigint, 1),
         (11750237029::bigint, 2),
         (11626627914::bigint, 3),
         (11750237028::bigint, 4),
         (11626627913::bigint, 5),
         (11750237027::bigint, 6),
         (11626627912::bigint, 7),
         (11629375272::bigint, 8),
         (11750237026::bigint, 9),
         (2503475485::bigint, 10),
         (11750237025::bigint, 11),
         (11652450388::bigint, 12),
         (11594616789::bigint, 13),
         (11594616788::bigint, 14),
         (11602247231::bigint, 15),
         (11750237024::bigint, 16),
         (11591414398::bigint, 17),
         (11750237023::bigint, 18),
         (11750237022::bigint, 19),
         (11750237021::bigint, 20),
         (11750237016::bigint, 21),
         (11616172969::bigint, 22),
         (11616169068::bigint, 23),
         (11750237015::bigint, 24),
         (11750237014::bigint, 25),
         (11750237013::bigint, 26),
         (11750237012::bigint, 27),
         (11586752350::bigint, 28),
         (9610020118::bigint, 29),
         (11626627901::bigint, 30),
         (11626627900::bigint, 31),
         (9608017372::bigint, 32),
         (9592863285::bigint, 33),
         (3481605614::bigint, 34),
         (3077546540::bigint, 35),
         (3077546539::bigint, 36),
         (11626627897::bigint, 37),
         (11716558594::bigint, 38),
         (9630273766::bigint, 39),
         (11626627895::bigint, 40),
         (11750237011::bigint, 41),
         (11745381405::bigint, 42),
         (11745381400::bigint, 43),
         (11750237010::bigint, 44),
         (11745381399::bigint, 45),
         (11750237009::bigint, 46),
         (11745381398::bigint, 47),
         (11750237008::bigint, 48),
         (11745381397::bigint, 49),
         (11745381396::bigint, 50),
         (11745381395::bigint, 51),
         (11745381411::bigint, 52),
         (11745381394::bigint, 53),
         (2900059988::bigint, 54),
         (11745381392::bigint, 55),
         (11750237006::bigint, 56),
         (11745381391::bigint, 57),
         (11745381390::bigint, 58),
         (11745381417::bigint, 59),
         (11745381389::bigint, 60),
         (11750237055::bigint, 61),
         (11750237005::bigint, 62),
         (11745381387::bigint, 63),
         (11750237004::bigint, 64),
         (11745381386::bigint, 65),
         (11745381385::bigint, 66),
         (11750237003::bigint, 67),
         (11745381384::bigint, 68),
         (11750237002::bigint, 69),
         (11745381383::bigint, 70),
         (11745381382::bigint, 71),
         (11750237059::bigint, 72),
         (11745381435::bigint, 73)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 17369420) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 17369421);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (11745381435::bigint, 1),
         (11750237059::bigint, 2),
         (11745381434::bigint, 3),
         (11745381433::bigint, 4),
         (11745381427::bigint, 5),
         (11745381384::bigint, 6),
         (11745381426::bigint, 7),
         (11745381425::bigint, 8),
         (11745381424::bigint, 9),
         (11750237058::bigint, 10),
         (11750237057::bigint, 11),
         (11745381423::bigint, 12),
         (11745381388::bigint, 13),
         (11750237055::bigint, 14),
         (11750237052::bigint, 15),
         (11745381417::bigint, 16),
         (11745381390::bigint, 17),
         (11745381416::bigint, 18),
         (11745381415::bigint, 19),
         (11750237006::bigint, 20),
         (11745381414::bigint, 21),
         (2900059988::bigint, 22),
         (11745381412::bigint, 23),
         (11745381394::bigint, 24),
         (11745381411::bigint, 25),
         (11745381395::bigint, 26),
         (11745381410::bigint, 27),
         (11745381409::bigint, 28),
         (11745381408::bigint, 29),
         (11745381406::bigint, 30),
         (11745381405::bigint, 31),
         (11508368351::bigint, 32),
         (11750237051::bigint, 33),
         (11750237050::bigint, 34),
         (9630273766::bigint, 35),
         (11622193185::bigint, 36),
         (11750237049::bigint, 37),
         (11648852788::bigint, 38),
         (11750237048::bigint, 39),
         (3054594660::bigint, 40),
         (3054594661::bigint, 41),
         (11499855690::bigint, 42),
         (3054594662::bigint, 43),
         (11499855691::bigint, 44),
         (3054594663::bigint, 45),
         (3054594664::bigint, 46),
         (3054594665::bigint, 47),
         (11622193184::bigint, 48),
         (9654655365::bigint, 49),
         (11622193183::bigint, 50),
         (11499855693::bigint, 51),
         (10788568329::bigint, 52),
         (11590192515::bigint, 53),
         (11750237045::bigint, 54),
         (11750237044::bigint, 55),
         (11750237043::bigint, 56),
         (5438692442::bigint, 57),
         (11750237042::bigint, 58),
         (11750237041::bigint, 59),
         (11750237036::bigint, 60),
         (11750237035::bigint, 61),
         (11591414397::bigint, 62),
         (11591414396::bigint, 63),
         (11591414395::bigint, 64),
         (11750237034::bigint, 65),
         (11591414394::bigint, 66),
         (11596427201::bigint, 67),
         (11591414393::bigint, 68),
         (1212726589::bigint, 69),
         (11591414392::bigint, 70),
         (11640593143::bigint, 71),
         (11591414391::bigint, 72),
         (11591414390::bigint, 73),
         (11594616795::bigint, 74),
         (2703511768::bigint, 75),
         (2703455233::bigint, 76),
         (11602247232::bigint, 77),
         (11622193174::bigint, 78),
         (11750809189::bigint, 79),
         (11594616797::bigint, 80),
         (11591414387::bigint, 81),
         (10880100961::bigint, 82)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 17369421) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 17369422);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (10837232580::bigint, 1),
         (11748061249::bigint, 2),
         (11748061248::bigint, 3),
         (11748727257::bigint, 4),
         (11748061247::bigint, 5),
         (11750237066::bigint, 6),
         (11748061246::bigint, 7),
         (11748727256::bigint, 8),
         (11748061221::bigint, 9),
         (11750717861::bigint, 10),
         (11748727255::bigint, 11),
         (11749241729::bigint, 12),
         (11750809207::bigint, 13),
         (11748061243::bigint, 14),
         (11748061242::bigint, 15),
         (11750717860::bigint, 16),
         (11748061241::bigint, 17),
         (355039799::bigint, 18),
         (1224283140::bigint, 19),
         (11700999663::bigint, 20),
         (11750717859::bigint, 21),
         (11700999662::bigint, 22),
         (11700999661::bigint, 23),
         (11750809206::bigint, 24),
         (11700999660::bigint, 25),
         (11703735593::bigint, 26),
         (11700999659::bigint, 27),
         (11703735594::bigint, 28),
         (2724209578::bigint, 29),
         (10742437458::bigint, 30),
         (11690806169::bigint, 31),
         (11700999657::bigint, 32),
         (11690772568::bigint, 33),
         (11750237065::bigint, 34),
         (11700999656::bigint, 35),
         (11681428575::bigint, 36),
         (11700999655::bigint, 37),
         (11690772566::bigint, 38),
         (11700999654::bigint, 39),
         (11690772565::bigint, 40),
         (11700999653::bigint, 41),
         (11690772564::bigint, 42),
         (11700999652::bigint, 43),
         (11748231703::bigint, 44),
         (4917303821::bigint, 45),
         (11700999651::bigint, 46),
         (11502937469::bigint, 47),
         (11510859310::bigint, 48),
         (9574100730::bigint, 49),
         (11502929868::bigint, 50),
         (9574100733::bigint, 51),
         (12144077505::bigint, 52),
         (12112457212::bigint, 53),
         (12120184002::bigint, 54),
         (12146079715::bigint, 55),
         (10140159295::bigint, 56),
         (5349662692::bigint, 57),
         (11745843043::bigint, 58),
         (5337560205::bigint, 59),
         (9574158677::bigint, 60),
         (4116855114::bigint, 61),
         (11745843042::bigint, 62),
         (11745381403::bigint, 63),
         (10100951965::bigint, 64),
         (4116855112::bigint, 65),
         (5423025879::bigint, 66),
         (11745381402::bigint, 67),
         (11505958868::bigint, 68),
         (10100979100::bigint, 69),
         (11690772562::bigint, 70),
         (10100981309::bigint, 71),
         (10132364564::bigint, 72),
         (11505958856::bigint, 73),
         (9622477371::bigint, 74),
         (4595625753::bigint, 75),
         (11505958861::bigint, 76),
         (11745843041::bigint, 77),
         (11745843040::bigint, 78),
         (11745843039::bigint, 79),
         (11745843038::bigint, 80),
         (11748231702::bigint, 81),
         (11745843036::bigint, 82),
         (11748231701::bigint, 83),
         (11748231700::bigint, 84),
         (11748231699::bigint, 85),
         (5423025881::bigint, 86),
         (11745843027::bigint, 87),
         (11750237064::bigint, 88),
         (5423025888::bigint, 89),
         (11745843023::bigint, 90),
         (11750809196::bigint, 91),
         (11750237061::bigint, 92),
         (11750237060::bigint, 93),
         (11750809198::bigint, 94),
         (11745381434::bigint, 95),
         (11745381435::bigint, 96)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 17369422) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 17370233);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (11750237059::bigint, 1),
         (11745381434::bigint, 2),
         (11749262548::bigint, 3),
         (11749262547::bigint, 4),
         (11750237063::bigint, 5),
         (11749262546::bigint, 6),
         (5423025888::bigint, 7),
         (11745843176::bigint, 8),
         (11745843175::bigint, 9),
         (11750809195::bigint, 10),
         (11745381416::bigint, 11),
         (11745381415::bigint, 12),
         (11750237006::bigint, 13),
         (11745381414::bigint, 14),
         (2900059988::bigint, 15),
         (11745381412::bigint, 16),
         (11745381394::bigint, 17),
         (11745381411::bigint, 18),
         (11745381395::bigint, 19),
         (11745381410::bigint, 20),
         (11745381409::bigint, 21),
         (11745381408::bigint, 22),
         (11745381406::bigint, 23),
         (11745381405::bigint, 24),
         (11505958852::bigint, 25),
         (11505958851::bigint, 26),
         (11505958850::bigint, 27),
         (11724812666::bigint, 28),
         (4603393591::bigint, 29),
         (5432236583::bigint, 30),
         (10772099263::bigint, 31),
         (11505958849::bigint, 32),
         (11508368353::bigint, 33),
         (11622193193::bigint, 34),
         (11568879567::bigint, 35),
         (11580325127::bigint, 36),
         (11750809192::bigint, 37),
         (11586752338::bigint, 38),
         (11748061233::bigint, 39),
         (11586752339::bigint, 40),
         (11748061232::bigint, 41),
         (11750809202::bigint, 42),
         (11750809191::bigint, 43),
         (11750809203::bigint, 44),
         (11734233721::bigint, 45),
         (11586752341::bigint, 46),
         (11734233720::bigint, 47),
         (2383938357::bigint, 48),
         (11734233719::bigint, 49),
         (11734233718::bigint, 50),
         (11750809190::bigint, 51),
         (11668801268::bigint, 52),
         (11664987763::bigint, 53),
         (11668814569::bigint, 54),
         (11664987762::bigint, 55),
         (11668814570::bigint, 56),
         (11664987761::bigint, 57),
         (11668814571::bigint, 58),
         (11664987760::bigint, 59),
         (11668814572::bigint, 60),
         (11664987759::bigint, 61),
         (11750809204::bigint, 62),
         (11750809189::bigint, 63),
         (11594616797::bigint, 64),
         (11622193174::bigint, 65),
         (11602247232::bigint, 66),
         (12113205579::bigint, 67),
         (11750237029::bigint, 68),
         (11626627914::bigint, 69),
         (11750237028::bigint, 70),
         (11626627913::bigint, 71),
         (11750237027::bigint, 72),
         (11626627912::bigint, 73),
         (11626627911::bigint, 74),
         (11626627910::bigint, 75),
         (11664987748::bigint, 76),
         (11648852781::bigint, 77),
         (11724812652::bigint, 78),
         (11724812651::bigint, 79),
         (11724812650::bigint, 80),
         (11716558615::bigint, 81),
         (11716558616::bigint, 82),
         (11724812648::bigint, 83),
         (11716558617::bigint, 84),
         (11741246876::bigint, 85),
         (11741246875::bigint, 86),
         (11741246874::bigint, 87),
         (11741246873::bigint, 88),
         (11734233731::bigint, 89),
         (11703735594::bigint, 90),
         (11700999659::bigint, 91),
         (11703735593::bigint, 92),
         (11703735592::bigint, 93),
         (11703735591::bigint, 94),
         (11700999663::bigint, 95),
         (11703735589::bigint, 96),
         (11748061224::bigint, 97),
         (11750717865::bigint, 98),
         (11748061223::bigint, 99),
         (11750809186::bigint, 100),
         (11750809185::bigint, 101),
         (11749262544::bigint, 102),
         (11750717864::bigint, 103),
         (11748061221::bigint, 104),
         (11748061220::bigint, 105),
         (11748061219::bigint, 106),
         (11748061218::bigint, 107),
         (3238657397::bigint, 108)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 17370233) rv
on conflict (route_variant_id, stop_order) do nothing;
delete from public.route_stops
 where route_variant_id = (select id from public.route_variants where osm_relation_id = 17370234);
insert into public.route_stops (route_variant_id, stop_id, stop_order)
select rv.id, s.id, v.stop_order
  from (values
         (3238657395::bigint, 1),
         (11750717863::bigint, 2),
         (11750717862::bigint, 3),
         (11750237066::bigint, 4),
         (11748061246::bigint, 5),
         (11748727256::bigint, 6),
         (11748061221::bigint, 7),
         (11750717861::bigint, 8),
         (11748727255::bigint, 9),
         (11749241729::bigint, 10),
         (11750809207::bigint, 11),
         (11748061243::bigint, 12),
         (11748061242::bigint, 13),
         (11750717860::bigint, 14),
         (11748061241::bigint, 15),
         (355039799::bigint, 16),
         (1224283140::bigint, 17),
         (11700999663::bigint, 18),
         (11750717859::bigint, 19),
         (11700999662::bigint, 20),
         (11700999661::bigint, 21),
         (11750809206::bigint, 22),
         (11700999660::bigint, 23),
         (11703735593::bigint, 24),
         (11700999659::bigint, 25),
         (11703735594::bigint, 26),
         (2724209578::bigint, 27),
         (11703735595::bigint, 28),
         (11741845581::bigint, 29),
         (11741845580::bigint, 30),
         (11741845579::bigint, 31),
         (11741845578::bigint, 32),
         (11716558616::bigint, 33),
         (11716558615::bigint, 34),
         (11716558612::bigint, 35),
         (11716558611::bigint, 36),
         (11716558610::bigint, 37),
         (11645131358::bigint, 38),
         (11648852781::bigint, 39),
         (11750809205::bigint, 40),
         (11629375274::bigint, 41),
         (11629375273::bigint, 42),
         (11629375272::bigint, 43),
         (11629375271::bigint, 44),
         (11629375270::bigint, 45),
         (10880100961::bigint, 46),
         (11594616798::bigint, 47),
         (11594616797::bigint, 48),
         (11750809189::bigint, 49),
         (11750809204::bigint, 50),
         (11668814573::bigint, 51),
         (11668814572::bigint, 52),
         (11664987760::bigint, 53),
         (11668814571::bigint, 54),
         (11664987761::bigint, 55),
         (11668814570::bigint, 56),
         (11664987762::bigint, 57),
         (11668814569::bigint, 58),
         (11664987763::bigint, 59),
         (11668801268::bigint, 60),
         (11750809190::bigint, 61),
         (11731162799::bigint, 62),
         (11731162798::bigint, 63),
         (2383938357::bigint, 64),
         (11734233720::bigint, 65),
         (11586752341::bigint, 66),
         (11734233721::bigint, 67),
         (11750809203::bigint, 68),
         (11750809191::bigint, 69),
         (11750809202::bigint, 70),
         (11748061232::bigint, 71),
         (11586752339::bigint, 72),
         (11748061233::bigint, 73),
         (11748061234::bigint, 74),
         (11502929851::bigint, 75),
         (11572838469::bigint, 76),
         (11568879567::bigint, 77),
         (1217510893::bigint, 78),
         (11716558593::bigint, 79),
         (11508368352::bigint, 80),
         (11563981252::bigint, 81),
         (11750809201::bigint, 82),
         (11563981251::bigint, 83),
         (11508368351::bigint, 84),
         (11745381405::bigint, 85),
         (11745381400::bigint, 86),
         (11750237010::bigint, 87),
         (11745381399::bigint, 88),
         (11750237009::bigint, 89),
         (11745381398::bigint, 90),
         (11750237008::bigint, 91),
         (11745381397::bigint, 92),
         (11745381396::bigint, 93),
         (11745381395::bigint, 94),
         (11745381411::bigint, 95),
         (11745381394::bigint, 96),
         (2900059988::bigint, 97),
         (11745381392::bigint, 98),
         (11750237006::bigint, 99),
         (11745381391::bigint, 100),
         (11745381390::bigint, 101),
         (11745381417::bigint, 102),
         (11750809200::bigint, 103),
         (11745843026::bigint, 104),
         (11745843025::bigint, 105),
         (5423025888::bigint, 106),
         (11745843023::bigint, 107),
         (11750809196::bigint, 108),
         (11750237061::bigint, 109),
         (11750237060::bigint, 110),
         (11750809198::bigint, 111),
         (11745381434::bigint, 112)
       ) as v(osm_node_id, stop_order)
  join public.stops s on s.osm_node_id = v.osm_node_id
  cross join (select id from public.route_variants where osm_relation_id = 17370234) rv
on conflict (route_variant_id, stop_order) do nothing;

-- ------------------------------------------------------------
-- 5. Baja de las paradas que ya no sirve ningún recorrido
-- ------------------------------------------------------------
update public.stops s
   set is_active = false
 where s.is_active
   and not exists (
       select 1 from public.route_stops rs
        where rs.stop_id = s.id);

-- ------------------------------------------------------------
-- 6. Baja de las líneas que se quedaron sin recorridos
-- ------------------------------------------------------------
update public.lines l
   set is_active = false
  from public.networks n
 where l.network_id = n.id
   and l.is_active
   and n.code in ('gran-resistencia', 'interurbano-chaco', 'interurbano-chaco-corrientes')
   and not exists (
       select 1 from public.route_variants rv
        where rv.line_id = l.id and rv.is_active);

commit;

-- ====================================================================
-- DIAGNÓSTICO DE LA IMPORTACIÓN (solo informativo)
-- ====================================================================
--
-- Relations descartadas (12):
--   · relation 6606030 sin ref — "Buenos Aires - Corrientes" (larga distancia o mapeo incompleto)
--   · relation 6614663 sin ref — "Corrientes - Concepción" (larga distancia o mapeo incompleto)
--   · relation 6614767 sin ref — "Concepción - Corrientes" (larga distancia o mapeo incompleto)
--   · relation 6614804 sin ref — "Caa Cati - Beron de Astrada - Corrientes" (larga distancia o mapeo incompleto)
--   · relation 6614839 sin ref — "Corrientes - Beron de Astrada - Caa Cati" (larga distancia o mapeo incompleto)
--   · relation 6614864 sin ref — "Corrientes - Paso de los Libres" (larga distancia o mapeo incompleto)
--   · relation 6614895 sin ref — "Paso de los Libres - Corrientes" (larga distancia o mapeo incompleto)
--   · relation 6616787 sin ref — "Corrientes - Mocoretá" (larga distancia o mapeo incompleto)
--   · relation 6616907 sin ref — "Mocoretá - Corrientes" (larga distancia o mapeo incompleto)
--   · relation 6618963 sin ref — "Corrientes - Monte Caseros" (larga distancia o mapeo incompleto)
--   · relation 6619034 sin ref — "Monte Caseros - Corrientes" (larga distancia o mapeo incompleto)
--   · relation 7966664 sin ref — "Chaco - Corrientes" (larga distancia o mapeo incompleto)
--
-- Advertencias de datos (6):
--   · relation 15540760: ref="207" no coincide con el nombre "206 Vuelta Resistencia - Barranqueras" → se usa 206 (el nombre es más confiable)
--   · 2638 asignaciones parada↔recorrido se INFIRIERON de la geometría (el trazado pasa a menos de 25 m y la deja a su derecha); OSM declaraba 3261. Es lo que arregla que la 110 y la 204 no figuraran en paradas de Avenida San Martín donde sí frenan
--   · 257 nodos de OSM eran una segunda representación de una parada ya existente (plataforma + posición de detención, o la misma parada mapeada dos veces) y se unificaron
--   · relation 14438359 (904A): sentido no declarado en OSM, se asignó ida por descarte
--   · relation 14438360 (904A): sentido no declarado en OSM, se asignó vuelta por descarte
--   · 1285 paradas sin nombre en OSM fueron bautizadas con la esquina más cercana del callejero
--
-- Trazados con saltos puenteados (16):
--   · 12A (relation 4764420): 1 salto(s) puenteados, el mayor de 120 m — conviene revisar el trazado en OSM
--   · 101 (relation 7948963): 1 salto(s) puenteados, el mayor de 120 m — conviene revisar el trazado en OSM
--   · 106A (relation 7962485): 1 salto(s) puenteados, el mayor de 120 m — conviene revisar el trazado en OSM
--   · 110 (relation 7986997): 1 salto(s) puenteados, el mayor de 120 m — conviene revisar el trazado en OSM
--   · 111 (relation 7997877): 1 salto(s) puenteados, el mayor de 120 m — conviene revisar el trazado en OSM
--   · 106A (relation 8004651): 1 salto(s) puenteados, el mayor de 600 m — conviene revisar el trazado en OSM
--   · 904A (relation 14438360): 1 salto(s) puenteados, el mayor de 120 m — conviene revisar el trazado en OSM
--   · 904B (relation 14442057): 1 salto(s) puenteados, el mayor de 369 m — conviene revisar el trazado en OSM
--   · 904C (relation 14447121): 1 salto(s) puenteados, el mayor de 120 m — conviene revisar el trazado en OSM
--   · 106B (relation 14465855): 1 salto(s) puenteados, el mayor de 120 m — conviene revisar el trazado en OSM
--   · 106C (relation 14468699): 1 salto(s) puenteados, el mayor de 120 m — conviene revisar el trazado en OSM
--   · 206 (relation 15540760): 1 salto(s) puenteados, el mayor de 120 m — conviene revisar el trazado en OSM
--   · 3A (relation 17132593): 1 salto(s) puenteados, el mayor de 369 m — conviene revisar el trazado en OSM
--   · 3C (relation 17160581): 1 salto(s) puenteados, el mayor de 369 m — conviene revisar el trazado en OSM
--   · 203 (relation 17367373): 2 salto(s) puenteados, el mayor de 654 m — conviene revisar el trazado en OSM
--   · 204 (relation 17369422): 1 salto(s) puenteados, el mayor de 120 m — conviene revisar el trazado en OSM
