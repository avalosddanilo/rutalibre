import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/rain_forecast.dart';
import '../repositories/weather_repository.dart';

/// "¿Me voy a mojar esperando el colectivo?"
final class GetRainForecast
    implements UseCase<RainForecast, GetRainForecastParams> {
  const GetRainForecast(this._repository);

  final WeatherRepository _repository;

  @override
  Result<RainForecast> call(GetRainForecastParams params) =>
      _repository.getRainForecast(lat: params.lat, lng: params.lng);
}

final class GetRainForecastParams extends Equatable {
  const GetRainForecastParams({required this.lat, required this.lng})
    : assert(lat >= -90 && lat <= 90, 'lat fuera de rango WGS84'),
      assert(lng >= -180 && lng <= 180, 'lng fuera de rango WGS84');

  final double lat;
  final double lng;

  @override
  List<Object?> get props => [lat, lng];
}
