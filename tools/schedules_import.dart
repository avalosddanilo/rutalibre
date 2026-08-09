/// Importador de horarios: de las tablas transcritas a mano al SQL de carga.
///
/// Uso:
///   dart run tools/schedules_import.dart
///   dart run tools/schedules_import.dart --in supabase/seed/horarios
///
/// Lee todos los `.txt` de `supabase/seed/horarios/` y genera
/// `supabase/seed/seed_horarios.sql`, que se corre EN EL SQL EDITOR de
/// Supabase después de los seeds de recorridos (los horarios cuelgan de
/// `route_variants`, así que los recorridos tienen que existir primero).
///
/// Por qué a mano: no hay fuente abierta de horarios en el Gran Resistencia.
/// Ver `docs/propuesta-datos-abiertos.md` — el pedido de GTFS a la
/// Secretaría de Transporte es el camino real; esto es el puente.
library;

import 'dart:io';

import 'src/schedule_sheet.dart';

Future<void> main(List<String> args) async {
  final inputDir = _argValue(args, '--in') ?? 'supabase/seed/horarios';
  final outputPath =
      _argValue(args, '--out') ?? 'supabase/seed/seed_horarios.sql';

  stdout.writeln('Ruta Libre · importador de horarios');

  final directory = Directory(inputDir);
  if (!directory.existsSync()) {
    stderr.writeln('No existe el directorio $inputDir');
    exitCode = 1;
    return;
  }

  final files =
      directory
          .listSync()
          .whereType<File>()
          .where((f) => f.path.toLowerCase().endsWith('.txt'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  if (files.isEmpty) {
    stderr.writeln('No hay archivos .txt en $inputDir');
    exitCode = 1;
    return;
  }

  final sheets = <ScheduleSheet>[];
  final warnings = <String>[];
  final sources = <String>[];

  for (final file in files) {
    final name = file.uri.pathSegments.last;
    stdout.writeln('· $name');
    final ScheduleParseResult parsed;
    try {
      parsed = parseScheduleSheets(file.readAsStringSync());
    } on ScheduleFormatException catch (error) {
      // Se aborta ENTERO: un SQL a medias cargaría la mitad de una tabla de
      // horarios, que es peor que no cargar nada.
      stderr.writeln('  ERROR en $name, $error');
      exitCode = 1;
      return;
    }
    sheets.addAll(parsed.sheets);
    warnings.addAll(parsed.warnings.map((w) => '$name — $w'));
    sources.add(name);
    stdout.writeln(
      '  ${parsed.sheets.length} tabla(s), ${parsed.departureCount} salidas',
    );
  }

  final result = ScheduleParseResult(sheets: sheets, warnings: warnings);
  final sql = emitScheduleSql(
    result,
    generatedAt: DateTime.now().toUtc().toIso8601String(),
    sourceNote:
        'transcripción manual — ver los encabezados de '
        '${sources.join(', ')} en supabase/seed/horarios/',
  );

  final file = File(outputPath);
  await file.parent.create(recursive: true);
  await file.writeAsString(sql);

  stdout.writeln('');
  stdout.writeln('Resultado:');
  stdout.writeln('  tablas:  ${result.sheets.length}');
  stdout.writeln('  salidas: ${result.departureCount}');
  for (final sheet in result.sheets) {
    stdout.writeln(
      '    ${sheet.label} · ${sheet.dayTypes.join(' + ')}: '
      '${sheet.departures.length} salidas '
      '(${sheet.departures.first} a ${sheet.departures.last})',
    );
  }
  if (warnings.isNotEmpty) {
    stdout.writeln('  Advertencias (${warnings.length}):');
    for (final warning in warnings) {
      stdout.writeln('    · $warning');
    }
  }

  stdout.writeln('');
  stdout.writeln('SQL escrito en $outputPath.');
  stdout.writeln(
    'Aplicar en Supabase → SQL Editor DESPUÉS de los seeds de recorridos.',
  );
  stdout.writeln(
    'ANTES: verificar las horas contra la fuente. Están transcritas a mano.',
  );
}

String? _argValue(List<String> args, String flag) {
  final index = args.indexOf(flag);
  if (index < 0 || index + 1 >= args.length) return null;
  return args[index + 1];
}
