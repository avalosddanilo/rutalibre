import 'dart:async';
// dart:io es seguro acá: el MVP compila solo android/ios. Si algún día se
// agrega web, este import se reemplaza por detección sin dart:io.
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/schedule.dart';
import '../models/bus_line_model.dart';
import '../models/nearby_stop_model.dart';
import '../models/route_at_stop_model.dart';
import '../models/route_variant_model.dart';
import '../models/schedule_model.dart';
import '../models/stop_model.dart';
import '../models/trip_plan_model.dart';

/// Contrato del datasource remoto. Habla en MODELOS y lanza EXCEPCIONES
/// (nunca devuelve Either: eso es trabajo del repositorio).
abstract interface class TransitRemoteDataSource {
  Future<List<BusLineModel>> getLines();

  Future<List<RouteVariantModel>> getRouteVariants(String lineId);

  Future<List<StopModel>> getStopsForRoute(String routeVariantId);

  Future<List<StopModel>> getAllStops();

  Future<List<NearbyStopModel>> getNearbyStops({
    required double lat,
    required double lng,
    required int radiusMeters,
  });

  Future<List<RouteAtStopModel>> getRoutesForStop(String stopId);

  Future<List<TripPlanModel>> planTrip({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    required int maxWalkMeters,
    required int maxResults,
  });

  Future<List<ScheduleModel>> getSchedules({
    required String routeVariantId,
    required DayType dayType,
  });
}

/// Implementación contra Supabase (PostgREST + RPCs).
///
/// El filtrado por `is_active` NO se hace acá: las políticas RLS ya
/// garantizan que la anon key solo ve registros activos. Menos código,
/// una sola fuente de verdad.
final class SupabaseTransitRemoteDataSource implements TransitRemoteDataSource {
  const SupabaseTransitRemoteDataSource(this._client);

  final SupabaseClient _client;

  @override
  Future<List<BusLineModel>> getLines() => _guard(
    // `networks(...)` es un join embebido de PostgREST: la red viene en
    // el mismo viaje. El orden natural ("3" antes que "110") ya está
    // resuelto en la columna `sort_order`.
    () => _client
        .from('lines')
        .select(
          'id, code, name, destinations, color_hex, sort_order, '
          'networks(code, name, sort_order)',
        )
        .order('sort_order', ascending: true)
        .order('code', ascending: true),
    BusLineModel.fromJson,
  );

  @override
  Future<List<RouteVariantModel>> getRouteVariants(String lineId) => _guard(
    // Columnas explícitas: NUNCA traer `geom` acá (WKB pesado que el
    // mapa pide por separado vía RPC get_route_geojson).
    () => _client
        .from('route_variants')
        .select('id, line_id, name, branch, direction, is_active')
        .eq('line_id', lineId)
        .order('branch', ascending: true)
        .order('direction', ascending: true),
    RouteVariantModel.fromJson,
  );

  @override
  Future<List<StopModel>> getStopsForRoute(String routeVariantId) => _guard(
    // RPC (migración 0002): devuelve JSON con lat/lng planos,
    // ya ordenado por stop_order.
    () => _client.rpc<dynamic>(
      'get_stops_for_route',
      params: {'variant_id': routeVariantId},
    ),
    StopModel.fromJson,
  );

  @override
  Future<List<StopModel>> getAllStops() => _guard(
    // RPC (migración 0008): las ~1416 paradas de una vez, ordenadas por
    // nombre. Se bajan enteras y se cachean porque el buscador de destino
    // tiene que andar SIN SEÑAL — arriba del colectivo es donde se usa.
    () => _client.rpc<dynamic>('get_all_stops'),
    StopModel.fromJson,
  );

  @override
  Future<List<NearbyStopModel>> getNearbyStops({
    required double lat,
    required double lng,
    required int radiusMeters,
  }) => _guard(
    // RPC (migración 0003): ordenado por distancia real en metros, y
    // con esa distancia incluida en cada fila.
    () => _client.rpc<dynamic>(
      'get_nearby_stops',
      params: {'lat': lat, 'lng': lng, 'radius_m': radiusMeters},
    ),
    NearbyStopModel.fromJson,
  );

  @override
  Future<List<RouteAtStopModel>> getRoutesForStop(String stopId) => _guard(
    // RPC (migración 0003): resuelve el join línea↔recorrido en la base
    // en vez de bajarse `route_stops` entero al teléfono.
    () =>
        _client.rpc<dynamic>('get_lines_for_stop', params: {'stop_id': stopId}),
    RouteAtStopModel.fromJson,
  );

  @override
  Future<List<TripPlanModel>> planTrip({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    required int maxWalkMeters,
    required int maxResults,
  }) => _guard(
    // RPC (migración 0004): el cruce de `route_stops` consigo mismo para
    // encontrar directos y transbordos se resuelve en Postgres. Traerse
    // las 3030 filas de secuencia al teléfono para cruzarlas acá sería
    // pagar la red y la batería por lo mismo.
    () => _client.rpc<dynamic>(
      'plan_trip',
      params: {
        'origin_lat': originLat,
        'origin_lng': originLng,
        'dest_lat': destLat,
        'dest_lng': destLng,
        'max_walk_m': maxWalkMeters,
        'max_results': maxResults,
      },
    ),
    TripPlanModel.fromJson,
  );

  @override
  Future<List<ScheduleModel>> getSchedules({
    required String routeVariantId,
    required DayType dayType,
  }) => _guard(
    () => _client
        .from('schedules')
        .select('id, route_variant_id, day_type, departure_time')
        .eq('route_variant_id', routeVariantId)
        .eq('day_type', ScheduleModel.dayTypeToDb(dayType))
        .order('departure_time', ascending: true),
    ScheduleModel.fromJson,
  );

  /// Toda consulta pasa por acá: un solo lugar donde los errores crudos
  /// (Supabase, red, JSON) se traducen a las excepciones tipadas que el
  /// repositorio sabe atrapar.
  Future<List<T>> _guard<T>(
    Future<dynamic> Function() query,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final dynamic response;
    try {
      response = await query();
    } on PostgrestException catch (e) {
      throw ServerException(e.message, statusCode: int.tryParse(e.code ?? ''));
    } on SocketException {
      throw const NetworkException('Sin conexión con el servidor');
    } on TimeoutException {
      throw const NetworkException('La consulta al servidor excedió el tiempo');
    } catch (e) {
      // supabase puede envolver el error de socket en otras excepciones.
      if (e.toString().contains('SocketException')) {
        throw const NetworkException('Sin conexión con el servidor');
      }
      throw ServerException('Error inesperado consultando Supabase: $e');
    }

    try {
      return (response as List<dynamic>)
          .map((row) => fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ParsingException('Respuesta remota con formato inesperado: $e');
    }
  }
}
