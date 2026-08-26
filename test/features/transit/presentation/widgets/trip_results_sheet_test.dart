import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rutalibre/core/providers/shared_preferences_provider.dart';
import 'package:rutalibre/features/transit/domain/entities/trip_plan.dart';
import 'package:rutalibre/features/transit/presentation/providers/trip_providers.dart';
import 'package:rutalibre/features/transit/presentation/widgets/trip_results_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _casa = (lat: -27.4869, lng: -58.9469);
const _campus = (lat: -27.4699, lng: -58.7823);

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Future<ProviderContainer> pumpSheet(
    WidgetTester tester, {
    required bool guiding,
  }) async {
    final c = ProviderContainer(
      retry: (retryCount, error) => null,
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        // La lista en sí no importa acá: vacía alcanza para dibujar la hoja.
        tripPlansProvider(const (
          originLat: -27.4869,
          originLng: -58.9469,
          destLat: -27.4699,
          destLng: -58.7823,
        )).overrideWith((ref) async => const <TripPlan>[]),
      ],
    );
    addTearDown(c.dispose);

    c.read(tripSearchProvider.notifier)
      ..startFrom(_casa)
      ..setDestination(_campus);
    if (guiding) c.read(tripGuidanceProvider.notifier).start();

    final query = (c.read(tripSearchProvider) as TripRoute).query;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: MaterialApp(
          home: Scaffold(body: TripResultsSheet(query: query)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return c;
  }

  testWidgets('sin guía, "invertir el viaje" está a un toque', (tester) async {
    await pumpSheet(tester, guiding: false);
    expect(find.byIcon(Icons.swap_vert), findsOneWidget);
  });

  testWidgets('con la guía ANDANDO, invertir no se ofrece', (tester) async {
    // Invertir suelta el viaje elegido, y soltarlo mata la guía y borra su
    // guardado — un toque, sin confirmación, arriba del colectivo. "Para
    // volver" es una pregunta de después de llegar.
    await pumpSheet(tester, guiding: true);
    expect(find.byIcon(Icons.swap_vert), findsNothing);
  });
}
