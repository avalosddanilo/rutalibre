/// Unificación de los nodos de OSM que describen la MISMA parada física.
///
/// El problema: el esquema PTv2 de OpenStreetMap mapea cada parada DOS veces
/// — un `public_transport=stop_position` sobre la calzada (donde frena el
/// colectivo) y un `public_transport=platform` / `highway=bus_stop` en la
/// vereda (donde espera el pasajero). Además hay paradas mapeadas dos veces
/// por error, con nodos distintos a pocos metros.
///
/// `_collapseAdjacent` (en `importer.dart`) ya une el par DENTRO de un
/// recorrido, pero no alcanza: si la línea 3 usa el `stop_position` y la 9
/// usa el `platform` de la misma esquina, la tabla `stops` termina con dos
/// paradas separadas por 5 m. En el mapa se ven dos pines pegados; en "cerca
/// mío", la misma parada listada dos veces.
///
/// Este módulo hace el pase GLOBAL que faltaba. Dart PURO.
library;

import 'geometry.dart';

/// Distancia máxima para dar por unido un par PTv2 (`platform` en la vereda +
/// `stop_position` sobre la calzada). Es generoso a propósito: en avenidas
/// anchas la vereda queda lejos del eje de la calzada.
const ptv2RadiusMeters = 30.0;

/// Distancia máxima para unir dos nodos del MISMO rol. Acá hay que ser
/// estricto: dos paradas ENFRENTADAS (una por sentido) son dos `stop_position`
/// separados por el ancho de la calle, y unirlas sería mentir sobre en qué
/// vereda para cada línea. A 12 m no entra ninguna calle.
const sameRoleRadiusMeters = 12.0;

/// Resultado del pase de unificación.
class StopMergeResult {
  const StopMergeResult({required this.canonicalOf, required this.clusters});

  /// nodeId de OSM → nodeId que representa a su parada física.
  /// Los nodos que no se unieron a nadie se mapean a sí mismos.
  final Map<int, int> canonicalOf;

  /// canónico → todos los nodos de su parada, el canónico incluido.
  final Map<int, List<int>> clusters;

  /// Cuántos nodos dejaron de ser una parada por su cuenta.
  int get mergedAway => canonicalOf.length - clusters.length;
}

/// Une los nodos de [nodeIds] que son la misma parada física.
///
/// El representante de cada grupo es la PLATAFORMA cuando existe: es donde
/// se para la gente (la vereda), no el eje de la calzada. Así el pin del mapa
/// cae donde uno espera el colectivo. A igualdad, gana el nodo que trae
/// `name` y, como desempate determinista, el id más chico.
StopMergeResult mergeSameStops({
  required Iterable<int> nodeIds,
  required Map<int, GeoPoint> points,
  required Map<int, Map<String, String>> tags,
}) {
  final ids = [
    for (final id in nodeIds)
      if (points.containsKey(id)) id,
  ]..sort();

  final parent = {for (final id in ids) id: id};

  int find(int id) {
    var root = id;
    while (parent[root] != root) {
      root = parent[root]!;
    }
    // Compresión de camino: sin esto, cadenas largas de plataformas hacen
    // que cada consulta recorra el grupo entero.
    var cursor = id;
    while (parent[cursor] != root) {
      final next = parent[cursor]!;
      parent[cursor] = root;
      cursor = next;
    }
    return root;
  }

  void union(int a, int b) {
    final rootA = find(a);
    final rootB = find(b);
    if (rootA == rootB) return;
    // El id más chico manda: hace el resultado independiente del orden.
    if (rootA < rootB) {
      parent[rootB] = rootA;
    } else {
      parent[rootA] = rootB;
    }
  }

  // Grilla de ~55 m de lado: comparar todos contra todos serían 1500² pares.
  const cellDegrees = 0.0005;
  String cellKey(int lat, int lng) => '$lat:$lng';
  final grid = <String, List<int>>{};
  for (final id in ids) {
    final p = points[id]!;
    final key = cellKey(
      (p.lat / cellDegrees).floor(),
      (p.lng / cellDegrees).floor(),
    );
    grid.putIfAbsent(key, () => []).add(id);
  }

  for (final id in ids) {
    final p = points[id]!;
    final baseLat = (p.lat / cellDegrees).floor();
    final baseLng = (p.lng / cellDegrees).floor();
    for (var dLat = -1; dLat <= 1; dLat++) {
      for (var dLng = -1; dLng <= 1; dLng++) {
        for (final other in grid[cellKey(baseLat + dLat, baseLng + dLng)] ??
            const <int>[]) {
          if (other <= id) continue;
          if (_isSameStop(
            id,
            other,
            points: points,
            tags: tags,
          )) {
            union(id, other);
          }
        }
      }
    }
  }

  final groups = <int, List<int>>{};
  for (final id in ids) {
    groups.putIfAbsent(find(id), () => []).add(id);
  }

  final canonicalOf = <int, int>{};
  final clusters = <int, List<int>>{};
  for (final group in groups.values) {
    final canonical = _pickCanonical(group, tags);
    clusters[canonical] = group;
    for (final id in group) {
      canonicalOf[id] = canonical;
    }
  }

  return StopMergeResult(canonicalOf: canonicalOf, clusters: clusters);
}

/// True cuando [a] y [b] son dos representaciones de la misma parada.
bool _isSameStop(
  int a,
  int b, {
  required Map<int, GeoPoint> points,
  required Map<int, Map<String, String>> tags,
}) {
  final distance = haversineMeters(points[a]!, points[b]!);
  if (distance > ptv2RadiusMeters) return false;

  final tagsA = tags[a] ?? const <String, String>{};
  final tagsB = tags[b] ?? const <String, String>{};

  // Dos nodos que se pisan son el mismo poste, digan lo que digan sus tags.
  if (distance <= sameRoleRadiusMeters) return true;

  // Más lejos, solo vale la pareja PTv2 calzada + vereda.
  final isPair =
      (isPlatform(tagsA) && isStopPosition(tagsB)) ||
      (isStopPosition(tagsA) && isPlatform(tagsB));
  if (!isPair) return false;

  // Si los dos traen nombre y NO es el mismo, son dos paradas distintas que
  // quedaron cerca (una esquina con parada en las dos manos).
  final nameA = tagsA['name']?.trim().toLowerCase();
  final nameB = tagsB['name']?.trim().toLowerCase();
  if (nameA != null &&
      nameA.isNotEmpty &&
      nameB != null &&
      nameB.isNotEmpty &&
      nameA != nameB) {
    return false;
  }
  return true;
}

/// El nodo donde ESPERA el pasajero (vereda), no donde frena el colectivo.
bool isPlatform(Map<String, String> tags) =>
    tags['public_transport'] == 'platform' || tags['highway'] == 'bus_stop';

/// El punto sobre la calzada donde frena el colectivo.
bool isStopPosition(Map<String, String> tags) =>
    tags['public_transport'] == 'stop_position';

int _pickCanonical(List<int> group, Map<int, Map<String, String>> tags) {
  if (group.length == 1) return group.first;
  final ranked = [...group]..sort((a, b) {
    final tagsA = tags[a] ?? const <String, String>{};
    final tagsB = tags[b] ?? const <String, String>{};
    final byPlatform = _boolRank(isPlatform(tagsB)) - _boolRank(isPlatform(tagsA));
    if (byPlatform != 0) return byPlatform;
    final byName =
        _boolRank((tagsB['name'] ?? '').trim().isNotEmpty) -
        _boolRank((tagsA['name'] ?? '').trim().isNotEmpty);
    if (byName != 0) return byName;
    return a.compareTo(b);
  });
  return ranked.first;
}

int _boolRank(bool value) => value ? 1 : 0;
