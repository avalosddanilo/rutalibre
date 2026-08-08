import '../../domain/entities/schedule.dart';

/// DTO de `schedules`. Dos mapeos viven acá y solo acá:
/// - `day_type` de Postgres ('weekday' | 'saturday' | 'sunday_holiday')
///   ↔ enum [DayType] del dominio.
/// - `departure_time` tipo `time` ("06:05:00") ↔ [Duration] desde
///   medianoche.
final class ScheduleModel extends Schedule {
  const ScheduleModel({
    required super.id,
    required super.routeVariantId,
    required super.dayType,
    required super.departureTime,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) => ScheduleModel(
    id: json['id'] as String,
    routeVariantId: json['route_variant_id'] as String,
    dayType: dayTypeFromDb(json['day_type'] as String),
    departureTime: parseTime(json['departure_time'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'route_variant_id': routeVariantId,
    'day_type': dayTypeToDb(dayType),
    'departure_time': formatTime(departureTime),
  };

  static DayType dayTypeFromDb(String value) => switch (value) {
    'weekday' => DayType.weekday,
    'saturday' => DayType.saturday,
    'sunday_holiday' => DayType.sundayHoliday,
    _ => throw FormatException('day_type desconocido: "$value"'),
  };

  static String dayTypeToDb(DayType dayType) => switch (dayType) {
    DayType.weekday => 'weekday',
    DayType.saturday => 'saturday',
    DayType.sundayHoliday => 'sunday_holiday',
  };

  /// Acepta "HH:MM:SS", "HH:MM" y "HH:MM:SS.ffffff" (Postgres puede emitir
  /// fracciones de segundo).
  static Duration parseTime(String raw) {
    final parts = raw.split(':');
    if (parts.length < 2) {
      throw FormatException('departure_time inválido: "$raw"');
    }
    return Duration(
      hours: int.parse(parts[0]),
      minutes: int.parse(parts[1]),
      seconds: parts.length > 2 ? int.parse(parts[2].split('.').first) : 0,
    );
  }

  static String formatTime(Duration duration) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(duration.inHours)}:'
        '${two(duration.inMinutes % 60)}:'
        '${two(duration.inSeconds % 60)}';
  }
}
