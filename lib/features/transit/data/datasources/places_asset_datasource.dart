import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/place.dart';

/// De dónde salen los lugares.
///
/// **No hay red ni base de por medio**: los lugares se empaquetan con la app
/// en `assets/places.json`. Por qué, en `tools/places_import.dart`; en dos
/// líneas: son 200 KB que andan desde la instalación y sin señal, y meterlos
/// en la cache los haría cargar en cada arranque antes del primer cuadro.
abstract interface class PlacesDataSource {
  /// Lanza [ParsingException] si el asset no está o vino roto — que solo
  /// puede pasar por un error de build, no por algo del usuario.
  Future<List<Place>> getPlaces();
}

final class AssetPlacesDataSource implements PlacesDataSource {
  const AssetPlacesDataSource([this._bundle]);

  /// Inyectable para los tests, que no tienen `rootBundle`.
  final AssetBundle? _bundle;

  static const assetPath = 'assets/places.json';

  @override
  Future<List<Place>> getPlaces() async {
    final String raw;
    try {
      raw = await (_bundle ?? rootBundle).loadString(assetPath);
    } catch (e) {
      throw ParsingException('No se pudo leer $assetPath: $e');
    }

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final rows = json['p'] as List<dynamic>;
      return [
        for (final row in rows)
          // Claves de una letra porque el archivo se lee entero en memoria:
          // n=nombre, y=lat, x=lng, k=categoría. Con `case` y no con `[]`
          // para que una fila rota se saltee en vez de tirar todo el asset.
          if (row case {
            'n': final String name,
            'y': final num lat,
            'x': final num lng,
            'k': final String kind,
          })
            Place(
              name: name,
              lat: lat.toDouble(),
              lng: lng.toDouble(),
              kind: PlaceKind.parse(kind),
            ),
      ];
    } catch (e) {
      throw ParsingException('$assetPath con formato inesperado: $e');
    }
  }
}
