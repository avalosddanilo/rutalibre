import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// La instancia de `SharedPreferences`, resuelta una sola vez en el arranque.
///
/// **Lanza a propósito.** Se sobreescribe en `main.dart` con
/// `overrideWithValue(prefs)`: la inicialización es async y Riverpod no puede
/// esperarla acá sin volver async medio grafo. Que reviente es mejor que un
/// valor de mentira — el error dice exactamente qué falta.
///
/// Vive en `core/` y no adentro de un feature por la misma razón que
/// [clockProvider]: lo usan transit (la cache de líneas, recorridos y
/// paradas) y weather (la del pronóstico). Tenerlo colgado de transit
/// obligaría a weather a importar del feature hermano, que es justo la
/// dependencia que la arquitectura no quiere.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(
    'sharedPreferencesProvider debe sobreescribirse en ProviderScope '
    'con la instancia real (ver main.dart)',
  ),
);
