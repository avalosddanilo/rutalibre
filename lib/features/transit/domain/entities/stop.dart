import 'package:equatable/equatable.dart';

/// Parada física georreferenciada.
///
/// Independiente de las líneas: una misma parada puede servir a muchos
/// recorridos (la relación N:M vive en `route_stops`, capa data).
///
/// Las coordenadas son `lat`/`lng` planos (WGS84) y NO un tipo del paquete
/// de mapas: así el dominio no depende de flutter_map/latlong2 y se puede
/// migrar a Mapbox sin tocar esta clase. La conversión a `LatLng` es
/// responsabilidad de presentation.
class Stop extends Equatable {
  const Stop({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    this.description,
    this.osmNodeId,
  });

  final String id;

  /// Nombre por intersección: "Av. 25 de Mayo y French".
  final String name;

  /// Referencia opcional para el usuario: "frente a la plaza".
  final String? description;

  /// Latitud en grados decimales, WGS84 (rango válido: -90 a 90).
  final double lat;

  /// Longitud en grados decimales, WGS84 (rango válido: -180 a 180).
  final double lng;

  /// El nodo de OpenStreetMap del que salió esta parada, si se sabe.
  ///
  /// **Para qué sirve tener un id de otra base acá.** Una parada que se
  /// levantó en la realidad pero que OSM todavía mapea es indistinguible de
  /// una vigente: no hay dato nuestro que lo delate. Lo único que lo arregla
  /// es corregir OSM, y con el nodo a mano eso pasa de "encontrala en el
  /// editor" a un toque desde la parada que uno está mirando.
  ///
  /// Nullable porque puede faltar por dos razones distintas y las dos son
  /// normales: la base todavía no corrió la migración 0010, o la parada llegó
  /// por un camino que no lo trae. Sin él la app se comporta como antes.
  final int? osmNodeId;

  @override
  List<Object?> get props => [id, name, description, lat, lng, osmNodeId];
}
