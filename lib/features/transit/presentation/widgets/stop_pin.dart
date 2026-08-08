import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Pin de parada: la gota clásica de los mapas, con la PUNTA apoyada en el
/// punto exacto de la parada.
///
/// Reemplaza al círculo que se usaba antes. El círculo tenía dos problemas:
/// se confundía con los puntos de interés que ya dibujan los tiles de OSM, y
/// al estar centrado en la coordenada tapaba justo la esquina que uno quiere
/// ver. El pin señala sin tapar.
///
/// Quien lo use en un `Marker` de flutter_map DEBE poner
/// `alignment: Alignment.topCenter` para que la punta caiga sobre `point`
/// (esa alineación deja el widget entero por ARRIBA de la coordenada).
class StopPin extends StatelessWidget {
  const StopPin({
    required this.color,
    this.width = defaultWidth,
    this.glyph,
    super.key,
  });

  /// Ancho de la cabeza del pin. El alto sale de [heightFor].
  static const double defaultWidth = 22;

  /// Alto total para un ancho dado. La proporción 1:1.45 es la que hace que
  /// la cola se vea como una punta y no como un triángulo aparte.
  static double heightFor(double width) => width * 1.45;

  final Color color;
  final double width;

  /// Contenido de la cabeza. Por defecto, un punto blanco.
  final Widget? glyph;

  @override
  Widget build(BuildContext context) {
    final height = heightFor(width);
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _PinPainter(color: color)),
          ),
          // La cabeza es el cuadrado de arriba: ahí va el contenido.
          Positioned(
            left: 0,
            top: 0,
            width: width,
            height: width,
            child: Center(
              child:
                  glyph ??
                  SizedBox(
                    width: width * 0.36,
                    height: width * 0.36,
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Punto de parada: la versión liviana del pin.
///
/// El pin GRITA — está bien para una parada, mal para doce. Cuando hay que
/// mostrar varias a la vez ("cerca mío"), una sola es la protagonista y va
/// como [StopPin]; las demás son alternativas y van como punto: se ven, se
/// tocan, pero no compiten.
///
/// A diferencia del pin, el punto va CENTRADO en la coordenada
/// (`Alignment.center`, el default del `Marker`).
class StopDot extends StatelessWidget {
  const StopDot({required this.color, this.size = defaultSize, super.key});

  static const double defaultSize = 14;

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        // Aro blanco por lo mismo que el borde del pin: sobre un tile con
        // parques y avenidas de colores, sin aro se pierde.
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: const [BoxShadow(blurRadius: 3, color: Colors.black26)],
      ),
    ),
  );
}

class _PinPainter extends CustomPainter {
  const _PinPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _pinPath(size);

    // Sombra propia y no un BoxShadow: la silueta del pin no es un rectángulo
    // y una sombra rectangular se nota. Sobre los tiles claros de OSM es lo
    // que despega el pin del fondo.
    canvas.drawShadow(path, Colors.black.withValues(alpha: 0.5), 2, false);
    canvas.drawPath(path, Paint()..color = color);
    // Borde blanco: sobre un tile con muchas manchas de color (parques,
    // avenidas) el pin sin contorno se pierde.
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white,
    );
  }

  /// Gota: círculo arriba, punta abajo, unidos por las dos TANGENTES al
  /// círculo desde la punta (si no fueran tangentes se ve el quiebre).
  static Path _pinPath(Size size) {
    final radius = size.width / 2;
    final center = Offset(radius, radius);
    final tip = Offset(radius, size.height);

    final distance = tip.dy - center.dy;
    // Ángulo entre "derecho para abajo" y el punto de tangencia.
    final alpha = math.acos((radius / distance).clamp(-1.0, 1.0));
    // Ángulos de los dos puntos de tangencia (0 = 3 en punto, crece en
    // sentido horario porque el eje Y del canvas apunta hacia abajo).
    final left = math.atan2(math.cos(alpha), -math.sin(alpha));
    final right = math.atan2(math.cos(alpha), math.sin(alpha));

    return Path()
      // Del tangente derecho al izquierdo pasando por ARRIBA (barrido
      // negativo = antihorario en pantalla).
      ..addArc(
        Rect.fromCircle(center: center, radius: radius),
        right,
        (left - 2 * math.pi) - right,
      )
      ..lineTo(tip.dx, tip.dy)
      ..close();
  }

  @override
  bool shouldRepaint(_PinPainter oldDelegate) => oldDelegate.color != color;
}
