/// CLI: baja los recorridos urbanos de Corrientes capital del portal de
/// datos abiertos municipal y genera el SQL de carga.
///
///   dart run tools/corrientes_import.dart
///   dart run tools/corrientes_import.dart --csv ruta/al/recorridosurbanos.csv
///
/// No toca la base: emite `supabase/seed/seed_corrientes.sql` para poder
/// revisarlo en el diff antes de aplicarlo.
library;

import 'dart:convert';
import 'dart:io';

import 'src/corrientes_import.dart';

const _sourceUrl =
    'https://datos.ciudaddecorrientes.gov.ar/dataset/bd941d41-8906-4494-9e31-135d4c309de2/'
    'resource/b60f67ef-bf0e-459e-98ff-2cde25c486dc/download/recorridosurbanos.csv';

const _outputPath = 'supabase/seed/seed_corrientes.sql';

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

  final sql = emitCorrientesSql(
    result,
    generatedAt: DateTime.now().toUtc().toIso8601String(),
    sourceUrl: _sourceUrl,
  );
  File(outputPath).writeAsStringSync(sql);

  stdout
    ..writeln('')
    ..writeln('Líneas:     ${result.lines.length}')
    ..writeln('Recorridos: ${result.variants.length}')
    ..writeln('Paradas:    0 (el portal dio de baja el recurso)');

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
