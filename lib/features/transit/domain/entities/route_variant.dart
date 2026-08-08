import 'package:equatable/equatable.dart';

/// Sentido de circulación de un recorrido.
///
/// En la base (`route_variants.direction`) se persiste como smallint:
/// 0 = ida, 1 = vuelta. El mapeo int ↔ enum vive en el modelo de la
/// capa data (`RouteVariantModel`), no acá.
enum RouteDirection {
  /// Ida (0 en la base).
  outbound,

  /// Vuelta (1 en la base).
  inbound;

  bool get isOutbound => this == RouteDirection.outbound;

  /// Etiqueta para la UI. Vive en el dominio porque "ida"/"vuelta" es
  /// vocabulario del negocio, no una decisión de presentación.
  String get label => isOutbound ? 'Ida' : 'Vuelta';
}

/// Un recorrido concreto de una línea: ida, vuelta o ramal.
///
/// La GEOMETRÍA del trazado no forma parte de la entidad a propósito:
/// es un dato pesado y de representación (GeoJSON) que la capa de mapa
/// pide bajo demanda vía el RPC `get_route_geojson(variant_id)`.
/// El dominio solo necesita saber que el recorrido existe y a qué
/// línea pertenece.
class RouteVariant extends Equatable {
  const RouteVariant({
    required this.id,
    required this.lineId,
    required this.name,
    required this.direction,
    required this.isActive,
    this.branch,
  });

  final String id;

  /// FK a la [BusLine] dueña de este recorrido.
  final String lineId;

  /// Descripción del recorrido: "Ida: Centro → Barranqueras".
  final String name;

  /// Ramal dentro de la línea: "A", "B", "C"... o null si la línea no se
  /// abre en ramales. Con el ramal y el sentido queda identificado el
  /// recorrido dentro de su línea.
  final String? branch;

  final RouteDirection direction;

  /// Los recorridos inactivos no se dibujan ni se listan.
  final bool isActive;

  /// Etiqueta corta para chips: "Ramal A · Ida" o "Ida".
  String get shortLabel {
    final sentido = direction == RouteDirection.outbound ? 'Ida' : 'Vuelta';
    return branch == null ? sentido : 'Ramal $branch · $sentido';
  }

  @override
  List<Object?> get props => [id, lineId, name, branch, direction, isActive];
}
