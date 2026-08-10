import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/bus_line.dart';
import '../../domain/entities/nearby_stop.dart';
import '../../domain/entities/route_at_stop.dart';
import '../../domain/entities/route_variant.dart';
import '../../domain/entities/schedule.dart';
import '../../domain/entities/stop.dart';
import '../../domain/entities/trip_plan.dart';
import '../../domain/repositories/transit_repository.dart';
import '../datasources/transit_local_datasource.dart';
import '../datasources/transit_remote_datasource.dart';
import '../models/bus_line_model.dart';
import '../models/route_variant_model.dart';
import '../models/schedule_model.dart';
import '../models/stop_model.dart';

final class TransitRepositoryImpl implements TransitRepository {
  const TransitRepositoryImpl({
    required TransitRemoteDataSource remoteDataSource,
    required TransitLocalDataSource localDataSource,
    DateTime Function()? now,
  }) : _remote = remoteDataSource,
       _local = localDataSource,
       _now = now ?? DateTime.now;

  final TransitRemoteDataSource _remote;
  final TransitLocalDataSource _local;
  final DateTime Function() _now;

  /// A partir de cuándo una cache de datos estáticos se considera vieja.
  ///
  /// **Sin esto la cache no se refrescaba NUNCA.** `_cacheFirst` devuelve lo
  /// guardado sin mirar la red, así que un recorrido que cambia no le llegaba
  /// a nadie que ya hubiera abierto la app: hacía falta publicar una versión
  /// con la versión de la cache subida. Siete días es un compromiso: los
  /// recorridos cambian pocas veces por año, y esperar más volvería a hacer
  /// que la única forma de corregir un dato sea una release.
  static const cacheTtl = Duration(days: 7);

  @override
  Result<List<BusLine>> getLines() async {
    final result = await _cacheFirst<BusLine, BusLineModel>(
      readCache: _local.getCachedLines,
      fetchRemote: _remote.getLines,
      writeCache: (lines) =>
          _local.cacheLines(lines.map((e) => e as BusLineModel).toList()),
    );
    return result.map(
      (lines) =>
          List<BusLine>.unmodifiable(<BusLine>[...lines]..sort(_compareLines)),
    );
  }

  @override
  Result<List<RouteVariant>> getRouteVariants(String lineId) =>
      _cacheFirst<RouteVariant, RouteVariantModel>(
        readCache: () => _local.getCachedRouteVariants(lineId),
        fetchRemote: () => _remote.getRouteVariants(lineId),
        writeCache: (variants) => _local.cacheRouteVariants(
          lineId,
          variants.map((e) => e as RouteVariantModel).toList(),
        ),
      );

  @override
  Result<List<Stop>> getStopsForRoute(String routeVariantId) =>
      _cacheFirst<Stop, StopModel>(
        readCache: () => _local.getCachedStopsForRoute(routeVariantId),
        fetchRemote: () => _remote.getStopsForRoute(routeVariantId),
        writeCache: (stops) => _local.cacheStopsForRoute(
          routeVariantId,
          stops.map((e) => e as StopModel).toList(),
        ),
      );

  @override
  Result<List<Stop>> getAllStops() => _cacheFirst<Stop, StopModel>(
    readCache: _local.getCachedAllStops,
    fetchRemote: _remote.getAllStops,
    writeCache: (stops) =>
        _local.cacheAllStops(stops.map((e) => e as StopModel).toList()),
  );

  @override
  Result<List<NearbyStop>> getNearbyStops({
    required double lat,
    required double lng,
    required int radiusMeters,
  }) async {
    // SIEMPRE a la red: depende de dónde está parado el usuario, así que
    // no hay nada que cachear.
    try {
      final stops = await _remote.getNearbyStops(
        lat: lat,
        lng: lng,
        radiusMeters: radiusMeters,
      );
      return Right(stops);
    } on AppException catch (e) {
      return Left(_toFailure(e));
    }
  }

  @override
  Result<List<TripPlan>> planTrip({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    required int maxWalkMeters,
    required int maxResults,
  }) async {
    // SIEMPRE a la red, por lo mismo que `getNearbyStops`: la respuesta
    // depende de dos puntos arbitrarios del mapa. Cachear por par de
    // coordenadas sería una cache que nunca acierta dos veces.
    try {
      return Right(
        await _remote.planTrip(
          originLat: originLat,
          originLng: originLng,
          destLat: destLat,
          destLng: destLng,
          maxWalkMeters: maxWalkMeters,
          maxResults: maxResults,
        ),
      );
    } on AppException catch (e) {
      return Left(_toFailure(e));
    }
  }

  @override
  Result<List<RouteAtStop>> getRoutesForStop(String stopId) async {
    // Sin cache: se consulta al tocar UNA parada puntual, y cachear 1579
    // listas para un uso esporádico no paga.
    try {
      return Right(await _remote.getRoutesForStop(stopId));
    } on AppException catch (e) {
      return Left(_toFailure(e));
    }
  }

  @override
  Result<List<Schedule>> getSchedules({
    required String routeVariantId,
    required DayType dayType,
  }) => _cacheFirst<Schedule, ScheduleModel>(
    readCache: () => _local.getCachedSchedules(
      routeVariantId: routeVariantId,
      dayType: dayType,
    ),
    fetchRemote: () =>
        _remote.getSchedules(routeVariantId: routeVariantId, dayType: dayType),
    writeCache: (schedules) => _local.cacheSchedules(
      routeVariantId: routeVariantId,
      dayType: dayType,
      schedules: schedules.map((e) => e as ScheduleModel).toList(),
    ),
  );

  Future<Either<Failure, List<T>>> _cacheFirst<T, M extends T>({
    required Future<List<M>> Function() readCache,
    required Future<List<M>> Function() fetchRemote,
    required Future<void> Function(List<T>) writeCache,
  }) async {
    try {
      final cached = await readCache();
      if (cached.isNotEmpty) {
        // Se devuelve YA, sin tocar la red: la velocidad de arranque es EL
        // requisito del producto. Pero si lo guardado está viejo se dispara
        // un refresco de fondo, así que la próxima vez que se abra la app los
        // datos son nuevos. Es stale-while-revalidate: nadie espera y nadie
        // se queda con una copia de hace tres meses.
        if (await _isStale()) {
          _refreshInBackground(
            fetchRemote: fetchRemote,
            writeCache: writeCache,
          );
        }
        return Right(cached);
      }
    } on CacheException {
      // Miss o corrupción
    }

    try {
      final fresh = await fetchRemote();
      if (fresh.isNotEmpty) {
        try {
          await writeCache(fresh);
        } on CacheException {
          // No fatal
        }
      }
      return Right(fresh);
    } on AppException catch (e) {
      return Left(_toFailure(e));
    }
  }

  /// True si lo guardado pasó el [cacheTtl].
  ///
  /// **Sin marca de sincronización devuelve false**, o sea "no está vieja". Es
  /// a propósito: significa que no sabemos de cuándo es, y salir a la red por
  /// las dudas convertiría cada arranque de una cache legacy en una consulta
  /// que nadie pidió. La primera escritura pone la marca y a partir de ahí sí
  /// se puede decidir.
  Future<bool> _isStale() async {
    try {
      final synced = await _local.lastSyncedAt();
      if (synced == null) return false;
      return _now().difference(synced) > cacheTtl;
    } on Object {
      return false;
    }
  }

  /// Baja datos frescos y reescribe la cache SIN hacer esperar a nadie.
  ///
  /// No se await-ea y se traga todos los errores: es trabajo especulativo
  /// —sin señal, con el servidor caído o con la app cerrándose en el medio, el
  /// usuario ya tiene su respuesta— y una excepción sin capturar acá sería un
  /// crash en un camino que nadie pidió.
  void _refreshInBackground<T, M extends T>({
    required Future<List<M>> Function() fetchRemote,
    required Future<void> Function(List<T>) writeCache,
  }) {
    Future<void>(() async {
      try {
        final fresh = await fetchRemote();
        if (fresh.isNotEmpty) await writeCache(fresh);
      } on Object {
        // Queda la cache vieja y se reintenta en el próximo arranque.
      }
    });
  }

  Failure _toFailure(AppException exception) => switch (exception) {
    ServerException(:final message, :final statusCode) => ServerFailure(
      message: message,
      statusCode: statusCode,
    ),
    CacheException(:final message) => CacheFailure(message: message),
    NetworkException(:final message) => NetworkFailure(message: message),
    ParsingException(:final message) => DataParsingFailure(message: message),
  };

  /// Orden del listado de líneas: primero la RED, después el orden dentro
  /// de la red.
  ///
  /// La red va primero porque la UI agrupa por red con un encabezado por
  /// grupo: si dos redes se intercalan, los encabezados se repiten línea por
  /// medio. Y se intercalan sí o sí ordenando solo por código — el Gran
  /// Resistencia y Corrientes capital tienen los dos una 101, una 104, una
  /// 106 y una 110.
  static int _compareLines(BusLine a, BusLine b) {
    final byNetwork = a.network.sortOrder.compareTo(b.network.sortOrder);
    if (byNetwork != 0) return byNetwork;
    // Empate de sortOrder (cache vieja sin el campo): el código de red
    // desempata y mantiene el orden estable.
    final byNetworkCode = a.network.code.compareTo(b.network.code);
    if (byNetworkCode != 0) return byNetworkCode;

    final bySortOrder = a.sortOrder.compareTo(b.sortOrder);
    if (bySortOrder != 0) return bySortOrder;
    return _compareCodes(a.code, b.code);
  }

  static int _compareCodes(String a, String b) {
    final numA = int.tryParse(RegExp(r'^\d+').stringMatch(a) ?? '');
    final numB = int.tryParse(RegExp(r'^\d+').stringMatch(b) ?? '');
    if (numA != null && numB != null && numA != numB) {
      return numA.compareTo(numB);
    }
    if (numA != null && numB == null) return -1;
    if (numA == null && numB != null) return 1;
    return a.compareTo(b);
  }
}
