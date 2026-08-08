import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rutalibre/core/errors/failures.dart';
import 'package:rutalibre/core/usecases/usecase.dart';
import 'package:rutalibre/features/transit/domain/entities/bus_line.dart';
import 'package:rutalibre/features/transit/domain/entities/nearby_stop.dart';
import 'package:rutalibre/features/transit/domain/entities/route_at_stop.dart';
import 'package:rutalibre/features/transit/domain/entities/route_variant.dart';
import 'package:rutalibre/features/transit/domain/entities/schedule.dart';
import 'package:rutalibre/features/transit/domain/entities/stop.dart';
import 'package:rutalibre/features/transit/domain/entities/transit_network.dart';
import 'package:rutalibre/features/transit/domain/entities/trip_plan.dart';
import 'package:rutalibre/features/transit/domain/repositories/transit_repository.dart';
import 'package:rutalibre/features/transit/domain/usecases/get_all_stops.dart';
import 'package:rutalibre/features/transit/domain/usecases/get_lines.dart';
import 'package:rutalibre/features/transit/domain/usecases/get_nearby_stops.dart';
import 'package:rutalibre/features/transit/domain/usecases/get_route_variants.dart';
import 'package:rutalibre/features/transit/domain/usecases/get_routes_for_stop.dart';
import 'package:rutalibre/features/transit/domain/usecases/get_schedules.dart';
import 'package:rutalibre/features/transit/domain/usecases/get_stops_for_route.dart';
import 'package:rutalibre/features/transit/domain/usecases/plan_trip.dart';

class _MockRepo extends Mock implements TransitRepository {}

const _network = TransitNetwork(
  code: 'gran-resistencia',
  name: 'Gran Resistencia',
);
const _lines = [
  BusLine(
    id: 'l1',
    code: '1',
    name: 'Línea 1',
    colorHex: '#000000',
    network: _network,
  ),
];
const _variants = [
  RouteVariant(
    id: 'rv1',
    lineId: 'l1',
    name: 'Ida',
    direction: RouteDirection.outbound,
    isActive: true,
  ),
];
const _stops = [Stop(id: 's1', name: 'A', lat: -27.1, lng: -58.1)];
const _nearbyStops = [
  NearbyStop(
    stop: Stop(id: 's1', name: 'A', lat: -27.1, lng: -58.1),
    distanceMeters: 120,
  ),
];

void main() {
  late _MockRepo repo;

  setUp(() => repo = _MockRepo());

  test('GetLines delega en repository.getLines()', () async {
    when(() => repo.getLines()).thenAnswer((_) async => const Right(_lines));

    final result = await GetLines(repo)(const NoParams());

    expect(result.getRight().toNullable(), _lines);
    verify(() => repo.getLines()).called(1);
  });

  test('GetRouteVariants pasa el lineId al repositorio', () async {
    when(
      () => repo.getRouteVariants('l1'),
    ).thenAnswer((_) async => const Right(_variants));

    final result = await GetRouteVariants(repo)(
      const GetRouteVariantsParams(lineId: 'l1'),
    );

    expect(result.getRight().toNullable(), _variants);
    verify(() => repo.getRouteVariants('l1')).called(1);
  });

  test('GetStopsForRoute pasa el routeVariantId al repositorio', () async {
    when(
      () => repo.getStopsForRoute('rv1'),
    ).thenAnswer((_) async => const Right(_stops));

    final result = await GetStopsForRoute(repo)(
      const GetStopsForRouteParams(routeVariantId: 'rv1'),
    );

    expect(result.getRight().toNullable(), _stops);
    verify(() => repo.getStopsForRoute('rv1')).called(1);
  });

  group('GetNearbyStops', () {
    test('pasa lat/lng/radius al repositorio', () async {
      when(
        () => repo.getNearbyStops(lat: -27.45, lng: -58.98, radiusMeters: 800),
      ).thenAnswer((_) async => const Right(_nearbyStops));

      final result = await GetNearbyStops(repo)(
        const GetNearbyStopsParams(lat: -27.45, lng: -58.98, radiusMeters: 800),
      );

      expect(result.getRight().toNullable(), _nearbyStops);
      expect(result.getRight().toNullable()!.single.formattedDistance, '120 m');
      verify(
        () => repo.getNearbyStops(lat: -27.45, lng: -58.98, radiusMeters: 800),
      ).called(1);
    });

    test('usa el radio por defecto (500 m) cuando no se especifica', () async {
      when(
        () => repo.getNearbyStops(lat: 0, lng: 0, radiusMeters: 500),
      ).thenAnswer((_) async => const Right(_nearbyStops));

      await GetNearbyStops(repo)(const GetNearbyStopsParams(lat: 0, lng: 0));

      verify(
        () => repo.getNearbyStops(lat: 0, lng: 0, radiusMeters: 500),
      ).called(1);
    });

    test('devuelve solo las más cercanas: en el centro hay 40 paradas a '
        '500 m y nadie camina hasta la número 40', () async {
      // Llegan desordenadas a propósito: recortar los primeros N solo
      // significa "los más cercanos" si el usecase ordena.
      final lejanas = [
        for (var i = 20; i > 0; i--)
          NearbyStop(
            stop: Stop(id: 's$i', name: 'Parada $i', lat: -27.1, lng: -58.1),
            distanceMeters: i * 10,
          ),
      ];
      when(
        () => repo.getNearbyStops(lat: 0, lng: 0, radiusMeters: 500),
      ).thenAnswer((_) async => Right(lejanas));

      final result = await GetNearbyStops(repo)(
        const GetNearbyStopsParams(lat: 0, lng: 0, maxResults: 5),
      );

      final devueltas = result.getRight().toNullable()!;
      expect(devueltas, hasLength(5));
      expect(devueltas.map((n) => n.distanceMeters), [10, 20, 30, 40, 50]);
    });

    test('con menos paradas que el tope las devuelve todas', () async {
      when(
        () => repo.getNearbyStops(lat: 0, lng: 0, radiusMeters: 500),
      ).thenAnswer((_) async => const Right(_nearbyStops));

      final result = await GetNearbyStops(repo)(
        const GetNearbyStopsParams(lat: 0, lng: 0),
      );

      expect(result.getRight().toNullable(), _nearbyStops);
    });
  });

  test('GetAllStops delega en repository.getAllStops()', () async {
    when(() => repo.getAllStops()).thenAnswer((_) async => const Right(_stops));

    final result = await GetAllStops(repo)(const NoParams());

    expect(result.getRight().toNullable(), _stops);
    verify(() => repo.getAllStops()).called(1);
  });

  group('PlanTrip', () {
    const trip = TripPlan(
      walkToBoardMeters: 150,
      walkFromAlightMeters: 220,
      legs: [
        TripLeg(
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
          boardStop: Stop(id: 's1', name: 'A', lat: -27.1, lng: -58.1),
          alightStop: Stop(id: 's2', name: 'B', lat: -27.2, lng: -58.2),
          stopCount: 12,
        ),
      ],
    );

    test('pasa las dos puntas y los topes al repositorio', () async {
      when(
        () => repo.planTrip(
          originLat: -27.45,
          originLng: -58.98,
          destLat: -27.46,
          destLng: -58.99,
          maxWalkMeters: 500,
          maxResults: 6,
        ),
      ).thenAnswer((_) async => const Right([trip]));

      final result = await PlanTrip(repo)(
        const PlanTripParams(
          originLat: -27.45,
          originLng: -58.98,
          destLat: -27.46,
          destLng: -58.99,
        ),
      );

      expect(result.getRight().toNullable(), [trip]);
      expect(result.getRight().toNullable()!.single.formattedWalk, '370 m');
      verify(
        () => repo.planTrip(
          originLat: -27.45,
          originLng: -58.98,
          destLat: -27.46,
          destLng: -58.99,
          maxWalkMeters: 500,
          maxResults: 6,
        ),
      ).called(1);
    });

    test('sin viajes posibles devuelve Right(vacío): es una respuesta, '
        'no un error', () async {
      when(
        () => repo.planTrip(
          originLat: any(named: 'originLat'),
          originLng: any(named: 'originLng'),
          destLat: any(named: 'destLat'),
          destLng: any(named: 'destLng'),
          maxWalkMeters: any(named: 'maxWalkMeters'),
          maxResults: any(named: 'maxResults'),
        ),
      ).thenAnswer((_) async => const Right([]));

      final result = await PlanTrip(repo)(
        const PlanTripParams(
          originLat: 0,
          originLng: 0,
          destLat: 1,
          destLng: 1,
        ),
      );

      expect(result.isRight(), isTrue);
      expect(result.getRight().toNullable(), isEmpty);
    });

    test('los params rechazan coordenadas fuera de WGS84', () {
      expect(
        () =>
            PlanTripParams(originLat: 91, originLng: 0, destLat: 0, destLng: 0),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => PlanTripParams(
          originLat: 0,
          originLng: 0,
          destLat: 0,
          destLng: 181,
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  test('GetRoutesForStop pasa el stopId al repositorio', () async {
    const routes = [
      RouteAtStop(
        lineId: 'l1',
        lineCode: '3',
        lineName: 'Vial ↔ Monte Alto',
        colorHex: '#F57C00',
        routeVariantId: 'rv1',
        variantName: 'Ida',
        branch: 'A',
        direction: RouteDirection.outbound,
      ),
    ];
    when(
      () => repo.getRoutesForStop('s1'),
    ).thenAnswer((_) async => const Right(routes));

    final result = await GetRoutesForStop(repo)(
      const GetRoutesForStopParams(stopId: 's1'),
    );

    expect(result.getRight().toNullable(), routes);
    // Así lo nombraría un pasajero: "el 3A".
    expect(result.getRight().toNullable()!.single.displayCode, '3A');
    verify(() => repo.getRoutesForStop('s1')).called(1);
  });

  group('GetSchedules', () {
    // Salidas DESORDENADAS a propósito.
    const unsorted = [
      Schedule(
        id: 'b',
        routeVariantId: 'rv1',
        dayType: DayType.weekday,
        departureTime: Duration(hours: 8),
      ),
      Schedule(
        id: 'a',
        routeVariantId: 'rv1',
        dayType: DayType.weekday,
        departureTime: Duration(hours: 6),
      ),
    ];

    test(
      'ordena cronológicamente aunque el repositorio devuelva desordenado',
      () async {
        when(
          () => repo.getSchedules(
            routeVariantId: 'rv1',
            dayType: DayType.weekday,
          ),
        ).thenAnswer((_) async => const Right(unsorted));

        final result = await GetSchedules(repo)(
          const GetSchedulesParams(
            routeVariantId: 'rv1',
            dayType: DayType.weekday,
          ),
        );

        final schedules = result.getRight().toNullable()!;
        expect(schedules.map((s) => s.id).toList(), ['a', 'b']);
      },
    );

    test('la lista devuelta es inmodificable', () async {
      when(
        () =>
            repo.getSchedules(routeVariantId: 'rv1', dayType: DayType.weekday),
      ).thenAnswer((_) async => const Right(unsorted));

      final schedules = (await GetSchedules(repo)(
        const GetSchedulesParams(
          routeVariantId: 'rv1',
          dayType: DayType.weekday,
        ),
      )).getRight().toNullable()!;

      expect(() => schedules.add(unsorted.first), throwsUnsupportedError);
    });

    test('propaga el Left del repositorio sin tocarlo', () async {
      when(
        () =>
            repo.getSchedules(routeVariantId: 'rv1', dayType: DayType.weekday),
      ).thenAnswer((_) async => const Left(ServerFailure()));

      final result = await GetSchedules(repo)(
        const GetSchedulesParams(
          routeVariantId: 'rv1',
          dayType: DayType.weekday,
        ),
      );

      expect(result.getLeft().toNullable(), isA<ServerFailure>());
    });
  });
}
