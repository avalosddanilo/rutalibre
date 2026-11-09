import 'package:flutter_test/flutter_test.dart';
import 'package:rutalibre/features/transit/domain/entities/place.dart';
import 'package:rutalibre/features/transit/domain/entities/stop.dart';
import 'package:rutalibre/features/transit/presentation/utils/destination_search.dart';

Place _place(String name, [PlaceKind kind = PlaceKind.otro]) =>
    Place(name: name, lat: -27.45, lng: -58.98, kind: kind);

Stop _stop(String name) =>
    Stop(id: 'id-$name', name: name, lat: -27.46, lng: -58.99);

List<String> _names(List<Destination> results) => [
  for (final r in results) r.name,
];

void main() {
  group('encuentra lugares, que es para lo que existe', () {
    test('la gente escribe la parte distintiva, no el genérico', () {
      // "perrando", no "hospital doctor julio c perrando".
      final results = searchDestinations(
        query: 'perrando',
        places: [_place('Hospital Julio C. Perrando', PlaceKind.salud)],
        stops: const [],
      );
      expect(_names(results), ['Hospital Julio C. Perrando']);
    });

    test('ignora tildes, como el buscador de líneas', () {
      final results = searchDestinations(
        query: 'sarmiento',
        places: [_place('Shopping Sarmiento', PlaceKind.compras)],
        stops: const [],
      );
      expect(results, hasLength(1));
    });

    test('"chango mas" encuentra "Hiper Changomás": las marcas se escriben '
        'separadas o juntas', () {
      // Lo reportó una usuaria: en OSM está todo junto.
      final results = searchDestinations(
        query: 'chango más',
        places: [
          _place('Hiper Changomás Resistencia', PlaceKind.compras),
          _place('Chango Paniagua (Laguna Brava)', PlaceKind.calle),
        ],
        stops: const [],
      );
      expect(_names(results), ['Hiper Changomás Resistencia']);
    });

    test('y al revés: "changomas" encuentra un "Chango Más"', () {
      final results = searchDestinations(
        query: 'changomas',
        places: [_place('Chango Más Barranqueras', PlaceKind.compras)],
        stops: const [],
      );
      expect(_names(results), ['Chango Más Barranqueras']);
    });

    test('juntar palabras no le gana a lo que ya matcheaba tal cual', () {
      final results = searchDestinations(
        query: 'san ta',
        places: [_place('Santa Fe'), _place('San Tadeo')],
        stops: const [],
      );
      expect(_names(results), ['San Tadeo', 'Santa Fe']);
    });

    test('"gala y convenciones" encuentra "Gala Convenciones": las letras '
        'sueltas no cuentan', () {
      final results = searchDestinations(
        query: 'gala y convenciones',
        places: [
          _place('Gala Convenciones', PlaceKind.cultura),
          _place('Plaza Ramona Galarza', PlaceKind.plaza),
        ],
        stops: const [],
      );
      expect(_names(results), ['Gala Convenciones']);
    });

    test('las palabras pueden venir en otro orden', () {
      final results = searchDestinations(
        query: 'convenciones gala',
        places: [_place('Gala Convenciones', PlaceKind.cultura)],
        stops: const [],
      );
      expect(results, hasLength(1));
    });

    test(
      'pero los artículos SÍ cuentan: "el hiper" no es "Hiper Libertad"',
      () {
        // Decisión de producto: no acostumbrar a buscar de cualquier forma.
        final results = searchDestinations(
          query: 'el hiper',
          places: [_place('Hiper Libertad', PlaceKind.compras)],
          stops: const [],
        );
        expect(results, isEmpty);
      },
    );

    test('y los números también: "9 julio" no da cualquier "Julio"', () {
      final results = searchDestinations(
        query: '9 julio',
        places: [_place('Escuela Julio Cortázar')],
        stops: const [],
      );
      expect(results, isEmpty);
    });

    test('con menos de 4 letras no junta nada', () {
      final results = searchDestinations(
        query: 'a b',
        places: [_place('Club Abc')],
        stops: const [],
      );
      expect(results, isEmpty);
    });

    test('sin query no devuelve nada: la lista vacía la llenan los '
        'favoritos y recientes', () {
      expect(
        searchDestinations(
          query: '   ',
          places: [_place('Hospital')],
          stops: [_stop('Ameghino y French')],
        ),
        isEmpty,
      );
    });
  });

  group('orden de los resultados', () {
    test('el que EMPIEZA con lo escrito va antes que el que lo tiene en el '
        'medio', () {
      final results = searchDestinations(
        query: 'san',
        places: [_place('Clínica San Justo'), _place('San Martín 1200')],
        stops: const [],
      );
      expect(_names(results).first, 'San Martín 1200');
    });

    test('una palabra que empieza le gana a un match en el medio', () {
      final results = searchDestinations(
        query: 'roca',
        places: [
          _place('Barroca Center'), // "roca" en el medio de una palabra
          _place('Plaza Julio Roca'), // palabra que empieza con "roca"
        ],
        stops: const [],
      );
      expect(_names(results).first, 'Plaza Julio Roca');
    });

    test('a igual match, el LUGAR le gana a la parada', () {
      // Quien escribe "perrando" quiere el hospital, no la parada que
      // alguien bautizó igual. La parada sigue apareciendo abajo.
      final results = searchDestinations(
        query: 'perrando',
        places: [_place('Perrando', PlaceKind.salud)],
        stops: [_stop('Perrando')],
      );
      expect(results.first, isA<PlaceDestination>());
      expect(results.last, isA<StopDestination>());
    });

    test('a igual todo, gana el nombre más corto', () {
      final results = searchDestinations(
        query: 'escuela 123',
        places: [
          _place('Escuela 123 Anexo Barrio Provincias Unidas'),
          _place('Escuela 123'),
        ],
        stops: const [],
      );
      expect(_names(results).first, 'Escuela 123');
    });
  });

  group('paradas', () {
    test('siguen apareciendo: la función suma, no reemplaza', () {
      final results = searchDestinations(
        query: 'ameghino',
        places: const [],
        stops: [_stop('Ameghino y French')],
      );
      expect(_names(results), ['Ameghino y French']);
      expect(results.single, isA<StopDestination>());
    });

    test('sin lugares cargados el buscador funciona igual que antes', () {
      // Si el asset no cargó, la hoja pasa una lista vacía. Eso NO puede
      // romper la búsqueda de paradas, que es lo que ya andaba.
      final results = searchDestinations(
        query: 'french',
        places: const [],
        stops: [_stop('Ameghino y French')],
      );
      expect(results, hasLength(1));
    });
  });

  group('savedId', () {
    test('distingue un lugar de una parada con el mismo nombre', () {
      final place = PlaceDestination(_place('Perrando'));
      final stop = StopDestination(_stop('Perrando'));
      expect(place.savedId, isNot(stop.savedId));
    });

    test('el mismo lugar da SIEMPRE la misma clave', () {
      // Si no, "últimos destinos" acumularía el mismo lugar una y otra vez.
      expect(
        PlaceDestination(_place('Plaza 25 de Mayo')).savedId,
        PlaceDestination(_place('Plaza 25 de Mayo')).savedId,
      );
    });
  });

  test('respeta el tope de resultados', () {
    final results = searchDestinations(
      query: 'plaza',
      places: [for (var i = 0; i < 100; i++) _place('Plaza $i')],
      stops: const [],
      limit: 12,
    );
    expect(results, hasLength(12));
  });
}
