import '../../../../core/utils/result.dart';
import '../entities/bus_line.dart';
import '../entities/nearby_stop.dart';
import '../entities/route_at_stop.dart';
import '../entities/route_variant.dart';
import '../entities/schedule.dart';
import '../entities/stop.dart';
import '../entities/trip_plan.dart';

/// Contrato del repositorio de tránsito — la ÚNICA puerta de entrada del
/// dominio a los datos. Domain define QUÉ necesita; data decide CÓMO
/// conseguirlo (cache-first: local primero, Supabase como fallback/refresh).
///
/// Reglas del contrato:
/// - Nunca lanza excepciones: todo error llega como `Failure` dentro del
///   `Either` (ver `core/errors/failures.dart`).
/// - Solo devuelve registros activos (`is_active = true`); el filtrado es
///   responsabilidad de la implementación, no del caller.
/// - Las listas devueltas ya vienen en el orden útil para el caller
///   (ver doc de cada método).
///
/// La implementación (`TransitRepositoryImpl`) vive en
/// `features/transit/data/repositories/`.
abstract interface class TransitRepository {
  /// Todas las líneas activas, ordenadas por `code` (numérico primero:
  /// "3" antes que "110", "9" antes que "9B").
  Result<List<BusLine>> getLines();

  /// Los recorridos activos (ida/vuelta/ramales) de una línea.
  Result<List<RouteVariant>> getRouteVariants(String lineId);

  /// Las paradas de un recorrido, ordenadas por `stop_order`
  /// (posición 1 = cabecera). La secuencia viene de `route_stops`.
  Result<List<Stop>> getStopsForRoute(String routeVariantId);

  /// Paradas activas dentro de [radiusMeters] metros de la posición dada,
  /// ordenadas por distancia real (la más cercana primero) y CON esa
  /// distancia incluida.
  ///
  /// Respaldado por el RPC `get_nearby_stops(lat, lng, radius_m)`:
  /// la distancia en metros la calcula PostGIS (tipo `geography`),
  /// no el cliente. Requiere red: la posición del usuario no es cacheable.
  Result<List<NearbyStop>> getNearbyStops({
    required double lat,
    required double lng,
    required int radiusMeters,
  });

  /// TODAS las paradas activas, ordenadas por nombre.
  ///
  /// Existe para buscar el destino escribiendo: con la lista en el
  /// teléfono, el buscador es instantáneo y anda sin señal — que es
  /// exactamente donde se usa, arriba del colectivo.
  ///
  /// Cache-first como el resto de los datos estáticos: son ~1416 filas
  /// livianas que cambian una vez por reimportación.
  Result<List<Stop>> getAllStops();

  /// Cómo ir de un punto a otro — "¿qué me tomo para llegar allá?".
  ///
  /// Devuelve viajes de un colectivo o de UN transbordo, del mejor al peor
  /// (primero los directos, después por caminata total). Lista vacía = no
  /// hay forma de hacerlo caminando [maxWalkMeters] de cada punta, que es
  /// una respuesta legítima y no un error.
  ///
  /// Respaldado por el RPC `plan_trip(...)` (migración 0004): el cruce de
  /// `route_stops` consigo mismo lo resuelve Postgres, que es el único
  /// lugar donde no cuesta.
  ///
  /// Va SIEMPRE a red, como `getNearbyStops`: la respuesta depende de dos
  /// puntos arbitrarios y no hay nada que cachear.
  Result<List<TripPlan>> planTrip({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    required int maxWalkMeters,
    required int maxResults,
  });

  /// Recorridos que pasan por una parada — "¿qué colectivo me sirve acá?".
  ///
  /// Respaldado por el RPC `get_lines_for_stop(stop_id)`, que resuelve el
  /// join en la base en vez de bajarse `route_stops` entero.
  Result<List<RouteAtStop>> getRoutesForStop(String stopId);

  /// Las salidas desde cabecera de un recorrido para un tipo de día.
  Result<List<Schedule>> getSchedules({
    required String routeVariantId,
    required DayType dayType,
  });
}
