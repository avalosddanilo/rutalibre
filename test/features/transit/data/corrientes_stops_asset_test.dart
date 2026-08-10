import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show ByteData, CachingAssetBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:rutalibre/features/transit/data/datasources/corrientes_stops_datasource.dart';
import 'package:rutalibre/features/transit/domain/entities/reference_stop.dart';

/// Un bundle que sirve lo que se le diga, sin tocar el asset real.
class _FakeBundle extends CachingAssetBundle {
  _FakeBundle(this.content);

  final String? content;

  @override
  Future<ByteData> load(String key) async {
    final text = content;
    if (text == null) throw StateError('asset no encontrado: $key');
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(text)));
  }
}

Future<List<ReferenceStop>> _parse(Object json) =>
    AssetCorrientesStopsDataSource(_FakeBundle(jsonEncode(json))).getStops();

void main() {
  group('parseo', () {
    test('lee el nodo de OSM del asset v2', () async {
      final stops = await _parse({
        'v': 2,
        's': [
          {
            'i': 2286343843,
            'n': 'Perón y Dumas',
            'y': -27.49,
            'x': -58.78,
            'l': ['102'],
          },
        ],
      });

      expect(stops.single.name, 'Perón y Dumas');
      expect(stops.single.osmNodeId, 2286343843);
    });

    test('un asset v1 —sin nodo— sigue dando paradas, solo sin enlace', () {
      // La versión vieja del asset no traía `i`. Si el nodo fuera obligatorio,
      // una app nueva con un asset viejo se quedaría con CERO paradas de
      // Corrientes en vez de con 254 sin enlace a OSM.
      expect(
        _parse({
          'v': 1,
          's': [
            {
              'n': 'Perón y Dumas',
              'y': -27.49,
              'x': -58.78,
              'l': ['102'],
            },
          ],
        }),
        completion(
          isA<List<ReferenceStop>>()
              .having((s) => s.length, 'cantidad', 1)
              .having((s) => s.single.osmNodeId, 'nodo', isNull),
        ),
      );
    });
  });

  group('el asset REAL del repo', () {
    late List<ReferenceStop> stops;

    setUpAll(() async {
      // El archivo del disco y no rootBundle, igual que en el test de lugares:
      // lo que se verifica es que lo que emite el importador sea exactamente
      // lo que la app sabe leer.
      stops = await AssetCorrientesStopsDataSource(
        _FakeBundle(File('assets/corrientes_stops.json').readAsStringSync()),
      ).getStops();
    });

    test('tiene las paradas de Corrientes', () {
      expect(stops, hasLength(254));
    });

    test('TODAS traen su nodo de OSM', () {
      // Es lo que habilita "corregila en OpenStreetMap". Una sola parada sin
      // nodo sería una que nadie puede arreglar.
      for (final stop in stops) {
        expect(stop.osmNodeId, isNotNull, reason: 'sin nodo: ${stop.name}');
        expect(stop.osmNodeId, greaterThan(0));
      }
    });

    test('sin nodos repetidos', () {
      final ids = stops.map((s) => s.osmNodeId).toSet();
      expect(ids, hasLength(stops.length));
    });

    test('todas del lado correntino del río y con líneas declaradas', () {
      for (final stop in stops) {
        expect(stop.lines, isNotEmpty);
        expect(stop.lat, inInclusiveRange(-27.62, -27.32));
        // El límite oeste con el que el importador separa Corrientes del Gran
        // Resistencia.
        expect(stop.lng, greaterThan(-58.9));
      }
    });
  });
}
