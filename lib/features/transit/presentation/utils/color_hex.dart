import 'dart:math' as math;
import 'dart:ui';

/// "#RRGGBB" → [Color] opaco.
///
/// Null-safe a propósito: los `color_hex` vienen de la base y no son de
/// fiar (nulo, vacío, malformado). Ante cualquier duda devuelve null y el
/// caller decide el fallback (típicamente `colorScheme.primary`).
Color? colorFromHex(String? hex) {
  if (hex == null) return null;
  final value = int.tryParse(hex.replaceFirst('#', ''), radix: 16);
  return value == null ? null : Color(0xFF000000 | value);
}

/// Blanco o negro, el que MÁS contraste tenga sobre [background].
///
/// El número de línea va sobre el color de la línea, y ese color sale de una
/// paleta con tonos claros (el ámbar y el oliva): el blanco fijo daba 2.2:1
/// ahí, muy por debajo del 4.5:1 que pide WCAG AA para texto chico. Elegir
/// según luminancia hace que el badge se lea siempre.
Color onColorFor(Color background) =>
    _contrastRatio(background, const Color(0xFFFFFFFF)) >=
        _contrastRatio(background, const Color(0xFF000000))
    ? const Color(0xFFFFFFFF)
    : const Color(0xFF000000);

/// Razón de contraste WCAG 2.1 entre dos colores opacos (1:1 a 21:1).
double _contrastRatio(Color a, Color b) {
  final la = _relativeLuminance(a);
  final lb = _relativeLuminance(b);
  final lighter = la > lb ? la : lb;
  final darker = la > lb ? lb : la;
  return (lighter + 0.05) / (darker + 0.05);
}

double _relativeLuminance(Color color) =>
    0.2126 * _linearize(color.r) +
    0.7152 * _linearize(color.g) +
    0.0722 * _linearize(color.b);

/// Deshace la corrección gamma de sRGB. [channel] viene en 0..1.
double _linearize(double channel) => channel <= 0.03928
    ? channel / 12.92
    : math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
