import '../../../../core/utils/result.dart';
import '../entities/rain_forecast.dart';

/// Contrato del repositorio de clima.
///
/// Mismas reglas que `TransitRepository`: nunca lanza, todo error llega como
/// `Failure` adentro del `Either`.
abstract interface class WeatherRepository {
  /// Pronóstico de lluvia por hora para un punto.
  ///
  /// Va SIEMPRE a red, como `getNearbyStops`: depende de dónde está el
  /// usuario y de la hora. La cache que tiene sentido acá es de minutos, no
  /// de días, y vive en el provider (ver `rainForecastProvider`), no en
  /// disco.
  Result<RainForecast> getRainForecast({
    required double lat,
    required double lng,
  });
}
