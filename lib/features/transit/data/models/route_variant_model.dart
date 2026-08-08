import '../../domain/entities/route_variant.dart';

/// DTO de `route_variants`. El mapeo smallint ↔ [RouteDirection] vive acá:
/// el dominio nunca ve el 0/1 de la base.
///
/// NOTA: `geom` NO se mapea a propósito. El datasource remoto pide las
/// columnas explícitamente sin la geometría (payload pesado que el mapa
/// pide por separado vía `get_route_geojson`).
final class RouteVariantModel extends RouteVariant {
  const RouteVariantModel({
    required super.id,
    required super.lineId,
    required super.name,
    required super.direction,
    required super.isActive,
    super.branch,
  });

  factory RouteVariantModel.fromJson(Map<String, dynamic> json) =>
      RouteVariantModel(
        id: json['id'] as String,
        lineId: json['line_id'] as String,
        name: json['name'] as String,
        branch: json['branch'] as String?,
        direction: directionFromDb(json['direction'] as int),
        isActive: json['is_active'] as bool,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'line_id': lineId,
    'name': name,
    'branch': branch,
    'direction': directionToDb(direction),
    'is_active': isActive,
  };

  /// 0 = ida, 1 = vuelta (CHECK constraint en la base).
  static RouteDirection directionFromDb(int value) => switch (value) {
    0 => RouteDirection.outbound,
    1 => RouteDirection.inbound,
    _ => throw FormatException('direction desconocida: $value'),
  };

  static int directionToDb(RouteDirection direction) => switch (direction) {
    RouteDirection.outbound => 0,
    RouteDirection.inbound => 1,
  };
}
