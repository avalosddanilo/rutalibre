import 'package:flutter/material.dart';

import '../utils/color_hex.dart';

/// El cartel para el chofer: la pantalla entera con el número de la línea.
///
/// **Esto resuelve un problema físico, no digital.** De noche, en una parada
/// mal iluminada, el colectivo no para si nadie le hace señas — y una mano
/// levantada no dice A CUÁL de los tres que vienen le estás haciendo señas.
/// La pantalla del teléfono es la superficie más brillante que hay en la
/// vereda: con el número gigante en el color de la línea, el chofer sabe
/// desde lejos si le hablás a él.
///
/// Se cierra tocando en cualquier lado. No rota ni anima nada: es un cartel.
class HailScreen extends StatelessWidget {
  const HailScreen({required this.code, this.colorHex, super.key});

  final String code;
  final String? colorHex;

  static Future<void> show(
    BuildContext context, {
    required String code,
    String? colorHex,
  }) => showDialog<void>(
    context: context,
    // Sin barrera gris ni margen: el cartel ES la pantalla.
    useSafeArea: false,
    builder: (context) => HailScreen(code: code, colorHex: colorHex),
  );

  @override
  Widget build(BuildContext context) {
    final color =
        colorFromHex(colorHex) ?? Theme.of(context).colorScheme.primary;
    final onColor = onColorFor(color);

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Material(
        color: color,
        child: SafeArea(
          child: Semantics(
            label: 'Cartel con el número de la línea $code. Tocá para volver.',
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    // FittedBox: "904A" y "3" ocupan igual la pantalla, y con
                    // el texto del sistema agrandado no desborda — se achica.
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: FittedBox(
                        child: Text(
                          code,
                          style: TextStyle(
                            color: onColor,
                            fontSize: 280,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -8,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Text(
                    'Tocá para volver',
                    style: TextStyle(
                      color: onColor.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
