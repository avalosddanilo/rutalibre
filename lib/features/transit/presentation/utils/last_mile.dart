import 'package:latlong2/latlong.dart';

import '../../domain/entities/reference_stop.dart';

/// Cómo hacer el último tramo cuando el colectivo más cercano te deja lejos.
///
/// **Existe por Corrientes.** El planificador conoce los colectivos que
/// cruzan el puente, pero no las líneas urbanas de Corrientes: el municipio
/// publica 10 de 22 y sin el orden de las paradas (ver [ReferenceStop]). Un
/// destino en Corrientes lejos del centro terminaba en "no encontramos cómo
/// llegar", aunque la app SÍ sabe qué líneas paran en cada esquina.
///
/// Con eso se puede decir algo útil y honesto: "del 904 te bajás acá; desde
/// esa esquina pasa la 103A, que también para cerca de tu destino". Lo que
/// NO se puede asegurar es el sentido ni el orden —esos datos no existen—,
/// y por eso la pantalla lo presenta como sugerencia a confirmar, nunca como
/// un viaje planificado.
class LastMileSuggestion {
  const LastMileSuggestion({
    required this.lines,
    required this.boardStop,
    required this.alightStop,
  });

  /// Las líneas que paran en las DOS paradas, ordenadas.
  final List<String> lines;

  /// Dónde tomarla: cerca de donde te deja el primer colectivo.
  final ReferenceStop boardStop;

  /// Dónde bajarse: cerca del destino.
  final ReferenceStop alightStop;
}

/// Hasta dónde se considera "cerca" una parada, a pie.
///
/// 500 m, el mismo radio que usa el planificador para las caminatas: más
/// lejos, una sugerencia deja de ser "de la esquina" y pasa a ser otro viaje.
const lastMileWalkMeters = 500.0;

/// Busca una línea urbana que conecte donde te bajás con tu destino.
///
/// Prioriza las paradas más cercanas a cada punta: entre dos que sirven,
/// gana la que menos hace caminar. Null si ninguna línea para cerca de las
/// dos puntas a la vez.
LastMileSuggestion? suggestLastMile({
  required List<ReferenceStop> stops,
  required double fromLat,
  required double fromLng,
  required double toLat,
  required double toLng,
}) {
  final nearFrom = _nearby(stops, fromLat, fromLng);
  final nearTo = _nearby(stops, toLat, toLng);
  if (nearFrom.isEmpty || nearTo.isEmpty) return null;

  for (final to in nearTo) {
    for (final from in nearFrom) {
      // La misma parada en las dos puntas no es un viaje: es caminar.
      if (identical(from, to) || from == to) continue;
      final common = from.lines.toSet().intersection(to.lines.toSet()).toList()
        ..sort();
      if (common.isNotEmpty) {
        return LastMileSuggestion(
          lines: common,
          boardStop: from,
          alightStop: to,
        );
      }
    }
  }
  return null;
}

/// Las líneas que paran cerca de un punto, sin repetir y ordenadas. Para
/// cuando no hay conexión: saber qué pasa por el destino ya orienta.
List<String> linesNear({
  required List<ReferenceStop> stops,
  required double lat,
  required double lng,
}) {
  final lines = {
    for (final stop in _nearby(stops, lat, lng)) ...stop.lines,
  }.toList()..sort();
  return lines;
}

List<ReferenceStop> _nearby(List<ReferenceStop> stops, double lat, double lng) {
  const distance = Distance();
  final here = LatLng(lat, lng);
  final withDistance = [
    for (final stop in stops)
      (
        stop: stop,
        meters: distance.as(LengthUnit.Meter, here, LatLng(stop.lat, stop.lng)),
      ),
  ]..removeWhere((e) => e.meters > lastMileWalkMeters);
  withDistance.sort((a, b) => a.meters.compareTo(b.meters));
  return [for (final e in withDistance) e.stop];
}
