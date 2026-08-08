import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/route_at_stop.dart';
import '../repositories/transit_repository.dart';

/// Qué recorridos pasan por una parada.
///
/// Es la consulta del pasajero parado en la vereda: toca la parada en el
/// mapa y quiere saber qué colectivos le sirven.
final class GetRoutesForStop
    implements UseCase<List<RouteAtStop>, GetRoutesForStopParams> {
  const GetRoutesForStop(this._repository);

  final TransitRepository _repository;

  @override
  Result<List<RouteAtStop>> call(GetRoutesForStopParams params) =>
      _repository.getRoutesForStop(params.stopId);
}

final class GetRoutesForStopParams extends Equatable {
  const GetRoutesForStopParams({required this.stopId});

  final String stopId;

  @override
  List<Object?> get props => [stopId];
}
