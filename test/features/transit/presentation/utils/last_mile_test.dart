import 'package:flutter_test/flutter_test.dart';
import 'package:rutalibre/features/transit/domain/entities/reference_stop.dart';
import 'package:rutalibre/features/transit/presentation/utils/last_mile.dart';

/// Donde te deja el 904, en el centro de Corrientes.
const _from = (lat: -27.4700, lng: -58.8380);

/// Un destino en el sur de Corrientes, a ~4 km: donde el planificador no llega.
const _to = (lat: -27.5000, lng: -58.7900);

ReferenceStop _stop(String name, double lat, double lng, List<String> lines) =>
    ReferenceStop(name: name, lat: lat, lng: lng, lines: lines);

void main() {
  group('suggestLastMile', () {
    test('encuentra la línea que para cerca de las DOS puntas', () {
      final stops = [
        _stop('Centro A', -27.4705, -58.8382, ['101', '103A']),
        _stop('Sur B', -27.5003, -58.7902, ['103A', '110B']),
      ];

      final suggestion = suggestLastMile(
        stops: stops,
        fromLat: _from.lat,
        fromLng: _from.lng,
        toLat: _to.lat,
        toLng: _to.lng,
      );

      expect(suggestion, isNotNull);
      expect(suggestion!.lines, ['103A']);
      expect(suggestion.boardStop.name, 'Centro A');
      expect(suggestion.alightStop.name, 'Sur B');
    });

    test('entre dos que sirven, gana la parada más cercana al destino', () {
      final stops = [
        _stop('Centro A', -27.4705, -58.8382, ['103A']),
        _stop('Sur lejos', -27.5030, -58.7920, ['103A']),
        _stop('Sur cerca', -27.5001, -58.7901, ['103A']),
      ];

      final suggestion = suggestLastMile(
        stops: stops,
        fromLat: _from.lat,
        fromLng: _from.lng,
        toLat: _to.lat,
        toLng: _to.lng,
      );

      expect(suggestion!.alightStop.name, 'Sur cerca');
    });

    test('sin línea en común no inventa: null', () {
      final stops = [
        _stop('Centro A', -27.4705, -58.8382, ['101']),
        _stop('Sur B', -27.5003, -58.7902, ['110B']),
      ];

      expect(
        suggestLastMile(
          stops: stops,
          fromLat: _from.lat,
          fromLng: _from.lng,
          toLat: _to.lat,
          toLng: _to.lng,
        ),
        isNull,
      );
    });

    test('una parada a más de 500 m de una punta no cuenta', () {
      final stops = [
        // ~1,1 km del punto de bajada.
        _stop('Centro lejos', -27.4800, -58.8380, ['103A']),
        _stop('Sur B', -27.5003, -58.7902, ['103A']),
      ];

      expect(
        suggestLastMile(
          stops: stops,
          fromLat: _from.lat,
          fromLng: _from.lng,
          toLat: _to.lat,
          toLng: _to.lng,
        ),
        isNull,
      );
    });

    test('sin paradas de referencia (fuera de Corrientes) no sugiere nada', () {
      expect(
        suggestLastMile(
          stops: const [],
          fromLat: _from.lat,
          fromLng: _from.lng,
          toLat: _to.lat,
          toLng: _to.lng,
        ),
        isNull,
      );
    });
  });

  test(
    'linesNear junta las líneas de todas las paradas cercanas, sin repetir',
    () {
      final stops = [
        _stop('Sur B', -27.5003, -58.7902, ['110B', '103A']),
        _stop('Sur C', -27.4998, -58.7898, ['103A', '105C']),
        _stop('Lejos', -27.5200, -58.7900, ['999']),
      ];

      expect(linesNear(stops: stops, lat: _to.lat, lng: _to.lng), [
        '103A',
        '105C',
        '110B',
      ]);
    },
  );
}
