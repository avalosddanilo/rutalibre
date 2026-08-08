import 'package:flutter/material.dart';

/// La marca de Ruta Libre, en código.
///
/// Está acá y no como un PNG suelto por dos razones: el ícono de la app se
/// GENERA desde este painter (ver `test/brand/brand_assets_test.dart`), así
/// que marca e ícono no pueden divergir; y la misma marca se dibuja dentro
/// de la app, donde un PNG se vería borroso o pesaría de más.
abstract final class Brand {
  /// El negro de la marca. Un poco más claro que el negro puro: sobre un
  /// panel oscuro el negro absoluto se ve como un agujero.
  static const black = Color(0xFF161616);

  /// El acento. Es el mismo azul que siembra el tema de la app
  /// (`AppTheme.light`), así que el ícono y la interfaz hablan del mismo
  /// color.
  static const accent = Color(0xFF1E88E5);
}

/// El dibujo de la marca: un colectivo de frente.
///
/// La versión anterior era el VIAJE —origen, recorrido y pin de destino—, que
/// decía mejor qué hace la app pero se leía como "otra app de mapas" en una
/// grilla de launcher. El colectivo se reconoce antes de leer el nombre, que
/// es lo único que importa cuando nadie te conoce todavía.
///
/// Se dibuja sobre un lienzo cuadrado y sin fondo: quien lo use decide el
/// fondo (negro en el ícono, transparente en la barra).
class BrandMark extends StatelessWidget {
  const BrandMark({
    this.size = 32,
    this.bodyColor = Colors.white,
    this.accentColor = Brand.accent,
    super.key,
  });

  final double size;

  /// La carrocería. Blanca sobre el negro de marca.
  final Color bodyColor;

  /// Los faros.
  final Color accentColor;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(
      painter: BrandMarkPainter(bodyColor: bodyColor, accentColor: accentColor),
    ),
  );
}

/// Pinta [BrandMark]. Público porque el generador de assets lo usa directo,
/// sin árbol de widgets.
class BrandMarkPainter extends CustomPainter {
  const BrandMarkPainter({
    this.bodyColor = Colors.white,
    this.accentColor = Brand.accent,
  });

  final Color bodyColor;
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    // Todo se define en un lienzo de 100x100 y se escala. Los números salen
    // de probar el dibujo a 32 px, que es donde un ícono se rompe.
    //
    // El dibujo llega a los bordes de ARRIBA y ABAJO a propósito: así `size`
    // significa la altura del colectivo y no "el lado de una caja con aire
    // adentro", que es lo que hace que los generadores de íconos calculen mal
    // cuánto ocupa la marca. A los costados sí sobra, porque un colectivo de
    // frente es más alto que ancho.
    final u = size.width / 100;
    Rect rect(double l, double t, double r, double b) =>
        Rect.fromLTRB(l * u, t * u, r * u, b * u);
    Radius radius(double r) => Radius.circular(r * u);

    // El cartel de destino y el parabrisas son AGUJEROS (`evenOdd`), no
    // manchas de otro color. La razón es la capa monocroma de Android 13+:
    // ahí el launcher pinta todo de un solo color y conserva únicamente el
    // alfa, así que cualquier detalle hecho con color desaparece y el
    // colectivo quedaría como un bloque liso. Hechos como agujeros, se leen
    // igual en las tres versiones del ícono.
    final body = Path()
      ..fillType = PathFillType.evenOdd
      ..addRRect(
        RRect.fromRectAndCorners(
          rect(13.5, 0, 86.5, 90),
          topLeft: radius(21),
          topRight: radius(21),
          bottomLeft: radius(10),
          bottomRight: radius(10),
        ),
      )
      ..addRRect(RRect.fromRectAndRadius(rect(27, 10, 73, 21), radius(4.5)))
      ..addRRect(RRect.fromRectAndRadius(rect(23, 29, 77, 61), radius(8.5)));

    final paint = Paint()..color = bodyColor;
    canvas.drawPath(body, paint);

    // Las ruedas van en un trazo APARTE y no sumadas al path de arriba: como
    // ese path es `evenOdd`, la parte donde la rueda pisa la carrocería se
    // cancelaría y quedaría un mordisco blanco. Dibujadas después y del mismo
    // color, se funden.
    canvas.drawPath(
      Path()
        ..addRRect(RRect.fromRectAndRadius(rect(19.5, 85, 39, 100), radius(5)))
        ..addRRect(RRect.fromRectAndRadius(rect(61, 85, 80.5, 100), radius(5))),
      paint,
    );

    // Los faros son lo único de color. Que se pierdan en la capa monocroma
    // no importa: el colectivo ya se lee sin ellos.
    final lights = Paint()..color = accentColor;
    canvas.drawCircle(Offset(25.5 * u, 73 * u), 6.7 * u, lights);
    canvas.drawCircle(Offset(74.5 * u, 73 * u), 6.7 * u, lights);
  }

  @override
  bool shouldRepaint(BrandMarkPainter oldDelegate) =>
      oldDelegate.bodyColor != bodyColor ||
      oldDelegate.accentColor != accentColor;
}
