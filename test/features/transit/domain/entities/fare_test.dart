import 'package:flutter_test/flutter_test.dart';
import 'package:rutalibre/features/transit/domain/entities/fare.dart';

void main() {
  group('formattedAmount — formato argentino', () {
    Fare fare(double amount) =>
        Fare(amount: amount, validFrom: DateTime(2026), source: 'x');

    test('punto para los miles', () {
      expect(fare(1885).formattedAmount, r'$1.885');
      expect(fare(890).formattedAmount, r'$890');
      expect(fare(12345).formattedAmount, r'$12.345');
      expect(fare(1234567).formattedAmount, r'$1.234.567');
    });

    test('coma para los decimales, y solo si los hay', () {
      expect(fare(2921.10).formattedAmount, r'$2.921,10');
      expect(fare(1890).formattedAmount, r'$1.890');
      expect(fare(1890.5).formattedAmount, r'$1.890,50');
    });
  });

  group('formattedValidity', () {
    test('mes y año, nunca el día: nadie decide nada con el día', () {
      expect(
        Fare(
          amount: 1885,
          validFrom: DateTime(2026, 1, 12),
          source: 'x',
        ).formattedValidity,
        'vigente desde enero de 2026',
      );
    });

    test('los doce meses están escritos', () {
      for (var m = 1; m <= 12; m++) {
        final texto = Fare(
          amount: 1,
          validFrom: DateTime(2026, m),
          source: 'x',
        ).formattedValidity;
        expect(texto, isNot(contains('null')));
        expect(texto, contains('2026'));
      }
    });
  });

  group('fareFor', () {
    test('la tarifa de la red', () {
      final gr = fareFor(networkCode: 'gran-resistencia', lineCode: '3')!;
      expect(gr.formattedAmount, r'$1.885');
      expect(gr.formattedValidity, 'vigente desde enero de 2026');
      expect(gr.source, 'Diario Chaco');
    });

    test('el 904A cobra distinto que su red y GANA la excepción', () {
      // Errarle acá es errarle por mil pesos justo en el que más sale.
      final red = fareFor(
        networkCode: 'interurbano-chaco-corrientes',
        lineCode: '904B',
      )!;
      final campus = fareFor(
        networkCode: 'interurbano-chaco-corrientes',
        lineCode: '904A',
      )!;

      expect(red.formattedAmount, r'$1.890');
      expect(campus.formattedAmount, r'$2.921,10');
    });

    test('sin tarifa conocida devuelve null, NO un precio inventado', () {
      expect(
        fareFor(networkCode: 'corrientes-capital', lineCode: '101'),
        isNull,
      );
      expect(fareFor(networkCode: 'interurbano-chaco', lineCode: '1'), isNull);
    });

    test('el código de línea se resuelve DENTRO de su red', () {
      // '904A' es una línea del interurbano; el mismo código en otra red no
      // tiene por qué heredar su excepción.
      expect(
        fareFor(networkCode: 'gran-resistencia', lineCode: '904A')?.amount,
        1885,
      );
    });
  });

  group('networkHasFareExceptions', () {
    test('avisa que la tarifa de la red no vale para todas sus líneas', () {
      expect(networkHasFareExceptions('interurbano-chaco-corrientes'), isTrue);
      expect(networkHasFareExceptions('gran-resistencia'), isFalse);
    });
  });

  test('TODA tarifa conocida tiene fecha y fuente', () {
    // La regla del archivo: no se puede mostrar un precio anónimo o sin
    // fecha. Esto lo verifica sobre los datos reales, no sobre el tipo.
    for (final red in ['gran-resistencia', 'interurbano-chaco-corrientes']) {
      final fare = networkFareFor(red)!;
      expect(fare.source, isNotEmpty);
      expect(fare.validFrom.year, greaterThanOrEqualTo(2026));
      expect(fare.formattedValidity, contains('vigente desde'));
    }
  });
}
