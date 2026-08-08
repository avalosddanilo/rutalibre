import 'package:flutter_test/flutter_test.dart';
import 'package:rutalibre/features/transit/data/models/trip_plan_model.dart';
import 'package:rutalibre/features/transit/domain/entities/route_variant.dart';

/// Un tramo tal como lo arma `trip_leg_json` en la migración 0004.
Map<String, dynamic> _leg({
  String lineCode = '3',
  String? branch = 'A',
  int direction = 0,
  int stopCount = 12,
}) => {
  'line_id': 'l3',
  'line_code': lineCode,
  'line_name': 'Vial ↔ Monte Alto',
  'color_hex': '#F57C00',
  'network_code': 'gran-resistencia',
  'network_name': 'Gran Resistencia',
  'route_variant_id': 'rv1',
  'variant_name': 'Ida: Vial → Monte Alto',
  'branch': branch,
  'direction': direction,
  'stop_count': stopCount,
  'board_stop': {
    'id': 's1',
    'name': 'Ameghino y Sáenz Peña',
    'description': 'Parada C001',
    'lat': -27.4519,
    'lng': -58.9865,
  },
  'alight_stop': {
    'id': 's2',
    'name': 'Av. 25 de Mayo y French',
    'description': null,
    'lat': -27.46,
    'lng': -58.99,
  },
};

void main() {
  group('TripPlanModel.fromJson', () {
    test('lee un viaje directo', () {
      final plan = TripPlanModel.fromJson({
        'leg_count': 1,
        'walk_to_board_m': 150,
        'walk_from_alight_m': 220,
        'walk_total_m': 370,
        'legs': [_leg()],
      });

      expect(plan.isDirect, isTrue);
      expect(plan.legs, hasLength(1));
      expect(plan.walkToBoardMeters, 150);
      expect(plan.walkFromAlightMeters, 220);
      expect(plan.walkTotalMeters, 370);
      expect(plan.transferStop, isNull);

      final leg = plan.legs.single;
      expect(leg.displayCode, '3A');
      expect(leg.direction, RouteDirection.outbound);
      expect(leg.boardStop.name, 'Ameghino y Sáenz Peña');
      expect(leg.boardStop.description, 'Parada C001');
      expect(leg.alightStop.description, isNull);
      expect(leg.stopCount, 12);
    });

    test('lee un viaje con transbordo y sabe dónde se hace', () {
      final plan = TripPlanModel.fromJson({
        'leg_count': 2,
        'walk_to_board_m': 100,
        'walk_from_alight_m': 300,
        'walk_total_m': 400,
        'legs': [
          _leg(stopCount: 5),
          _leg(lineCode: '9', branch: null, direction: 1, stopCount: 8),
        ],
      });

      expect(plan.isDirect, isFalse);
      expect(plan.legs.map((l) => l.displayCode), ['3A', '9']);
      expect(plan.legs.last.direction, RouteDirection.inbound);
      expect(plan.totalStopCount, 13);
      // El transbordo es donde termina el primer tramo — siempre la misma
      // parada, porque el planificador no ofrece transbordos caminando.
      expect(plan.transferStop, plan.legs.first.alightStop);
    });

    test('los metros pueden llegar como int: los RPCs devuelven num', () {
      final plan = TripPlanModel.fromJson({
        'walk_to_board_m': 0,
        'walk_from_alight_m': 1200,
        'legs': [_leg()],
      });

      expect(plan.walkToBoardMeters, 0.0);
      expect(plan.walkFromAlightMeters, 1200.0);
    });

    test('ramal nulo: se muestra la línea sola', () {
      // Pasa en dos casos y los dos se leen igual: la línea no tiene
      // ramales, o varios ramales hacen el mismo viaje y el RPC omite el
      // ramal a propósito (nombrar uno haría que el pasajero deje pasar
      // el otro).
      final plan = TripPlanModel.fromJson({
        'walk_to_board_m': 10,
        'walk_from_alight_m': 10,
        'legs': [_leg(lineCode: '110', branch: null)],
      });

      expect(plan.legs.single.branch, isNull);
      expect(plan.legs.single.displayCode, '110');
    });
  });

  group('formato de la caminata', () {
    ({double toBoard, double fromAlight}) walk(double a, double b) =>
        (toBoard: a, fromAlight: b);

    String formatted(double a, double b) => TripPlanModel.fromJson({
      'walk_to_board_m': walk(a, b).toBoard,
      'walk_from_alight_m': walk(a, b).fromAlight,
      'legs': [_leg()],
    }).formattedWalk;

    test('en metros abajo del kilómetro', () {
      expect(formatted(150, 220), '370 m');
    });

    test('en kilómetros con coma decimal, como se escribe en castellano', () {
      expect(formatted(600, 600), '1,2 km');
    });
  });
}
