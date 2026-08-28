import 'package:flutter_test/flutter_test.dart';

import '../../tools/src/place_import.dart';
import '../../tools/src/street_import.dart';

/// Centros aproximados de las dos localidades del caso que motivó todo esto:
/// la San Juan de Barranqueras no es la San Juan del centro de Resistencia.
const _localities = <Locality>[
  (name: 'Resistencia', lat: -27.451, lng: -58.986),
  (name: 'Barranqueras', lat: -27.487, lng: -58.934),
];

RawStreet _way(String? name, double? lat, double? lng) =>
    (name: name, lat: lat, lng: lng);

void main() {
  group('buildStreets', () {
    test('la misma calle en dos localidades sale DOS veces, rotulada', () {
      // El caso real: "San Juan" existe en Resistencia Y en Barranqueras.
      // Agrupar por nombre solo daría un punto a mitad de camino entre las
      // dos ciudades, que no es ninguna de las dos calles.
      final result = buildStreets([
        _way('San Juan', -27.436, -58.986),
        _way('San Juan', -27.437, -58.984),
        _way('San Juan', -27.473, -58.928),
        _way('San Juan', -27.472, -58.927),
      ], _localities);

      expect(result.streets, hasLength(2));
      expect(
        result.streets.map((s) => s.name),
        containsAll(['San Juan (Resistencia)', 'San Juan (Barranqueras)']),
      );
      final barranqueras = result.streets.firstWhere(
        (s) => s.name == 'San Juan (Barranqueras)',
      );
      // El punto está SOBRE la calle de Barranqueras, no en el promedio de
      // las cuatro (que caería en el medio de la nada entre las ciudades).
      expect(barranqueras.lat, closeTo(-27.4725, 0.001));
      expect(barranqueras.lng, closeTo(-58.9275, 0.001));
      expect(barranqueras.kind, PlaceKind.calle);
    });

    test(
      'los treinta ways de una calle larga son UNA entrada, en el medio',
      () {
        // OSM parte una calle en un way por cada cambio de velocidad o de
        // carriles. Para el buscador es una sola calle.
        final ways = [
          for (var i = 0; i < 30; i++)
            _way('French', -27.400 - i * 0.002, -58.99),
        ];
        final result = buildStreets(ways, _localities);

        expect(result.streets, hasLength(1));
        final street = result.streets.single;
        // El representante es el way REAL más cercano al promedio: con una
        // fila pareja de treinta, uno del medio.
        expect(street.lat, closeTo(-27.429, 0.002));
      },
    );

    test('gana la grafía mayoritaria, no la del primer way', () {
      final result = buildStreets([
        _way('SAN MARTIN', -27.451, -58.986),
        _way('San Martín', -27.452, -58.986),
        _way('San Martín', -27.453, -58.986),
      ], _localities);

      expect(result.streets.single.name, 'San Martín (Resistencia)');
    });

    test('sin localidades, el nombre va sin rótulo', () {
      // Overpass pudo devolver vacío: mejor calles sin rótulo que sin calles.
      final result = buildStreets([
        _way('Ameghino', -27.451, -58.986),
      ], const []);

      expect(result.streets.single.name, 'Ameghino');
    });

    test('filtra lo de siempre y lo cuenta', () {
      final result = buildStreets([
        _way(null, -27.451, -58.986),
        _way('  ', -27.451, -58.986),
        _way('Sin coordenada', null, -58.986),
        // Una ruta rural a 40 km, fuera del área urbana.
        _way('Ruta a Margarita Belén', -27.20, -58.986),
        _way('Ameghino', -27.451, -58.986),
      ], _localities);

      expect(result.report.total, 5);
      expect(result.report.sinNombre, 2);
      expect(result.report.sinCoordenada, 1);
      expect(result.report.fueraDelArea, 1);
      expect(result.report.calles, 1);
      expect(result.streets.single.name, 'Ameghino (Resistencia)');
    });

    test('el orden es estable entre corridas', () {
      // Regenerar sin cambios en la fuente tiene que dar diff vacío; si el
      // orden dependiera del orden del mapa interno, cada corrida ensuciaría
      // el repo con miles de líneas movidas.
      final ways = [
        _way('Zeballos', -27.451, -58.986),
        _way('Ameghino', -27.452, -58.986),
        _way('French', -27.453, -58.986),
      ];
      final first = buildStreets(ways, _localities);
      final second = buildStreets(ways.reversed.toList(), _localities);

      expect(
        first.streets.map((s) => s.name).toList(),
        second.streets.map((s) => s.name).toList(),
      );
      expect(first.streets.first.name, 'Ameghino (Resistencia)');
    });
  });
}
