/// Importador de recorridos y paradas del Gran Resistencia desde
/// OpenStreetMap hacia el esquema de Ruta Libre.
///
/// Uso:
///   dart run tools/osm_import.dart                 # baja de Overpass
///   dart run tools/osm_import.dart --cache dump/   # reusa una descarga
///
/// Genera `supabase/seed/seed_gran_resistencia.sql`, que se corre EN EL
/// SQL EDITOR de Supabase después de la migración 0003. El script nunca
/// toca la base directamente: el SQL queda versionado y revisable antes
/// de aplicarlo.
library;

import 'dart:convert';
import 'dart:io';

import 'src/geometry.dart';
import 'src/importer.dart';
import 'src/sql_emitter.dart';
import 'src/stop_naming.dart';

/// Gran Resistencia (Resistencia, Barranqueras, Fontana, Puerto Vilelas) y
/// el corredor hacia Corrientes capital: (sur, oeste, norte, este).
const _bbox = '-27.62,-59.15,-27.32,-58.70';

const _overpassEndpoints = [
  'https://overpass-api.de/api/interpreter',
  'https://overpass.kumi.systems/api/interpreter',
];

const _routesQuery =
    '''
[out:json][timeout:270];
relation["route"="bus"]($_bbox);
out body;
>;
out skel qt;
''';

const _stopsQuery =
    '''
[out:json][timeout:180];
(
  node["highway"="bus_stop"]($_bbox);
  node["public_transport"~"platform|stop_position"]($_bbox);
);
out body;
''';

/// Callejero con nombre, para bautizar las paradas que en OSM solo traen el
/// código interno de la concesionaria ("Parada C03253" no le dice nada a
/// nadie; "Ávalos y Rivadavia" sí).
const _streetsQuery =
    '''
[out:json][timeout:270];
way["highway"~"^(motorway|trunk|primary|secondary|tertiary|unclassified|residential|living_street)\$"]["name"]($_bbox);
out body;
>;
out skel qt;
''';

Future<void> main(List<String> args) async {
  final cacheDir = _argValue(args, '--cache');
  final outputPath =
      _argValue(args, '--out') ?? 'supabase/seed/seed_gran_resistencia.sql';

  stdout.writeln('Ruta Libre · importador OSM');
  stdout.writeln('bbox: $_bbox');

  final routesJson = await _load(
    label: 'recorridos',
    query: _routesQuery,
    cachePath: cacheDir == null ? null : '$cacheDir/osm_routes.json',
  );
  final stopsJson = await _load(
    label: 'paradas',
    query: _stopsQuery,
    cachePath: cacheDir == null ? null : '$cacheDir/osm_stops.json',
  );

  final streetsJson = await _load(
    label: 'callejero',
    query: _streetsQuery,
    cachePath: cacheDir == null ? null : '$cacheDir/osm_streets.json',
  );

  final input = _toInput(routesJson, stopsJson, streetsJson);
  stdout.writeln(
    'Leídos: ${input.relations.length} recorridos, '
    '${input.wayNodes.length} ways, ${input.nodePoints.length} nodos, '
    '${input.streets.length} tramos de calle.',
  );

  final result = buildImport(input);

  stdout.writeln('');
  stdout.writeln('Resultado:');
  stdout.writeln('  líneas:     ${result.lines.length}');
  stdout.writeln('  recorridos: ${result.variants.length}');
  stdout.writeln('  paradas:    ${result.stops.length}');
  _report('Descartadas', result.skipped);
  _report('Advertencias', result.warnings);
  _report('Saltos puenteados', result.gapReport);

  final sql = emitSql(
    result,
    generatedAt: DateTime.now().toUtc().toIso8601String(),
  );
  final file = File(outputPath);
  await file.parent.create(recursive: true);
  await file.writeAsString(sql);

  final kb = (sql.length / 1024).toStringAsFixed(0);
  stdout.writeln('');
  stdout.writeln('SQL escrito en $outputPath ($kb KB).');
  stdout.writeln(
    'Aplicar en Supabase → SQL Editor DESPUÉS de la migración 0003.',
  );
}

String? _argValue(List<String> args, String flag) {
  final index = args.indexOf(flag);
  if (index < 0 || index + 1 >= args.length) return null;
  return args[index + 1];
}

/// Descarga de Overpass, o lee del cache si existe (para iterar el
/// importer sin castigar un servicio público y gratuito).
Future<Map<String, dynamic>> _load({
  required String label,
  required String query,
  String? cachePath,
}) async {
  if (cachePath != null) {
    final cached = File(cachePath);
    if (cached.existsSync()) {
      stdout.writeln('· $label: usando cache $cachePath');
      return jsonDecode(await cached.readAsString()) as Map<String, dynamic>;
    }
  }

  Object? lastError;
  for (final endpoint in _overpassEndpoints) {
    try {
      stdout.writeln('· $label: consultando $endpoint ...');
      final body = await _post(endpoint, query);
      final json = jsonDecode(body) as Map<String, dynamic>;
      if (cachePath != null) {
        final cached = File(cachePath);
        await cached.parent.create(recursive: true);
        await cached.writeAsString(body);
      }
      return json;
    } catch (error) {
      // Overpass es un servicio comunitario y se satura seguido: si un
      // endpoint contesta HTML de error o corta, se prueba el siguiente.
      stdout.writeln('  falló ($error), pruebo el próximo endpoint');
      lastError = error;
    }
  }
  throw StateError('No se pudo descargar $label de Overpass: $lastError');
}

Future<String> _post(String endpoint, String query) async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 30);
  try {
    final request = await client.postUrl(Uri.parse(endpoint));
    request.headers.set(
      HttpHeaders.contentTypeHeader,
      'application/x-www-form-urlencoded',
    );
    // Identificarse es parte de la política de uso de Overpass.
    request.headers.set(
      HttpHeaders.userAgentHeader,
      'RutaLibre-import/1.0 (+https://github.com/rutalibre)',
    );
    request.write('data=${Uri.encodeQueryComponent(query)}');

    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    if (response.statusCode != 200) {
      throw HttpException('HTTP ${response.statusCode}');
    }
    if (body.trimLeft().startsWith('<')) {
      throw const FormatException('Overpass devolvió HTML (servidor ocupado)');
    }
    return body;
  } finally {
    client.close();
  }
}

/// Normaliza las dos respuestas de Overpass al input del importer.
OsmInput _toInput(
  Map<String, dynamic> routesJson,
  Map<String, dynamic> stopsJson,
  Map<String, dynamic> streetsJson,
) {
  final relations = <OsmRelation>[];
  final wayNodes = <int, List<int>>{};
  final nodePoints = <int, GeoPoint>{};
  final nodeTags = <int, Map<String, String>>{};
  final streetNames = <int, String>{};

  void ingest(Map<String, dynamic> json, {bool collectStreetNames = false}) {
    for (final raw in (json['elements'] as List? ?? const [])) {
      final element = raw as Map<String, dynamic>;
      switch (element['type']) {
        case 'relation':
          final tags = _stringMap(element['tags']);
          if (tags['route'] != 'bus') continue;
          relations.add(
            OsmRelation(
              id: element['id'] as int,
              tags: tags,
              members: [
                for (final m in (element['members'] as List? ?? const []))
                  OsmMember(
                    type: '${(m as Map)['type']}',
                    ref: m['ref'] as int,
                    role: '${m['role'] ?? ''}',
                  ),
              ],
            ),
          );
        case 'way':
          final wayId = element['id'] as int;
          wayNodes[wayId] = (element['nodes'] as List? ?? const []).cast<int>();
          if (collectStreetNames) {
            final name = _stringMap(element['tags'])['name']?.trim();
            if (name != null && name.isNotEmpty) streetNames[wayId] = name;
          }
        case 'node':
          final id = element['id'] as int;
          final lat = element['lat'];
          final lon = element['lon'];
          if (lat != null && lon != null) {
            nodePoints[id] = (
              lat: (lat as num).toDouble(),
              lng: (lon as num).toDouble(),
            );
          }
          final tags = _stringMap(element['tags']);
          if (tags.isNotEmpty) nodeTags[id] = tags;
      }
    }
  }

  ingest(routesJson);
  ingest(stopsJson);
  ingest(streetsJson, collectStreetNames: true);

  final streets = <NamedStreet>[];
  for (final entry in streetNames.entries) {
    final points = <GeoPoint>[];
    for (final nodeId in wayNodes[entry.key] ?? const <int>[]) {
      final point = nodePoints[nodeId];
      if (point != null) points.add(point);
    }
    if (points.length >= 2) {
      streets.add(NamedStreet(name: entry.value, points: points));
    }
  }

  relations.sort((a, b) => a.id.compareTo(b.id));
  return OsmInput(
    relations: relations,
    wayNodes: wayNodes,
    nodePoints: nodePoints,
    nodeTags: nodeTags,
    streets: streets,
  );
}

Map<String, String> _stringMap(Object? raw) {
  if (raw is! Map) return const {};
  return {for (final entry in raw.entries) '${entry.key}': '${entry.value}'};
}

void _report(String title, List<String> items) {
  if (items.isEmpty) {
    stdout.writeln('  $title: ninguna');
    return;
  }
  stdout.writeln('  $title (${items.length}):');
  for (final item in items.take(12)) {
    stdout.writeln('    · $item');
  }
  if (items.length > 12) {
    stdout.writeln('    ... y ${items.length - 12} más (ver el SQL generado)');
  }
}
