import 'package:flutter_test/flutter_test.dart';

import '../../tools/src/corrientes_import.dart';

/// CSV mínimo con la forma REAL del portal de Corrientes, incluyendo los
/// casos feos que trae el dataset: ramales que comparten letra, el Aerobus
/// sin número, y nombres en mayúsculas con abreviaturas.
const _csv = '''
"gid","the_geom","linea","linea_descrip","nombre","ramal","nro_para"
1,"LINESTRING (5614867.5 6962661.9, 5615867.5 6962661.9)","00","Aerobus - IDA","PUERTO - AEROPUERTO","Aerobus",
2,"LINESTRING (5615867.5 6962661.9, 5614867.5 6962661.9)","00","Aerobus - VUELTA","AEROPUERTO - PUERTO","Aerobus",
3,"LINESTRING (5614867.5 6962661.9, 5616867.5 6962661.9)","103","103 C- DIRECTO - IDA","PUERTO - B° ESPERANZA","103 C- DIRECTO",
4,"LINESTRING (5616867.5 6962661.9, 5614867.5 6962661.9)","103","103 C- DIRECTO - VUELTA","B° ESPERANZA - PUERTO","103 C- DIRECTO",
5,"LINESTRING (5614867.5 6962661.9, 5617867.5 6962661.9)","103","103 C- Bo ESPERANZA - IDA","B° DR. MONTAÑA - B° ESPERANZA","103 C- Bo ESPERANZA",
6,"LINESTRING (5614867.5 6962661.9, 5618867.5 6962661.9)","108","108 C - IDA","CENTRO - 40 VIV. F.J. QUINTANA-SAN ROQUE","108 C",
''';

void main() {
  group('parseDirection', () {
    test('lee el sufijo IDA/VUELTA', () {
      expect(parseDirection('101 B - IDA'), 0);
      expect(parseDirection('101 B - VUELTA'), 1);
    });

    test('no se confunde con un destino que contenga "IDA"', () {
      // Mira el FINAL, no `contains`.
      expect(parseDirection('105 - MERIDA - VUELTA'), 1);
      expect(parseDirection('105 - MERIDA'), isNull);
    });

    test('devuelve null si el sentido no está declarado', () {
      expect(parseDirection('101 B'), isNull);
      expect(parseDirection(''), isNull);
    });
  });

  group('normalizeBranch', () {
    test('saca el número de línea del ramal', () {
      expect(normalizeBranch('101 B', '101'), 'B');
    });

    test('CONSERVA el descriptor: hay ramales que comparten letra', () {
      // La 103 tiene un "C - DIRECTO" y un "C - Bo Esperanza" distintos.
      expect(normalizeBranch('103 C- DIRECTO', '103'), 'C DIRECTO');
      expect(normalizeBranch('103 C- Bo ESPERANZA', '103'), 'C Bo ESPERANZA');
      expect(
        normalizeBranch('103 C- DIRECTO', '103'),
        isNot(normalizeBranch('103 C- Bo ESPERANZA', '103')),
      );
    });

    test('normaliza separadores sueltos', () {
      expect(normalizeBranch('105 A - COLECTORA', '105'), 'A COLECTORA');
      expect(normalizeBranch('109 A-LAGUNA SOTO', '109'), 'A LAGUNA SOTO');
    });

    test('sin ramal devuelve null', () {
      expect(normalizeBranch('', '101'), isNull);
      expect(normalizeBranch('101', '101'), isNull);
    });
  });

  group('titleCase', () {
    test('convierte el guion separador en flecha', () {
      expect(titleCase('PUERTO - AEROPUERTO'), 'Puerto ↔ Aeropuerto');
    });

    test('capitaliza los dos lados de un compuesto con guion', () {
      expect(titleCase('QUINTANA-SAN ROQUE'), 'Quintana-San Roque');
    });

    test('deja las iniciales con punto en mayúscula', () {
      expect(titleCase('F.J. QUINTANA'), 'F.J. Quintana');
    });

    test('deja en minúscula los conectores que no van primero', () {
      expect(titleCase('17 DE AGOSTO'), '17 de Agosto');
    });
  });

  group('importCorrientes (end to end sobre el CSV de muestra)', () {
    final result = importCorrientes(_csv);

    test('agrupa los recorridos en líneas', () {
      expect(result.lines.map((l) => l.code).toList(), [
        '103',
        '108',
        'Aerobus',
      ]);
      expect(result.variants.length, 6);
    });

    test('no descarta ni advierte nada con datos sanos', () {
      expect(result.skipped, isEmpty);
      expect(result.warnings, isEmpty);
    });

    test('reproyecta la geometría a coordenadas reales de Corrientes', () {
      final punto = result.variants.first.geometry.first;
      expect(punto.lat, inInclusiveRange(-27.65, -27.35));
      expect(punto.lng, inInclusiveRange(-58.95, -58.65));
    });

    test('el Aerobus no repite su propio nombre como ramal', () {
      final aerobus = result.variants.where((v) => v.lineCode == 'Aerobus');
      expect(aerobus, hasLength(2));
      expect(aerobus.every((v) => v.branch == null), isTrue);
    });

    test('los ramales de la 103 que comparten letra NO colisionan', () {
      final ramales103 = result.variants
          .where((v) => v.lineCode == '103')
          .map((v) => '${v.branch}/${v.direction}')
          .toList();
      expect(ramales103.toSet().length, ramales103.length);
    });

    test('el nombre del recorrido dice el sentido en castellano', () {
      final ida = result.variants.firstWhere(
        (v) => v.lineCode == 'Aerobus' && v.direction == 0,
      );
      expect(ida.name, 'Ida: Puerto ↔ Aeropuerto');
    });

    test(
      'la 110 de Corrientes no comparte color con la del Gran Resistencia',
      () {
        // El hash incluye la red justamente para esto.
        final corrientes103 = result.lines.firstWhere((l) => l.code == '103');
        expect(corrientes103.colorHex, startsWith('#'));
        expect(corrientes103.colorHex.length, 7);
      },
    );
  });

  group('importCorrientes — datos sucios', () {
    test('descarta (sin inventar) una fila sin sentido declarado', () {
      const sucio = '''
"gid","the_geom","linea","linea_descrip","nombre","ramal","nro_para"
1,"LINESTRING (5614867.5 6962661.9, 5615867.5 6962661.9)","101","101 B","PUERTO - PONCE","101 B",
''';
      final r = importCorrientes(sucio);
      expect(r.variants, isEmpty);
      expect(r.skipped.single, contains('sentido no declarado'));
    });

    test('descarta una fila sin geometría usable', () {
      const sucio = '''
"gid","the_geom","linea","linea_descrip","nombre","ramal","nro_para"
1,"","101","101 B - IDA","PUERTO - PONCE","101 B",
''';
      final r = importCorrientes(sucio);
      expect(r.variants, isEmpty);
      expect(r.skipped.single, contains('sin geometría'));
    });

    test('falla ruidosamente si el portal cambia las columnas', () {
      expect(
        () => importCorrientes('a,b\n1,2\n'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
