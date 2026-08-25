// ¿Aguanta la app con el texto del sistema al 200%?
//
// **Por qué esto es un test y no una revisión a ojo.** Un desborde de layout
// en Flutter tira una excepción, y en un test eso es un fallo: alcanza con
// dibujar cada pantalla con el texto agrandado para que el framework nos diga
// dónde no entra. A ojo habría que abrir la app, cambiar el ajuste del
// sistema y recorrer todo, cada vez.
//
// Y por qué importa acá más que en otras apps: esto se usa parado en la
// vereda, de reojo, y una parte de quien lo usa tiene el texto agrandado
// justamente porque no ve bien de lejos. Si la pantalla se rompe ahí, se
// rompe para la persona que más la necesita.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rutalibre/core/providers/clock_provider.dart';
import 'package:rutalibre/core/providers/shared_preferences_provider.dart';
import 'package:rutalibre/features/transit/domain/entities/bus_line.dart';
import 'package:rutalibre/features/transit/domain/entities/place.dart';
import 'package:rutalibre/features/transit/domain/entities/route_at_stop.dart';
import 'package:rutalibre/features/transit/domain/entities/route_variant.dart';
import 'package:rutalibre/features/transit/domain/entities/schedule.dart';
import 'package:rutalibre/features/transit/domain/entities/stop.dart';
import 'package:rutalibre/features/transit/domain/entities/transit_network.dart';
import 'package:rutalibre/features/transit/domain/repositories/transit_repository.dart';
import 'package:rutalibre/features/transit/presentation/providers/transit_providers.dart';
import 'package:rutalibre/features/transit/presentation/providers/trip_providers.dart';
import 'package:rutalibre/features/transit/presentation/screens/schedules_screen.dart';
import 'package:rutalibre/features/transit/presentation/widgets/line_sheet.dart';
import 'package:rutalibre/features/transit/presentation/widgets/place_search_sheet.dart';
import 'package:rutalibre/features/transit/presentation/widgets/stop_details_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockRepo extends Mock implements TransitRepository {}

/// El 904C: tiene tarifa Y frecuencia regulada, o sea los dos renglones de
/// datos apilados arriba de la pantalla de horarios. Es el peor caso.
const _line = BusLine(
  id: 'l1',
  code: '904C',
  name: 'Resistencia - Corrientes por Barranqueras',
  colorHex: '#1E88E5',
  network: TransitNetwork(
    code: 'interurbano-chaco-corrientes',
    name: 'Chaco - Corrientes',
  ),
);

const _variant = RouteVariant(
  id: 'rv1',
  lineId: 'l1',
  name: 'Ida: Terminal Resistencia - Puerto de Corrientes',
  branch: 'C',
  direction: RouteDirection.outbound,
  isActive: true,
);

const _stop = Stop(
  id: 's1',
  name: 'Avenida 25 de Mayo y French',
  lat: -27.4519,
  lng: -58.9865,
  description: 'Parada 1234',
  osmNodeId: 2286343843,
);

const _stops = [
  _stop,
  Stop(id: 's2', name: 'Guemes y Santa Maria de Oro', lat: -27.46, lng: -58.97),
];

const _routes = [
  RouteAtStop(
    lineId: 'l1',
    lineCode: '904',
    lineName: 'Resistencia - Corrientes por Barranqueras',
    colorHex: '#1E88E5',
    routeVariantId: 'rv1',
    variantName: 'Ida: Terminal Resistencia - Puerto de Corrientes',
    branch: 'C',
    direction: RouteDirection.outbound,
  ),
];

const _schedules = [
  Schedule(
    id: 'a',
    routeVariantId: 'rv1',
    dayType: DayType.weekday,
    departureTime: Duration(hours: 6, minutes: 5),
  ),
  Schedule(
    id: 'b',
    routeVariantId: 'rv1',
    dayType: DayType.weekday,
    departureTime: Duration(hours: 14, minutes: 30),
  ),
];

/// El tope que hay que aguantar.
///
/// Android llega a 2.0 en "Tamaño de fuente" y bastante más con "Tamaño de
/// pantalla" encima; 2.0 es el piso razonable y ya rompe casi todo lo que se
/// va a romper.
const _scale = TextScaler.linear(2);

void main() {
  late _MockRepo repo;
  late SharedPreferences prefs;

  setUpAll(() {
    registerFallbackValue(DayType.weekday);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    repo = _MockRepo();
    when(() => repo.getLines()).thenAnswer((_) async => const Right([_line]));
    when(
      () => repo.getRouteVariants('l1'),
    ).thenAnswer((_) async => const Right([_variant]));
    when(
      () => repo.getRoutesForStop(any()),
    ).thenAnswer((_) async => const Right(_routes));
    when(
      () => repo.getSchedules(
        routeVariantId: any(named: 'routeVariantId'),
        dayType: any(named: 'dayType'),
      ),
    ).thenAnswer((_) async => const Right(_schedules));
  });

  ProviderContainer container() {
    final c = ProviderContainer(
      retry: (retryCount, error) => null,
      overrides: [
        transitRepositoryProvider.overrideWithValue(repo),
        sharedPreferencesProvider.overrideWithValue(prefs),
        allStopsProvider.overrideWith((ref) async => _stops),
        placesProvider.overrideWith((ref) async => const <Place>[]),
        clockProvider.overrideWithValue(() => DateTime(2026, 8, 25, 12)),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  /// Dibuja [child] con el texto al 200% en una pantalla de teléfono chico.
  ///
  /// El teléfono chico es parte de la prueba: el desborde aparece cuando el
  /// texto grande se junta con poco ancho, que es el combo real de un equipo
  /// barato con la fuente agrandada.
  Future<void> pumpBig(
    WidgetTester tester,
    ProviderContainer c,
    Widget child,
  ) async {
    tester.view
      ..physicalSize = const Size(360 * 2, 640 * 2)
      ..devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: MaterialApp(
          builder: (context, widget) => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: _scale),
            child: widget!,
          ),
          home: child,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('el panel de lineas', (tester) async {
    await pumpBig(
      tester,
      container(),
      Scaffold(
        body: Stack(children: [LineSheet(onPlanTrip: () {})]),
      ),
    );
    expect(find.textContaining('¿A dónde vas?'), findsOneWidget);
  });

  testWidgets('la pantalla de horarios, con tarifa y frecuencia', (
    tester,
  ) async {
    final c = container();
    c.read(selectedLineProvider.notifier).select(_line);
    c.read(selectedRouteVariantProvider.notifier).select(_variant);

    await pumpBig(tester, c, const SchedulesScreen());

    expect(find.text('Línea 904C'), findsOneWidget);
  });

  testWidgets('la hoja de una parada', (tester) async {
    final c = container();
    await pumpBig(
      tester,
      c,
      Consumer(
        builder: (context, ref, _) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => StopDetailsSheet.show(context, ref, stop: _stop),
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    expect(find.text('Avenida 25 de Mayo y French'), findsOneWidget);
  });

  testWidgets('el buscador de destino, con el renglón del origen', (
    tester,
  ) async {
    final c = container();
    c.read(tripSearchProvider.notifier).startFrom((lat: -27.48, lng: -58.94));

    await pumpBig(
      tester,
      c,
      Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => PlaceSearchSheet.showDestination(
                context,
                origin: (lat: -27.48, lng: -58.94),
              ),
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    expect(find.text('¿A dónde vas?'), findsOneWidget);
  });
}
