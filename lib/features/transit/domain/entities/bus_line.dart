import 'package:equatable/equatable.dart';

import 'transit_network.dart';

/// La línea comercial que el usuario reconoce ("Línea 3", "Línea 110").
///
/// No contiene geometría: una línea tiene N recorridos ([RouteVariant]).
/// Espeja la tabla `lines` de Supabase (sin los campos de auditoría,
/// que son un detalle de infraestructura y no interesan al dominio).
///
/// Los RAMALES tampoco viven acá: "3A" no es una línea, es el ramal A de la
/// línea 3. El pasajero piensa en "la 3"; ramal y sentido son atributos del
/// recorrido ([RouteVariant]).
class BusLine extends Equatable {
  const BusLine({
    required this.id,
    required this.code,
    required this.name,
    required this.colorHex,
    required this.network,
    this.sortOrder = 0,
    this.destinations = const [],
  });

  final String id;

  /// Código corto visible en el cartel del colectivo: "3", "110".
  /// Único DENTRO de la red, no globalmente.
  final String code;

  /// Recorrido resumido: "Vial ↔ Los Troncos / Monte Alto".
  final String name;

  /// Color del trazado en el mapa, formato `#RRGGBB` (ej: "#1E88E5").
  /// La conversión a `Color` de Flutter es responsabilidad de presentation.
  final String colorHex;

  /// Red a la que pertenece (Gran Resistencia, interurbano, Corrientes).
  final TransitNetwork network;

  /// Orden natural resuelto en la base: "3" antes que "110" sin que cada
  /// cliente reimplemente la comparación de códigos.
  final int sortOrder;

  /// Todas las cabeceras y destinos, la primera es el tronco.
  ///
  /// [name] es un RESUMEN de esto que entra en un renglón: a partir del
  /// tercer destino dice "y N más". Buscar sobre el nombre solo, entonces,
  /// no encontraba la línea 3 tecleando "Sarmiento" —aunque su ramal A
  /// termina en el Shopping Sarmiento—, y una línea que no se encuentra es
  /// una línea que no está. Truncar es decisión de la PANTALLA; esta lista
  /// es lo que hay.
  ///
  /// Puede venir vacía: una base donde todavía no se corrió el seed nuevo
  /// no la tiene. La app degrada a buscar por nombre, que es como estaba.
  final List<String> destinations;

  @override
  List<Object?> get props => [
    id,
    code,
    name,
    colorHex,
    network,
    sortOrder,
    destinations,
  ];
}
