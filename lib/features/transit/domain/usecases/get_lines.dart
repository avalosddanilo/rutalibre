import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/bus_line.dart';
import '../repositories/transit_repository.dart';

/// Devuelve todas las líneas activas, ordenadas por código.
///
/// Es la primera llamada de la app (pantalla principal / listado de líneas).
///
/// ```dart
/// final result = await getLines(const NoParams());
/// ```
final class GetLines implements UseCase<List<BusLine>, NoParams> {
  const GetLines(this._repository);

  final TransitRepository _repository;

  @override
  Result<List<BusLine>> call(NoParams params) => _repository.getLines();
}
