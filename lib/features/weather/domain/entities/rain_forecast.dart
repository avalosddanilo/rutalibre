import 'package:equatable/equatable.dart';

/// Cuán fuerte llueve.
///
/// Es una escala METEOROLÓGICA y nada más. Qué significa para el colectivo
/// —que suele haber menos unidades y demoras— es una lectura de PRODUCTO y
/// vive en la pantalla, no acá: el dominio del clima no sabe que existen los
/// colectivos.
enum RainIntensity {
  none,

  /// Se moja el que espera, pero el tránsito sigue igual.
  light,

  /// Llueve en serio.
  strong,
}

/// Cuánta lluvia se espera en una hora puntual.
class RainHour extends Equatable {
  const RainHour({
    required this.time,
    required this.millimeters,
    required this.probabilityPercent,
  });

  /// Hora local del pronóstico.
  final DateTime time;

  /// Milímetros esperados en esa hora.
  final double millimeters;

  /// Probabilidad de precipitación, 0-100.
  final int probabilityPercent;

  /// A partir de acá se moja el que espera en la parada.
  ///
  /// El umbral está en los milímetros y no en la probabilidad a propósito:
  /// "60% de probabilidad de 0 mm" es lluvia que no cae. 0,2 mm es el piso
  /// donde una llovizna se empieza a sentir.
  static const wetMillimeters = 0.2;

  /// De acá para arriba deja de ser una llovizna.
  ///
  /// 2,5 mm/h es el corte que la convención meteorológica usa entre lluvia
  /// *débil* y *moderada* — la que llaman "fuerte" arranca recién en 7,6.
  /// Tomamos el corte de abajo a propósito: para lo que nos importa —calles
  /// anegadas, gente que no sale, colectivos que tardan— 2,5 mm en una hora
  /// ya alcanza, y errar hacia avisar de más es más barato que errar hacia
  /// no avisar.
  static const strongMillimeters = 2.5;

  RainIntensity get intensity => switch (millimeters) {
    >= strongMillimeters => RainIntensity.strong,
    >= wetMillimeters => RainIntensity.light,
    _ => RainIntensity.none,
  };

  bool get isWet => intensity != RainIntensity.none;

  @override
  List<Object?> get props => [time, millimeters, probabilityPercent];
}

/// El pronóstico de lluvia de un punto, hora por hora.
///
/// No es un pronóstico completo del tiempo a propósito: la app no es del
/// clima. Las únicas dos preguntas que contesta son si llueve y qué tan
/// fuerte.
///
/// [now] entra por parámetro en todos lados y no se lee de `DateTime.now()`
/// para que esto se pueda testear.
class RainForecast extends Equatable {
  const RainForecast({required this.hours});

  /// Ordenadas de la más cercana a la más lejana.
  final List<RainHour> hours;

  /// Hasta dónde se mira. Más allá de seis horas, "va a llover" ya no
  /// cambia si salís ahora o no.
  static const horizon = Duration(hours: 6);

  /// La hora en curso, o null si el pronóstico no la trae.
  ///
  /// Devuelve la HORA y no su intensidad porque quien pregunta necesita las
  /// dos cosas del mismo renglón: cuánto llueve y con qué probabilidad. Que
  /// salgan de la misma [RainHour] es lo que evita el bicho de mostrar la
  /// probabilidad de una hora y la intensidad de otra.
  RainHour? hourAt(DateTime now) {
    final current = _startOfHour(now);
    for (final hour in hours) {
      if (hour.time == current) return hour;
    }
    return null;
  }

  /// La hora con MÁS lluvia dentro del horizonte —contando la hora en curso—,
  /// o null si no se espera nada.
  ///
  /// Se mira el pico y no la primera hora mojada porque lo que se advierte es
  /// el peor momento del rato que viene: si en una hora chispea y en dos cae
  /// un temporal, avisar por la chispa sería quedarse corto.
  RainHour? wettestHour(DateTime now) {
    final start = _startOfHour(now);
    final limit = now.add(horizon);
    RainHour? peak;
    for (final hour in hours) {
      if (hour.time.isBefore(start)) continue;
      if (hour.time.isAfter(limit)) break;
      if (!hour.isWet) continue;
      if (peak == null || hour.millimeters > peak.millimeters) peak = hour;
    }
    return peak;
  }

  static DateTime _startOfHour(DateTime time) =>
      DateTime(time.year, time.month, time.day, time.hour);

  @override
  List<Object?> get props => [hours];
}
