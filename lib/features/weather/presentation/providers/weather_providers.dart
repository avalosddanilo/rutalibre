import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../../core/providers/clock_provider.dart';
import '../../../../core/providers/shared_preferences_provider.dart';
import '../../data/datasources/weather_local_datasource.dart';
import '../../data/datasources/weather_remote_datasource.dart';
import '../../data/repositories/weather_repository_impl.dart';
import '../../domain/entities/rain_forecast.dart';
import '../../domain/repositories/weather_repository.dart';
import '../../domain/usecases/get_rain_forecast.dart';

/// Composition root del feature weather.

final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final weatherRemoteDataSourceProvider = Provider<WeatherRemoteDataSource>(
  (ref) => OpenMeteoWeatherRemoteDataSource(ref.watch(httpClientProvider)),
);

final weatherLocalDataSourceProvider = Provider<WeatherLocalDataSource>(
  (ref) =>
      SharedPrefsWeatherLocalDataSource(ref.watch(sharedPreferencesProvider)),
);

final weatherRepositoryProvider = Provider<WeatherRepository>(
  (ref) => WeatherRepositoryImpl(
    remoteDataSource: ref.watch(weatherRemoteDataSourceProvider),
    localDataSource: ref.watch(weatherLocalDataSourceProvider),
    clock: ref.watch(clockProvider),
  ),
);

final getRainForecastProvider = Provider<GetRainForecast>(
  (ref) => GetRainForecast(ref.watch(weatherRepositoryProvider)),
);

/// Punto para pedir el pronóstico. Record por el == estructural del family.
typedef ForecastPoint = ({double lat, double lng});

/// Redondea a ~1 km. El pronóstico tiene resolución de 1-2 km, así que
/// pedirlo con seis decimales sería una entrada de cache distinta por cada
/// temblor del GPS y la misma respuesta.
ForecastPoint coarsePoint(double lat, double lng) => (
  lat: double.parse(lat.toStringAsFixed(2)),
  lng: double.parse(lng.toStringAsFixed(2)),
);

/// Cuánto vale un pronóstico antes de volver a pedirlo. Los modelos de
/// Open-Meteo se actualizan cada 1-3 horas: consultar más seguido que esto
/// gasta llamadas para recibir lo mismo.
const forecastFreshness = Duration(minutes: 20);

/// El pronóstico de lluvia de un punto.
///
/// `autoDispose` CON `keepAlive` temporal: sin el keepAlive se pediría de
/// nuevo cada vez que se abre la hoja de viajes (son varias veces por
/// minuto mientras uno decide); sin el autoDispose quedaría cacheado para
/// siempre y a las tres horas estaría mintiendo.
final rainForecastProvider = FutureProvider.autoDispose
    .family<RainForecast, ForecastPoint>((ref, point) async {
      final link = ref.keepAlive();
      final timer = Timer(forecastFreshness, link.close);
      ref.onDispose(timer.cancel);

      final result = await ref.watch(getRainForecastProvider)(
        GetRainForecastParams(lat: point.lat, lng: point.lng),
      );
      return result.fold((failure) => throw failure, (forecast) => forecast);
    });
