import 'package:equatable/equatable.dart';

import 'stop.dart';

/// Una parada CON su distancia a la posición consultada.
///
/// La distancia no es un atributo de la parada (la misma parada está a
/// distinta distancia de cada persona): es el resultado de una consulta.
/// Por eso viaja acá y no dentro de [Stop].
///
/// El número lo calcula PostGIS en el servidor sobre `geography`, así que
/// son metros reales sobre el elipsoide, no una aproximación del cliente.
class NearbyStop extends Equatable {
  const NearbyStop({required this.stop, required this.distanceMeters});

  final Stop stop;

  /// Distancia en metros desde la posición consultada.
  final double distanceMeters;

  /// "120 m" o "1,4 km" — formato listo para mostrar.
  String get formattedDistance {
    if (distanceMeters < 1000) {
      return '${distanceMeters.round()} m';
    }
    final km = (distanceMeters / 1000).toStringAsFixed(1).replaceAll('.', ',');
    return '$km km';
  }

  @override
  List<Object?> get props => [stop, distanceMeters];
}
