// Genera las páginas web de las líneas (una por línea, más el índice).
//
//   dart run tools/web_lineas.dart                      baja de Supabase
//   dart run tools/web_lineas.dart --desde datos.json   sin red
//
// Baja los datos con la anon key —la misma, pública, que usa la app—, de
// `env.json` o de las variables SUPABASE_URL y SUPABASE_ANON_KEY (así corre
// en GitHub Actions). Nunca con la service_role.
//
// Escribe el sitio en `build/sitio/` (gitignoreado: se regenera). Qué dice
// cada página y qué no: `tools/src/web_lineas.dart`.
//
//   --base URL       dónde va a vivir el sitio (para el sitemap)
//   --out DIR        dónde escribirlo
//   --guardar ARCH   además, guarda los datos bajados para usar con --desde
import 'dart:convert';
import 'dart:io';

import 'src/web_lineas.dart';

const _defaultBase = 'https://avalosddanilo.github.io/rutalibre/';

Future<void> main(List<String> args) async {
  final desde = _flag(args, '--desde');
  final out = _flag(args, '--out') ?? 'build/sitio';
  var base = _flag(args, '--base') ?? _defaultBase;
  if (!base.endsWith('/')) base = '$base/';

  final WebData data;
  if (desde != null) {
    data = webDataFromJson(
      jsonDecode(File(desde).readAsStringSync()) as Map<String, dynamic>,
    );
  } else {
    data = await _fetch();
    final guardar = _flag(args, '--guardar');
    if (guardar != null) {
      File(guardar)
        ..parent.createSync(recursive: true)
        ..writeAsStringSync(jsonEncode(webDataToJson(data)));
    }
  }

  if (data.lines.isEmpty) {
    stderr.writeln('ERROR: no llegó ninguna línea. No se escribe nada.');
    exit(1);
  }

  final files = renderSite(data, baseUrl: base);
  final dir = Directory(out);
  if (dir.existsSync()) dir.deleteSync(recursive: true);
  for (final MapEntry(key: path, value: content) in files.entries) {
    File('$out/$path')
      ..parent.createSync(recursive: true)
      ..writeAsStringSync(content);
  }
  stdout.writeln(
    '${data.lines.length} líneas, ${files.length} archivos en $out/ '
    '(datos al ${data.updatedOn}).',
  );
}

Future<WebData> _fetch() async {
  final (url, key) = _credentials();
  final client = HttpClient();
  try {
    Future<dynamic> get(String path) async {
      final request = await client.getUrl(Uri.parse('$url/rest/v1/$path'));
      request.headers
        ..set('apikey', key)
        ..set('Authorization', 'Bearer $key');
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      if (response.statusCode != 200) {
        throw HttpException('$path: HTTP ${response.statusCode} $body');
      }
      return jsonDecode(body);
    }

    Future<dynamic> rpc(String name, Map<String, Object?> params) async {
      final request = await client.postUrl(Uri.parse('$url/rest/v1/rpc/$name'));
      request.headers
        ..set('apikey', key)
        ..set('Authorization', 'Bearer $key')
        ..contentType = ContentType.json;
      request.write(jsonEncode(params));
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      if (response.statusCode != 200) {
        throw HttpException('rpc $name: HTTP ${response.statusCode} $body');
      }
      return jsonDecode(body);
    }

    stdout.writeln('Bajando líneas y recorridos de $url …');
    final lines =
        (await get(
                  'lines?select=id,code,name,color_hex,sort_order,'
                  'networks(code,name,sort_order)',
                )
                as List)
            .cast<Map<String, dynamic>>();
    final variants =
        (await get(
                  'route_variants?select=id,line_id,name,branch,direction'
                  '&order=direction.asc,branch.asc',
                )
                as List)
            .cast<Map<String, dynamic>>();

    lines.sort((a, b) {
      final na = (a['networks'] as Map)['sort_order'] as int;
      final nb = (b['networks'] as Map)['sort_order'] as int;
      if (na != nb) return na.compareTo(nb);
      return (a['sort_order'] as int).compareTo(b['sort_order'] as int);
    });

    final result = <WebLine>[];
    for (final line in lines) {
      final own = variants.where((v) => v['line_id'] == line['id']).toList();
      if (own.isEmpty) continue;
      final webVariants = <WebVariant>[];
      for (final v in own) {
        final stops =
            (await rpc('get_stops_for_route', {'variant_id': v['id']}) as List)
                .cast<Map<String, dynamic>>();
        final geojson = await rpc('get_route_geojson', {'variant_id': v['id']});
        final coords =
            (geojson is Map ? geojson['coordinates'] as List? : null) ??
            const [];
        webVariants.add(
          WebVariant(
            name: v['name'] as String,
            branch: v['branch'] as String?,
            direction: (v['direction'] as num).toInt(),
            stops: [
              for (final s in stops)
                WebStop(
                  name: s['name'] as String,
                  lat: (s['lat'] as num).toDouble(),
                  lng: (s['lng'] as num).toDouble(),
                ),
            ],
            // GeoJSON es [lng, lat]; acá se guarda (lat, lng).
            geometry: [
              for (final p in coords.cast<List<dynamic>>())
                ((p[1] as num).toDouble(), (p[0] as num).toDouble()),
            ],
          ),
        );
      }
      final network = line['networks'] as Map<String, dynamic>;
      result.add(
        WebLine(
          networkCode: network['code'] as String,
          networkName: network['name'] as String,
          code: line['code'] as String,
          name: line['name'] as String,
          colorHex: (line['color_hex'] as String?) ?? '#1E88E5',
          variants: webVariants,
        ),
      );
      stdout.writeln('· ${line['code']}: ${webVariants.length} recorridos');
    }

    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    return WebData(
      lines: result,
      updatedOn: '${two(now.day)}/${two(now.month)}/${now.year}',
    );
  } finally {
    client.close();
  }
}

/// La URL y la anon key: de las variables de entorno, o de `env.json`.
(String, String) _credentials() {
  var url = Platform.environment['SUPABASE_URL'];
  var key = Platform.environment['SUPABASE_ANON_KEY'];
  if ((url == null || key == null) && File('env.json').existsSync()) {
    final env =
        jsonDecode(File('env.json').readAsStringSync()) as Map<String, dynamic>;
    url ??= env['SUPABASE_URL'] as String?;
    key ??= env['SUPABASE_ANON_KEY'] as String?;
  }
  if (url == null || url.isEmpty || key == null || key.isEmpty) {
    stderr.writeln(
      'Faltan SUPABASE_URL y SUPABASE_ANON_KEY (env.json o variables de '
      'entorno). Es la anon key, la pública; nunca la service_role.',
    );
    exit(2);
  }
  return (url.replaceAll(RegExp(r'/+$'), ''), key);
}

String? _flag(List<String> args, String name) {
  final i = args.indexOf(name);
  return i >= 0 && i + 1 < args.length ? args[i + 1] : null;
}
