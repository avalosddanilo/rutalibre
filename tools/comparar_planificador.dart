/// Compara el planificador sin conexión con `plan_trip_v2` sobre viajes al
/// azar.
///
/// Uso (con una base local que tenga las migraciones y los seeds):
///
///   psql -d rl -At -f tools/sql/exportar_red.sql      > red.json
///   psql -d rl -At -f tools/sql/exportar_casos.sql    > casos.json
///   dart run tools/comparar_planificador.dart red.json casos.json
///
/// `exportar_casos.sql` elige pares de paradas al azar (con semilla fija) y
/// guarda lo que contesta el SQL. Esto corre el de Dart sobre los mismos
/// pares y cuenta en cuántos coinciden. Se corre cada vez que se toca una
/// regla del planificador, en la base o en la app.
library;

import 'dart:convert';
import 'dart:io';

import 'package:rutalibre/features/transit/data/planner/offline_trip_planner.dart';

void main(List<String> args) {
  if (args.length != 2) {
    stderr.writeln(
      'Uso: dart run tools/comparar_planificador.dart red.json casos.json',
    );
    exit(64);
  }
  final red =
      jsonDecode(File(args[0]).readAsStringSync()) as Map<String, dynamic>;
  final casos = (jsonDecode(File(args[1]).readAsStringSync()) as List<dynamic>)
      .cast<Map<String, dynamic>>();

  final net = PlannerNetwork.fromJson(
    red['network'] as Map<String, dynamic>,
    stops: [
      for (final s
          in (red['stops'] as List<dynamic>).cast<Map<String, dynamic>>())
        PlannerStop(
          id: s['id'] as String,
          name: s['name'] as String,
          description: s['description'] as String?,
          osmNodeId: (s['osm_node_id'] as num?)?.toInt(),
          lat: (s['lat'] as num).toDouble(),
          lng: (s['lng'] as num).toDouble(),
        ),
    ],
    lines: [
      for (final l
          in (red['lines'] as List<dynamic>).cast<Map<String, dynamic>>())
        PlannerLine(
          id: l['id'] as String,
          code: l['code'] as String,
          name: l['name'] as String,
          colorHex: l['color_hex'] as String?,
          networkCode: l['network_code'] as String,
          networkName: l['network_name'] as String,
        ),
    ],
  );

  var resueltosSql = 0;
  var resueltosDart = 0;
  var mismaCantidad = 0;
  var mismaPrimera = 0;
  var mismasOpciones = 0;
  final distintos = <String>[];
  var empates = 0;
  var mismosTiempos = 0;
  final sw = Stopwatch();
  var maxMs = 0;

  for (final c in casos) {
    final o = (c['o'] as List<dynamic>).cast<num>();
    final d = (c['d'] as List<dynamic>).cast<num>();
    final sql = (c['sql'] as List<dynamic>).cast<Map<String, dynamic>>();
    sw
      ..reset()
      ..start();
    final dart = planTripOffline(
      net,
      originLat: o[0].toDouble(),
      originLng: o[1].toDouble(),
      destLat: d[0].toDouble(),
      destLng: d[1].toDouble(),
    );
    sw.stop();
    if (sw.elapsedMilliseconds > maxMs) maxMs = sw.elapsedMilliseconds;

    if (sql.isNotEmpty) resueltosSql++;
    if (dart.isNotEmpty) resueltosDart++;
    if (sql.length == dart.length) mismaCantidad++;
    final firmaSql = sql.map(_firma).toList();
    final firmaDart = dart.map(_firma).toList();
    final primeraIgual =
        (sql.isEmpty && dart.isEmpty) ||
        (sql.isNotEmpty &&
            dart.isNotEmpty &&
            firmaSql.first == firmaDart.first);
    if (primeraIgual) {
      mismaPrimera++;
    } else if (sql.isNotEmpty &&
        dart.isNotEmpty &&
        (_minutos(net, sql.first) - _minutos(net, dart.first)).abs() < 0.5) {
      // Dos viajes que tardan lo mismo (menos de medio minuto de
      // diferencia, que es lo que separa medir sobre el elipsoide de medir
      // con haversine): cada uno elige uno. No es un error.
      empates++;
    } else {
      distintos.add(
        '${c['i']}: SQL ${firmaSql.isEmpty ? '—' : firmaSql.first}  '
        'DART ${firmaDart.isEmpty ? '—' : firmaDart.first}',
      );
    }
    final tSql = [for (final v in sql) _minutos(net, v)];
    final tDart = [for (final v in dart) _minutos(net, v)];
    if (tSql.length == tDart.length &&
        [
          for (var k = 0; k < tSql.length; k++) (tSql[k] - tDart[k]).abs(),
        ].every((x) => x < 0.5)) {
      mismosTiempos++;
    }
    if (firmaSql.toSet().containsAll(firmaDart) &&
        firmaDart.toSet().containsAll(firmaSql)) {
      mismasOpciones++;
    }
  }

  final n = casos.length;
  stdout
    ..writeln('Viajes: $n')
    ..writeln('Con resultado: SQL $resueltosSql · Dart $resueltosDart')
    ..writeln('Misma cantidad de opciones: $mismaCantidad')
    ..writeln('Misma primera opción: $mismaPrimera')
    ..writeln(
      'Distinta pero empatada (menos de medio minuto de diferencia): $empates',
    )
    ..writeln('Mismas opciones (sin mirar el orden): $mismasOpciones')
    ..writeln(
      'Mismos tiempos opción por opción (empates incluidos): $mismosTiempos',
    )
    ..writeln('El viaje más lento en Dart: $maxMs ms');
  if (distintos.isNotEmpty) {
    stdout.writeln('\nPrimera opción distinta (${distintos.length}):');
    for (final x in distintos.take(30)) {
      stdout.writeln('  $x');
    }
  }
}

/// Los "minutos" de la 0018 de un viaje del JSON, recalculados con la red.
double _minutos(PlannerNetwork net, Map<String, dynamic> viaje) {
  var total = (viaje['walk_total_m'] as num) / 40.0;
  for (final l
      in (viaje['legs'] as List<dynamic>).cast<Map<String, dynamic>>()) {
    final v = net.variants.firstWhere((v) => v.id == l['route_variant_id']);
    final b = v.stopIds.indexOf((l['board_stop'] as Map)['id'] as String);
    final a = v.stopIds.indexOf((l['alight_stop'] as Map)['id'] as String);
    total += (a - b) * 0.5 + (v.distM[a] - v.distM[b]) / 450.0;
  }
  return total;
}

/// Lo que define un viaje: líneas, recorridos, dónde se sube y se baja.
/// La caminata no entra: PostGIS mide sobre el elipsoide y acá con
/// haversine, y difieren en un par de metros.
String _firma(Map<String, dynamic> viaje) => [
  for (final l in (viaje['legs'] as List<dynamic>).cast<Map<String, dynamic>>())
    '${l['line_code']}${l['branch'] ?? ''}'
        '[${(l['board_stop'] as Map)['id'].toString().substring(0, 6)}'
        '→${(l['alight_stop'] as Map)['id'].toString().substring(0, 6)}'
        '/${l['stop_count']}]',
].join(' + ');
