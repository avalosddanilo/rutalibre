import 'package:flutter/material.dart';
import 'package:screen_brightness/screen_brightness.dart';

import '../utils/color_hex.dart';

/// El brillo de la pantalla, con nombre de lo que hace acá.
///
/// Es una interfaz y no llamadas directas al plugin por dos razones: los
/// tests verifican que el cartel sube y RESTAURA el brillo sin necesitar la
/// plataforma, y el plugin puede no estar (test, plataforma sin soporte) sin
/// que eso rompa el cartel — que sigue sirviendo al brillo que esté.
abstract interface class HailBrightness {
  /// Al máximo, mientras el cartel esté a la vista.
  Future<void> boost();

  /// De vuelta al brillo que manejaba el sistema antes del cartel.
  Future<void> restore();
}

/// La implementación real, sobre `screen_brightness`.
///
/// Usa el brillo DE LA APLICACIÓN, no el del sistema: al salir de la app —o
/// al restaurar— el teléfono vuelve solo a lo que el usuario tenía, sin que
/// toquemos su configuración. Todo va en try/catch porque un cartel que no
/// pudo subir el brillo sigue siendo un cartel; un cartel que crashea no.
final class ScreenHailBrightness implements HailBrightness {
  const ScreenHailBrightness();

  @override
  Future<void> boost() async {
    try {
      await ScreenBrightness.instance.setApplicationScreenBrightness(1);
    } on Object {
      // Sin plugin o sin permiso: el cartel sirve igual.
    }
  }

  @override
  Future<void> restore() async {
    try {
      await ScreenBrightness.instance.resetApplicationScreenBrightness();
    } on Object {
      // Nada que restaurar si nunca se pudo subir.
    }
  }
}

/// El cartel para el chofer: la pantalla entera con el número de la línea.
///
/// **Esto resuelve un problema físico, no digital.** De noche, en una parada
/// mal iluminada, el colectivo no para si nadie le hace señas — y una mano
/// levantada no dice A CUÁL de los tres que vienen le estás haciendo señas.
/// La pantalla del teléfono es la superficie más brillante que hay en la
/// vereda: con el número gigante en el color de la línea, el chofer sabe
/// desde lejos si le hablás a él. Y mientras está abierto, **el brillo sube
/// al máximo solo** — un cartel al 30% de brillo no es un cartel — y al
/// cerrarlo vuelve al que había.
///
/// Se cierra tocando en cualquier lado. No rota ni anima nada: es un cartel.
class HailScreen extends StatefulWidget {
  const HailScreen({
    required this.code,
    this.colorHex,
    this.brightness = const ScreenHailBrightness(),
    super.key,
  });

  final String code;
  final String? colorHex;

  /// Inyectable para los tests; en la app es siempre el plugin real.
  final HailBrightness brightness;

  /// True mientras hay un cartel abierto: dos toques rápidos al botón abrían
  /// DOS diálogos apilados, y al cerrar el primero su dispose restauraba el
  /// brillo con el segundo todavía en pantalla — un cartel a media luz.
  static bool _showing = false;

  static Future<void> show(
    BuildContext context, {
    required String code,
    String? colorHex,
  }) async {
    if (_showing) return;
    _showing = true;
    try {
      await showDialog<void>(
        context: context,
        // Sin barrera gris ni margen: el cartel ES la pantalla.
        useSafeArea: false,
        builder: (context) => HailScreen(code: code, colorHex: colorHex),
      );
    } finally {
      _showing = false;
    }
  }

  @override
  State<HailScreen> createState() => _HailScreenState();
}

class _HailScreenState extends State<HailScreen> {
  @override
  void initState() {
    super.initState();
    widget.brightness.boost();
  }

  @override
  void dispose() {
    // En dispose y no en el onTap de cerrar: el cartel también se cierra con
    // el botón de atrás del sistema, y ese camino no pasa por ningún onTap.
    widget.brightness.restore();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color =
        colorFromHex(widget.colorHex) ?? Theme.of(context).colorScheme.primary;
    final onColor = onColorFor(color);

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Material(
        color: color,
        child: SafeArea(
          child: Semantics(
            label:
                'Cartel con el número de la línea ${widget.code}. Tocá para volver.',
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
                          widget.code,
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
