import 'package:flutter_test/flutter_test.dart';
import 'package:rutalibre/features/weather/data/models/rain_forecast_model.dart';
import 'package:rutalibre/features/weather/domain/entities/rain_forecast.dart';
import 'package:rutalibre/features/weather/presentation/utils/rain_advisory.dart';

/// Las 14:00 de un día cualquiera. Todo se mide contra esto.
final _now = DateTime(2026, 8, 5, 14, 30);

RainHour _hour(int hour, double mm) => RainHour(
  time: DateTime(2026, 8, 5, hour),
  millimeters: mm,
  probabilityPercent: mm > 0 ? 80 : 5,
);

/// Un día seco, para ir mojando horas puntuales.
RainForecast _forecast(Map<int, double> wetHours) => RainForecast(
  hours: [for (var h = 0; h < 24; h++) _hour(h, wetHours[h] ?? 0)],
);

void main() {
  group('RainHour.intensity', () {
    test('los dos umbrales', () {
      // 0,1 mm no moja a nadie; 0,2 sí; 2,5 ya no es una llovizna.
      expect(_hour(14, 0.1).intensity, RainIntensity.none);
      expect(_hour(14, 0.2).intensity, RainIntensity.light);
      expect(_hour(14, 2.4).intensity, RainIntensity.light);
      expect(_hour(14, 2.5).intensity, RainIntensity.strong);
    });
  });

  group('hourAt', () {
    test('mira la hora EN CURSO, no la siguiente', () {
      // 14:30 cae dentro de la hora de las 14.
      expect(
        _forecast({14: 3.0}).hourAt(_now)?.intensity,
        RainIntensity.strong,
      );
      expect(_forecast({15: 3.0}).hourAt(_now)?.intensity, RainIntensity.none);
    });

    test('null si el pronóstico no trae la hora en curso', () {
      expect(const RainForecast(hours: []).hourAt(_now), isNull);
    });
  });

  group('wettestHour', () {
    test('se queda con la PEOR hora, no con la primera', () {
      // Si a las 15 chispea y a las 17 cae un temporal, avisar por la chispa
      // sería quedarse corto.
      expect(_forecast({15: 0.3, 17: 8.0}).wettestHour(_now)?.time.hour, 17);
    });

    test('cuenta la hora en curso', () {
      expect(_forecast({14: 4.0}).wettestHour(_now)?.time.hour, 14);
    });

    test('null si no se espera nada', () {
      expect(_forecast(const {}).wettestHour(_now), isNull);
    });

    test('IGNORA las horas ya pasadas: la API manda el día entero desde las '
        '00:00, así que a la tarde media respuesta es vieja', () {
      expect(_forecast({6: 5.0}).wettestHour(_now), isNull);
    });

    test('no mira más allá del horizonte de 6 horas', () {
      // 23:00 está a 8h30 de las 14:30; 20:00 entra justo.
      expect(_forecast({23: 4.0}).wettestHour(_now), isNull);
      expect(_forecast({20: 4.0}).wettestHour(_now)?.time.hour, 20);
    });
  });

  group('rainAdvisory', () {
    test('sin lluvia no dice nada: la tira no tiene que ocupar lugar', () {
      expect(rainAdvisory(_forecast(const {}), _now), isNull);
    });

    test('lloviendo fuerte ahora: la afirmación completa', () {
      final aviso = rainAdvisory(_forecast({14: 4.0}), _now)!;
      expect(aviso.headline, 'Llueve fuerte.');
      expect(aviso.detail, 'Suele haber menos unidades y demoras.');
    });

    test('una llovizna NO afirma que haya menos unidades', () {
      // La parte honesta del asunto: la afirmación fuerte se guarda para
      // cuando el pronóstico la banca.
      final aviso = rainAdvisory(_forecast({14: 0.4}), _now)!;
      expect(aviso.headline, 'Está lloviendo.');
      expect(aviso.detail, 'Puede haber demoras.');
      expect(aviso.detail, isNot(contains('unidades')));
    });

    test('lluvia que viene: se avisa en futuro, no en presente', () {
      final aviso = rainAdvisory(_forecast({17: 5.0}), _now)!;
      expect(aviso.headline, 'Se espera lluvia fuerte.');
    });

    test('lo que llueve AHORA manda sobre lo que viene después', () {
      // Llueve poco ahora y mucho más tarde: el titular tiene que hablar del
      // presente, que es lo que la persona ve por la ventana.
      final aviso = rainAdvisory(_forecast({14: 0.3, 18: 9.0}), _now)!;
      expect(aviso.headline, 'Está lloviendo.');
    });

    test('NUNCA promete un dato en vivo del servicio', () {
      // No tenemos esa fuente: es el dato de la Fase 2. Un número inventado
      // sería peor que el silencio.
      for (final mm in [0.3, 4.0]) {
        for (final hora in [14, 17]) {
          final aviso = rainAdvisory(_forecast({hora: mm}), _now)!;
          final texto = '${aviso.headline} ${aviso.detail}';
          expect(texto, isNot(matches(RegExp(r'\d'))));
          expect(texto.toLowerCase(), isNot(contains('ahora')));
          expect(texto.toLowerCase(), isNot(contains('en este momento')));
        }
      }
    });

    test('la probabilidad sale de la MISMA hora que manda el aviso', () {
      // El bicho que esto evita: mostrar la probabilidad de una hora y la
      // intensidad de otra, y quedar diciendo "llueve fuerte, 5%".
      final forecast = RainForecast(
        hours: [
          _hour(14, 0), // seca: no manda
          RainHour(
            time: DateTime(2026, 8, 5, 17),
            millimeters: 6.0,
            probabilityPercent: 95,
          ),
        ],
      );
      final aviso = rainAdvisory(forecast, _now)!;
      expect(aviso.headline, 'Se espera lluvia fuerte.');
      expect(aviso.probabilityPercent, 95);
      expect(aviso.hasProbability, isTrue);
    });

    test('sin probabilidad publicada NO se muestra un 0%', () {
      // Open-Meteo no la publica en todos sus modelos y el parseo la deja en
      // cero. "0%" al lado de una gotita mientras llueve se lee como que la
      // app está rota.
      final forecast = RainForecast(
        hours: [
          RainHour(
            time: DateTime(2026, 8, 5, 14),
            millimeters: 4.0,
            probabilityPercent: 0,
          ),
        ],
      );
      final aviso = rainAdvisory(forecast, _now)!;
      expect(aviso.headline, 'Llueve fuerte.');
      expect(aviso.hasProbability, isFalse);
    });
  });

  group('RainForecastModel.fromJson', () {
    test('lee los arreglos PARALELOS de Open-Meteo', () {
      final model = RainForecastModel.fromJson({
        'hourly': {
          'time': ['2026-08-05T00:00', '2026-08-05T01:00'],
          'precipitation': [0.0, 1.4],
          'precipitation_probability': [5, 80],
        },
      });

      expect(model.hours, hasLength(2));
      expect(model.hours[1].millimeters, 1.4);
      expect(model.hours[1].probabilityPercent, 80);
      expect(model.hours[1].isWet, isTrue);
    });

    test('los tiempos se leen como hora LOCAL, no UTC', () {
      // Se pide `timezone=auto`: si esto se parseara como UTC, todo el
      // pronóstico se correría tres horas y "llueve en 40 min" sería
      // "llovió hace rato".
      final model = RainForecastModel.fromJson({
        'hourly': {
          'time': ['2026-08-05T14:00'],
          'precipitation': [1.0],
          'precipitation_probability': [90],
        },
      });

      expect(model.hours.single.time.hour, 14);
      expect(model.hours.single.time.isUtc, isFalse);
    });

    test('un arreglo más corto que el de tiempos NO revienta', () {
      // Pasa cuando un modelo no publica alguna variable.
      final model = RainForecastModel.fromJson({
        'hourly': {
          'time': ['2026-08-05T00:00', '2026-08-05T01:00'],
          'precipitation': [0.5],
        },
      });

      expect(model.hours, hasLength(2));
      expect(model.hours[1].millimeters, 0);
      expect(model.hours[1].probabilityPercent, 0);
    });

    test('una respuesta sin "hourly" aborta con un error claro', () {
      expect(
        () => RainForecastModel.fromJson({'error': true}),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => RainForecastModel.fromJson({'hourly': <String, dynamic>{}}),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
