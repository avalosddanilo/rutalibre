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

  /// Lo que contesta [holdTrip]: true = consiguió el servicio en primer
  /// plano. False es el teléfono donde la alarma necesita la pantalla.
  bool hayServicio = true;

  @override
  Future<bool> holdTrip() async {
    calls.add('holdTrip');
    return hayServicio;
  }

  @override
  Future<void> releaseTrip() async => calls.add('releaseTrip');
  @override
  Future<void> wakeScreen() async => calls.add('wakeScreen');
  @override
  Future<void> ring() async => calls.add('ring');
  @override
  Future<void> silence() async => calls.add('silence');
  @override
  Future<void> chime() async => calls.add('chime');
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
    test('armar sostiene el viaje; desarmar lo suelta', () async {
      final c = container();

      await c.read(wakeAlarmProvider.notifier).setArmed(true);
      expect(c.read(wakeAlarmProvider), isTrue);
      expect(gear.calls, ['holdTrip']);

      await c.read(wakeAlarmProvider.notifier).setArmed(false);
      expect(c.read(wakeAlarmProvider), isFalse);
      expect(gear.calls, ['holdTrip', 'releaseTrip']);
    });

    test('un teléfono sin servicio igual queda armado', () async {
      // `holdTrip` contestando false es iOS, o un Android que rechazó el
      // servicio en primer plano: ahí la alarma vuelve a necesitar la
      // pantalla prendida (el wakelock lo pone la implementación real). Lo
      // que NO puede pasar es que la alarma quede desarmada por eso: sin
      // servicio despierta peor, pero despierta.
      final c = container();
      gear.hayServicio = false;

      await c.read(wakeAlarmProvider.notifier).setArmed(true);

      expect(c.read(wakeAlarmProvider), isTrue);
      expect(gear.calls, ['holdTrip']);
    });

    test('armar dos veces no duplica el pedido', () async {
      final c = container();
      await c.read(wakeAlarmProvider.notifier).setArmed(true);
      await c.read(wakeAlarmProvider.notifier).setArmed(true);
      expect(gear.calls, ['holdTrip']);
    });

    test('terminar la guía desarma, calla y suelta el teléfono', () async {
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
      expect(gear.calls, ['holdTrip', 'silence', 'releaseTrip']);
    });
  });

  group('WakeAlarmScreen', () {
    Future<void> pumpAndShow(WidgetTester tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container(),
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => Center(
                  child: ElevatedButton(
                    onPressed: () => WakeAlarmScreen.show(
                      context,
                      stopName: 'French y Güemes',
                    ),
                    child: const Text('sonar'),
                  ),
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

    testWidgets('dice dónde bajarse, que es lo primero que se lee', (
      tester,
    ) async {
      await pumpAndShow(tester);

      expect(find.text('¡Preparate para bajar!'), findsOneWidget);
      expect(find.text('Tu parada es French y Güemes.'), findsOneWidget);
    });

    testWidgets('la pantalla NO es la que hace sonar el tono', (tester) async {
      // Parece un test al revés y es el más importante del archivo.
      //
      // El tono lo arranca `WakeAlarmWatchNotifier` al decidir, no este
      // widget al montarse. Si volviera a sonar desde acá, con la pantalla
      // apagada no sonaría nunca —Flutter no dibuja, el widget no se monta—
      // y estaríamos de vuelta en el bug de `docs/alarma-pantalla-apagada.md`
      // con los tests en verde.
      await pumpAndShow(tester);

      expect(gear.calls, isNot(contains('ring')));
      expect(gear.calls, isNot(contains('wakeScreen')));
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
        UncontrolledProviderScope(
          container: container(),
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  ctx = context;
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      );
      WakeAlarmScreen.show(ctx, stopName: 'French y Güemes');
      WakeAlarmScreen.show(ctx, stopName: 'French y Güemes');
      await tester.pump();
      await tester.pump();

      expect(find.text('¡Preparate para bajar!'), findsOneWidget);

      // Cerrar para no dejar la vibración periódica viva en el test.
      await tester.tap(find.text('Listo, estoy despierto'));
      await tester.pumpAndSettle();
    });
  });
}
