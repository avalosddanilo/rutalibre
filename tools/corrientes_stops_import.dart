/// Importador de las PARADAS de Corrientes capital desde OpenStreetMap.
///
/// Uso:
///   dart run tools/corrientes_stops_import.dart --cache .osmcache
///
/// Genera `assets/corrientes_stops.json`.
///
/// **Por qué un importador aparte y no `osm_import.dart`.** Ese arma las
/// paradas recorriendo las que pertenecen a algún recorrido de OSM, y las
/// líneas urbanas de Corrientes no están mapeadas como relations: sus
/// paradas se caían aunque estuvieran bajadas. En vez de aflojar esa regla
/// —que es la que evita que el Gran Resistencia se llene de paradas de
/// larga distancia— salen por su propio camino.
///
/// **Por qué un asset y no la base.** Estas paradas NO entran al
/// planificador (ver `src/corrientes_stops.dart` para los números que lo
/// justifican). Meterlas en `stops` las dejaría a merced de la sección 5 del
/// seed del Gran Resistencia, que desactiva toda parada sin recorrido — se
/// borrarían solas en el próximo import. Y como asset andan sin señal y sin
/// que nadie corra un SQL.
library;

import 'dart:convert';
import 'dart:io';

import 'src/corrientes_stops.dart';
import 'src/stop_naming.dart';

const _bbox = '-27.62,-59.15,-27.32,-58.70';

const _overpassEndpoints = [
  'https://overpass.kumi.systems/api/interpreter',
  'https://overpass-api.de/api/interpreter',
];

const _stopsQuery =
    '''
[out:json][timeout:180];
(
  node["highway"="bus_stop"]($_bbox);
  node["public_transport"~"platform|stop_position"]($_bbox);
);
out body;
''';

const _streetsQuery =
    '''
[out:json][timeout:270];
way["highway"~"^(motorway|trunk|primary|secondary|tertiary|unclassified|residential|living_street)\$"]["name"]($_bbox);
out body;
>;
out skel qt;
''';

Future<void> main(List<String> args) async {
  final cacheDir = _argValue(args, '--cache') ?? '.osmcache';
  final outputPath = _argValue(args, '--out') ?? 'assets/corrientes_stops.json';

  stdout.writeln('Ruta Libre · paradas de Corrientes capital');

  final stopsJson = await _load(
    label: 'paradas',
    query: _stopsQuery,
    cachePath: '$cacheDir/osm_stops.json',
  );
  final streetsJson = await _load(
    label: 'callejero',
    query: _streetsQuery,
    cachePath: '$cacheDir/osm_streets.json',
  );

  // El mismo índice de calles que usa el importador del Gran Resistencia: la
  // parada correntina tampoco tiene nombre propio, así que se la bautiza con
  // la esquina.
  final index = StreetIndex(streetsFromOverpass(streetsJson));

  final raw = <RawStop>[
    for (final element
        in ((stopsJson['elements'] as List<dynamic>?) ?? const [])
            .cast<Map<String, dynamic>>())
      (
        id: (element['id'] as num?)?.toInt() ?? 0,
        lat: (element['lat'] as num?)?.toDouble(),
        lng: (element['lon'] as num?)?.toDouble(),
        name: (element['tags'] as Map<String, dynamic>?)?['name'] as String?,
      ),
  ];

  final result = buildCorrientesStops(
    raw,
    deriveName: (lat, lng) => deriveStopName((lat: lat, lng: lng), index),
  );
  final r = result.report;

  stdout.writeln('');
  stdout.writeln('Nodos leídos:              ${r.total}');
  stdout.writeln('  fuera de Corrientes:     ${r.fueraDeCorrientes}');
  stdout.writeln('  sin líneas en el nombre: ${r.sinLineas}');
  stdout.writeln('  → PARADAS:               ${result.stops.length}');
  stdout.writeln('     de esas, sin esquina derivada: ${r.sinNombreDerivado}');

  final lineas = <String>{};
  for (final stop in result.stops) {
    lineas.addAll(stop.lines);
  }
  final ordenadas = lineas.toList()..sort();
  stdout.writeln('');
  stdout.writeln('Líneas mencionadas (${ordenadas.length}):');
  stdout.writeln('  ${ordenadas.join(", ")}');

  final encoded = jsonEncode(encodeCorrientesStops(result.stops));
  final file = File(outputPath);
  await file.parent.create(recursive: true);
  await file.writeAsString(encoded);

  stdout.writeln('');
  stdout.writeln(
    '$outputPath escrito (${(encoded.length / 1024).toStringAsFixed(0)} KB).',
  );
}

String? _argValue(List<String> args, String flag) {
  final index = args.indexOf(flag);
  if (index < 0 || index + 1 >= args.length) return null;
  return args[index + 1];
}

Future<Map<String, dynamic>> _load({
  required String label,
  required String query,
  required String cachePath,
}) async {
  final cached = File(cachePath);
  if (cached.existsSync()) {
    stdout.writeln('· $label: usando cache $cachePath');
    return jsonDecode(await cached.readAsString()) as Map<String, dynamic>;
  }

  Object? lastError;
  for (final endpoint in _overpassEndpoints) {
    try {
      stdout.writeln('· $label: consultando $endpoint ...');
      final body = await _post(endpoint, query);
      await cached.parent.create(recursive: true);
      await cached.writeAsString(body);
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (error) {
      stdout.writeln('  falló ($error), pruebo el próximo endpoint');
      lastError = error;
    }
  }
  throw StateError('No se pudo descargar $label: $lastError');
}

Future<String> _post(String endpoint, String query) async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 60);
  try {
    final request = await client.postUrl(Uri.parse(endpoint));
    request.headers.set(
      HttpHeaders.contentTypeHeader,
      'application/x-www-form-urlencoded',
    );
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
