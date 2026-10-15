import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rutalibre/core/diagnostics/diagnostics_log.dart';

void main() {
  late SharedPreferences prefs;
  final now = DateTime(2026, 10, 15, 8, 30, 5);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  DiagnosticsLog log() => DiagnosticsLog(prefs, now: () => now);

  group('nunca guarda una ubicación', () {
    test('un número con pinta de coordenada se tapa', () {
      expect(
        DiagnosticsLog.sanitize('fix en -27.46321, -58.98540 ok'),
        'fix en [n], [n] ok',
      );
    });

    test('la URL del pronóstico pierde latitude y longitude', () {
      final clean = DiagnosticsLog.sanitize(
        'HttpException: https://api.open-meteo.com/v1/forecast?'
        'latitude=-27.4512&longitude=-58.9867&hourly=rain',
      );
      expect(clean, isNot(contains('27.45')));
      expect(clean, isNot(contains('58.98')));
      expect(clean, contains('latitude=[n]'));
      expect(clean, contains('hourly=rain'));
    });

    test('tampoco a través de un error guardado', () {
      log().recordError(
        StateError('posición -27.48385,-58.79109 fuera de ruta'),
        StackTrace.current,
      );
      final saved = log().entries.single;
      expect(saved, isNot(contains('27.48')));
      expect(saved, contains('StateError'));
    });
  });

  test('guarda la hora y el evento, y el detalle limpio', () {
    log().record('alarma_armada');
    log().record('servicio_viaje', 'rechazado');
    expect(log().entries, [
      '2026-10-15 08:30:05 alarma_armada',
      '2026-10-15 08:30:05 servicio_viaje rechazado',
    ]);
  });

  test('se queda con los últimos ${DiagnosticsLog.maxEntries}', () {
    final l = log();
    for (var i = 0; i < DiagnosticsLog.maxEntries + 25; i++) {
      l.record('evento', i);
    }
    expect(l.entries, hasLength(DiagnosticsLog.maxEntries));
    expect(l.entries.first, endsWith('evento 25'));
    expect(
      l.entries.last,
      endsWith('evento ${DiagnosticsLog.maxEntries + 24}'),
    );
  });

  test('lo que se manda dice qué es y qué no tiene', () {
    final l = log()..record('alarma_suena');
    final text = l.export(version: '1.3.0');
    expect(text, startsWith('Diagnóstico de Ruta Libre 1.3.0'));
    expect(text, contains('Sin ubicación'));
    expect(text, contains('alarma_suena'));
  });

  test('borrar deja el registro vacío', () async {
    final l = log()..record('algo');
    await l.clear();
    expect(l.entries, isEmpty);
    expect(l.export(), contains('(sin eventos registrados)'));
  });

  test('sin preferencias no guarda nada, y no falla', () {
    final l = DiagnosticsLog.disabled()..record('algo');
    expect(l.entries, isEmpty);
  });
}
