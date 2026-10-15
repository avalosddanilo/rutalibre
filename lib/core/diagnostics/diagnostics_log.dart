import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/clock_provider.dart';
import '../providers/shared_preferences_provider.dart';

/// El registro de diagnóstico: qué le pasó a la app, nunca dónde estabas.
///
/// **Para qué.** La alarma "avisame para bajar" depende de un servicio en
/// primer plano, de permisos y de que Android no lo mate con la pantalla
/// apagada. Cuando alguien escribe "no me sonó", Android vitals no dice nada
/// de eso. Esto sí: "servicio rechazado", "permiso de ubicación denegado",
/// "alarma sonó", con la hora.
///
/// **Qué NO guarda, y es la regla de este archivo:** ubicación. La política de
/// privacidad promete que la ubicación no se guarda, y un registro con
/// coordenadas la rompería. Por eso:
/// - Los eventos son textos fijos que escribe el código, no datos del usuario.
/// - Todo detalle (también el mensaje de un error, que puede traer la URL del
///   pronóstico con `latitude=`) pasa por [sanitize], que borra cualquier
///   número con pinta de coordenada antes de guardarlo.
///
/// **Dónde vive:** en el teléfono, en `SharedPreferences`, los últimos
/// [maxEntries] eventos. Sale del teléfono solo si la persona toca "Enviar
/// diagnóstico" y elige con qué app mandarlo.
class DiagnosticsLog {
  DiagnosticsLog(SharedPreferences prefs, {DateTime Function()? now})
    : _prefs = prefs,
      _now = now ?? DateTime.now;

  /// Un registro que no guarda nada: para cuando no hay dónde guardar.
  DiagnosticsLog.disabled() : _prefs = null, _now = DateTime.now;

  final SharedPreferences? _prefs;
  final DateTime Function() _now;

  static const storageKey = 'ruta_libre_diagnostico_v1';

  /// Alcanza para un par de viajes con alarma, y entra entero en un mail.
  static const maxEntries = 200;

  /// Lo guardado, del más viejo al más nuevo.
  List<String> get entries => _prefs?.getStringList(storageKey) ?? const [];

  /// Anota un evento. Nunca falla: un diagnóstico que rompe la app es peor
  /// que no tenerlo.
  void record(String event, [Object? detail]) {
    final prefs = _prefs;
    if (prefs == null) return;
    try {
      final line = [
        _stamp(_now()),
        event,
        if (detail != null) sanitize('$detail'),
      ].join(' ');
      final list = [...entries, line];
      final start = list.length > maxEntries ? list.length - maxEntries : 0;
      prefs.setStringList(storageKey, list.sublist(start));
    } on Object {
      // Sin espacio o preferencias rotas: se pierde el evento, no la app.
    }
  }

  /// Un error: el tipo, el mensaje limpio y las primeras líneas de la pila
  /// (que son nombres de archivos y funciones del código, no datos).
  void recordError(Object error, StackTrace? stack) {
    final frames = (stack?.toString() ?? '')
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .take(4)
        .map((l) => l.trim())
        .join(' | ');
    record(
      'error',
      '${error.runtimeType}: $error${frames.isEmpty ? '' : ' @ $frames'}',
    );
  }

  Future<void> clear() async {
    try {
      await _prefs?.remove(storageKey);
    } on Object {
      // Nada que borrar.
    }
  }

  /// El texto que se manda: un encabezado y los eventos.
  String export({String? version}) {
    final lines = entries;
    return [
      'Diagnóstico de Ruta Libre${version == null ? '' : ' $version'}',
      'Generado: ${_stamp(_now())}',
      'Solo eventos de la app (viaje, alarma, permisos, errores). Sin ubicación.',
      '',
      if (lines.isEmpty) '(sin eventos registrados)' else ...lines,
    ].join('\n');
  }

  /// Borra lo que podría ser una ubicación y acota el largo.
  ///
  /// Cualquier número con tres o más decimales (-27.46321, 58.98540) es
  /// candidato a coordenada y se reemplaza: en este registro no hace falta
  /// ningún número así, y es más seguro tapar de más que de menos.
  static String sanitize(String value) {
    final masked = value
        .replaceAll(RegExp(r'-?\d{1,3}\.\d{3,}'), '[n]')
        .replaceAllMapped(
          RegExp(
            r'(lat(?:itude)?|lng|lon(?:gitude)?)=[^&\s]*',
            caseSensitive: false,
          ),
          (m) => '${m[1]}=[n]',
        )
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return masked.length > 300 ? '${masked.substring(0, 300)}…' : masked;
  }

  static String _stamp(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${t.year}-${two(t.month)}-${two(t.day)} '
        '${two(t.hour)}:${two(t.minute)}:${two(t.second)}';
  }
}

/// El registro de la app.
///
/// Si las preferencias no están (un test que no las preparó, o un arranque
/// que falló antes), devuelve uno que no guarda nada en vez de reventar: el
/// diagnóstico es un accesorio y no puede tirar abajo la alarma ni el GPS.
final diagnosticsLogProvider = Provider<DiagnosticsLog>((ref) {
  try {
    return DiagnosticsLog(
      ref.watch(sharedPreferencesProvider),
      now: ref.watch(clockProvider),
    );
  } on Object {
    return DiagnosticsLog.disabled();
  }
});
