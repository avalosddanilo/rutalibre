import 'package:flutter_test/flutter_test.dart';
import 'package:rutalibre/features/transit/domain/entities/service_frequency.dart';

ServiceFrequency? _f(
  String lineCode, {
  String network = 'interurbano-chaco-corrientes',
}) => frequencyFor(networkCode: network, lineCode: lineCode);

void main() {
  group('las bandas del pliego del 904', () {
    // Los números salen del Anexo II de la Res. 141/2017, transcritos en
    // docs/frecuencias-oficiales.md. Si alguien los toca sin cambiar el doc,
    // esto lo delata: el valor de este dato es que sea verificable.
    test('ramal A: cada 50 a 100 minutos', () {
      expect(_f('904A')!.shortestMinutes, 50);
      expect(_f('904A')!.longestMinutes, 100);
    });

    test('ramal B: cada 10 a 12 minutos', () {
      expect(_f('904B')!.formattedBand, 'cada 10 a 12 minutos');
    });

    test('ramal C: cada 12 a 15 minutos', () {
      expect(_f('904C')!.shortBand, 'cada 12 a 15 min');
    });

    test('la banda se muestra SIEMPRE con su fecha y su norma', () {
      final band = _f('904B')!;
      // Un dato de 2017 sin fecha se lee como si fuera de hoy. Es la misma
      // regla que la tarifa.
      expect(band.formattedValidity, 'según el pliego de diciembre de 2017');
      expect(band.source, contains('141/2017'));
      // Y por qué esa norma vale hoy: sin esto parece un antecedente
      // histórico y no la condición de lo que opera la empresa.
      expect(band.permitNote, contains('ERSA'));
    });

    test('el alcance dice hora pico y no promete el resto del día', () {
      // El pliego fija la banda solo para las "horas pico" y ni siquiera
      // define qué horas son.
      expect(_f('904A')!.scope, 'en hora pico');
    });
  });

  group('lo que NO tiene frecuencia', () {
    test('el resto del interurbano no tiene banda publicada', () {
      expect(_f('902'), isNull);
      expect(_f('904'), isNull);
    });

    test('ninguna línea del Gran Resistencia', () {
      // No hay norma que fije intervalos para las urbanas. Estimar una a
      // partir del largo del recorrido sería inventar un horario con otro
      // nombre.
      for (final code in ['3', '9', '10', '101']) {
        expect(_f(code, network: 'gran-resistencia'), isNull, reason: code);
      }
    });

    test('la clave lleva la RED: la 904A de otra red no existe', () {
      // El código de línea es único por red, no globalmente.
      expect(_f('904A', network: 'corrientes-capital'), isNull);
    });
  });

  test('una banda de un solo valor se dice en singular', () {
    // Ninguna del 904 es así hoy, pero el formato no puede decir "cada 12 a
    // 12 minutos" si algún día aparece una.
    final band = ServiceFrequency(
      shortestMinutes: 12,
      longestMinutes: 12,
      scope: 'en hora pico',
      source: 'una norma',
      permitNote: 'de algún permiso',
      validFrom: DateTime(2017, 12),
    );
    expect(band.formattedBand, 'cada 12 minutos');
    expect(band.shortBand, 'cada 12 min');
  });
}
