import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show ByteData, CachingAssetBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:rutalibre/core/errors/exceptions.dart';
import 'package:rutalibre/features/transit/data/datasources/places_asset_datasource.dart';
import 'package:rutalibre/features/transit/domain/entities/place.dart';

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

void main() {
  group('parseo', () {
    test('lee una lista de lugares', () async {
      final places = await AssetPlacesDataSource(
        _FakeBundle(
          jsonEncode({
            'v': 1,
            'p': [
              {
                'n': 'Hospital Perrando',
                'y': -27.45,
                'x': -58.98,
                'k': 'salud',
              },
            ],
          }),
        ),
      ).getPlaces();

      expect(places.single.name, 'Hospital Perrando');
      expect(places.single.kind, PlaceKind.salud);
      expect(places.single.lat, -27.45);
    });

    test('una fila rota se SALTEA en vez de tirar el asset entero', () async {
      final places = await AssetPlacesDataSource(
        _FakeBundle(
          jsonEncode({
            'v': 1,
            'p': [
              {'n': 'Bueno', 'y': -27.45, 'x': -58.98, 'k': 'salud'},
              {'n': 'Sin coordenada', 'k': 'salud'},
              {'roto': true},
            ],
          }),
        ),
      ).getPlaces();

      expect(places, hasLength(1));
      expect(places.single.name, 'Bueno');
    });

    test('una categoría desconocida cae en "otro", no revienta', () async {
      // Un asset nuevo con una categoría que esta versión de la app no
      // conoce todavía tiene que seguir funcionando.
      final places = await AssetPlacesDataSource(
        _FakeBundle(
          jsonEncode({
            'v': 1,
            'p': [
              {'n': 'X', 'y': -27.45, 'x': -58.98, 'k': 'categoria_del_futuro'},
            ],
          }),
        ),
      ).getPlaces();
      expect(places.single.kind, PlaceKind.otro);
    });

    test('sin asset lanza ParsingException', () {
      expect(
        AssetPlacesDataSource(_FakeBundle(null)).getPlaces,
        throwsA(isA<ParsingException>()),
      );
    });

    test('con basura adentro también', () {
      expect(
        AssetPlacesDataSource(_FakeBundle('esto no es json')).getPlaces,
        throwsA(isA<ParsingException>()),
      );
    });
  });

  group('el asset REAL del repo', () {
    // No usa rootBundle —que en tests no tiene los assets— sino el archivo
    // del disco. Lo que se verifica es que lo que genera el importador sea
    // exactamente lo que la app sabe leer: si el formato se desincroniza, el
    // buscador de destino se queda sin lugares y nadie se entera hasta que
    // alguien lo prueba en un teléfono.
    late List<Place> places;

    setUpAll(() async {
      places = await AssetPlacesDataSource(
        _FakeBundle(File('assets/places.json').readAsStringSync()),
      ).getPlaces();
    });

    test('tiene lugares de verdad', () {
      expect(places.length, greaterThan(2000));
    });

    test('todos tienen nombre y coordenada dibujable', () {
      for (final place in places) {
        expect(place.name.trim(), isNotEmpty);
        expect(place.lat.isFinite && place.lng.isFinite, isTrue);
        // Dentro del Gran Resistencia: si algo se coló de otra provincia, el
        // buscador lo ofrecería como destino de un colectivo urbano.
        expect(place.lat, inInclusiveRange(-27.54, -27.37));
        expect(place.lng, inInclusiveRange(-59.09, -58.74));
      }
    });

    test('hay de todas las categorías que la app sabe dibujar', () {
      final kinds = places.map((p) => p.kind).toSet();
      // `otro` puede no estar si el import cambia; el resto tiene que estar.
      for (final kind in PlaceKind.values) {
        if (kind == PlaceKind.otro) continue;
        expect(
          kinds,
          contains(kind),
          reason: 'falta la categoría ${kind.name}',
        );
      }
    });
  });
}
