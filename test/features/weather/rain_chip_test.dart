import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rutalibre/app/theme/app_theme.dart';
import 'package:rutalibre/core/errors/failures.dart';
import 'package:rutalibre/core/providers/clock_provider.dart';
import 'package:rutalibre/core/utils/result.dart';
import 'package:rutalibre/features/weather/domain/entities/rain_forecast.dart';
import 'package:rutalibre/features/weather/domain/repositories/weather_repository.dart';
import 'package:rutalibre/features/weather/presentation/providers/weather_providers.dart';
import 'package:rutalibre/features/weather/presentation/widgets/rain_chip.dart';

final _now = DateTime(2026, 8, 5, 14, 30);

/// Devuelve siempre lo mismo. No hace falta mocktail para un contrato de un
/// solo método.
class _FakeWeatherRepository implements WeatherRepository {
  _FakeWeatherRepository(this.answer);

  _FakeWeatherRepository.failing()
    : answer = const Left(NetworkFailure(message: 'sin señal'));

  final Either<Failure, RainForecast> answer;

  @override
  Result<RainForecast> getRainForecast({
    required double lat,
    required double lng,
  }) async => answer;
}

RainForecast _forecast(Map<int, (double mm, int prob)> wetHours) =>
    RainForecast(
      hours: [
        for (var h = 0; h < 24; h++)
          RainHour(
            time: DateTime(2026, 8, 5, h),
            millimeters: wetHours[h]?.$1 ?? 0,
            probabilityPercent: wetHours[h]?.$2 ?? 5,
          ),
      ],
    );

Future<void> _pump(
  WidgetTester tester, {
  required WeatherRepository repository,
  Brightness brightness = Brightness.light,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      // El mismo `retry` que main.dart: sin esto, el caso de error entra en
      // el reintento automático de Riverpod 3 y `pumpAndSettle` se queda
      // esperando sus timers hasta el timeout.
      retry: (retryCount, error) => error is Failure
          ? null
          : ProviderContainer.defaultRetry(retryCount, error),
      overrides: [
        weatherRepositoryProvider.overrideWithValue(repository),
        clockProvider.overrideWithValue(() => _now),
      ],
      child: MaterialApp(
        theme: brightness == Brightness.dark ? AppTheme.dark : AppTheme.light,
        home: const Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: RainChip(lat: -27.4519, lng: -58.9865),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  // `rainForecastProvider` arma un Timer de `forecastFreshness` para soltar
  // su keepAlive. Como el widget lo sigue escuchando, el provider no se
  // dispone al terminar el test y el timer queda pendiente — que es lo que el
  // framework marca como fuga. Adelantar el reloj lo hace disparar; el dato
  // queda igual porque el listener sigue vivo.
  await tester.pump(forecastFreshness);
}

void main() {
  testWidgets('sin lluvia no dibuja NADA: los días de sol el mapa queda '
      'limpio', (tester) async {
    await _pump(
      tester,
      repository: _FakeWeatherRepository(Right(_forecast(const {}))),
    );
    expect(find.byType(Text), findsNothing);
    expect(find.byType(Icon), findsNothing);
  });

  testWidgets('si el pronóstico FALLA tampoco dibuja nada: no saber si '
      'llueve no puede romperle la pantalla a nadie', (tester) async {
    await _pump(tester, repository: _FakeWeatherRepository.failing());
    expect(find.byType(Text), findsNothing);
  });

  testWidgets('cerrado muestra la probabilidad y NADA del servicio', (
    tester,
  ) async {
    await _pump(
      tester,
      repository: _FakeWeatherRepository(Right(_forecast({14: (5.0, 80)}))),
    );
    expect(find.text('80%'), findsOneWidget);
    // La advertencia está guardada hasta que la pidan: cerrado, el chip no
    // ocupa el mapa con una frase.
    expect(find.textContaining('demoras'), findsNothing);
  });

  testWidgets('tocándolo aparece la advertencia, y de nuevo se cierra', (
    tester,
  ) async {
    await _pump(
      tester,
      repository: _FakeWeatherRepository(Right(_forecast({14: (5.0, 80)}))),
    );

    await tester.tap(find.text('80%'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Llueve fuerte.'), findsOneWidget);
    expect(
      find.textContaining('Suele haber menos unidades y demoras.'),
      findsOneWidget,
    );

    await tester.tap(find.text('80%'));
    await tester.pumpAndSettle();
    expect(find.textContaining('demoras'), findsNothing);
  });

  testWidgets('una llovizna NO afirma que haya menos unidades', (tester) async {
    await _pump(
      tester,
      repository: _FakeWeatherRepository(Right(_forecast({14: (0.4, 45)}))),
    );
    expect(find.text('45%'), findsOneWidget);
    await tester.tap(find.text('45%'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Está lloviendo.'), findsOneWidget);
    expect(find.textContaining('unidades'), findsNothing);
  });

  testWidgets('sin probabilidad publicada no dibuja un 0%', (tester) async {
    await _pump(
      tester,
      repository: _FakeWeatherRepository(Right(_forecast({14: (5.0, 0)}))),
    );
    expect(find.text('0%'), findsNothing);
    expect(find.byIcon(Icons.grain), findsOneWidget);
  });

  testWidgets('se dibuja igual en dark mode', (tester) async {
    await _pump(
      tester,
      repository: _FakeWeatherRepository(Right(_forecast({14: (5.0, 80)}))),
      brightness: Brightness.dark,
    );
    expect(find.text('80%'), findsOneWidget);
  });
}
