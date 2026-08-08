import '../../domain/entities/nearby_stop.dart';
import 'stop_model.dart';

/// DTO de la salida del RPC `get_nearby_stops`, que devuelve las columnas
/// de la parada MÁS `distance_m` calculada por PostGIS.
final class NearbyStopModel extends NearbyStop {
  const NearbyStopModel({
    required StopModel super.stop,
    required super.distanceMeters,
  });

  factory NearbyStopModel.fromJson(Map<String, dynamic> json) =>
      NearbyStopModel(
        stop: StopModel.fromJson(json),
        // `as num` y no `as double`: si la distancia da exacta, Postgres
        // puede mandarla como entero.
        distanceMeters: (json['distance_m'] as num).toDouble(),
      );
}
