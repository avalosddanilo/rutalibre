import 'package:flutter_test/flutter_test.dart';
import 'package:rutalibre/core/errors/exceptions.dart';
import 'package:rutalibre/core/errors/failures.dart';
import 'package:rutalibre/features/weather/data/datasources/weather_local_datasource.dart';
import 'package:rutalibre/features/weather/data/datasources/weather_remote_datasource.dart';
import 'package:rutalibre/features/weather/data/models/rain_forecast_model.dart';
import 'package:rutalibre/features/weather/data/repositories/weather_repository_impl.dart';
import 'package:rutalibre/features/weather/domain/entities/rain_forecast.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _lat = -27.45;
const _lng = -58.99;
final _now = DateTime(2026, 8, 5, 14, 30);

RainForecastModel _forecast({double mm = 3.0, int prob = 80}) =>
    RainForecastModel(
      hours: [
        RainHour(
          time: DateTime(2026, 8, 5, 14),
          millimeters: mm,
          probabilityPercent: prob,
        ),
      ],
    );

/// Cuenta los pedidos: lo que se está probando es justamente cuántas veces se
/// sale a la red.
class _CountingRemote implements WeatherRemoteDataSource {
  _CountingRemote({this.failure});

  final AppException? failure;
  int calls = 0;

  @override
  Future<RainForecastModel> getRainForecast({
    required double lat,
    required double lng,
  }) async {
    calls++;
    if (failure != null) throw failure!;
    return _forecast();
  }
}

WeatherRepositoryImpl _repo(
  WeatherRemoteDataSource remote,
  WeatherLocalDataSource local, {
  DateTime? now,
}) => WeatherRepositoryImpl(
  remoteDataSource: remote,
  localDataSource: local,
  clock: () => now ?? _now,
);

void main() {
  late SharedPreferences prefs;
  late SharedPrefsWeatherLocalDataSource local;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    local = SharedPrefsWeatherLocalDataSource(prefs);
  });

  group('SharedPrefsWeatherLocalDataSource', () {
    Future<RainForecastModel> read({
      double lat = _lat,
      double lng = _lng,
      Duration maxAge = const Duration(minutes: 45),
      DateTime? now,
    }) => local.getCachedForecast(
      lat: lat,
      lng: lng,
      maxAge: maxAge,
      now: now ?? _now,
    );

    test('sin nada guardado lanza CacheException', () {
      expect(read, throwsA(isA<CacheException>()));
    });

    test('lo guardado vuelve igual', () async {
      await local.cacheForecast(
        lat: _lat,
        lng: _lng,
        forecast: _forecast(mm: 4.2, prob: 77),
        now: _now,
      );

      final leido = await read();
      expect(leido.hours, hasLength(1));
      expect(leido.hours.single.millimeters, 4.2);
      expect(leido.hours.single.probabilityPercent, 77);
      expect(leido.hours.single.time, DateTime(2026, 8, 5, 14));
    });

    test('más viejo que maxAge NO sirve', () async {
      await local.cacheForecast(
        lat: _lat,
        lng: _lng,
        forecast: _forecast(),
        now: _now,
      );
      // 46 minutos después, con una ventana de 45.
      expect(
        () => read(now: _now.add(const Duration(minutes: 46))),
        throwsA(isA<CacheException>()),
      );
      // Con la ventana larga, la misma entrada sí sirve.
      expect(
        await read(
          now: _now.add(const Duration(minutes: 46)),
          maxAge: const Duration(hours: 6),
        ),
        isA<RainForecastModel>(),
      );
    });

    test('un reloj corrido para ATRÁS no da por fresco algo viejo', () async {
      // Si esto se calculara con una resta, la diferencia daría negativa y
      // pasaría el `< maxAge`.
      await local.cacheForecast(
        lat: _lat,
        lng: _lng,
        forecast: _forecast(),
        now: _now,
      );
      expect(
        () => read(now: _now.subtract(const Duration(days: 3))),
        throwsA(isA<CacheException>()),
      );
    });

    test('el pronóstico de OTRO punto no se reusa', () async {
      await local.cacheForecast(
        lat: _lat,
        lng: _lng,
        forecast: _forecast(),
        now: _now,
      );
      expect(
        () => read(lat: -31.42, lng: -64.18),
        throwsA(isA<CacheException>()),
      );
    });

    test('guardar otro punto PISA el anterior: una sola entrada', () async {
      await local.cacheForecast(
        lat: _lat,
        lng: _lng,
        forecast: _forecast(),
        now: _now,
      );
      await local.cacheForecast(
        lat: -31.42,
        lng: -64.18,
        forecast: _forecast(),
        now: _now,
      );

      expect(prefs.getKeys().where((k) => k.contains('weather')), hasLength(1));
      expect(read, throwsA(isA<CacheException>()));
    });

    test('cache corrupta se comporta como cache vacía', () async {
      await prefs.setString('ruta_libre_weather_v1', 'esto no es json');
      expect(read, throwsA(isA<CacheException>()));
    });

    test('no se puede guardar → NO explota: quien llama ya tiene el dato', () {
      expect(
        () => local.cacheForecast(
          lat: _lat,
          lng: _lng,
          forecast: _forecast(),
          now: _now,
        ),
        returnsNormally,
      );
    });
  });

  group('WeatherRepositoryImpl — cuántas veces sale a la red', () {
    test('la primera vez pide; la segunda NO', () async {
      final remote = _CountingRemote();
      final repo = _repo(remote, local);

      await repo.getRainForecast(lat: _lat, lng: _lng);
      expect(remote.calls, 1);

      await repo.getRainForecast(lat: _lat, lng: _lng);
      expect(remote.calls, 1, reason: 'el segundo tiene que salir de disco');
    });

    test('pasada la ventana de 45 min vuelve a pedir', () async {
      final remote = _CountingRemote();
      await _repo(remote, local).getRainForecast(lat: _lat, lng: _lng);
      expect(remote.calls, 1);

      final despues = _now
          .add(WeatherRepositoryImpl.freshness)
          .add(const Duration(minutes: 1));
      await _repo(
        remote,
        local,
        now: despues,
      ).getRainForecast(lat: _lat, lng: _lng);
      expect(remote.calls, 2);
    });

    test('sin red pero con algo guardado: se muestra lo viejo', () async {
      // Se llena la cache con una corrida exitosa.
      await _repo(
        _CountingRemote(),
        local,
      ).getRainForecast(lat: _lat, lng: _lng);

      // Tres horas después, sin señal: pasó la ventana de 45 min, así que
      // intenta la red, falla, y cae en lo guardado.
      final caido = _CountingRemote(
        failure: const NetworkException('sin señal'),
      );
      final resultado = await _repo(
        caido,
        local,
        now: _now.add(const Duration(hours: 3)),
      ).getRainForecast(lat: _lat, lng: _lng);

      expect(caido.calls, 1);
      expect(resultado.isRight(), isTrue);
    });

    test('sin red y con lo guardado DEMASIADO viejo: falla', () async {
      await _repo(
        _CountingRemote(),
        local,
      ).getRainForecast(lat: _lat, lng: _lng);

      final resultado = await _repo(
        _CountingRemote(failure: const NetworkException('sin señal')),
        local,
        // Más allá de staleButUsable (6 h).
        now: _now.add(const Duration(hours: 7)),
      ).getRainForecast(lat: _lat, lng: _lng);

      expect(resultado.isLeft(), isTrue);
    });

    test('sin red y sin nada guardado devuelve el error de la RED, no el de '
        'la cache', () async {
      // "Sin conexión" explica lo que pasó; "no se pudieron leer los datos
      // guardados" manda a mirar donde no está el problema.
      final resultado = await _repo(
        _CountingRemote(failure: const NetworkException('sin señal')),
        local,
      ).getRainForecast(lat: _lat, lng: _lng);

      expect(resultado.getLeft().toNullable(), isA<NetworkFailure>());
    });
  });
}
