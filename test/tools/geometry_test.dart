import 'package:flutter_test/flutter_test.dart';

import '../../tools/src/geometry.dart';

void main() {
  group('haversineMeters', () {
    test('mismo punto = 0', () {
      const p = (lat: -27.45, lng: -58.98);
      expect(haversineMeters(p, p), 0);
    });

    test('un grado de latitud ≈ 111 km', () {
      const a = (lat: -27.0, lng: -58.98);
      const b = (lat: -28.0, lng: -58.98);
      expect(haversineMeters(a, b), closeTo(111195, 500));
    });
  });

  group('stitchWays', () {
    // Cuatro nodos en línea recta sobre la misma latitud.
    final nodes = <int, GeoPoint>{
      1: (lat: 0, lng: 0),
      2: (lat: 0, lng: 0.001),
      3: (lat: 0, lng: 0.002),
      4: (lat: 0, lng: 0.003),
      9: (lat: 0, lng: 0.010), // lejos: fuerza un salto
    };

    test(
      'ways ya orientados: cosen sin saltos y sin repetir el nodo unión',
      () {
        final result = stitchWays([
          const WaySegment([1, 2]),
          const WaySegment([2, 3]),
          const WaySegment([3, 4]),
        ], nodes);
        expect(result.gaps, isEmpty);
        expect(result.points, hasLength(4));
      },
    );

    test('way dado vuelta se invierte solo', () {
      final result = stitchWays([
        const WaySegment([1, 2]),
        const WaySegment([3, 2]), // al revés
        const WaySegment([3, 4]),
      ], nodes);
      expect(result.gaps, isEmpty);
      expect(result.points, hasLength(4));
      expect(result.points.first, nodes[1]);
      expect(result.points.last, nodes[4]);
    });

    test('el primer way se orienta mirando al segundo', () {
      final result = stitchWays([
        const WaySegment([2, 1]), // arranca al revés
        const WaySegment([2, 3]),
      ], nodes);
      expect(result.gaps, isEmpty);
      expect(result.points.first, nodes[1]);
      expect(result.points.last, nodes[3]);
    });

    test('discontinuidad: se puentea entrando por el extremo MÁS CERCANO', () {
      final result = stitchWays([
        const WaySegment([1, 2]),
        const WaySegment([9, 4]), // no comparte nodo con el anterior
      ], nodes);
      expect(result.gaps, hasLength(1));
      // El salto se mide contra el extremo más cercano (nodo 4, ~222 m) y
      // no contra el primero de la lista (nodo 9, ~1000 m): el way entra
      // dado vuelta.
      expect(result.gaps.single, closeTo(222, 25));
      expect(result.points.last, nodes[9]);
    });

    test('ways de un solo nodo se ignoran', () {
      final result = stitchWays([
        const WaySegment([1]),
        const WaySegment([1, 2]),
      ], nodes);
      expect(result.points, hasLength(2));
    });

    test('sin ways devuelve vacío en vez de explotar', () {
      expect(stitchWays(const [], nodes).points, isEmpty);
    });
  });

  group('simplify (Douglas-Peucker)', () {
    test('saca los puntos intermedios de una recta', () {
      final line = <GeoPoint>[
        (lat: 0, lng: 0),
        (lat: 0, lng: 0.0005),
        (lat: 0, lng: 0.001),
        (lat: 0, lng: 0.0015),
        (lat: 0, lng: 0.002),
      ];
      expect(simplify(line, 5).length, 2);
    });

    test('conserva un quiebre real', () {
      final corner = <GeoPoint>[
        (lat: 0, lng: 0),
        (lat: 0.002, lng: 0.001), // ~220 m fuera de la recta
        (lat: 0, lng: 0.002),
      ];
      expect(simplify(corner, 5).length, 3);
    });

    test('conserva siempre los extremos', () {
      final line = <GeoPoint>[
        (lat: 0, lng: 0),
        (lat: 0, lng: 0.0005),
        (lat: 0, lng: 0.001),
      ];
      final result = simplify(line, 5);
      expect(result.first, line.first);
      expect(result.last, line.last);
    });

    test('tolerancia 0 o pocos puntos: no toca nada', () {
      final line = <GeoPoint>[(lat: 0, lng: 0), (lat: 0, lng: 0.001)];
      expect(simplify(line, 0), line);
      expect(simplify(line, 5), line);
    });
  });
}
