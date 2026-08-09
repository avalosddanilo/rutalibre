/// Orquestación del import: de elementos crudos de OSM al modelo listo
/// para SQL. Sin red y sin archivos — recibe los elementos ya parseados,
/// así que es completamente testeable.
library;

import 'geometry.dart';
import 'import_model.dart';
import 'line_palette.dart';
import 'route_parser.dart';
import 'stop_merge.dart';
import 'stop_naming.dart';

/// Dos nodos a menos de esta distancia son la MISMA parada física.
/// En el esquema PTv2 de OSM cada parada aparece dos veces (el
/// `stop_position` sobre la calzada y el `platform` en la vereda);
/// sin este umbral cada parada entraría duplicada al recorrido.
const _samePlatformMeters = 40.0;

/// Tolerancia de simplificación del trazado. A 5 m no hay diferencia
/// visible a escala urbana y el SQL baja a un tercio.
const _simplifyToleranceMeters = 5.0;

/// Un salto mayor a esto merece que alguien mire el recorrido en OSM.
const _reportableGapMeters = 100.0;

/// Elementos de OSM que necesita el importer, ya normalizados.
class OsmInput {
  const OsmInput({
    required this.relations,
    required this.wayNodes,
    required this.nodePoints,
    required this.nodeTags,
    this.streets = const [],
  });

  /// Relations `route=bus` con sus tags y su lista de miembros.
  final List<OsmRelation> relations;

  /// wayId → nodos que lo componen, en orden.
  final Map<int, List<int>> wayNodes;

  /// nodeId → coordenada.
  final Map<int, GeoPoint> nodePoints;

  /// nodeId → tags (solo hace falta de los nodos de parada).
  final Map<int, Map<String, String>> nodeTags;

  /// Callejero con nombre, para bautizar las paradas que en OSM solo traen
  /// el código interno de la concesionaria. Vacío = se deja el código.
  final List<NamedStreet> streets;
}

class OsmRelation {
  const OsmRelation({
    required this.id,
    required this.tags,
    required this.members,
  });

  final int id;
  final Map<String, String> tags;
  final List<OsmMember> members;
}

class OsmMember {
  const OsmMember({required this.type, required this.ref, required this.role});

  final String type;
  final int ref;
  final String role;
}

/// Convierte los datos de OSM en líneas, recorridos y paradas.
ImportResult buildImport(OsmInput input) {
  final warnings = <String>[];
  final skipped = <String>[];
  final gapReport = <String>[];

  final parsedRoutes = <(OsmRelation, ParsedRoute)>[];

  for (final relation in input.relations) {
    final ref = relation.tags['ref'];
    final name = relation.tags['name'];

    // Sin `ref` no hay línea que identificar. En el Gran Resistencia esto
    // deja afuera exactamente a los micros de LARGA DISTANCIA (Corrientes–
    // Paso de los Libres, Buenos Aires–Corrientes...), que no son
    // transporte urbano y no van en esta app.
    if (ref == null || ref.trim().isEmpty) {
      skipped.add(
        'relation ${relation.id} sin ref — "${name ?? 'sin nombre'}" '
        '(larga distancia o mapeo incompleto)',
      );
      continue;
    }

    final parsed = parseRoute(
      osmRelationId: relation.id,
      ref: ref,
      name: name,
      fromTag: relation.tags['from'],
      toTag: relation.tags['to'],
    );
    warnings.addAll(parsed.warnings);

    if (parsed.lineCode.isEmpty) {
      skipped.add('relation ${relation.id}: ref="$ref" no da un código usable');
      continue;
    }
    parsedRoutes.add((relation, parsed));
  }

  // --- Recorridos: geometría + paradas ---
  final variants = <ImportedVariant>[];
  final usedStopIds = <int>{};

  /// Todo lo que compitió por un lugar, incluido lo que el colapsado por
  /// recorrido descartó: la unificación global los necesita para juntar el
  /// nombre de la plataforma con el código de la posición de detención.
  final candidateStopIds = <int>{};
  final stopGrid = _StopGrid.of(input);
  var declaredTotal = 0;
  var inferredTotal = 0;

  for (final (relation, parsed) in parsedRoutes) {
    final ways = <WaySegment>[];
    for (final member in relation.members) {
      if (member.type != 'way' || member.role.isNotEmpty) continue;
      final nodes = input.wayNodes[member.ref];
      if (nodes != null) ways.add(WaySegment(nodes));
    }

    final stitched = stitchWays(ways, input.nodePoints);
    if (stitched.points.length < 2) {
      skipped.add(
        'relation ${relation.id} (${parsed.lineCode}${parsed.branch ?? ''}): '
        'sin geometría utilizable',
      );
      continue;
    }

    final bigGaps = stitched.gaps
        .where((g) => g > _reportableGapMeters)
        .toList();
    if (bigGaps.isNotEmpty) {
      final worst = bigGaps.reduce((a, b) => a > b ? a : b).round();
      gapReport.add(
        '${parsed.lineCode}${parsed.branch ?? ''} '
        '(relation ${relation.id}): ${bigGaps.length} salto(s) puenteados, '
        'el mayor de $worst m — conviene revisar el trazado en OSM',
      );
    }

    final geometry = simplify(stitched.points, _simplifyToleranceMeters);
    // Se proyecta contra el trazado SIN simplificar: más vértices, mejor
    // precisión al ubicar cada parada sobre el recorrido.
    final declaredIds = _declaredStops(relation, input);
    final resolved = _orderedStops(relation, input, stitched.points, stopGrid);
    final stopIds = resolved.ordered;
    usedStopIds.addAll(stopIds);
    candidateStopIds.addAll(resolved.candidates);
    declaredTotal += declaredIds.length;
    inferredTotal += stopIds.where((id) => !declaredIds.contains(id)).length;

    // En el interurbano el ramal se promueve a línea (ver `lineIdentityFor`),
    // así que la identidad se resuelve acá y no al leer el `ref`: el parser
    // reporta lo que dice OSM y esta es una decisión de producto.
    final identity = lineIdentityFor(parsed.lineCode, parsed.branch);

    variants.add(
      ImportedVariant(
        osmRelationId: relation.id,
        networkCode: networkCodeFor(parsed.lineCode),
        lineCode: identity.lineCode,
        branch: identity.branch,
        // Provisorio: los nulls se resuelven abajo, cuando se ven los dos
        // recorridos de la misma línea juntos.
        direction: parsed.direction?.dbValue ?? -1,
        name: parsed.variantName,
        geometry: geometry,
        stopOsmIds: stopIds,
      ),
    );
  }

  // --- Una parada física, un solo registro ---
  //
  // El colapsado de `_orderedStops` es POR RECORRIDO: si la 3 usa el
  // `stop_position` de una esquina y la 9 usa el `platform`, las dos
  // sobreviven y la esquina queda con dos paradas a metros una de la otra.
  // Este pase las une mirando el dataset ENTERO y reescribe las secuencias.
  final merge = mergeSameStops(
    nodeIds: candidateStopIds,
    points: input.nodePoints,
    tags: input.nodeTags,
  );
  if (inferredTotal > 0) {
    warnings.add(
      '$inferredTotal asignaciones parada↔recorrido se INFIRIERON de la '
      'geometría (el trazado pasa a menos de ${_inferredMaxOffsetMeters.round()} m '
      'y la deja a su derecha); OSM declaraba $declaredTotal. Es lo que '
      'arregla que la 110 y la 204 no figuraran en paradas de Avenida San '
      'Martín donde sí frenan',
    );
  }
  if (merge.mergedAway > 0) {
    warnings.add(
      '${merge.mergedAway} nodos de OSM eran una segunda representación de '
      'una parada ya existente (plataforma + posición de detención, o la '
      'misma parada mapeada dos veces) y se unificaron',
    );
  }
  usedStopIds
    ..clear()
    ..addAll(_remapStopSequences(variants, merge));

  _resolveDirections(variants, warnings);
  _disambiguateNames(variants);

  // --- Líneas ---
  final lines = _buildLines(variants, parsedRoutes);

  // --- Paradas efectivamente usadas por algún recorrido ---
  //
  // Prioridad del nombre: el de OSM si existe → la esquina derivada del
  // callejero → el código interno de la concesionaria como último recurso.
  // El código nunca se pierde: si no es el nombre, queda en description.
  final streetIndex = input.streets.isEmpty ? null : StreetIndex(input.streets);
  var derivedNames = 0;
  final stops = <ImportedStop>[];
  for (final nodeId in usedStopIds) {
    final point = input.nodePoints[nodeId];
    if (point == null) continue;
    // Se miran los tags del grupo unificado ENTERO, no solo los del nodo
    // elegido: en PTv2 el nombre suele estar en la plataforma y el código
    // de la concesionaria en la posición de detención. Quedarse con uno
    // solo perdía la mitad de la información.
    final name = _firstTag(merge, nodeId, input, 'name');
    final ref = _firstTag(merge, nodeId, input, 'ref');
    final fallbackCode = (ref != null && ref.isNotEmpty) ? 'Parada $ref' : null;

    String resolvedName;
    String? description;
    if (name != null && name.isNotEmpty) {
      resolvedName = name;
      description = fallbackCode;
    } else {
      final derived = streetIndex == null
          ? null
          : deriveStopName(point, streetIndex);
      if (derived != null) {
        resolvedName = derived;
        description = fallbackCode;
        derivedNames++;
      } else {
        resolvedName = fallbackCode ?? 'Parada sin nombre';
        description = null;
      }
    }

    stops.add(
      ImportedStop(
        osmNodeId: nodeId,
        name: resolvedName,
        description: description,
        point: point,
      ),
    );
  }
  if (derivedNames > 0) {
    warnings.add(
      '$derivedNames paradas sin nombre en OSM fueron bautizadas '
      'con la esquina más cercana del callejero',
    );
  }
  stops.sort((a, b) => a.osmNodeId.compareTo(b.osmNodeId));

  return ImportResult(
    lines: lines,
    variants: variants,
    stops: stops,
    warnings: warnings,
    skipped: skipped,
    gapReport: gapReport,
  );
}

/// Reescribe la secuencia de paradas de cada recorrido con los nodos
/// canónicos y devuelve el conjunto de paradas que quedan en uso.
///
/// La deduplicación es sobre TODA la secuencia y no solo entre vecinas: al
/// unificar, un recorrido que traía la plataforma y la posición de detención
/// separadas por otra parada termina con el mismo canónico dos veces, y
/// `route_stops` tiene `unique (route_variant_id, stop_id)`.
Set<int> _remapStopSequences(
  List<ImportedVariant> variants,
  StopMergeResult merge,
) {
  final inUse = <int>{};
  for (final variant in variants) {
    final remapped = <int>[];
    final seen = <int>{};
    for (final nodeId in variant.stopOsmIds) {
      final canonical = merge.canonicalOf[nodeId] ?? nodeId;
      if (seen.add(canonical)) remapped.add(canonical);
    }
    variant.stopOsmIds = remapped;
    inUse.addAll(remapped);
  }
  return inUse;
}

/// Primer valor no vacío de [key] entre los nodos unificados bajo [nodeId].
/// El canónico tiene prioridad; después, el resto en orden de id.
String? _firstTag(
  StopMergeResult merge,
  int nodeId,
  OsmInput input,
  String key,
) {
  final cluster = merge.clusters[nodeId] ?? [nodeId];
  for (final candidate in [nodeId, ...cluster]) {
    final value = input.nodeTags[candidate]?[key]?.trim();
    if (value != null && value.isNotEmpty) return value;
  }
  return null;
}

/// Paradas de un recorrido en orden de paso, sin duplicados.
///
/// NO se usa el orden en que la relation lista sus miembros: en los datos
/// reales del Gran Resistencia ese orden viene en BLOQUES (todas las
/// plataformas y después todas las posiciones de detención), no en orden de
/// recorrido. Tomarlo literal dejaba 41 de 64 secuencias yendo y viniendo,
/// con saltos de hasta 11 km entre paradas "consecutivas".
///
/// En su lugar cada parada se PROYECTA sobre el trazado ya cosido y se
/// ordena por cuánto se avanzó sobre él. Eso además colapsa solo el par
/// `stop_position` + `platform` de una misma parada física, que caen
/// prácticamente en el mismo punto del trazado.
///
/// [geometry] es el trazado del recorrido. Si viene vacío no hay contra qué
/// proyectar y se cae al orden de los miembros, que es lo único que queda.
/// Cuán cerca del trazado tiene que caer una parada que la relation NO
/// declaró para adoptarla igual. Corto a propósito: 25 m es la vereda, no la
/// otra cuadra.
const _inferredMaxOffsetMeters = 25.0;

/// Cuánto se tolera hacia la IZQUIERDA del sentido de marcha.
///
/// En Argentina se maneja por la derecha, así que un colectivo levanta gente
/// de su lado derecho ([Projection.sideMeters] negativo). El margen positivo
/// existe porque los nodos `stop_position` están mapeados SOBRE la calzada
/// (lado ≈ 0) y porque una avenida angosta no da 8 m de error. Lo que este
/// número corta es la parada de ENFRENTE, que le sirve al recorrido que va
/// en contramano y no a este.
const _inferredMaxLeftMeters = 8.0;

/// Las paradas del recorrido, en orden de paso.
///
/// Dos fuentes, y la segunda es la que arregla el problema real:
///
/// 1. Las que la relation de OSM DECLARA como miembros. Es lo único que se
///    usaba, y depende de que el mapeador se haya tomado el trabajo de
///    agregar cada nodo de parada a cada relation. Muchas veces no pasó: la
///    110 y la 204 pasan por Avenida San Martín y no figuraban en paradas
///    donde el 206 y el 207 sí, aunque los cuatro frenan ahí.
///
/// 2. Las que el trazado PASA POR AL LADO. Si el recorrido va a menos de
///    [_inferredMaxOffsetMeters] de una parada y la deja a su derecha, es
///    muchísimo más probable que pare que lo contrario. El error posible
///    —mostrar una línea que pasa de largo— es mucho más barato que el que
///    hay hoy: no mostrar la línea que la persona efectivamente se toma.
///
/// Lo que NO hace: inventar paradas. Solo usa nodos que ya existen en OSM.
/// Devuelve además los CANDIDATOS previos al colapsado. No es un detalle:
/// el colapsado por recorrido se queda con uno de los dos nodos de una
/// parada (plataforma / posición de detención) y el otro desaparece — pero
/// el nombre suele estar en uno y el código de la concesionaria en el otro.
/// La unificación global necesita ver los dos para no perder la mitad.
({List<int> ordered, List<int> candidates}) _orderedStops(
  OsmRelation relation,
  OsmInput input,
  List<GeoPoint> geometry,
  _StopGrid grid,
) {
  final declared = _declaredStops(relation, input);

  if (geometry.length < 2) {
    return (ordered: _collapseAdjacent(declared, input), candidates: declared);
  }

  // Se descartan las declaradas que caen lejísimos del trazado: son errores
  // de tagueo, y colarlas inventaría una secuencia que no existe.
  const maxDeclaredOffsetMeters = 250.0;
  final projected = <({int nodeId, Projection at})>[];
  final seen = <int>{};
  for (final nodeId in declared) {
    final at = projectOntoLine(input.nodePoints[nodeId]!, geometry);
    if (at.offsetMeters <= maxDeclaredOffsetMeters) {
      projected.add((nodeId: nodeId, at: at));
      seen.add(nodeId);
    }
  }

  for (final nodeId in grid.near(geometry)) {
    if (seen.contains(nodeId)) continue;
    final at = projectOntoLine(input.nodePoints[nodeId]!, geometry);
    if (at.offsetMeters > _inferredMaxOffsetMeters) continue;
    if (at.sideMeters > _inferredMaxLeftMeters) continue;
    projected.add((nodeId: nodeId, at: at));
    seen.add(nodeId);
  }

  if (projected.isEmpty) {
    return (ordered: _collapseAdjacent(declared, input), candidates: declared);
  }

  projected.sort((a, b) => a.at.alongMeters.compareTo(b.at.alongMeters));
  final ordered = [for (final p in projected) p.nodeId];
  return (ordered: _collapseAdjacent(ordered, input), candidates: ordered);
}

/// Las paradas que la relation de OSM lista como miembros, sin repetir.
List<int> _declaredStops(OsmRelation relation, OsmInput input) {
  final declared = <int>[];
  for (final member in relation.members) {
    if (member.type != 'node') continue;
    if (member.role != 'stop' && !member.role.startsWith('platform')) continue;
    if (!input.nodePoints.containsKey(member.ref)) continue;
    if (!declared.contains(member.ref)) declared.add(member.ref);
  }
  return declared;
}

/// Índice espacial grosero de las paradas conocidas.
///
/// Sin esto habría que proyectar cada parada del área contra cada uno de los
/// 73 recorridos: decenas de millones de operaciones para descartar casi
/// todo. Con celdas de ~200 m alcanza con mirar las 9 vecinas de cada
/// vértice del trazado.
class _StopGrid {
  _StopGrid._(this._cells, this._points);

  /// ~200 m a esta latitud.
  static const _cellDegrees = 0.002;

  final Map<(int, int), List<int>> _cells;
  final Map<int, GeoPoint> _points;

  factory _StopGrid.of(OsmInput input) {
    final cells = <(int, int), List<int>>{};
    final points = <int, GeoPoint>{};
    for (final entry in input.nodeTags.entries) {
      if (!_isStopNode(entry.value)) continue;
      final point = input.nodePoints[entry.key];
      if (point == null) continue;
      points[entry.key] = point;
      cells.putIfAbsent(_cellOf(point), () => []).add(entry.key);
    }
    return _StopGrid._(cells, points);
  }

  static bool _isStopNode(Map<String, String> tags) =>
      tags['highway'] == 'bus_stop' ||
      tags['public_transport'] == 'platform' ||
      tags['public_transport'] == 'stop_position';

  static (int, int) _cellOf(GeoPoint p) =>
      ((p.lat / _cellDegrees).floor(), (p.lng / _cellDegrees).floor());

  /// Paradas candidatas cerca de [line], sin repetir.
  Set<int> near(List<GeoPoint> line) {
    final found = <int>{};
    for (final point in line) {
      final (cellLat, cellLng) = _cellOf(point);
      for (var dLat = -1; dLat <= 1; dLat++) {
        for (var dLng = -1; dLng <= 1; dLng++) {
          found.addAll(_cells[(cellLat + dLat, cellLng + dLng)] ?? const []);
        }
      }
    }
    return found;
  }

  bool contains(int nodeId) => _points.containsKey(nodeId);
}

/// Colapsa paradas consecutivas que son la misma parada física (el par
/// `stop_position` + `platform` de PTv2) y descarta repeticiones: la tabla
/// `route_stops` tiene `unique (route_variant_id, stop_id)` y un recorrido
/// circular pasa dos veces por la cabecera.
List<int> _collapseAdjacent(List<int> nodeIds, OsmInput input) {
  final collapsed = <int>[];
  for (final nodeId in nodeIds) {
    if (collapsed.isEmpty) {
      collapsed.add(nodeId);
      continue;
    }
    final previous = collapsed.last;
    final a = input.nodePoints[previous]!;
    final b = input.nodePoints[nodeId]!;
    if (haversineMeters(a, b) <= _samePlatformMeters) {
      // Misma parada física: quedarse con la que tenga nombre.
      final previousNamed =
          (input.nodeTags[previous]?['name'] ?? '').isNotEmpty;
      final currentNamed = (input.nodeTags[nodeId]?['name'] ?? '').isNotEmpty;
      if (currentNamed && !previousNamed) {
        collapsed[collapsed.length - 1] = nodeId;
      }
      continue;
    }
    collapsed.add(nodeId);
  }

  final seen = <int>{};
  return collapsed.where(seen.add).toList();
}

/// Asigna ida/vuelta a los recorridos cuyo sentido no venía en los datos.
///
/// Regla: dentro de una misma (línea, ramal), si un recorrido ya tomó la
/// ida, el que queda es la vuelta. Es determinista porque los recorridos
/// llegan ordenados por id de relation.
void _resolveDirections(List<ImportedVariant> variants, List<String> warnings) {
  final byGroup = <String, List<ImportedVariant>>{};
  for (final variant in variants) {
    final key =
        '${variant.networkCode}/${variant.lineCode}/${variant.branch ?? ''}';
    byGroup.putIfAbsent(key, () => []).add(variant);
  }

  for (final entry in byGroup.entries) {
    final group = entry.value
      ..sort((a, b) => a.osmRelationId.compareTo(b.osmRelationId));

    // Dos recorridos del mismo ramal declarando el MISMO sentido es un error
    // de tagueo: chocarían contra `unique (line, ramal, sentido)` y tumbarían
    // la carga entera. Se conserva el primero y se manda el resto al sentido
    // libre, avisando.
    final declared = <int, ImportedVariant>{};
    for (final variant in group) {
      if (variant.direction < 0) continue;
      final previous = declared[variant.direction];
      if (previous == null) {
        declared[variant.direction] = variant;
        continue;
      }
      warnings.add(
        'relation ${variant.osmRelationId} (${variant.lineCode}'
        '${variant.branch ?? ''}): declara el mismo sentido que la relation '
        '${previous.osmRelationId} — se reasigna por descarte',
      );
      variant.direction = -1;
    }

    final taken = declared.keys.toSet();

    for (final variant in group) {
      if (variant.direction >= 0) continue;
      final free = taken.contains(0) ? (taken.contains(1) ? -1 : 1) : 0;
      if (free < 0) {
        // Los dos sentidos ocupados: sin sentido libre, se deja en ida y el
        // emisor de SQL descartará el duplicado.
        variant.direction = 0;
        warnings.add(
          'relation ${variant.osmRelationId} (${variant.lineCode}'
          '${variant.branch ?? ''}): no se pudo determinar el sentido y los '
          'dos sentidos ya estaban ocupados',
        );
        continue;
      }
      variant.direction = free;
      taken.add(free);
      variant.name = _withDirectionLabel(variant.name, free);
      warnings.add(
        'relation ${variant.osmRelationId} (${variant.lineCode}'
        '${variant.branch ?? ''}): sentido no declarado en OSM, se asignó '
        '${free == 0 ? 'ida' : 'vuelta'} por descarte',
      );
    }
  }
}

/// Agrega el ramal al nombre de los recorridos que, dentro de una línea,
/// quedaron llamándose igual.
///
/// Pasa de verdad: los tres ramales de la línea 2 tienen el mismo `from`/`to`
/// en OSM, así que los tres se llaman "Ida: Carpincho Macho → Villa
/// Prosperidad". En la lista de recorridos serían tres entradas idénticas y
/// el pasajero no podría elegir.
///
/// Solo se toca lo ambiguo: donde el nombre ya distingue, se deja limpio.
void _disambiguateNames(List<ImportedVariant> variants) {
  final byName = <String, List<ImportedVariant>>{};
  for (final variant in variants) {
    final key = '${variant.networkCode}/${variant.lineCode}/${variant.name}';
    byName.putIfAbsent(key, () => []).add(variant);
  }

  for (final group in byName.values) {
    if (group.length < 2) continue;
    for (final variant in group) {
      final branch = variant.branch;
      if (branch == null || branch.isEmpty) continue;
      variant.name = '${variant.name} (ramal $branch)';
    }
  }
}

/// Antepone "Ida:"/"Vuelta:" a un nombre que no lo trae.
///
/// El nombre se arma en `parseRoute`, ANTES de saber el sentido de los
/// recorridos que no lo declaran. Sin esto los dos recorridos de un ramal
/// quedan con el mismo texto y violan `unique (line_id, name)`.
String _withDirectionLabel(String name, int direction) {
  if (RegExp(r'^(ida|vuelta)\b', caseSensitive: false).hasMatch(name)) {
    return name;
  }
  return '${direction == 0 ? 'Ida' : 'Vuelta'}: $name';
}

/// Una línea por (red, código), con nombre derivado de sus cabeceras.
List<ImportedLine> _buildLines(
  List<ImportedVariant> variants,
  List<(OsmRelation, ParsedRoute)> parsedRoutes,
) {
  final parsedByRelation = {
    for (final (_, parsed) in parsedRoutes) parsed.osmRelationId: parsed,
  };

  final lines = <String, ImportedLine>{};
  final endpointsByLine = <String, List<String>>{};
  // Para las líneas que no declaran cabecera ni destino en OSM: el 904B y el
  // 904C no tienen `from`/`to`, solo un `name` ("Chaco - Corrientes directo")
  // que es justamente lo que las distingue. Sin esto quedaban como
  // "Línea 904B", que no le dice nada a nadie.
  final fallbackNamesByLine = <String, List<String>>{};

  for (final variant in variants) {
    final line = lines.putIfAbsent(
      '${variant.networkCode}/${variant.lineCode}',
      () => ImportedLine(
        networkCode: variant.networkCode,
        code: variant.lineCode,
        name: 'Línea ${variant.lineCode}',
        colorHex: colorForLine(variant.lineCode),
        sortOrder: sortOrderFor(variant.lineCode),
      ),
    );

    final parsed = parsedByRelation[variant.osmRelationId];
    if (parsed == null) continue;
    fallbackNamesByLine
        .putIfAbsent(line.key, () => [])
        .add(_withoutDirectionPrefix(parsed.variantName));
    // Los DOS sentidos aportan: la vuelta trae los mismos extremos al revés,
    // y hay recorridos (la 101) donde solo uno de los dos los declara.
    for (final endpoint in [parsed.origin, parsed.destination]) {
      if (endpoint != null && endpoint.trim().isNotEmpty) {
        endpointsByLine.putIfAbsent(line.key, () => []).add(endpoint.trim());
      }
    }
  }

  for (final line in lines.values) {
    final endpoints = endpointsByLine[line.key] ?? const <String>[];
    final naming = _lineNamingFrom(endpoints);
    if (naming != null) {
      line.name = naming.name;
      line.destinations = naming.destinations;
      continue;
    }
    final fallback = _mostCommon(fallbackNamesByLine[line.key] ?? const []);
    if (fallback != null) {
      line.name = fallback;
      line.destinations = [fallback];
    }
  }

  // Al final, y pisando lo derivado: acá el nombre de OSM es peor que el que
  // usa el pasajero. Ver `_corridorNames`.
  for (final line in lines.values) {
    final override = _corridorNames[line.key];
    if (override == null) continue;
    line.name = override.name;
    line.destinations = [
      ...override.aliases,
      for (final destination in line.destinations)
        if (!override.aliases.contains(destination)) destination,
    ];
  }

  final result = lines.values.toList()
    ..sort((a, b) {
      final byNetwork = a.networkCode.compareTo(b.networkCode);
      if (byNetwork != 0) return byNetwork;
      return a.sortOrder.compareTo(b.sortOrder);
    });
  return result;
}

/// Nombre de la línea a partir de todas sus cabeceras y destinos, MÁS la
/// lista completa de esos destinos.
///
/// La idea del nombre: el extremo que más se repite es el TRONCO de la línea
/// (todos los ramales salen de ahí) y el resto son los destinos que la
/// distinguen. Resultado: "Barrio Vial ↔ Shopping Sarmiento / Los Troncos".
///
/// Y por qué además se devuelve la lista COMPLETA: el nombre entra en un
/// renglón, así que a partir del tercer destino dice "y N más". Guardando
/// solo eso, esos destinos dejaban de existir para la app — buscar
/// "Sarmiento" no encontraba la línea 3 aunque su ramal A termina en el
/// Shopping Sarmiento. Truncar es una decisión de PANTALLA; la base guarda
/// todo y la pantalla decide cuánto muestra.
({String name, List<String> destinations})? _lineNamingFrom(
  List<String> endpoints,
) {
  final counts = <String, int>{};
  final display = <String, Map<String, int>>{};
  for (final raw in endpoints) {
    final key = _canonicalEndpoint(raw);
    if (key.isEmpty) continue;
    counts[key] = (counts[key] ?? 0) + 1;
    final forms = display.putIfAbsent(key, () => {});
    forms[raw] = (forms[raw] ?? 0) + 1;
  }
  if (counts.isEmpty) return null;

  /// De todas las formas en que se escribió un mismo lugar ("UOM",
  /// "Barrio UOM"), se muestra la más usada; a igualdad, la más descriptiva.
  String bestForm(String key) {
    final forms = display[key]!.entries.toList()
      ..sort((a, b) {
        final byCount = b.value.compareTo(a.value);
        if (byCount != 0) return byCount;
        return b.key.length.compareTo(a.key.length);
      });
    return forms.first.key;
  }

  final ranked = counts.keys.toList()
    ..sort((a, b) {
      final byCount = counts[b]!.compareTo(counts[a]!);
      if (byCount != 0) return byCount;
      return a.compareTo(b);
    });

  final trunk = bestForm(ranked.first);
  final others = ranked.skip(1).map(bestForm).toList();
  // El tronco va primero: es la cabecera de la que salen todos los ramales.
  final destinations = [trunk, ...others];
  if (others.isEmpty) return (name: trunk, destinations: destinations);

  // Se muestran hasta dos destinos, y uno solo si el nombre se va de largo:
  // en la lista de líneas esto entra en un renglón.
  for (final shownCount in [2, 1]) {
    final shown = others.take(shownCount).join(' / ');
    final rest = others.length - shownCount;
    final name = rest > 0 ? '$trunk ↔ $shown y $rest más' : '$trunk ↔ $shown';
    if (name.length <= 58 || shownCount == 1) {
      return (name: name, destinations: destinations);
    }
  }
  return (name: trunk, destinations: destinations);
}

/// Cómo llama LA GENTE a los servicios del corredor Chaco ↔ Corrientes.
///
/// En OSM los nombres están puestos desde la óptica del mapeador: el 904B es
/// "Chaco - Corrientes directo". Nadie lo pide así. Le dicen "el Sarmiento",
/// porque hace toda la traza por Avenida Sarmiento, y al 904C "el
/// Barranqueras" porque entra a Barranqueras.
///
/// No es una suposición, se midió contra el callejero de OSM:
///
/// | recorrido | vértices a <25 m de Av. Sarmiento | al centro de Barranqueras |
/// |-----------|----------------------------------|---------------------------|
/// | 904B      | 117 de 487                       | 5,44 km                   |
/// | 904C      | 0 de 417                         | 0,46 km                   |
///
/// O sea: van por lados distintos y cada apodo cae en uno solo. El 904A es
/// el del Campus de la UNNE y es el que la gente llama "el 904" a secas.
///
/// Los apodos se agregan a `destinations` además de al nombre: son el término
/// con el que se va a buscar, y el buscador mira esa lista.
const _corridorNames = <String, ({String name, List<String> aliases})>{
  'interurbano-chaco-corrientes/904A': (
    name: 'Chaco ↔ Corrientes por el Campus de la UNNE',
    aliases: ['904', 'Campus UNNE', 'Terminal de Ómnibus Resistencia'],
  ),
  'interurbano-chaco-corrientes/904B': (
    name: 'Chaco ↔ Corrientes por Avenida Sarmiento',
    aliases: ['Sarmiento', 'Avenida Sarmiento', 'directo'],
  ),
  'interurbano-chaco-corrientes/904C': (
    name: 'Chaco ↔ Corrientes por Barranqueras',
    aliases: ['Barranqueras'],
  ),
};

/// "Ida: Chaco - Corrientes directo" → "Chaco - Corrientes directo".
///
/// De paso, la "x" de "Chaco - Corrientes x Barranqueras" pasa a "por": es
/// la abreviatura que usa el mapeador y en un nombre que va a leer un
/// pasajero se lee como un error de tipeo. Solo la palabra suelta — así no
/// toca un "Km 12 x 24" ni nada parecido.
String _withoutDirectionPrefix(String variantName) {
  final withoutPrefix = variantName.replaceFirst(
    RegExp(r'^\s*(ida|vuelta)\s*:\s*', caseSensitive: false),
    '',
  );
  return withoutPrefix
      .replaceAll(RegExp(r'(?<=\s)x(?=\s)', caseSensitive: false), 'por')
      .trim();
}

/// El valor que más se repite; a igualdad, el primero que llegó.
String? _mostCommon(List<String> values) {
  if (values.isEmpty) return null;
  final counts = <String, int>{};
  for (final value in values) {
    if (value.isEmpty) continue;
    counts[value] = (counts[value] ?? 0) + 1;
  }
  if (counts.isEmpty) return null;
  return counts.entries.reduce((a, b) => b.value > a.value ? b : a).key;
}

/// Clave para reconocer que "Vial" y "Barrio Vial" son el mismo lugar.
/// Solo se saca el prefijo "barrio": "Villa Luisa" y "Villa Chica" son
/// lugares distintos y no hay que fusionarlos.
String _canonicalEndpoint(String value) {
  var text = value.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
  for (final prefix in ['barrio ', 'b° ', 'bº ', 'bo. ', 'b. ']) {
    if (text.startsWith(prefix)) {
      text = text.substring(prefix.length).trim();
      break;
    }
  }
  return text;
}
