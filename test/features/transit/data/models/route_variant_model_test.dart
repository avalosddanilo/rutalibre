import 'package:flutter_test/flutter_test.dart';
import 'package:rutalibre/features/transit/data/models/route_variant_model.dart';
import 'package:rutalibre/features/transit/domain/entities/route_variant.dart';

void main() {
  group('direction ↔ smallint (0 = ida, 1 = vuelta)', () {
    test('fromDb: 0 → outbound, 1 → inbound', () {
      expect(RouteVariantModel.directionFromDb(0), RouteDirection.outbound);
      expect(RouteVariantModel.directionFromDb(1), RouteDirection.inbound);
    });

    test('fromDb tira FormatException ante un valor fuera de {0,1}', () {
      expect(() => RouteVariantModel.directionFromDb(2), throwsFormatException);
    });

    test('toDb es la inversa exacta', () {
      for (final d in RouteDirection.values) {
        expect(
          RouteVariantModel.directionFromDb(RouteVariantModel.directionToDb(d)),
          d,
        );
      }
    });
  });

  group('fromJson / toJson', () {
    final json = {
      'id': 'rv1',
      'line_id': 'l1',
      'name': 'Ida: Centro → Barranqueras',
      'direction': 0,
      'is_active': true,
    };

    test('fromJson mapea todos los campos (direction como enum)', () {
      final model = RouteVariantModel.fromJson(json);
      expect(model.id, 'rv1');
      expect(model.lineId, 'l1');
      expect(model.name, 'Ida: Centro → Barranqueras');
      expect(model.direction, RouteDirection.outbound);
      expect(model.isActive, isTrue);
    });

    test('toJson vuelve a persistir direction como smallint', () {
      final model = RouteVariantModel.fromJson(json);
      expect(model.toJson()['direction'], 0);
    });

    test('round-trip toJson → fromJson preserva la entidad (Equatable)', () {
      final model = RouteVariantModel.fromJson(json);
      expect(RouteVariantModel.fromJson(model.toJson()), model);
    });
  });
}
