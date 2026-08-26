import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rutalibre/core/providers/clock_provider.dart';
import 'package:rutalibre/core/providers/shared_preferences_provider.dart';
import 'package:rutalibre/features/transit/domain/entities/route_variant.dart';
import 'package:rutalibre/features/transit/domain/entities/stop.dart';
import 'package:rutalibre/features/transit/domain/entities/trip_plan.dart';
import 'package:rutalibre/features/transit/presentation/providers/location_providers.dart';
import 'package:rutalibre/features/transit/presentation/providers/transit_providers.dart';
import 'package:rutalibre/features/transit/presentation/providers/trip_providers.dart';
import 'package:rutalibre/features/transit/presentation/utils/trip_guidance.dart';
import 'package:rutalibre/features/transit/presentation/widgets/trip_guidance_panel.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Recorrido recto, paradas cada ~200 m (0.002 de longitud a esta latitud).
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

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    // La guía ahora PERSISTE el viaje activo en cada paso (para retomarlo si
    // Android mata la app), así que el harness necesita las prefs como la
    // app real.
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  ProviderContainer container({
    ({double lat, double lng})? position,
    Stream<({double lat, double lng})>? positionStream,
  }) {
    final c = ProviderContainer(
      // Sin reintentos: el retry de Riverpod 3 re-suscribe el stream muerto
      // con un Timer de backoff, y flutter_test acusa el timer pendiente al
      // desmontar. En la app el reintento es deseable (si el permiso vuelve,
      // el contador revive); en el test solo mete ruido.
      retry: (retryCount, error) => null,
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        stopsForRouteProvider('rv1').overrideWith((ref) async => _routeStops),
        livePositionProvider.overrideWith(
          // Sin posición: un stream que nunca emite, como un GPS que no
          // consigue fix. Con posición: un solo valor. Con positionStream:
          // el guion que diga el test (fix y después error, por ejemplo).
          (ref) =>
              positionStream ??
              (position == null
                  ? const Stream.empty()
                  : Stream.value(position)),
        ),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  Future<void> pumpPanel(
    WidgetTester tester,
    ProviderContainer c, {
    required List<GuidanceStep> steps,
    required int stepIndex,
  }) async {
    c.read(tripGuidanceProvider.notifier).start();
    for (var i = 0; i < stepIndex; i++) {
      c.read(tripGuidanceProvider.notifier).next(steps.length);
    }
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: MaterialApp(
          home: Scaffold(body: TripGuidancePanel(steps: steps)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  final steps = [
    BoardStep(_leg),
    RideStep(_leg),
    ArrivalStep(focusLat: -27.4519, focusLng: -58.97),
  ];

  testWidgets('viajando, el contador dice cuántas paradas faltan EN VIVO', (
    tester,
  ) async {
    // Parado en la parada 3, bajando en la 6.
    final c = container(position: (lat: -27.4519, lng: _routeStops[3].lng));
    await pumpPanel(tester, c, steps: steps, stepIndex: 1);

    expect(find.text('Faltan 3 paradas'), findsOneWidget);
  });

  testWidgets('a una parada de bajar, el renglón pide prepararse', (
    tester,
  ) async {
    final c = container(position: (lat: -27.4519, lng: _routeStops[5].lng));
    await pumpPanel(tester, c, steps: steps, stepIndex: 1);

    expect(find.text('La próxima es la tuya — preparate'), findsOneWidget);
  });

  testWidgets('sin GPS el paso queda EXACTAMENTE como siempre', (tester) async {
    // Es el contrato del renglón en vivo: aparece si puede, y si no puede no
    // deja rastro. Nada de "buscando GPS…" arriba del colectivo.
    final c = container();
    await pumpPanel(tester, c, steps: steps, stepIndex: 1);

    expect(find.text('Viajá 5 paradas'), findsOneWidget);
    expect(find.textContaining('Faltan'), findsNothing);
    expect(find.textContaining('GPS'), findsNothing);
  });

  testWidgets('fuera de la zona del tramo, el contador se calla', (
    tester,
  ) async {
    // 2 km al este de todo el recorrido: todavía no subiste o el GPS delira.
    final c = container(
      position: (lat: -27.4519, lng: _routeStops[7].lng + 0.02),
    );
    await pumpPanel(tester, c, steps: steps, stepIndex: 1);

    expect(find.textContaining('Faltan'), findsNothing);
  });

  testWidgets('un fix VIEJO no alimenta el contador: túnel = esperando señal', (
    tester,
  ) async {
    // El GPS puede callarse SIN error (terminal techada, el puente): la
    // posición queda retenida y el contador seguiría corriendo sobre un dato
    // de hace un minuto. Con fixes continuos, más de 25 s de silencio es
    // pérdida de señal, y se dice.
    final ahora = DateTime(2026, 8, 26, 10);
    final c = ProviderContainer(
      retry: (retryCount, error) => null,
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        stopsForRouteProvider('rv1').overrideWith((ref) async => _routeStops),
        clockProvider.overrideWithValue(() => ahora),
        livePositionProvider.overrideWith(
          (ref) => Stream.value((lat: -27.4519, lng: _routeStops[3].lng)),
        ),
      ],
    );
    addTearDown(c.dispose);
    // El último fix llegó hace 30 segundos.
    c
        .read(lastLiveFixAtProvider.notifier)
        .mark(ahora.subtract(const Duration(seconds: 30)));

    await pumpPanel(tester, c, steps: steps, stepIndex: 1);

    expect(find.text('Esperando señal de GPS…'), findsOneWidget);
    expect(find.textContaining('Faltan'), findsNothing);
  });

  testWidgets('el stream de posición SE AUTO-CURA: ubicación prendida tarde', (
    tester,
  ) async {
    // Con la ubicación apagada al arrancar la guía, geolocator ni registra
    // el pedido de updates: prenderla después no emitía nada, nunca. El
    // provider ahora re-suscribe solo cada 8 segundos mientras la guía viva.
    var calls = 0;
    final c = ProviderContainer(
      // Sin el retry de Riverpod: lo que se prueba es NUESTRO reintento.
      retry: (retryCount, error) => null,
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        stopsForRouteProvider('rv1').overrideWith((ref) async => _routeStops),
        locationServiceProvider.overrideWithValue(
          _ScriptedLocationService(() {
            calls++;
            return calls == 1
                ? Stream.error(const LocationServiceDisabled())
                : Stream.value((lat: -27.4519, lng: _routeStops[3].lng));
          }),
        ),
      ],
    );
    addTearDown(c.dispose);
    await pumpPanel(tester, c, steps: steps, stepIndex: 1);

    // Primer intento: muerto al nacer, sin renglón (nunca hubo señal).
    expect(find.textContaining('Faltan'), findsNothing);

    // A los 9 segundos el reintento interno vuelve a suscribir: la
    // ubicación "ya está prendida" y el contador aparece solo.
    await tester.pump(const Duration(seconds: 9));
    await tester.pumpAndSettle();

    expect(calls, 2);
    expect(find.text('Faltan 3 paradas'), findsOneWidget);
  });

  group('el GPS se muere a mitad de viaje', () {
    // El caso real: permiso revocado desde los ajustes de Android/iOS, o la
    // ubicación apagada, CON la guía abierta y el contador andando. El
    // stream se maneja a mano porque el orden importa: fix, un frame donde
    // el contador se VE, y recién ahí el error.
    testWidgets('el contador NO queda congelado: dice que espera señal', (
      tester,
    ) async {
      final gps = StreamController<({double lat, double lng})>();
      addTearDown(gps.close);
      final c = container(positionStream: gps.stream);
      await pumpPanel(tester, c, steps: steps, stepIndex: 1);

      gps.add((lat: -27.4519, lng: _routeStops[3].lng));
      await tester.pumpAndSettle();
      expect(find.text('Faltan 3 paradas'), findsOneWidget);

      // Riverpod conserva el último valor cuando el stream muere: sin el
      // corte explícito, "Faltan 3 paradas" quedaría clavado en pantalla
      // presentado como vivo — un dato viejo con cara de dato.
      gps.addError(Exception('permiso revocado'));
      await tester.pumpAndSettle();

      expect(find.text('Esperando señal de GPS…'), findsOneWidget);
      expect(find.textContaining('Faltan'), findsNothing);
      // Y el paso estático sigue ahí: la guía no se rompe.
      expect(find.text('Viajá 5 paradas'), findsOneWidget);
    });

    testWidgets('si NUNCA hubo señal, el error no agrega ruido', (
      tester,
    ) async {
      // Permiso negado desde el arranque: el stream muere sin haber emitido.
      // Acá el paso sin renglón ES el estado normal — "esperando señal"
      // prometería algo que no va a llegar.
      final c = container(
        positionStream: Stream.error(Exception('sin permiso')),
      );
      await pumpPanel(tester, c, steps: steps, stepIndex: 1);

      expect(find.text('Esperando señal de GPS…'), findsNothing);
      expect(find.text('Viajá 5 paradas'), findsOneWidget);
    });

    testWidgets('"Reintentar" re-suscribe el stream y el contador revive', (
      tester,
    ) async {
      // Los reintentos automáticos se rinden con backoff creciente: quien
      // apagó la ubicación por error y la prendió cinco minutos después se
      // quedaba mirando "esperando" para siempre. El botón revive el stream.
      var subscriptions = 0;
      final gps = StreamController<({double lat, double lng})>();
      addTearDown(gps.close);
      final c = ProviderContainer(
        retry: (retryCount, error) => null,
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          stopsForRouteProvider('rv1').overrideWith((ref) async => _routeStops),
          livePositionProvider.overrideWith((ref) {
            subscriptions++;
            // Primera suscripción: el guion del GPS que se apaga (lo maneja
            // el test a mano). Segunda (tras Reintentar): señal de vuelta.
            return subscriptions == 1
                ? gps.stream
                : Stream.value((lat: -27.4519, lng: _routeStops[5].lng));
          }),
        ],
      );
      addTearDown(c.dispose);
      await pumpPanel(tester, c, steps: steps, stepIndex: 1);

      gps.add((lat: -27.4519, lng: _routeStops[3].lng));
      await tester.pumpAndSettle();
      expect(find.text('Faltan 3 paradas'), findsOneWidget);

      gps.addError(Exception('ubicación apagada'));
      await tester.pumpAndSettle();
      expect(find.text('Esperando señal de GPS…'), findsOneWidget);

      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();

      expect(subscriptions, 2);
      expect(find.text('La próxima es la tuya — preparate'), findsOneWidget);
      expect(find.text('Esperando señal de GPS…'), findsNothing);
    });

    testWidgets('caminando pasa lo mismo: aviso, no metros congelados', (
      tester,
    ) async {
      final walkSteps = [
        WalkStep(
          meters: 400,
          toName: 'Parada 1',
          focusLat: _routeStops[1].lat,
          focusLng: _routeStops[1].lng,
          isFinal: false,
        ),
        ...steps,
      ];
      final gps = StreamController<({double lat, double lng})>();
      addTearDown(gps.close);
      final c = container(positionStream: gps.stream);
      await pumpPanel(tester, c, steps: walkSteps, stepIndex: 0);

      gps.add((lat: -27.4519, lng: _routeStops[0].lng));
      await tester.pumpAndSettle();
      expect(find.textContaining('Faltan ~'), findsOneWidget);

      gps.addError(Exception('ubicación apagada'));
      await tester.pumpAndSettle();

      expect(find.text('Esperando señal de GPS…'), findsOneWidget);
      expect(find.textContaining('Faltan ~'), findsNothing);
    });
  });

  testWidgets('caminando, dice los metros que quedan en vivo', (tester) async {
    final walkSteps = [
      WalkStep(
        meters: 400,
        toName: 'Parada 1',
        focusLat: _routeStops[1].lat,
        focusLng: _routeStops[1].lng,
        isFinal: false,
      ),
      ...steps,
    ];
    // A ~198 m de la parada 1.
    final c = container(position: (lat: -27.4519, lng: _routeStops[0].lng));
    await pumpPanel(tester, c, steps: walkSteps, stepIndex: 0);

    expect(find.textContaining('Faltan ~'), findsOneWidget);
  });
}

/// Un LocationService cuyo stream de posición lo decide el test.
final class _ScriptedLocationService implements LocationService {
  _ScriptedLocationService(this._stream);

  final Stream<({double lat, double lng})> Function() _stream;

  @override
  Stream<({double lat, double lng})> positionStream() => _stream();

  @override
  Future<LocationFix> currentPosition() => throw UnimplementedError();

  @override
  Future<({double lat, double lng})?> lastKnownPosition() async => null;
}
