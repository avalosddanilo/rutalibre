import 'package:flutter_test/flutter_test.dart';
import 'package:rutalibre/features/transit/domain/entities/schedule.dart';
import 'package:rutalibre/features/transit/presentation/utils/day_type_resolver.dart';

void main() {
  group('easterSunday (computus de Meeus/Jones/Butcher)', () {
    // Fechas de Pascua occidental verificables en cualquier calendario.
    test('2025 → 20 de abril', () {
      expect(easterSunday(2025), DateTime(2025, 4, 20));
    });
    test('2026 → 5 de abril', () {
      expect(easterSunday(2026), DateTime(2026, 4, 5));
    });
    test('2027 → 28 de marzo', () {
      expect(easterSunday(2027), DateTime(2027, 3, 28));
    });
    test('2028 → 16 de abril', () {
      expect(easterSunday(2028), DateTime(2028, 4, 16));
    });
  });

  group('isNationalHoliday', () {
    test('feriados fijos', () {
      for (final date in [
        DateTime(2026, 1, 1), // Año Nuevo
        DateTime(2026, 3, 24), // Memoria
        DateTime(2026, 4, 2), // Malvinas
        DateTime(2026, 5, 1), // Trabajador
        DateTime(2026, 5, 25), // Revolución de Mayo
        DateTime(2026, 6, 20), // Belgrano
        DateTime(2026, 7, 9), // Independencia
        DateTime(2026, 12, 8), // Inmaculada
        DateTime(2026, 12, 25), // Navidad
      ]) {
        expect(isNationalHoliday(date), isTrue, reason: '$date');
      }
    });

    test('Carnaval 2026: lunes 16 y martes 17 de febrero', () {
      expect(isNationalHoliday(DateTime(2026, 2, 16)), isTrue);
      expect(isNationalHoliday(DateTime(2026, 2, 17)), isTrue);
      // El miércoles de ceniza NO es feriado.
      expect(isNationalHoliday(DateTime(2026, 2, 18)), isFalse);
    });

    test('Viernes Santo 2026: 3 de abril', () {
      expect(isNationalHoliday(DateTime(2026, 4, 3)), isTrue);
    });

    test('un martes cualquiera no es feriado', () {
      expect(isNationalHoliday(DateTime(2026, 8, 4)), isFalse);
    });

    test('LIMITACIÓN DOCUMENTADA: los trasladables no se detectan', () {
      // San Martín (17/8) es trasladable por decreto: el resolver no lo
      // conoce y el usuario lo cubre cambiando el día a mano en la UI.
      expect(isNationalHoliday(DateTime(2026, 8, 17)), isFalse);
    });
  });

  group('dayTypeFor', () {
    test('martes común → weekday', () {
      expect(dayTypeFor(DateTime(2026, 8, 4)), DayType.weekday);
    });

    test('sábado común → saturday', () {
      expect(dayTypeFor(DateTime(2026, 8, 8)), DayType.saturday);
    });

    test('domingo → sundayHoliday', () {
      expect(dayTypeFor(DateTime(2026, 8, 9)), DayType.sundayHoliday);
    });

    test('feriado en día de semana → sundayHoliday (no weekday)', () {
      // 1/5/2026 cae viernes.
      expect(dayTypeFor(DateTime(2026, 5, 1)), DayType.sundayHoliday);
    });

    test(
      'feriado en sábado → sundayHoliday (el feriado le gana al sábado)',
      () {
        // Navidad 2027 cae sábado.
        expect(dayTypeFor(DateTime(2027, 12, 25)), DayType.sundayHoliday);
      },
    );
  });
}
