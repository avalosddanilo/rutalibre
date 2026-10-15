/// CLI: baja los recorridos urbanos de Corrientes capital del portal de
/// datos abiertos municipal y genera el SQL de carga.
///
///   dart run tools/corrientes_import.dart
///   dart run tools/corrientes_import.dart --csv ruta/al/recorridosurbanos.csv
///   dart run tools/corrientes_import.dart --paradas ruta/al/paradas.csv
///
/// Carga también las PARADAS del municipio y las ordena sobre cada
/// recorrido, que es lo que hace que el planificador funcione en Corrientes.
/// Por defecto las baja de la copia del Internet Archive; `--paradas` usa un
/// CSV local. De dónde sale ese CSV y por qué se puede usar:
/// `docs/corrientes-paradas-archivadas.md`.
///
/// Las paradas NO son opcionales: si la fuente viene vacía o no se puede
/// bajar, el importador falla y no escribe nada. Un seed sin paradas borra
/// el planificador de Corrientes entero (ver `stopsFailure`).
///
/// El callejero, para bautizar las paradas con su esquina, se baja de
/// Overpass. `--calles ARCHIVO` usa una respuesta de Overpass ya bajada, y
/// `--calles-asset` el asset de alturas, sin red (con ese, cerca de 500
/// paradas quedan "Parada 1234", que es verdadero pero inútil).
///
/// No toca la base: emite `supabase/seed/seed_corrientes.sql` para poder
/// revisarlo en el diff antes de aplicarlo. Si lo único que cambiaría es la
/// fecha de extracción, deja el archivo como está: así regenerar sin cambios
/// da un diff limpio.
library;

import 'dart:convert';
import 'dart:io';

import 'src/corrientes_correcciones.dart';
import 'src/corrientes_import.dart';
import 'src/corrientes_stops_csv.dart';
import 'src/geometry.dart';
import 'src/overpass.dart';
import 'src/stop_naming.dart';

const _sourceUrl =
    'https://datos.ciudaddecorrientes.gov.ar/dataset/bd941d41-8906-4494-9e31-135d4c309de2/'
    'resource/b60f67ef-bf0e-459e-98ff-2cde25c486dc/download/recorridosurbanos.csv';

const _outputPath = 'supabase/seed/seed_corrientes.sql';

const _correccionesPath = 'tools/data/corrientes_correcciones.json';

/// Corrientes capital y alrededores: (sur, oeste, norte, este).
const _streetsBbox = '-27.60,-58.88,-27.40,-58.68';

/// El mismo filtro de calles que el importador del Gran Resistencia.
const _streetsQuery =
    '''
[out:json][timeout:180];
way["highway"~"^(motorway|trunk|primary|secondary|tertiary|unclassified|residential|living_street)\$"]["name"]($_streetsBbox);
out body;
>;
out skel qt;
''';

/// El recurso de paradas que el municipio retiró del portal, recuperado del
/// Internet Archive. Ver `docs/corrientes-paradas-archivadas.md`.
const _stopsUrl =
    'https://web.archive.org/web/20220625135303id_/'
    'https://datos.ciudaddecorrientes.gov.ar/dataset/'
    'bd941d41-8906-4494-9e31-135d4c309de2/resource/'
    'a8d8893c-4e50-497f-85e8-4e57de960e2c/download/paradas-colectivos.csv';

Future<void> main(List<String> args) async {
  final localCsv = _flag(args, '--csv');
  final outputPath = _flag(args, '--out') ?? _outputPath;

  final String csv;
  if (localCsv != null) {
    stdout.writeln('Leyendo $localCsv');
    csv = File(localCsv).readAsStringSync();
  } else {
    stdout.writeln('Bajando el CSV del portal de Corrientes…');
    csv = await _download(_sourceUrl);
  }

  // Los recorridos que cambiaron y el portal todavía no publicó: ver
  // tools/src/corrientes_correcciones.dart.
  final correcciones = parseCorrections(
    jsonDecode(File(_correccionesPath).readAsStringSync())
        as Map<String, dynamic>,
  );
  final result = applyRouteCorrections(importCorrientes(csv), correcciones);

  // Paradas: siempre. Antes eran opt-in (`--con-paradas`) y el CI, que
  // corría sin el flag, regeneraba un seed sin ellas. `--con-paradas` se
  // sigue aceptando para no romper a quien lo tenga anotado, pero ya no
  // cambia nada.
  final String stopsUrl;
  final String paradasCsv;
  final paradasArg = _flag(args, '--paradas');
  final callesArg = _flag(args, '--calles');
  if (paradasArg != null) {
    stdout.writeln('Leyendo paradas de $paradasArg');
    paradasCsv = File(paradasArg).readAsStringSync();
    stopsUrl = paradasArg;
  } else {
    stdout.writeln('Bajando las paradas del archivo…');
    paradasCsv = await _download(_stopsUrl);
    stopsUrl = _stopsUrl;
  }
  final (crudas, avisos) = parseMunicipalStops(paradasCsv);
  final stops = applyStopCorrections(
    placeStops(stops: crudas, variants: result.variants),
    all: crudas,
    corrections: correcciones,
  );
  for (final a in avisos) {
    stdout.writeln('  aviso: $a');
  }
  final falla = stopsFailure(parsed: crudas.length, placed: stops);
  if (falla != null) {
    stderr
      ..writeln('')
      ..writeln('ERROR: $falla.')
      ..writeln('  Fuente: $stopsUrl')
      ..writeln('  No se escribió $outputPath: un seed sin paradas borraría')
      ..writeln('  el planificador de Corrientes.');
    exit(1);
  }

  // El callejero, para bautizar cada parada con su esquina. Es el mismo
  // índice que usan los dos importadores de OSM.
  //
  // Por defecto se baja de Overpass, como en el importador del Gran
  // Resistencia: con el asset de alturas —que era el default— 496 de las
  // 1357 paradas quedaban "Parada 1234", porque esas alturas son portales y
  // no el eje de la calle. `--calles ARCHIVO` usa una respuesta de Overpass
  // ya bajada, y `--calles-asset` el asset, para trabajar sin red. Nunca
  // inventa: si el callejero no alcanza, la parada se queda con su código.
  final List<NamedStreet> streets;
  if (args.contains('--calles-asset')) {
    stdout.writeln('Callejero: assets/addresses.json (sin red)');
    streets = streetsFromAddressAsset(
      jsonDecode(File('assets/addresses.json').readAsStringSync())
          as Map<String, dynamic>,
    );
  } else if (callesArg != null) {
    stdout.writeln('Callejero: $callesArg');
    streets = streetsFromOverpass(
      jsonDecode(File(callesArg).readAsStringSync()) as Map<String, dynamic>,
    );
  } else {
    streets = streetsFromOverpass(
      await loadOverpass(label: 'callejero', query: _streetsQuery),
    );
  }
  final index = StreetIndex(streets);
  var sinEsquina = 0;
  String nombrar(GeoPoint p) {
    final derivado = deriveStopName(p, index);
    if (derivado == null) sinEsquina++;
    return derivado ?? '';
  }

  final sql = emitCorrientesSql(
    result,
    generatedAt: DateTime.now().toUtc().toIso8601String(),
    sourceUrl: _sourceUrl,
    stops: stops,
    stopsSourceUrl: stopsUrl,
    stopName: nombrar,
  );
  final output = File(outputPath);
  final sinCambios =
      output.existsSync() &&
      sameSeedIgnoringDate(output.readAsStringSync(), sql);
  if (!sinCambios) output.writeAsStringSync(sql);

  final enRecorridos = stops.byVariant.values.fold(0, (n, v) => n + v.length);
  stdout
    ..writeln('')
    ..writeln('Líneas:     ${result.lines.length}')
    ..writeln('Recorridos: ${result.variants.length}')
    ..writeln(
      'Paradas:    ${stops.stops.length} ($enRecorridos en secuencias)',
    );
  if (sinEsquina > 0) {
    stdout.writeln('            $sinEsquina sin esquina derivada');
  }
  for (final w in stops.warnings) {
    stdout.writeln('  · $w');
  }

  if (result.skipped.isNotEmpty) {
    stdout.writeln('\nDescartadas (${result.skipped.length}):');
    for (final s in result.skipped) {
      stdout.writeln('  · $s');
    }
  }
  if (result.warnings.isNotEmpty) {
    stdout.writeln('\nAdvertencias (${result.warnings.length}):');
    for (final w in result.warnings) {
      stdout.writeln('  · $w');
    }
  }

  stdout
    ..writeln('')
    ..writeln(
      sinCambios
          ? 'Sin cambios: $outputPath ya coincide (salvo la fecha).'
          : 'Escrito: $outputPath',
    )
    ..writeln('Aplicalo DESPUÉS de la migración 0003.');
}

String? _flag(List<String> args, String name) {
  final i = args.indexOf(name);
  if (i < 0 || i + 1 >= args.length) return null;
  return args[i + 1];
}

Future<String> _download(String url) async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 30);
  try {
    final request = await client.getUrl(Uri.parse(url));
    request.headers.set(HttpHeaders.userAgentHeader, 'ruta-libre-importer/1.0');
    final response = await request.close();
    if (response.statusCode != 200) {
      throw HttpException(
        'El portal respondió ${response.statusCode}',
        uri: Uri.parse(url),
      );
    }
    return await response.transform(utf8.decoder).join();
  } finally {
    client.close();
  }
}
