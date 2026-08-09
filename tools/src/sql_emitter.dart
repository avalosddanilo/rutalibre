/// Generación del SQL de carga. Puro: entra el modelo, sale un string.
///
/// El SQL resultante es IDEMPOTENTE (se puede correr N veces) y va todo en
/// una transacción: o entra el mapa completo o no entra nada.
library;

import 'geometry.dart';
import 'import_model.dart';

/// Escapa un literal de texto para SQL (comillas simples duplicadas).
String sqlString(String? value) {
  if (value == null) return 'null';
  return "'${value.replaceAll("'", "''")}'";
}

/// `array['a', 'b']::text[]` — se usa el constructor `array[...]` y no el
/// literal `'{a,b}'` porque este último tiene sus propias reglas de escapado
/// (comillas dobles, backslashes) distintas de las de un literal de texto, y
/// un destino con una coma adentro lo partiría en dos en silencio.
String sqlTextArray(List<String> values) => values.isEmpty
    ? "array[]::text[]"
    : 'array[${values.map(sqlString).join(', ')}]::text[]';

/// Coordenada con precisión de ~1 cm: más decimales solo engordan el archivo.
String _coord(double value) => value.toStringAsFixed(6);

/// `LINESTRING(lng lat, ...)` — OJO el orden: WKT es (x y) = (lng lat),
/// al revés de como se piensa una coordenada. Es EL error clásico.
String lineStringWkt(List<GeoPoint> points) {
  final pairs = points
      .map((p) => '${_coord(p.lng)} ${_coord(p.lat)}')
      .join(', ');
  return 'LINESTRING($pairs)';
}

/// Convierte el resultado del import en un script SQL completo.
String emitSql(ImportResult result, {required String generatedAt}) {
  final buffer = StringBuffer();
  final networks = {for (final line in result.lines) line.networkCode}.toList()
    ..sort();

  buffer
    ..writeln('-- ${'=' * 68}')
    ..writeln('-- RUTA LIBRE — Carga de datos reales del Gran Resistencia')
    ..writeln('--')
    ..writeln('-- GENERADO AUTOMÁTICAMENTE por tools/osm_import.dart.')
    ..writeln('-- No editar a mano: se regenera con')
    ..writeln('--   dart run tools/osm_import.dart')
    ..writeln('--')
    ..writeln('-- Fuente: OpenStreetMap vía Overpass API.')
    ..writeln('-- Los datos de OSM están bajo ODbL: la app DEBE mantener')
    ..writeln('-- visible el crédito "© OpenStreetMap contributors".')
    ..writeln('--')
    ..writeln('-- Fecha de extracción: $generatedAt')
    ..writeln(
      '-- Líneas: ${result.lines.length} | '
      'Recorridos: ${result.variants.length} | '
      'Paradas: ${result.stops.length}',
    )
    ..writeln('--')
    ..writeln('-- REQUIERE la migración 0003 aplicada.')
    ..writeln('--')
    ..writeln('-- OJO: borra los recorridos SIN origen OSM de estas redes')
    ..writeln('-- (los del seed de desarrollo) para que no queden trazados')
    ..writeln('-- mock mezclados con los reales. Eso arrastra por cascada los')
    ..writeln('-- horarios que colgaran de ellos.')
    ..writeln('-- ${'=' * 68}')
    ..writeln()
    ..writeln('begin;')
    ..writeln();

  // --- Limpieza del seed de desarrollo ---
  buffer
    ..writeln('-- ${'-' * 60}')
    ..writeln('-- 0. Fuera lo que no vino de OSM en estas redes')
    ..writeln('-- ${'-' * 60}')
    ..writeln('delete from public.route_variants rv')
    ..writeln(' using public.lines l, public.networks n')
    ..writeln(' where rv.line_id = l.id')
    ..writeln('   and l.network_id = n.id')
    ..writeln('   and rv.osm_relation_id is null')
    ..writeln('   and n.code in (${networks.map(sqlString).join(', ')});')
    ..writeln();

  // --- Líneas ---
  buffer
    ..writeln('-- ${'-' * 60}')
    ..writeln('-- 1. Líneas (${result.lines.length})')
    ..writeln('-- ${'-' * 60}');
  for (final line in result.lines) {
    buffer
      ..writeln(
        'insert into public.lines '
        '(network_id, code, name, destinations, color_hex, sort_order, '
        'is_active)',
      )
      ..writeln(
        'values ((select id from public.networks where code = '
        '${sqlString(line.networkCode)}),',
      )
      ..writeln(
        '        ${sqlString(line.code)}, ${sqlString(line.name)}, '
        '${sqlTextArray(line.destinations)},',
      )
      ..writeln('        ${sqlString(line.colorHex)}, ${line.sortOrder}, true)')
      ..writeln('on conflict (network_id, code) do update set')
      ..writeln('    name = excluded.name,')
      ..writeln('    destinations = excluded.destinations,')
      ..writeln('    color_hex = excluded.color_hex,')
      ..writeln('    sort_order = excluded.sort_order,')
      ..writeln('    is_active = true;');
  }
  buffer.writeln();

  // --- Paradas ---
  buffer
    ..writeln('-- ${'-' * 60}')
    ..writeln('-- 2. Paradas (${result.stops.length})')
    ..writeln('-- ${'-' * 60}');
  for (final stop in result.stops) {
    buffer
      ..writeln(
        'insert into public.stops '
        '(osm_node_id, name, description, geom, is_active)',
      )
      ..writeln(
        'values (${stop.osmNodeId}, ${sqlString(stop.name)}, '
        '${sqlString(stop.description)},',
      )
      ..writeln(
        '        st_setsrid(st_point(${_coord(stop.point.lng)}, '
        '${_coord(stop.point.lat)}), 4326)::geography, true)',
      )
      ..writeln('on conflict (osm_node_id) do update set')
      ..writeln('    name = excluded.name,')
      ..writeln('    description = excluded.description,')
      ..writeln('    geom = excluded.geom,')
      ..writeln('    is_active = true;');
  }
  buffer.writeln();

  // --- Recorridos ---
  buffer
    ..writeln('-- ${'-' * 60}')
    ..writeln('-- 3. Recorridos con su trazado (${result.variants.length})')
    ..writeln('-- ${'-' * 60}');
  for (final variant in result.variants) {
    buffer
      ..writeln(
        'insert into public.route_variants '
        '(line_id, name, branch, direction, geom, osm_relation_id, is_active)',
      )
      ..writeln(
        'values ((select l.id from public.lines l '
        'join public.networks n on n.id = l.network_id',
      )
      ..writeln(
        '         where n.code = ${sqlString(variant.networkCode)} '
        'and l.code = ${sqlString(variant.lineCode)}),',
      )
      ..writeln(
        '        ${sqlString(variant.name)}, '
        '${sqlString(variant.branch)}, ${variant.direction},',
      )
      ..writeln(
        '        st_geomfromtext(${sqlString(lineStringWkt(variant.geometry))}, 4326),',
      )
      ..writeln('        ${variant.osmRelationId}, true)')
      ..writeln('on conflict (osm_relation_id) do update set')
      ..writeln('    line_id = excluded.line_id,')
      ..writeln('    name = excluded.name,')
      ..writeln('    branch = excluded.branch,')
      ..writeln('    direction = excluded.direction,')
      ..writeln('    geom = excluded.geom,')
      ..writeln('    is_active = true;');
  }
  buffer.writeln();

  // --- Secuencia de paradas ---
  final totalRouteStops = result.variants.fold<int>(
    0,
    (sum, v) => sum + v.stopOsmIds.length,
  );
  buffer
    ..writeln('-- ${'-' * 60}')
    ..writeln('-- 4. Secuencia de paradas por recorrido ($totalRouteStops)')
    ..writeln('--    Se reemplaza entera: si en OSM sacaron una parada del')
    ..writeln('--    recorrido, acá también tiene que desaparecer.')
    ..writeln('-- ${'-' * 60}');
  for (final variant in result.variants) {
    // El DELETE va SIEMPRE, incluso si el recorrido se quedó sin paradas: si
    // en OSM las sacaron, acá también tienen que desaparecer. Saltearlo
    // dejaba la secuencia vieja colgada para siempre.
    buffer
      ..writeln('delete from public.route_stops')
      ..writeln(
        ' where route_variant_id = (select id from public.route_variants '
        'where osm_relation_id = ${variant.osmRelationId});',
      );
    if (variant.stopOsmIds.isEmpty) continue;
    buffer
      ..writeln(
        'insert into public.route_stops '
        '(route_variant_id, stop_id, stop_order)',
      )
      ..writeln('select rv.id, s.id, v.stop_order')
      ..writeln('  from (values');
    for (var i = 0; i < variant.stopOsmIds.length; i++) {
      final comma = i == variant.stopOsmIds.length - 1 ? '' : ',';
      buffer.writeln(
        '         (${variant.stopOsmIds[i]}::bigint, ${i + 1})$comma',
      );
    }
    buffer
      ..writeln('       ) as v(osm_node_id, stop_order)')
      ..writeln('  join public.stops s on s.osm_node_id = v.osm_node_id')
      ..writeln(
        '  cross join (select id from public.route_variants '
        'where osm_relation_id = ${variant.osmRelationId}) rv',
      )
      ..writeln('on conflict (route_variant_id, stop_order) do nothing;');
  }
  buffer.writeln();

  // --- Paradas que ya no sirve nadie ---
  //
  // VA AL FINAL, después de rehacer `route_stops`: recién ahí se sabe qué
  // paradas quedaron sin ningún recorrido. Acá caen las del seed mock, las
  // que OSM dejó de usar y las que este import unificó con otra. Si se
  // quedaran activas aparecerían en "cerca mío" y al tocarlas no pasaría
  // nada: son las "paradas que ya no son paradas".
  buffer
    ..writeln('-- ${'-' * 60}')
    ..writeln('-- 5. Baja de las paradas que ya no sirve ningún recorrido')
    ..writeln('-- ${'-' * 60}')
    ..writeln('update public.stops s')
    ..writeln('   set is_active = false')
    ..writeln(' where s.is_active')
    ..writeln('   and not exists (')
    ..writeln('       select 1 from public.route_stops rs')
    ..writeln('        where rs.stop_id = s.id);')
    ..writeln();

  // --- Líneas que se quedaron sin recorridos ---
  //
  // Mismo problema que las paradas huérfanas, una tabla más arriba, y se
  // vio en la base de verdad: al partir el 904 en tres servicios
  // (904A/B/C), la línea `904` original quedó activa con CERO recorridos.
  // Una línea así aparece en el listado y al tocarla no pasa nada.
  //
  // Se limita a las redes de ESTE import: una línea de Corrientes sin
  // recorridos no es asunto de este archivo, y darla de baja acá la
  // apagaría cada vez que se corre el seed del Gran Resistencia.
  buffer
    ..writeln('-- ${'-' * 60}')
    ..writeln('-- 6. Baja de las líneas que se quedaron sin recorridos')
    ..writeln('-- ${'-' * 60}')
    ..writeln('update public.lines l')
    ..writeln('   set is_active = false')
    ..writeln('  from public.networks n')
    ..writeln(' where l.network_id = n.id')
    ..writeln('   and l.is_active')
    ..writeln('   and n.code in (${networks.map(sqlString).join(', ')})')
    ..writeln('   and not exists (')
    ..writeln('       select 1 from public.route_variants rv')
    ..writeln('        where rv.line_id = l.id and rv.is_active);')
    ..writeln();

  buffer.writeln('commit;');
  buffer.writeln();

  // --- Diagnóstico ---
  buffer
    ..writeln('-- ${'=' * 68}')
    ..writeln('-- DIAGNÓSTICO DE LA IMPORTACIÓN (solo informativo)')
    ..writeln('-- ${'=' * 68}');
  _writeSection(buffer, 'Relations descartadas', result.skipped);
  _writeSection(buffer, 'Advertencias de datos', result.warnings);
  _writeSection(buffer, 'Trazados con saltos puenteados', result.gapReport);

  return buffer.toString();
}

void _writeSection(StringBuffer buffer, String title, List<String> items) {
  buffer.writeln('--');
  if (items.isEmpty) {
    buffer.writeln('-- $title: ninguna.');
    return;
  }
  buffer.writeln('-- $title (${items.length}):');
  for (final item in items) {
    buffer.writeln('--   · $item');
  }
}
