import 'package:equatable/equatable.dart';

/// Tipo de día al que aplica un horario.
///
/// Espeja el enum `day_type` de Postgres. El mapeo string ↔ enum
/// ('weekday' | 'saturday' | 'sunday_holiday') vive en `ScheduleModel`
/// (capa data), no acá.
enum DayType {
  /// Lunes a viernes hábiles.
  weekday,

  /// Sábado.
  saturday,

  /// Domingo y feriados.
  sundayHoliday,
}

/// Una salida desde cabecera de un recorrido, para un tipo de día.
///
/// Una fila por salida (modelo simple, sin GTFS completo): la lista de
/// Schedules de un recorrido ES su tabla de horarios.
class Schedule extends Equatable {
  const Schedule({
    required this.id,
    required this.routeVariantId,
    required this.dayType,
    required this.departureTime,
  });

  final String id;

  /// FK al recorrido ([RouteVariant]) que sale a esta hora.
  final String routeVariantId;

  final DayType dayType;

  /// Hora de salida desde cabecera, como offset desde la medianoche.
  ///
  /// Se usa `Duration` (Dart puro) y no `TimeOfDay` (Flutter) ni
  /// `DateTime` (arrastra fecha y zona horaria que acá no existen).
  /// Ventaja: ordenar y comparar contra "ahora" es aritmética directa.
  final Duration departureTime;

  /// Hora formateada "HH:mm" para mostrar en listas ("06:05", "14:30").
  String get formattedTime {
    final hours = departureTime.inHours.toString().padLeft(2, '0');
    final minutes = (departureTime.inMinutes % 60).toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  @override
  List<Object?> get props => [id, routeVariantId, dayType, departureTime];
}
