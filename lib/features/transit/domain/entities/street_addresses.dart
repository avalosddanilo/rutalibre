import 'package:equatable/equatable.dart';

/// Un número de puerta mapeado: el 5240 de alguna calle, con su coordenada.
class AddressPoint extends Equatable {
  const AddressPoint({
    required this.number,
    required this.lat,
    required this.lng,
  });

  final int number;
  final double lat;
  final double lng;

  @override
  List<Object?> get props => [number, lat, lng];
}

/// Los números de puerta mapeados de UNA calle en UNA localidad.
///
/// **Existe porque "San Juan 5240" es como la gente dice su casa** — y el
/// área tiene ~58.000 direcciones con número en OpenStreetMap (importes
/// catastrales), así que la app puede caer en la cuadra real sin inventar.
/// La localidad separa homónimas: el 5240 de la San Juan de Barranqueras no
/// tiene nada que ver con la San Juan del centro.
///
/// Sin `id`, como [Place]: es una lista de puntos con nombre que sale de un
/// asset, no se guarda ni se referencia desde ningún lado.
class StreetAddresses extends Equatable {
  const StreetAddresses({
    required this.street,
    required this.locality,
    required this.numbers,
  });

  final String street;

  /// Vacía si el importador no pudo asignar una (sin nodos de localidad).
  final String locality;

  /// Ordenados por número, de menor a mayor — la búsqueda del más cercano
  /// cuenta con eso.
  final List<AddressPoint> numbers;

  @override
  List<Object?> get props => [street, locality, numbers];
}
