import '../../domain/entities/rain_forecast.dart';

/// Lo que hay para decir sobre la lluvia: un dato y una advertencia.
///
/// **La distinción entre los dos campos es la regla de honestidad de todo
/// esto, y por eso son campos separados y no un párrafo.**
///
/// * [probabilityPercent] es un DATO: sale tal cual de Open-Meteo.
/// * [headline] y [detail] son una ADVERTENCIA GENERAL. Que con lluvia
///   suele haber menos unidades y más demoras es cierto siempre, no es una
///   medición de este momento. **No tenemos ninguna fuente de cuántos coches
///   están circulando** —ese es el dato de la Fase 2— así que el texto habla
///   de lo que *suele* pasar y nunca de lo que *está* pasando.
class RainAdvisory {
  const RainAdvisory({
    required this.headline,
    required this.detail,
    required this.probabilityPercent,
    required this.intensity,
  });

  /// Qué está pasando con el tiempo. Verificable contra el pronóstico.
  final String headline;

  /// Qué suele significar para el servicio. Es una generalidad, y está
  /// redactada como tal a propósito.
  final String detail;

  /// Probabilidad de precipitación de la hora que manda el aviso, 0-100.
  final int probabilityPercent;

  final RainIntensity intensity;

  /// Open-Meteo no publica la probabilidad en todos sus modelos, y cuando
  /// falta el parseo la deja en cero. Un "0%" al lado de una gotita mientras
  /// llueve se lee como que la app está rota: mejor mostrar la gotita sola.
  bool get hasProbability => probabilityPercent > 0;
}

/// La advertencia que corresponde, o null si no hay nada que advertir.
///
/// Manda lo que llueve AHORA sobre lo que viene después: es lo que la persona
/// ve por la ventana, y un titular en futuro mientras le cae agua encima se
/// lee como que la app no se enteró.
///
/// El reclamo se GRADÚA con la intensidad, que es la otra parte honesta: una
/// llovizna no baja frecuencias, así que con lluvia débil se dice "puede
/// haber demoras" y nada sobre las unidades. La afirmación fuerte se guarda
/// para cuando el pronóstico la banca.
RainAdvisory? rainAdvisory(RainForecast forecast, DateTime now) {
  final current = forecast.hourAt(now);
  final raining = current != null && current.isWet;
  final hour = raining ? current : forecast.wettestHour(now);
  if (hour == null) return null;

  final strong = hour.intensity == RainIntensity.strong;
  return RainAdvisory(
    headline: switch ((raining, strong)) {
      (true, true) => 'Llueve fuerte.',
      (true, false) => 'Está lloviendo.',
      (false, true) => 'Se espera lluvia fuerte.',
      (false, false) => 'Se espera lluvia.',
    },
    detail: strong
        ? 'Suele haber menos unidades y demoras.'
        : 'Puede haber demoras.',
    probabilityPercent: hour.probabilityPercent,
    intensity: hour.intensity,
  );
}
