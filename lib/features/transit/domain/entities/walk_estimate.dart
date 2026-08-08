import 'dart:math' as math;

import 'package:equatable/equatable.dart';

/// Cuánto hay caminando hasta una parada: la distancia y el tiempo.
///
/// Es un modelo de lectura de una sola cuenta, pero vive en el dominio y no
/// en la pantalla porque las dos constantes de abajo son decisiones de
/// PRODUCTO, no de dibujo, y las va a necesitar más de una pantalla (el
/// detalle de parada hoy; los tramos a pie del planificador mañana, que ya
/// guardan metros y no saben decir minutos).
///
/// Dart puro, sin latlong2: el dominio no depende del paquete de mapas (ver
/// [Stop]). El haversine de acá abajo son ocho líneas y evita esa dependencia.
class WalkEstimate extends Equatable {
  const WalkEstimate({required this.meters}) : assert(meters >= 0);

  /// Distancia EN LÍNEA RECTA. El nombre importa: no es lo que se camina.
  final double meters;

  /// Ritmo de alguien que va a tomarse el colectivo: ~4,9 km/h. Más rápido
  /// que un paseo y más lento que apurado.
  static const metersPerSecond = 1.35;

  /// Cuánto más se camina que la línea recta.
  ///
  /// Nadie atraviesa las manzanas: se va por la vereda, doblando en las
  /// esquinas. En una traza de damero como la de Resistencia el recorrido
  /// real ronda un 30% más que la recta. Sin este factor, cada estimación
  /// saldría corta —siempre para el mismo lado—, que es la peor forma de
  /// equivocarse: manda a alguien a salir tarde.
  static const detourFactor = 1.3;

  /// Metros que se caminan de verdad, estimados.
  double get walkedMeters => meters * detourFactor;

  /// Cuánto se tarda. Redondeado HACIA ARRIBA al minuto y con un piso de un
  /// minuto: "0 min" no es una respuesta, y quedarse corto es peor que
  /// pasarse.
  Duration get duration {
    final seconds = walkedMeters / metersPerSecond;
    return Duration(minutes: math.max(1, (seconds / 60).ceil()));
  }

  /// "350 m" o "1,2 km" — el mismo formato que `NearbyStop`.
  String get formattedDistance {
    if (meters < 1000) return '${meters.round()} m';
    final km = (meters / 1000).toStringAsFixed(1).replaceAll('.', ',');
    return '$km km';
  }

  /// "6 min" o "1 h 5 min".
  String get formattedDuration {
    final minutes = duration.inMinutes;
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final rest = minutes % 60;
    return rest == 0 ? '$hours h' : '$hours h $rest min';
  }

  /// Una línea lista para mostrar.
  ///
  /// Dice "unos" a propósito: esto es una recta por una velocidad promedio,
  /// no un ruteo por las veredas. Poner "6 min" a secas prometería una
  /// precisión que la cuenta no tiene — la misma regla que el aviso de
  /// lluvia, que dice "en menos de una hora" y no "en 43 minutos".
  String get label =>
      'A $formattedDistance · unos $formattedDuration caminando';

  /// Distancia sobre la esfera entre dos puntos WGS84.
  ///
  /// Precisión de sobra: a escala de barrio el error del modelo esférico
  /// contra el elipsoide es de centímetros, y el factor de rodeo de arriba
  /// lo tapa mil veces.
  static WalkEstimate between({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) {
    const earthRadius = 6371000.0;
    double rad(double degrees) => degrees * math.pi / 180;

    final dLat = rad(toLat - fromLat);
    final dLng = rad(toLng - fromLng);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(rad(fromLat)) *
            math.cos(rad(toLat)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return WalkEstimate(
      meters: 2 * earthRadius * math.atan2(math.sqrt(a), math.sqrt(1 - a)),
    );
  }

  @override
  List<Object?> get props => [meters];
}
