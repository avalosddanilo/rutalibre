import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/route_variant.dart';
import '../repositories/transit_repository.dart';

/// Devuelve los recorridos activos (ida/vuelta/ramales) de una línea.
///
/// Se invoca cuando el usuario selecciona una línea, para ofrecerle
/// qué trazado dibujar en el mapa.
final class GetRouteVariants
    implements UseCase<List<RouteVariant>, GetRouteVariantsParams> {
  const GetRouteVariants(this._repository);

  final TransitRepository _repository;

  @override
  Result<List<RouteVariant>> call(GetRouteVariantsParams params) =>
      _repository.getRouteVariants(params.lineId);
}

final class GetRouteVariantsParams extends Equatable {
  const GetRouteVariantsParams({required this.lineId});

  /// Id de la [BusLine] cuyos recorridos se piden.
  final String lineId;

  @override
  List<Object?> get props => [lineId];
}
