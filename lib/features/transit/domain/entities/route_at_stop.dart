import 'package:equatable/equatable.dart';

import 'route_variant.dart';

/// Un recorrido que pasa por una parada determinada.
///
/// Es un MODELO DE LECTURA: responde "¿qué colectivos me sirven acá?", la
/// pregunta que uno se hace parado en la vereda. Trae aplanados los datos
/// de la línea y del recorrido porque la pantalla los muestra juntos y
/// pedirlos por separado serían dos viajes a la base.
///
/// No se reusa [BusLine] a propósito: esta consulta no trae la red, y una
/// entidad con campos nullables "según de dónde venga" miente sobre lo que
/// garantiza.
class RouteAtStop extends Equatable {
  const RouteAtStop({
    required this.lineId,
    required this.lineCode,
    required this.lineName,
    required this.colorHex,
    required this.routeVariantId,
    required this.variantName,
    required this.branch,
    required this.direction,
  });

  final String lineId;

  /// "3", "110" — lo que dice el cartel del colectivo.
  final String lineCode;
  final String lineName;
  final String colorHex;

  final String routeVariantId;
  final String variantName;

  /// Ramal dentro de la línea ("A", "B") o null si no tiene.
  final String? branch;

  final RouteDirection direction;

  /// "3A" o "3" — como lo nombraría un pasajero.
  String get displayCode => '$lineCode${branch ?? ''}';

  @override
  List<Object?> get props => [
    lineId,
    lineCode,
    lineName,
    colorHex,
    routeVariantId,
    variantName,
    branch,
    direction,
  ];
}
