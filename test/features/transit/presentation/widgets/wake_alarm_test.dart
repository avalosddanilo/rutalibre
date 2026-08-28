import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rutalibre/core/providers/shared_preferences_provider.dart';
import 'package:rutalibre/features/transit/presentation/providers/trip_providers.dart';
import 'package:rutalibre/features/transit/presentation/widgets/wake_alarm.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Registra qué le pidió la alarma al teléfono, en orden.
final class FakeWakeAlarmGear implements WakeAlarmGear {
  final calls = <String>[];

  @override
  Future<void> keepScreenOn() async => calls.add('keepScreenOn');
  @override
  Future<void> allowScreenOff() async => calls.add('allowScreenOff');
  @override
  Future<void> ring() async => calls.add('ring');
  @override
  Future<void> silence() async => calls.add('silence');
}

void main() {
  late SharedPreferences prefs;
  late FakeWakeAlarmGear gear;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    gear = FakeWakeAlarmGear();
    // Un test que desmonta el árbol con la alarma abierta no pasa por el
    // pop, y el flag anti-apilado quedaría trabado para el siguiente.
    WakeAlarmScreen.resetShowingForTest();
  });

  ProviderContainer container() {
    final c = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        wakeAlarmGearProvider.overrideWithValue(gear),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  group('WakeAlarmNotifier', () {
    test('armar agarra la pantalla; desarmar la suelta', () async {
      final c = container();

      await c.read(wakeAlarmProvider.notifier).setArmed(true);
      expect(c.read(wakeAlarmProvider), isTrue);
      expect(gear.calls, ['keepScreenOn']);

      await c.read(wakeAlarmProvider.notifier).setArmed(false);
      expect(c.read(wakeAlarmProvider), isFalse);
      expect(gear.calls, ['keepScreenOn', 'allowScreenOff']);
    });

    test('armar dos veces no duplica el pedido', () async {
      final c = container();
      await c.read(wakeAlarmProvider.notifier).setArmed(true);
      await c.read(wakeAlarmProvider.notifier).setArmed(true);
      expect(gear.calls, ['keepScreenOn']);
    });

    test('terminar la guía desarma, calla y devuelve la pantalla', () async {
      // "Terminar" con la alarma armada (o sonando) no puede dejar ni el
      // wakelock agarrado ni el tono en loop sobre el mapa.
      final c = container();
      // El listener del notifier existe recién cuando alguien lo lee, como
      // en la app lo hace el interruptor del panel.
      c.listen(wakeAlarmProvider, (_, _) {});
      await c.read(wakeAlarmProvider.notifier).setArmed(true);

      c.read(tripGuidanceProvider.notifier).start();
      c.read(tripGuidanceProvider.notifier).stop();
      await Future<void>.delayed(Duration.zero);

      expect(c.read(wakeAlarmProvider), isFalse);
      expect(gear.calls, ['keepScreenOn', 'silence', 'allowScreenOff']);
    });
  });

  group('WakeAlarmScreen', () {
    Future<void> pumpAndShow(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () => WakeAlarmScreen.show(
                    context,
                    stopName: 'French y Güemes',
                    gear: gear,
                  ),
                  child: const Text('sonar'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('sonar'));
      // pump y no pumpAndSettle: la vibración periódica no "settlea" nunca.
      await tester.pump();
      await tester.pump();
    }

    testWidgets('suena al abrir y dice dónde bajarse', (tester) async {
      await pumpAndShow(tester);

      expect(gear.calls, contains('ring'));
      expect(find.text('¡Preparate para bajar!'), findsOneWidget);
      expect(find.text('Tu parada es French y Güemes.'), findsOneWidget);
    });

    testWidgets('solo el botón la apaga, y apaga de verdad', (tester) async {
      await pumpAndShow(tester);

      await tester.tap(find.text('Listo, estoy despierto'));
      await tester.pumpAndSettle();

      expect(find.text('¡Preparate para bajar!'), findsNothing);
      expect(gear.calls, contains('silence'));
    });

    testWidgets('dos disparos seguidos no apilan dos alarmas', (tester) async {
      // El GPS oscila: dos fixes seguidos en zona de bajada dispararían dos
      // veces, y dos alarmas apiladas obligan a apagar dos veces.
      late BuildContext ctx;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                ctx = context;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      WakeAlarmScreen.show(ctx, stopName: 'French y Güemes', gear: gear);
      WakeAlarmScreen.show(ctx, stopName: 'French y Güemes', gear: gear);
      await tester.pump();
      await tester.pump();

      expect(find.text('¡Preparate para bajar!'), findsOneWidget);
      expect(gear.calls.where((c) => c == 'ring'), hasLength(1));

      // Cerrar para no dejar la vibración periódica viva en el test.
      await tester.tap(find.text('Listo, estoy despierto'));
      await tester.pumpAndSettle();
    });
  });
}
