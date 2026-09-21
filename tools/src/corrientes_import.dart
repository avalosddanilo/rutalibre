/// Importador de los recorridos urbanos de Corrientes capital.
///
/// Fuente: portal de datos abiertos de la Municipalidad de Corrientes,
/// dataset "Servicio de Transporte Urbano" (`recorridosurbanos.csv`).
///
/// Diferencias con el importador de OSM (por eso son dos pipelines y no uno):
/// - la geometría viene PROYECTADA (Gauss-Krüger Faja 5), no en lat/lng;
/// - el sentido viene EXPLÍCITO en `linea_descrip` ("... - IDA" / "- VUELTA"),
///   no hay que adivinarlo del nombre como en OSM;
/// - NO hay paradas: el recurso fue dado de baja del portal.
///
/// Comparten las piezas genéricas: [GeoPoint], `simplify`, los literales SQL
/// y la paleta de colores.
///
/// Dart PURO — sin red, sin SQL, sin Flutter.
library;

import 'corrientes_stops_csv.dart';
import 'csv_reader.dart';
import 'gauss_kruger.dart';
import 'geometry.dart';
import 'line_palette.dart';
import 'sql_emitter.dart' show sqlString, sqlTextArray, lineStringWkt;

const _networkCode = 'corrientes-capital';

/// Misma tolerancia que el importador de OSM: a escala urbana no se nota.
const _simplifyToleranceMeters = 5.0;

/// Un recorrido de Corrientes ya resuelto.
class CorrientesVariant {
  const CorrientesVariant({
    required this.lineCode,
    required this.branch,
    required this.direction,
    required this.name,
    required this.geometry,
  });

  final String lineCode;

  /// Ramal ya normalizado: "B", "C DIRECTO", "A COLECTORA"… o null.
  final String? branch;

  /// 0 = ida, 1 = vuelta.
  final int direction;
  final String name;
  final List<GeoPoint> geometry;
}

class CorrientesLine {
  CorrientesLine({
    required this.code,
    required this.name,
    required this.colorHex,
    required this.sortOrder,
    this.destinations = const [],
  });

  final String code;
  String name;

  /// Todos los destinos de la línea; [name] es un resumen que entra en un
  /// renglón. Ver [lineDestinations].
  final List<String> destinations;

  final String colorHex;
  final int sortOrder;
}

class CorrientesImportResult {
  const CorrientesImportResult({
    required this.lines,
    required this.variants,
    required this.warnings,
    required this.skipped,
  });

  final List<CorrientesLine> lines;
  final List<CorrientesVariant> variants;
  final List<String> warnings;
  final List<String> skipped;
}

/// El dataset usa `linea = "00"` para el servicio al aeropuerto. Nadie lo
/// busca como "00": lo busca como "Aerobus". Es la única desviación
/// deliberada respecto del campo original, y queda documentada acá.
const _lineCodeOverrides = <String, String>{'00': 'Aerobus'};

/// Convierte el CSV crudo en el modelo listo para emitir.
CorrientesImportResult importCorrientes(String csvContent) {
  final table = CsvTable.parse(csvContent)
    ..requireColumns(['the_geom', 'linea', 'linea_descrip', 'nombre', 'ramal']);

  final warnings = <String>[];
  final skipped = <String>[];
  final variants = <CorrientesVariant>[];
  final lineNames = <String, List<String>>{};

  for (final row in table.rows) {
    final rawLine = table.value(row, 'linea');
    final lineCode = _lineCodeOverrides[rawLine] ?? rawLine;
    final ramal = table.value(row, 'ramal');
    final descrip = table.value(row, 'linea_descrip');
    final nombre = table.value(row, 'nombre');

    if (lineCode.isEmpty) {
      skipped.add('fila sin línea — "$nombre"');
      continue;
    }

    final direction = parseDirection(descrip);
    if (direction == null) {
      skipped.add(
        'línea $lineCode "$nombre": sentido no declarado en '
        '"$descrip" — se descarta para no inventarlo',
      );
      continue;
    }

    final points = parseProjectedLineString(table.value(row, 'the_geom'));
    if (points.length < 2) {
      skipped.add('línea $lineCode "$nombre": sin geometría usable');
      continue;
    }

    var branch = normalizeBranch(ramal, rawLine);
    // El Aerobus tiene un único recorrido: repetir "Aerobus" como ramal de
    // la línea "Aerobus" no le dice nada al pasajero.
    if (branch != null && branch.toLowerCase() == lineCode.toLowerCase()) {
      branch = null;
    }
    variants.add(
      CorrientesVariant(
        lineCode: lineCode,
        branch: branch,
        direction: direction,
        name: '${direction == 0 ? "Ida" : "Vuelta"}: ${titleCase(nombre)}',
        geometry: simplify(points, _simplifyToleranceMeters),
      ),
    );

    if (direction == 0) {
      lineNames.putIfAbsent(lineCode, () => []).add(titleCase(nombre));
    }
  }

  // Un mismo (línea, ramal, sentido) dos veces significaría que el ramal no
  // quedó bien distinguido: hay que reportarlo, no pisarlo en silencio.
  final vistos = <String>{};
  for (final v in variants) {
    final key = '${v.lineCode}/${v.branch ?? ''}/${v.direction}';
    if (!vistos.add(key)) {
      warnings.add(
        'línea ${v.lineCode} ramal "${v.branch}" '
        '${v.direction == 0 ? "ida" : "vuelta"} está duplicado — '
        'el último gana',
      );
    }
  }

  final codes = variants.map((v) => v.lineCode).toSet().toList()
    ..sort(compareLineCodes);
  final lines = <CorrientesLine>[];
  for (var i = 0; i < codes.length; i++) {
    final code = codes[i];
    final nombres = lineNames[code] ?? const <String>[];
    lines.add(
      CorrientesLine(
        code: code,
        name: buildLineName(nombres),
        destinations: lineDestinations(nombres),
        // Se hashea con la red adelante para que la 110 de Corrientes no salga
        // del mismo color que la 110 del Gran Resistencia.
        colorHex: colorForLine('$_networkCode/$code'),
        sortOrder: i + 1,
      ),
    );
  }

  return CorrientesImportResult(
    lines: lines,
    variants: variants,
    warnings: warnings,
    skipped: skipped,
  );
}

/// `linea_descrip` termina en " - IDA" o " - VUELTA".
///
/// Se mira el FINAL y no `contains`, porque un destino podría contener la
/// palabra (ej. "Vuelta de Obligado").
int? parseDirection(String descrip) {
  // El límite de palabra es imprescindible: un destino como "MERIDA"
  // TERMINA en "IDA" y sin esto se importaría como ida.
  final match = RegExp(
    r'(?:^|[\s\-–])(IDA|VUELTA)\s*$',
  ).firstMatch(descrip.toUpperCase().trim());
  if (match == null) return null;
  return match.group(1) == 'VUELTA' ? 1 : 0;
}

/// "101 B" → "B" · "103 C- DIRECTO" → "C DIRECTO" · "Aerobus" → null.
///
/// El descriptor se CONSERVA porque hay ramales que comparten letra: la
/// línea 103 tiene un "C - DIRECTO" y un "C - Bo Esperanza" que son
/// recorridos distintos. Sin el descriptor colisionarían.
String? normalizeBranch(String ramal, String rawLineCode) {
  var rest = ramal.trim();
  if (rest.isEmpty) return null;
  if (rest.toUpperCase().startsWith(rawLineCode.toUpperCase())) {
    rest = rest.substring(rawLineCode.length);
  }
  // Saca separadores sueltos que quedan al remover el número.
  rest = rest.replaceAll(RegExp(r'^[\s\-–]+'), '');
  rest = rest.replaceAll(RegExp(r'[\s\-–]+'), ' ').trim();
  return rest.isEmpty ? null : rest;
}

/// `LINESTRING (x y, x y, ...)` proyectado → puntos WGS84.
List<GeoPoint> parseProjectedLineString(String wkt) {
  final match = RegExp(
    r'LINESTRING\s*\(([^)]*)\)',
    caseSensitive: false,
  ).firstMatch(wkt);
  if (match == null) return const [];

  final points = <GeoPoint>[];
  for (final pair in match.group(1)!.split(',')) {
    final parts = pair.trim().split(RegExp(r'\s+'));
    if (parts.length < 2) continue;
    final x = double.tryParse(parts[0]);
    final y = double.tryParse(parts[1]);
    if (x == null || y == null) continue;
    points.add(gaussKrugerToWgs84(x, y));
  }
  return points;
}

/// "PUERTO - B° PONCE" → "Puerto ↔ B° Ponce".
String titleCase(String value) {
  const minusculas = {'de', 'del', 'la', 'las', 'los', 'y', 'a'};
  final words = value.trim().split(RegExp(r'\s+'));
  final out = <String>[];
  for (var i = 0; i < words.length; i++) {
    final w = words[i];
    if (w == '-') {
      out.add('↔');
      continue;
    }
    if (!RegExp(r'[A-Za-zÁÉÍÓÚÑáéíóúñ]').hasMatch(w)) {
      out.add(w);
      continue;
    }
    final lower = w.toLowerCase();
    if (i > 0 && minusculas.contains(lower)) {
      out.add(lower);
      continue;
    }
    // Los compuestos con guion se capitalizan de los dos lados
    // ("QUINTANA-SAN ROQUE" → "Quintana-San Roque").
    out.add(lower.split('-').map(_capitalize).join('-'));
  }
  return out.join(' ');
}

String _capitalize(String word) {
  if (word.isEmpty) return word;
  // Iniciales con puntos van enteras en mayúscula ("f.j." → "F.J.").
  if (word.contains('.') && word.replaceAll('.', '').length <= 3) {
    return word.toUpperCase();
  }
  return word[0].toUpperCase() + word.substring(1);
}

/// Nombre de la línea a partir de los destinos de sus ramales de ida.
String buildLineName(List<String> nombresDeIda) {
  final distintos = lineDestinations(nombresDeIda);
  if (distintos.isEmpty) return 'Recorrido urbano';
  if (distintos.length == 1) return distintos.first;
  final extra = distintos.length - 1;
  return '${distintos.first} y $extra ramal${extra == 1 ? "" : "es"} más';
}

/// Los destinos de la línea, sin repetir y en el orden en que aparecen.
///
/// Van a `lines.destinations` porque [buildLineName] resume a partir del
/// segundo ramal ("y 4 ramales más") y esos destinos, guardados solo en el
/// nombre, quedaban imposibles de buscar en la app.
List<String> lineDestinations(List<String> nombresDeIda) =>
    nombresDeIda.toSet().toList();

/// "3" antes que "110"; los códigos no numéricos al final.
int compareLineCodes(String a, String b) {
  final na = int.tryParse(a);
  final nb = int.tryParse(b);
  if (na != null && nb != null) return na.compareTo(nb);
  if (na != null) return -1;
  if (nb != null) return 1;
  return a.compareTo(b);
}

/// Genera el SQL de carga: idempotente y en una transacción.
///
/// Estrategia de reimportación: primero se DESACTIVAN todos los recorridos
/// de la red y después se reactivan los que vinieron en esta corrida. Un
/// recorrido que la Municipalidad dio de baja queda `is_active = false` y
/// desaparece de la app sin borrar nada (la RLS filtra por activo).
String emitCorrientesSql(
  CorrientesImportResult result, {
  required String generatedAt,
  required String sourceUrl,
  CorrientesStopsResult? stops,
  String? stopsSourceUrl,
  String Function(GeoPoint point)? stopName,
}) {
  final buffer = StringBuffer()
    ..writeln('-- ${'=' * 68}')
    ..writeln('-- RUTA LIBRE — Recorridos urbanos de Corrientes capital')
    ..writeln('--')
    ..writeln('-- GENERADO AUTOMÁTICAMENTE por tools/corrientes_import.dart.')
    ..writeln('-- No editar a mano: se regenera con')
    ..writeln('--   dart run tools/corrientes_import.dart')
    ..writeln('--')
    ..writeln('-- Fuente: Municipalidad de la Ciudad de Corrientes,')
    ..writeln('--   Dirección General de Sistemas de Información Geográfica.')
    ..writeln('--   $sourceUrl')
    ..writeln('--   OJO: el portal NO declara licencia, aunque el servicio')
    ..writeln('--   WMS del municipio declara <AccessConstraints>NONE</>.')
    ..writeln('--   Atribución obligatoria. Ver docs/corrientes-geoserver.md.')
    ..writeln('--')
    ..writeln(
      stopsSourceUrl == null
          ? '-- Paradas: no se importaron en esta corrida.'
          : '-- Paradas: recurso `paradas-colectivos.csv` del MISMO dataset,',
    )
    ..writeln(
      stopsSourceUrl == null
          ? '--'
          : '--   retirado del portal y recuperado del Internet Archive:',
    )
    ..writeln(stopsSourceUrl == null ? '--' : '--   $stopsSourceUrl')
    ..writeln('--')
    ..writeln('-- Coordenadas: el origen viene en Gauss-Krüger Faja 5 y se')
    ..writeln('-- reproyecta a WGS84 en el importador (ver gauss_kruger.dart).')
    ..writeln('--')
    ..writeln('-- Fecha de extracción: $generatedAt')
    ..writeln(
      '-- Líneas: ${result.lines.length} | '
      'Recorridos: ${result.variants.length} | '
      'Paradas: ${stops?.stops.length ?? 0}',
    )
    ..writeln('--')
    ..writeln('-- REQUIERE la migración 0003 aplicada.')
    ..writeln('-- ${'=' * 68}')
    ..writeln()
    ..writeln('begin;')
    ..writeln();

  buffer
    ..writeln('-- ${'-' * 60}')
    ..writeln('-- 0. Baja lógica de todo lo anterior de esta red')
    ..writeln('-- ${'-' * 60}')
    ..writeln('update public.route_variants rv')
    ..writeln('   set is_active = false')
    ..writeln('  from public.lines l, public.networks n')
    ..writeln(' where rv.line_id = l.id')
    ..writeln('   and l.network_id = n.id')
    ..writeln('   and n.code = ${sqlString(_networkCode)};')
    ..writeln();

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
        '${sqlString(_networkCode)}),',
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

  buffer
    ..writeln('-- ${'-' * 60}')
    ..writeln('-- 2. Recorridos con su trazado (${result.variants.length})')
    ..writeln('--    Identidad natural: (línea, ramal, sentido). Estos datos')
    ..writeln('--    no traen un id estable de origen.')
    ..writeln('-- ${'-' * 60}');
  for (final v in result.variants) {
    buffer
      ..writeln(
        'insert into public.route_variants '
        '(line_id, name, branch, direction, geom, is_active)',
      )
      ..writeln(
        'values ((select l.id from public.lines l '
        'join public.networks n on n.id = l.network_id',
      )
      ..writeln(
        '         where n.code = ${sqlString(_networkCode)} '
        'and l.code = ${sqlString(v.lineCode)}),',
      )
      ..writeln(
        '        ${sqlString(v.name)}, ${sqlString(v.branch)}, '
        '${v.direction},',
      )
      ..writeln(
        '        st_geomfromtext(${sqlString(lineStringWkt(v.geometry))}, 4326), true)',
      )
      ..writeln(
        'on conflict (line_id, coalesce(branch, \'\'), direction) '
        'do update set',
      )
      ..writeln('    name = excluded.name,')
      ..writeln('    geom = excluded.geom,')
      ..writeln('    is_active = true;');
  }
  if (stops != null && stops.stops.isNotEmpty) {
    buffer
      ..writeln()
      ..writeln('-- ${'-' * 60}')
      ..writeln('-- 3. Paradas (${stops.stops.length})')
      ..writeln('--    Identidad: `source_ref` = ctes:<gid> del dataset')
      ..writeln('--    municipal. NO son nodos de OSM (ver migración 0013).')
      ..writeln('-- ${'-' * 60}');
    for (final stop in stops.stops) {
      // Sin esquina derivada queda el código del municipio. Feo y
      // verdadero le gana a bonito e inventado.
      final derivado = stopName?.call(stop.point) ?? '';
      final nombre = derivado.isEmpty ? 'Parada ${stop.gid}' : derivado;
      buffer
        ..writeln(
          'insert into public.stops '
          '(source_ref, name, description, geom, is_active)',
        )
        ..writeln(
          'values (${sqlString('ctes:${stop.gid}')}, ${sqlString(nombre)}, '
          '${sqlString('Parada ${stop.gid} · Municipalidad de Corrientes')},',
        )
        ..writeln(
          '        st_setsrid(st_point(${stop.point.lng.toStringAsFixed(6)}, '
          '${stop.point.lat.toStringAsFixed(6)}), 4326)::geography, true)',
        )
        ..writeln('on conflict (source_ref) do update set')
        ..writeln('    name = excluded.name,')
        ..writeln('    description = excluded.description,')
        ..writeln('    geom = excluded.geom,')
        ..writeln('    is_active = true;');
    }

    final total = stops.byVariant.values.fold(0, (n, v) => n + v.length);
    buffer
      ..writeln()
      ..writeln('-- ${'-' * 60}')
      ..writeln('-- 4. Secuencia de paradas por recorrido ($total)')
      ..writeln('--    El orden NO sale del archivo: cada parada se proyecta')
      ..writeln('--    sobre el trazado y se ordena por cuánto se avanzó.')
      ..writeln('-- ${'-' * 60}')
      ..writeln('delete from public.route_stops rs')
      ..writeln('  using public.route_variants rv, public.lines l,')
      ..writeln('        public.networks n')
      ..writeln(' where rs.route_variant_id = rv.id')
      ..writeln('   and rv.line_id = l.id and l.network_id = n.id')
      ..writeln('   and n.code = ${sqlString(_networkCode)};');
    for (final v in result.variants) {
      final gids =
          stops.byVariant['${v.lineCode}/${v.branch ?? ''}/${v.direction}'];
      if (gids == null) continue;
      for (var i = 0; i < gids.length; i++) {
        buffer
          ..writeln(
            'insert into public.route_stops '
            '(route_variant_id, stop_id, stop_order)',
          )
          ..writeln(
            'values ((select rv.id from public.route_variants rv '
            'join public.lines l on l.id = rv.line_id',
          )
          ..writeln(
            '         join public.networks n on n.id = l.network_id '
            'where n.code = ${sqlString(_networkCode)}',
          )
          ..writeln(
            '           and l.code = ${sqlString(v.lineCode)} '
            'and rv.branch is not distinct from ${sqlString(v.branch)}',
          )
          ..writeln('           and rv.direction = ${v.direction}),')
          ..writeln(
            '        (select id from public.stops where source_ref = '
            '${sqlString('ctes:${gids[i]}')}), ${i + 1});',
          );
      }
    }
  }

  buffer
    ..writeln()
    ..writeln('commit;')
    ..writeln();

  buffer
    ..writeln('-- ${'=' * 68}')
    ..writeln('-- DIAGNÓSTICO DE LA IMPORTACIÓN (solo informativo)')
    ..writeln('-- ${'=' * 68}');
  _section(buffer, 'Filas descartadas', result.skipped);
  _section(buffer, 'Advertencias de datos', result.warnings);
  if (stops != null) {
    _section(buffer, 'Paradas', stops.warnings);
  }

  return buffer.toString();
}

void _section(StringBuffer buffer, String title, List<String> items) {
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
