import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:rutalibre/features/transit/presentation/utils/route_segment.dart';

/// Un recorrido recto de oeste a este sobre la misma latitud, con un vértice
/// cada 0,01°. Recto a propósito: lo que se prueba es el RECORTE, y una
/// geometría simple hace obvio qué pedazo tendría que quedar.
final _line = [for (var i = 0; i < 10; i++) LatLng(-27.45, -59.00 + i * 0.01)];

void main() {
  group('nearestVertexIndex', () {
    test('encuentra el vértice de al lado', () {
      expect(nearestVertexIndex(_line, -27.45, -59.00), 0);
      expect(nearestVertexIndex(_line, -27.45, -58.95), 5);
      expect(nearestVertexIndex(_line, -27.45, -58.91), 9);
    });

    test('un punto que no está sobre la línea cae en el más cercano', () {
      // Una parada nunca está exactamente sobre el trazado: está en la
      // vereda, a unos metros.
      expect(nearestVertexIndex(_line, -27.4512, -58.9698), 3);
    });
  });

  group('segmentBetween', () {
    List<LatLng> segment(double boardLng, double alightLng) => segmentBetween(
      points: _line,
      boardLat: -27.45,
      boardLng: boardLng,
      alightLat: -27.45,
      alightLng: alightLng,
    );

    test('devuelve SOLO el pedazo que se viaja', () {
      // Del vértice 2 al 5: cuatro puntos, no los diez.
      final result = segment(-58.98, -58.95);
      expect(result, hasLength(4));
      expect(result.first.longitude, closeTo(-58.98, 0.0001));
      expect(result.last.longitude, closeTo(-58.95, 0.0001));
    });

    test('el trazado entero seguía siendo lo que se dibujaba antes: esto es '
        'lo que cambia', () {
      // Cuatro cuadras de viaje sobre una línea de veinte kilómetros.
      expect(segment(-58.99, -58.98).length, lessThan(_line.length));
    });

    test('con la geometría al REVÉS devuelve el orden en que se viaja', () {
      // La bajada está antes que la subida en el arreglo de puntos: pasa
      // cuando el recorrido está cargado en el sentido contrario.
      final result = segment(-58.95, -58.98);
      expect(result.first.longitude, closeTo(-58.95, 0.0001));
      expect(result.last.longitude, closeTo(-58.98, 0.0001));
      expect(result, hasLength(4));
    });

    test('subir y bajar en el mismo vértice devuelve todo, no una lista '
        'vacía', () {
      // Dibujar de más es mucho mejor que dejar el mapa sin trazado.
      expect(segment(-58.98, -58.98), _line);
    });

    test('una geometría degenerada no revienta', () {
      expect(
        segmentBetween(
          points: const [],
          boardLat: -27.45,
          boardLng: -58.98,
          alightLat: -27.45,
          alightLng: -58.95,
        ),
        isEmpty,
      );
      expect(
        segmentBetween(
          points: [LatLng(-27.45, -58.98)],
          boardLat: -27.45,
          boardLng: -58.98,
          alightLat: -27.45,
          alightLng: -58.95,
        ),
        hasLength(1),
      );
    });

    test('las puntas del tramo son las paradas, no el final de la línea', () {
      // Es la garantía que hace que el dibujo se lea como un camino: empieza
      // donde subís y termina donde bajás.
      final result = segment(-58.97, -58.94);
      expect(nearestVertexIndex(result, -27.45, -58.97), 0);
      expect(nearestVertexIndex(result, -27.45, -58.94), result.length - 1);
    });
  });
}
