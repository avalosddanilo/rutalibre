import 'package:flutter_test/flutter_test.dart';
import 'package:rutalibre/features/transit/data/models/schedule_model.dart';
import 'package:rutalibre/features/transit/domain/entities/schedule.dart';

void main() {
  group('dayType ↔ Postgres', () {
    test('fromDb mapea los tres valores válidos', () {
      expect(ScheduleModel.dayTypeFromDb('weekday'), DayType.weekday);
      expect(ScheduleModel.dayTypeFromDb('saturday'), DayType.saturday);
      expect(
        ScheduleModel.dayTypeFromDb('sunday_holiday'),
        DayType.sundayHoliday,
      );
    });

    test('fromDb tira FormatException ante un valor desconocido', () {
      expect(
        () => ScheduleModel.dayTypeFromDb('holiday'),
        throwsFormatException,
      );
    });

    test('toDb es la inversa exacta de fromDb', () {
      for (final dt in DayType.values) {
        expect(ScheduleModel.dayTypeFromDb(ScheduleModel.dayTypeToDb(dt)), dt);
      }
    });
  });

  group('parseTime (departure_time "time" de Postgres → Duration)', () {
    test('HH:MM:SS', () {
      expect(
        ScheduleModel.parseTime('06:05:30'),
        const Duration(hours: 6, minutes: 5, seconds: 30),
      );
    });

    test('HH:MM (sin segundos)', () {
      expect(
        ScheduleModel.parseTime('14:30'),
        const Duration(hours: 14, minutes: 30),
      );
    });

    test('HH:MM:SS.ffffff (Postgres puede emitir fracciones)', () {
      expect(
        ScheduleModel.parseTime('06:05:30.123456'),
        const Duration(hours: 6, minutes: 5, seconds: 30),
      );
    });

    test('tira FormatException si falta el minuto', () {
      expect(() => ScheduleModel.parseTime('6'), throwsFormatException);
    });
  });

  group('formatTime (Duration → "HH:MM:SS", inversa de parseTime)', () {
    test('rellena con ceros a la izquierda', () {
      expect(
        ScheduleModel.formatTime(
          const Duration(hours: 6, minutes: 5, seconds: 3),
        ),
        '06:05:03',
      );
    });

    test('round-trip parse→format para "23:59:00"', () {
      expect(
        ScheduleModel.formatTime(ScheduleModel.parseTime('23:59:00')),
        '23:59:00',
      );
    });
  });

  group('fromJson / toJson', () {
    final json = {
      'id': 'sc1',
      'route_variant_id': 'rv1',
      'day_type': 'saturday',
      'departure_time': '07:15:00',
    };

    test('fromJson mapea todos los campos', () {
      final model = ScheduleModel.fromJson(json);
      expect(model.id, 'sc1');
      expect(model.routeVariantId, 'rv1');
      expect(model.dayType, DayType.saturday);
      expect(model.departureTime, const Duration(hours: 7, minutes: 15));
    });

    test('round-trip toJson → fromJson preserva la entidad (Equatable)', () {
      final model = ScheduleModel.fromJson(json);
      expect(ScheduleModel.fromJson(model.toJson()), model);
    });
  });

  test('Schedule.formattedTime muestra "HH:mm" sin segundos', () {
    const schedule = Schedule(
      id: 'x',
      routeVariantId: 'rv1',
      dayType: DayType.weekday,
      departureTime: Duration(hours: 6, minutes: 5, seconds: 59),
    );
    expect(schedule.formattedTime, '06:05');
  });
}
