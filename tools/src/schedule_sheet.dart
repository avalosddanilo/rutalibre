/// Lectura de las tablas de horarios y su paso a SQL.
///
/// Los horarios NO salen de OpenStreetMap ni de ningún portal de datos: no
/// existe fuente abierta en el Gran Resistencia (ver
/// `docs/propuesta-datos-abiertos.md`). Se transcriben A MANO de lo que
/// publican las empresas, y por eso el formato de entrada está pensado para
/// UNA sola cosa: que se pueda comparar de un vistazo contra la foto de la
/// tabla original. Un horario mal tipeado es alguien parado en la vereda.
///
/// Formato — una línea por (recorrido, tipos de día), campos con `|`:
///
///     red | línea | ramal | sentido | tipos de día | salidas
///     interurbano-chaco-corrientes | 904 | A | ida | weekday | 05:35, 06:25
///
/// * `ramal` vacío = la línea no tiene ramales.
/// * `sentido`: `ida` o `vuelta` (0 y 1 en la base).
/// * `tipos de día`: `weekday`, `saturday`, `sunday_holiday`, o varios
///   unidos con `+` cuando comparten tabla (`saturday+sunday_holiday`), que
///   es como las publican las empresas.
/// * Comentarios con `#`. Las líneas en blanco se ignoran.
///
/// Dart PURO — sin red, sin SQL, sin archivos.
library;

import 'sql_emitter.dart' show sqlString;

/// Los tres tipos de día del esquema (`public.day_type`).
const dayTypes = ['weekday', 'saturday', 'sunday_holiday'];

/// Una tabla de salidas: un recorrido, uno o más tipos de día.
class ScheduleSheet {
  const ScheduleSheet({
    required this.networkCode,
    required this.lineCode,
    required this.branch,
    required this.direction,
    required this.dayTypes,
    required this.departures,
  });

  final String networkCode;
  final String lineCode;

  /// Ramal, o null si la línea no tiene.
  final String? branch;

  /// 0 = ida, 1 = vuelta.
  final int direction;

  /// Tipos de día que comparten esta tabla.
  final List<String> dayTypes;

  /// Salidas desde cabecera, `HH:mm`, ordenadas y sin repetidos.
  final List<String> departures;

  String get label =>
      '$networkCode/$lineCode${branch ?? ''} '
      '${direction == 0 ? 'ida' : 'vuelta'}';
}

/// Lo que se pudo leer, más lo que hay que mirar.
class ScheduleParseResult {
  const ScheduleParseResult({required this.sheets, required this.warnings});

  final List<ScheduleSheet> sheets;

  /// Problemas que NO impidieron leer (repetidos, tablas vacías…).
  final List<String> warnings;

  int get departureCount =>
      sheets.fold(0, (sum, s) => sum + s.departures.length * s.dayTypes.length);
}

/// Excepción de formato. Se aborta en vez de adivinar: un horario inventado
/// es peor que no tener horarios.
class ScheduleFormatException implements Exception {
  const ScheduleFormatException(this.lineNumber, this.message);

  final int lineNumber;
  final String message;

  @override
  String toString() => 'línea $lineNumber: $message';
}

ScheduleParseResult parseScheduleSheets(String text) {
  final sheets = <ScheduleSheet>[];
  final warnings = <String>[];
  final seen = <String>{};

  final lines = text.split('\n');
  for (var i = 0; i < lines.length; i++) {
    final lineNumber = i + 1;
    final raw = lines[i].split('#').first.trim();
    if (raw.isEmpty) continue;

    final fields = raw.split('|').map((f) => f.trim()).toList();
    if (fields.length != 6) {
      throw ScheduleFormatException(
        lineNumber,
        'se esperaban 6 campos separados por "|" y hay ${fields.length}',
      );
    }

    final [
      networkCode,
      lineCode,
      branchField,
      directionField,
      dayField,
      timesField,
    ] = fields;
    if (networkCode.isEmpty || lineCode.isEmpty) {
      throw ScheduleFormatException(lineNumber, 'red y línea son obligatorias');
    }

    final direction = switch (directionField.toLowerCase()) {
      'ida' => 0,
      'vuelta' => 1,
      _ => throw ScheduleFormatException(
        lineNumber,
        'sentido "$directionField": se esperaba "ida" o "vuelta"',
      ),
    };

    final days = dayField.split('+').map((d) => d.trim()).toList();
    for (final day in days) {
      if (!dayTypes.contains(day)) {
        throw ScheduleFormatException(
          lineNumber,
          'tipo de día "$day": se esperaba uno de ${dayTypes.join(', ')}',
        );
      }
    }
    if (days.toSet().length != days.length) {
      throw ScheduleFormatException(lineNumber, 'tipo de día repetido');
    }

    final departures = <String>[];
    final duplicated = <String>[];
    for (final piece in timesField.split(',')) {
      final time = piece.trim();
      if (time.isEmpty) continue;
      final normalized = _normalizeTime(time, lineNumber);
      if (departures.contains(normalized)) {
        duplicated.add(normalized);
        continue;
      }
      departures.add(normalized);
    }
    if (departures.isEmpty) {
      throw ScheduleFormatException(lineNumber, 'no hay ninguna salida');
    }
    if (duplicated.isNotEmpty) {
      // No es fatal —`unique (recorrido, día, hora)` lo aguanta— pero casi
      // siempre es un renglón mal copiado de la tabla original.
      warnings.add(
        'línea $lineNumber: salidas repetidas ${duplicated.join(', ')} '
        '— revisar contra la tabla original',
      );
    }

    // El orden lo pone el importador y no quien tipea: las empresas publican
    // por coche, no por hora.
    departures.sort();

    final branch = branchField.isEmpty ? null : branchField;
    for (final day in days) {
      final key = '$networkCode/$lineCode/${branch ?? ''}/$direction/$day';
      if (!seen.add(key)) {
        throw ScheduleFormatException(
          lineNumber,
          'ya había una tabla para $key — se pisarían entre sí',
        );
      }
    }

    sheets.add(
      ScheduleSheet(
        networkCode: networkCode,
        lineCode: lineCode,
        branch: branch,
        direction: direction,
        dayTypes: days,
        departures: departures,
      ),
    );
  }

  return ScheduleParseResult(sheets: sheets, warnings: warnings);
}

/// `H:mm`, `HH:mm` o `HH.mm` → `HH:mm`.
///
/// Se acepta el punto porque así lo publica Ataco Norte, y se valida el
/// rango: `25:00` sería un tipeo, no un horario nocturno.
String _normalizeTime(String value, int lineNumber) {
  final match = RegExp(r'^(\d{1,2})[:.](\d{2})$').firstMatch(value);
  if (match == null) {
    throw ScheduleFormatException(
      lineNumber,
      'hora "$value": se esperaba HH:mm',
    );
  }
  final hours = int.parse(match.group(1)!);
  final minutes = int.parse(match.group(2)!);
  if (hours > 23 || minutes > 59) {
    throw ScheduleFormatException(lineNumber, 'hora "$value" fuera de rango');
  }
  return '${hours.toString().padLeft(2, '0')}:'
      '${minutes.toString().padLeft(2, '0')}';
}

/// SQL idempotente para cargar las tablas.
///
/// Cada (recorrido, tipo de día) se REEMPLAZA entero: si una empresa saca
/// una salida, tiene que desaparecer de la base y no quedar colgada.
String emitScheduleSql(
  ScheduleParseResult result, {
  required String generatedAt,
  required String sourceNote,
}) {
  final buffer = StringBuffer()
    ..writeln('-- ${'=' * 68}')
    ..writeln('-- RUTA LIBRE — Horarios')
    ..writeln('--')
    ..writeln('-- GENERADO AUTOMÁTICAMENTE por tools/schedules_import.dart.')
    ..writeln('-- No editar a mano: se regenera con')
    ..writeln('--   dart run tools/schedules_import.dart')
    ..writeln('--')
    ..writeln('-- La fuente editable es supabase/seed/horarios/*.txt.')
    ..writeln('--')
    ..writeln('-- FUENTE: $sourceNote')
    ..writeln('-- Generado: $generatedAt')
    ..writeln(
      '-- Tablas: ${result.sheets.length} | '
      'Salidas: ${result.departureCount}',
    )
    ..writeln('--')
    ..writeln('-- OJO: los horarios se transcriben A MANO de lo que publican')
    ..writeln('-- las empresas. Verificar contra la fuente ANTES de correr.')
    ..writeln('-- ${'=' * 68}')
    ..writeln()
    ..writeln('begin;')
    ..writeln();

  for (final sheet in result.sheets) {
    final selector = _variantSelector(sheet);
    buffer
      ..writeln('-- ${'-' * 60}')
      ..writeln(
        '-- ${sheet.label} · ${sheet.dayTypes.join(' + ')} '
        '(${sheet.departures.length} salidas)',
      )
      ..writeln('-- ${'-' * 60}');

    for (final dayType in sheet.dayTypes) {
      buffer
        ..writeln('delete from public.schedules')
        ..writeln(' where day_type = ${sqlString(dayType)}::public.day_type')
        ..writeln('   and route_variant_id in ($selector);')
        ..writeln(
          'insert into public.schedules '
          '(route_variant_id, day_type, departure_time)',
        )
        ..writeln(
          'select rv.id, ${sqlString(dayType)}::public.day_type, t.departure',
        )
        ..writeln('  from (values');
      for (var i = 0; i < sheet.departures.length; i++) {
        final comma = i == sheet.departures.length - 1 ? '' : ',';
        buffer.writeln(
          '         (${sqlString(sheet.departures[i])}::time)$comma',
        );
      }
      buffer
        ..writeln('       ) as t(departure)')
        ..writeln('  cross join ($selector) rv')
        ..writeln(
          'on conflict (route_variant_id, day_type, departure_time) '
          'do nothing;',
        )
        ..writeln();
    }
  }

  buffer
    ..writeln('commit;')
    ..writeln()
    ..writeln('-- ${'=' * 68}')
    ..writeln('-- CONTROL — debería devolver una fila por tabla cargada')
    ..writeln('-- ${'=' * 68}')
    ..writeln('-- select l.code, rv.branch, rv.direction, s.day_type,')
    ..writeln(
      '--        count(*) as salidas, min(s.departure_time) as primera,',
    )
    ..writeln('--        max(s.departure_time) as ultima')
    ..writeln('--   from public.schedules s')
    ..writeln(
      '--   join public.route_variants rv on rv.id = s.route_variant_id',
    )
    ..writeln('--   join public.lines l on l.id = rv.line_id')
    ..writeln('--  group by 1, 2, 3, 4 order by 1, 2, 3, 4;');

  if (result.warnings.isNotEmpty) {
    buffer
      ..writeln('--')
      ..writeln('-- Advertencias (${result.warnings.length}):');
    for (final warning in result.warnings) {
      buffer.writeln('--   · $warning');
    }
  }

  return buffer.toString();
}

/// Subconsulta que resuelve el recorrido por (red, línea, ramal, sentido).
///
/// No se usa el id: los uuid los genera la base y cambian entre entornos.
String _variantSelector(ScheduleSheet sheet) {
  final branch = sheet.branch == null
      ? 'rv.branch is null'
      : 'rv.branch = ${sqlString(sheet.branch)}';
  return 'select rv.id from public.route_variants rv '
      'join public.lines l on l.id = rv.line_id '
      'join public.networks n on n.id = l.network_id '
      'where n.code = ${sqlString(sheet.networkCode)} '
      'and l.code = ${sqlString(sheet.lineCode)} '
      'and $branch and rv.direction = ${sheet.direction}';
}
