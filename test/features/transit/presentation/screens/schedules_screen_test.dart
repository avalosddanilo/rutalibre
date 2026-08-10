import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rutalibre/core/errors/failures.dart';
import 'package:rutalibre/features/transit/presentation/utils/display_text.dart';
import 'package:rutalibre/features/transit/domain/entities/bus_line.dart';
import 'package:rutalibre/features/transit/domain/entities/route_variant.dart';
import 'package:rutalibre/features/transit/domain/entities/schedule.dart';
import 'package:rutalibre/features/transit/domain/entities/transit_network.dart';
import 'package:rutalibre/features/transit/domain/repositories/transit_repository.dart';
import 'package:rutalibre/core/providers/clock_provider.dart';
import 'package:rutalibre/features/transit/presentation/providers/transit_providers.dart';
import 'package:rutalibre/features/transit/presentation/screens/schedules_screen.dart';

class _MockRepo extends Mock implements TransitRepository {}

const _line = BusLine(
  id: 'l1',
  code: '3',
  name: 'Línea 3',
  colorHex: '#1E88E5',
  network: TransitNetwork(code: 'gran-resistencia', name: 'Gran Resistencia'),
);
const _variant = RouteVariant(
  id: 'rv1',
  lineId: 'l1',
  name: 'Ida: Centro → Barranqueras',
  direction: RouteDirection.outbound,
  isActive: true,
);

/// El 904C, que SÍ tiene frecuencia regulada (Anexo II de la Res. 141/2017).
const _line904c = BusLine(
  id: 'l1',
  code: '904C',
  name: '904 por Barranqueras',
  colorHex: '#1E88E5',
  network: TransitNetwork(
    code: 'interurbano-chaco-corrientes',
    name: 'Chaco ↔ Corrientes',
  ),
);

const _weekdaySchedules = [
  Schedule(
    id: 'a',
    routeVariantId: 'rv1',
    dayType: DayType.weekday,
    departureTime: Duration(hours: 6),
  ),
  Schedule(
    id: 'b',
    routeVariantId: 'rv1',
    dayType: DayType.weekday,
    departureTime: Duration(hours: 14, minutes: 30),
  ),
  Schedule(
    id: 'c',
    routeVariantId: 'rv1',
    dayType: DayType.weekday,
    departureTime: Duration(hours: 22),
  ),
];

/// Martes 4/8/2026 a las 12:00 → hoy es "Hábiles"; próxima salida: 14:30.
DateTime _fixedNow() => DateTime(2026, 8, 4, 12, 0);

ProviderContainer _makeContainer(
  TransitRepository repo, {
  DateTime Function()? clock,
}) {
  final container = ProviderContainer(
    // Espeja la política del ProviderScope de main.dart: los Failure no se
    // reintentan (sin esto, el auto-retry de Riverpod re-ejecuta el mock a
    // los 200 ms y los tests de error ven el segundo resultado).
    retry: (retryCount, error) => null,
    overrides: [
      transitRepositoryProvider.overrideWithValue(repo),
      clockProvider.overrideWithValue(clock ?? _fixedNow),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

Widget _app(ProviderContainer container) => UncontrolledProviderScope(
  container: container,
  child: const MaterialApp(home: SchedulesScreen()),
);

/// La pantalla tiene un Timer periódico (refresco por minuto): hay que
/// desmontarla al final de cada test o flutter_test acusa timer pendiente.
Future<void> _unmount(WidgetTester tester) =>
    tester.pumpWidget(const SizedBox.shrink());

void main() {
  testWidgets('sin recorrido seleccionado muestra la guía para elegir uno', (
    tester,
  ) async {
    final container = _makeContainer(_MockRepo());

    await tester.pumpWidget(_app(container));

    expect(
      find.textContaining('Elegí una línea y un recorrido'),
      findsOneWidget,
    );
    await _unmount(tester);
  });

  testWidgets(
    'muestra los horarios del día actual y resalta la próxima salida',
    (tester) async {
      final repo = _MockRepo();
      when(
        () =>
            repo.getSchedules(routeVariantId: 'rv1', dayType: DayType.weekday),
      ).thenAnswer((_) async => const Right(_weekdaySchedules));

      final container = _makeContainer(repo);
      container.read(selectedLineProvider.notifier).select(_line);
      container.read(selectedRouteVariantProvider.notifier).select(_variant);

      await tester.pumpWidget(_app(container));
      await tester.pumpAndSettle();

      // Cabecera con línea y recorrido.
      expect(find.text('Línea 3'), findsOneWidget);
      expect(
        find.text(displayText('Ida: Centro → Barranqueras')),
        findsOneWidget,
      );

      // Todos los horarios listados.
      expect(find.text('06:00'), findsOneWidget);
      expect(find.text('22:00'), findsOneWidget);

      // La próxima salida (14:30 a las 12:00) aparece en la tarjeta y su
      // chip de la grilla está en negrita (resaltado).
      expect(find.text('Próxima salida: 14:30'), findsOneWidget);
      expect(find.text('en 2 h 30 min'), findsOneWidget);
      final chip = tester.widget<Text>(find.text('14:30'));
      expect(chip.style?.fontWeight, FontWeight.bold);
      await _unmount(tester);
    },
  );

  testWidgets('cambiar el tipo de día vuelve a pedir horarios', (tester) async {
    final repo = _MockRepo();
    when(
      () => repo.getSchedules(routeVariantId: 'rv1', dayType: DayType.weekday),
    ).thenAnswer((_) async => const Right(_weekdaySchedules));
    when(
      () => repo.getSchedules(
        routeVariantId: 'rv1',
        dayType: DayType.sundayHoliday,
      ),
    ).thenAnswer((_) async => const Right(<Schedule>[]));

    final container = _makeContainer(repo);
    container.read(selectedLineProvider.notifier).select(_line);
    container.read(selectedRouteVariantProvider.notifier).select(_variant);

    await tester.pumpWidget(_app(container));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dom. y fer.'));
    await tester.pumpAndSettle();

    // El vacío explica POR QUÉ está vacío: hoy le pasa a todas las líneas
    // porque no hay fuente pública de horarios.
    expect(find.text('Todavía no tenemos los horarios'), findsOneWidget);
    expect(find.textContaining('ninguna fuente'), findsOneWidget);
    verify(
      () => repo.getSchedules(
        routeVariantId: 'rv1',
        dayType: DayType.sundayHoliday,
      ),
    ).called(1);
    await _unmount(tester);
  });

  testWidgets('mirando un día que no es hoy, no se resalta próxima salida', (
    tester,
  ) async {
    final repo = _MockRepo();
    // El primer build pide el día de hoy (weekday): también va stubbeado.
    when(
      () => repo.getSchedules(routeVariantId: 'rv1', dayType: DayType.weekday),
    ).thenAnswer((_) async => const Right(_weekdaySchedules));
    when(
      () => repo.getSchedules(routeVariantId: 'rv1', dayType: DayType.saturday),
    ).thenAnswer((_) async => const Right(_weekdaySchedules));

    final container = _makeContainer(repo);
    container.read(selectedLineProvider.notifier).select(_line);
    container.read(selectedRouteVariantProvider.notifier).select(_variant);

    await tester.pumpWidget(_app(container));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sábados'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Próxima salida'), findsNothing);
    expect(find.text('14:30'), findsOneWidget);
    await _unmount(tester);
  });

  testWidgets('error de carga muestra el mensaje y Reintentar recupera', (
    tester,
  ) async {
    final repo = _MockRepo();
    var calls = 0;
    when(
      () => repo.getSchedules(routeVariantId: 'rv1', dayType: DayType.weekday),
    ).thenAnswer((_) async {
      calls++;
      return calls == 1
          ? const Left(ServerFailure())
          : const Right(_weekdaySchedules);
    });

    final container = _makeContainer(repo);
    container.read(selectedLineProvider.notifier).select(_line);
    container.read(selectedRouteVariantProvider.notifier).select(_variant);

    await tester.pumpWidget(_app(container));
    await tester.pumpAndSettle();

    expect(
      find.text('El servidor no respondió. Probá de nuevo en un rato.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(find.text('06:00'), findsOneWidget);
    expect(calls, 2);
    await _unmount(tester);
  });

  group('frecuencia regulada', () {
    testWidgets('sin horarios, el 904C igual contesta cada cuánto pasa', (
      tester,
    ) async {
      // Es el caso que esto vino a resolver: la pantalla decía "todavía no
      // tenemos los horarios" teniendo la banda del pliego a mano.
      final repo = _MockRepo();
      when(
        () =>
            repo.getSchedules(routeVariantId: 'rv1', dayType: DayType.weekday),
      ).thenAnswer((_) async => const Right(<Schedule>[]));

      final container = _makeContainer(repo);
      container.read(selectedLineProvider.notifier).select(_line904c);
      container.read(selectedRouteVariantProvider.notifier).select(_variant);

      await tester.pumpWidget(_app(container));
      await tester.pumpAndSettle();

      expect(find.text('cada 12 a 15 min'), findsOneWidget);
      // "regulada" no es un adorno: sin esa palabra el número se lee como una
      // promesa de que viene uno cada 12 minutos.
      expect(find.text('frecuencia regulada en hora pico'), findsOneWidget);
      // Y el cartel del vacío NO se contradice con el renglón de arriba.
      expect(find.text('No hay tabla de horarios'), findsOneWidget);
      expect(find.textContaining('CNRT'), findsOneWidget);
      await _unmount(tester);
    });

    testWidgets('tocarla explica que es una obligación, no una medición', (
      tester,
    ) async {
      final repo = _MockRepo();
      when(
        () =>
            repo.getSchedules(routeVariantId: 'rv1', dayType: DayType.weekday),
      ).thenAnswer((_) async => const Right(<Schedule>[]));

      final container = _makeContainer(repo);
      container.read(selectedLineProvider.notifier).select(_line904c);
      container.read(selectedRouteVariantProvider.notifier).select(_variant);

      await tester.pumpWidget(_app(container));
      await tester.pumpAndSettle();

      await tester.tap(find.text('cada 12 a 15 min'));
      await tester.pumpAndSettle();

      expect(find.textContaining('obligada a cumplir'), findsOneWidget);
      expect(
        find.textContaining('Anexo II de la Res. 141/2017'),
        findsOneWidget,
      );
      await _unmount(tester);
    });

    testWidgets('una línea sin banda no muestra nada inventado', (
      tester,
    ) async {
      final repo = _MockRepo();
      when(
        () =>
            repo.getSchedules(routeVariantId: 'rv1', dayType: DayType.weekday),
      ).thenAnswer((_) async => const Right(<Schedule>[]));

      final container = _makeContainer(repo);
      // La 3 del Gran Resistencia: ninguna norma publicada fija su intervalo.
      container.read(selectedLineProvider.notifier).select(_line);
      container.read(selectedRouteVariantProvider.notifier).select(_variant);

      await tester.pumpWidget(_app(container));
      await tester.pumpAndSettle();

      expect(find.textContaining('frecuencia regulada'), findsNothing);
      expect(find.text('Todavía no tenemos los horarios'), findsOneWidget);
      await _unmount(tester);
    });
  });

  testWidgets('sin salidas restantes hoy muestra el aviso y nada resaltado', (
    tester,
  ) async {
    final repo = _MockRepo();
    when(
      () => repo.getSchedules(routeVariantId: 'rv1', dayType: DayType.weekday),
    ).thenAnswer((_) async => const Right(_weekdaySchedules));

    // Martes 23:30: la última salida (22:00) ya pasó.
    final container = _makeContainer(
      repo,
      clock: () => DateTime(2026, 8, 4, 23, 30),
    );
    container.read(selectedLineProvider.notifier).select(_line);
    container.read(selectedRouteVariantProvider.notifier).select(_variant);

    await tester.pumpWidget(_app(container));
    await tester.pumpAndSettle();

    expect(
      find.text('No quedan salidas hoy para este recorrido.'),
      findsOneWidget,
    );
    expect(find.textContaining('Próxima salida'), findsNothing);
    await _unmount(tester);
  });

  testWidgets('salida exactamente a la hora actual se muestra como "ahora"', (
    tester,
  ) async {
    final repo = _MockRepo();
    when(
      () => repo.getSchedules(routeVariantId: 'rv1', dayType: DayType.weekday),
    ).thenAnswer(
      (_) async => const Right([
        Schedule(
          id: 'x',
          routeVariantId: 'rv1',
          dayType: DayType.weekday,
          departureTime: Duration(hours: 12),
        ),
      ]),
    );

    final container = _makeContainer(repo); // reloj fijo: 12:00 en punto
    container.read(selectedLineProvider.notifier).select(_line);
    container.read(selectedRouteVariantProvider.notifier).select(_variant);

    await tester.pumpWidget(_app(container));
    await tester.pumpAndSettle();

    expect(find.text('Próxima salida: 12:00'), findsOneWidget);
    expect(find.text('ahora'), findsOneWidget);
    await _unmount(tester);
  });
}
