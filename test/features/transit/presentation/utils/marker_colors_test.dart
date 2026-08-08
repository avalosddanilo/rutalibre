import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rutalibre/features/transit/presentation/utils/marker_colors.dart';

import '../../../../../tools/src/line_palette.dart';

/// `#RRGGBB` como lo escribe la paleta del importer.
String _hex(Color color) {
  String channel(double value) =>
      (value * 255).round().toRadixString(16).padLeft(2, '0').toUpperCase();
  return '#${channel(color.r)}${channel(color.g)}${channel(color.b)}';
}

void main() {
  // El único test que cruza `lib/` con `tools/`, y por una razón concreta:
  // el invariante vive justo en el medio de los dos.
  group('los marcadores no pueden usar un color de línea', () {
    final palette = linePalette.map((hex) => hex.toUpperCase()).toSet();

    test('el de "cerca mío"', () {
      // Si esto falla, una línea va a caer tarde o temprano en ese color por
      // el hash de `colorForLine` y sus paradas se van a ver iguales a las
      // de "cerca mío". Ya pasó una vez con #00695C.
      expect(palette, isNot(contains(_hex(nearbyMarkerColor))));
    });

    test('el de la capa de todas las paradas', () {
      // Esta es la más expuesta de todas: está dibujada SIEMPRE y debajo del
      // recorrido elegido, así que compartir color con una línea haría que
      // las paradas de fondo se leyeran como paradas de esa línea.
      expect(palette, isNot(contains(_hex(allStopsMarkerColor))));
    });

    test('el de "acá estás vos"', () {
      expect(palette, isNot(contains(_hex(userMarkerColor))));
    });

    test('el del destino', () {
      expect(palette, isNot(contains(_hex(destinationMarkerColor))));
    });
  });

  test('el hex se arma bien (si no, el test de arriba pasaría siempre)', () {
    expect(_hex(const Color(0xFF00695C)), '#00695C');
    expect(_hex(const Color(0xFF212121)), '#212121');
  });
}
