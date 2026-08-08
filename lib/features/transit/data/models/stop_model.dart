import '../../domain/entities/stop.dart';

/// DTO de paradas. IMPORTANTE: no mapea la tabla `stops` cruda (cuyo `geom`
/// llega como WKB hexadecimal, inservible en el cliente) sino la salida de
/// los RPCs `get_stops_for_route` y `get_nearby_stops` (migración 0002),
/// que ya devuelven `lat`/`lng` como números planos calculados por PostGIS.
///
/// Claves extra del RPC (`stop_order`, `distance_m`) se ignoran: el orden
/// de la lista ya las refleja.
final class StopModel extends Stop {
  const StopModel({
    required super.id,
    required super.name,
    required super.lat,
    required super.lng,
    super.description,
  });

  factory StopModel.fromJson(Map<String, dynamic> json) => StopModel(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String?,
    // `as num` y no `as double`: jsonDecode entrega int para valores
    // enteros exactos (ej: lat = -27.0) y el cast directo a double explota.
    lat: (json['lat'] as num).toDouble(),
    lng: (json['lng'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'lat': lat,
    'lng': lng,
  };
}
