import 'package:flutter_test/flutter_test.dart';

import '../../tools/src/place_import.dart';

RawPlace _raw(
  String? name,
  double? lat,
  double? lng,
  Map<String, String> tags,
) => (name: name, lat: lat, lng: lng, tags: tags);

/// En pleno centro de Resistencia.
const _lat = -27.4519;
const _lng = -58.9865;

void main() {
  group('kindFor', () {
    test('mapea los tags que nos importan', () {
      expect(kindFor({'amenity': 'hospital'}), PlaceKind.salud);
      expect(kindFor({'shop': 'mall'}), PlaceKind.compras);
      expect(kindFor({'leisure': 'park'}), PlaceKind.plaza);
      expect(kindFor({'amenity': 'place_of_worship'}), PlaceKind.iglesia);
    });

    test('lo que no está en la lista blanca NO entra', () {
      // OSM tiene miles de valores y casi ninguno es un destino: un buzón,
      // una boca de incendio, un banco de plaza.
      expect(kindFor({'amenity': 'bench'}), isNull);
      expect(kindFor({'amenity': 'waste_basket'}), isNull);
      expect(kindFor(const {}), isNull);
    });

    test('con varios tags manda el orden declarado', () {
      // Un shopping etiquetado también como mercado es un shopping.
      expect(
        kindFor({'shop': 'mall', 'amenity': 'marketplace'}),
        PlaceKind.compras,
      );
    });
  });

  group('normalizeName', () {
    test('saca tildes, puntuación y espacios de más', () {
      expect(normalizeName('Hospital  PERRANDO.'), 'hospital perrando');
      expect(normalizeName('Plaza 25 de Mayo'), 'plaza 25 de mayo');
      expect(
        normalizeName('Escuela N° 12 "San Martín"'),
        'escuela n 12 san martin',
      );
    });
  });

  group('buildPlaces', () {
    test('descarta y REPORTA cada motivo', () {
      final result = buildPlaces([
        _raw(null, _lat, _lng, {'amenity': 'hospital'}),
        _raw('  ', _lat, _lng, {'amenity': 'hospital'}),
        _raw('Sin coordenada', null, _lng, {'amenity': 'hospital'}),
        _raw('Banco de plaza', _lat, _lng, {'amenity': 'bench'}),
        _raw('Escuela rural', -27.60, -59.10, {'amenity': 'school'}),
        _raw('Hospital Perrando', _lat, _lng, {'amenity': 'hospital'}),
      ]);

      expect(result.places, hasLength(1));
      expect(result.report.sinNombre, 2);
      expect(result.report.sinCoordenada, 1);
      expect(result.report.categoriaDesconocida, 1);
      expect(result.report.fueraDelArea, 1);
      expect(result.report.total, 6);
    });

    test('el mismo lugar mapeado como nodo Y como polígono se une', () {
      // OSM trae la misma escuela como el nodo del edificio y como el way del
      // terreno. Son una sola escuela.
      final result = buildPlaces([
        _raw('Escuela 123', _lat, _lng, {'amenity': 'school'}),
        _raw('escuela  123', _lat + 0.0005, _lng, {'amenity': 'school'}),
      ]);
      expect(result.places, hasLength(1));
      expect(result.report.duplicados, 1);
    });

    test('dos sucursales lejanas con el mismo nombre NO se unen', () {
      // "Farmacia del Pueblo" hay una en cada barrio, y las dos sirven.
      final result = buildPlaces([
        _raw('Farmacia del Pueblo', _lat, _lng, {'amenity': 'pharmacy'}),
        _raw('Farmacia del Pueblo', _lat + 0.02, _lng, {'amenity': 'pharmacy'}),
      ]);
      expect(result.places, hasLength(2));
      expect(result.report.duplicados, 0);
    });

    test('NaN e Infinity se descartan como coordenada', () {
      final result = buildPlaces([
        _raw('Roto', double.nan, _lng, {'amenity': 'hospital'}),
        _raw('Roto 2', _lat, double.infinity, {'amenity': 'hospital'}),
      ]);
      expect(result.places, isEmpty);
      expect(result.report.sinCoordenada, 2);
    });

    test('el orden es ESTABLE entre corridas', () {
      // Si no, cada regeneración del asset ensucia el repo con miles de
      // líneas movidas y el diff deja de servir para revisar.
      final input = [
        _raw('Zoológico', _lat, _lng, {'tourism': 'attraction'}),
        _raw('Escuela 1', _lat + 0.001, _lng, {'amenity': 'school'}),
        _raw('Municipalidad', _lat + 0.002, _lng, {'amenity': 'townhall'}),
      ];
      expect(
        [for (final p in buildPlaces(input).places) p.name],
        [for (final p in buildPlaces(input.reversed).places) p.name],
      );
    });
  });

  group('encodePlaces', () {
    test('claves cortas y coordenadas recortadas: el archivo se lee entero '
        'en memoria', () {
      final encoded = encodePlaces([
        (
          name: 'Hospital Perrando',
          lat: -27.451912345,
          lng: -58.986598765,
          kind: PlaceKind.salud,
        ),
      ]);
      final row = (encoded['p']! as List).single as Map<String, Object?>;
      expect(row['n'], 'Hospital Perrando');
      expect(row['y'], -27.45191);
      expect(row['x'], -58.9866);
      expect(row['k'], 'salud');
      expect(encoded['v'], 1);
    });
  });
}
