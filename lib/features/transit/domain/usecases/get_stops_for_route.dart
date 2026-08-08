import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/stop.dart';
import '../repositories/transit_repository.dart';

/// Devuelve las paradas de un recorrido en orden de paso
/// (índice 0 = cabecera), para marcarlas sobre el trazado en el mapa.
final class GetStopsForRoute
    implements UseCase<List<Stop>, GetStopsForRouteParams> {
  const GetStopsForRoute(this._repository);

  final TransitRepository _repository;

  @override
  Result<List<Stop>> call(GetStopsForRouteParams params) =>
      _repository.getStopsForRoute(params.routeVariantId);
}

final class GetStopsForRouteParams extends Equatable {
  const GetStopsForRouteParams({required this.routeVariantId});

  /// Id del [RouteVariant] cuyas paradas se piden.
  final String routeVariantId;

  @override
  List<Object?> get props => [routeVariantId];
}
