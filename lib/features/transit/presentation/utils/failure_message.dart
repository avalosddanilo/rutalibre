import '../../../../core/errors/failures.dart';
import '../providers/location_providers.dart';

/// Punto ÚNICO de traducción error → texto visible para el usuario.
/// Futuro punto de i18n: cuando llegue la localización, se toca este
/// archivo y ninguna pantalla.
///
/// Recibe `Object` porque los errores llegan desde `AsyncValue.error`
/// (que borra el tipo) y desde `catch` genéricos, pero deriva de inmediato
/// a switches EXHAUSTIVOS sin wildcard: agregar un `Failure` o
/// `LocationError` nuevo sin traducción es error de compilación, no un
/// "Algo salió mal" silencioso.
String failureMessage(Object error) {
  if (error is Failure) return _failureText(error);
  if (error is LocationError) return _locationText(error);
  return 'Algo salió mal. Probá de nuevo.';
}

String _failureText(Failure failure) => switch (failure) {
  NetworkFailure() =>
    'Sin conexión. Conectate a internet al menos una vez para descargar los datos.',
  ServerFailure() => 'El servidor no respondió. Probá de nuevo en un rato.',
  CacheFailure() => 'No se pudieron leer los datos guardados.',
  DataParsingFailure() =>
    'Los datos llegaron en un formato inesperado. Actualizá la app.',
};

String _locationText(LocationError error) => switch (error) {
  LocationServiceDisabled() =>
    'El GPS está apagado. Encendelo para ver qué paradas tenés cerca.',
  LocationPermissionDenied() =>
    'Sin permiso de ubicación no podemos mostrarte las paradas cercanas.',
  LocationPermissionDeniedForever() =>
    'El permiso de ubicación está bloqueado. Habilitalo desde los ajustes del teléfono.',
  LocationUnavailable() => 'No pudimos obtener tu ubicación. Probá de nuevo.',
};
