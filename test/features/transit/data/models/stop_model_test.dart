import 'package:flutter_test/flutter_test.dart';
import 'package:rutalibre/features/transit/data/models/stop_model.dart';

void main() {
  group('StopModel.fromJson', () {
    test('acepta lat/lng ENTEROS del RPC sin explotar (gotcha num→double)', () {
      // jsonDecode entrega int para valores enteros exactos (ej: lat = -27);
      // el cast directo `as double` explotaría. El modelo usa `as num`.
      final model = StopModel.fromJson({
        'id': 's1',
        'name': 'Plaza',
        'description': null,
        'lat': -27,
        'lng': -58,
      });
      expect(model.lat, -27.0);
      expect(model.lng, -58.0);
      expect(model.lat, isA<double>());
    });

    test('mapea description opcional cuando viene presente', () {
      final model = StopModel.fromJson({
        'id': 's2',
        'name': 'Terminal',
        'description': 'frente a la plaza',
        'lat': -27.45,
        'lng': -58.98,
      });
      expect(model.description, 'frente a la plaza');
    });

    test('round-trip toJson → fromJson preserva la entidad (Equatable)', () {
      const model = StopModel(
        id: 's3',
        name: 'Esquina',
        lat: -27.1,
        lng: -58.2,
        description: 'x',
        osmNodeId: 1234567890,
      );
      expect(StopModel.fromJson(model.toJson()), model);
    });

    test('lee el nodo de OSM que agrega la migración 0010', () {
      final model = StopModel.fromJson({
        'id': 's4',
        'name': 'Ameghino y French',
        'description': null,
        'osm_node_id': 2286343843,
        'lat': -27.45,
        'lng': -58.98,
      });
      expect(model.osmNodeId, 2286343843);
    });

    test('sin osm_node_id NO rompe: queda en null', () {
      // Pasa en dos casos reales y los dos tienen que andar: una base a la que
      // todavía no le corrieron la 0010, y una cache escrita por una versión
      // vieja de la app. Quedarse sin el enlace a OSM es aceptable; quedarse
      // sin paradas no.
      final model = StopModel.fromJson({
        'id': 's5',
        'name': 'Terminal',
        'description': null,
        'lat': -27.45,
        'lng': -58.98,
      });
      expect(model.osmNodeId, isNull);
    });
  });
}
