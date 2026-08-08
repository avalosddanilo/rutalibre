import '../../domain/entities/rain_forecast.dart';

/// DTO del `hourly` de Open-Meteo.
///
/// OJO CON LA FORMA: Open-Meteo no devuelve una lista de horas, devuelve
/// **arreglos paralelos** — uno de tiempos, uno de milímetros y uno de
/// probabilidades, alineados por índice:
///
/// ```json
/// "hourly": {
///   "time":                     ["2026-08-05T00:00", "2026-08-05T01:00"],
///   "precipitation":            [0.0, 1.4],
///   "precipitation_probability":[5, 80]
/// }
/// ```
///
/// Es eficiente para transmitir y fácil de leer mal: si un arreglo viene
/// más corto que el de tiempos (pasa cuando un modelo no publica alguna
/// variable), recorrer por el índice de `time` revienta. Por eso acá se
/// lee defensivamente y la hora faltante queda en cero.
final class RainForecastModel extends RainForecast {
  const RainForecastModel({required super.hours});

  factory RainForecastModel.fromJson(Map<String, dynamic> json) {
    final hourly = json['hourly'];
    if (hourly is! Map<String, dynamic>) {
      throw const FormatException('La respuesta no trae "hourly"');
    }

    final times = hourly['time'];
    if (times is! List) {
      throw const FormatException('La respuesta no trae "hourly.time"');
    }
    final millimeters = hourly['precipitation'];
    final probabilities = hourly['precipitation_probability'];

    T? at<T>(Object? list, int index) =>
        list is List && index < list.length ? list[index] as T? : null;

    return RainForecastModel(
      hours: [
        for (var i = 0; i < times.length; i++)
          RainHour(
            // Sin zona horaria: se pide `timezone=auto`, así que estos
            // tiempos ya vienen en la hora LOCAL del punto consultado.
            // Parsearlos como UTC los correría tres horas y "llueve en 40
            // min" pasaría a ser "llovió hace rato".
            time: DateTime.parse(times[i] as String),
            millimeters: (at<num>(millimeters, i) ?? 0).toDouble(),
            probabilityPercent: (at<num>(probabilities, i) ?? 0).round(),
          ),
      ],
    );
  }

  /// Lee lo que escribió [toCacheJson].
  ///
  /// **No reusa `fromJson`**: el JSON de la cache es nuestro y es plano, no
  /// los arreglos paralelos de Open-Meteo. Guardar la respuesta cruda para
  /// volver a parsearla con la misma lógica sería atarle el formato de disco
  /// a una API que no controlamos: el día que Open-Meteo cambie la forma,
  /// además de arreglar el parseo habría que migrar lo guardado.
  factory RainForecastModel.fromCacheJson(List<dynamic> hours) =>
      RainForecastModel(
        hours: [
          for (final raw in hours)
            if (raw case {
              't': final String t,
              'mm': final num mm,
              'p': final num p,
            })
              RainHour(
                time: DateTime.parse(t),
                millimeters: mm.toDouble(),
                probabilityPercent: p.round(),
              )
            else
              throw const FormatException('Hora de la cache con otra forma'),
        ],
      );

  /// Claves cortas a propósito: son ~48 horas por entrada y esto se guarda en
  /// `SharedPreferences`, que se carga ENTERO al arrancar.
  List<Map<String, Object?>> toCacheJson() => [
    for (final hour in hours)
      {
        't': hour.time.toIso8601String(),
        'mm': hour.millimeters,
        'p': hour.probabilityPercent,
      },
  ];
}
