/// El mapa base viaja adentro de la app.
///
/// **Por qué.** Hasta la 1.3 las calles se bajaban de los servidores de
/// OpenStreetMap, tile por tile. Eso tenía tres problemas:
/// - Sin señal el mapa quedaba gris, justo en la parada, que es donde más
///   falta hace (el planificador ya andaba sin conexión; el mapa no).
/// - La política de esos servidores prohíbe guardar tiles para usarlos sin
///   conexión, y avisa que pueden cortar el acceso a una app sin previo
///   aviso. Una app con miles de usuarios no puede colgar de eso.
/// - Cada vistazo al mapa gastaba datos de quien lo usa.
///
/// Las dos ciudades enteras, con calles hasta el último pasaje, pesan ~5 MB
/// en un archivo PMTiles (ver `docs/mapa.md` para cómo se genera). Eso entra
/// en la app y se lee de memoria: cero red, cero espera.
library;

import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map_vector_tiles/flutter_map_vector_tiles.dart' as vt;
import 'package:http/http.dart' as http;

const bundledMapArchive = 'assets/map/gran-resistencia-corrientes.pmtiles';
const bundledMapLightStyle = 'assets/map/estilo-claro.json';
const bundledMapDarkStyle = 'assets/map/estilo-oscuro.json';

/// El id de la fuente en los estilos (`sources.protomaps`).
const _sourceId = 'protomaps';

/// El mapa listo para dibujar: un estilo para cada modo, sobre el mismo
/// archivo.
class BundledMap {
  const BundledMap({required this.light, required this.dark});

  final vt.Style light;
  final vt.Style dark;

  void dispose() {
    light.dispose();
    dark.dispose();
  }
}

/// Lee el archivo y los dos estilos de los assets.
Future<BundledMap> loadBundledMap() async {
  final data = await rootBundle.load(bundledMapArchive);
  final archive = await openArchive(
    data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
    name: bundledMapArchive,
  );
  Future<vt.Style> style(String asset) => vt.StyleReader(
    uri: 'asset://$asset',
    // Es un asset: no hay nada que guardar en disco ni que refrescar.
    cache: false,
    resolveProvider: (id) async => id == _sourceId ? archive : null,
  ).read();
  return BundledMap(
    light: await style(bundledMapLightStyle),
    dark: await style(bundledMapDarkStyle),
  );
}

/// Abre un PMTiles que ya está en memoria.
///
/// El lector del paquete pide el archivo por rangos de bytes, como a un
/// servidor; [BytesRangeClient] le contesta esos pedidos desde [bytes]. Así
/// se reusa el lector probado del paquete en vez de escribir otro.
Future<vt.VectorTileProvider> openArchive(
  Uint8List bytes, {
  required String name,
}) async => _LocalArchive(
  await vt.PmTilesVectorTileProvider.open(
    'asset:$name',
    client: BytesRangeClient(bytes),
  ),
);

/// Contesta pedidos `Range: bytes=a-b` desde un archivo en memoria.
class BytesRangeClient extends http.BaseClient {
  BytesRangeClient(this._bytes);

  final Uint8List _bytes;

  static final _range = RegExp(r'^bytes=(\d+)-(\d+)$');

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final match = _range.firstMatch(request.headers['range'] ?? '');
    if (match == null) {
      return http.StreamedResponse(
        Stream.value(_bytes),
        200,
        contentLength: _bytes.length,
        request: request,
      );
    }
    final start = int.parse(match[1]!);
    final end = math.min(int.parse(match[2]!), _bytes.length - 1);
    if (start > end) {
      return http.StreamedResponse(const Stream.empty(), 416, request: request);
    }
    final slice = Uint8List.sublistView(_bytes, start, end + 1);
    return http.StreamedResponse(
      Stream.value(slice),
      206,
      contentLength: slice.length,
      request: request,
    );
  }
}

/// El archivo ya está en el teléfono: que la librería no lo copie tile por
/// tile a su cache de disco (sería guardar dos veces lo mismo).
class _LocalArchive extends vt.VectorTileProvider {
  _LocalArchive(this._inner);

  final vt.VectorTileProvider _inner;

  @override
  int get maximumZoom => _inner.maximumZoom;

  @override
  int get minimumZoom => _inner.minimumZoom;

  @override
  String get cacheKey => _inner.cacheKey;

  @override
  bool get cacheBytesToDisk => false;

  @override
  Future<vt.TileResponse> load(
    vt.TileKey tile, {
    vt.CancellationToken? cancellation,
  }) => _inner.load(tile, cancellation: cancellation);

  @override
  void dispose() => _inner.dispose();
}
