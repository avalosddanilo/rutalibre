/// "¿Cómo llego?" sin conexión: el mismo cálculo que `plan_trip_v2`, en el
/// teléfono.
///
/// **Por qué.** El planificador corre en el servidor. Sin señal —en el
/// colectivo, en un barrio con mala cobertura, sin datos a fin de mes— no
/// había viaje, aunque el teléfono ya tuviera las líneas y las paradas.
///
/// **Cómo.** Es una traducción directa de `plan_trip_v2` tal como quedó en
/// la migración 0018, y devuelve **el mismo JSON**: la app lo parsea con el
/// mismo `TripPlanModel.fromJson` y no tiene que saber de dónde vino. Las
/// reglas son las de allá:
/// - paradas a menos de [maxWalkM] del origen y del destino;
/// - un colectivo, o dos con transbordo en la misma parada o caminando hasta
///   otra a menos de [maxTransferM];
/// - el 904 solo cruza el río (sube de un lado y baja del otro), y nunca
///   dos tramos del 904 seguidos;
/// - de cada línea (o par de líneas), la combinación más rápida, y los
///   directos primero; "minutos" = caminata doble a 80 m/min + medio minuto
///   por parada + los metros en colectivo a 27 km/h.
///
/// `tools/comparar_planificador.dart` lo corre contra el SQL sobre cientos
/// de viajes al azar: si se cambia una regla en la base, se cambia acá.
///
/// Dart puro, sin Flutter: lo usan también las herramientas.
library;

import 'dart:math' as math;

/// Una parada, con lo que el JSON del viaje necesita mostrar.
class PlannerStop {
  const PlannerStop({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    this.description,
    this.osmNodeId,
  });

  final String id;
  final String name;
  final String? description;
  final int? osmNodeId;
  final double lat;
  final double lng;
}

class PlannerLine {
  const PlannerLine({
    required this.id,
    required this.code,
    required this.name,
    required this.colorHex,
    required this.networkCode,
    required this.networkName,
  });

  final String id;
  final String code;
  final String name;
  final String? colorHex;
  final String networkCode;
  final String networkName;
}

/// Un recorrido con su secuencia de paradas, como lo da
/// `get_planner_network()` (0021).
class PlannerVariant {
  const PlannerVariant({
    required this.id,
    required this.lineId,
    required this.name,
    required this.branch,
    required this.direction,
    required this.stopIds,
    required this.distM,
  });

  final String id;
  final String lineId;
  final String name;
  final String? branch;
  final int direction;
  final List<String> stopIds;

  /// Metros desde la primera parada, uno por parada. Vacío si la base no
  /// los tenía: se estima con 224 m por parada, como el SQL.
  final List<double> distM;
}

/// La red completa, lista para planificar.
class PlannerNetwork {
  factory PlannerNetwork({
    required List<PlannerStop> stops,
    required List<PlannerLine> lines,
    required List<PlannerVariant> variants,
  }) {
    final byStop = {for (final s in stops) s.id: s};
    final byLine = {for (final l in lines) l.id: l};
    return PlannerNetwork._(byStop, byLine, [
      // Un recorrido cuya línea o alguna parada no está en el teléfono no
      // se usa: armar un viaje con un hueco es peor que no armarlo.
      for (final v in variants)
        if (byLine.containsKey(v.lineId) && v.stopIds.every(byStop.containsKey))
          v,
    ]);
  }

  PlannerNetwork._(this.stops, this.lines, this.variants) {
    for (final s in stops.values) {
      (_grid[_cell(s.lat, s.lng)] ??= []).add(s);
    }
  }

  /// Arma la red desde el JSON de `get_planner_network()` más las paradas y
  /// las líneas que el teléfono ya tiene guardadas.
  factory PlannerNetwork.fromJson(
    Map<String, dynamic> json, {
    required List<PlannerStop> stops,
    required List<PlannerLine> lines,
  }) => PlannerNetwork(
    stops: stops,
    lines: lines,
    variants: [
      for (final raw
          in (json['variants'] as List<dynamic>? ?? const [])
              .cast<Map<String, dynamic>>())
        PlannerVariant(
          id: raw['id'] as String,
          lineId: raw['line_id'] as String,
          name: raw['name'] as String,
          branch: raw['branch'] as String?,
          direction: (raw['direction'] as num).toInt(),
          stopIds: (raw['stops'] as List<dynamic>? ?? const []).cast<String>(),
          distM: [
            for (final d in (raw['dist'] as List<dynamic>? ?? const []))
              (d as num).toDouble(),
          ],
        ),
    ],
  );

  final Map<String, PlannerStop> stops;
  final Map<String, PlannerLine> lines;
  final List<PlannerVariant> variants;

  // Grilla de ~550 m para buscar paradas cerca sin recorrer las siete mil.
  static const _cellDeg = 0.005;
  final _grid = <(int, int), List<PlannerStop>>{};

  static (int, int) _cell(double lat, double lng) =>
      ((lat / _cellDeg).floor(), (lng / _cellDeg).floor());

  /// Las paradas a menos de [radiusM] del punto, con su distancia.
  Map<String, double> stopsNear(double lat, double lng, double radiusM) {
    final (cy, cx) = _cell(lat, lng);
    final reach = (radiusM / 500).ceil() + 1;
    final out = <String, double>{};
    for (var dy = -reach; dy <= reach; dy++) {
      for (var dx = -reach; dx <= reach; dx++) {
        for (final s in _grid[(cy + dy, cx + dx)] ?? const <PlannerStop>[]) {
          final d = distanceM(lat, lng, s.lat, s.lng);
          if (d <= radiusM) out[s.id] = d;
        }
      }
    }
    return out;
  }
}

/// La red del 904: cada tramo tiene que cruzar el río.
const crossRiverNetwork = 'interurbano-chaco-corrientes';

/// Al este de esto, Corrientes (la misma línea que usa el SQL, 0012).
const _riverLng = -58.86;

/// Metros entre dos puntos, sobre el elipsoide WGS84 como PostGIS.
///
/// Empezó con haversine (Tierra esférica) y difería del SQL en un 0,3 %:
/// poco, pero justo en los bordes —un transbordo de 250 m, una parada a
/// 500— cambiaba qué entra y qué no. Con los radios de curvatura del
/// elipsoide en esa latitud, para distancias de una ciudad, la diferencia
/// con PostGIS es de milímetros.
double distanceM(double lat1, double lng1, double lat2, double lng2) {
  const a = 6378137.0;
  const e2 = 0.00669437999014;
  final phi = (lat1 + lat2) / 2 * math.pi / 180;
  final sin2 = math.sin(phi) * math.sin(phi);
  final w = math.sqrt(1 - e2 * sin2);
  final meridian = a * (1 - e2) / (w * w * w);
  final primeVertical = a / w;
  final dy = (lat2 - lat1) * math.pi / 180 * meridian;
  final dx = (lng2 - lng1) * math.pi / 180 * primeVertical * math.cos(phi);
  return math.sqrt(dx * dx + dy * dy);
}

class _Leg {
  _Leg({
    required this.variant,
    required this.boardIdx,
    required this.alightIdx,
    required this.walk,
  });

  final PlannerVariant variant;
  final int boardIdx;
  final int alightIdx;

  /// La caminata del lado de afuera del tramo: hasta la parada de subida
  /// (tramo 1) o desde la de bajada (tramo 2).
  final double walk;

  int get stops => alightIdx - boardIdx;
  String get boardId => variant.stopIds[boardIdx];
  String get alightId => variant.stopIds[alightIdx];

  double get busM {
    final d = variant.distM;
    if (d.length == variant.stopIds.length) {
      return d[alightIdx] - d[boardIdx];
    }
    return stops * 224.0;
  }
}

class _Trip {
  _Trip(this.first, this.second, this.walkStart, this.walkMid, this.walkEnd);

  final _Leg first;
  final _Leg? second;
  final double walkStart;
  final double walkMid;
  final double walkEnd;
  bool showBranch1 = true;
  bool showBranch2 = true;

  int get legCount => second == null ? 1 : 2;

  /// La estimación de la 0018.
  double get minutes =>
      (walkStart + walkMid + walkEnd) / 40.0 +
      (first.stops + (second?.stops ?? 0)) * 0.5 +
      (first.busM + (second?.busM ?? 0)) / 450.0;
}

/// Los viajes de [originLat],[originLng] a [destLat],[destLng], como el JSON
/// de `plan_trip_v2`.
List<Map<String, dynamic>> planTripOffline(
  PlannerNetwork net, {
  required double originLat,
  required double originLng,
  required double destLat,
  required double destLng,
  double maxWalkM = 500,
  int maxResults = 6,
  double maxTransferM = 250,
}) {
  final o = net.stopsNear(originLat, originLng, maxWalkM);
  final d = net.stopsNear(destLat, destLng, maxWalkM);
  if (o.isEmpty || d.isEmpty) return const [];

  bool crosses(PlannerVariant v) =>
      net.lines[v.lineId]!.networkCode == crossRiverNetwork;
  bool sameBank(String a, String b) =>
      (net.stops[a]!.lng > _riverLng) == (net.stops[b]!.lng > _riverLng);

  // --- Tramo 1: subir cerca del origen. De cada (recorrido, parada de
  // bajada), la subida más cerca del origen y, a igual caminata, la más
  // avanzada.
  final leg1 = <(String, String), _Leg>{};
  // --- Tramo 2: bajar cerca del destino. De cada (recorrido, parada de
  // subida), la bajada más cerca del destino y, a igual caminata, la
  // primera.
  final leg2 = <(String, String), _Leg>{};

  for (final v in net.variants) {
    final ids = v.stopIds;
    final cross = crosses(v);
    for (var i = 0; i < ids.length; i++) {
      final walk = o[ids[i]];
      if (walk == null) continue;
      for (var j = i + 1; j < ids.length; j++) {
        if (cross && sameBank(ids[i], ids[j])) continue;
        final key = (v.id, ids[j]);
        final prev = leg1[key];
        if (prev == null ||
            walk < prev.walk ||
            (walk == prev.walk && i > prev.boardIdx)) {
          leg1[key] = _Leg(variant: v, boardIdx: i, alightIdx: j, walk: walk);
        }
      }
    }
    for (var j = 0; j < ids.length; j++) {
      final walk = d[ids[j]];
      if (walk == null) continue;
      for (var i = 0; i < j; i++) {
        if (cross && sameBank(ids[i], ids[j])) continue;
        final key = (v.id, ids[i]);
        final prev = leg2[key];
        if (prev == null ||
            walk < prev.walk ||
            (walk == prev.walk && j < prev.alightIdx)) {
          leg2[key] = _Leg(variant: v, boardIdx: i, alightIdx: j, walk: walk);
        }
      }
    }
  }

  // --- Un solo colectivo: de cada línea, el recorrido más rápido.
  final directByLine = <String, _Trip>{};
  final directVariants = <String, Set<String>>{};
  for (final l in leg1.values) {
    final walkEnd = d[l.alightId];
    if (walkEnd == null) continue;
    final line = l.variant.lineId;
    (directVariants[line] ??= {}).add(l.variant.id);
    final trip = _Trip(l, null, l.walk, 0, walkEnd);
    final best = directByLine[line];
    if (best == null || trip.minutes < best.minutes) directByLine[line] = trip;
  }
  for (final MapEntry(key: line, value: t) in directByLine.entries) {
    t.showBranch1 = directVariants[line]!.length == 1;
  }

  // --- Un transbordo, en la misma parada o caminando.
  final leg2ByBoard = <String, List<_Leg>>{};
  for (final l in leg2.values) {
    (leg2ByBoard[l.boardId] ??= []).add(l);
  }
  final leg1ByAlight = <String, List<_Leg>>{};
  for (final l in leg1.values) {
    (leg1ByAlight[l.alightId] ??= []).add(l);
  }
  final transferByPair = <(String, String), _Trip>{};
  final pairV1 = <(String, String), Set<String>>{};
  final pairV2 = <(String, String), Set<String>>{};
  for (final MapEntry(key: offId, value: firsts) in leg1ByAlight.entries) {
    final off = net.stops[offId]!;
    final near = net.stopsNear(off.lat, off.lng, maxTransferM);
    for (final MapEntry(key: onId, value: walkMid) in near.entries) {
      final seconds = leg2ByBoard[onId];
      if (seconds == null) continue;
      for (final a in firsts) {
        for (final b in seconds) {
          final lineA = a.variant.lineId;
          final lineB = b.variant.lineId;
          if (lineA == lineB) continue;
          // Dos tramos del 904 son cruzar el río y volver.
          if (crosses(a.variant) && crosses(b.variant)) continue;
          final pair = (lineA, lineB);
          (pairV1[pair] ??= {}).add(a.variant.id);
          (pairV2[pair] ??= {}).add(b.variant.id);
          final trip = _Trip(a, b, a.walk, walkMid, b.walk);
          final best = transferByPair[pair];
          if (best == null || trip.minutes < best.minutes) {
            transferByPair[pair] = trip;
          }
        }
      }
    }
  }
  for (final MapEntry(key: pair, value: t) in transferByPair.entries) {
    t.showBranch1 = pairV1[pair]!.length == 1;
    t.showBranch2 = pairV2[pair]!.length == 1;
  }

  final ranked = [...directByLine.values, ...transferByPair.values]
    ..sort((a, b) {
      final c = a.legCount.compareTo(b.legCount);
      return c != 0 ? c : a.minutes.compareTo(b.minutes);
    });

  return [
    for (final t in ranked.take(maxResults))
      {
        'leg_count': t.legCount,
        'walk_to_board_m': t.walkStart.round(),
        'walk_from_alight_m': t.walkEnd.round(),
        'transfer_walk_m': t.walkMid.round(),
        'walk_total_m':
            t.walkStart.round() + t.walkMid.round() + t.walkEnd.round(),
        'legs': [
          _legJson(net, t.first, t.showBranch1),
          if (t.second case final second?) _legJson(net, second, t.showBranch2),
        ],
      },
  ];
}

Map<String, dynamic> _legJson(PlannerNetwork net, _Leg leg, bool showBranch) {
  final v = leg.variant;
  final line = net.lines[v.lineId]!;
  Map<String, dynamic> stop(String id) {
    final s = net.stops[id]!;
    return {
      'id': s.id,
      'name': s.name,
      'description': s.description,
      'osm_node_id': s.osmNodeId,
      'lat': s.lat,
      'lng': s.lng,
    };
  }

  return {
    'line_id': line.id,
    'line_code': line.code,
    'line_name': line.name,
    'color_hex': line.colorHex,
    'network_code': line.networkCode,
    'network_name': line.networkName,
    'route_variant_id': v.id,
    'variant_name': v.name,
    'branch': showBranch ? v.branch : null,
    'direction': v.direction,
    'stop_count': leg.stops,
    'board_stop': stop(leg.boardId),
    'alight_stop': stop(leg.alightId),
  };
}
