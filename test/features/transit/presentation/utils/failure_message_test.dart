import 'package:flutter_test/flutter_test.dart';
import 'package:rutalibre/core/errors/failures.dart';
import 'package:rutalibre/features/transit/presentation/providers/location_providers.dart';
import 'package:rutalibre/features/transit/presentation/utils/failure_message.dart';

/// Pinnea cada mensaje: failureMessage recibe Object (AsyncValue.error borra
/// el tipo), así que el compilador no puede garantizar acá la cobertura de
/// los sealed — este test es la única guarda de que cada error tiene su
/// texto accionable y no cae al genérico.
void main() {
  group('failureMessage: Failures del dominio', () {
    test('NetworkFailure', () {
      expect(
        failureMessage(const NetworkFailure()),
        'Sin conexión. Conectate a internet al menos una vez para descargar los datos.',
      );
    });

    test('ServerFailure', () {
      expect(
        failureMessage(const ServerFailure()),
        'El servidor no respondió. Probá de nuevo en un rato.',
      );
    });

    test('CacheFailure', () {
      expect(
        failureMessage(const CacheFailure()),
        'No se pudieron leer los datos guardados.',
      );
    });

    test('DataParsingFailure', () {
      expect(
        failureMessage(const DataParsingFailure()),
        'Los datos llegaron en un formato inesperado. Actualizá la app.',
      );
    });
  });

  group('failureMessage: LocationErrors', () {
    test('LocationServiceDisabled', () {
      expect(
        failureMessage(const LocationServiceDisabled()),
        'El GPS está apagado. Encendelo para ver qué paradas tenés cerca.',
      );
    });

    test('LocationPermissionDenied', () {
      expect(
        failureMessage(const LocationPermissionDenied()),
        'Sin permiso de ubicación no podemos mostrarte las paradas cercanas.',
      );
    });

    test('LocationPermissionDeniedForever', () {
      expect(
        failureMessage(const LocationPermissionDeniedForever()),
        'El permiso de ubicación está bloqueado. Habilitalo desde los ajustes del teléfono.',
      );
    });

    test('LocationUnavailable', () {
      expect(
        failureMessage(const LocationUnavailable()),
        'No pudimos obtener tu ubicación. Probá de nuevo.',
      );
    });
  });

  test('cualquier otro Object cae al mensaje genérico', () {
    expect(failureMessage(Exception('x')), 'Algo salió mal. Probá de nuevo.');
    expect(failureMessage('un string'), 'Algo salió mal. Probá de nuevo.');
  });
}
