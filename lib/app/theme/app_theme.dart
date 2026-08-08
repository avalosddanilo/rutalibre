import 'package:flutter/material.dart';

import 'brand.dart';

/// El tema de la app.
///
/// Antes eran cuatro líneas (`colorSchemeSeed` y nada más) y el resultado era
/// que cada pantalla resolvía por su cuenta cuánto redondear, cuánta sombra y
/// cuánto aire poner. Eso es lo que hace que una app se vea "de Material" en
/// vez de verse de alguien: los defaults son razonables, pero no son una
/// decisión.
///
/// Las de acá abajo sí lo son, y todas apuntan al mismo lado — una app que se
/// usa parada en la vereda, con una mano, mirando de reojo:
///
/// * **Radios grandes y consistentes** ([radius]). Nada de 6 en un lado, 10
///   en otro y 12 en el tercero.
/// * **Blancos tocables grandes**: los botones y los ítems de lista tienen
///   más alto del default. El pulgar no apunta fino arriba del colectivo.
/// * **Sombras difusas** en vez de bordes: sobre un mapa, un borde compite
///   con las calles y una sombra no.
/// * **Tipografía un poco más apretada** en los títulos. El default de
///   Material tiene el tracking pensado para pantallas grandes.
abstract final class AppTheme {
  /// El radio de la casa. Grande: en una app de mapa casi todo es una
  /// tarjeta flotando, y una tarjeta con esquinas duras se ve pegoteada al
  /// mapa en vez de por encima.
  ///
  /// Público, como [pillRadius]: hay superficies dibujadas a mano —fuera de
  /// un widget de Material— que tienen que redondear igual.
  static const radius = 16.0;

  /// Para lo que es un "chip" o una píldora: redondeo total, así se lee como
  /// otra categoría de objeto y no como una tarjeta chiquita.
  ///
  /// Público porque hay chips que no salen de un widget de Material y tienen
  /// que redondear igual — la grilla de horarios, por ejemplo, son
  /// `Container`s dibujados a mano.
  static const pillRadius = 999.0;

  static final light = _build(Brightness.light);
  static final dark = _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: Brand.accent,
      brightness: brightness,
    );
    // Inter, empaquetada (ver pubspec). Elegida por los NÚMEROS, que es casi
    // todo lo que esta app muestra: número de línea, hora de salida, precio,
    // distancia. Roboto —el default de Android— confunde el 1 con la I
    // mayúscula y el 0 con la O a tamaño chico y de reojo, que es exactamente
    // cómo se lee esto: parado en la vereda, sin anteojos, con el colectivo
    // llegando.
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'Inter',
    );
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
    );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),

      // Los paneles de abajo son el esqueleto de la app: el buscador de
      // destino, las líneas, las paradas cercanas. Van sin franja de arrastre
      // propia —cada hoja dibuja la suya, más gorda— y redondeados solo
      // arriba, que es lo que hace leer "esto sube desde el borde".
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: false,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      cardTheme: CardThemeData(
        shape: shape,
        elevation: 0,
        // Sin tinte de superficie: sobre el mapa, el tinte de Material 3 le
        // mete un lavado azulado a las tarjetas que las despega de la marca.
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
      ),

      // El campo de búsqueda es LA puerta de entrada de la app, así que se
      // ve como un botón lleno y no como un formulario: sin borde, con fondo
      // propio y bien alto.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 3,
        focusElevation: 3,
        hoverElevation: 4,
        highlightElevation: 6,
        // Cuadrado redondeado y no círculo: los botones del mapa forman una
        // columna, y en columna los círculos dejan huecos raros entre uno y
        // otro mientras que los redondeados se leen como una botonera.
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        smallSizeConstraints: const BoxConstraints.tightFor(
          width: 46,
          height: 46,
        ),
        extendedTextStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 52),
          shape: shape,
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 52),
          shape: shape,
        ),
      ),

      chipTheme: base.chipTheme.copyWith(
        shape: const StadiumBorder(),
        side: BorderSide.none,
        backgroundColor: scheme.surfaceContainerHighest,
        selectedColor: scheme.secondaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        // Un poco más de aire vertical que el default: la lista de líneas se
        // toca en movimiento.
        minVerticalPadding: 10,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      dividerTheme: DividerThemeData(
        space: 1,
        thickness: 1,
        color: scheme.outlineVariant.withValues(alpha: 0.5),
      ),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: scheme.inverseSurface,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: TextStyle(color: scheme.onInverseSurface, fontSize: 12),
      ),

      // La misma curva y el mismo tiempo que el resto (ver `motion.dart`):
      // las transiciones de pantalla son lo primero que delata dos manos
      // distintas.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
