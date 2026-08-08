import 'package:equatable/equatable.dart';

import '../utils/result.dart';

/// Contrato base de todo usecase del dominio.
///
/// - `Type`: lo que devuelve en caso de éxito (ej: `List<BusLine>`).
/// - `Params`: los argumentos de entrada. Si no necesita ninguno, usar
///   [NoParams].
///
/// Al implementar `call`, cada usecase es invocable como función:
/// ```dart
/// final result = await getLines(const NoParams());
/// result.fold(
///   (failure) => /* mostrar error */,
///   (lines)   => /* renderizar */,
/// );
/// ```
abstract interface class UseCase<T, Params> {
  /// Nunca lanza excepciones: todo error viaja como `Failure` en la
  /// izquierda del `Either`.
  Result<T> call(Params params);
}

/// Marcador para usecases sin argumentos (ej: `GetLines`).
///
/// Se usa una clase (y no `void`) para mantener la firma de [UseCase]
/// uniforme y poder pasar `const NoParams()` explícitamente.
final class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => const [];
}
