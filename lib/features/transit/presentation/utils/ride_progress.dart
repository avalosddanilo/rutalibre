import 'package:latlong2/latlong.dart';

import '../../domain/entities/stop.dart';
import '../../domain/entities/trip_plan.dart';

/// Dónde venís dentro del tramo de colectivo, medido contra las paradas.
///
/// **Esto es lo que la app puede decir en vivo sin inventar.** No sabemos a
/// qué velocidad va el colectivo ni cuándo llega — pero con el GPS y las
/// paradas EN ORDEN del recorrido, "faltan 3 paradas para bajarte" es pura
/// geometría: la parada más cercana a tu posición, contada contra la de
/// bajada. Es el dato que evita ir pegado a la ventanilla contando esquinas.
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
}

/// El progreso dentro de [leg], o null si no se puede decir con honestidad.
///
/// Null sale en tres casos y los tres son "mejor callar que adivinar":
///
/// * las paradas de subida o bajada no aparecen en [routeStops] (datos
///   desalineados entre el planificador y el recorrido);
/// * la posición está a más de [_offRouteMeters] de TODA parada del tramo —
///   todavía no subiste, ya bajaste, o el GPS está delirando. Un contador
///   que corre mientras esperás en la vereda diría cualquier cosa;
/// * el tramo quedó al revés (bajada antes que subida en la lista).
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

  const distance = Distance();
  final here = LatLng(lat, lng);

  // La parada del tramo más cercana a donde estás. SOLO del tramo: contra el
  // recorrido entero, un recorrido que va y vuelve por la misma avenida
  // matchearía la parada de la mano contraria y el contador saltaría.
  var nearestIndex = boardIndex;
  var nearestMeters = double.infinity;
  for (var i = boardIndex; i <= alightIndex; i++) {
    final stop = routeStops[i];
    final meters = distance.as(
      LengthUnit.Meter,
      here,
      LatLng(stop.lat, stop.lng),
    );
    if (meters < nearestMeters) {
      nearestMeters = meters;
      nearestIndex = i;
    }
  }
  if (nearestMeters > _offRouteMeters) return null;

  return RideProgress(
    stopsRemaining: alightIndex - nearestIndex,
    metersToAlight: distance.as(
      LengthUnit.Meter,
      here,
      LatLng(leg.alightStop.lat, leg.alightStop.lng),
    ),
  );
}

/// Más lejos que esto de toda parada del tramo, el contador se calla.
///
/// 400 m: en el interurbano hay paradas a más de medio kilómetro una de
/// otra, así que en el medio de un tramo largo la más cercana puede quedar
/// lejos sin que nada ande mal. Más margen que esto y el contador seguiría
/// corriendo mientras esperás el colectivo en tu casa.
const _offRouteMeters = 400.0;
