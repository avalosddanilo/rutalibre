import 'dart:async' show TimeoutException;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

/// Errores de geolocalización. NO son `Failure`s del dominio a propósito:
/// la posición del usuario es una preocupación del DISPOSITIVO, no de los
/// datos de tránsito — geolocator no puede entrar a domain. Son `sealed`
/// para que `failureMessage()` los traduzca con switch exhaustivo.
sealed class LocationError implements Exception {
  const LocationError();
}

/// El servicio de ubicación del sistema está apagado.
final class LocationServiceDisabled extends LocationError {
  const LocationServiceDisabled();
}

/// El usuario negó el permiso (se puede volver a pedir).
final class LocationPermissionDenied extends LocationError {
  const LocationPermissionDenied();
}

/// El usuario bloqueó el permiso permanentemente (solo se arregla
/// desde los ajustes del sistema).
final class LocationPermissionDeniedForever extends LocationError {
  const LocationPermissionDeniedForever();
}

/// El GPS no entregó una posición (timeout sin posición previa conocida).
final class LocationUnavailable extends LocationError {
  const LocationUnavailable();
}

/// Posición del usuario sin acoplar la UI al tipo `Position` del plugin.
typedef UserPosition = ({double lat, double lng});

/// Resultado de una localización: la posición y si es APROXIMADA
/// (permiso "aproximada" de Android 12+ / Precise off en iOS, o un fix con
/// error mayor al radio de búsqueda). La UI decide si avisa; no es error.
typedef LocationFix = ({UserPosition position, bool approximate});

/// Envuelve geolocator: el baile completo de permisos vive acá y en ningún
/// otro lado, y la UI puede mockear este servicio en tests sin plugins.
class LocationService {
  const LocationService();

  /// Un fix con más error que esto no sirve para un radio de ~500 m.
  static const _accuracyThresholdMeters = 400.0;

  Future<LocationFix> currentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationServiceDisabled();
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationPermissionDeniedForever();
    }
    if (permission == LocationPermission.denied) {
      throw const LocationPermissionDenied();
    }

    final reduced = await _hasReducedAccuracy();

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      return _fix(position, reduced);
    } on TimeoutException {
      // GPS lento (interiores, emulador): una posición vieja sirve más
      // que un error para "¿qué paradas tengo cerca?".
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) {
        return _fix(last, reduced);
      }
      throw const LocationUnavailable();
    }
  }

  /// La posición en vivo, mientras alguien la escuche.
  ///
  /// Existe para UNA cosa: el viaje en curso. Con la guía abierta, saber
  /// dónde estás es lo que permite decir "faltan 3 paradas" de verdad — y es
  /// el único momento en que seguir el GPS se justifica: la persona pidió
  /// explícitamente que la acompañemos.
  ///
  /// `distanceFilter: 20`: arriba de un colectivo no interesa cada metro, y
  /// cada fix de menos es batería. **No pide permiso**: si no está dado, el
  /// stream falla y quien escucha simplemente no muestra el dato — pedirlo
  /// acá interrumpiría con un diálogo en medio del viaje.
  Stream<UserPosition> positionStream() => Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 20,
    ),
  ).map((position) => (lat: position.latitude, lng: position.longitude));

  /// La última posición que el sistema YA tiene, o null.
  ///
  /// A diferencia de [currentPosition], esto **no pide permiso, no enciende
  /// el GPS y no espera un fix**: solo lee lo que la plataforma tenga
  /// guardado. Existe para lo que ADORNA una pantalla —"a cuánto llego
  /// caminando"— y que no justifica interrumpir a nadie con un diálogo de
  /// permisos ni gastarle batería.
  ///
  /// Devuelve null en vez de tirar: quien la llama no tiene un plan B que
  /// ofrecer, simplemente no muestra el dato.
  Future<UserPosition?> lastKnownPosition() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
      final last = await Geolocator.getLastKnownPosition();
      return last == null ? null : (lat: last.latitude, lng: last.longitude);
    } catch (_) {
      // Plataforma sin soporte, servicio apagado, lo que sea: sin posición.
      return null;
    }
  }

  static LocationFix _fix(Position position, bool reduced) => (
    position: (lat: position.latitude, lng: position.longitude),
    // accuracy == 0 significa "desconocida" en varias plataformas:
    // no lo tratamos como aproximado.
    approximate: reduced || position.accuracy > _accuracyThresholdMeters,
  );

  static Future<bool> _hasReducedAccuracy() async {
    try {
      final status = await Geolocator.getLocationAccuracy();
      return status == LocationAccuracyStatus.reduced;
    } catch (_) {
      // Plataformas sin soporte del API: decide el accuracy del fix.
      return false;
    }
  }
}

final locationServiceProvider = Provider<LocationService>(
  (ref) => const LocationService(),
);

/// Query activa del modo "cerca mío" (null = modo apagado).
///
/// Cuando tiene valor, la pantalla de mapa dibuja la posición del usuario
/// y las paradas cercanas devueltas por `nearbyStopsProvider`.
final nearbyQueryProvider =
    NotifierProvider<NearbyQueryNotifier, UserPosition?>(
      NearbyQueryNotifier.new,
    );

final class NearbyQueryNotifier extends Notifier<UserPosition?> {
  @override
  UserPosition? build() => null;

  void show(UserPosition position) => state = position;

  void clear() => state = null;
}

/// La posición en vivo del viaje en curso.
///
/// `autoDispose` es LA decisión acá: el stream del GPS arranca cuando el
/// primer widget lo escucha —la guía— y se corta solo cuando el último deja
/// de hacerlo — al terminar el viaje. Nadie tiene que acordarse de apagarlo,
/// y fuera de la guía la app no sigue a nadie, que es exactamente lo que
/// promete la política de privacidad.
///
/// El error (sin permiso, GPS apagado) NO se traduce a mensaje: los widgets
/// usan `.value` y sin posición simplemente no muestran el dato en vivo. La
/// guía completa funciona igual sin GPS, como siempre.
final livePositionProvider = StreamProvider.autoDispose<UserPosition>(
  (ref) => ref.watch(locationServiceProvider).positionStream(),
);

/// Desde dónde se mide "a cuánto llego caminando", o null si no se sabe.
///
/// Dos fuentes, en este orden:
///
/// 1. La posición del modo "cerca mío", si está encendido. Es de ESTA sesión
///    y la pidió el usuario a propósito, así que es la más confiable.
/// 2. La última que tenga guardada el sistema, que no cuesta permisos ni
///    batería.
///
/// Null es un resultado NORMAL —sin permiso, sin fix previo— y quien lo
/// consume simplemente no dibuja nada. Este provider nunca abre un diálogo
/// de permisos: pedirlo para adornar una hoja sería cobrarle al usuario una
/// interrupción por un dato que no pidió.
///
/// `autoDispose` para que cada vez que se abre una hoja se relea la posición
/// en vez de quedar clavada la de hace media hora.
final walkOriginProvider = FutureProvider.autoDispose<UserPosition?>((
  ref,
) async {
  final nearby = ref.watch(nearbyQueryProvider);
  if (nearby != null) return nearby;
  return ref.watch(locationServiceProvider).lastKnownPosition();
});
