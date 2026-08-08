import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rutalibre/core/errors/exceptions.dart';
import 'package:rutalibre/core/errors/failures.dart';
import 'package:rutalibre/features/transit/data/datasources/transit_local_datasource.dart';
import 'package:rutalibre/features/transit/data/datasources/transit_remote_datasource.dart';
import 'package:rutalibre/features/transit/data/models/bus_line_model.dart';
import 'package:rutalibre/features/transit/data/models/nearby_stop_model.dart';
import 'package:rutalibre/features/transit/data/models/route_at_stop_model.dart';
import 'package:rutalibre/features/transit/data/models/schedule_model.dart';
import 'package:rutalibre/features/transit/data/models/stop_model.dart';
import 'package:rutalibre/features/transit/data/models/trip_plan_model.dart';
import 'package:rutalibre/features/transit/data/repositories/transit_repository_impl.dart';
import 'package:rutalibre/features/transit/domain/entities/route_variant.dart';
import 'package:rutalibre/features/transit/domain/entities/schedule.dart';
import 'package:rutalibre/features/transit/domain/entities/transit_network.dart';

class _MockRemote extends Mock implements TransitRemoteDataSource {}

class _MockLocal extends Mock implements TransitLocalDataSource {}

// Fixtures. Los codes están DESORDENADOS a propósito: getLines debe ordenar
// numéricamente ("3" < "9B" < "110"), no alfabéticamente.
const _network = TransitNetwork(
  code: 'gran-resistencia',
  name: 'Gran Resistencia',
);
const _line3 = BusLineModel(
  id: 'l3',
  code: '3',
  name: 'Línea 3',
  colorHex: '#111111',
  network: _network,
);
const _line9b = BusLineModel(
  id: 'l9b',
  code: '9B',
  name: 'Línea 9B',
  colorHex: '#222222',
  network: _network,
);
const _line110 = BusLineModel(
  id: 'l110',
  code: '110',
  name: 'Línea 110',
  colorHex: '#333333',
  network: _network,
);

const _unordered = [_line110, _line3, _line9b];
const _orderedByCode = [_line3, _line9b, _line110];

// Corrientes capital: comparte los códigos 101/104/106/110 con el Gran
// Resistencia, que es exactamente lo que hace falta para el test de que las
// redes NO se intercalan.
const _corrientes = TransitNetwork(
  code: 'corrientes-capital',
  name: 'Corrientes Capital',
  sortOrder: 3,
);
const _ctes101 = BusLineModel(
  id: 'c101',
  code: '101',
  name: 'Línea 101 de Corrientes',
  colorHex: '#444444',
  network: _corrientes,
);
const _ctes110 = BusLineModel(
  id: 'c110',
  code: '110',
  name: 'Línea 110 de Corrientes',
  colorHex: '#555555',
  network: _corrientes,
);

const _stops = [
  StopModel(id: 's1', name: 'A', lat: -27.1, lng: -58.1),
  StopModel(id: 's2', name: 'B', lat: -27.2, lng: -58.2),
];

const _nearbyStops = [
  NearbyStopModel(
    stop: StopModel(id: 's1', name: 'A', lat: -27.1, lng: -58.1),
    distanceMeters: 120,
  ),
  NearbyStopModel(
    stop: StopModel(id: 's2', name: 'B', lat: -27.2, lng: -58.2),
    distanceMeters: 340,
  ),
];

const _tripPlans = [
  TripPlanModel(
    walkToBoardMeters: 150,
    walkFromAlightMeters: 220,
    legs: [
      TripLegModel(
        lineId: 'l3',
        lineCode: '3',
        lineName: 'Línea 3',
        colorHex: '#111111',
        networkCode: 'gran-resistencia',
        networkName: 'Gran Resistencia',
        routeVariantId: 'rv1',
        variantName: 'Ida',
        branch: 'A',
        direction: RouteDirection.outbound,
        boardStop: StopModel(id: 's1', name: 'A', lat: -27.1, lng: -58.1),
        alightStop: StopModel(id: 's2', name: 'B', lat: -27.2, lng: -58.2),
        stopCount: 12,
      ),
    ],
  ),
];

const _schedules = [
  ScheduleModel(
    id: 'sc1',
    routeVariantId: 'rv1',
    dayType: DayType.weekday,
    departureTime: Duration(hours: 6, minutes: 5),
  ),
];

void main() {
  late _MockRemote remote;
  late _MockLocal local;
  late TransitRepositoryImpl repository;

  setUpAll(() {
    // Requerido por mocktail para usar any()/captureAny() con estos tipos.
    registerFallbackValue(<BusLineModel>[]);
    registerFallbackValue(<StopModel>[]);
    registerFallbackValue(<ScheduleModel>[]);
    registerFallbackValue(DayType.weekday);
  });

  setUp(() {
    remote = _MockRemote();
    local = _MockLocal();
    repository = TransitRepositoryImpl(
      remoteDataSource: remote,
      localDataSource: local,
    );
  });

  group('getLines (cache-first, representativo del mecanismo _cacheFirst)', () {
    test('cache HIT: devuelve la cache ordenada y NO toca la red', () async {
      when(() => local.getCachedLines()).thenAnswer((_) async => _unordered);

      final result = await repository.getLines();

      expect(result.getRight().toNullable(), _orderedByCode);
      verify(() => local.getCachedLines()).called(1);
      verifyNever(() => remote.getLines());
      verifyNever(() => local.cacheLines(any()));
    });

    test(
      'cache MISS (vacía) → red OK: devuelve red y cachea el resultado',
      () async {
        when(() => local.getCachedLines()).thenAnswer((_) async => const []);
        when(() => remote.getLines()).thenAnswer((_) async => _unordered);
        when(() => local.cacheLines(any())).thenAnswer((_) async {});

        final result = await repository.getLines();

        expect(result.getRight().toNullable(), _orderedByCode);
        verify(() => remote.getLines()).called(1);
        final cached =
            verify(() => local.cacheLines(captureAny())).captured.single
                as List<BusLineModel>;
        expect(
          cached,
          _unordered,
        ); // cachea el crudo; el orden lo aplica getLines
      },
    );

    test(
      'cache MISS (CacheException) → red OK: la excepción de cache = miss',
      () async {
        when(
          () => local.getCachedLines(),
        ).thenThrow(const CacheException('corrupta'));
        when(() => remote.getLines()).thenAnswer((_) async => _unordered);
        when(() => local.cacheLines(any())).thenAnswer((_) async {});

        final result = await repository.getLines();

        expect(result.isRight(), isTrue);
        verify(() => remote.getLines()).called(1);
        verify(() => local.cacheLines(any())).called(1);
      },
    );

    test(
      'cache MISS → red FALLA: devuelve Left(NetworkFailure), no cachea',
      () async {
        when(() => local.getCachedLines()).thenAnswer((_) async => const []);
        when(
          () => remote.getLines(),
        ).thenThrow(const NetworkException('sin red'));

        final result = await repository.getLines();

        expect(result.getLeft().toNullable(), isA<NetworkFailure>());
        verifyNever(() => local.cacheLines(any()));
      },
    );

    test(
      'escribir la cache falla → NO es fatal: igual devuelve los datos de red',
      () async {
        when(() => local.getCachedLines()).thenAnswer((_) async => const []);
        when(() => remote.getLines()).thenAnswer((_) async => _unordered);
        when(
          () => local.cacheLines(any()),
        ).thenThrow(const CacheException('disco lleno'));

        final result = await repository.getLines();

        expect(result.getRight().toNullable(), _orderedByCode);
      },
    );

    test(
      'red devuelve vacío: Right(vacío) y NO intenta cachear vacío',
      () async {
        when(() => local.getCachedLines()).thenAnswer((_) async => const []);
        when(() => remote.getLines()).thenAnswer((_) async => const []);

        final result = await repository.getLines();

        expect(result.getRight().toNullable(), isEmpty);
        verifyNever(() => local.cacheLines(any()));
      },
    );

    test('las redes NO se intercalan aunque compartan códigos', () async {
      // El Gran Resistencia (sortOrder 1) y Corrientes (3) tienen los dos
      // una 110. Ordenar solo por código las mezclaría, y el listado
      // agrupado por red quedaría con encabezados alternados.
      when(
        () => local.getCachedLines(),
      ).thenAnswer((_) async => const [_ctes110, _line110, _ctes101, _line3]);

      final lines = (await repository.getLines()).getRight().toNullable()!;

      expect(lines.map((l) => '${l.network.code}/${l.code}').toList(), [
        'gran-resistencia/3',
        'gran-resistencia/110',
        'corrientes-capital/101',
        'corrientes-capital/110',
      ]);
    });

    test('la lista devuelta es inmodificable', () async {
      when(() => local.getCachedLines()).thenAnswer((_) async => _unordered);

      final lines = (await repository.getLines()).getRight().toNullable()!;

      expect(() => lines.add(_line3), throwsUnsupportedError);
    });
  });

  group(
    'getNearbyStops (SIEMPRE remoto: la posición del usuario no es cacheable)',
    () {
      test(
        'éxito: va directo a la red y no toca la cache en absoluto',
        () async {
          when(
            () => remote.getNearbyStops(
              lat: any(named: 'lat'),
              lng: any(named: 'lng'),
              radiusMeters: any(named: 'radiusMeters'),
            ),
          ).thenAnswer((_) async => _nearbyStops);

          final result = await repository.getNearbyStops(
            lat: -27.45,
            lng: -58.98,
            radiusMeters: 500,
          );

          expect(result.getRight().toNullable(), _nearbyStops);
          verify(
            () => remote.getNearbyStops(
              lat: -27.45,
              lng: -58.98,
              radiusMeters: 500,
            ),
          ).called(1);
          verifyZeroInteractions(local);
        },
      );

      test('falla remota → Left mapeado, sin tocar la cache', () async {
        when(
          () => remote.getNearbyStops(
            lat: any(named: 'lat'),
            lng: any(named: 'lng'),
            radiusMeters: any(named: 'radiusMeters'),
          ),
        ).thenThrow(const NetworkException('sin red'));

        final result = await repository.getNearbyStops(
          lat: 0,
          lng: 0,
          radiusMeters: 100,
        );

        expect(result.getLeft().toNullable(), isA<NetworkFailure>());
        verifyZeroInteractions(local);
      });
    },
  );

  group('getAllStops (cache-first: el buscador tiene que andar sin señal)', () {
    test('cache HIT: devuelve la cache y NO toca la red', () async {
      when(() => local.getCachedAllStops()).thenAnswer((_) async => _stops);

      final result = await repository.getAllStops();

      expect(result.getRight().toNullable(), _stops);
      verifyNever(() => remote.getAllStops());
    });

    test('cache MISS → red OK: devuelve red y cachea', () async {
      when(() => local.getCachedAllStops()).thenAnswer((_) async => const []);
      when(() => remote.getAllStops()).thenAnswer((_) async => _stops);
      when(() => local.cacheAllStops(any())).thenAnswer((_) async {});

      final result = await repository.getAllStops();

      expect(result.getRight().toNullable(), _stops);
      verify(() => local.cacheAllStops(_stops)).called(1);
    });

    test('cache MISS → red FALLA: Left, sin cachear', () async {
      when(() => local.getCachedAllStops()).thenAnswer((_) async => const []);
      when(
        () => remote.getAllStops(),
      ).thenThrow(const NetworkException('sin red'));

      final result = await repository.getAllStops();

      expect(result.getLeft().toNullable(), isA<NetworkFailure>());
      verifyNever(() => local.cacheAllStops(any()));
    });
  });

  group('planTrip (SIEMPRE remoto: dos puntos arbitrarios no se cachean)', () {
    Future<void> stubRemote(Object answer) async {
      when(
        () => remote.planTrip(
          originLat: any(named: 'originLat'),
          originLng: any(named: 'originLng'),
          destLat: any(named: 'destLat'),
          destLng: any(named: 'destLng'),
          maxWalkMeters: any(named: 'maxWalkMeters'),
          maxResults: any(named: 'maxResults'),
        ),
      ).thenAnswer((_) async {
        if (answer is AppException) throw answer;
        return answer as List<TripPlanModel>;
      });
    }

    test('éxito: pasa los seis parámetros y no toca la cache', () async {
      await stubRemote(_tripPlans);

      final result = await repository.planTrip(
        originLat: -27.45,
        originLng: -58.98,
        destLat: -27.46,
        destLng: -58.99,
        maxWalkMeters: 500,
        maxResults: 6,
      );

      expect(result.getRight().toNullable(), _tripPlans);
      verify(
        () => remote.planTrip(
          originLat: -27.45,
          originLng: -58.98,
          destLat: -27.46,
          destLng: -58.99,
          maxWalkMeters: 500,
          maxResults: 6,
        ),
      ).called(1);
      verifyZeroInteractions(local);
    });

    test('sin viajes posibles NO es un error: es una lista vacía', () async {
      await stubRemote(<TripPlanModel>[]);

      final result = await repository.planTrip(
        originLat: 0,
        originLng: 0,
        destLat: 1,
        destLng: 1,
        maxWalkMeters: 500,
        maxResults: 6,
      );

      expect(result.getRight().toNullable(), isEmpty);
      expect(result.isRight(), isTrue);
    });

    test('falla remota → Left mapeado, sin tocar la cache', () async {
      await stubRemote(const ServerException('el RPC no existe'));

      final result = await repository.planTrip(
        originLat: 0,
        originLng: 0,
        destLat: 1,
        destLng: 1,
        maxWalkMeters: 500,
        maxResults: 6,
      );

      expect(result.getLeft().toNullable(), isA<ServerFailure>());
      verifyZeroInteractions(local);
    });
  });

  group('getStopsForRoute (cache-first)', () {
    test('cache HIT: devuelve la cache y no toca la red', () async {
      when(
        () => local.getCachedStopsForRoute('rv1'),
      ).thenAnswer((_) async => _stops);

      final result = await repository.getStopsForRoute('rv1');

      expect(result.getRight().toNullable(), _stops);
      verifyNever(() => remote.getStopsForRoute(any()));
    });
  });

  group(
    'getRoutesForStop (SIEMPRE remoto: consulta puntual, no se cachea)',
    () {
      const routes = [
        RouteAtStopModel(
          lineId: 'l3',
          lineCode: '3',
          lineName: 'Vial ↔ Monte Alto',
          colorHex: '#F57C00',
          routeVariantId: 'rv1',
          variantName: 'Ida',
          branch: 'A',
          direction: RouteDirection.outbound,
        ),
      ];

      test('éxito: va a la red sin tocar la cache', () async {
        when(
          () => remote.getRoutesForStop('s1'),
        ).thenAnswer((_) async => routes);

        final result = await repository.getRoutesForStop('s1');

        expect(result.getRight().toNullable(), routes);
        verifyZeroInteractions(local);
      });

      test('falla remota → Left mapeado', () async {
        when(
          () => remote.getRoutesForStop('s1'),
        ).thenThrow(const ServerException('boom'));

        final result = await repository.getRoutesForStop('s1');

        expect(result.getLeft().toNullable(), isA<ServerFailure>());
      });
    },
  );

  group('_toFailure: cada AppException se mapea a su Failure (1:1)', () {
    Future<Either<Failure, dynamic>> nearbyThrowing(AppException e) {
      when(
        () => remote.getNearbyStops(
          lat: any(named: 'lat'),
          lng: any(named: 'lng'),
          radiusMeters: any(named: 'radiusMeters'),
        ),
      ).thenThrow(e);
      return repository.getNearbyStops(lat: 0, lng: 0, radiusMeters: 100);
    }

    test(
      'ServerException → ServerFailure (preserva mensaje y statusCode)',
      () async {
        final result = await nearbyThrowing(
          const ServerException('boom', statusCode: 503),
        );
        final failure = result.getLeft().toNullable();
        expect(failure, isA<ServerFailure>());
        expect((failure! as ServerFailure).statusCode, 503);
        expect(failure.message, 'boom');
      },
    );

    test('CacheException → CacheFailure', () async {
      final result = await nearbyThrowing(const CacheException('x'));
      expect(result.getLeft().toNullable(), isA<CacheFailure>());
    });

    test('NetworkException → NetworkFailure', () async {
      final result = await nearbyThrowing(const NetworkException('x'));
      expect(result.getLeft().toNullable(), isA<NetworkFailure>());
    });

    test('ParsingException → DataParsingFailure', () async {
      final result = await nearbyThrowing(const ParsingException('x'));
      expect(result.getLeft().toNullable(), isA<DataParsingFailure>());
    });
  });

  group(
    'getSchedules (cache-first con keying por routeVariantId + dayType)',
    () {
      test('cache HIT: devuelve la cache y no toca la red', () async {
        when(
          () => local.getCachedSchedules(
            routeVariantId: 'rv1',
            dayType: DayType.weekday,
          ),
        ).thenAnswer((_) async => _schedules);

        final result = await repository.getSchedules(
          routeVariantId: 'rv1',
          dayType: DayType.weekday,
        );

        expect(result.getRight().toNullable(), _schedules);
        verifyNever(
          () => remote.getSchedules(
            routeVariantId: any(named: 'routeVariantId'),
            dayType: any(named: 'dayType'),
          ),
        );
      });
    },
  );
}
