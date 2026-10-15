/// Recorridos de Corrientes que cambiaron y que el portal todavía no publicó.
///
/// **Por qué existe.** El 12/8/2026 la 102A y la 106A cambiaron su recorrido
/// (El Litoral y el cartel de ERSA). Dos meses después el portal de datos
/// abiertos seguía con el trazado viejo —idéntico al nuestro, a 5 m—, así que
/// la app mostraba un recorrido que ya no existe y nadie se había dado
/// cuenta. Regenerar el seed desde el portal lo volvería a romper.
///
/// **Qué hace.** Lee `tools/data/corrientes_correcciones.json` y, para cada
/// recorrido corregido, reemplaza el trazado del portal y su secuencia de
/// paradas. Todo lo demás sigue saliendo del portal.
///
/// **De dónde salen las correcciones.** Las calles de la fuente, ruteadas
/// sobre el callejero de OpenStreetMap y revisadas a mano por alguien que
/// conoce la zona. Las paradas son las oficiales del municipio (`ctes:N`).
/// Nunca Google Maps.
///
/// **Cuándo se borran.** Cuando el portal publique el recorrido nuevo: ahí
/// vuelve a mandar el portal.
///
/// Dart PURO — sin red, sin SQL de archivos, sin Flutter.
library;

import 'corrientes_import.dart';
import 'corrientes_stops_csv.dart';
import 'geometry.dart';
import 'sql_emitter.dart' show sqlString, lineStringWkt;

/// Misma tolerancia que el trazado del portal.
const _simplifyToleranceMeters = 5.0;

/// Un recorrido corregido.
class RouteCorrection {
  const RouteCorrection({
    required this.lineCode,
    required this.branch,
    required this.direction,
    required this.validFrom,
    required this.source,
    required this.streets,
    required this.reviewed,
    required this.stopGids,
    required this.geometry,
  });

  final String lineCode;
  final String? branch;
  final int direction;
  final String validFrom;

  /// De dónde salió: es obligatorio, como en las tarifas. Una corrección sin
  /// fuente es una opinión.
  final String source;
  final String streets;

  /// Quién lo revisó contra la fuente, y cuándo.
  final String reviewed;

  /// Los `gid` de las paradas municipales, en orden de paso.
  final List<int> stopGids;
  final List<GeoPoint> geometry;

  /// La misma clave que usan el emisor y las paradas: `línea/ramal/sentido`.
  String get key => '$lineCode/${branch ?? ''}/$direction';

  String get label =>
      '$lineCode${branch ?? ''} ${direction == 0 ? 'ida' : 'vuelta'}';
}

/// Lee el JSON de correcciones. Falla fuerte ante cualquier campo faltante:
/// una corrección a medias haría un seed peor que el del portal.
List<RouteCorrection> parseCorrections(Map<String, dynamic> json) {
  final list = json['recorridos'] as List<dynamic>? ?? const [];
  return [
    for (final raw in list.cast<Map<String, dynamic>>())
      () {
        String text(String key) {
          final value = raw[key];
          if (value is! String || value.trim().isEmpty) {
            throw FormatException('Corrección sin "$key": $raw');
          }
          return value;
        }

        final direction = raw['sentido'];
        if (direction != 0 && direction != 1) {
          throw FormatException('Sentido inválido en la corrección: $raw');
        }
        final stops = (raw['paradas'] as List<dynamic>? ?? const [])
            .cast<int>();
        final points = [
          for (final p in (raw['trazado'] as List<dynamic>? ?? const []))
            (
              lat: ((p as List<dynamic>)[1] as num).toDouble(),
              lng: (p[0] as num).toDouble(),
            ),
        ];
        final correction = RouteCorrection(
          lineCode: text('linea'),
          branch: raw['ramal'] as String?,
          direction: direction as int,
          validFrom: text('vigente_desde'),
          source: text('fuente'),
          streets: text('calles'),
          reviewed: text('revisado'),
          stopGids: stops,
          geometry: points,
        );
        if (points.length < 2) {
          throw FormatException('${correction.label}: trazado sin puntos');
        }
        if (stops.length < 2) {
          throw FormatException('${correction.label}: menos de dos paradas');
        }
        if (stops.toSet().length != stops.length) {
          throw FormatException('${correction.label}: paradas repetidas');
        }
        return correction;
      }(),
  ];
}

/// El trazado ya simplificado, como el del portal.
List<GeoPoint> correctedGeometry(RouteCorrection c) =>
    simplify(c.geometry, _simplifyToleranceMeters);

/// Reemplaza el trazado de los recorridos corregidos.
///
/// Si una corrección no encuentra su recorrido en el portal, **falla**: el
/// portal lo dio de baja o lo renombró, y eso lo tiene que decidir una
/// persona, no el importador en silencio.
CorrientesImportResult applyRouteCorrections(
  CorrientesImportResult result,
  List<RouteCorrection> corrections,
) {
  final byKey = {for (final c in corrections) c.key: c};
  final found = <String>{};
  final variants = [
    for (final v in result.variants)
      if (byKey[variantKey(v)] case final c?)
        () {
          found.add(c.key);
          return CorrientesVariant(
            lineCode: v.lineCode,
            branch: v.branch,
            direction: v.direction,
            name: v.name,
            geometry: correctedGeometry(c),
          );
        }()
      else
        v,
  ];
  final missing = byKey.keys.where((k) => !found.contains(k)).toList();
  if (missing.isNotEmpty) {
    throw StateError(
      'Correcciones sin recorrido en el portal: ${missing.join(', ')}',
    );
  }
  return CorrientesImportResult(
    lines: result.lines,
    variants: variants,
    warnings: [
      ...result.warnings,
      for (final c in corrections)
        '${c.label}: trazado y paradas de tools/data/corrientes_correcciones.json '
            '(vigente desde ${c.validFrom}; el portal sigue con el anterior)',
    ],
    skipped: result.skipped,
  );
}

/// Reemplaza la secuencia de paradas de los recorridos corregidos.
///
/// Las paradas físicas se vuelven a armar desde [all] (las del archivo
/// municipal): una que solo usaba el recorrido viejo deja de emitirse, y una
/// que el corregido suma, entra.
CorrientesStopsResult applyStopCorrections(
  CorrientesStopsResult placed, {
  required List<MunicipalStop> all,
  required List<RouteCorrection> corrections,
}) {
  final known = {for (final s in all) s.gid};
  for (final c in corrections) {
    final unknown = c.stopGids.where((g) => !known.contains(g)).toList();
    if (unknown.isNotEmpty) {
      throw StateError(
        '${c.label}: paradas que no están en el archivo municipal: '
        '${unknown.join(', ')}',
      );
    }
  }

  final byVariant = {
    ...placed.byVariant,
    for (final c in corrections) c.key: c.stopGids,
  };
  final used = {for (final gids in byVariant.values) ...gids};
  final seen = <int>{};
  final stops = [
    for (final s in all)
      if (used.contains(s.gid) && seen.add(s.gid)) s,
  ];
  return CorrientesStopsResult(
    stops: stops,
    byVariant: byVariant,
    warnings: placed.warnings,
  );
}

/// El SQL que aplica las correcciones en una base que ya tiene el seed.
///
/// Es lo que va a la migración: el seed regenerado y la migración salen del
/// mismo JSON, así que no pueden decir cosas distintas.
String emitCorrectionsSql(List<RouteCorrection> corrections) {
  final b = StringBuffer();
  for (final c in corrections) {
    final variant =
        '(select rv.id from public.route_variants rv '
        'join public.lines l on l.id = rv.line_id '
        'join public.networks n on n.id = l.network_id '
        "where n.code = 'corrientes-capital' "
        'and l.code = ${sqlString(c.lineCode)} '
        'and rv.branch is not distinct from ${sqlString(c.branch)} '
        'and rv.direction = ${c.direction})';
    b
      ..writeln()
      ..writeln('-- ${c.label}: ${c.streets}.')
      ..writeln('update public.route_variants')
      ..writeln(
        "   set geom = st_geomfromtext('${lineStringWkt(correctedGeometry(c))}', 4326)",
      )
      ..writeln(' where id = $variant;')
      ..writeln(
        'delete from public.route_stops where route_variant_id = $variant;',
      )
      ..writeln(
        'insert into public.route_stops (route_variant_id, stop_id, stop_order)',
      )
      ..writeln('select $variant, s.id, p.orden')
      ..writeln('  from unnest(array[${c.stopGids.join(', ')}])')
      ..writeln('       with ordinality as p(gid, orden)')
      ..writeln("  join public.stops s on s.source_ref = 'ctes:' || p.gid;");
  }
  return b.toString();
}
