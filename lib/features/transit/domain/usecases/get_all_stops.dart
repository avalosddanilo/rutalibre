import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/stop.dart';
import '../repositories/transit_repository.dart';

/// Todas las paradas activas, ordenadas por nombre.
///
/// Alimenta al buscador de destino de "¿cómo llego?". No filtra ni recorta:
/// filtrar por texto es trabajo de presentation (la comparación sin tildes
/// vive en `search_text.dart`), y hacerlo acá obligaría a un viaje a la red
/// por cada tecla — justo lo que este usecase evita.
final class GetAllStops implements UseCase<List<Stop>, NoParams> {
  const GetAllStops(this._repository);

  final TransitRepository _repository;

  @override
  Result<List<Stop>> call(NoParams params) => _repository.getAllStops();
}
