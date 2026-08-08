/// Las piezas que flotan SOBRE el mapa.
///
/// Vive en `app/` y no adentro de un feature porque el mapa de transit y el
/// aviso de lluvia de weather tienen que verse de la misma familia: dos
/// tarjetas con radios y sombras distintas encima del mismo mapa se leen como
/// dos apps pegadas.
library;

import 'package:flutter/material.dart';

/// Una tarjeta flotante sobre el mapa.
///
/// Dos decisiones que estaban sueltas por las pantallas y acá quedan una sola:
///
/// * **El fondo es OPACO.** Antes cada panel se dibujaba con `alpha 0.92` y
///   se le transparentaban las calles por detrás: sobre un mapa cargado el
///   texto peleaba con lo que había abajo y se leía peor justo donde hay más
///   información. Un panel flotante tapa; para eso flota.
/// * **La sombra es difusa y baja**, no un borde oscuro pegado. La sombra
///   corta (`blurRadius: 6`) que había se ve como una línea sucia; una
///   sombra ancha y tenue es lo que hace leer "esto está por encima".
class FloatingPanel extends StatelessWidget {
  const FloatingPanel({
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    this.color,
    this.radius = 16,
    this.onTap,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  /// Por defecto, la superficie del tema.
  final Color? color;
  final double radius;

  /// Si se pasa, el panel entero es tocable y muestra el ripple recortado a
  /// sus esquinas.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
    );

    return Material(
      color: color ?? scheme.surface,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      // La sombra la pone el Material, no un BoxShadow a mano: así respeta
      // el `shadowColor` del tema y se atenúa sola en modo oscuro, donde una
      // sombra negra sobre fondo negro es solo una mancha.
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.35),
      child: InkWell(
        onTap: onTap,
        // `null` deja el InkWell inerte pero sigue sirviendo de contenedor:
        // no hace falta un árbol distinto según si el panel es tocable.
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
