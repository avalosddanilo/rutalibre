-- ============================================================
-- RUTA LIBRE — 0020: los recorridos que no decían hacia dónde van
--
-- EL PROBLEMA. Desde la 1.3 la app muestra cada recorrido como "Hacia X,
-- desde Y", que es como lo dice alguien en la parada. Siete recorridos no
-- tenían destino en el nombre ("Chaco - Corrientes directo", "Colonia
-- Benítez", o solo "Ida") y caían en "Ida/Vuelta", justo lo que la gente
-- no entiende. Entre ellos el 904B y el 904C, de los más usados.
--
-- LA SOLUCIÓN. El nombre sale de dónde están la primera y la última
-- parada de cada recorrido, no de suponer el sentido: así apareció que la
-- "Ida" del 904B va de Corrientes a Resistencia, al revés que la del 904A.
-- Los importadores ya ponen estos nombres (`_variantNameOverrides` en
-- tools/src/importer.dart y `_nombreFixes` en corrientes_import.dart), así
-- que regenerar el seed no los pierde.
--
-- Las apps 1.0 a 1.2 muestran el nombre tal cual: "Ida: Corrientes →
-- Resistencia, directo" se lee bien también ahí.
--
-- Correr en: Supabase Dashboard → SQL Editor, después de la 0019.
-- ============================================================

begin;

update public.route_variants v
   set name = n.name
  from (values
          (14442058::bigint, 'Ida: Corrientes → Resistencia, directo'),
          (14442057, 'Vuelta: Resistencia → Corrientes, directo'),
          (14447122, 'Ida: Resistencia → Corrientes, por Barranqueras'),
          (14447121, 'Vuelta: Corrientes → Resistencia, por Barranqueras'),
          (14449326, 'Ida: Resistencia → Colonia Benítez'),
          (14449325, 'Vuelta: Colonia Benítez → Resistencia'),
          (7948963,  'Ida: Barranqueras → Barrio Santa Inés')
       ) as n(osm_relation_id, name)
 where v.osm_relation_id = n.osm_relation_id;

-- La 106D de Corrientes: al nombre del portal le faltaba el guion.
update public.route_variants rv
   set name = 'Ida: B° 500 VIV. ↔ B° Pirayui'
  from public.lines l, public.networks n
 where rv.line_id = l.id and l.network_id = n.id
   and n.code = 'corrientes-capital' and l.code = '106'
   and rv.branch = 'D' and rv.direction = 0;

update public.lines l
   set destinations = array_replace(l.destinations,
                                    'B° 500 VIV. B° Pirayui',
                                    'B° 500 VIV. ↔ B° Pirayui')
  from public.networks n
 where l.network_id = n.id and n.code = 'corrientes-capital' and l.code = '106';

commit;

-- Control: no queda ningún recorrido activo sin flecha (tiene que dar 0).
--   select count(*) from public.route_variants
--    where is_active and name !~ '[→↔]';
