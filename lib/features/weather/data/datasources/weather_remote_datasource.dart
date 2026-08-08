import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../../core/errors/exceptions.dart';
import '../models/rain_forecast_model.dart';

/// Contrato del datasource remoto de clima. Habla en MODELOS y lanza
/// EXCEPCIONES, igual que el de transporte.
abstract interface class WeatherRemoteDataSource {
  Future<RainForecastModel> getRainForecast({
    required double lat,
    required double lng,
  });
}

/// Implementación contra Open-Meteo.
///
/// Por qué Open-Meteo y no otro: **gratis y sin API key**. Es el mismo
/// criterio por el que el mapa usa OpenStreetMap y no Mapbox — una app que
/// tiene que poder correr sin que nadie pague ni administre credenciales.
///
/// ⚠️ El tier gratuito es para uso NO COMERCIAL. Ruta Libre es gratuita y de
/// interés público, así que entra; si algún día se monetiza, hay que pasar
/// al plan pago. Está anotado también en ARCHITECTURE.md.
final class OpenMeteoWeatherRemoteDataSource
    implements WeatherRemoteDataSource {
  const OpenMeteoWeatherRemoteDataSource(this._client);

  final http.Client _client;

  static const _host = 'api.open-meteo.com';
  static const _path = '/v1/forecast';

  /// Un pronóstico que tarda más que esto no sirve para decidir si salir.
  static const _timeout = Duration(seconds: 8);

  @override
  Future<RainForecastModel> getRainForecast({
    required double lat,
    required double lng,
  }) async {
    final uri = Uri.https(_host, _path, {
      'latitude': lat.toStringAsFixed(4),
      'longitude': lng.toStringAsFixed(4),
      'hourly': 'precipitation,precipitation_probability',
      // Dos días y no uno: a las 22 h, "las próximas seis horas" cruzan la
      // medianoche y con un solo día el pronóstico se corta.
      'forecast_days': '2',
      // La API devuelve los tiempos en la hora LOCAL del punto. Sin esto
      // vendrían en UTC y "llueve en 40 min" saldría corrido tres horas.
      'timezone': 'auto',
    });

    final http.Response response;
    try {
      response = await _client.get(uri).timeout(_timeout);
    } on SocketException {
      throw const NetworkException('Sin conexión para consultar el clima');
    } on TimeoutException {
      throw const NetworkException('El pronóstico tardó demasiado');
    } catch (e) {
      throw ServerException('Error consultando el clima: $e');
    }

    if (response.statusCode != 200) {
      throw ServerException(
        'El servicio de clima respondió ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }

    try {
      return RainForecastModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } catch (e) {
      throw ParsingException('Pronóstico con formato inesperado: $e');
    }
  }
}
