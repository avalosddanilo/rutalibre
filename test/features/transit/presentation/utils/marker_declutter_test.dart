import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:rutalibre/features/transit/presentation/utils/marker_declutter.dart';

/// Plaza 25 de Mayo y puntos al este. A esta latitud 0,002° de longitud son
/// ~197 m: a zoom 17 eso son ~186 px (entran las dos) y a zoom 12 apenas
/// ~6 px (no entran).
const _origin = LatLng(-27.4519, -58.9865);
const _at197m = LatLng(-27.4519, -58.9845);

LatLng _itself(LatLng point) => point;

void main() {
  group('spreadOutMarkers', () {
    test('a zoom alto entran las dos paradas', () {
      expect(
        spreadOutMarkers(const [_origin, _at197m], location: _itself, zoom: 17),
        [_origin, _at197m],
      );
    });

    test('a zoom bajo la segunda se cae: se dibujarían encima', () {
      expect(
        spreadOutMarkers(const [_origin, _at197m], location: _itself, zoom: 12),
        [_origin],
      );
    });

    test('el orden manda: el que viene primero se queda con el lugar', () {
      expect(
        spreadOutMarkers(const [_at197m, _origin], location: _itself, zoom: 12),
        [_at197m],
      );
    });

    test('los puntos reservados ocupan lugar aunque no estén en la lista '
        '(las cabeceras del recorrido se dibujan siempre)', () {
      expect(
        spreadOutMarkers(
          const [_at197m],
          location: _itself,
          zoom: 12,
          reserved: const [_origin],
        ),
        isEmpty,
      );
    });

    test('con separación mínima cero no se descarta nada', () {
      expect(
        spreadOutMarkers(
          const [_origin, _origin, _origin],
          location: _itself,
          zoom: 5,
          minSeparation: 0,
        ),
        hasLength(3),
      );
    });

    test('una lista vacía no explota', () {
      expect(
        spreadOutMarkers(const <LatLng>[], location: _itself, zoom: 13),
        isEmpty,
      );
    });

    test('acercando el mapa reaparecen: no se pierde ninguna parada', () {
      final stops = [
        for (var i = 0; i < 20; i++) LatLng(-27.4519, -58.9865 + i * 0.0015),
      ];

      final far = spreadOutMarkers(stops, location: _itself, zoom: 12);
      final near = spreadOutMarkers(stops, location: _itself, zoom: 17);

      expect(far.length, lessThan(stops.length));
      expect(near, stops);
    });
  });

  group('nearestTo', () {
    // Cuatro paradas al este del origen, cada una más lejos que la anterior.
    const a = LatLng(-27.4519, -58.9860);
    const b = LatLng(-27.4519, -58.9850);
    const c = LatLng(-27.4519, -58.9840);
    const d = LatLng(-27.4519, -58.9830);

    test('devuelve las más cercanas, ordenadas', () {
      expect(
        nearestTo(
          const [d, b, c, a],
          origin: _origin,
          location: _itself,
          count: 3,
        ),
        [a, b, c],
      );
    });

    test('con menos elementos que el tope los devuelve todos', () {
      expect(
        nearestTo(const [b, a], origin: _origin, location: _itself, count: 10),
        [a, b],
      );
    });

    test('count 0 o negativo devuelve vacío', () {
      expect(
        nearestTo(const [a, b], origin: _origin, location: _itself, count: 0),
        isEmpty,
      );
      expect(
        nearestTo(const [a, b], origin: _origin, location: _itself, count: -1),
        isEmpty,
      );
    });

    test('NO saca por su cuenta lo que cae en el origen: una parada mapeada '
        'en el mismo punto que otra no debe desaparecer en silencio', () {
      expect(
        nearestTo(
          const [_origin, a],
          origin: _origin,
          location: _itself,
          count: 2,
        ),
        [_origin, a],
      );
    });
  });

  group('worldPixels', () {
    test('a zoom 0 el mundo entero es un tile de 256 px y el origen cae en '
        'el centro', () {
      final origin = worldPixels(const LatLng(0, 0), 0);
      expect(origin.x, closeTo(128, 0.001));
      expect(origin.y, closeTo(128, 0.001));
    });

    test('cada nivel de zoom duplica la escala', () {
      final z10 = worldPixels(_origin, 10);
      final z11 = worldPixels(_origin, 11);
      expect(z11.x, closeTo(z10.x * 2, 0.001));
      expect(z11.y, closeTo(z10.y * 2, 0.001));
    });

    test('el este crece en x y el norte decrece en y', () {
      final base = worldPixels(_origin, 13);
      expect(
        worldPixels(const LatLng(-27.4519, -58.98), 13).x,
        greaterThan(base.x),
      );
      expect(
        worldPixels(const LatLng(-27.44, -58.9865), 13).y,
        lessThan(base.y),
      );
    });

    test('los polos no producen NaN', () {
      expect(worldPixels(const LatLng(90, 0), 3).y.isFinite, isTrue);
      expect(worldPixels(const LatLng(-90, 0), 3).y.isFinite, isTrue);
    });
  });
}
