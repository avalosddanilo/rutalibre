import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_map_vector_tiles/flutter_map_vector_tiles.dart' as vt;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:rutalibre/features/transit/data/map/bundled_map.dart';

/// El tile de [zoom] que contiene el punto, como lo numera el mapa.
vt.TileKey _tileAt(double lat, double lng, int zoom) {
  final n = 1 << zoom;
  final x = ((lng + 180) / 360 * n).floor();
  final rad = lat * math.pi / 180;
  final y =
      ((1 - math.log(math.tan(rad) + 1 / math.cos(rad)) / math.pi) / 2 * n)
          .floor();
  return vt.TileKey(zoom, x, y);
}

void main() {
  group('BytesRangeClient', () {
    final bytes = Uint8List.fromList(List.generate(100, (i) => i));

    test('contesta un rango con esos bytes y 206', () async {
      final r = await BytesRangeClient(
        bytes,
      ).get(Uri.parse('asset:x'), headers: {'range': 'bytes=10-14'});
      expect(r.statusCode, 206);
      expect(r.bodyBytes, [10, 11, 12, 13, 14]);
    });

    test('un rango que se pasa del final se corta en el final', () async {
      final r = await BytesRangeClient(
        bytes,
      ).get(Uri.parse('asset:x'), headers: {'range': 'bytes=95-16383'});
      expect(r.statusCode, 206);
      expect(r.bodyBytes, [95, 96, 97, 98, 99]);
    });

    test('un rango que empieza después del final es 416', () async {
      final r = await BytesRangeClient(
        bytes,
      ).get(Uri.parse('asset:x'), headers: {'range': 'bytes=200-300'});
      expect(r.statusCode, 416);
    });

    test('sin rango, el archivo entero', () async {
      final r = await BytesRangeClient(bytes).get(Uri.parse('asset:x'));
      expect(r.statusCode, 200);
      expect(r.bodyBytes.length, 100);
    });

    test('el lector de PMTiles le pide en minúscula y igual se entiende', () {
      // http normaliza los nombres de encabezado: "Range" y "range" son el
      // mismo. Si un día no, este test lo dice antes que un mapa en blanco.
      final request = http.Request('GET', Uri.parse('asset:x'))
        ..headers['Range'] = 'bytes=0-1';
      expect(request.headers['range'], 'bytes=0-1');
    });
  });

  group('el archivo que viaja en la app', () {
    late vt.VectorTileProvider archive;

    setUpAll(() async {
      archive = await openArchive(
        File(bundledMapArchive).readAsBytesSync(),
        name: bundledMapArchive,
      );
    });

    tearDownAll(() => archive.dispose());

    test('va hasta zoom 15 y no se copia a la cache de disco', () {
      expect(archive.maximumZoom, 15);
      expect(archive.cacheBytesToDisk, isFalse);
    });

    // Las puntas de la red: si una queda afuera del archivo, ahí el mapa
    // sale vacío. Los extremos de los recorridos, según la base (st_extent
    // de route_variants), más las dos plazas centrales.
    for (final (name, lat, lng) in [
      ('Plaza 25 de Mayo, Resistencia', -27.4512, -58.9867),
      ('Plaza 25 de Mayo, Corrientes', -27.4660, -58.8336),
      ('el punto más al norte de un recorrido', -27.3128, -58.95),
      ('el punto más al sur de un recorrido', -27.5826, -58.85),
      ('el punto más al oeste de un recorrido', -27.45, -59.0999),
      ('el punto más al este de un recorrido', -27.47, -58.6900),
    ]) {
      test('tiene calles en $name', () async {
        final response = await archive.load(_tileAt(lat, lng, 15));
        expect(response, isA<vt.TileResponseData>(), reason: name);
        expect((response as vt.TileResponseData).bytes, isNotEmpty);
      });
    }

    test('lejos de las dos ciudades no hay tiles (y no rompe)', () async {
      final response = await archive.load(_tileAt(-34.6037, -58.3816, 15));
      expect(response, isA<vt.TileResponseNotFound>());
    });
  });

  group('los estilos', () {
    for (final asset in [bundledMapLightStyle, bundledMapDarkStyle]) {
      test('$asset se lee entero y apunta a la fuente del archivo', () {
        final json =
            jsonDecode(File(asset).readAsStringSync()) as Map<String, dynamic>;
        expect((json['sources'] as Map).keys, ['protomaps']);
        // Sin sprites ni glyphs: los dos serían pedidos por red.
        expect(json.containsKey('sprite'), isFalse);
        expect(json.containsKey('glyphs'), isFalse);
        final warnings = <String>[];
        final theme = vt.ThemeReader(
          logger: vt.Logger.custom(onWarn: warnings.add),
        ).read(json);
        expect(theme.layers, hasLength((json['layers'] as List).length));
        expect(warnings, isEmpty);
      });
    }

    test('claro y oscuro son temas distintos', () {
      String id(String asset) => vt.ThemeReader()
          .read(
            jsonDecode(File(asset).readAsStringSync()) as Map<String, dynamic>,
          )
          .id;
      expect(id(bundledMapLightStyle), isNot(id(bundledMapDarkStyle)));
    });
  });
}
