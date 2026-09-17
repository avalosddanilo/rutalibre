/// Recorta el trazado de un recorrido al PEDAZO que la persona viaja.
///
/// **Por qué hace falta.** El mapa dibujaba el recorrido entero: si tomabas la
/// 3 durante cuatro cuadras, te pintaba los veinte kilómetros de la línea. Es
/// correcto y es inútil — no se distingue "por acá vas" de "por acá pasa el
/// colectivo", que es justamente lo que uno quiere ver.
///
/// Lo que se dibuja después de esto es el camino de verdad: de dónde subís a
/// dónde bajás, y nada más.
library;

import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

/// El índice del vértice más cercano a un punto.
///
/// Fuerza bruta sobre los vértices. Un recorrido tiene ~500 puntos y esto
/// corre dos veces por tramo al elegir un viaje: no vale la pena un índice
/// espacial para eso, y un algoritmo que se entiende de una vale más que uno
/// rápido que nadie toca.
int nearestVertexIndex(List<LatLng> points, double lat, double lng) {
  var bestIndex = 0;
  var bestDistance = double.infinity;
  for (var i = 0; i < points.length; i++) {
    final distance = _squaredMeters(points[i], lat, lng);
    if (distance < bestDistance) {
      bestDistance = distance;
      bestIndex = i;
    }
  }
  return bestIndex;
}

/// Distancia al cuadrado, en metros aproximados.
///
/// Al cuadrado y sin raíz porque solo se COMPARA: la raíz no cambia cuál es
/// el menor y es la operación cara del bucle. Y plana en vez de haversine
/// porque a esta escala —un recorrido urbano— la diferencia es de
/// centímetros.
double _squaredMeters(LatLng point, double lat, double lng) {
  const metersPerDegree = 111320.0;
  final dLat = (point.latitude - lat) * metersPerDegree;
  final dLng =
      (point.longitude - lng) * metersPerDegree * math.cos(lat * math.pi / 180);
  return dLat * dLat + dLng * dLng;
}

/// El tramo del trazado entre dónde se sube y dónde se baja.
///
/// **Corta en la parada, no en el vértice más cercano.** Cada parada se
/// proyecta sobre el SEGMENTO del trazado que le queda más cerca y el dibujo
/// arranca y termina en ese punto exacto. Cortar en el vértice más cercano
/// fallaba justo donde más se nota: una avenida recta está mapeada con muy
/// pocos vértices, a veces separados por cuadras, y el tramo dibujado
/// arrancaba a mitad de camino de la parada anterior — en la prueba de campo
/// la línea "empezaba en otro lado".
///
/// Devuelve la lista entera si algo no cierra —muy pocos puntos, las dos
/// paradas en el mismo lugar del trazado—: es mejor dibujar de más que dejar
/// el mapa sin trazado.
///
/// **Soporta el recorrido al revés.** Si la bajada queda ANTES que la subida
/// sobre la geometría (pasa cuando está cargada en el sentido contrario al
/// del viaje), se recorta igual y se devuelve en el orden en que se viaja.
List<LatLng> segmentBetween({
  required List<LatLng> points,
  required double boardLat,
  required double boardLng,
  required double alightLat,
  required double alightLng,
}) {
  if (points.length < 2) return points;

  final board = _projectOnto(points, boardLat, boardLng);
  final alight = _projectOnto(points, alightLat, alightLng);
  if ((board.position - alight.position).abs() < 1e-9) return points;

  final reversed = alight.position < board.position;
  final from = reversed ? alight : board;
  final to = reversed ? board : alight;

  final slice = <LatLng>[
    from.point,
    // Los vértices ESTRICTAMENTE entre los dos cortes.
    ...points.sublist(from.segment + 1, to.segment + 1),
    to.point,
  ];
  // Una parada que cae justo sobre un vértice lo repite: fuera el duplicado,
  // que no dibuja nada y ensucia el trazado.
  final result = <LatLng>[];
  for (final point in slice) {
    if (result.isEmpty || result.last != point) result.add(point);
  }
  return reversed ? result.reversed.toList() : result;
}

/// Dónde cae un punto sobre el trazado.
///
/// [position] es `segmento + t`, creciente a lo largo de la geometría: sirve
/// para saber cuál de dos cortes viene primero sin recorrer nada.
typedef _Cut = ({int segment, double position, LatLng point});

_Cut _projectOnto(List<LatLng> points, double lat, double lng) {
  const metersPerDegree = 111320.0;
  final metersPerDegreeLng = metersPerDegree * math.cos(lat * math.pi / 180);

  var bestSegment = 0;
  var bestT = 0.0;
  var bestDistance = double.infinity;
  for (var i = 0; i < points.length - 1; i++) {
    // Plano, con el punto buscado como origen: a escala de una ciudad el
    // error es de centímetros.
    final ax = (points[i].longitude - lng) * metersPerDegreeLng;
    final ay = (points[i].latitude - lat) * metersPerDegree;
    final bx = (points[i + 1].longitude - lng) * metersPerDegreeLng;
    final by = (points[i + 1].latitude - lat) * metersPerDegree;
    final dx = bx - ax;
    final dy = by - ay;
    final lengthSquared = dx * dx + dy * dy;
    final t = lengthSquared == 0
        ? 0.0
        : (-(ax * dx + ay * dy) / lengthSquared).clamp(0.0, 1.0);
    final cx = ax + t * dx;
    final cy = ay + t * dy;
    final distance = cx * cx + cy * cy;
    if (distance < bestDistance) {
      bestDistance = distance;
      bestSegment = i;
      bestT = t;
    }
  }

  final a = points[bestSegment];
  final b = points[bestSegment + 1];
  final point = bestT == 0
      ? a
      : bestT == 1
      ? b
      : LatLng(
          a.latitude + (b.latitude - a.latitude) * bestT,
          a.longitude + (b.longitude - a.longitude) * bestT,
        );
  return (segment: bestSegment, position: bestSegment + bestT, point: point);
}
