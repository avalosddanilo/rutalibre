import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rutalibre/core/providers/shared_preferences_provider.dart';
import 'package:rutalibre/features/transit/domain/entities/reference_stop.dart';
import 'package:rutalibre/features/transit/domain/entities/route_variant.dart';
import 'package:rutalibre/features/transit/domain/entities/stop.dart';
import 'package:rutalibre/features/transit/domain/entities/trip_plan.dart';
import 'package:rutalibre/features/transit/presentation/providers/transit_providers.dart';
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

  group('sin viaje a distancia caminable', () {
    // El hallazgo de campo: un destino de salud en Corrientes terminaba en
    // "no encontramos cómo llegar", aunque el 904 cruza hasta allá y la app
    // sabe qué líneas urbanas paran en cada esquina de Corrientes.
    const destino = (lat: -27.5000, lng: -58.7900);
    const query = (
      originLat: -27.4869,
      originLng: -58.9469,
      destLat: -27.5000,
      destLng: -58.7900,
    );

    final approach = TripPlan(
      legs: [
        TripLeg(
          lineId: 'l904',
          lineCode: '904',
          lineName: 'Chaco ↔ Corrientes',
          colorHex: '#7B1FA2',
          networkCode: 'interurbano-chaco-corrientes',
          networkName: 'Chaco ↔ Corrientes',
          routeVariantId: 'rv904',
          variantName: 'Ida',
          branch: 'A',
          direction: RouteDirection.outbound,
          boardStop: const Stop(
            id: 'b',
            name: 'Terminal',
            lat: -27.4869,
            lng: -58.9469,
          ),
          alightStop: const Stop(
            id: 'a',
            name: 'Parada Chaco-Corrientes',
            lat: -27.4700,
            lng: -58.8380,
          ),
          stopCount: 30,
        ),
      ],
      walkToBoardMeters: 50,
      walkFromAlightMeters: 3600,
    );

    Future<void> pumpEmpty(
      WidgetTester tester,
      List<ReferenceStop> corrientes,
    ) async {
      final c = ProviderContainer(
        retry: (retryCount, error) => null,
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          tripPlansProvider(
            query,
          ).overrideWith((ref) async => const <TripPlan>[]),
          approachTripProvider(query).overrideWith((ref) async => approach),
          corrientesStopsProvider.overrideWith((ref) async => corrientes),
        ],
      );
      addTearDown(c.dispose);
      c.read(tripSearchProvider.notifier)
        ..startFrom(_casa)
        ..setDestination(destino);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: const MaterialApp(
            home: Scaffold(body: TripResultsSheet(query: query)),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('muestra el colectivo que más te acerca, no un "no"', (
      tester,
    ) async {
      await pumpEmpty(tester, const []);

      expect(find.textContaining('No encontramos'), findsNothing);
      expect(find.textContaining('el que más te acerca'), findsOneWidget);
      expect(find.textContaining('904'), findsWidgets);
    });

    testWidgets('sugiere la línea urbana que conecta la bajada con el destino', (
      tester,
    ) async {
      await pumpEmpty(tester, const [
        ReferenceStop(
          name: 'Junín y La Rioja',
          lat: -27.4705,
          lng: -58.8382,
          lines: ['101', '103A'],
        ),
        ReferenceStop(
          name: 'Avenida Maipú y Cazadores',
          lat: -27.5003,
          lng: -58.7902,
          lines: ['103A'],
        ),
      ]);

      expect(
        find.textContaining('podés tomar la 103A en Junín y La Rioja'),
        findsOneWidget,
      );
      // Y dice de dónde sale y qué no sabe: el sentido no está en ningún dato.
      expect(find.textContaining('confirmá con el chofer'), findsOneWidget);
    });
  });

  group('transbordo caminando (plan_trip_v2)', () {
    // Desde un barrio de Corrientes a Resistencia: la 102 deja en una
    // parada de la Municipalidad y el 904 para en otra, de OpenStreetMap.
    const query = (
      originLat: -27.48385,
      originLng: -58.79109,
      destLat: -27.462627,
      destLng: -58.985006,
    );

    TripLeg leg(String code, Stop board, Stop alight, int stops) => TripLeg(
      lineId: 'l$code',
      lineCode: code,
      lineName: 'Línea $code',
      colorHex: '#7B1FA2',
      networkCode: 'n',
      networkName: 'N',
      routeVariantId: 'rv$code',
      variantName: 'Ida',
      branch: null,
      direction: RouteDirection.outbound,
      boardStop: board,
      alightStop: alight,
      stopCount: stops,
    );

    const araoz = Stop(
      id: 'm1',
      name: 'Pedro Araoz y Avenida Independencia',
      lat: -27.48308,
      lng: -58.792402,
    );
    const ferre = Stop(
      id: 'm2',
      name: 'Avenida Pedro Ferré y Avenida Chacabuco',
      lat: -27.4800,
      lng: -58.8050,
    );
    const chacabuco = Stop(
      id: 'o1',
      name: 'Avenida Chacabuco y Pje. Sarmiento',
      lat: -27.4801,
      lng: -58.8055,
    );
    const lasHeras = Stop(
      id: 'o2',
      name: 'Avenida Las Heras y Franklin',
      lat: -27.4627,
      lng: -58.9850,
    );

    testWidgets('dice que hay que caminar y a qué parada, no "la misma"', (
      tester,
    ) async {
      final plan = TripPlan(
        legs: [
          leg('102', araoz, ferre, 9),
          leg('904A', chacabuco, lasHeras, 51),
        ],
        walkToBoardMeters: 151,
        walkFromAlightMeters: 100,
        transferWalkMeters: 46,
      );
      final c = ProviderContainer(
        retry: (retryCount, error) => null,
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          tripPlansProvider(query).overrideWith((ref) async => [plan]),
        ],
      );
      addTearDown(c.dispose);
      c.read(tripSearchProvider.notifier)
        ..startFrom((lat: query.originLat, lng: query.originLng))
        ..setDestination((lat: query.destLat, lng: query.destLng));

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: const MaterialApp(
            home: Scaffold(body: TripResultsSheet(query: query)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('misma parada'), findsNothing);
      expect(
        find.textContaining(
          'Caminás 46 m y te cambiás a la 904A en '
          'Avenida Chacabuco y Pje. Sarmiento',
        ),
        findsOneWidget,
      );
    });

    Future<void> pumpPlan(WidgetTester tester, TripPlan plan) async {
      final c = ProviderContainer(
        retry: (retryCount, error) => null,
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          tripPlansProvider(query).overrideWith((ref) async => [plan]),
        ],
      );
      addTearDown(c.dispose);
      c.read(tripSearchProvider.notifier)
        ..startFrom((lat: query.originLat, lng: query.originLng))
        ..setDestination((lat: query.destLat, lng: query.destLng));
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: const MaterialApp(
            home: Scaffold(body: TripResultsSheet(query: query)),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('calculado sin conexión, lo dice y avisa que no hay avisos', (
      tester,
    ) async {
      await pumpPlan(
        tester,
        TripPlan(
          legs: [leg('102', araoz, ferre, 9)],
          walkToBoardMeters: 151,
          walkFromAlightMeters: 100,
          calculatedOffline: true,
        ),
      );
      expect(find.textContaining('Sin conexión'), findsOneWidget);
      expect(find.textContaining('paros ni desvíos'), findsOneWidget);
    });

    testWidgets('con conexión, no hay cartel', (tester) async {
      await pumpPlan(
        tester,
        TripPlan(
          legs: [leg('102', araoz, ferre, 9)],
          walkToBoardMeters: 151,
          walkFromAlightMeters: 100,
        ),
      );
      expect(find.textContaining('Sin conexión'), findsNothing);
    });
  });
}
