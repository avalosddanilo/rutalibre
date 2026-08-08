import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Reloj inyectable: el ÚNICO acceso a "ahora" en la UI.
///
/// Los tests lo fijan con `overrideWithValue(() => fecha)` para ser
/// determinísticos — sin esto, "la próxima salida" o "llueve en 40 min"
/// dependerían de cuándo se corre el test.
///
/// Vive en `core/` y no dentro de un feature porque lo necesita más de uno
/// (transit para la próxima salida, weather para cuánto falta para la
/// lluvia) y dos relojes distintos se desincronizarían en los tests.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);
