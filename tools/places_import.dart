/// Importador de LUGARES (hospitales, escuelas, plazas, shoppings…) y de
/// CALLES con nombre, desde OpenStreetMap hacia el asset que la app empaqueta.
///
/// Uso:
///   dart run tools/places_import.dart                    # baja de Overpass
///   dart run tools/places_import.dart --cache .osmcache  # reusa la descarga
///
/// Genera `assets/places.json`.
///
/// **Por qué un asset y no la base**, a diferencia de paradas y recorridos:
///
/// * Son ~240 KB de nombres. Meterlos en `SharedPreferences` los haría cargar
///   ENTEROS en cada arranque, antes del primer cuadro — que es justo el
///   costo que `docs/arranque.md` marca como el riesgo a no empeorar. Como
///   asset se leen recién cuando alguien abre el buscador de destino.
/// * Andan **desde la instalación y sin señal**, sin depender de que la cache
///   se haya llenado antes.
/// * No obligan a correr una migración a mano para que la función exista.
///
/// El costo es que actualizarlos pide publicar una versión. Se banca: un
/// hospital no se muda. (La tarifa SÍ cambia seguido y por eso está en
/// código, con su fecha — ver `domain/entities/fare.dart`.)
library;

import 'dart:convert';
import 'dart:io';

import 'src/place_import.dart';
import 'src/street_import.dart';

/// Mismo bbox que el importador de recorridos: se filtra al área urbana
/// después, en `buildPlaces`.
const _bbox = '-27.62,-59.15,-27.32,-58.70';

const _overpassEndpoints = [
  // El de kumi aguanta mejor esta consulta; el oficial devolvió 504.
  'https://overpass.kumi.systems/api/interpreter',
  'https://overpass-api.de/api/interpreter',
];

/// `nwr` = nodos, ways y relations: la misma escuela puede estar mapeada de
/// las tres formas. `out center` da un punto para los que son polígonos.
/// `["name"]` filtra en el servidor lo que no tiene nombre, que no sirve para
/// buscar y sería la mitad de la respuesta.
const _placesQuery =
    '''
[out:json][timeout:270];
(
  nwr["amenity"~"^(hospital|clinic|doctors|pharmacy|school|university|college|kindergarten|townhall|police|courthouse|post_office|bank|library|theatre|cinema|marketplace|bus_station|place_of_worship|community_centre)\$"]["name"]($_bbox);
  nwr["shop"~"^(mall|supermarket|department_store)\$"]["name"]($_bbox);
  nwr["leisure"~"^(park|stadium|sports_centre)\$"]["name"]($_bbox);
  nwr["tourism"~"^(museum|attraction)\$"]["name"]($_bbox);
  nwr["public_transport"="station"]["name"]($_bbox);
  nwr["landuse"="cemetery"]["name"]($_bbox);
  nwr["office"="government"]["name"]($_bbox);
);
out center tags;
''';

/// Las CALLES con nombre. Solo las categorías por las que pasa gente y
/// colectivos: sin `service` (entradas de cocheras), sin `track` (huellas
/// rurales), sin `footway` (senderos, casi nunca con nombre de verdad).
///
/// `out tags center`: el centro de cada way alcanza — la geometría completa
/// pesa diez veces más y el buscador necesita UN punto, no el trazado.
const _streetsQuery =
    '''
[out:json][timeout:270];
way["highway"~"^(trunk|primary|secondary|tertiary|unclassified|residential|living_street|pedestrian)\$"]["name"]($_bbox);
out tags center;
''';

/// Las localidades, para rotular calles homónimas: la San Juan de
/// Barranqueras no es la San Juan del centro de Resistencia.
const _localitiesQuery =
    '''
[out:json][timeout:270];
node["place"~"^(city|town|village)\$"]["name"]($_bbox);
out;
''';

Future<void> main(List<String> args) async {
  final cacheDir = _argValue(args, '--cache');
  final outputPath = _argValue(args, '--out') ?? 'assets/places.json';

  stdout.writeln('Ruta Libre · importador de lugares');
  stdout.writeln('bbox: $_bbox');

  final json = await _load(
    label: 'lugares',
    query: _placesQuery,
    cachePath: cacheDir == null ? null : '$cacheDir/osm_places.json',
  );

  final elements = (json['elements'] as List<dynamic>?) ?? const [];
  final raw = <RawPlace>[
    for (final element in elements.cast<Map<String, dynamic>>())
      (
        name: (element['tags'] as Map<String, dynamic>?)?['name'] as String?,
        // Los nodos traen lat/lon; ways y relations traen `center`.
        lat: _coord(element, 'lat'),
        lng: _coord(element, 'lon'),
        tags: {
          for (final entry
              in (element['tags'] as Map<String, dynamic>? ?? const {}).entries)
            entry.key: '${entry.value}',
        },
      ),
  ];

  final result = buildPlaces(raw);
  final r = result.report;

  stdout.writeln('');
  stdout.writeln('Leídos: ${r.total}');
  stdout.writeln('  sin nombre:             ${r.sinNombre}');
  stdout.writeln('  sin coordenada:         ${r.sinCoordenada}');
  stdout.writeln('  categoría no listada:   ${r.categoriaDesconocida}');
  stdout.writeln('  fuera del área urbana:  ${r.fueraDelArea}');
  stdout.writeln('  duplicados (<150 m):    ${r.duplicados}');
  stdout.writeln('  → LUGARES:              ${result.places.length}');

  final byKind = <PlaceKind, int>{};
  for (final place in result.places) {
    byKind[place.kind] = (byKind[place.kind] ?? 0) + 1;
  }
  stdout.writeln('');
  final sorted = byKind.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  for (final entry in sorted) {
    stdout.writeln('  ${entry.value.toString().padLeft(5)}  ${entry.key.name}');
  }

  // Las calles: misma fuente, otro armado (ver street_import.dart).
  final localitiesJson = await _load(
    label: 'localidades',
    query: _localitiesQuery,
    cachePath: cacheDir == null ? null : '$cacheDir/osm_localities.json',
  );
  final localities = <Locality>[
    for (final element
        in ((localitiesJson['elements'] as List<dynamic>?) ?? const [])
            .cast<Map<String, dynamic>>())
      if ((element['tags'] as Map<String, dynamic>?)?['name'] is String &&
          element['lat'] is num &&
          element['lon'] is num)
        (
          name: (element['tags'] as Map<String, dynamic>)['name'] as String,
          lat: (element['lat'] as num).toDouble(),
          lng: (element['lon'] as num).toDouble(),
        ),
  ];
  stdout.writeln('');
  stdout.writeln('Localidades: ${localities.map((l) => l.name).join(', ')}');

  final streetsJson = await _load(
    label: 'calles',
    query: _streetsQuery,
    cachePath: cacheDir == null ? null : '$cacheDir/osm_streets.json',
  );
  final rawStreets = <RawStreet>[
    for (final element
        in ((streetsJson['elements'] as List<dynamic>?) ?? const [])
            .cast<Map<String, dynamic>>())
      (
        name: (element['tags'] as Map<String, dynamic>?)?['name'] as String?,
        lat: _coord(element, 'lat'),
        lng: _coord(element, 'lon'),
      ),
  ];
  final streetResult = buildStreets(rawStreets, localities);
  final sr = streetResult.report;
  stdout.writeln('');
  stdout.writeln('Ways de calles leídos: ${sr.total}');
  stdout.writeln('  sin nombre:             ${sr.sinNombre}');
  stdout.writeln('  sin coordenada:         ${sr.sinCoordenada}');
  stdout.writeln('  fuera del área urbana:  ${sr.fueraDelArea}');
  stdout.writeln('  → CALLES:               ${sr.calles}');

  // Un solo asset, orden estable global: regenerar sin cambios en la fuente
  // tiene que dar diff vacío.
  final combined = [...result.places, ...streetResult.streets]
    ..sort((a, b) {
      final byName = normalizeName(a.name).compareTo(normalizeName(b.name));
      if (byName != 0) return byName;
      return a.lat.compareTo(b.lat);
    });

  final encoded = jsonEncode(encodePlaces(combined));
  final file = File(outputPath);
  await file.parent.create(recursive: true);
  await file.writeAsString(encoded);

  stdout.writeln('');
  stdout.writeln(
    '$outputPath escrito (${(encoded.length / 1024).toStringAsFixed(0)} KB).',
  );
}

double? _coord(Map<String, dynamic> element, String key) {
  final direct = element[key];
  if (direct is num) return direct.toDouble();
  final center = element['center'];
  if (center is Map<String, dynamic> && center[key] is num) {
    return (center[key] as num).toDouble();
  }
  return null;
}

String? _argValue(List<String> args, String flag) {
  final index = args.indexOf(flag);
  if (index < 0 || index + 1 >= args.length) return null;
  return args[index + 1];
}

/// Igual que el importador de recorridos: cache en disco para no castigar un
/// servicio público y gratuito mientras se itera.
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
      stdout.writeln('  falló ($error), pruebo el próximo endpoint');
      lastError = error;
    }
  }
  throw StateError('No se pudo descargar $label de Overpass: $lastError');
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
