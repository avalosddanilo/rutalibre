import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

import '../../domain/entities/stop.dart';
import '../../domain/entities/trip_plan.dart';

/// Dónde venís dentro del tramo de colectivo, medido contra las paradas.
///
/// **Esto es lo que la app puede decir en vivo sin inventar.** No sabemos a
/// qué velocidad va el colectivo ni cuándo llega — pero con el GPS y las
/// paradas EN ORDEN del recorrido, "faltan 3 paradas para bajarte" es pura
/// geometría. Es el dato que evita ir pegado a la ventanilla contando
/// esquinas.
class RideProgress {
  const RideProgress({
    required this.stopsRemaining,
    required this.metersToAlight,
  });

  /// Cuántas paradas faltan para la de bajada. 0 = es esta.
  final int stopsRemaining;

  /// Metros en línea recta hasta la parada de bajada.
  final double metersToAlight;

  /// Si ya hay que estar mirando la puerta.
  ///
  /// Una parada antes, o a menos de 250 m: en el Gran Resistencia las
  /// cuadras son de ~100 m, así que 250 es "dos cuadras y media" — tiempo de
  /// tocar el timbre, no de quedarse sentado.
  bool get shouldPrepare => stopsRemaining <= 1 || metersToAlight < 250;

  /// Si la ALARMA tiene que sonar ya (una parada antes que [shouldPrepare]).
  ///
  /// Para quien va despierto mirando el renglón, avisar a una parada alcanza.
  /// Para DESPERTAR a alguien no: entre abrir los ojos, entender dónde está y
  /// juntar sus cosas, el aviso de la prueba de campo llegaba "muy justo".
  /// Dos paradas —o 500 m— es margen para despertarse, no para dormirse de
  /// vuelta.
  bool get shouldWake => stopsRemaining <= 2 || metersToAlight < 500;
}

/// El progreso dentro de [leg], o null si no se puede decir con honestidad.
///
/// La posición se mide contra los SEGMENTOS entre paradas consecutivas del
/// tramo, no solo contra las paradas: entre dos paradas lejanas —el puente
/// General Belgrano son ~1,7 km sin ninguna— el punto medio queda lejos de
/// TODA parada, y medir contra paradas hacía desaparecer el contador justo
/// en el medio del tramo más largo de la red (y vibrar dos veces, porque el
/// aviso se rearmaba). Estar cerca del CAMINO es estar en el viaje.
///
/// Null sale en cuatro casos y los cuatro son "mejor callar que adivinar":
///
/// * las paradas de subida o bajada no aparecen en [routeStops], o el tramo
///   quedó al revés (datos desalineados);
/// * **la cantidad de paradas del tramo no coincide con la que el
///   planificador prometió** ([TripLeg.stopCount]): pasa cuando un reimport
///   cambió el recorrido y la cache local quedó de otra generación — contar
///   contra esa secuencia diría "faltan 6" abajo de un paso que dice "viajá
///   4", y un contador que se contradice con su propio paso es peor que
///   ninguno;
/// * la posición está a más de [_offRouteMeters] del camino entero del
///   tramo — todavía no subiste, ya bajaste, o el GPS delira.
RideProgress? rideProgress({
  required List<Stop> routeStops,
  required TripLeg leg,
  required double lat,
  required double lng,
}) {
  final boardIndex = routeStops.indexWhere((s) => s.id == leg.boardStop.id);
  final alightIndex = routeStops.indexWhere((s) => s.id == leg.alightStop.id);
  if (boardIndex < 0 || alightIndex < 0 || alightIndex <= boardIndex) {
    return null;
  }
  if (alightIndex - boardIndex != leg.stopCount) return null;

  final here = LatLng(lat, lng);

  // El segmento del tramo más cercano a donde estás. SOLO del tramo: contra
  // el recorrido entero, una línea que va y vuelve por la misma avenida
  // matchearía la mano contraria y el contador saltaría. Empate a favor del
  // segmento POSTERIOR: parado exactamente en una parada, lo que viene es el
  // segmento que sale de ella.
  var nearestSegmentStart = boardIndex;
  var nearestMeters = double.infinity;
  for (var i = boardIndex; i < alightIndex; i++) {
    final meters = _metersToSegment(
      here,
      LatLng(routeStops[i].lat, routeStops[i].lng),
      LatLng(routeStops[i + 1].lat, routeStops[i + 1].lng),
    );
    if (meters <= nearestMeters) {
      nearestMeters = meters;
      nearestSegmentStart = i;
    }
  }
  if (nearestMeters > _offRouteMeters) return null;

  final metersToAlight = const Distance().as(
    LengthUnit.Meter,
    here,
    LatLng(leg.alightStop.lat, leg.alightStop.lng),
  );
  // Pegado a la bajada es CERO, gane el segmento que gane: el modelo por
  // segmentos no tiene "después de la última parada", y parado en la parada
  // de bajada diría "falta 1" — a 30 m de la puerta.
  final stopsRemaining = metersToAlight < 30
      ? 0
      : alightIndex - nearestSegmentStart;

  return RideProgress(
    stopsRemaining: stopsRemaining,
    metersToAlight: metersToAlight,
  );
}

/// Distancia en metros de [p] al segmento [a]→[b].
///
/// Planar equirectangular: para segmentos de menos de un par de kilómetros a
/// esta latitud, el error es de centímetros — nada que importe contra un
/// umbral de 400 m.
double _metersToSegment(LatLng p, LatLng a, LatLng b) {
  const metersPerDegLat = 111320.0;
  final metersPerDegLng = metersPerDegLat * math.cos(p.latitudeInRad.abs());

  final ax = (a.longitude - p.longitude) * metersPerDegLng;
  final ay = (a.latitude - p.latitude) * metersPerDegLat;
  final bx = (b.longitude - p.longitude) * metersPerDegLng;
  final by = (b.latitude - p.latitude) * metersPerDegLat;

  final dx = bx - ax;
  final dy = by - ay;
  final lengthSquared = dx * dx + dy * dy;
  if (lengthSquared == 0) return math.sqrt(ax * ax + ay * ay);

  // Proyección de p (el origen) sobre el segmento, acotada a sus extremos.
  final t = (-(ax * dx + ay * dy) / lengthSquared).clamp(0.0, 1.0);
  final cx = ax + t * dx;
  final cy = ay + t * dy;
  return math.sqrt(cx * cx + cy * cy);
}

/// Más lejos que esto de todo el camino del tramo, el contador se calla.
///
/// 400 m del CAMINO (no de las paradas): margen para el error del GPS urbano
/// y para que el trazado real se aparte de la línea recta entre paradas —el
/// puente tiene curva de acceso—. Más margen y el contador seguiría
/// corriendo mientras esperás el colectivo en tu casa.
const _offRouteMeters = 400.0;
