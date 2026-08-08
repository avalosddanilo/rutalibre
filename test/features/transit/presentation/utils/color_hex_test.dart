import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:rutalibre/features/transit/presentation/utils/color_hex.dart';

void main() {
  group('colorFromHex', () {
    test('"#RRGGBB" → Color opaco', () {
      expect(colorFromHex('#1E88E5'), const Color(0xFF1E88E5));
    });

    test('acepta el hex sin "#"', () {
      expect(colorFromHex('1E88E5'), const Color(0xFF1E88E5));
    });

    test('null → null (el caller decide el fallback)', () {
      expect(colorFromHex(null), isNull);
    });

    test('basura → null, nunca explota', () {
      expect(colorFromHex('no-soy-un-color'), isNull);
      expect(colorFromHex(''), isNull);
      expect(colorFromHex('#GGGGGG'), isNull);
    });
  });

  group('onColorFor', () {
    const blanco = Color(0xFFFFFFFF);
    const negro = Color(0xFF000000);

    test('sobre los tonos oscuros de la paleta usa blanco', () {
      for (final hex in ['#D32F2F', '#1976D2', '#512DA8', '#5D4037']) {
        expect(onColorFor(colorFromHex(hex)!), blanco, reason: hex);
      }
    });

    test('sobre los tonos CLAROS usa negro (el bug del badge ilegible)', () {
      // Con blanco fijo estos daban ~2.2:1, muy debajo del 4.5:1 de WCAG AA.
      for (final hex in ['#F9A825', '#AFB42B']) {
        expect(onColorFor(colorFromHex(hex)!), negro, reason: hex);
      }
    });

    test('los extremos son obvios', () {
      expect(onColorFor(negro), blanco);
      expect(onColorFor(blanco), negro);
    });

    test('toda la paleta del importer queda sobre 4.5:1', () {
      // Es la garantía que importa: sea cual sea el color de la línea, el
      // número se lee.
      const paleta = [
        '#D32F2F',
        '#1976D2',
        '#388E3C',
        '#F57C00',
        '#7B1FA2',
        '#00838F',
        '#C2185B',
        '#5D4037',
        '#455A64',
        '#AFB42B',
        '#0288D1',
        '#E64A19',
        '#512DA8',
        '#00695C',
        '#AD1457',
        '#F9A825',
      ];
      for (final hex in paleta) {
        final fondo = colorFromHex(hex)!;
        final texto = onColorFor(fondo);
        expect(
          _contraste(fondo, texto),
          greaterThanOrEqualTo(4.5),
          reason: '$hex quedó por debajo de WCAG AA',
        );
      }
    });
  });
}

/// Razón de contraste WCAG, reimplementada acá a propósito: si el test usara
/// la misma función que el código, un error en la fórmula pasaría inadvertido.
double _contraste(Color a, Color b) {
  double lum(Color c) {
    double canal(double v) => v <= 0.03928
        ? v / 12.92
        : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
    return 0.2126 * canal(c.r) + 0.7152 * canal(c.g) + 0.0722 * canal(c.b);
  }

  final la = lum(a);
  final lb = lum(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}
