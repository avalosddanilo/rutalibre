/// Las paradas de Corrientes capital, del dataset del municipio.
///
/// **De dónde salen.** Del recurso `paradas-colectivos.csv` del mismo
/// dataset que los recorridos (`bd941d41-…`). El municipio lo retiró del
/// portal, pero la capa sigue viva en su GeoServer
/// (`transporte:vw_paradas_colectivos`) y el Internet Archive conserva el
/// CSV. Ver `docs/corrientes-paradas-archivadas.md` y
/// `docs/corrientes-geoserver.md`.
///
/// **Por qué se puede usar un dato de 2022 con recorridos de 2026.** Porque
/// se midió: 2492 pares (parada, línea), mediana de 5 metros, 96 % a menos
/// de 80. Las paradas caen ARRIBA de los recorridos actuales. Y el bounding
/// box de la capa viva coincide con el del CSV hasta la tercera decimal.
///
/// **Qué hace este archivo y qué no.** Parsea, empareja cada parada con el
/// recorrido que le corresponde y la ORDENA sobre el trazado. No decide
/// nada de nombres ni emite SQL: eso es de quien lo llama.
library;

import 'dart:math' as math;

import 'corrientes_import.dart';
import 'csv_reader.dart';
import 'geometry.dart';

/// Una parada tal como viene del CSV municipal.
typedef MunicipalStop = ({
  /// El `gid` del dataset. Es la identidad estable: va a `stops.source_ref`
  /// como `ctes:<gid>`.
  int gid,

  /// 0 = ida, 1 = vuelta. La misma convención que `route_variants`.
  int direction,

  /// Los códigos de ramal tal cual los declara el CSV: `105-A`,
  /// `105-C-250VIV`, `109-B-YECOHA`…
  List<String> ramalCodes,
  GeoPoint point,
});

/// Una parada ya ubicada en un recorrido.
typedef PlacedStop = ({
  MunicipalStop stop,
  double alongMeters,
  double offsetMeters,
});

class CorrientesStopsResult {
  const CorrientesStopsResult({
    required this.stops,
    required this.byVariant,
    required this.warnings,
  });

  /// Las paradas físicas, deduplicadas, en orden estable por `gid`.
  final List<MunicipalStop> stops;

  /// Para cada recorrido (clave `línea/ramal/sentido`), los `gid` en orden
  /// de paso.
  final Map<String, List<int>> byVariant;

  final List<String> warnings;
}

/// La clave con la que se identifica un recorrido, igual que en el emisor.
String variantKey(CorrientesVariant v) =>
    '${v.lineCode}/${v.branch ?? ''}/${v.direction}';

/// Más allá de esto, la parada no es de ese recorrido.
///
/// El importador del Gran Resistencia descarta a 250 m por el mismo motivo:
/// un error de tagueo no puede inventar una secuencia. Acá se puede ser más
/// estricto —el 96 % cae dentro de 80 m— pero se deja el mismo número para
/// no tener dos criterios distintos para lo mismo.
const maxOffsetMeters = 250.0;

/// Dos paradas a menos de esto son la misma.
///
/// Chico a propósito: en el CSV, ida y vuelta de la misma esquina son filas
/// distintas y están enfrentadas. Unirlas sería mentir sobre en qué vereda
/// se espera, que es el error caro (ver `stop_merge.dart`).
const _sameStopMeters = 5.0;

/// Lee el CSV del municipio.
///
/// El formato es particular: los valores vienen entre comillas SIMPLES
/// adentro del campo CSV (`'VUELTA'`, `'105-A 105-C-250VIV'`), así que hay
/// que limpiarlas a mano.
(List<MunicipalStop>, List<String>) parseMunicipalStops(String csv) {
  final warnings = <String>[];
  final table = CsvTable.parse(csv);
  if (table.rows.isEmpty) return (const [], ['el CSV de paradas vino vacío']);

  // Los encabezados vienen con comillas SIMPLES adentro del campo CSV
  // (`'tipo_recorrido'`), así que `CsvTable` los deja con las comillas
  // puestas. Se limpian acá y se resuelven los índices a mano.
  final header = [for (final h in table.headers) _clean(h).toLowerCase()];
  int col(String name) => header.indexOf(name);
  final iGid = col('gid');
  final iDir = col('tipo_recorrido');
  final iRamal = col('linea_ramal');
  final iLng = col('lng');
  final iLat = col('lat');
  if ([iGid, iDir, iRamal, iLng, iLat].any((i) => i < 0)) {
    return (const [], ['al CSV de paradas le faltan columnas: $header']);
  }

  final out = <MunicipalStop>[];
  for (final row in table.rows) {
    if (row.length <= iLat) continue;
    final gid = int.tryParse(_clean(row[iGid]));
    final lat = double.tryParse(_clean(row[iLat]));
    final lng = double.tryParse(_clean(row[iLng]));
    if (gid == null || lat == null || lng == null) continue;
    if (!lat.isFinite || !lng.isFinite) continue;

    final crudo = _clean(row[iDir]).toUpperCase();
    final dir = switch (crudo) {
      'IDA' => 0,
      'VUELTA' => 1,
      _ => -1,
    };
    if (dir < 0) {
      warnings.add('parada $gid: sentido desconocido "$crudo"');
      continue;
    }

    final codes = _clean(
      row[iRamal],
    ).split(RegExp(r'\s+')).where((c) => c.isNotEmpty).toList();
    if (codes.isEmpty) continue;

    out.add((
      gid: gid,
      direction: dir,
      ramalCodes: codes,
      point: (lat: lat, lng: lng),
    ));
  }
  out.sort((a, b) => a.gid.compareTo(b.gid));
  return (out, warnings);
}

String _clean(String v) => v.trim().replaceAll("'", '').trim();

/// Empareja el código de ramal del CSV con un recorrido del seed.
///
/// Los dos lados nombran los ramales distinto —el CSV dice `105-C-250VIV` y
/// el dataset de recorridos dice `C 250 VIV.`— así que se compara
/// normalizando y en tres pasadas, de la más estricta a la más laxa:
///
/// 1. **Igualdad exacta** ya normalizada (`C250VIV` == `C250VIV`).
/// 2. **Prefijo único**: `A` contra `A LAGUNA SOTO` cuando es el único
///    ramal de esa línea que empieza con A.
/// 3. **Mayor solapamiento de palabras**, y solo si gana por diferencia:
///    `C ESPERANZA MONTAÑA` contra `C Bo ESPERANZA Bo DR. MONTAÑA`.
///
/// Si ninguna resuelve, devuelve null y quien llama lo reporta. Nunca
/// adivina entre dos empatados: meter una parada en el ramal equivocado es
/// mandar a alguien a esperar donde no pasa.
String? matchBranch(
  String ramalCode,
  String lineCode,
  List<String?> candidateBranches,
) {
  final parts = ramalCode.split('-');
  if (parts.isEmpty) return null;
  if (_norm(parts.first) != _norm(lineCode)) return null;
  final rest = parts.skip(1).toList();
  if (rest.isEmpty) {
    return candidateBranches.contains(null) ? null : _sentinelNoBranch;
  }

  final wanted = _norm(rest.join());
  final named = [for (final b in candidateBranches) ?b];

  for (final b in named) {
    if (_norm(b) == wanted) return b;
  }

  final prefixed = [
    for (final b in named)
      if (_norm(b).startsWith(wanted)) b,
  ];
  if (prefixed.length == 1) return prefixed.single;

  final wantedWords = _words(rest.join(' '));
  var best = <String>[];
  var bestScore = 0;
  for (final b in named) {
    final score = _words(b).where(wantedWords.contains).length;
    if (score > bestScore) {
      bestScore = score;
      best = [b];
    } else if (score == bestScore && score > 0) {
      best.add(b);
    }
  }
  if (bestScore > 0 && best.length == 1) return best.single;
  return null;
}

/// Marcador para "este código NO trae ramal y el recorrido tampoco".
const _sentinelNoBranch = '\u0000sin-ramal';

String _norm(String s) {
  const from = 'ÁÉÍÓÚÜÑáéíóúüñ';
  const to = 'AEIOUUNAEIOUUN';
  final buffer = StringBuffer();
  for (final ch in s.toUpperCase().split('')) {
    final i = from.indexOf(ch);
    final c = i >= 0 ? to[i] : ch;
    if (RegExp(r'[A-Z0-9]').hasMatch(c)) buffer.write(c);
  }
  return buffer.toString();
}

Set<String> _words(String s) => {
  for (final w in s.split(RegExp(r'[^A-Za-zÁÉÍÓÚÜÑáéíóúüñ0-9]+')))
    if (w.isNotEmpty) _norm(w),
}..removeWhere((w) => w.isEmpty);

/// Cuántos metros se avanzó sobre [route] al llegar a la proyección de [p],
/// y a qué distancia quedó el punto del trazado.
(double along, double offset) projectOnRoute(GeoPoint p, List<GeoPoint> route) {
  var bestOffset = double.infinity;
  var bestAlong = 0.0;
  var travelled = 0.0;
  for (var i = 0; i < route.length - 1; i++) {
    final a = route[i];
    final b = route[i + 1];
    final segment = haversineMeters(a, b);
    final offset = distanceToSegmentMeters(p, a, b);
    if (offset < bestOffset) {
      bestOffset = offset;
      bestAlong = travelled + segment * _fractionAlong(p, a, b);
    }
    travelled += segment;
  }
  return (bestAlong, bestOffset);
}

double _fractionAlong(GeoPoint p, GeoPoint a, GeoPoint b) {
  const metersPerDegreeLat = 111320.0;
  final metersPerDegreeLng =
      metersPerDegreeLat * math.cos(a.lat * math.pi / 180);
  final px = (p.lng - a.lng) * metersPerDegreeLng;
  final py = (p.lat - a.lat) * metersPerDegreeLat;
  final bx = (b.lng - a.lng) * metersPerDegreeLng;
  final by = (b.lat - a.lat) * metersPerDegreeLat;
  final len2 = bx * bx + by * by;
  if (len2 == 0) return 0;
  return ((px * bx + py * by) / len2).clamp(0.0, 1.0);
}

/// Deduplica las paradas físicas y arma la secuencia de cada recorrido.
CorrientesStopsResult placeStops({
  required List<MunicipalStop> stops,
  required List<CorrientesVariant> variants,
}) {
  final warnings = <String>[];

  // 1. Deduplicar lo que es la misma parada física. El CSV trae una fila por
  //    parada, pero nada garantiza que no se repita.
  final unique = <MunicipalStop>[];
  for (final s in stops) {
    final twin = unique.firstWhere(
      (u) =>
          u.direction == s.direction &&
          haversineMeters(u.point, s.point) <= _sameStopMeters,
      orElse: () => s,
    );
    if (identical(twin, s)) unique.add(s);
  }
  if (unique.length != stops.length) {
    warnings.add(
      '${stops.length - unique.length} paradas repetidas a menos de '
      '${_sameStopMeters.toInt()} m se unieron',
    );
  }

  // 2. Índice de ramales por línea, para emparejar.
  //
  //    SIN duplicados: cada ramal aparece una vez por sentido, y con la
  //    lista repetida "el único que empieza con A" nunca es único y el
  //    emparejamiento por prefijo no resuelve nada. Costó cuatro ramales
  //    antes de verlo.
  final branchesByLine = <String, List<String?>>{};
  for (final v in variants) {
    final list = branchesByLine[v.lineCode] ??= <String?>[];
    if (!list.contains(v.branch)) list.add(v.branch);
  }

  final sinRecorrido = <String>{};
  final byVariant = <String, List<PlacedStop>>{};

  for (final stop in unique) {
    for (final code in stop.ramalCodes) {
      final lineCode = code.split('-').first;
      final candidates = branchesByLine[lineCode];
      if (candidates == null) {
        sinRecorrido.add(code);
        continue;
      }
      final matched = matchBranch(code, lineCode, candidates);
      if (matched == null) {
        sinRecorrido.add(code);
        continue;
      }
      final branch = matched == _sentinelNoBranch ? null : matched;

      final variant = variants.firstWhere(
        (v) =>
            v.lineCode == lineCode &&
            v.branch == branch &&
            v.direction == stop.direction,
        orElse: () => const CorrientesVariant(
          lineCode: '',
          branch: null,
          direction: -1,
          name: '',
          geometry: [],
        ),
      );
      if (variant.direction < 0) continue;

      final (along, offset) = projectOnRoute(stop.point, variant.geometry);
      if (offset > maxOffsetMeters) continue;
      (byVariant[variantKey(variant)] ??= <PlacedStop>[]).add((
        stop: stop,
        alongMeters: along,
        offsetMeters: offset,
      ));
    }
  }

  if (sinRecorrido.isNotEmpty) {
    final ordenados = sinRecorrido.toList()..sort();
    warnings.add(
      'códigos de ramal sin recorrido publicado, sus paradas quedan fuera: '
      '${ordenados.join(", ")}',
    );
  }

  // 3. Ordenar cada recorrido por avance sobre el trazado, no por el orden
  //    del archivo. Y sacar repetidas: `route_stops` tiene
  //    unique (route_variant_id, stop_id) y un circular pasa dos veces por
  //    la cabecera.
  final ordered = <String, List<int>>{};
  final usados = <int>{};
  for (final entry in byVariant.entries) {
    final list = entry.value
      ..sort((a, b) {
        final c = a.alongMeters.compareTo(b.alongMeters);
        return c != 0 ? c : a.stop.gid.compareTo(b.stop.gid);
      });
    final gids = <int>[];
    for (final p in list) {
      if (gids.contains(p.stop.gid)) continue;
      gids.add(p.stop.gid);
    }
    // `usados` se marca RECIÉN acá, con la secuencia ya aceptada: una
    // parada suelta en un recorrido de una sola parada no es una parada
    // usada, y si se emitiera quedaría huérfana en la tabla.
    if (gids.length >= 2) {
      ordered[entry.key] = gids;
      usados.addAll(gids);
    }
  }

  // 4. Solo se emiten las paradas que entraron en algún recorrido: una
  //    parada suelta en `stops` la desactiva el seed del Gran Resistencia
  //    en su sección 5.
  final emitidas = [
    for (final s in unique)
      if (usados.contains(s.gid)) s,
  ];
  if (emitidas.length != unique.length) {
    warnings.add(
      '${unique.length - emitidas.length} paradas no cayeron en ningún '
      'recorrido publicado y no se emiten',
    );
  }

  return CorrientesStopsResult(
    stops: emitidas,
    byVariant: ordered,
    warnings: warnings,
  );
}
