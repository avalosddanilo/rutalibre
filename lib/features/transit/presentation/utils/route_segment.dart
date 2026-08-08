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
/// Devuelve la lista entera si algo no cierra —muy pocos puntos, las dos
/// paradas sobre el mismo vértice—: es mejor dibujar de más que dejar el mapa
/// sin trazado.
///
/// **Soporta el recorrido al revés.** Si el vértice de bajada viene ANTES que
/// el de subida (pasa cuando la geometría está cargada en el sentido
/// contrario al del viaje), se recorta igual y se devuelve en el orden en que
/// se viaja.
List<LatLng> segmentBetween({
  required List<LatLng> points,
  required double boardLat,
  required double boardLng,
  required double alightLat,
  required double alightLng,
}) {
  if (points.length < 2) return points;

  final boardIndex = nearestVertexIndex(points, boardLat, boardLng);
  final alightIndex = nearestVertexIndex(points, alightLat, alightLng);
  if (boardIndex == alightIndex) return points;

  final reversed = alightIndex < boardIndex;
  final from = reversed ? alightIndex : boardIndex;
  final to = reversed ? boardIndex : alightIndex;

  final slice = points.sublist(from, to + 1);
  return reversed ? slice.reversed.toList() : slice;
}
