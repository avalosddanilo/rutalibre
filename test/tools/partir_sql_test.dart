import 'package:flutter_test/flutter_test.dart';

import '../../tools/src/partir_sql.dart';

void main() {
  group('partirSentencias', () {
    test('es sin pérdida: unir lo que devuelve da el original', () {
      const sql =
          '-- encabezado\nbegin;\n\n'
          "insert into t values (1, 'a');\n"
          '-- comentario suelto\n'
          "update t set x = 'b';\n"
          'commit;\n-- cola\n';
      expect(partirSentencias(sql).join(), sql);
    });

    test('un punto y coma adentro de un texto no corta', () {
      final s = partirSentencias(
        "insert into t values ('Parada 105; 109');\nselect 1;",
      );
      expect(s, hasLength(2));
      expect(s.first, contains("'Parada 105; 109'"));
    });

    test('las comillas escapadas duplicándose no confunden el corte', () {
      final s = partirSentencias(
        "insert into t values ('O''Higgins; centro');\nselect 2;",
      );
      expect(s, hasLength(2));
      expect(s.first, contains("O''Higgins; centro"));
    });

    test('un punto y coma en un comentario o un identificador no corta', () {
      final s = partirSentencias(
        '-- a; b\nselect 1;\n/* c; d */ select "col;x" from t;',
      );
      expect(s.where((x) => !esVacia(x)), hasLength(2));
    });

    test(r'rechaza el dollar-quoting en vez de cortar mal', () {
      expect(
        () => partirSentencias(r'do $$ begin perform 1; end $$;'),
        throwsFormatException,
      );
    });
  });

  group('armarPartes', () {
    final sentencias = partirSentencias(
      'begin;\n'
      "insert into a values ('${'x' * 40}');\n"
      "insert into b values ('${'y' * 40}');\n"
      "insert into c values ('${'z' * 40}');\n"
      'commit;\n',
    );

    test('saca el begin/commit del original y envuelve cada parte', () {
      final partes = armarPartes(sentencias, maxBytes: 70);
      expect(partes, hasLength(3));
      for (final p in partes) {
        expect(p.startsWith('begin;\n'), isTrue);
        expect(p.endsWith('\ncommit;\n'), isTrue);
        // Uno de cada, no el del original metido en el medio.
        expect(
          RegExp(r'^begin;$', multiLine: true).allMatches(p),
          hasLength(1),
        );
        expect(
          RegExp(r'^commit;$', multiLine: true).allMatches(p),
          hasLength(1),
        );
      }
    });

    test('nunca parte una sentencia, aunque supere el límite', () {
      final partes = armarPartes(sentencias, maxBytes: 10);
      expect(partes, hasLength(3));
      expect(partes.first, contains("'${'x' * 40}'"));
    });

    test('con lugar de sobra, todo entra en una sola parte', () {
      expect(armarPartes(sentencias, maxBytes: 1 << 20), hasLength(1));
    });

    test('resumen cuenta por tabla', () {
      final r = resumen(armarPartes(sentencias, maxBytes: 1 << 20).single);
      expect(r, {'insert a': 1, 'insert b': 1, 'insert c': 1});
    });
  });
}
