/// Modelo intermedio del importer: lo que se va a escribir en la base,
/// ya limpio y resuelto, antes de convertirlo en SQL.
library;

import 'geometry.dart';

class ImportedLine {
  ImportedLine({
    required this.networkCode,
    required this.code,
    required this.name,
    required this.colorHex,
    required this.sortOrder,
    this.destinations = const [],
  });

  final String networkCode;
  final String code;
  String name;

  /// Todas las cabeceras y destinos de la línea, la primera es el tronco.
  /// [name] es un resumen de esto que entra en un renglón; acá está completo
  /// para que el buscador de la app pueda encontrar los que el nombre tapa.
  List<String> destinations;

  final String colorHex;
  final int sortOrder;

  String get key => '$networkCode/$code';
}

class ImportedVariant {
  ImportedVariant({
    required this.osmRelationId,
    required this.networkCode,
    required this.lineCode,
    required this.branch,
    required this.direction,
    required this.name,
    required this.geometry,
    required this.stopOsmIds,
  });

  final int osmRelationId;
  final String networkCode;
  final String lineCode;
  final String? branch;

  /// 0 = ida, 1 = vuelta. Ya resuelto (sin nulls).
  int direction;

  /// Mutable junto con [direction]: cuando el sentido no venía en OSM y se
  /// asigna por descarte, el nombre tiene que decirlo. Si no, los dos
  /// recorridos del ramal quedan con el MISMO nombre y chocan contra
  /// `unique (line_id, name)`.
  String name;
  final List<GeoPoint> geometry;

  /// Paradas en orden de paso, deduplicadas.
  ///
  /// Mutable: el pase de unificación de paradas (`stop_merge.dart`) la
  /// reescribe con los nodos canónicos cuando ya vio el dataset ENTERO.
  List<int> stopOsmIds;
}

class ImportedStop {
  const ImportedStop({
    required this.osmNodeId,
    required this.name,
    required this.description,
    required this.point,
  });

  final int osmNodeId;
  final String name;
  final String? description;
  final GeoPoint point;
}

/// Todo lo que produjo el import, más el diagnóstico para auditarlo.
class ImportResult {
  ImportResult({
    required this.lines,
    required this.variants,
    required this.stops,
    required this.warnings,
    required this.skipped,
    required this.gapReport,
  });

  final List<ImportedLine> lines;
  final List<ImportedVariant> variants;
  final List<ImportedStop> stops;

  /// Problemas de datos que NO impidieron importar (ref mal etiquetado,
  /// sentido inferido, etc.).
  final List<String> warnings;

  /// Relations descartadas y por qué.
  final List<String> skipped;

  /// Saltos puenteados por recorrido, para saber qué trazados revisar en OSM.
  final List<String> gapReport;
}
