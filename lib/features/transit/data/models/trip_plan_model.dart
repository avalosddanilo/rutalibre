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

  /// El espejo exacto de [TripLegModel.fromJson], para poder GUARDAR un
  /// viaje: el viaje activo se persiste en el teléfono y se restaura con el
  /// mismo `fromJson` que parsea la respuesta del RPC. Un solo formato, un
  /// solo parser.
  static Map<String, dynamic> legToJson(TripLeg leg) => {
    'line_id': leg.lineId,
    'line_code': leg.lineCode,
    'line_name': leg.lineName,
    'color_hex': leg.colorHex,
    'network_code': leg.networkCode,
    'network_name': leg.networkName,
    'route_variant_id': leg.routeVariantId,
    'variant_name': leg.variantName,
    'branch': leg.branch,
    'direction': RouteVariantModel.directionToDb(leg.direction),
    'board_stop': StopModel(
      id: leg.boardStop.id,
      name: leg.boardStop.name,
      description: leg.boardStop.description,
      lat: leg.boardStop.lat,
      lng: leg.boardStop.lng,
      osmNodeId: leg.boardStop.osmNodeId,
    ).toJson(),
    'alight_stop': StopModel(
      id: leg.alightStop.id,
      name: leg.alightStop.name,
      description: leg.alightStop.description,
      lat: leg.alightStop.lat,
      lng: leg.alightStop.lng,
      osmNodeId: leg.alightStop.osmNodeId,
    ).toJson(),
    'stop_count': leg.stopCount,
  };
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

  /// Espejo de [TripPlanModel.fromJson]. Ver [TripLegModel.legToJson].
  static Map<String, dynamic> planToJson(TripPlan plan) => {
    'leg_count': plan.legs.length,
    'walk_to_board_m': plan.walkToBoardMeters,
    'walk_from_alight_m': plan.walkFromAlightMeters,
    'legs': [for (final leg in plan.legs) TripLegModel.legToJson(leg)],
  };
}
