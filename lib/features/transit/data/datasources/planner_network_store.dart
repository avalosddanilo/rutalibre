import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Dónde vive en el teléfono la red para planificar sin conexión.
///
/// **Por qué no en la misma cache que lo demás.** Son ~370 KB, y la cache
/// de siempre usa el `SharedPreferences` de toda la vida, que Android carga
/// ENTERO al abrir la app: sumarle esto le agregaba trabajo a cada arranque,
/// que es justo lo que `docs/arranque.md` pide no empeorar. Acá va con
/// `SharedPreferencesAsync`, que guarda aparte y lee recién cuando se lo
/// piden — es decir, solo cuando no hubo señal para planificar.
abstract interface class PlannerNetworkStore {
  /// Lo guardado y cuándo se guardó, o null si no hay nada (o está roto).
  Future<({Map<String, dynamic> network, DateTime savedAt})?> read();

  Future<void> write(Map<String, dynamic> network, DateTime savedAt);

  /// Cuándo se guardó, sin leer la red entera: es lo que se mira después de
  /// cada viaje planificado con señal, para saber si hay que renovarla.
  Future<DateTime?> savedAt();
}

final class AsyncPrefsPlannerNetworkStore implements PlannerNetworkStore {
  AsyncPrefsPlannerNetworkStore([SharedPreferencesAsync? prefs])
    : _prefs = prefs ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _prefs;

  /// Con versión, como el resto de las claves: si cambia la forma, se sube
  /// el número y la red se vuelve a bajar entera.
  static const key = 'ruta_libre_planner_network_v1';
  static const savedAtKey = 'ruta_libre_planner_network_v1_saved_at';

  @override
  Future<DateTime?> savedAt() async {
    try {
      final raw = await _prefs.getString(savedAtKey);
      return raw == null ? null : DateTime.parse(raw);
    } on Object {
      return null;
    }
  }

  @override
  Future<({Map<String, dynamic> network, DateTime savedAt})?> read() async {
    try {
      final raw = await _prefs.getString(key);
      if (raw == null) return null;
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return (
        network: json['network'] as Map<String, dynamic>,
        savedAt: DateTime.parse(json['saved_at'] as String),
      );
    } on Object {
      // Guardado roto o de otra versión: como si no hubiera nada. Se vuelve
      // a bajar la próxima vez que haya señal.
      return null;
    }
  }

  @override
  Future<void> write(Map<String, dynamic> network, DateTime savedAt) async {
    try {
      await _prefs.setString(
        key,
        jsonEncode({'saved_at': savedAt.toIso8601String(), 'network': network}),
      );
      // Después de la red: si el guardado de la red falló, no queda una
      // fecha que diga que está al día.
      await _prefs.setString(savedAtKey, savedAt.toIso8601String());
    } on Object {
      // Sin espacio: se pierde el modo sin conexión, no la app.
    }
  }
}
