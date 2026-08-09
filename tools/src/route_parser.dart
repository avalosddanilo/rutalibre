/// Traducción de los tags de una relation de OSM al modelo de Ruta Libre.
///
/// Dart PURO y sin I/O: es la pieza con más reglas de negocio del importer
/// y la que más barato sale testear. Todas las reglas de acá salieron de
/// mirar los datos REALES del Gran Resistencia (ver `docs/osm-import.md`),
/// no de suponer cómo debería estar mapeado OSM.
library;

/// Sentido de circulación tal como lo entiende el esquema (0 = ida, 1 = vuelta).
enum ParsedDirection {
  outbound(0),
  inbound(1);

  const ParsedDirection(this.dbValue);

  final int dbValue;
}

/// Resultado de interpretar una relation.
class ParsedRoute {
  const ParsedRoute({
    required this.osmRelationId,
    required this.lineCode,
    required this.branch,
    required this.direction,
    required this.variantName,
    required this.origin,
    required this.destination,
    required this.warnings,
  });

  final int osmRelationId;

  /// Código de la LÍNEA, ya sin el ramal: "3", "110", "904", "Tirol".
  final String lineCode;

  /// Ramal dentro de la línea: "A", "B", "C"... o null si la línea no tiene.
  final String? branch;

  /// Null si no se pudo determinar; el importer resuelve el desempate.
  final ParsedDirection? direction;

  /// Descripción legible del recorrido: "Ida: Vial → Shopping Sarmiento".
  final String variantName;

  /// Cabecera y destino, cuando el nombre o los tags from/to los revelan.
  /// Se usan para construir el nombre de la LÍNEA ("Vial ↔ Monte Alto").
  final String? origin;
  final String? destination;

  /// Problemas detectados en los datos de origen (se reportan al final del
  /// import; ninguno es fatal).
  final List<String> warnings;
}

const networkGranResistencia = 'gran-resistencia';

/// Interurbano que NO sale de la provincia: Colonia Benítez, Puerto Tirol.
///
/// Estaba metido en la red "Chaco – Corrientes" junto con la 904, y era una
/// mentira: esos dos recorridos no cruzan el Paraná ni se acercan. Un
/// pasajero que abre "Chaco – Corrientes" busca cómo cruzar a Corrientes,
/// no cómo ir a Puerto Tirol.
const networkInterurbanoChaco = 'interurbano-chaco';

/// El que sí cruza a Corrientes capital.
const networkChacoCorrientes = 'interurbano-chaco-corrientes';

/// Códigos de línea que no son del servicio urbano del Gran Resistencia.
const _chacoCorrientesCodes = {'904'};
const _interurbanChacoCodes = {'RES-CB', 'Tirol'};

/// A qué red pertenece una línea según su código.
String networkCodeFor(String lineCode) {
  if (_chacoCorrientesCodes.contains(lineCode)) return networkChacoCorrientes;
  if (_interurbanChacoCodes.contains(lineCode)) return networkInterurbanoChaco;
  return networkGranResistencia;
}

/// En el interurbano Chaco ↔ Corrientes el RAMAL **es** la línea.
///
/// Rompe a propósito la regla general de la app ("3A no es una línea, es el
/// ramal A de la 3") y por exactamente la misma razón que la sostiene: lo que
/// el pasajero tiene en la cabeza. En el Gran Resistencia nadie espera "la
/// 3A", espera la 3 y se sube a la que venga. Cruzando el puente nadie espera
/// "la 904": espera el DIRECTO o el que va POR BARRANQUERAS, que son
/// servicios distintos, con otro recorrido, otra duración y otras paradas.
/// Meterlos en una línea sola —que además queda bautizada como el 904A, que
/// va al campus de la UNNE— le miente a los otros dos.
({String lineCode, String? branch}) lineIdentityFor(
  String lineCode,
  String? branch,
) {
  if (branch == null || branch.isEmpty) {
    return (lineCode: lineCode, branch: null);
  }
  if (networkCodeFor(lineCode) != networkChacoCorrientes) {
    return (lineCode: lineCode, branch: branch);
  }
  return (lineCode: '$lineCode$branch', branch: null);
}

/// Orden natural: las líneas numéricas por su número ("3" antes que "110"),
/// las nominales al final y alfabéticas. Se persiste en `lines.sort_order`
/// para que el orden lo defina la base y no cada cliente.
///
/// El número se multiplica por 100 para dejar lugar a un sufijo de letra:
/// desde que el interurbano promueve el ramal a línea existen códigos como
/// "904A", y tienen que caer JUNTO al 904 y en orden, no al final con los
/// nominales.
int sortOrderFor(String lineCode) {
  final match = RegExp(r'^(\d+)([A-Za-z]?)$').firstMatch(lineCode);
  if (match != null) {
    final number = int.parse(match.group(1)!);
    final suffix = match.group(2)!;
    final letter = suffix.isEmpty ? 0 : suffix.toUpperCase().codeUnitAt(0) - 64;
    return number * 100 + letter;
  }
  return 900000 + lineCode.codeUnitAt(0);
}

final _dirSuffix = RegExp(r'\s+(ida|vuelta)\s*$', caseSensitive: false);
final _dirPrefix = RegExp(r'^\s*\S+\s+(ida|vuelta)\b', caseSensitive: false);
final _dirWord = RegExp(r'\b(ida|vuelta)\b', caseSensitive: false);

/// El sentido declarado en el nombre, buscándolo donde el convenio de la red
/// lo pone antes de buscarlo en cualquier lado.
///
/// El orden importa: "Vuelta de Obligado" es una calle real en muchas
/// ciudades argentinas, y buscar la palabra suelta primero invertiría el
/// sentido de un recorrido que pase por ahí. Por eso la búsqueda libre queda
/// última y descarta los casos en que la palabra arrastra un "de"/"del"
/// (la forma típica del topónimo).
ParsedDirection? _directionFromName(String rawName) {
  ParsedDirection fromWord(String word) => word.toLowerCase() == 'ida'
      ? ParsedDirection.outbound
      : ParsedDirection.inbound;

  // 1. "{código} Ida ..." — el convenio de la red.
  final prefix = _dirPrefix.firstMatch(rawName);
  if (prefix != null) return fromWord(prefix.group(1)!);

  // 2. "... Ida" — la otra forma que aparece en los datos reales.
  final suffix = _dirSuffix.firstMatch(rawName);
  if (suffix != null) return fromWord(suffix.group(1)!);

  // 3. En cualquier lado, salvo que parezca topónimo.
  for (final match in _dirWord.allMatches(rawName)) {
    final rest = rawName.substring(match.end);
    if (RegExp(r'^\s+del?\b', caseSensitive: false).hasMatch(rest)) continue;
    return fromWord(match.group(1)!);
  }
  return null;
}

/// "3A" → ("3", "A") | "101" → ("101", null) | "Tirol A" → ("Tirol", "A")
/// | "RES-CB" → ("RES-CB", null)
({String code, String? branch}) splitCodeAndBranch(String ref) {
  final trimmed = ref.trim();

  final numberLetter = RegExp(r'^(\d+)\s*([A-Za-z])$').firstMatch(trimmed);
  if (numberLetter != null) {
    return (
      code: numberLetter.group(1)!,
      branch: numberLetter.group(2)!.toUpperCase(),
    );
  }

  if (RegExp(r'^\d+$').hasMatch(trimmed)) {
    return (code: trimmed, branch: null);
  }

  // "Tirol A": palabra + letra suelta al final.
  final wordLetter = RegExp(r'^(.+?)\s+([A-Za-z])$').firstMatch(trimmed);
  if (wordLetter != null) {
    return (
      code: wordLetter.group(1)!.trim(),
      branch: wordLetter.group(2)!.toUpperCase(),
    );
  }

  return (code: trimmed, branch: null);
}

/// Interpreta una relation de OSM.
///
/// [ref] es el tag `ref` (puede traer el sentido pegado: "904B Ida").
/// [name] es el tag `name`, que en esta red sigue el convenio
/// "{ref} {Ida|Vuelta} {Origen} - {Destino}" y es MÁS CONFIABLE que el ref:
/// hay al menos una relation con `ref=207` cuyo nombre es "206 Vuelta ...".
ParsedRoute parseRoute({
  required int osmRelationId,
  required String? ref,
  required String? name,
  String? fromTag,
  String? toTag,
}) {
  final warnings = <String>[];
  final rawName = (name ?? '').trim();

  // --- 1. Sentido: primero del nombre, después del ref ---
  ParsedDirection? direction = _directionFromName(rawName);

  // --- 2. Ref sin el sentido pegado ("904B Ida" → "904B") ---
  var refCore = (ref ?? '').trim();
  final refDir = _dirSuffix.firstMatch(refCore);
  if (refDir != null) {
    direction ??= refDir.group(1)!.toLowerCase() == 'ida'
        ? ParsedDirection.outbound
        : ParsedDirection.inbound;
    refCore = refCore.substring(0, refDir.start).trim();
  }

  var parts = splitCodeAndBranch(refCore);

  // --- 3. El nombre manda sobre el ref si se contradicen ---
  // Caso real: relation con ref=207 llamada "206 Vuelta Resistencia -
  // Barranqueras". Confiar en el ref metería el recorrido en la línea
  // equivocada.
  final nameCode = RegExp(
    r'^(\d+\s*[A-Za-z]?)\s+(?:ida|vuelta)\b',
    caseSensitive: false,
  ).firstMatch(rawName);
  if (nameCode != null) {
    final fromName = splitCodeAndBranch(nameCode.group(1)!.trim());
    if (fromName.code != parts.code || fromName.branch != parts.branch) {
      warnings.add(
        'relation $osmRelationId: ref="$ref" no coincide con el nombre '
        '"$rawName" → se usa ${fromName.code}${fromName.branch ?? ''} '
        '(el nombre es más confiable)',
      );
      parts = fromName;
    }
  }

  if (parts.code.isEmpty) {
    warnings.add('relation $osmRelationId: sin código de línea usable');
  }

  // --- 4. Extremos del recorrido ---
  //
  // El " - " solo separa cabecera y destino si el nombre sigue el convenio
  // de la red ("{código} {Ida|Vuelta} Origen - Destino", o el sentido al
  // final). En nombres libres como "Chaco - Corrientes directo" ese guion
  // NO separa extremos y partirlo daría destinos inventados.
  var descriptor = rawName;
  final prefix = RegExp(
    r'^\s*\S+\s+(?:ida|vuelta)\s*',
    caseSensitive: false,
  ).firstMatch(descriptor);
  var followsConvention = false;
  if (prefix != null) {
    descriptor = descriptor.substring(prefix.end).trim();
    followsConvention = true;
  } else if (_dirSuffix.hasMatch(descriptor)) {
    // "Resistencia - Puerto Tirol Ida": el sentido va al final.
    descriptor = descriptor.replaceFirst(_dirSuffix, '').trim();
    followsConvention = true;
  }

  String? origin;
  String? destination;
  final dash = descriptor.indexOf(' - ');
  if (followsConvention && dash > 0) {
    origin = descriptor.substring(0, dash).trim();
    destination = descriptor.substring(dash + 3).trim();
  } else if ((fromTag ?? '').isNotEmpty && (toTag ?? '').isNotEmpty) {
    origin = fromTag!.trim();
    destination = toTag!.trim();
  } else if (descriptor.isNotEmpty && !descriptor.contains(' - ')) {
    // Sin par origen/destino, pero el descriptor igual dice ADÓNDE va
    // ("Colonia Benítez"): sirve para nombrar la línea. Si trae un guion
    // es una descripción de ruta ("Chaco - Corrientes directo"), no un
    // lugar, y usarla como destino ensucia el nombre de la línea.
    destination = descriptor;
  }

  // --- 5. Nombre legible del recorrido ---
  final dirLabel = switch (direction) {
    ParsedDirection.outbound => 'Ida',
    ParsedDirection.inbound => 'Vuelta',
    null => null,
  };
  final String variantName;
  if (origin != null && destination != null) {
    variantName = dirLabel == null
        ? '$origin → $destination'
        : '$dirLabel: $origin → $destination';
  } else if (descriptor.isNotEmpty) {
    variantName = dirLabel == null ? descriptor : '$dirLabel: $descriptor';
  } else {
    variantName = dirLabel ?? 'Recorrido';
  }

  return ParsedRoute(
    osmRelationId: osmRelationId,
    lineCode: parts.code,
    branch: parts.branch,
    direction: direction,
    variantName: variantName,
    origin: origin,
    destination: destination,
    warnings: warnings,
  );
}
