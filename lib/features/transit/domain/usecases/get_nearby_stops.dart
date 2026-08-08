import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/nearby_stop.dart';
import '../repositories/transit_repository.dart';

/// Devuelve las paradas MÁS CERCANAS a una posición, ordenadas por distancia
/// (la más cercana primero) y con la distancia en metros.
///
/// El cálculo de distancia lo hace PostGIS en el servidor (metros reales
/// sobre `geography`); este usecase ordena y recorta.
///
/// El recorte es la respuesta a una pregunta de producto: parado en el
/// centro de Resistencia hay más de 40 paradas a menos de 500 m, y nadie
/// camina hasta la número 40. "Cerca mío" son las primeras, no todas.
final class GetNearbyStops
    implements UseCase<List<NearbyStop>, GetNearbyStopsParams> {
  const GetNearbyStops(this._repository);

  final TransitRepository _repository;

  @override
  Result<List<NearbyStop>> call(GetNearbyStopsParams params) async {
    final result = await _repository.getNearbyStops(
      lat: params.lat,
      lng: params.lng,
      radiusMeters: params.radiusMeters,
    );
    return result.map((stops) {
      // Se ordena acá aunque el RPC ya devuelva ordenado: recortar los
      // primeros N solo significa "los más cercanos" si la lista está
      // ordenada, y esa garantía tiene que valer en este archivo y no en el
      // SQL de otra capa.
      final sorted = [...stops]
        ..sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
      return sorted.take(params.maxResults).toList(growable: false);
    });
  }
}

final class GetNearbyStopsParams extends Equatable {
  const GetNearbyStopsParams({
    required this.lat,
    required this.lng,
    this.radiusMeters = defaultRadiusMeters,
    this.maxResults = defaultMaxResults,
  }) : assert(lat >= -90 && lat <= 90, 'lat fuera de rango WGS84'),
       assert(lng >= -180 && lng <= 180, 'lng fuera de rango WGS84'),
       assert(radiusMeters > 0, 'radiusMeters debe ser positivo'),
       assert(maxResults > 0, 'maxResults debe ser positivo');

  /// Radio por defecto: ~5 cuadras. Mismo default que el RPC
  /// `get_nearby_stops` en Supabase — mantener sincronizados.
  static const int defaultRadiusMeters = 500;

  /// Cuántas paradas devolver como mucho. Doce entran en una hoja sin
  /// scrollear a lo loco y cubren de sobra las opciones caminables.
  static const int defaultMaxResults = 12;

  /// Posición del usuario en grados decimales, WGS84.
  final double lat;
  final double lng;

  /// Radio de búsqueda en metros.
  final int radiusMeters;

  /// Tope de paradas devueltas, las más cercanas primero.
  final int maxResults;

  @override
  List<Object?> get props => [lat, lng, radiusMeters, maxResults];
}
