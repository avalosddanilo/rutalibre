import 'package:flutter_test/flutter_test.dart';

import '../../tools/src/geometry.dart';
import '../../tools/src/stop_merge.dart';

/// A esta latitud 0,0001° de longitud son ~9,9 m y 0,0001° de latitud ~11 m.
/// Los tests se escriben en esos pasos para que las distancias sean legibles.
const _lat = -27.45;
const _lng = -58.98;

GeoPoint _eastOf(double meters) => (lat: _lat, lng: _lng + meters / 98775);

void main() {
  group('mergeSameStops', () {
    test('une la pareja PTv2: plataforma en la vereda + posición en la '
        'calzada', () {
      final result = mergeSameStops(
        nodeIds: const [1, 2],
        points: {1: (lat: _lat, lng: _lng), 2: _eastOf(8)},
        tags: const {
          1: {'public_transport': 'stop_position'},
          2: {'public_transport': 'platform'},
        },
      );

      expect(result.clusters.length, 1);
      expect(result.mergedAway, 1);
      // Gana la PLATAFORMA: es la vereda donde espera el pasajero.
      expect(result.canonicalOf[1], 2);
      expect(result.canonicalOf[2], 2);
    });

    test('une dos nodos que se pisan aunque tengan el mismo rol: es la '
        'misma parada mapeada dos veces', () {
      final result = mergeSameStops(
        nodeIds: const [1, 2],
        points: {1: (lat: _lat, lng: _lng), 2: _eastOf(8)},
        tags: const {
          1: {'public_transport': 'stop_position'},
          2: {'public_transport': 'stop_position'},
        },
      );

      expect(result.clusters.length, 1);
    });

    test('NO une dos paradas del mismo rol con una calle de por medio: son '
        'las dos manos de la esquina y unirlas mentiría sobre en qué vereda '
        'para cada línea', () {
      final result = mergeSameStops(
        nodeIds: const [1, 2],
        points: {1: (lat: _lat, lng: _lng), 2: _eastOf(20)},
        tags: const {
          1: {'public_transport': 'stop_position'},
          2: {'public_transport': 'stop_position'},
        },
      );

      expect(result.clusters.length, 2);
      expect(result.mergedAway, 0);
    });

    test('une la pareja PTv2 aunque estén separadas por una avenida ancha', () {
      final result = mergeSameStops(
        nodeIds: const [1, 2],
        points: {1: (lat: _lat, lng: _lng), 2: _eastOf(25)},
        tags: const {
          1: {'public_transport': 'stop_position'},
          2: {'public_transport': 'platform'},
        },
      );

      expect(result.clusters.length, 1);
    });

    test('NO une una pareja PTv2 lejana si cada nodo declara OTRO nombre: '
        'son dos paradas distintas que quedaron cerca', () {
      final result = mergeSameStops(
        nodeIds: const [1, 2],
        points: {1: (lat: _lat, lng: _lng), 2: _eastOf(25)},
        tags: const {
          1: {'public_transport': 'stop_position', 'name': 'Terminal'},
          2: {'public_transport': 'platform', 'name': 'Hospital'},
        },
      );

      expect(result.clusters.length, 2);
    });

    test('más lejos que el radio PTv2 no se une nada', () {
      final result = mergeSameStops(
        nodeIds: const [1, 2],
        points: {1: (lat: _lat, lng: _lng), 2: _eastOf(35)},
        tags: const {
          1: {'public_transport': 'stop_position'},
          2: {'public_transport': 'platform'},
        },
      );

      expect(result.clusters.length, 2);
    });

    test('encadena la plataforma con las dos posiciones de detención de la '
        'misma parada', () {
      final result = mergeSameStops(
        nodeIds: const [1, 2, 3],
        points: {1: (lat: _lat, lng: _lng), 2: _eastOf(8), 3: _eastOf(16)},
        tags: const {
          1: {'public_transport': 'stop_position'},
          2: {'public_transport': 'platform', 'highway': 'bus_stop'},
          3: {'public_transport': 'stop_position'},
        },
      );

      expect(result.clusters.length, 1);
      expect(result.clusters[2], containsAll([1, 2, 3]));
    });

    test('el resultado no depende del orden de entrada', () {
      Map<int, int> canonicals(List<int> order) => mergeSameStops(
        nodeIds: order,
        points: {1: (lat: _lat, lng: _lng), 2: _eastOf(8), 3: _eastOf(16)},
        tags: const {
          1: {'public_transport': 'stop_position'},
          2: {'public_transport': 'stop_position'},
          3: {'public_transport': 'stop_position'},
        },
      ).canonicalOf;

      expect(canonicals([1, 2, 3]), canonicals([3, 1, 2]));
    });

    test('a igualdad de rol gana el que trae nombre', () {
      final result = mergeSameStops(
        nodeIds: const [1, 2],
        points: {1: (lat: _lat, lng: _lng), 2: _eastOf(8)},
        tags: const {
          1: {'public_transport': 'stop_position'},
          2: {'public_transport': 'stop_position', 'name': 'Plaza España'},
        },
      );

      expect(result.canonicalOf[1], 2);
    });

    test('un nodo sin coordenada no entra al resultado', () {
      final result = mergeSameStops(
        nodeIds: const [1, 99],
        points: {1: (lat: _lat, lng: _lng)},
        tags: const {},
      );

      expect(result.canonicalOf.keys, [1]);
    });
  });

  group('clasificación de nodos', () {
    test('highway=bus_stop cuenta como plataforma aunque no traiga '
        'public_transport', () {
      expect(isPlatform(const {'highway': 'bus_stop'}), isTrue);
      expect(isPlatform(const {'public_transport': 'platform'}), isTrue);
      expect(isPlatform(const {'public_transport': 'stop_position'}), isFalse);
      expect(
        isStopPosition(const {'public_transport': 'stop_position'}),
        isTrue,
      );
    });
  });
}
