import 'package:equatable/equatable.dart';

/// Qué clase de lugar es.
///
/// Corto a propósito: no es la taxonomía de OpenStreetMap, es cómo lo nombra
/// la gente cuando dice a dónde va. Nadie dice "voy al `amenity=doctors`".
enum PlaceKind {
  salud,
  educacion,
  compras,
  transporte,
  gobierno,
  plaza,
  deporte,
  cultura,
  iglesia,
  otro;

  static PlaceKind parse(String raw) => PlaceKind.values.firstWhere(
    (kind) => kind.name == raw,
    // Una categoría nueva en el asset no puede romperle el buscador a nadie:
    // aparece como "otro" hasta que la app se actualice.
    orElse: () => PlaceKind.otro,
  );
}

/// Un lugar al que alguien puede querer ir: el hospital, la escuela, la plaza.
///
/// **Existe porque la gente no piensa en esquinas.** El buscador de destino
/// solo conocía paradas, así que había que saber que el Perrando queda en
/// "Avenida 9 de Julio y Juan B. Justo" para poder ir. Nadie lo sabe: uno
/// sabe que va al Perrando.
///
/// No tiene `id`: no se guarda en ninguna base, no se referencia desde ningún
/// lado y no se edita. Es una lista de puntos con nombre.
class Place extends Equatable {
  const Place({
    required this.name,
    required this.lat,
    required this.lng,
    required this.kind,
  });

  final String name;
  final double lat;
  final double lng;
  final PlaceKind kind;

  @override
  List<Object?> get props => [name, lat, lng, kind];
}
