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
    super.osmNodeId,
  });

  factory StopModel.fromJson(Map<String, dynamic> json) => StopModel(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String?,
    // `as num` y no `as double`: jsonDecode entrega int para valores
    // enteros exactos (ej: lat = -27.0) y el cast directo a double explota.
    lat: (json['lat'] as num).toDouble(),
    lng: (json['lng'] as num).toDouble(),
    // Ausente ANTES de la migración 0010, y ausente en cualquier cache
    // escrita por una versión vieja de la app. Que falte no puede romper el
    // parseo: sería cambiar "no hay enlace a OSM" por "no hay paradas".
    osmNodeId: (json['osm_node_id'] as num?)?.toInt(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'lat': lat,
    'lng': lng,
    'osm_node_id': osmNodeId,
  };
}
