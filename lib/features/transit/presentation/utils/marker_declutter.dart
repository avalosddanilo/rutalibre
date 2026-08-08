/// Descongestionado de marcadores: qué paradas se dibujan a cada zoom.
///
/// El problema que resuelve: un recorrido del Gran Resistencia tiene ~47
/// paradas y las paradas urbanas están cada 130-250 m. Encuadrado entero
/// (zoom ~13) eso son 8 px entre pin y pin: una mancha en la que no se
/// distingue ni se puede tocar nada. Lo mismo en "cerca mío" en el centro,
/// donde hay 40 paradas a menos de 500 m.
///
/// La regla es de PANTALLA, no de datos: no se dibuja un marcador a menos de
/// [defaultMinSeparation] píxeles de otro ya dibujado. Nada se pierde —
/// acercando el mapa aparecen todas.
///
/// Dart puro + latlong2: sin Flutter y sin flutter_map, así se testea sin
/// levantar un mapa.
library;

import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

/// Separación mínima en píxeles entre dos marcadores.
///
/// Un pin mide 22 px de ancho; 40 deja aire suficiente para que no se toquen
/// y para que el área tocable de 44 px de cada uno sea mayormente propia.
const double defaultMinSeparation = 40;

/// Devuelve los elementos de [items] que entran sin pisarse al zoom [zoom],
/// respetando el orden recibido: el que viene primero gana el lugar.
///
/// Por eso el orden importa y es responsabilidad de quien llama — en "cerca
/// mío" los elementos vienen ordenados por distancia, así que la parada más
/// cercana nunca se cae.
///
/// [reserved] son puntos que ya ocupan lugar aunque no estén en [items]
/// (las cabeceras del recorrido, que se dibujan siempre).
List<T> spreadOutMarkers<T>(
  Iterable<T> items, {
  required LatLng Function(T item) location,
  required double zoom,
  double minSeparation = defaultMinSeparation,
  Iterable<LatLng> reserved = const [],
}) {
  if (minSeparation <= 0) return items.toList();

  // Grilla de celdas del tamaño de la separación mínima: alcanza con mirar
  // las 8 celdas vecinas, porque nada más lejos que una celda puede estar a
  // menos de `minSeparation`.
  final occupied = <({int x, int y}), List<Offset2D>>{};

  bool tryPlace(Offset2D point) {
    final cellX = (point.x / minSeparation).floor();
    final cellY = (point.y / minSeparation).floor();
    for (var dx = -1; dx <= 1; dx++) {
      for (var dy = -1; dy <= 1; dy++) {
        for (final other
            in occupied[(x: cellX + dx, y: cellY + dy)] ?? const <Offset2D>[]) {
          final distanceX = point.x - other.x;
          final distanceY = point.y - other.y;
          if (distanceX * distanceX + distanceY * distanceY <
              minSeparation * minSeparation) {
            return false;
          }
        }
      }
    }
    occupied.putIfAbsent((x: cellX, y: cellY), () => []).add(point);
    return true;
  }

  for (final point in reserved) {
    tryPlace(worldPixels(point, zoom));
  }

  final kept = <T>[];
  for (final item in items) {
    if (tryPlace(worldPixels(location(item), zoom))) kept.add(item);
  }
  return kept;
}

/// Los [count] elementos de [items] más cercanos a [origin].
///
/// La otra mitad de "dibujar menos": [spreadOutMarkers] recorta por lo que
/// entra en pantalla, esto recorta por lo que le importa al usuario. Cuando
/// elige una parada, sus vecinas siguen siendo útiles (son las alternativas
/// de la misma esquina) y el resto de la lista ya no.
///
/// No excluye nada por su cuenta: si [origin] es la posición de uno de los
/// elementos, sacarlo es responsabilidad de quien llama. Filtrar por
/// coordenada acá haría desaparecer en silencio a una parada que quedó
/// mapeada en el mismo punto que otra.
///
/// Se mide con la distancia real de latlong2, no con píxeles: "las cuatro de
/// al lado" no depende del zoom.
List<T> nearestTo<T>(
  Iterable<T> items, {
  required LatLng origin,
  required LatLng Function(T item) location,
  required int count,
}) {
  if (count <= 0) return const [];
  const distance = Distance();
  final ranked = items.toList()
    ..sort(
      (a, b) => distance
          .as(LengthUnit.Meter, origin, location(a))
          .compareTo(distance.as(LengthUnit.Meter, origin, location(b))),
    );
  return ranked.take(count).toList();
}

/// Punto en el plano de píxeles del mundo, en pantalla.
typedef Offset2D = ({double x, double y});

/// Proyección Web Mercator a píxeles absolutos del mundo al zoom dado.
///
/// Absolutos y no relativos a la pantalla A PROPÓSITO: así el resultado del
/// descongestionado depende SOLO del zoom. Si dependiera de dónde está la
/// cámara, las paradas aparecerían y desaparecerían al arrastrar el mapa.
Offset2D worldPixels(LatLng point, double zoom) {
  final scale = 256 * math.pow(2, zoom).toDouble();
  final x = (point.longitude + 180) / 360 * scale;
  // Clampeado a los ~85° donde Mercator deja de estar definido; en el Chaco
  // no pasa nunca, pero un log(0) sería un NaN silencioso.
  final latRad =
      point.latitude.clamp(-85.05112878, 85.05112878) * math.pi / 180;
  final y =
      (0.5 -
          math.log((1 + math.sin(latRad)) / (1 - math.sin(latRad))) /
              (4 * math.pi)) *
      scale;
  return (x: x, y: y);
}
