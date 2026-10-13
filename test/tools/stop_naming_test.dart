import 'package:flutter_test/flutter_test.dart';

import '../../tools/src/stop_naming.dart';

/// Callejero de juguete con dos calles que se cruzan en (0, 0), en una
/// escala parecida a la de una cuadra real (~110 m por 0.001°).
///
///        Ameghino (norte-sur, sobre lng 0)
///              |
///  Sáenz Peña  |   (este-oeste, sobre lat 0)
///  ------------+------------
///              |
StreetIndex _grilla() => StreetIndex([
  const NamedStreet(
    name: 'Ameghino',
    points: [(lat: -0.01, lng: 0), (lat: 0.01, lng: 0)],
  ),
  const NamedStreet(
    name: 'Sáenz Peña',
    points: [(lat: 0, lng: -0.01), (lat: 0, lng: 0.01)],
  ),
]);

void main() {
  group('StreetIndex.nearestStreets', () {
    test('encuentra las dos calles del cruce, la más cercana primero', () {
      // Un poco al norte del cruce: está sobre Ameghino.
      final hits = _grilla().nearestStreets((lat: 0.0003, lng: 0));
      expect(hits.first.name, 'Ameghino');
      expect(hits.map((h) => h.name), containsAll(['Ameghino', 'Sáenz Peña']));
      expect(hits.first.distanceMeters, lessThan(5));
    });

    test('no devuelve la misma calle dos veces aunque tenga muchos tramos', () {
      final index = StreetIndex([
        const NamedStreet(
          name: 'Ameghino',
          points: [(lat: -0.01, lng: 0), (lat: 0, lng: 0), (lat: 0.01, lng: 0)],
        ),
      ]);
      final hits = index.nearestStreets((lat: 0.0001, lng: 0));
      expect(hits.length, 1);
    });

    test('respeta el radio máximo', () {
      // ~1.1 km al norte: fuera de los 150 m por defecto.
      expect(_grilla().nearestStreets((lat: 0.01, lng: 0.01)), isEmpty);
    });
  });

  group('deriveStopName', () {
    test('una parada sobre el cruce se nombra con la esquina', () {
      expect(
        deriveStopName((lat: 0.0002, lng: 0), _grilla()),
        'Ameghino y Sáenz Peña',
      );
    });

    test('sin transversal cerca usa solo la calle', () {
      final index = StreetIndex([
        const NamedStreet(
          name: 'Ameghino',
          points: [(lat: -0.02, lng: 0), (lat: 0.02, lng: 0)],
        ),
      ]);
      expect(deriveStopName((lat: 0.015, lng: 0), index), 'Ameghino');
    });

    test('devuelve null si no hay ninguna calle cerca — NO inventa', () {
      // Preferimos mostrar el código interno antes que una esquina falsa.
      expect(deriveStopName((lat: 5, lng: 5), _grilla()), isNull);
    });

    test('devuelve null si la calle más cercana está demasiado lejos', () {
      // A ~110 m de Ameghino: está "cerca" pero no "sobre" la calle.
      expect(
        deriveStopName((lat: 0.005, lng: 0.001), _grilla(), onStreetMeters: 40),
        isNull,
      );
    });

    test('un callejero vacío no rompe', () {
      expect(deriveStopName((lat: 0, lng: 0), StreetIndex(const [])), isNull);
    });
  });

  group('joinStreetNames — eufonía del castellano', () {
    test('usa "e" ante i-', () {
      expect(joinStreetNames('Italia', 'Yrigoyen'), 'Italia y Yrigoyen');
      expect(joinStreetNames('Yrigoyen', 'Italia'), 'Yrigoyen e Italia');
    });

    test('usa "e" ante hi- pero NO ante hie-', () {
      expect(joinStreetNames('Sarmiento', 'Hidalgo'), 'Sarmiento e Hidalgo');
      expect(joinStreetNames('Sarmiento', 'Hierro'), 'Sarmiento y Hierro');
    });

    test('ignora las tildes al decidir', () {
      expect(joinStreetNames('Colón', 'Íbera'), 'Colón e Íbera');
    });

    test('el caso normal usa "y"', () {
      expect(
        joinStreetNames('Ameghino', 'Sáenz Peña'),
        'Ameghino y Sáenz Peña',
      );
    });
  });

  group('isUninformativeStopName', () {
    test('los que no ubican: líneas, "parada" a secas y el de tipeo', () {
      for (final name in [
        'Línea 8',
        'Línea 8 y 104',
        'Lineas 5, 7',
        'Parada de colectivo',
        'Parada',
        'Parada 106 y 108A',
        'Parada 105 110',
        'Varias linas',
        'Varias líneas',
        '  ',
      ]) {
        expect(isUninformativeStopName(name), isTrue, reason: name);
      }
    });

    test('los que sí ubican se respetan, aunque digan "parada" o "línea"', () {
      for (final name in [
        'Ávalos y Rivadavia',
        'Parada Chaco-Corrientes',
        'Terminal de la línea 110',
        'Terminal de colectivos',
        'Hospital Perrando',
        'Parada C01832',
      ]) {
        expect(isUninformativeStopName(name), isFalse, reason: name);
      }
    });
  });
}
