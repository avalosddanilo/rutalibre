/// Descargas de Overpass, compartidas por los dos importadores.
///
/// Overpass es un servicio comunitario y gratuito, y se satura seguido: se
/// prueban dos endpoints y se puede cachear la respuesta para iterar un
/// importador sin volver a castigarlo.
library;

import 'dart:convert';
import 'dart:io';

const overpassEndpoints = [
  'https://overpass-api.de/api/interpreter',
  'https://overpass.kumi.systems/api/interpreter',
];

/// Descarga de Overpass, o lee del cache si existe (para iterar el
/// importer sin castigar un servicio público y gratuito).
Future<Map<String, dynamic>> loadOverpass({
  required String label,
  required String query,
  String? cachePath,
}) async {
  if (cachePath != null) {
    final cached = File(cachePath);
    if (cached.existsSync()) {
      stdout.writeln('· $label: usando cache $cachePath');
      return jsonDecode(await cached.readAsString()) as Map<String, dynamic>;
    }
  }

  Object? lastError;
  for (final endpoint in overpassEndpoints) {
    try {
      stdout.writeln('· $label: consultando $endpoint ...');
      final body = await _post(endpoint, query);
      final json = jsonDecode(body) as Map<String, dynamic>;
      if (cachePath != null) {
        final cached = File(cachePath);
        await cached.parent.create(recursive: true);
        await cached.writeAsString(body);
      }
      return json;
    } catch (error) {
      // Overpass es un servicio comunitario y se satura seguido: si un
      // endpoint contesta HTML de error o corta, se prueba el siguiente.
      stdout.writeln('  falló ($error), pruebo el próximo endpoint');
      lastError = error;
    }
  }
  throw StateError('No se pudo descargar $label de Overpass: $lastError');
}

Future<String> _post(String endpoint, String query) async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 30);
  try {
    final request = await client.postUrl(Uri.parse(endpoint));
    request.headers.set(
      HttpHeaders.contentTypeHeader,
      'application/x-www-form-urlencoded',
    );
    // Identificarse es parte de la política de uso de Overpass.
    request.headers.set(
      HttpHeaders.userAgentHeader,
      'RutaLibre-import/1.0 (+https://github.com/rutalibre)',
    );
    request.write('data=${Uri.encodeQueryComponent(query)}');

    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    if (response.statusCode != 200) {
      throw HttpException('HTTP ${response.statusCode}');
    }
    if (body.trimLeft().startsWith('<')) {
      throw const FormatException('Overpass devolvió HTML (servidor ocupado)');
    }
    return body;
  } finally {
    client.close();
  }
}
