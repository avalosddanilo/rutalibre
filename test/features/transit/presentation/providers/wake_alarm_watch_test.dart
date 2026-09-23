import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rutalibre/core/providers/shared_preferences_provider.dart';
import 'package:rutalibre/features/transit/domain/entities/route_variant.dart';
import 'package:rutalibre/features/transit/domain/entities/stop.dart';
import 'package:rutalibre/features/transit/domain/entities/trip_plan.dart';
import 'package:rutalibre/features/transit/presentation/providers/location_providers.dart';
import 'package:rutalibre/features/transit/presentation/providers/transit_providers.dart';
import 'package:rutalibre/features/transit/presentation/providers/wake_alarm_watch.dart';
import 'package:rutalibre/features/transit/presentation/widgets/wake_alarm.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/wake_alarm_test.dart' show FakeWakeAlarmGear;

/// ESTE ARCHIVO NO TIENE UN SOLO `testWidgets`, Y ESA ES LA PRUEBA.
///
/// El bug que arregla todo esto era que la alarma se decidía adentro del
/// `build()` de un widget, y con la pantalla apagada Flutter deja de dibujar
/// cuadros: la condición nunca se evaluaba. Los tests de widget pasaban
/// igual, porque un `tester` dibuja cuadros todo el tiempo — justamente lo
/// que el teléfono dormido no hace.
///
/// Acá no hay árbol de widgets, no hay `tester` y no se dibuja nada. Si la
/// alarma suena en este archivo, suena con la pantalla apagada. Si alguien
/// devuelve la decisión a un widget, estos tests se ponen rojos.
///
/// Ver `docs/alarma-pantalla-apagada.md`.

/// Recorrido recto, paradas cada ~200 m.
final _routeStops = [
  for (var i = 0; i < 8; i++)
    Stop(
      id: 's$i',
      name: 'Parada $i',
      lat: -27.4519,
      lng: -58.9865 + i * 0.002,
    ),
];

final _leg = TripLeg(
  lineId: 'l1',
  lineCode: '3',
  lineName: 'Línea 3',
  colorHex: '#111111',
  networkCode: 'gran-resistencia',
  networkName: 'Gran Resistencia',
  routeVariantId: 'rv1',
  variantName: 'Ida',
  branch: 'A',
  direction: RouteDirection.outbound,
  boardStop: _routeStops[1],
  alightStop: _routeStops[6],
  stopCount: 5,
);

/// Lejos de la bajada: ni prepararse ni alarma.
const _lejos = (lat: -27.4519, lng: -58.9865 + 3 * 0.002);

/// Dos paradas antes: zona de alarma ([RideProgress.shouldWake]).
const _zonaDeAlarma = (lat: -27.4519, lng: -58.9865 + 4 * 0.002);

void main() {
  late SharedPreferences prefs;
  late FakeWakeAlarmGear gear;
  late StreamController<UserPosition> gps;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    gear = FakeWakeAlarmGear();
    gps = StreamController<UserPosition>.broadcast();
    addTearDown(gps.close);
  });

  /// Arma el contenedor y lo deja listo para recibir fixes.
  ///
  /// `armada` es si la persona tocó "Avisame para bajar".
  Future<ProviderContainer> preparar({required bool armada}) async {
    final c = ProviderContainer(
      retry: (retryCount, error) => null,
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        stopsForRouteProvider('rv1').overrideWith((ref) async => _routeStops),
        wakeAlarmGearProvider.overrideWithValue(gear),
        livePositionProvider.overrideWith((ref) => gps.stream),
      ],
    );
    addTearDown(c.dispose);

    if (armada) await c.read(wakeAlarmProvider.notifier).setArmed(true);

    // `listen` y no `read`: los providers son perezosos, y el que decide
    // tiene que estar VIVO antes de que llegue el primer fix.
    c.listen(wakeAlarmWatchProvider, (_, _) {});

    // Y este listen sostiene el stream, como hace el panel en la app real.
    // `livePositionProvider` es autoDispose: cuando el provider de la alarma
    // se reconstruye —al armar, por ejemplo— suelta su suscripción un
    // instante, y sin nadie más escuchando el stream se destruye y se vuelve
    // a suscribir, perdiendo los fixes de esa ventana. En la app el panel lo
    // observa todo el viaje y eso no ocurre; sin esto, el test mediría un
    // problema que solo existe en el test.
    c.listen(livePositionProvider, (_, _) {});

    c.read(watchedRideLegProvider.notifier).watch(_leg);
    // Las paradas del recorrido llegan por Future: sin esto, el primer fix
    // encontraría `stops == null` y no decidiría nada.
    await c.read(stopsForRouteProvider('rv1').future);
    // Y este `read` fuerza la reconstrucción pendiente. Poner el tramo
    // invalida el provider pero Riverpod lo reconstruye recién cuando
    // alguien lo pide, y hasta que no se reconstruya no está suscrito al
    // GPS: un fix que llegue antes se pierde —el stream es broadcast— y el
    // test mide una alarma que nunca tuvo la chance de sonar.
    c.read(wakeAlarmWatchProvider);
    await Future<void>.delayed(Duration.zero);
    return c;
  }

  /// Manda un fix y deja correr el event loop — que es TODO lo que hay.
  /// Ni un `pump`: si esto alcanza, el teléfono dormido alcanza.
  Future<void> fix(UserPosition position) async {
    // Dejar asentar cualquier reconstrucción pendiente ANTES de emitir: el
    // stream es broadcast, y un fix que llega mientras el provider se
    // reconstruye no lo escucha nadie y se pierde.
    await Future<void>.delayed(Duration.zero);
    gps.add(position);
    await Future<void>.delayed(Duration.zero);
  }

  test(
    'con la alarma armada, un fix en zona de bajada la hace sonar',
    () async {
      final c = await preparar(armada: true);

      await fix(_lejos);
      expect(gear.calls, isNot(contains('ring')), reason: 'todavía no');

      await fix(_zonaDeAlarma);

      expect(gear.calls, contains('ring'));
      expect(c.read(wakeAlarmWatchProvider)?.stopName, 'Parada 6');
    },
  );

  test('enciende la pantalla ANTES de sonar', () async {
    // El caso para el que se hizo todo esto: el teléfono en el bolsillo,
    // pantalla apagada y bloqueada. Si el tono arranca antes que la
    // pantalla, el que se despierta lo hace a oscuras sin saber por qué.
    await preparar(armada: true);

    await fix(_zonaDeAlarma);

    expect(gear.calls, containsAllInOrder(['wakeScreen', 'ring']));
  });

  test('sin armar, la zona de bajada NO despierta a nadie', () async {
    final c = await preparar(armada: false);

    await fix(_zonaDeAlarma);

    expect(gear.calls, isNot(contains('ring')));
    expect(c.read(wakeAlarmWatchProvider), isNull);
  });

  test('el GPS oscila y la alarma suena UNA vez', () async {
    // Dos fixes seguidos adentro de la zona no pueden sonar dos veces: la
    // persona ya está despierta y apagarla dos veces es peor que no sonar.
    await preparar(armada: true);

    await fix(_zonaDeAlarma);
    await fix(_zonaDeAlarma);
    await fix(_zonaDeAlarma);

    expect(gear.calls.where((c) => c == 'ring'), hasLength(1));
  });

  test('armar tarde —ya adentro de la zona— igual dispara', () async {
    // El flag se consume cuando SUENA, no cuando se entra en la zona: quien
    // arma la alarma con el colectivo ya llegando tiene que ser despertado
    // igual.
    final c = await preparar(armada: false);

    await fix(_zonaDeAlarma);
    expect(gear.calls, isNot(contains('ring')));

    await c.read(wakeAlarmProvider.notifier).setArmed(true);
    await fix(_zonaDeAlarma);

    expect(gear.calls, contains('ring'));
  });

  test('sin tramo activo no se escucha el GPS', () async {
    // `livePositionProvider` es autoDispose para que fuera de la guía la app
    // no siga a nadie, como dice la política de privacidad. Si este provider
    // se suscribiera "por las dudas", lo mantendría vivo para siempre.
    final c = ProviderContainer(
      retry: (retryCount, error) => null,
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        stopsForRouteProvider('rv1').overrideWith((ref) async => _routeStops),
        wakeAlarmGearProvider.overrideWithValue(gear),
        livePositionProvider.overrideWith((ref) => gps.stream),
      ],
    );
    addTearDown(c.dispose);
    await c.read(wakeAlarmProvider.notifier).setArmed(true);
    c.listen(wakeAlarmWatchProvider, (_, _) {});
    // Sin `watch(_leg)`: no hay viaje.

    await fix(_zonaDeAlarma);

    expect(gear.calls, isNot(contains('ring')));
  });

  test('salir de la zona del tramo rearma el aviso', () async {
    // Bajarse, caminar y volver a subir es raro pero existe.
    final c = await preparar(armada: true);

    await fix(_zonaDeAlarma);
    expect(gear.calls.where((c) => c == 'ring'), hasLength(1));

    // Lejos del recorrido entero: `rideProgress` devuelve null.
    await fix((lat: -27.50, lng: -58.90));
    c.read(wakeAlarmWatchProvider.notifier).dismiss();

    await fix(_zonaDeAlarma);

    expect(gear.calls.where((c) => c == 'ring'), hasLength(2));
  });
}
