// El cartel de "el dibujo del mapa no carga".
//
// **El reporte del tester**: "no le dejaba hacer nada" — el mapa todo gris,
// sin calles ni paradas, con el panel de líneas funcionando arriba y una
// búsqueda escrita. Reproducido acá: los tiles de OSM son lo ÚNICO de la
// pantalla que necesita red sí o sí, así que sin conexión el mapa queda en
// blanco. Antes de este cartel, la app no decía absolutamente nada — y una
// pantalla en blanco sin explicación se lee como una app rota.
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
import 'package:rutalibre/features/transit/domain/entities/stop.dart';
import 'package:rutalibre/features/transit/domain/entities/transit_network.dart';
import 'package:rutalibre/features/transit/domain/repositories/transit_repository.dart';
import 'package:rutalibre/features/transit/presentation/providers/transit_providers.dart';
import 'package:rutalibre/features/transit/presentation/screens/map_screen.dart';
import 'package:rutalibre/features/weather/domain/entities/rain_forecast.dart';
import 'package:rutalibre/features/weather/presentation/providers/weather_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockRepo extends Mock implements TransitRepository {}

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

/// Los tiles llegan: el caso normal.
class _OkTileProvider extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) =>
      MemoryImage(_transparentPng);
}

/// Ningún tile llega: el teléfono sin datos, o el servidor de OSM caído.
class _DeadTileProvider extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) =>
      const NetworkImage('http://127.0.0.1:9/sin-red.png');
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
];

/// El texto del cartel, por su principio: el resto es una frase larga que se
/// parte en varios renglones.
const _aviso = 'El dibujo del mapa no carga.';

void main() {
  late _MockRepo repo;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    repo = _MockRepo();
    when(() => repo.getLines()).thenAnswer((_) async => const Right([_line]));
  });

  Future<void> pumpMap(WidgetTester tester, TileProvider tiles) async {
    final c = ProviderContainer(
      retry: (retryCount, error) => null,
      overrides: [
        transitRepositoryProvider.overrideWithValue(repo),
        sharedPreferencesProvider.overrideWithValue(prefs),
        allStopsProvider.overrideWith((ref) async => _stops),
        placesProvider.overrideWith((ref) async => const <Place>[]),
        corrientesStopsProvider.overrideWith((ref) async => const []),
        tileProviderFactoryProvider.overrideWithValue(() => tiles),
        rainForecastProvider.overrideWith(
          (ref, point) async => const RainForecast(hours: []),
        ),
        clockProvider.overrideWithValue(() => DateTime(2026, 9, 18, 12)),
      ],
    );
    addTearDown(c.dispose);

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
    // Los tiles fallan de a uno y el cartel espera a que fallen varios, así
    // que hay que dejar correr unos cuadros.
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 400));
    }
  }

  testWidgets('sin red para los tiles, la app lo DICE', (tester) async {
    await pumpMap(tester, _DeadTileProvider());

    expect(find.textContaining(_aviso), findsOneWidget);
    // Y dice qué sigue funcionando: sin esa mitad, el que lo lee cierra la
    // app creyendo que no anda nada.
    expect(find.textContaining('siguen'), findsOneWidget);
  });

  testWidgets('con los tiles llegando no molesta a nadie', (tester) async {
    await pumpMap(tester, _OkTileProvider());

    expect(find.textContaining(_aviso), findsNothing);
  });
}
