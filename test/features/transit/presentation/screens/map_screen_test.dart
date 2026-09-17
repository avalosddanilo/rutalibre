// Los PRIMEROS widget tests de la pantalla principal.
//
// map_screen.dart es el archivo más grande de la app y hasta ahora tenía
// CERO tests: dibujar un mapa exige tiles, y el TileProvider por defecto sale
// a la red — que en un test devuelve 400 por cada tile y llena la corrida de
// excepciones. La salida fue hacer el provider inyectable
// (`tileProviderFactoryProvider`) y servir acá una imagen fija.
//
// No prueban el dibujo del mapa (eso es de flutter_map): prueban que NUESTRA
// composición arranca y que el modo "¿cómo llego?" entra y sale bien.
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rutalibre/core/providers/clock_provider.dart';
import 'package:rutalibre/core/providers/shared_preferences_provider.dart';
import 'package:rutalibre/features/transit/domain/entities/bus_line.dart';
import 'package:rutalibre/features/transit/domain/entities/place.dart';
import 'package:rutalibre/features/transit/domain/entities/route_variant.dart';
import 'package:rutalibre/features/transit/domain/entities/stop.dart';
import 'package:rutalibre/features/transit/domain/entities/street_addresses.dart';
import 'package:rutalibre/features/transit/domain/entities/transit_network.dart';
import 'package:rutalibre/features/transit/domain/entities/trip_plan.dart';
import 'package:rutalibre/features/transit/domain/repositories/transit_repository.dart';
import 'package:rutalibre/features/transit/presentation/providers/transit_providers.dart';
import 'package:rutalibre/features/transit/presentation/providers/trip_providers.dart';
import 'package:rutalibre/features/transit/presentation/screens/map_screen.dart';
import 'package:rutalibre/features/transit/presentation/widgets/place_search_sheet.dart';
import 'package:rutalibre/features/transit/presentation/widgets/trip_results_sheet.dart';
import 'package:rutalibre/features/transit/presentation/widgets/wake_alarm.dart';
import 'package:rutalibre/features/weather/domain/entities/rain_forecast.dart';
import 'package:rutalibre/features/weather/presentation/providers/weather_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/wake_alarm_test.dart' show FakeWakeAlarmGear;

class _MockRepo extends Mock implements TransitRepository {}

/// Un PNG transparente de 1×1, para servir como "tile".
final _transparentPng = Uint8List.fromList(const [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, //
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, //
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, //
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, //
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, //
  0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, //
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, //
  0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, //
  0x42, 0x60, 0x82,
]);

/// Sirve el mismo pixel para todos los tiles, sin tocar la red.
class _FakeTileProvider extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) =>
      MemoryImage(_transparentPng);
}

const _line = BusLine(
  id: 'l3',
  code: '3',
  name: 'Vial - Monte Alto',
  colorHex: '#F57C00',
  network: TransitNetwork(code: 'gran-resistencia', name: 'Gran Resistencia'),
);

const _stops = [
  Stop(id: 's1', name: 'Ameghino y French', lat: -27.4519, lng: -58.9865),
  Stop(id: 's2', name: 'Guemes y Franklin', lat: -27.4601, lng: -58.9721),
];

void main() {
  late _MockRepo repo;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    repo = _MockRepo();
    when(() => repo.getLines()).thenAnswer((_) async => const Right([_line]));
  });

  // `dynamic` porque Riverpod 3 no exporta el tipo `Override`: los elementos
  // se bajan solos al tipo interno al entrar a la lista de overrides.
  ProviderContainer container({List<dynamic> extra = const []}) {
    final c = ProviderContainer(
      retry: (retryCount, error) => null,
      overrides: [
        ...extra,
        transitRepositoryProvider.overrideWithValue(repo),
        sharedPreferencesProvider.overrideWithValue(prefs),
        allStopsProvider.overrideWith((ref) async => _stops),
        placesProvider.overrideWith((ref) async => const <Place>[]),
        corrientesStopsProvider.overrideWith((ref) async => const []),
        tileProviderFactoryProvider.overrideWithValue(_FakeTileProvider.new),
        // Sin pronóstico: el chip de lluvia no se dibuja, que es el estado
        // de la mayoría de los arranques (y evita el fetch a Open-Meteo).
        rainForecastProvider.overrideWith(
          (ref, point) async => const RainForecast(hours: []),
        ),
        clockProvider.overrideWithValue(() => DateTime(2026, 8, 25, 12)),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  Future<void> pumpMap(WidgetTester tester, ProviderContainer c) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(home: MapScreen()),
      ),
    );
    // pump con duración y NO pumpAndSettle: el mapa anima tiles y la lista
    // entra escalonada; a settle no llega nunca en el primer cuadro.
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('arranca entera: mapa, marca, crédito OSM y panel de líneas', (
    tester,
  ) async {
    await pumpMap(tester, container());

    // El crédito de OSM es obligación de la licencia ODbL: si un refactor lo
    // pierde, este test lo dice antes que la comunidad de OSM.
    expect(find.textContaining('OpenStreetMap'), findsWidgets);
    // La pregunta principal, arriba del panel.
    expect(find.text('¿A dónde vas?'), findsOneWidget);
    // Y la línea del mock, listada.
    expect(find.text('Vial - Monte Alto'), findsOneWidget);
  });

  testWidgets('el modo "¿cómo llego?" muestra el banner y Cancelar lo apaga', (
    tester,
  ) async {
    final c = container();
    await pumpMap(tester, c);

    // Como si el GPS ya hubiera contestado.
    c.read(tripSearchProvider.notifier).startFrom((
      lat: -27.4519,
      lng: -58.9865,
    ));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Tocá en el mapa a dónde querés ir'), findsOneWidget);

    await tester.tap(find.text('Cancelar'));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Tocá en el mapa a dónde querés ir'), findsNothing);
    expect(c.read(tripSearchProvider), isA<TripIdle>());
  });

  testWidgets('con el texto del sistema al 200% no desborda', (tester) async {
    // La pantalla principal también entra en la política de accesibilidad:
    // un desborde acá es una excepción y el test la reporta.
    tester.view
      ..physicalSize = const Size(360 * 2, 640 * 2)
      ..devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container(),
        child: MaterialApp(
          builder: (context, widget) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(2)),
            child: widget!,
          ),
          home: const MapScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.textContaining('¿A dónde vas?'), findsOneWidget);
  });

  testWidgets('elegir una dirección del buscador abre la hoja de viajes', (
    tester,
  ) async {
    // El bug de campo: "pongo san juan 5240... ya no me aparece cómo llegar
    // en cole ni nada". El destino se fijaba (la bandera aparecía) pero la
    // hoja de resultados nunca — este test recorre el camino ENTERO, del
    // banner al resultado, sobre la pantalla real.
    final c = container(
      extra: [
        addressesProvider.overrideWith(
          (ref) async => const [
            StreetAddresses(
              street: 'San Juan',
              locality: 'Barranqueras',
              numbers: [
                AddressPoint(number: 5200, lat: -27.47643, lng: -58.92416),
              ],
            ),
          ],
        ),
        // Sin viajes: alcanza con que la HOJA se abra — lo que muestre
        // adentro es asunto de sus propios tests.
        tripPlansProvider.overrideWith((ref, query) async => const []),
      ],
    );
    await pumpMap(tester, c);

    c.read(tripSearchProvider.notifier).startFrom((
      lat: -27.4519,
      lng: -58.9865,
    ));
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.byTooltip('Buscarlo por nombre'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    await tester.enterText(find.byType(TextField).last, 'san juan 5200');
    // Dos cuadros: el asset de alturas se carga recién con el número escrito
    // (un future), y el resultado se dibuja en el cuadro siguiente.
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.text('San Juan 5200 (Barranqueras)'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    // El buscador se fue, la hoja de viajes está, el destino quedó.
    expect(find.byType(PlaceSearchSheet), findsNothing);
    expect(find.byType(TripResultsSheet), findsOneWidget);
    expect(c.read(tripSearchProvider), isA<TripRoute>());
  });

  testWidgets('elegido un viaje, el panel de abajo lo resume y lo arranca', (
    tester,
  ) async {
    // El hallazgo de campo, textual: "en vez de tener que poner iniciar
    // viaje a un costado, sea más grande en medio abajo... porque si no
    // podría parecer bug la app". Elegida la opción quedaba el mapa pelado
    // con un botón chico al costado — el momento del "dale, empezá" era el
    // más mudo de la app.
    final leg = TripLeg(
      lineId: 'l3',
      lineCode: '3',
      lineName: 'Vial - Monte Alto',
      colorHex: '#F57C00',
      networkCode: 'gran-resistencia',
      networkName: 'Gran Resistencia',
      routeVariantId: 'rv1',
      variantName: 'Ida',
      branch: null,
      direction: RouteDirection.outbound,
      boardStop: _stops[0],
      alightStop: _stops[1],
      stopCount: 1,
    );
    final plan = TripPlan(
      legs: [leg],
      walkToBoardMeters: 200,
      walkFromAlightMeters: 100,
    );

    final gear = FakeWakeAlarmGear();
    final c = container(extra: [wakeAlarmGearProvider.overrideWithValue(gear)]);
    await pumpMap(tester, c);

    // Como un viaje ya elegido: TripRoute en una sola transición (restore no
    // abre la hoja de resultados, que acá taparía justo lo que se prueba).
    c
        .read(tripSearchProvider.notifier)
        .restore(
          origin: (lat: _stops[0].lat, lng: _stops[0].lng),
          destination: (lat: _stops[1].lat, lng: _stops[1].lng),
        );
    c.read(selectedTripProvider.notifier).select(plan);
    await tester.pump(const Duration(milliseconds: 400));

    // El resumen, abajo y grande: qué tomás, dónde subís, dónde bajás.
    expect(find.text('Subís en Ameghino y French'), findsOneWidget);
    expect(find.text('Bajás en Guemes y Franklin · 1 parada'), findsOneWidget);
    expect(find.text('Iniciar viaje'), findsOneWidget);
    expect(find.text('Ver otras opciones'), findsOneWidget);

    await tester.tap(find.text('Iniciar viaje'));
    await tester.pump(const Duration(milliseconds: 400));

    // Arrancó: la guía en pantalla y el panel del resumen ya cumplió.
    expect(c.read(tripGuidanceProvider), 0);
    expect(find.text('Iniciar viaje'), findsNothing);
    expect(find.text('Siguiente'), findsOneWidget);
    // Y se SINTIÓ: el ding del arranque, pedido en la prueba de campo.
    expect(gear.calls, contains('chime'));
  });

  group('salir de un viaje elegido', () {
    // El hallazgo de campo: con un viaje elegido el botón "Salir" quedaba
    // tapado detrás del panel, y el ATRÁS del teléfono cerraba la app.
    TripPlan plan() => TripPlan(
      legs: [
        TripLeg(
          lineId: 'l3',
          lineCode: '3',
          lineName: 'Vial - Monte Alto',
          colorHex: '#F57C00',
          networkCode: 'gran-resistencia',
          networkName: 'Gran Resistencia',
          routeVariantId: 'rv1',
          variantName: 'Ida',
          branch: null,
          direction: RouteDirection.outbound,
          boardStop: _stops[0],
          alightStop: _stops[1],
          stopCount: 1,
        ),
      ],
      walkToBoardMeters: 200,
      walkFromAlightMeters: 100,
    );

    Future<ProviderContainer> pumpWithTrip(WidgetTester tester) async {
      final c = container(
        extra: [
          wakeAlarmGearProvider.overrideWithValue(FakeWakeAlarmGear()),
          tripPlansProvider.overrideWith((ref, query) async => [plan()]),
        ],
      );
      await pumpMap(tester, c);
      c
          .read(tripSearchProvider.notifier)
          .restore(
            origin: (lat: _stops[0].lat, lng: _stops[0].lng),
            destination: (lat: _stops[1].lat, lng: _stops[1].lng),
          );
      c.read(selectedTripProvider.notifier).select(plan());
      await tester.pump(const Duration(milliseconds: 400));
      return c;
    }

    testWidgets('la cruz del panel sale del "¿cómo llego?"', (tester) async {
      final c = await pumpWithTrip(tester);

      await tester.tap(find.byTooltip('Salir').last);
      await tester.pump(const Duration(milliseconds: 400));

      expect(c.read(tripSearchProvider), isA<TripIdle>());
      expect(find.text('Iniciar viaje'), findsNothing);
      // Al salir vuelve el panel de líneas con su entrada escalonada.
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('ATRÁS desanda un paso por vez y no cierra la app', (
      tester,
    ) async {
      final c = await pumpWithTrip(tester);

      // Primer atrás: suelta el viaje elegido y vuelve a la lista.
      await tester.binding.handlePopRoute();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 400));
      expect(c.read(selectedTripProvider), isNull);
      expect(c.read(tripSearchProvider), isA<TripRoute>());
      expect(find.byType(TripResultsSheet), findsOneWidget);

      // Segundo: cierra la lista (la hoja se cierra sola con atrás).
      await tester.binding.handlePopRoute();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(TripResultsSheet), findsNothing);

      // Tercero: sale del modo. Recién ahí no queda nada que deshacer.
      await tester.binding.handlePopRoute();
      await tester.pump(const Duration(milliseconds: 400));
      expect(c.read(tripSearchProvider), isA<TripIdle>());
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('con la guía andando, ATRÁS avisa en vez de cortarla', (
      tester,
    ) async {
      final c = await pumpWithTrip(tester);
      c.read(tripGuidanceProvider.notifier).start();
      await tester.pump(const Duration(milliseconds: 400));

      await tester.binding.handlePopRoute();
      await tester.pump(const Duration(milliseconds: 400));

      // Un roce en el bolsillo no puede perder la guía a mitad de viaje.
      expect(c.read(tripGuidanceProvider), 0);
      expect(find.textContaining('tocá "Terminar"'), findsOneWidget);
    });
  });
}
