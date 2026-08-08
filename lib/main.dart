import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'core/config/env.dart';
import 'core/errors/failures.dart';
import 'core/providers/shared_preferences_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Fallar con instrucciones si faltan las claves: el error clásico es
  // correr `flutter run` pelado y ver pantallas en blanco.
  //
  // Se DIBUJA el error en vez de lanzarlo. Lanzar acá deja la app muerta en
  // gris, sin una línea de explicación en el teléfono: hay que ir a buscar
  // el log. Y si un build de release llegara a salir sin las claves, un
  // cartel es lo único que separa "está rota" de "la desinstalo".
  if (Env.isMissing) {
    runApp(
      const _StartupError(
        'Faltan las claves de Supabase.\n\n'
        'Compilá con:\nflutter run --dart-define-from-file=env.json',
      ),
    );
    return;
  }

  // Las dos inicializaciones no dependen entre sí → en paralelo.
  // La velocidad de arranque es EL requisito del producto.
  final SharedPreferences prefs;
  try {
    (prefs, _) = await (
      SharedPreferences.getInstance(),
      Supabase.initialize(
        url: Env.supabaseUrl,
        publishableKey: Env.supabaseAnonKey,
      ),
    ).wait;
  } catch (error) {
    // Ninguna de las dos toca la red, así que llegar acá significa algo del
    // dispositivo: preferencias corruptas, almacenamiento lleno, una URL mal
    // formada. Sea lo que sea, arrancar igual dejaría todas las pantallas
    // fallando de a una; mejor decirlo una sola vez y de frente.
    runApp(_StartupError('No se pudo iniciar la app.\n\n$error'));
    return;
  }

  runApp(
    ProviderScope(
      overrides: [
        // La única instancia async del grafo se resuelve acá una vez;
        // el resto de los providers son síncronos y puros.
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      // Los Failure son VALORES deterministas del dominio (el repositorio ya
      // decidió qué significan): reintentarlos solo regala ~38 s de spinner
      // antes de mostrar el error (defaultRetry de Riverpod 3 reintenta 10
      // veces todo lo que no sea Error/ProviderException). La UI ya ofrece
      // "Reintentar" explícito donde corresponde.
      retry: (retryCount, error) => error is Failure
          ? null
          : ProviderContainer.defaultRetry(retryCount, error),
      child: const RutaLibreApp(),
    ),
  );
}

/// La pantalla de "esto no arrancó".
///
/// Deliberadamente SIN tema, sin providers y sin nada del resto de la app:
/// se dibuja justamente cuando algo de esa maquinaria no está disponible, y
/// una pantalla de error que depende de lo que falló no se dibuja.
class _StartupError extends StatelessWidget {
  const _StartupError(this.message);

  final String message;

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.ltr,
    child: ColoredBox(
      color: const Color(0xFF161616),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFEFEFEF),
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ),
      ),
    ),
  );
}
