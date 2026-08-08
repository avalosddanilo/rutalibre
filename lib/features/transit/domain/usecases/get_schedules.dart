import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/schedule.dart';
import '../repositories/transit_repository.dart';

/// Devuelve las salidas desde cabecera de un recorrido para un tipo de día,
/// SIEMPRE ordenadas cronológicamente.
///
/// El orden se garantiza acá (regla de dominio: una tabla de horarios
/// desordenada no tiene sentido para nadie) en lugar de confiar en que
/// cada implementación del repositorio lo recuerde. `Either.map` solo
/// transforma el caso exitoso; un `Failure` pasa de largo intacto.
final class GetSchedules
    implements UseCase<List<Schedule>, GetSchedulesParams> {
  const GetSchedules(this._repository);

  final TransitRepository _repository;

  @override
  Result<List<Schedule>> call(GetSchedulesParams params) async {
    final result = await _repository.getSchedules(
      routeVariantId: params.routeVariantId,
      dayType: params.dayType,
    );

    return result.map(
      (schedules) => List<Schedule>.unmodifiable(
        [...schedules]
          ..sort((a, b) => a.departureTime.compareTo(b.departureTime)),
      ),
    );
  }
}

final class GetSchedulesParams extends Equatable {
  const GetSchedulesParams({
    required this.routeVariantId,
    required this.dayType,
  });

  /// Id del [RouteVariant] cuyos horarios se piden.
  final String routeVariantId;

  /// Hábil, sábado o domingo/feriado. Quién decide qué [DayType]
  /// corresponde a "hoy" es presentation (necesita fecha y feriados);
  /// el dominio solo responde a lo que se le pide.
  final DayType dayType;

  @override
  List<Object?> get props => [routeVariantId, dayType];
}
