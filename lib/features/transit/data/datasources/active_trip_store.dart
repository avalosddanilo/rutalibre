import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/trip_plan.dart';
import '../models/trip_plan_model.dart';

/// Un viaje con la guía andando, congelado para sobrevivir a cerrar la app.
///
/// Trae TODO lo que hace falta para volver a dibujarlo sin red: el plan
/// entero (tramos con sus paradas), las dos puntas del viaje y en qué paso
/// estaba la guía. El trazado y las paradas del recorrido no viajan acá
/// porque ya viven en la cache normal — quedaron guardados al dibujarse la
/// primera vez.
class ActiveTrip {
  const ActiveTrip({
    required this.plan,
    required this.originLat,
    required this.originLng,
    required this.destinationLat,
    required this.destinationLng,
    required this.stepIndex,
    this.originName,
  });

  final TripPlan plan;
  final double originLat;
  final double originLng;
  final double destinationLat;
  final double destinationLng;
  final int stepIndex;
  final String? originName;
}

/// Persiste el viaje activo en el teléfono.
///
/// **El problema que resuelve es el pozo de batería del colectivo**: la guía
/// abierta, el teléfono que se apaga o Android que mata la app en segundo
/// plano, y al reabrir… el mapa vacío, con el viaje perdido a mitad de
/// camino y quizás sin señal para recalcularlo. Con esto, el viaje se
/// restaura del teléfono sin volver a consultar a Supabase: el plan estaba
/// acá y las paradas del recorrido en la cache de siempre.
final class ActiveTripStore {
  const ActiveTripStore(this._prefs, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final SharedPreferences _prefs;
  final DateTime Function() _now;

  /// Clave propia y versionada, FUERA del prefijo de la cache de datos:
  /// subir la versión de la cache (datos nuevos) no tiene por qué matar un
  /// viaje en curso, y viceversa.
  static const _key = 'ruta_libre_active_trip_v1';

  /// Un viaje sin actividad hace más de esto no se ofrece retomar.
  ///
  /// Tres horas DESDE LA ÚLTIMA INTERACCIÓN, no desde el arranque: la guía
  /// puede abrirse desde casa mucho antes de subir (un interurbano demorado
  /// lo hace normal), y lo que dice "este viaje sigue vivo" es que alguien
  /// tocó "siguiente", no cuándo empezó. Tres horas porque ningún viaje del
  /// Gran Resistencia dura eso, y "retomar" un viaje de ayer hace
  /// desconfiar del cartel.
  static const maxAge = Duration(hours: 3);

  Future<void> save(ActiveTrip trip) async {
    await _prefs.setString(
      _key,
      jsonEncode({
        // SIEMPRE en UTC. En hora local sin zona, un teléfono que cambia de
        // zona horaria (pasa: en la frontera se agarra la antena del otro
        // lado) reinterpreta la marca y corre el vencimiento sin que el
        // reloj haya cambiado.
        'saved_at': _now().toUtc().toIso8601String(),
        'origin_lat': trip.originLat,
        'origin_lng': trip.originLng,
        'dest_lat': trip.destinationLat,
        'dest_lng': trip.destinationLng,
        'origin_name': trip.originName,
        'step': trip.stepIndex,
        'plan': TripPlanModel.planToJson(trip.plan),
      }),
    );
  }

  /// Actualiza SOLO el paso, sin re-serializar el plan entero.
  ///
  /// Se llama en cada "siguiente"/"anterior": si no hay viaje guardado no
  /// hace nada (la guía puede estar corriendo con el guardado fallado, y
  /// eso no puede romperla).
  Future<void> saveStep(int stepIndex) async {
    final raw = _prefs.getString(_key);
    if (raw == null) return;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      json['step'] = stepIndex;
      // Tocar un paso ES actividad: refresca la frescura. Sin esto, la
      // ventana de 3 horas corría desde el ARRANQUE de la guía, y un viaje
      // en uso activo —guía abierta desde casa, colectivo demorado— vencía
      // arriba del colectivo: justo el caso para el que la persistencia
      // existe.
      json['saved_at'] = _now().toUtc().toIso8601String();
      await _prefs.setString(_key, jsonEncode(json));
    } on Object {
      // Guardado corrupto: se limpia en el próximo load().
    }
  }

  /// El viaje guardado, o null si no hay, venció o no se puede leer.
  ///
  /// Cualquier problema —JSON corrupto, formato viejo, reloj movido— termina
  /// en null y NUNCA en excepción: retomar un viaje es una cortesía, y una
  /// cortesía no puede impedir que la app abra.
  Future<ActiveTrip?> load() async {
    final raw = _prefs.getString(_key);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final savedAt = DateTime.parse(json['saved_at'] as String).toUtc();
      final now = _now().toUtc();
      // También se descarta una marca EN EL FUTURO: pasa cuando el guardado
      // se hizo con el reloj adelantado a mano y después NTP lo corrigió.
      // Solo con `> maxAge`, esa diferencia negativa figuraba "fresca" por
      // horas de más. Es la misma guarda que ya tiene la cache del clima.
      if (savedAt.isAfter(now) || now.difference(savedAt) > maxAge) {
        await clear();
        return null;
      }
      return ActiveTrip(
        plan: TripPlanModel.fromJson(json['plan'] as Map<String, dynamic>),
        originLat: (json['origin_lat'] as num).toDouble(),
        originLng: (json['origin_lng'] as num).toDouble(),
        destinationLat: (json['dest_lat'] as num).toDouble(),
        destinationLng: (json['dest_lng'] as num).toDouble(),
        stepIndex: (json['step'] as num).toInt(),
        originName: json['origin_name'] as String?,
      );
    } on Object {
      await clear();
      return null;
    }
  }

  Future<void> clear() async {
    await _prefs.remove(_key);
  }
}
