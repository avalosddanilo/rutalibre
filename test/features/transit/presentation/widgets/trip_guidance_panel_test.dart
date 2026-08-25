import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rutalibre/features/transit/domain/entities/route_variant.dart';
import 'package:rutalibre/features/transit/domain/entities/stop.dart';
import 'package:rutalibre/features/transit/domain/entities/trip_plan.dart';
import 'package:rutalibre/features/transit/presentation/providers/location_providers.dart';
import 'package:rutalibre/features/transit/presentation/providers/transit_providers.dart';
import 'package:rutalibre/features/transit/presentation/providers/trip_providers.dart';
import 'package:rutalibre/features/transit/presentation/utils/trip_guidance.dart';
import 'package:rutalibre/features/transit/presentation/widgets/trip_guidance_panel.dart';

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
  ProviderContainer container({({double lat, double lng})? position}) {
    final c = ProviderContainer(
      overrides: [
        stopsForRouteProvider('rv1').overrideWith((ref) async => _routeStops),
        livePositionProvider.overrideWith(
          // Sin posición: un stream que nunca emite, como un GPS que no
          // consigue fix. Con posición: un solo valor.
          (ref) =>
              position == null ? const Stream.empty() : Stream.value(position),
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
