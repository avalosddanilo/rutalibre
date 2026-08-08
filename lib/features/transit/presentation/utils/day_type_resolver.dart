import '../../domain/entities/schedule.dart';

/// Resuelve qué [DayType] corresponde a una fecha en Argentina.
///
/// Vive en presentation (no en domain) por decisión de arquitectura: el
/// dominio responde "los horarios del día que me pidas"; decidir qué día
/// es "hoy" — calendario y feriados incluidos — es un problema de la UI.
///
/// Regla: domingo o feriado nacional → [DayType.sundayHoliday];
/// sábado → [DayType.saturday]; el resto → [DayType.weekday].
/// Un feriado que cae sábado cuenta como domingo/feriado (el servicio de
/// colectivos se rige por el feriado, no por el día de semana).
DayType dayTypeFor(DateTime date) {
  if (date.weekday == DateTime.sunday || isNationalHoliday(date)) {
    return DayType.sundayHoliday;
  }
  if (date.weekday == DateTime.saturday) {
    return DayType.saturday;
  }
  return DayType.weekday;
}

/// Feriados nacionales INAMOVIBLES de fecha fija, como (mes, día).
///
/// Los feriados TRASLADABLES (Güemes 17/6, San Martín 17/8, Diversidad
/// Cultural 12/10, Soberanía 20/11) y los puente turísticos se decretan
/// cada año y NO están acá: ante la duda la app asume día hábil y el
/// usuario puede cambiar el tipo de día a mano en la pantalla de horarios.
/// Si algún día hace falta exactitud total, esto se reemplaza por una
/// tabla `holidays` en Supabase sin tocar ninguna pantalla.
const _fixedHolidays = <(int, int)>{
  (1, 1), // Año Nuevo
  (3, 24), // Día de la Memoria
  (4, 2), // Malvinas
  (5, 1), // Día del Trabajador
  (5, 25), // Revolución de Mayo
  (6, 20), // Paso a la Inmortalidad de Belgrano
  (7, 9), // Independencia
  (12, 8), // Inmaculada Concepción
  (12, 25), // Navidad
};

/// True si la fecha es feriado nacional (fijos + derivados de Pascua:
/// lunes y martes de Carnaval, Viernes Santo).
bool isNationalHoliday(DateTime date) {
  if (_fixedHolidays.contains((date.month, date.day))) {
    return true;
  }
  final easter = easterSunday(date.year);
  // Aritmética de fecha pura (el constructor normaliza días negativos):
  // inmune a saltos de DST, a diferencia de subtract(Duration).
  final day = DateTime(date.year, date.month, date.day);
  final carnivalMonday = DateTime(easter.year, easter.month, easter.day - 48);
  final carnivalTuesday = DateTime(easter.year, easter.month, easter.day - 47);
  final goodFriday = DateTime(easter.year, easter.month, easter.day - 2);
  return day == carnivalMonday || day == carnivalTuesday || day == goodFriday;
}

/// Domingo de Pascua (algoritmo de Meeus/Jones/Butcher, calendario
/// gregoriano). Determinístico y sin dependencias: entra año, sale fecha.
DateTime easterSunday(int year) {
  final a = year % 19;
  final b = year ~/ 100;
  final c = year % 100;
  final d = b ~/ 4;
  final e = b % 4;
  final f = (b + 8) ~/ 25;
  final g = (b - f + 1) ~/ 3;
  final h = (19 * a + b - d - g + 15) % 30;
  final i = c ~/ 4;
  final k = c % 4;
  final l = (32 + 2 * e + 2 * i - h - k) % 7;
  final m = (a + 11 * h + 22 * l) ~/ 451;
  final month = (h + l - 7 * m + 114) ~/ 31;
  final day = ((h + l - 7 * m + 114) % 31) + 1;
  return DateTime(year, month, day);
}
