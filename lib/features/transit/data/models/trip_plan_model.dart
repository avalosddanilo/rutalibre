import '../../domain/entities/trip_plan.dart';
import 'route_variant_model.dart';
import 'stop_model.dart';

/// DTO de un tramo dentro de la salida del RPC `plan_trip`.
final class TripLegModel extends TripLeg {
  const TripLegModel({
    required super.lineId,
    required super.lineCode,
    required super.lineName,
    required super.colorHex,
    required super.networkCode,
    required super.networkName,
    required super.routeVariantId,
    required super.variantName,
    required super.branch,
    required super.direction,
    required super.boardStop,
    required super.alightStop,
    required super.stopCount,
  });

  factory TripLegModel.fromJson(Map<String, dynamic> json) => TripLegModel(
    lineId: json['line_id'] as String,
    lineCode: json['line_code'] as String,
    lineName: json['line_name'] as String,
    colorHex: json['color_hex'] as String,
    networkCode: json['network_code'] as String,
    networkName: json['network_name'] as String,
    routeVariantId: json['route_variant_id'] as String,
    variantName: json['variant_name'] as String,
    branch: json['branch'] as String?,
    // El mismo mapeo smallint ↔ enum que el resto de la capa data.
    direction: RouteVariantModel.directionFromDb(
      (json['direction'] as num).toInt(),
    ),
    boardStop: StopModel.fromJson(json['board_stop'] as Map<String, dynamic>),
    alightStop: StopModel.fromJson(json['alight_stop'] as Map<String, dynamic>),
    stopCount: (json['stop_count'] as num).toInt(),
  );
}

/// DTO de la salida del RPC `plan_trip`.
///
/// El JSON viene ANIDADO (un viaje trae su lista de tramos) y no aplanado
/// como el resto de los RPCs: aplanarlo obligaría a la app a reagrupar por
/// viaje, que es justo el trabajo que la base ya hizo.
final class TripPlanModel extends TripPlan {
  const TripPlanModel({
    required super.legs,
    required super.walkToBoardMeters,
    required super.walkFromAlightMeters,
  });

  factory TripPlanModel.fromJson(Map<String, dynamic> json) => TripPlanModel(
    legs: [
      for (final leg in json['legs'] as List)
        TripLegModel.fromJson(leg as Map<String, dynamic>),
    ],
    // Los RPCs devuelven los números como `num`: puede llegar int.
    walkToBoardMeters: (json['walk_to_board_m'] as num).toDouble(),
    walkFromAlightMeters: (json['walk_from_alight_m'] as num).toDouble(),
  );
}
