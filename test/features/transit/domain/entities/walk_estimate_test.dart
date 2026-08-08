import 'package:flutter_test/flutter_test.dart';
import 'package:rutalibre/features/transit/domain/entities/walk_estimate.dart';

/// Plaza 25 de Mayo, Resistencia.
const _plaza = (lat: -27.4519, lng: -58.9865);

void main() {
  group('distancia', () {
    test('mide bien sobre la esfera', () {
      // 0,001° de latitud son ~111 m en cualquier parte del planeta.
      final estimate = WalkEstimate.between(
        fromLat: _plaza.lat,
        fromLng: _plaza.lng,
        toLat: _plaza.lat + 0.001,
        toLng: _plaza.lng,
      );
      expect(estimate.meters, closeTo(111, 1));
    });

    test('el mismo punto da cero', () {
      final estimate = WalkEstimate.between(
        fromLat: _plaza.lat,
        fromLng: _plaza.lng,
        toLat: _plaza.lat,
        toLng: _plaza.lng,
      );
      expect(estimate.meters, closeTo(0, 0.01));
      // Pero el tiempo tiene piso de un minuto: "0 min" no es una respuesta.
      expect(estimate.duration, const Duration(minutes: 1));
    });

    test('es simétrica', () {
      final ida = WalkEstimate.between(
        fromLat: -27.45,
        fromLng: -58.98,
        toLat: -27.46,
        toLng: -58.99,
      );
      final vuelta = WalkEstimate.between(
        fromLat: -27.46,
        fromLng: -58.99,
        toLat: -27.45,
        toLng: -58.98,
      );
      expect(ida.meters, closeTo(vuelta.meters, 0.001));
    });
  });

  group('tiempo', () {
    test('cuenta lo que se CAMINA, no la línea recta', () {
      // Nadie atraviesa las manzanas: 300 m de recta son ~390 caminados.
      const estimate = WalkEstimate(meters: 300);
      expect(estimate.walkedMeters, closeTo(390, 0.1));
      // 390 m a 1,35 m/s son 289 s = 4,8 min → 5.
      expect(estimate.duration, const Duration(minutes: 5));
    });

    test('redondea HACIA ARRIBA: quedarse corto manda a alguien tarde', () {
      // 100 m → 130 caminados → 96 s → 1,6 min. Hacia abajo daría 1.
      expect(
        const WalkEstimate(meters: 100).duration,
        const Duration(minutes: 2),
      );
    });

    test('nunca dice cero minutos', () {
      expect(const WalkEstimate(meters: 0).duration.inMinutes, 1);
      expect(const WalkEstimate(meters: 5).duration.inMinutes, 1);
    });

    test('una caminata larga se expresa en horas', () {
      // 5 km de recta → 6,5 km caminados → 80,25 min → 81.
      expect(const WalkEstimate(meters: 5000).formattedDuration, '1 h 21 min');
    });

    test('una hora justa no dice "1 h 0 min"', () {
      // Se busca el valor que da exactamente 60 minutos.
      const meters =
          60 * 60 * WalkEstimate.metersPerSecond / WalkEstimate.detourFactor;
      expect(const WalkEstimate(meters: meters).formattedDuration, '1 h');
    });
  });

  group('formato', () {
    test('metros abajo del kilómetro', () {
      expect(const WalkEstimate(meters: 350).formattedDistance, '350 m');
    });

    test('kilómetros con coma decimal, como se escribe en castellano', () {
      expect(const WalkEstimate(meters: 1234).formattedDistance, '1,2 km');
    });

    test('la etiqueta NO promete precisión que la cuenta no tiene', () {
      // Es una recta por una velocidad promedio, no un ruteo por veredas.
      // Igual que el aviso de lluvia, el texto lo dice.
      // 350 m de recta → 455 caminados → 5,6 min → 6.
      final label = const WalkEstimate(meters: 350).label;
      expect(label, 'A 350 m · unos 6 min caminando');
      expect(label, contains('unos'));
    });
  });

  test('dos estimaciones de la misma distancia son iguales', () {
    expect(const WalkEstimate(meters: 350), const WalkEstimate(meters: 350));
  });
}
