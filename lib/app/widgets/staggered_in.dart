/// La entrada escalonada de una lista.
library;

import 'package:flutter/material.dart';

import '../theme/motion.dart';

/// Hace que [child] entre desde abajo con un desfase según su [index].
///
/// Para qué: una lista que aparece entera de golpe no le dice a nadie que
/// acaba de cargar; parece que siempre estuvo y que la pantalla se trabó
/// hasta ese momento. Entrando escalonada, el movimiento cuenta el orden —
/// primero lo de arriba, que es lo más cercano o lo más relevante— y de paso
/// tapa el salto del primer dibujado.
///
/// Está hecho a mano y no con un paquete de animaciones a propósito: es un
/// `TweenAnimationBuilder` con un retardo, treinta líneas, y evita meterle al
/// proyecto una dependencia que hay que seguir de por vida para esto.
///
/// Anima UNA sola vez, cuando el widget se monta. No reacciona a cambios de
/// [index]: reordenar una lista ya visible y volver a hacerla entrar sería
/// mareador, no informativo.
class StaggeredIn extends StatefulWidget {
  const StaggeredIn({
    required this.index,
    required this.child,
    this.offset = 12,
    super.key,
  });

  final int index;
  final Widget child;

  /// Cuántos píxeles sube al entrar. Chico a propósito: esto es un acento,
  /// no una coreografía.
  final double offset;

  @override
  State<StaggeredIn> createState() => _StaggeredInState();
}

class _StaggeredInState extends State<StaggeredIn> {
  double _target = 0;

  @override
  void initState() {
    super.initState();
    final delay = Motion.stagger * widget.index.clamp(0, Motion.staggerCap);
    // Un Future en vez de un AnimationController con delay: no hay nada que
    // controlar después, solo hay que empezar más tarde.
    Future<void>.delayed(delay, () {
      if (mounted) setState(() => _target = 1);
    });
  }

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: _target),
    duration: Motion.base,
    curve: Motion.curve,
    builder: (context, value, child) => Opacity(
      opacity: value,
      child: Transform.translate(
        offset: Offset(0, (1 - value) * widget.offset),
        child: child,
      ),
    ),
    child: widget.child,
  );
}
