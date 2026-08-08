/// Excepciones de INFRAESTRUCTURA: viven exclusivamente en la capa data.
///
/// Contrato de capas:
///   datasources  → lanzan estas excepciones (throw).
///   repositories → las atrapan (catch) y las convierten en `Failure`
///                  dentro de un `Either`. NINGUNA excepción cruza
///                  hacia domain ni presentation.
///
/// Correspondencia 1:1 con los Failures de `failures.dart`:
///   ServerException  → ServerFailure
///   CacheException   → CacheFailure
///   NetworkException → NetworkFailure
///   ParsingException → DataParsingFailure
library;

/// Base común: permite `on AppException` como catch genérico en el
/// repository sin atrapar errores de programación (StateError, etc.).
sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// El backend respondió con error (status 4xx/5xx, error de PostgREST/RPC).
final class ServerException extends AppException {
  const ServerException(super.message, {this.statusCode});

  final int? statusCode;

  @override
  String toString() => 'ServerException($statusCode): $message';
}

/// Falla al leer o escribir la cache local (corrupción, storage lleno,
/// clave inexistente en la primera apertura).
final class CacheException extends AppException {
  const CacheException(super.message);
}

/// La request nunca llegó al servidor: sin conectividad, timeout, DNS.
final class NetworkException extends AppException {
  const NetworkException(super.message);
}

/// El JSON recibido (de red o de cache) no matchea el modelo esperado.
final class ParsingException extends AppException {
  const ParsingException(super.message);
}
