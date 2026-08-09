/// Geometría del importer: coser los ways de una relation en un trazado
/// continuo y simplificarlo. Dart PURO — sin OSM, sin red, sin SQL.
library;

import 'dart:math' as math;

/// Punto WGS84. Se usa un record y no una clase para no arrastrar tipos
/// entre módulos del importer.
typedef GeoPoint = ({double lat, double lng});

/// Distancia en metros sobre la esfera. Precisión de sobra para decidir
/// si dos extremos de calle son "el mismo lugar".
double haversineMeters(GeoPoint a, GeoPoint b) {
  const earthRadius = 6371000.0;
  final dLat = _rad(b.lat - a.lat);
  final dLng = _rad(b.lng - a.lng);
  final h =
      math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_rad(a.lat)) *
          math.cos(_rad(b.lat)) *
          math.sin(dLng / 2) *
          math.sin(dLng / 2);
  return earthRadius * 2 * math.atan2(math.sqrt(h), math.sqrt(1 - h));
}

double _rad(double degrees) => degrees * math.pi / 180;

/// Un way del trazado: sus nodos en el orden en que OSM los guarda.
class WaySegment {
  const WaySegment(this.nodeIds);

  final List<int> nodeIds;
}

/// Resultado del cosido.
class StitchResult {
  const StitchResult({required this.points, required this.gaps});

  /// Trazado continuo, listo para un LineString.
  final List<GeoPoint> points;

  /// Distancia en metros de cada salto que hubo que puentear. Vacío = el
  /// recorrido cosió perfecto de punta a punta.
  final List<double> gaps;
}

/// Cose los ways de una relation en una única polilínea.
///
/// OSM guarda los ways de un recorrido en orden pero SIN garantizar la
/// orientación: un mismo way puede estar dibujado en sentido contrario al
/// del recorrido. El algoritmo orienta cada way para que su primer nodo
/// enganche con el último nodo ya colocado.
///
/// Cuando dos ways consecutivos no comparten nodo (calle sin mapear,
/// rotonda partida), se puentea con una recta y se reporta el salto en
/// [StitchResult.gaps] para que el import quede auditado: sobre los datos
/// reales del Gran Resistencia, 66 de 73 recorridos cosen sin ningún salto.
StitchResult stitchWays(List<WaySegment> ways, Map<int, GeoPoint> nodes) {
  final usable = ways.where((w) => w.nodeIds.length >= 2).toList();
  if (usable.isEmpty) {
    return const StitchResult(points: [], gaps: []);
  }

  final chain = <int>[];
  final gaps = <double>[];

  for (var i = 0; i < usable.length; i++) {
    var nodeIds = usable[i].nodeIds;

    if (chain.isEmpty) {
      // El primero se orienta mirando al segundo: si su nodo INICIAL es el
      // que engancha, entonces está al revés.
      if (usable.length > 1) {
        final next = usable[1].nodeIds;
        if (nodeIds.first == next.first || nodeIds.first == next.last) {
          nodeIds = nodeIds.reversed.toList();
        }
      }
      chain.addAll(nodeIds);
      continue;
    }

    final tail = chain.last;
    if (nodeIds.first == tail) {
      chain.addAll(nodeIds.skip(1));
    } else if (nodeIds.last == tail) {
      chain.addAll(nodeIds.reversed.skip(1));
    } else {
      // Salto: entrar por el extremo más cercano al punto actual.
      final tailPoint = nodes[tail];
      final head = nodes[nodeIds.first];
      final foot = nodes[nodeIds.last];
      var gap = double.infinity;
      var reversed = false;
      if (tailPoint != null && head != null) {
        gap = haversineMeters(tailPoint, head);
      }
      if (tailPoint != null && foot != null) {
        final alternative = haversineMeters(tailPoint, foot);
        if (alternative < gap) {
          gap = alternative;
          reversed = true;
        }
      }
      if (gap.isFinite) gaps.add(gap);
      chain.addAll(reversed ? nodeIds.reversed : nodeIds);
    }
  }

  final points = <GeoPoint>[];
  for (final id in chain) {
    final point = nodes[id];
    if (point == null) continue;
    // Nodos repetidos consecutivos no aportan nada al trazado.
    if (points.isNotEmpty &&
        points.last.lat == point.lat &&
        points.last.lng == point.lng) {
      continue;
    }
    points.add(point);
  }

  return StitchResult(points: points, gaps: gaps);
}

/// Dónde cae un punto sobre una polilínea.
typedef Projection = ({
  /// Metros recorridos sobre la polilínea hasta el punto más cercano.
  double alongMeters,

  /// Cuán lejos está el punto de la polilínea.
  double offsetMeters,

  /// De qué LADO del sentido de marcha cayó, en metros con signo:
  /// negativo a la derecha, positivo a la izquierda.
  ///
  /// Hace falta para decidir si una parada le sirve a ESTE recorrido o al que
  /// va en contramano por la misma avenida. En Argentina se maneja por la
  /// derecha, así que un colectivo levanta pasajeros de su lado derecho. Sin
  /// esto, en una avenida de doble mano las dos veredas quedan a la misma
  /// distancia del trazado y son indistinguibles.
  double sideMeters,
});

/// Proyecta [point] sobre [line] y devuelve cuánto se avanzó sobre el
/// trazado hasta el punto más cercano.
///
/// Es lo que permite ordenar las paradas por orden de PASO real en vez de
/// confiar en el orden en que OSM lista los miembros de la relation — que
/// viene en bloques (todas las plataformas y después todas las posiciones)
/// y no en orden de recorrido.
Projection projectOntoLine(GeoPoint point, List<GeoPoint> line) {
  if (line.isEmpty) {
    return (alongMeters: 0, offsetMeters: double.infinity, sideMeters: 0);
  }
  if (line.length == 1) {
    return (
      alongMeters: 0,
      offsetMeters: haversineMeters(point, line.first),
      sideMeters: 0,
    );
  }

  var best = (alongMeters: 0.0, offsetMeters: double.infinity, sideMeters: 0.0);
  var traveled = 0.0;

  for (var i = 1; i < line.length; i++) {
    final a = line[i - 1];
    final b = line[i];
    final segmentLength = haversineMeters(a, b);
    final offset = distanceToSegmentMeters(point, a, b);
    if (offset < best.offsetMeters) {
      // Cuánto del segmento se recorrió hasta el pie de la perpendicular.
      final fraction = segmentLength == 0
          ? 0.0
          : (_alongFraction(point, a, b)).clamp(0.0, 1.0);
      best = (
        alongMeters: traveled + segmentLength * fraction,
        offsetMeters: offset,
        sideMeters: _signedSide(point, a, b),
      );
    }
    traveled += segmentLength;
  }
  return best;
}

/// Distancia con signo de [p] a la RECTA que pasa por a→b: negativa a la
/// derecha del sentido de marcha, positiva a la izquierda.
///
/// Es el producto vectorial en un plano local (x = este, y = norte)
/// normalizado por el largo del segmento. Se calcula contra la recta y no
/// contra el segmento a propósito: el signo solo tiene sentido a los
/// costados, y quien lo usa ya sabe por [Projection.offsetMeters] si está
/// cerca.
double _signedSide(GeoPoint p, GeoPoint a, GeoPoint b) {
  const metersPerDegreeLat = 111320.0;
  final metersPerDegreeLng = metersPerDegreeLat * math.cos(_rad(a.lat));
  final px = (p.lng - a.lng) * metersPerDegreeLng;
  final py = (p.lat - a.lat) * metersPerDegreeLat;
  final bx = (b.lng - a.lng) * metersPerDegreeLng;
  final by = (b.lat - a.lat) * metersPerDegreeLat;
  final length = math.sqrt(bx * bx + by * by);
  if (length == 0) return 0;
  // cross > 0 ⇒ p está a la IZQUIERDA de a→b.
  return (bx * py - by * px) / length;
}

/// Fracción del segmento a-b donde cae la proyección de p (0 = en a).
double _alongFraction(GeoPoint p, GeoPoint a, GeoPoint b) {
  const metersPerDegreeLat = 111320.0;
  final metersPerDegreeLng = metersPerDegreeLat * math.cos(_rad(a.lat));
  final px = (p.lng - a.lng) * metersPerDegreeLng;
  final py = (p.lat - a.lat) * metersPerDegreeLat;
  final bx = (b.lng - a.lng) * metersPerDegreeLng;
  final by = (b.lat - a.lat) * metersPerDegreeLat;
  final lengthSquared = bx * bx + by * by;
  if (lengthSquared == 0) return 0;
  return (px * bx + py * by) / lengthSquared;
}

/// Simplificación Douglas-Peucker con tolerancia en METROS.
///
/// Un recorrido de OSM trae un vértice por cada quiebre de calle: cientos
/// de puntos que a escala urbana son indistinguibles. Bajarlos achica el
/// SQL generado y el payload que baja el teléfono, sin cambio visible.
List<GeoPoint> simplify(List<GeoPoint> points, double toleranceMeters) {
  if (points.length <= 2 || toleranceMeters <= 0) return points;

  final keep = List<bool>.filled(points.length, false);
  keep[0] = true;
  keep[points.length - 1] = true;

  // Iterativo y no recursivo: un recorrido largo puede tener miles de
  // puntos y la recursión no aporta nada acá.
  final pending = <(int, int)>[(0, points.length - 1)];
  while (pending.isNotEmpty) {
    final (first, last) = pending.removeLast();
    if (last <= first + 1) continue;

    var maxDistance = 0.0;
    var maxIndex = first;
    for (var i = first + 1; i < last; i++) {
      final distance = distanceToSegmentMeters(
        points[i],
        points[first],
        points[last],
      );
      if (distance > maxDistance) {
        maxDistance = distance;
        maxIndex = i;
      }
    }

    if (maxDistance > toleranceMeters) {
      keep[maxIndex] = true;
      pending.add((first, maxIndex));
      pending.add((maxIndex, last));
    }
  }

  final result = <GeoPoint>[];
  for (var i = 0; i < points.length; i++) {
    if (keep[i]) result.add(points[i]);
  }
  return result;
}

/// Distancia del punto [p] al segmento [a]-[b], en metros.
///
/// Proyecta a un plano local (equirrectangular alrededor de `a`): a escala
/// de cuadras el error es despreciable y evita trigonometría cara.
double distanceToSegmentMeters(GeoPoint p, GeoPoint a, GeoPoint b) {
  const metersPerDegreeLat = 111320.0;
  final metersPerDegreeLng = metersPerDegreeLat * math.cos(_rad(a.lat));

  final px = (p.lng - a.lng) * metersPerDegreeLng;
  final py = (p.lat - a.lat) * metersPerDegreeLat;
  final bx = (b.lng - a.lng) * metersPerDegreeLng;
  final by = (b.lat - a.lat) * metersPerDegreeLat;

  final segmentLengthSquared = bx * bx + by * by;
  if (segmentLengthSquared == 0) {
    return math.sqrt(px * px + py * py);
  }

  var t = (px * bx + py * by) / segmentLengthSquared;
  t = t.clamp(0.0, 1.0);
  final dx = px - t * bx;
  final dy = py - t * by;
  return math.sqrt(dx * dx + dy * dy);
}
