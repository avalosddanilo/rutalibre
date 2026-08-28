import 'package:flutter_test/flutter_test.dart';

import '../../tools/src/address_import.dart';
import '../../tools/src/street_import.dart';

const _localities = <Locality>[
  (name: 'Resistencia', lat: -27.451, lng: -58.986),
  (name: 'Barranqueras', lat: -27.487, lng: -58.934),
];

RawAddress _addr(
  String? street,
  String? housenumber,
  double? lat,
  double? lng,
) => (street: street, housenumber: housenumber, lat: lat, lng: lng);

void main() {
  group('buildAddresses', () {
    test('agrupa por calle y localidad, con los números ordenados', () {
      // El caso real: San Juan existe en Resistencia Y en Barranqueras, y el
      // 5240 de una no tiene nada que ver con la otra.
      final result = buildAddresses([
        _addr('San Juan', '5250', -27.477, -58.924),
        _addr('San Juan', '5200', -27.476, -58.924),
        _addr('San Juan', '450', -27.436, -58.986),
      ], _localities);

      expect(result.streets, hasLength(2));
      final barranqueras = result.streets.firstWhere(
        (s) => s.locality == 'Barranqueras',
      );
      expect(barranqueras.street, 'San Juan');
      expect(barranqueras.numbers.map((n) => n.$1), [5200, 5250]);
      final resistencia = result.streets.firstWhere(
        (s) => s.locality == 'Resistencia',
      );
      expect(resistencia.numbers.single.$1, 450);
    });

    test('el número es el ENTERO del principio; sin número no entra', () {
      // "5240 bis" es el 5240; "S/N" no es ninguno.
      final result = buildAddresses([
        _addr('Ameghino', '1250 bis', -27.451, -58.986),
        _addr('Ameghino', 'S/N', -27.452, -58.986),
        _addr('Ameghino', null, -27.453, -58.986),
      ], _localities);

      expect(result.streets.single.numbers.single.$1, 1250);
      expect(result.report.sinNumero, 2);
    });

    test('el mismo número dos veces queda una: esquina y edificio son la '
        'misma puerta', () {
      final result = buildAddresses([
        _addr('Ameghino', '1250', -27.4510, -58.986),
        _addr('Ameghino', '1250', -27.4512, -58.986),
      ], _localities);

      expect(result.streets.single.numbers, hasLength(1));
      expect(result.report.duplicados, 1);
      // Determinista: gana el de latitud menor (−27,4512 < −27,4510), no el
      // que Overpass mandó primero.
      expect(result.streets.single.numbers.single.$2, -27.4512);
    });

    test('filtra lo de siempre y lo cuenta', () {
      final result = buildAddresses([
        _addr(null, '100', -27.451, -58.986),
        _addr('Sin coordenada', '100', null, -58.986),
        // Fuera del área urbana.
        _addr('Ruta rural', '100', -27.20, -58.986),
        _addr('Ameghino', '1250', -27.451, -58.986),
      ], _localities);

      expect(result.report.total, 4);
      expect(result.report.sinCalle, 1);
      expect(result.report.sinCoordenada, 1);
      expect(result.report.fueraDelArea, 1);
      expect(result.report.numeros, 1);
    });

    test('el orden es estable entre corridas', () {
      final raw = [
        _addr('Zeballos', '200', -27.451, -58.986),
        _addr('Ameghino', '100', -27.452, -58.986),
      ];
      final first = buildAddresses(raw, _localities);
      final second = buildAddresses(raw.reversed.toList(), _localities);

      expect(
        first.streets.map((s) => s.street).toList(),
        second.streets.map((s) => s.street).toList(),
      );
      expect(first.streets.first.street, 'Ameghino');
    });
  });

  test('encodeAddresses: arrays pelados y coordenadas a cinco decimales', () {
    final encoded = encodeAddresses([
      (
        street: 'San Juan',
        locality: 'Barranqueras',
        numbers: [(5200, -27.476431, -58.924159)],
      ),
    ]);

    expect(encoded, {
      'v': 1,
      's': [
        [
          'San Juan',
          'Barranqueras',
          [
            [5200, -27.47643, -58.92416],
          ],
        ],
      ],
    });
  });
}
