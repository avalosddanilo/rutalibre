import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';

import '../../tools/src/gauss_kruger.dart';
import '../../tools/src/geometry.dart';

/// Estos tests son la red de seguridad de una conversión que, si se rompe,
/// falla EN SILENCIO: los recorridos siguen dibujándose, pero en el lugar
/// equivocado del planeta. Por eso se valida contra lugares reales.
void main() {
  group('gaussKrugerToWgs84 — puntos de control reales de Corrientes', () {
    // Extremos del recorrido "PUERTO - AEROPUERTO" (Aerobus) tal como
    // vienen en el CSV del portal municipal.
    const inicioAerobus = (
      easting: 5614867.555384401,
      northing: 6962661.9005853105,
    );
    const finAerobus = (easting: 5622773.0, northing: 6964022.0);

    test('el inicio del Aerobus cae sobre el puerto de Corrientes', () {
      final p = gaussKrugerToWgs84(
        inicioAerobus.easting,
        inicioAerobus.northing,
      );
      const puerto = (lat: -27.4665, lng: -58.8353);
      expect(haversineMeters(p, puerto), lessThan(1500));
    });

    test('el fin del Aerobus cae en dirección al aeropuerto', () {
      final p = gaussKrugerToWgs84(finAerobus.easting, finAerobus.northing);
      // Debe estar claramente al ESTE del puerto (el aeropuerto lo está).
      expect(p.lng, greaterThan(-58.80));
      expect(p.lat, greaterThan(-27.50));
      expect(p.lat, lessThan(-27.40));
    });

    test('todo el bbox del dataset cae sobre el área de Corrientes', () {
      final sw = gaussKrugerToWgs84(5613448, 6949147);
      final ne = gaussKrugerToWgs84(5629500, 6968057);
      expect(sw.lat, inInclusiveRange(-27.65, -27.35));
      expect(ne.lat, inInclusiveRange(-27.65, -27.35));
      expect(sw.lng, inInclusiveRange(-58.95, -58.65));
      expect(ne.lng, inInclusiveRange(-58.95, -58.65));
      // El norteo mayor tiene que dar una latitud MENOS negativa (más al norte).
      expect(ne.lat, greaterThan(sw.lat));
      // El esteo mayor, una longitud menos negativa (más al este).
      expect(ne.lng, greaterThan(sw.lng));
    });

    test('sobre el meridiano central el esteo falso da longitud -60', () {
      final p = gaussKrugerToWgs84(5500000, 6962661);
      expect(p.lng, closeTo(-60.0, 0.0001));
    });

    test('es monótona: mover 1 km al este mueve al este, no al oeste', () {
      final a = gaussKrugerToWgs84(5614867, 6962661);
      final b = gaussKrugerToWgs84(5615867, 6962661);
      expect(b.lng, greaterThan(a.lng));
      // Y ese kilómetro proyectado tiene que medir ~1 km en el terreno.
      expect(haversineMeters(a, b), closeTo(1000, 20));
    });
  });

  test('la conversión es estable (misma entrada, misma salida)', () {
    final a = gaussKrugerToWgs84(5620000, 6960000);
    final b = gaussKrugerToWgs84(5620000, 6960000);
    expect(a.lat, a.lat.isNaN ? isNaN : b.lat);
    expect(a.lng, b.lng);
    expect(a.lat.isNaN, isFalse);
    expect(a.lng.isNaN, isFalse);
    expect(a.lat.abs(), lessThan(90));
    expect(a.lng.abs(), lessThan(180));
    expect(math.max(a.lat, a.lng).isFinite, isTrue);
  });
}
