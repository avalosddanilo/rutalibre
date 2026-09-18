// Geometrías rotas entrando al mapa: que no lo maten.
//
// **De dónde sale.** Buscando el mapa gris que reportó un tester apareció
// esto: toda la pantalla pasa sus coordenadas por `map_safety.dart` —la
// cámara (`_moveTo`, `_fitRoute`), los pines de parada— menos las
// `Polyline`. Un punto roto ahí no mueve la cámara, así que ninguna de esas
// guardas lo ve. Y uno de los extremos de la caminata sale del GPS, que es de
// donde salió el NaN que mató el mapa la primera vez (ver el encabezado de
// `map_safety.dart`).
//
// **Honestidad sobre qué prueban.** Estos tests NO reproducen el mapa gris
// del tester: se escribieron primero contra la versión sin filtrar y pasaron
// igual — flutter_map 8.3.1 se come un NaN en una `Polyline` sin tirar
// excepción. O sea que el agujero era real pero no era ESE el crash. Quedan
// porque son el guardarraíl de un invariante que el proyecto ya decidió
// ("si nada roto entra, nada revienta adentro") y porque el día que la
// librería deje de tolerarlo, el que rompa el filtro se entera acá.
//
// Lo que sí explica el reporte del tester está en
// `map_screen_tiles_down_test.dart`.
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rutalibre/core/providers/clock_provider.dart';
import 'package:rutalibre/core/providers/shared_preferences_provider.dart';
import 'package:rutalibre/features/transit/domain/entities/bus_line.dart';
import 'package:rutalibre/features/transit/domain/entities/place.dart';
import 'package:rutalibre/features/transit/domain/entities/route_variant.dart';
import 'package:rutalibre/features/transit/domain/entities/stop.dart';
import 'package:rutalibre/features/transit/domain/entities/transit_network.dart';
import 'package:rutalibre/features/transit/domain/repositories/transit_repository.dart';
import 'package:rutalibre/features/transit/presentation/providers/transit_providers.dart';
import 'package:rutalibre/features/transit/presentation/screens/map_screen.dart';
import 'package:rutalibre/features/transit/presentation/widgets/line_sheet.dart';
import 'package:rutalibre/features/weather/domain/entities/rain_forecast.dart';
import 'package:rutalibre/features/weather/presentation/providers/weather_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockRepo extends Mock implements TransitRepository {}

/// Un PNG transparente de 1×1, para servir como "tile" sin salir a la red.
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

class _FakeTileProvider extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) =>
      MemoryImage(_transparentPng);
}

/// `LatLng` NO valida nada: acepta NaN sin chistar. Por eso un dato roto
/// viaja adentro de un `LatLng` hasta el fondo de flutter_map.
LatLng _raw(double lat, double lng) => LatLng(lat, lng);

const _network = TransitNetwork(
  code: 'gran-resistencia',
  name: 'Gran Resistencia',
);

/// La línea del reporte: el tester había escrito "fontana" en el buscador.
const _line = BusLine(
  id: 'l207',
  code: '207',
  name: 'Fontana - Barranqueras',
  colorHex: '#F57C00',
  network: _network,
  sortOrder: 207,
);

const _variant = RouteVariant(
  id: 'rv207',
  lineId: 'l207',
  name: 'Fontana - Barranqueras',
  direction: RouteDirection.outbound,
  isActive: true,
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
    when(
      () => repo.getRouteVariants('l207'),
    ).thenAnswer((_) async => const Right([_variant]));
    when(
      () => repo.getStopsForRoute('rv207'),
    ).thenAnswer((_) async => const Right(_stops));
  });

  // `dynamic` porque Riverpod 3 no exporta el tipo `Override`.
  ProviderContainer container(List<LatLng> geometry) {
    final c = ProviderContainer(
      retry: (retryCount, error) => null,
      overrides: [
        transitRepositoryProvider.overrideWithValue(repo),
        sharedPreferencesProvider.overrideWithValue(prefs),
        allStopsProvider.overrideWith((ref) async => _stops),
        placesProvider.overrideWith((ref) async => const <Place>[]),
        corrientesStopsProvider.overrideWith((ref) async => const []),
        tileProviderFactoryProvider.overrideWithValue(_FakeTileProvider.new),
        routeGeometryProvider.overrideWith((ref, variantId) async => geometry),
        rainForecastProvider.overrideWith(
          (ref, point) async => const RainForecast(hours: []),
        ),
        clockProvider.overrideWithValue(() => DateTime(2026, 9, 18, 12)),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  Future<void> pumpMap(WidgetTester tester, ProviderContainer c) async {
    // Pantalla de teléfono y no los 800×600 del test por defecto: el panel de
    // líneas ocupa el tercio de abajo, y en 600 px de alto el primer
    // resultado de la búsqueda cae FUERA de la pantalla — el `tap` avisa que
    // erró y el test pasa sin haber tocado nada.
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(home: MapScreen()),
      ),
    );
    // pump con duración y NO pumpAndSettle: el mapa anima tiles y a settle no
    // llega nunca en el primer cuadro.
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
  }

  /// El mapa sigue vivo: el crédito de OSM se dibuja adentro del subárbol de
  /// flutter_map, así que si el mapa se convirtió en un recuadro gris, esto
  /// ya no está.
  void expectMapAlive(WidgetTester tester) {
    expect(
      tester.takeException(),
      isNull,
      reason: 'una excepción acá es el recuadro GRIS en release',
    );
    expect(find.textContaining('OpenStreetMap'), findsWidgets);
  }

  testWidgets('un trazado con un punto NaN no deja el mapa gris', (
    tester,
  ) async {
    final c = container([
      LatLng(-27.4519, -58.9865),
      _raw(double.nan, double.nan),
      LatLng(-27.4601, -58.9721),
    ]);
    await pumpMap(tester, c);

    c.read(selectedLineProvider.notifier).select(_line);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    expectMapAlive(tester);
  });

  testWidgets('un trazado ENTERO roto tampoco', (tester) async {
    // Con todos los puntos descartados no queda `Polyline` que dibujar, que
    // es distinto de dibujar una rota: el mapa se queda sin trazado, no sin
    // mapa.
    final c = container([
      _raw(double.nan, -58.98),
      _raw(double.infinity, 0),
      _raw(91, 0),
    ]);
    await pumpMap(tester, c);

    c.read(selectedLineProvider.notifier).select(_line);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    expectMapAlive(tester);
  });

  testWidgets('buscar "fontana" y tocar la línea no rompe nada', (
    tester,
  ) async {
    // El camino tal cual lo hizo el tester: escribir en el buscador de líneas
    // y tocar el resultado.
    final c = container([
      LatLng(-27.4519, -58.9865),
      _raw(double.nan, double.nan),
      LatLng(-27.4601, -58.9721),
    ]);
    await pumpMap(tester, c);

    final searchField = find.descendant(
      of: find.byType(LineSheet),
      matching: find.byType(TextField),
    );
    expect(searchField, findsOneWidget);

    await tester.enterText(searchField, 'fontana');
    await tester.pump(const Duration(milliseconds: 400));

    // Sin tildes y por DESTINO además de por código: "fontana" tiene que
    // encontrarla.
    expect(find.text('Fontana - Barranqueras'), findsOneWidget);

    await tester.tap(find.text('Fontana - Barranqueras'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    expectMapAlive(tester);
  });
}
