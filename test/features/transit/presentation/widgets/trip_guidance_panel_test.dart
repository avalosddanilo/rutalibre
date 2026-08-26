import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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
