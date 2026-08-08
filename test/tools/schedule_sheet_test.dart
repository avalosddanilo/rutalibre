import 'package:flutter_test/flutter_test.dart';

import '../../tools/src/schedule_sheet.dart';

const _line =
    'interurbano-chaco-corrientes | 904 | A | ida | weekday | 05:35, 06:25';

void main() {
  group('parseScheduleSheets', () {
    test('lee una tabla completa', () {
      final result = parseScheduleSheets(_line);
      final sheet = result.sheets.single;

      expect(sheet.networkCode, 'interurbano-chaco-corrientes');
      expect(sheet.lineCode, '904');
      expect(sheet.branch, 'A');
      expect(sheet.direction, 0);
      expect(sheet.dayTypes, ['weekday']);
      expect(sheet.departures, ['05:35', '06:25']);
      expect(result.warnings, isEmpty);
    });

    test('vuelta es el sentido 1', () {
      final result = parseScheduleSheets(
        'red | 9 |  | vuelta | saturday | 07:00',
      );
      expect(result.sheets.single.direction, 1);
      // Ramal vacío es "la línea no tiene ramales", no el ramal "".
      expect(result.sheets.single.branch, isNull);
    });

    test('un solo renglón puede valer para varios tipos de día: así las '
        'publican las empresas', () {
      final result = parseScheduleSheets(
        'red | 904 | A | ida | saturday+sunday_holiday | 06:00, 07:30',
      );
      expect(result.sheets.single.dayTypes, ['saturday', 'sunday_holiday']);
      // Dos tipos de día × dos salidas = cuatro filas en la base.
      expect(result.departureCount, 4);
    });

    test('ignora comentarios y líneas en blanco', () {
      final result = parseScheduleSheets('''
# esto es un comentario

$_line   # y esto también
''');
      expect(result.sheets, hasLength(1));
      expect(result.sheets.single.departures, ['05:35', '06:25']);
    });

    test(
      'ordena las salidas: las empresas publican por coche, no por hora',
      () {
        final result = parseScheduleSheets(
          'red | 904 | A | ida | weekday | 21:15, 05:35, 13:05',
        );
        expect(result.sheets.single.departures, ['05:35', '13:05', '21:15']);
      },
    );

    test('acepta el punto como separador (así lo publica Ataco Norte)', () {
      final result = parseScheduleSheets(
        'red | 902 |  | ida | weekday | 05.00, 6:05',
      );
      expect(result.sheets.single.departures, ['05:00', '06:05']);
    });

    test('avisa de las salidas repetidas en vez de tragárselas', () {
      final result = parseScheduleSheets(
        'red | 904 | A | ida | weekday | 05:35, 05:35, 06:25',
      );
      expect(result.sheets.single.departures, ['05:35', '06:25']);
      expect(result.warnings.single, contains('05:35'));
    });
  });

  group('formatos que tienen que ABORTAR', () {
    // Adivinar acá sería inventar un horario, y un horario inventado es
    // peor que no tener horarios.
    void expectRejects(String text, Object matcher) => expect(
      () => parseScheduleSheets(text),
      throwsA(
        isA<ScheduleFormatException>().having(
          (e) => e.message,
          'message',
          matcher,
        ),
      ),
    );

    test('cantidad de campos equivocada', () {
      expectRejects('red | 904 | A | ida | weekday', contains('6 campos'));
    });

    test('sentido desconocido', () {
      expectRejects(
        'red | 904 | A | norte | weekday | 05:35',
        contains('sentido'),
      );
    });

    test('tipo de día que no existe en el enum', () {
      expectRejects(
        'red | 904 | A | ida | lunes | 05:35',
        contains('tipo de día'),
      );
    });

    test('hora sin formato de hora', () {
      expectRejects('red | 904 | A | ida | weekday | 5,35', contains('HH:mm'));
    });

    test(
      'hora fuera de rango — 25:00 es un tipeo, no un servicio nocturno',
      () {
        expectRejects(
          'red | 904 | A | ida | weekday | 25:00',
          contains('fuera de rango'),
        );
        expectRejects(
          'red | 904 | A | ida | weekday | 12:75',
          contains('fuera de rango'),
        );
      },
    );

    test('tabla sin ninguna salida', () {
      expectRejects('red | 904 | A | ida | weekday | ', contains('salida'));
    });

    test('dos tablas para el mismo recorrido y día se pisarían', () {
      expectRejects('$_line\n$_line', contains('ya había una tabla'));
    });

    test('el choque se detecta aunque venga de un renglón multi-día', () {
      expectRejects(
        'red | 904 | A | ida | saturday+sunday_holiday | 06:00\n'
        'red | 904 | A | ida | saturday | 07:00',
        contains('ya había una tabla'),
      );
    });

    test('red o línea vacías', () {
      expectRejects(' | 904 | A | ida | weekday | 05:35', contains('línea'));
    });

    test('el número de línea del error es el del archivo', () {
      expect(
        () => parseScheduleSheets('# nota\n\n$_line\nrota'),
        throwsA(
          isA<ScheduleFormatException>().having(
            (e) => e.lineNumber,
            'línea',
            4,
          ),
        ),
      );
    });
  });

  group('emitScheduleSql', () {
    final sql = emitScheduleSql(
      parseScheduleSheets(
        'red-x | 904 | A | ida | saturday+sunday_holiday | 06:00, 07:30',
      ),
      generatedAt: '2026-08-05T00:00:00Z',
      sourceNote: 'una foto',
    );

    test('va en una sola transacción', () {
      expect(sql, contains('begin;'));
      expect(sql, contains('commit;'));
    });

    test('resuelve el recorrido por red/línea/ramal/sentido y no por id: '
        'los uuid cambian entre entornos', () {
      expect(sql, contains("n.code = 'red-x'"));
      expect(sql, contains("l.code = '904'"));
      expect(sql, contains("rv.branch = 'A'"));
      expect(sql, contains('rv.direction = 0'));
      expect(sql, isNot(contains('uuid')));
    });

    test('un ramal nulo se busca con "is null" y no con = null', () {
      final noBranch = emitScheduleSql(
        parseScheduleSheets('red-x | 9 |  | ida | weekday | 06:00'),
        generatedAt: 'x',
        sourceNote: 'y',
      );
      expect(noBranch, contains('rv.branch is null'));
    });

    test('borra antes de insertar: si sacan una salida tiene que '
        'desaparecer, no quedar colgada', () {
      final deleteAt = sql.indexOf('delete from public.schedules');
      final insertAt = sql.indexOf('insert into public.schedules');
      expect(deleteAt, greaterThanOrEqualTo(0));
      expect(deleteAt, lessThan(insertAt));
    });

    test('emite un bloque por cada tipo de día del renglón', () {
      expect("'saturday'::public.day_type".allMatches(sql).length, 2);
      expect("'sunday_holiday'::public.day_type".allMatches(sql).length, 2);
    });

    test('deja la advertencia de transcripción manual a la vista', () {
      expect(sql, contains('A MANO'));
      expect(sql, contains('una foto'));
    });
  });
}
