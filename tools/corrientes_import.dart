/// CLI: baja los recorridos urbanos de Corrientes capital del portal de
/// datos abiertos municipal y genera el SQL de carga.
///
///   dart run tools/corrientes_import.dart
///   dart run tools/corrientes_import.dart --csv ruta/al/recorridosurbanos.csv
///   dart run tools/corrientes_import.dart --paradas ruta/al/paradas.csv
///
/// Con `--paradas` también carga las PARADAS del municipio y las ordena
/// sobre cada recorrido, que es lo que hace que el planificador funcione en
/// Corrientes. De dónde sale ese CSV y por qué se puede usar:
/// `docs/corrientes-paradas-archivadas.md`.
///
/// `--calles` apunta a la respuesta de Overpass con el callejero (la que
/// deja `corrientes_stops_import.dart --cache`): sin eso las paradas se
/// llaman "Parada 1234", que es verdadero pero inútil.
///
/// No toca la base: emite `supabase/seed/seed_corrientes.sql` para poder
/// revisarlo en el diff antes de aplicarlo.
library;

import 'dart:convert';
import 'dart:io';

import 'src/corrientes_import.dart';
import 'src/corrientes_stops_csv.dart';
import 'src/geometry.dart';
import 'src/stop_naming.dart';

const _sourceUrl =
    'https://datos.ciudaddecorrientes.gov.ar/dataset/bd941d41-8906-4494-9e31-135d4c309de2/'
    'resource/b60f67ef-bf0e-459e-98ff-2cde25c486dc/download/recorridosurbanos.csv';

const _outputPath = 'supabase/seed/seed_corrientes.sql';

/// El recurso de paradas que el municipio retiró del portal, recuperado del
/// Internet Archive. Ver `docs/corrientes-paradas-archivadas.md`.
const _stopsUrl =
    'https://web.archive.org/web/20220625135303id_/'
    'https://datos.ciudaddecorrientes.gov.ar/dataset/'
    'bd941d41-8906-4494-9e31-135d4c309de2/resource/'
    'a8d8893c-4e50-497f-85e8-4e57de960e2c/download/paradas-colectivos.csv';

/// Cuántas paradas se quedaron sin esquina, para el resumen final.
int Function()? _sinEsquina;

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

  final result = importCorrientes(csv);

  // Paradas: opcionales, porque el recorrido solo ya sirve para dibujar el
  // mapa. Sin ellas el planificador no funciona, pero la app tampoco miente.
  CorrientesStopsResult? stops;
  String? stopsUrl;
  final paradasArg = _flag(args, '--paradas');
  final callesArg = _flag(args, '--calles');
  if (paradasArg != null || args.contains('--con-paradas')) {
    final String paradasCsv;
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
    stops = placeStops(stops: crudas, variants: result.variants);
    for (final a in avisos) {
      stdout.writeln('  aviso: $a');
    }
  }

  // El callejero, para bautizar cada parada con su esquina. Es el mismo
  // índice que usan los dos importadores de OSM.
  String Function(GeoPoint)? nombrar;
  if (stops != null) {
    // Con `--calles` usa la respuesta cruda de Overpass (mejor geometría);
    // sin eso, el asset de alturas que ya viaja en el repo. Nunca inventa:
    // si el callejero no alcanza, la parada se queda con su código.
    final json =
        jsonDecode(
              File(callesArg ?? 'assets/addresses.json').readAsStringSync(),
            )
            as Map<String, dynamic>;
    final index = StreetIndex(
      callesArg != null
          ? streetsFromOverpass(json)
          : streetsFromAddressAsset(json),
    );
    var sinEsquina = 0;
    nombrar = (p) {
      final derivado = deriveStopName(p, index);
      if (derivado == null) sinEsquina++;
      return derivado ?? '';
    };
    _sinEsquina = () => sinEsquina;
  }

  final sql = emitCorrientesSql(
    result,
    generatedAt: DateTime.now().toUtc().toIso8601String(),
    sourceUrl: _sourceUrl,
    stops: stops,
    stopsSourceUrl: stopsUrl,
    stopName: nombrar,
  );
  File(outputPath).writeAsStringSync(sql);

  final enRecorridos = stops?.byVariant.values.fold(0, (n, v) => n + v.length);
  final sinEsquina = _sinEsquina?.call();
  stdout
    ..writeln('')
    ..writeln('Líneas:     ${result.lines.length}')
    ..writeln('Recorridos: ${result.variants.length}')
    ..writeln(
      'Paradas:    ${stops?.stops.length ?? 0}'
      '${enRecorridos == null ? "" : " ($enRecorridos en secuencias)"}',
    );
  if (sinEsquina != null && sinEsquina > 0) {
    stdout.writeln('            $sinEsquina sin esquina derivada');
  }
  if (stops != null) {
    for (final w in stops.warnings) {
      stdout.writeln('  · $w');
    }
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
    ..writeln('Escrito: $outputPath')
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
