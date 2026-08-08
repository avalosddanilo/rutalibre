import '../../domain/entities/route_at_stop.dart';
import 'route_variant_model.dart';

/// DTO de la salida del RPC `get_lines_for_stop`, que ya viene aplanada
/// (línea + recorrido en la misma fila).
final class RouteAtStopModel extends RouteAtStop {
  const RouteAtStopModel({
    required super.lineId,
    required super.lineCode,
    required super.lineName,
    required super.colorHex,
    required super.routeVariantId,
    required super.variantName,
    required super.branch,
    required super.direction,
  });

  factory RouteAtStopModel.fromJson(Map<String, dynamic> json) =>
      RouteAtStopModel(
        lineId: json['line_id'] as String,
        lineCode: json['line_code'] as String,
        lineName: json['line_name'] as String,
        colorHex: json['color_hex'] as String,
        routeVariantId: json['route_variant_id'] as String,
        variantName: json['variant_name'] as String,
        branch: json['branch'] as String?,
        // El mismo mapeo smallint ↔ enum que el resto de la capa data.
        direction: RouteVariantModel.directionFromDb(
          (json['direction'] as num).toInt(),
        ),
      );
}
