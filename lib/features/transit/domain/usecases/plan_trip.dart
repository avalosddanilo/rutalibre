import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/trip_plan.dart';
import '../repositories/transit_repository.dart';

/// Contesta "estoy acá, quiero ir allá, ¿qué me tomo?".
///
/// Devuelve viajes de UN colectivo o de un transbordo, del mejor al peor:
/// primero los directos, después por caminata total y por último por
/// cantidad de paradas arriba. El cálculo pesado (qué recorridos pasan por
/// qué paradas y en qué orden) lo hace PostGIS en el servidor; este usecase
/// valida y orquesta.
final class PlanTrip implements UseCase<List<TripPlan>, PlanTripParams> {
  const PlanTrip(this._repository);

  final TransitRepository _repository;

  @override
  Result<List<TripPlan>> call(PlanTripParams params) => _repository.planTrip(
    originLat: params.originLat,
    originLng: params.originLng,
    destLat: params.destLat,
    destLng: params.destLng,
    maxWalkMeters: params.maxWalkMeters,
    maxResults: params.maxResults,
  );
}

final class PlanTripParams extends Equatable {
  const PlanTripParams({
    required this.originLat,
    required this.originLng,
    required this.destLat,
    required this.destLng,
    this.maxWalkMeters = defaultMaxWalkMeters,
    this.maxResults = defaultMaxResults,
  }) : assert(
         originLat >= -90 && originLat <= 90,
         'originLat fuera de rango WGS84',
       ),
       assert(
         originLng >= -180 && originLng <= 180,
         'originLng fuera de rango WGS84',
       ),
       assert(destLat >= -90 && destLat <= 90, 'destLat fuera de rango WGS84'),
       assert(
         destLng >= -180 && destLng <= 180,
         'destLng fuera de rango WGS84',
       ),
       assert(maxWalkMeters > 0, 'maxWalkMeters debe ser positivo'),
       assert(maxResults > 0, 'maxResults debe ser positivo');

  /// Cuánto se acepta caminar de cada punta, en metros.
  ///
  /// 500 m son unas cinco cuadras. Es el número que decide cuánto sirve el
  /// planificador: medido sobre los datos reales del Gran Resistencia, con
  /// 300 m se resuelve el 82% de los pares origen-destino (directo o con
  /// un transbordo), con 400 m el 87% y con 600 m el 92%. Pasarse tampoco
  /// es gratis: nadie camina un kilómetro para tomarse el colectivo.
  static const int defaultMaxWalkMeters = 500;

  /// Cuántas opciones devolver. Más de media docena no se leen.
  static const int defaultMaxResults = 6;

  final double originLat;
  final double originLng;
  final double destLat;
  final double destLng;
  final int maxWalkMeters;
  final int maxResults;

  @override
  List<Object?> get props => [
    originLat,
    originLng,
    destLat,
    destLng,
    maxWalkMeters,
    maxResults,
  ];
}
