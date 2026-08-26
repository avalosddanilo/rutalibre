/// Auditoría del TRANSBORDO de `plan_trip`, contra la base real y por REST.
///
/// Uso:
///   dart run tools/verify_transfers.dart            (lee env.json de la raíz)
///   dart run tools/verify_transfers.dart --env otro.json
///
/// **Qué verifica.** El invariante del que depende el 46% de los viajes: en
/// toda opción de dos tramos, la parada donde BAJÁS del primero tiene que ser
/// la MISMA donde SUBÍS al segundo — mismo id, y por las dudas también
/// distancia (≤ 15 m). Si difieren, la app manda gente a caminar entre dos
/// paradas sin decírselo: el bug más caro que puede tener el planificador.
///
/// **Por qué por REST y no por SQL.** No hay stack local de Supabase ni psql:
/// la base vive en la nube. Pero `plan_trip` es un RPC público con la anon
/// key —exactamente lo que usa la app—, así que la auditoría llama al MISMO
/// código que llamaría un teléfono, con las mismas credenciales. Solo
/// lectura; la clave sale de env.json y NUNCA se imprime.
///
/// La muestra es ESTABLE (los pares se eligen ordenando por un hash del par,
/// no por random): dos corridas miran los mismos pares, así que un fallo se
/// puede volver a mirar.
library;

import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

/// Cuántos pares origen-destino se auditan. Cada par es una corrida completa
/// del planificador en el servidor: 30 es suficiente para agarrar decenas de
/// transbordos sin castigar la cuota.
const _samplePairs = 30;

/// El umbral del invariante. 0 sería lo correcto en un mundo ideal (mismo
/// id ⇒ misma coordenada); 15 m deja lugar a que dos registros de la misma
/// parada física difieran por redondeo sin declarar roto el planificador.
const _maxTransferMeters = 15.0;

Future<void> main(List<String> args) async {
  final envPath = _argValue(args, '--env') ?? 'env.json';
  final env =
      jsonDecode(File(envPath).readAsStringSync()) as Map<String, dynamic>;
  final baseUrl = env['SUPABASE_URL'] as String;
  final anonKey = env['SUPABASE_ANON_KEY'] as String;

  stdout.writeln('Ruta Libre · auditoría del transbordo (${DateTime.now()})');
  stdout.writeln('Base: $baseUrl');

  final client = HttpClient();
  try {
    Future<dynamic> rpc(String fn, Map<String, dynamic> params) async {
      final request = await client.postUrl(
        Uri.parse('$baseUrl/rest/v1/rpc/$fn'),
      );
      request.headers
        ..set('apikey', anonKey)
        ..set('Authorization', 'Bearer $anonKey')
        ..contentType = ContentType.json;
      request.write(jsonEncode(params));
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      if (response.statusCode != 200) {
        throw StateError('$fn devolvió HTTP ${response.statusCode}: $body');
      }
      return jsonDecode(body);
    }

    // 1. Todas las paradas activas (el mismo RPC del buscador de destino).
    final stops = ((await rpc('get_all_stops', const {})) as List)
        .cast<Map<String, dynamic>>();
    stdout.writeln('Paradas activas: ${stops.length}');

    // 2. Pares lejanos con muestra estable: se ordenan las paradas por un
    //    hash de su id y se emparejan buscando distancias de 4 a 9 km — la
    //    franja donde el transbordo es probable.
    stops.sort(
      (a, b) => _hash(a['id'] as String).compareTo(_hash(b['id'] as String)),
    );
    final pairs = <(Map<String, dynamic>, Map<String, dynamic>)>[];
    for (var i = 0; i < stops.length && pairs.length < _samplePairs; i += 7) {
      final origin = stops[i];
      for (var j = i + 1; j < stops.length; j += 13) {
        final dest = stops[j];
        final km = _meters(origin, dest) / 1000;
        if (km >= 4 && km <= 9) {
          pairs.add((origin, dest));
          break;
        }
      }
    }
    stdout.writeln('Pares a auditar: ${pairs.length}\n');

    var trips = 0;
    var transfers = 0;
    var okId = 0;
    final broken = <String>[];

    for (final (origin, dest) in pairs) {
      final plans =
          ((await rpc('plan_trip', {
                    'origin_lat': origin['lat'],
                    'origin_lng': origin['lng'],
                    'dest_lat': dest['lat'],
                    'dest_lng': dest['lng'],
                    'max_walk_m': 700,
                    'max_results': 6,
                  }))
                  as List)
              .cast<Map<String, dynamic>>();
      trips += plans.length;

      for (final plan in plans) {
        if (plan['leg_count'] != 2) continue;
        transfers++;
        final legs = (plan['legs'] as List).cast<Map<String, dynamic>>();
        final alight = legs[0]['alight_stop'] as Map<String, dynamic>;
        final board = legs[1]['board_stop'] as Map<String, dynamic>;
        final meters = _meters(alight, board);
        final sameId = alight['id'] == board['id'];
        if (sameId) okId++;
        if (!sameId || meters > _maxTransferMeters) {
          broken.add(
            'De "${origin['name']}" a "${dest['name']}": '
            'bajás en "${alight['name']}" (${alight['id']}) y subís en '
            '"${board['name']}" (${board['id']}) — a ${meters.round()} m',
          );
        }
      }
    }

    stdout
      ..writeln('Viajes devueltos:      $trips')
      ..writeln('Con transbordo:        $transfers')
      ..writeln('  mismo id:            $okId')
      ..writeln('  MAL (id o >15 m):    ${broken.length}');
    if (broken.isEmpty) {
      stdout.writeln(
        transfers == 0
            ? '\n⚠ La muestra no produjo transbordos: subí _samplePairs o '
                  'la caminata. NO es un aprobado.'
            : '\n✔ Invariante verificado: en los $transfers transbordos se '
                  'baja y se sube en la MISMA parada.',
      );
    } else {
      stdout.writeln('\n✘ TRANSBORDOS ROTOS:');
      broken.forEach(stdout.writeln);
      exitCode = 1;
    }
  } finally {
    client.close();
  }
}

double _meters(Map<String, dynamic> a, Map<String, dynamic> b) {
  const earthRadius = 6371000.0;
  final lat1 = (a['lat'] as num).toDouble() * math.pi / 180;
  final lat2 = (b['lat'] as num).toDouble() * math.pi / 180;
  final dLat = lat2 - lat1;
  final dLng =
      ((b['lng'] as num).toDouble() - (a['lng'] as num).toDouble()) *
      math.pi /
      180;
  final h =
      math.pow(math.sin(dLat / 2), 2) +
      math.cos(lat1) * math.cos(lat2) * math.pow(math.sin(dLng / 2), 2);
  return 2 * earthRadius * math.asin(math.sqrt(h.toDouble()));
}

/// Hash estable del id (djb2): el orden de la muestra no depende de la
/// corrida ni de la plataforma.
int _hash(String id) {
  var hash = 5381;
  for (final unit in id.codeUnits) {
    hash = ((hash << 5) + hash + unit) & 0x7fffffff;
  }
  return hash;
}

String? _argValue(List<String> args, String flag) {
  final index = args.indexOf(flag);
  if (index < 0 || index + 1 >= args.length) return null;
  return args[index + 1];
}
