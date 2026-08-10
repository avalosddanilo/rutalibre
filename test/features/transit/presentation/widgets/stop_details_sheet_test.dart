import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rutalibre/core/providers/shared_preferences_provider.dart';
import 'package:rutalibre/features/transit/domain/entities/route_at_stop.dart';
import 'package:rutalibre/features/transit/domain/entities/route_variant.dart';
import 'package:rutalibre/features/transit/domain/entities/stop.dart';
import 'package:rutalibre/features/transit/domain/repositories/transit_repository.dart';
import 'package:rutalibre/features/transit/presentation/providers/transit_providers.dart';
import 'package:rutalibre/features/transit/presentation/widgets/stop_details_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockRepo extends Mock implements TransitRepository {}

const _stop = Stop(
  id: 's1',
  name: 'Ameghino y Sáenz Peña',
  lat: -27.4519,
  lng: -58.9865,
);

/// La misma parada como la devuelve una base con la migración 0010 aplicada.
const _stopConNodo = Stop(
  id: 's1',
  name: 'Ameghino y Sáenz Peña',
  lat: -27.4519,
  lng: -58.9865,
  osmNodeId: 2286343843,
);

const _routes = [
  RouteAtStop(
    lineId: 'l3',
    lineCode: '3',
    lineName: 'Vial ↔ Monte Alto',
    colorHex: '#F57C00',
    routeVariantId: 'rv1',
    variantName: 'Ida',
    branch: 'A',
    direction: RouteDirection.outbound,
  ),
];

void main() {
  late _MockRepo repo;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    repo = _MockRepo();
    when(
      () => repo.getRoutesForStop(any()),
    ).thenAnswer((_) async => const Right(_routes));
  });

  testWidgets('abrir el detalle deja la parada marcada como elegida, y sigue '
      'marcada después de cerrar la hoja', (tester) async {
    final container = ProviderContainer(
      overrides: [
        transitRepositoryProvider.overrideWithValue(repo),
        // La hoja ahora tiene la estrella de favorito, que lee las prefs.
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, _) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () =>
                      StopDetailsSheet.show(context, ref, stop: _stop),
                  child: const Text('abrir'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(container.read(selectedStopProvider), isNull);

    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    expect(container.read(selectedStopProvider), _stop);
    expect(find.text('Ameghino y Sáenz Peña'), findsOneWidget);

    // Cerrar la hoja NO deselecciona: el sentido de elegir una parada es que
    // el mapa se calme alrededor de ella, y eso tiene que valer justo cuando
    // uno cierra la hoja para mirar el mapa.
    Navigator.of(tester.element(find.text('abrir'))).pop();
    await tester.pumpAndSettle();

    expect(container.read(selectedStopProvider), _stop);
  });

  group('enlace a OpenStreetMap', () {
    Future<void> pump(WidgetTester tester, Stop stop) async {
      final container = ProviderContainer(
        overrides: [
          transitRepositoryProvider.overrideWithValue(repo),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, _) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () =>
                        StopDetailsSheet.show(context, ref, stop: stop),
                    child: const Text('abrir'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
    }

    testWidgets('con el nodo, la hoja ofrece corregir la parada', (
      tester,
    ) async {
      await pump(tester, _stopConNodo);
      expect(find.text('Ver esta parada en OpenStreetMap'), findsOneWidget);
    });

    testWidgets('sin el nodo no hay enlace: no habría a dónde llevar a nadie', (
      tester,
    ) async {
      // Pasa con una base sin la migración 0010. La hoja tiene que verse
      // exactamente como antes, no con un enlace roto.
      await pump(tester, _stop);
      expect(find.text('Ver esta parada en OpenStreetMap'), findsNothing);
    });
  });
}
