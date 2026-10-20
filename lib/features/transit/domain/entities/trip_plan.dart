import 'package:equatable/equatable.dart';

import 'route_variant.dart';
import 'stop.dart';

/// Un tramo de viaje: subirse a un colectivo y bajarse más adelante.
///
/// Es un MODELO DE LECTURA, como [RouteAtStop]: trae aplanados la línea, el
/// recorrido y las dos paradas porque la pantalla los muestra juntos y
/// pedirlos por separado serían cuatro viajes a la base por tramo.
///
/// Acá SÍ se reusa [Stop] (a diferencia de lo que hace `RouteAtStop` con
/// `BusLine`): el RPC devuelve la parada completa —id, nombre, coordenadas—
/// así que la entidad no queda con campos nullables "según de dónde venga",
/// y el mapa necesita esas coordenadas para dibujar dónde subirse.
class TripLeg extends Equatable {
  const TripLeg({
    required this.lineId,
    required this.lineCode,
    required this.lineName,
    required this.colorHex,
    required this.networkCode,
    required this.networkName,
    required this.routeVariantId,
    required this.variantName,
    required this.branch,
    required this.direction,
    required this.boardStop,
    required this.alightStop,
    required this.stopCount,
  });

  final String lineId;

  /// "3", "110" — lo que dice el cartel del colectivo.
  final String lineCode;
  final String lineName;
  final String colorHex;

  final String networkCode;
  final String networkName;

  final String routeVariantId;
  final String variantName;

  /// Ramal dentro de la línea ("A", "B"), o null.
  ///
  /// Null significa DOS cosas distintas y las dos llevan al mismo texto:
  /// que la línea no tiene ramales, o que varios ramales hacen este mismo
  /// viaje y entonces nombrar uno sería peor que no nombrar ninguno (el
  /// pasajero dejaría pasar el otro). Cuál de las dos es se ve en
  /// [variantName], que sí trae el ramal cuando existe.
  final String? branch;
  final RouteDirection direction;

  /// Dónde subirse.
  final Stop boardStop;

  /// Dónde bajarse.
  final Stop alightStop;

  /// Cuántas paradas se viajan arriba del colectivo.
  ///
  /// Es la diferencia de posición en el recorrido, así que ya cuenta la de
  /// bajada: subirse en la 5 y bajarse en la 6 es 1.
  final int stopCount;

  /// "3A" o "3" — como lo nombraría un pasajero.
  String get displayCode => '$lineCode${branch ?? ''}';

  @override
  List<Object?> get props => [
    lineId,
    lineCode,
    lineName,
    colorHex,
    networkCode,
    networkName,
    routeVariantId,
    variantName,
    branch,
    direction,
    boardStop,
    alightStop,
    stopCount,
  ];
}

/// Una forma de ir de un punto a otro: uno o dos colectivos.
///
/// El planificador NO ofrece viajes de dos transbordos. La cobertura sube
/// poco y la confianza baja mucho: sin horarios, un itinerario de tres
/// colectivos es una promesa que nadie puede verificar.
class TripPlan extends Equatable {
  const TripPlan({
    required this.legs,
    required this.walkToBoardMeters,
    required this.walkFromAlightMeters,
    this.transferWalkMeters = 0,
    this.calculatedOffline = false,
  });

  /// Uno (directo) o dos (con transbordo), en orden de viaje.
  ///
  /// Nunca vacía: un viaje sin tramos no es un viaje, y el RPC no los emite.
  /// No hay `assert` porque Dart no deja mirar `.length` en un constructor
  /// const, y valer como constante importa más acá (la lista se arma una vez
  /// y se compara por valor). Los accesores de abajo son totales igual.
  final List<TripLeg> legs;

  /// Metros a pie desde el origen hasta la primera parada.
  final double walkToBoardMeters;

  /// Metros a pie desde la última parada hasta el destino.
  final double walkFromAlightMeters;

  /// Metros a pie en el transbordo: de donde te bajás del primer colectivo
  /// a donde tomás el segundo. 0 en los directos y en los transbordos en la
  /// misma parada.
  ///
  /// Existe desde `plan_trip_v2` (migración 0015). Antes el transbordo era
  /// siempre en la misma parada, y es lo que sigue pasando cuando este
  /// número es 0: las paradas del 904 y las urbanas de Corrientes, por
  /// ejemplo, están en las mismas esquinas pero son paradas distintas.
  final double transferWalkMeters;

  /// True si el servidor no contestó y el viaje lo calculó el teléfono con
  /// los datos que tenía guardados. Se dice en pantalla: sin conexión
  /// tampoco llegan los avisos de paros y desvíos.
  final bool calculatedOffline;

  bool get isDirect => legs.length <= 1;

  /// Dónde te bajás para hacer el transbordo, o null si el viaje es directo.
  ///
  /// Si [transferIsWalk], el segundo colectivo se toma en OTRA parada
  /// (`legs[1].boardStop`), a [transferWalkMeters] de esta.
  Stop? get transferStop => isDirect ? null : legs.first.alightStop;

  /// True si el transbordo pide caminar hasta otra parada.
  ///
  /// Se decide por las paradas y no por los metros: dos paradas distintas
  /// pegadas (2 m) siguen siendo dos lugares donde esperar, y mandar a
  /// alguien a "la misma parada" sería mandarlo a la equivocada.
  bool get transferIsWalk =>
      !isDirect && legs[1].boardStop.id != legs.first.alightStop.id;

  double get walkTotalMeters =>
      walkToBoardMeters + transferWalkMeters + walkFromAlightMeters;

  /// Paradas arriba de un colectivo, sumando los tramos.
  int get totalStopCount => legs.fold(0, (sum, leg) => sum + leg.stopCount);

  /// "350 m" o "1,2 km" — mismo formato que `NearbyStop.formattedDistance`.
  String get formattedWalk => _formatMeters(walkTotalMeters);

  @override
  List<Object?> get props => [
    legs,
    walkToBoardMeters,
    walkFromAlightMeters,
    transferWalkMeters,
    calculatedOffline,
  ];
}

String _formatMeters(double meters) {
  if (meters < 1000) return '${meters.round()} m';
  final km = (meters / 1000).toStringAsFixed(1).replaceAll('.', ',');
  return '$km km';
}
