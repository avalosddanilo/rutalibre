import 'package:flutter_test/flutter_test.dart';

import '../../tools/src/csv_reader.dart';

void main() {
  group('parseCsvLine', () {
    test('respeta las comas dentro de comillas (el caso del the_geom)', () {
      final f = parseCsvLine('107,"LINESTRING (1 2, 3 4)",101,"101 B"');
      expect(f, ['107', 'LINESTRING (1 2, 3 4)', '101', '101 B']);
    });

    test('interpreta la comilla escapada como comilla literal', () {
      expect(parseCsvLine('"dice ""hola""",x'), ['dice "hola"', 'x']);
    });

    test('conserva los campos vacíos', () {
      expect(parseCsvLine('a,,c'), ['a', '', 'c']);
    });
  });

  group('CsvTable', () {
    const content =
        'gid,the_geom,linea\n'
        '1,"LINESTRING (1 2, 3 4)",101\n'
        '2,"LINESTRING (5 6, 7 8)",102\n';

    test('parsea encabezado y filas', () {
      final t = CsvTable.parse(content);
      expect(t.headers, ['gid', 'the_geom', 'linea']);
      expect(t.rows.length, 2);
      expect(t.value(t.rows.first, 'linea'), '101');
    });

    test('tolera CRLF', () {
      final t = CsvTable.parse('a,b\r\n1,2\r\n');
      expect(t.headers, ['a', 'b']);
      expect(t.value(t.rows.single, 'b'), '2');
    });

    test('ignora líneas en blanco al final', () {
      final t = CsvTable.parse('a,b\n1,2\n\n');
      expect(t.rows.length, 1);
    });

    test('devuelve vacío para una columna inexistente en vez de explotar', () {
      final t = CsvTable.parse(content);
      expect(t.value(t.rows.first, 'no_existe'), '');
    });

    test('requireColumns falla RUIDOSAMENTE si el origen cambió de forma', () {
      final t = CsvTable.parse(content);
      expect(
        () => t.requireColumns(['gid', 'ramal']),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
