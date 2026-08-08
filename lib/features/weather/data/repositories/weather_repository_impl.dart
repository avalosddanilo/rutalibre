import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/rain_forecast.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/weather_local_datasource.dart';
import '../datasources/weather_remote_datasource.dart';
import '../models/rain_forecast_model.dart';

final class WeatherRepositoryImpl implements WeatherRepository {
  const WeatherRepositoryImpl({
    required WeatherRemoteDataSource remoteDataSource,
    required WeatherLocalDataSource localDataSource,
    required DateTime Function() clock,
  }) : _remote = remoteDataSource,
       _local = localDataSource,
       _now = clock;

  final WeatherRemoteDataSource _remote;
  final WeatherLocalDataSource _local;
  final DateTime Function() _now;

  /// Dentro de esta ventana NO se sale a la red.
  ///
  /// Los modelos de Open-Meteo se actualizan cada 1-3 horas, así que 45
  /// minutos no pierde nada de precisión y corta la mayor parte de los
  /// pedidos: sin esto se pedía uno por cada arranque en frío, porque el chip
  /// del mapa está en la primera pantalla. El tier gratuito no comercial son
  /// 10.000 llamadas por día — ver `docs/auditoria-seguridad.md`.
  static const freshness = Duration(minutes: 45);

  /// Hasta acá un pronóstico guardado sigue sirviendo **si la red falló**.
  ///
  /// Es mucho más largo que [freshness] a propósito: son dos preguntas
  /// distintas. La primera es "¿vale la pena volver a pedirlo?"; esta es
  /// "¿esto todavía dice algo cierto?". Un pronóstico por HORA de hace tres
  /// horas sigue cubriendo el rato que viene con el modelo de hace tres
  /// horas, y eso es mejor que no mostrar nada arriba del colectivo sin
  /// señal. Más allá de seis, el pronóstico ya casi no le queda futuro
  /// adentro: se prefiere el silencio.
  static const staleButUsable = Duration(hours: 6);

  @override
  Result<RainForecast> getRainForecast({
    required double lat,
    required double lng,
  }) async {
    final now = _now();

    // 1. Guardado y reciente: se responde sin tocar la red.
    try {
      return Right(
        await _local.getCachedForecast(
          lat: lat,
          lng: lng,
          maxAge: freshness,
          now: now,
        ),
      );
    } on CacheException {
      // Vacía, vieja, de otro punto o ilegible: todas significan "andá a la
      // red". Es el camino esperado, no un error.
    }

    // 2. A la red, y se guarda para la próxima.
    final RainForecastModel fresh;
    try {
      fresh = await _remote.getRainForecast(lat: lat, lng: lng);
    } on AppException catch (e) {
      // 3. La red falló: sirve lo guardado aunque ya no esté fresco. Si
      //    tampoco hay, se devuelve el error de la RED y no el de la cache —
      //    "sin conexión" explica lo que pasó; "no se pudieron leer los datos
      //    guardados" manda a mirar donde no está el problema.
      try {
        return Right(
          await _local.getCachedForecast(
            lat: lat,
            lng: lng,
            maxAge: staleButUsable,
            now: now,
          ),
        );
      } on CacheException {
        return Left(_toFailure(e));
      }
    }

    await _local.cacheForecast(lat: lat, lng: lng, forecast: fresh, now: now);
    return Right(fresh);
  }

  /// La misma traducción 1:1 que hace `TransitRepositoryImpl`. Se repite en
  /// vez de compartirse porque cada feature es dueño de su capa data; el día
  /// que un tercer feature la necesite, se gradúa a `core/`.
  Failure _toFailure(AppException exception) => switch (exception) {
    ServerException(:final message, :final statusCode) => ServerFailure(
      message: message,
      statusCode: statusCode,
    ),
    CacheException(:final message) => CacheFailure(message: message),
    NetworkException(:final message) => NetworkFailure(message: message),
    ParsingException(:final message) => DataParsingFailure(message: message),
  };
}
