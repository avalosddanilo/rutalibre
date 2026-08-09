import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/reference_stop.dart';

/// Las paradas de Corrientes capital, empaquetadas con la app.
///
/// Mismo criterio que los lugares: un asset y no la base. Acá hay una razón
/// extra — la sección 5 del seed del Gran Resistencia desactiva toda parada
/// sin recorrido asociado, y estas no lo tienen por diseño. En `stops` se
/// borrarían solas en el próximo import.
abstract interface class CorrientesStopsDataSource {
  Future<List<ReferenceStop>> getStops();
}

final class AssetCorrientesStopsDataSource
    implements CorrientesStopsDataSource {
  const AssetCorrientesStopsDataSource([this._bundle]);

  final AssetBundle? _bundle;

  static const assetPath = 'assets/corrientes_stops.json';

  @override
  Future<List<ReferenceStop>> getStops() async {
    final String raw;
    try {
      raw = await (_bundle ?? rootBundle).loadString(assetPath);
    } catch (e) {
      throw ParsingException('No se pudo leer $assetPath: $e');
    }

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return [
        for (final row in json['s'] as List<dynamic>)
          // Una fila rota se saltea en vez de tirar el asset entero.
          if (row case {
            'n': final String name,
            'y': final num lat,
            'x': final num lng,
            'l': final List<dynamic> lines,
          })
            ReferenceStop(
              name: name,
              lat: lat.toDouble(),
              lng: lng.toDouble(),
              lines: [for (final line in lines) '$line'],
            ),
      ];
    } catch (e) {
      throw ParsingException('$assetPath con formato inesperado: $e');
    }
  }
}
