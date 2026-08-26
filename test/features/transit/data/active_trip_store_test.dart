import 'package:flutter_test/flutter_test.dart';
import 'package:rutalibre/features/transit/data/datasources/active_trip_store.dart';
import 'package:rutalibre/features/transit/data/models/stop_model.dart';
import 'package:rutalibre/features/transit/data/models/trip_plan_model.dart';
import 'package:rutalibre/features/transit/domain/entities/route_variant.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _plan = TripPlanModel(
  walkToBoardMeters: 150,
  walkFromAlightMeters: 220,
  legs: [
    TripLegModel(
      lineId: 'l3',
      lineCode: '3',
      lineName: 'Vial ↔ Monte Alto',
      colorHex: '#F57C00',
      networkCode: 'gran-resistencia',
      networkName: 'Gran Resistencia',
      routeVariantId: 'rv1',
      variantName: 'Ida',
      branch: 'A',
      direction: RouteDirection.outbound,
      boardStop: const StopModel(
        id: 's1',
        name: 'Ameghino y French',
        lat: -27.4519,
        lng: -58.9865,
        osmNodeId: 123456,
      ),
      alightStop: const StopModel(
        id: 's2',
        name: 'Terminal',
        lat: -27.46,
        lng: -58.97,
      ),
      stopCount: 12,
    ),
  ],
);

ActiveTrip _trip({int step = 2}) => ActiveTrip(
  plan: _plan,
  originLat: -27.4869,
  originLng: -58.9469,
  destinationLat: -27.46,
  destinationLng: -58.97,
  originName: 'Mi casa',
  stepIndex: step,
);

final _ahora = DateTime(2026, 8, 25, 18);

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  ActiveTripStore store({DateTime? now}) =>
      ActiveTripStore(prefs, now: () => now ?? _ahora);

  test(
    'round-trip: lo que se guarda es lo que vuelve, tramos incluidos',
    () async {
      await store().save(_trip());

      final loaded = await store().load();
      expect(loaded, isNotNull);
      expect(loaded!.stepIndex, 2);
      expect(loaded.originName, 'Mi casa');
      expect(loaded.originLat, -27.4869);
      final leg = loaded.plan.legs.single;
      expect(leg.lineCode, '3');
      expect(leg.boardStop.name, 'Ameghino y French');
      expect(leg.boardStop.osmNodeId, 123456);
      expect(leg.alightStop.id, 's2');
      expect(leg.direction, RouteDirection.outbound);
      expect(loaded.plan.walkToBoardMeters, 150);
    },
  );

  test('el serializado es el MISMO formato que el RPC: un solo parser', () {
    // Si esto rompe, hay dos formatos de viaje en la app y uno de los dos
    // se va a desincronizar en silencio.
    final json = TripPlanModel.planToJson(_plan);
    final reparsed = TripPlanModel.fromJson(json);
    expect(reparsed, _plan);
  });

  test('sin nada guardado, null', () async {
    expect(await store().load(), isNull);
  });

  test('un viaje de hace más de tres horas venció: null y se limpia', () async {
    await store().save(_trip());

    final despues = _ahora.add(const Duration(hours: 3, minutes: 1));
    expect(await store(now: despues).load(), isNull);
    // Y quedó limpio: la próxima carga ni siquiera parsea.
    expect(prefs.getString('ruta_libre_active_trip_v1'), isNull);
  });

  test('un viaje de hace dos horas sigue vivo', () async {
    await store().save(_trip());
    final despues = _ahora.add(const Duration(hours: 2));
    expect(await store(now: despues).load(), isNotNull);
  });

  test('guardado corrupto: null sin excepción, y se limpia', () async {
    // Retomar un viaje es una cortesía: una cortesía no puede impedir que
    // la app abra.
    await prefs.setString('ruta_libre_active_trip_v1', '{esto no es');
    expect(await store().load(), isNull);
    expect(prefs.getString('ruta_libre_active_trip_v1'), isNull);
  });

  test('saveStep actualiza el paso sin tocar el resto', () async {
    await store().save(_trip(step: 1));
    await store().saveStep(4);

    final loaded = await store().load();
    expect(loaded!.stepIndex, 4);
    expect(loaded.plan.legs.single.lineCode, '3');
  });

  test('saveStep sin viaje guardado no inventa uno', () async {
    await store().saveStep(3);
    expect(await store().load(), isNull);
  });
}
