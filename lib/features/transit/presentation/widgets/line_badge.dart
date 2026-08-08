import 'package:flutter/material.dart';

import '../utils/color_hex.dart';

/// El número de la línea como se ve en el cartel del colectivo.
///
/// Es el elemento de identidad más fuerte de la app: el pasajero busca "el
/// 3", no "Vial ↔ Monte Alto". Se repite en la lista, en el mapa y en el
/// detalle de parada, así que vive en un solo lugar.
class LineBadge extends StatelessWidget {
  const LineBadge({
    required this.code,
    required this.colorHex,
    this.selected = false,
    this.size = 40,
    super.key,
  });

  final String code;
  final String? colorHex;
  final bool selected;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color =
        colorFromHex(colorHex) ?? Theme.of(context).colorScheme.primary;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.28),
        border: selected
            ? Border.all(
                color: Theme.of(context).colorScheme.onSurface,
                width: 2.5,
              )
            : null,
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size * 0.12),
          child: Text(
            code,
            style: TextStyle(
              // Blanco o negro según el color de la línea: la paleta tiene
              // tonos claros (ámbar, oliva) donde el blanco fijo quedaba
              // ilegible (2.2:1, contra el 4.5:1 que pide WCAG AA).
              color: onColorFor(color),
              fontWeight: FontWeight.bold,
              fontSize: size * 0.42,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ),
    );
  }
}
