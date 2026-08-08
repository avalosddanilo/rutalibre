import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/rain_forecast_model.dart';

/// Contrato de la cache del pronóstico.
///
/// Mismo contrato de errores que la cache de transporte: el getter lanza
/// [CacheException] ante cache vacía, corrupta, vieja o de otro punto. Para
/// el repositorio las cuatro cosas significan lo mismo — "andá a la red".
abstract interface class WeatherLocalDataSource {
  /// El pronóstico guardado para [lat]/[lng], si tiene menos de [maxAge].
  ///
  /// [maxAge] lo decide QUIEN LLAMA y no está fijo acá porque no hay un solo
  /// valor correcto: el repositorio pregunta con una ventana corta para no
  /// salir a la red, y con una larga cuando la red ya falló y lo viejo es
  /// mejor que nada.
  Future<RainForecastModel> getCachedForecast({
    required double lat,
    required double lng,
    required Duration maxAge,
    required DateTime now,
  });

  Future<void> cacheForecast({
    required double lat,
    required double lng,
    required RainForecastModel forecast,
    required DateTime now,
  });
}

final class SharedPrefsWeatherLocalDataSource
    implements WeatherLocalDataSource {
  const SharedPrefsWeatherLocalDataSource(this._prefs);

  final SharedPreferences _prefs;

  /// **UNA sola entrada, no una por punto.** El pronóstico se pide para donde
  /// está el usuario, y guardar una entrada por cada punto por el que pasó
  /// haría crecer sin techo un archivo que `SharedPreferences` carga ENTERO
  /// al arrancar (ver `docs/arranque.md`). Pedir otro punto pisa el anterior:
  /// nadie mira el pronóstico de la ciudad donde estuvo ayer.
  ///
  /// El sufijo de versión va por lo mismo que en la cache de transporte: si
  /// cambia la forma de lo guardado, se sube el número. Sin eso, quien
  /// actualiza queda con un formato viejo que solo se salva porque el parseo
  /// falla y cae por la rama de "cache corrupta".
  static const _key = 'ruta_libre_weather_v1';

  /// Cuánto tiene que coincidir el punto guardado con el pedido para que
  /// sirva. Es más chico que el redondeo de `coarsePoint` (~1 km), así que en
  /// la práctica compara puntos ya redondeados: está para atajar el error de
  /// punto flotante, no para decidir cercanía.
  static const _samePointDegrees = 0.001;

  @override
  Future<RainForecastModel> getCachedForecast({
    required double lat,
    required double lng,
    required Duration maxAge,
    required DateTime now,
  }) async {
    final raw = _prefs.getString(_key);
    if (raw == null) {
      throw const CacheException('Sin pronóstico guardado');
    }

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final savedLat = (json['lat'] as num).toDouble();
      final savedLng = (json['lng'] as num).toDouble();
      if ((savedLat - lat).abs() > _samePointDegrees ||
          (savedLng - lng).abs() > _samePointDegrees) {
        throw const CacheException('El pronóstico guardado es de otro punto');
      }

      final savedAt = DateTime.parse(json['saved_at'] as String);
      // `isAfter` y no una resta: si el reloj del teléfono se corrió para
      // atrás, la diferencia da negativa y un `< maxAge` daría por fresco
      // algo de la semana pasada.
      if (savedAt.isAfter(now) || now.difference(savedAt) > maxAge) {
        throw const CacheException('El pronóstico guardado quedó viejo');
      }

      return RainForecastModel.fromCacheJson(json['hours'] as List<dynamic>);
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException('Pronóstico guardado ilegible: $e');
    }
  }

  @override
  Future<void> cacheForecast({
    required double lat,
    required double lng,
    required RainForecastModel forecast,
    required DateTime now,
  }) async {
    // Que no se pueda guardar NO es un error para quien llama: ya tiene el
    // pronóstico en la mano. Lo único que se pierde es no pedirlo de nuevo
    // la próxima vez.
    try {
      await _prefs.setString(
        _key,
        jsonEncode({
          'lat': lat,
          'lng': lng,
          'saved_at': now.toIso8601String(),
          'hours': forecast.toCacheJson(),
        }),
      );
    } catch (_) {
      // Disco lleno, permisos, lo que sea.
    }
  }
}
