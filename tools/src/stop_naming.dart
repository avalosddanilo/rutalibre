/// Nombres de parada derivados del callejero.
///
/// El problema: 84% de las paradas del Gran Resistencia llegan de OSM sin
/// `name`, solo con un `ref` interno de la concesionaria. Al pasajero
/// "Parada C03253" no le dice absolutamente nada; "Ávalos y Rivadavia" sí.
///
/// La solución es la que ya usa la gente para describir una parada: la
/// esquina. Se busca la calle sobre la que está la parada y la transversal
/// más cercana.
///
/// Dart PURO — sin red, sin SQL.
library;

import 'geometry.dart';

/// Un tramo de calle con nombre, tal como viene de OSM.
class NamedStreet {
  const NamedStreet({required this.name, required this.points});

  final String name;
  final List<GeoPoint> points;
}

/// Distancia de un punto a una calle, junto con su nombre.
typedef StreetHit = ({String name, double distanceMeters});

/// Índice espacial de calles.
///
/// Sin índice esto sería 1579 paradas × ~40.000 segmentos de calle: la
/// grilla lo baja a mirar solo las celdas vecinas.
class StreetIndex {
  StreetIndex(List<NamedStreet> streets) {
    for (final street in streets) {
      final name = street.name.trim();
      if (name.isEmpty) continue;
      for (var i = 1; i < street.points.length; i++) {
        final a = street.points[i - 1];
        final b = street.points[i];
        final segment = (name: name, a: a, b: b);
        // Se indexa por TODAS las celdas que el segmento atraviesa, no solo
        // por las de sus extremos: OSM tiene ways con nodos separados por
        // cientos de metros (una avenida recta), y una parada en el medio
        // de un tramo así no encontraría su calle.
        for (final key in _cellsCrossedBy(a, b)) {
          _cells.putIfAbsent(key, () => []).add(segment);
        }
      }
    }
  }

  /// ~220 m de lado a esta latitud. Más chico multiplica celdas sin ganar
  /// nada; más grande hace que cada consulta mire de más.
  static const _cellDegrees = 0.002;

  final Map<String, List<({String name, GeoPoint a, GeoPoint b})>> _cells = {};

  static String _cellKey(GeoPoint p) =>
      '${(p.lat / _cellDegrees).floor()}:${(p.lng / _cellDegrees).floor()}';

  /// Celdas que toca el segmento a-b, muestreándolo cada media celda (una
  /// muestra más fina no agrega celdas: no se puede saltear ninguna).
  static Set<String> _cellsCrossedBy(GeoPoint a, GeoPoint b) {
    final spanLat = (b.lat - a.lat).abs();
    final spanLng = (b.lng - a.lng).abs();
    final steps = ((spanLat > spanLng ? spanLat : spanLng) / (_cellDegrees / 2))
        .ceil();
    if (steps <= 1) return {_cellKey(a), _cellKey(b)};

    final keys = <String>{};
    for (var i = 0; i <= steps; i++) {
      final t = i / steps;
      keys.add(
        _cellKey((
          lat: a.lat + (b.lat - a.lat) * t,
          lng: a.lng + (b.lng - a.lng) * t,
        )),
      );
    }
    return keys;
  }

  /// Calles a menos de [maxMeters], la más cercana primero y sin repetir
  /// nombre (una calle larga aparece una sola vez, con su tramo más cercano).
  List<StreetHit> nearestStreets(GeoPoint point, {double maxMeters = 150}) {
    final best = <String, double>{};
    final baseLat = (point.lat / _cellDegrees).floor();
    final baseLng = (point.lng / _cellDegrees).floor();

    for (var dLat = -1; dLat <= 1; dLat++) {
      for (var dLng = -1; dLng <= 1; dLng++) {
        final segments = _cells['${baseLat + dLat}:${baseLng + dLng}'];
        if (segments == null) continue;
        for (final s in segments) {
          final d = distanceToSegmentMeters(point, s.a, s.b);
          if (d > maxMeters) continue;
          final previous = best[s.name];
          if (previous == null || d < previous) best[s.name] = d;
        }
      }
    }

    final hits =
        best.entries.map((e) => (name: e.key, distanceMeters: e.value)).toList()
          ..sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    return hits;
  }
}

/// Nombre derivado para una parada, o null si el callejero no alcanza.
///
/// Devolver null es una respuesta legítima: es preferible mostrar el código
/// interno antes que inventar una esquina que no existe.
String? deriveStopName(
  GeoPoint stop,
  StreetIndex index, {

  /// Más lejos que esto, la parada no está "sobre" esa calle.
  double onStreetMeters = 40,

  /// Hasta acá se busca la transversal para armar la esquina.
  double crossStreetMeters = 120,
}) {
  final hits = index.nearestStreets(stop, maxMeters: crossStreetMeters);
  if (hits.isEmpty) return null;

  final main = hits.first;
  if (main.distanceMeters > onStreetMeters) return null;

  for (final hit in hits.skip(1)) {
    if (hit.name != main.name) {
      return joinStreetNames(main.name, hit.name);
    }
  }
  return main.name;
}

/// Une dos calles respetando la eufonía del castellano:
/// "Italia **e** Yrigoyen", no "Italia y Yrigoyen".
String joinStreetNames(String first, String second) {
  final normalized = second
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u');
  // "y" pasa a "e" ante i-/hi-, pero NO ante "hie-" ("y hierro").
  final startsWithI =
      normalized.startsWith('i') ||
      (normalized.startsWith('hi') && !normalized.startsWith('hie'));
  return '$first ${startsWithI ? 'e' : 'y'} $second';
}

/// Reconstruye los tramos de calle con nombre desde la respuesta de Overpass.
List<NamedStreet> streetsFromOverpass(Map<String, dynamic> json) {
  final points = <int, GeoPoint>{};
  final ways = <Map<String, dynamic>>[];
  for (final element
      in ((json['elements'] as List<dynamic>?) ?? const [])
          .cast<Map<String, dynamic>>()) {
    switch (element['type']) {
      case 'node':
        final lat = (element['lat'] as num?)?.toDouble();
        final lng = (element['lon'] as num?)?.toDouble();
        final id = (element['id'] as num?)?.toInt();
        if (lat != null && lng != null && id != null) {
          points[id] = (lat: lat, lng: lng);
        }
      case 'way':
        ways.add(element);
    }
  }

  final streets = <NamedStreet>[];
  for (final way in ways) {
    final name = (way['tags'] as Map<String, dynamic>?)?['name'] as String?;
    if (name == null || name.isEmpty) continue;
    final nodes = (way['nodes'] as List<dynamic>?) ?? const [];
    final geometry = <GeoPoint>[
      for (final node in nodes) ?points[(node as num).toInt()],
    ];
    if (geometry.length < 2) continue;
    streets.add(NamedStreet(name: name, points: geometry));
  }
  return streets;
}

/// Callejero armado desde `assets/addresses.json`, el de las alturas.
///
/// **Por qué existe además de [streetsFromOverpass].** Overpass no siempre
/// contesta —cuando este archivo se escribió devolvía 504— y el asset de
/// alturas ya viaja en el repo con 541 calles de Corrientes. No es tan bueno
/// como la geometría real de OSM: acá cada calle se reconstruye uniendo sus
/// puntos de altura, que son portales, no el eje de la calzada.
///
/// **Los puntos se ordenan por el eje dominante** (el que más se extiende,
/// norte-sur o este-oeste). Sin eso la polilínea zigzaguea entre alturas
/// desordenadas e inventa tramos que cruzan manzanas enteras. Para calles
/// urbanas, que son rectas, alcanza.
List<NamedStreet> streetsFromAddressAsset(Map<String, dynamic> json) {
  final streets = <NamedStreet>[];
  for (final entry in ((json['s'] as List<dynamic>?) ?? const [])) {
    if (entry is! List || entry.length < 3) continue;
    final name = entry[0];
    final raw = entry[2];
    if (name is! String || raw is! List) continue;

    final points = <GeoPoint>[
      for (final p in raw)
        if (p is List && p.length >= 3)
          (lat: (p[1] as num).toDouble(), lng: (p[2] as num).toDouble()),
    ];
    if (points.length < 2) continue;

    var minLat = points.first.lat, maxLat = points.first.lat;
    var minLng = points.first.lng, maxLng = points.first.lng;
    for (final p in points) {
      if (p.lat < minLat) minLat = p.lat;
      if (p.lat > maxLat) maxLat = p.lat;
      if (p.lng < minLng) minLng = p.lng;
      if (p.lng > maxLng) maxLng = p.lng;
    }
    // A esta latitud un grado de longitud mide ~0,887 de uno de latitud: se
    // compara en metros y no en grados, o las calles este-oeste se ordenan
    // por el eje equivocado.
    final spanLat = maxLat - minLat;
    final spanLng = (maxLng - minLng) * 0.887;
    points.sort(
      spanLat >= spanLng
          ? (a, b) => a.lat.compareTo(b.lat)
          : (a, b) => a.lng.compareTo(b.lng),
    );

    streets.add(NamedStreet(name: name, points: points));
  }
  return streets;
}
