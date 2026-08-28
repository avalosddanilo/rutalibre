import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rutalibre/core/providers/shared_preferences_provider.dart';
import 'package:rutalibre/features/transit/domain/entities/place.dart';
import 'package:rutalibre/features/transit/domain/entities/stop.dart';
import 'package:rutalibre/features/transit/presentation/providers/transit_providers.dart';
import 'package:rutalibre/features/transit/presentation/providers/trip_providers.dart';
import 'package:rutalibre/features/transit/presentation/providers/user_prefs_providers.dart';
import 'package:rutalibre/features/transit/presentation/widgets/place_search_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _stops = [
  Stop(id: 's1', name: 'Ameghino y Sáenz Peña', lat: -27.4519, lng: -58.9865),
  Stop(id: 's2', name: 'French y Güemes', lat: -27.4601, lng: -58.9721),
];

/// Donde dice estar el GPS. El origen a mano tiene que poder reemplazarlo.
const _gpsPoint = (lat: -27.4869, lng: -58.9469);

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  ProviderContainer container() {
    final c = ProviderContainer(
      overrides: [
        allStopsProvider.overrideWith((ref) async => _stops),
        placesProvider.overrideWith((ref) async => const <Place>[]),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  Future<void> pumpSheet(
    WidgetTester tester,
    ProviderContainer c,
    void Function(BuildContext context) open,
  ) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => open(context),
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

  testWidgets('el buscador de origen pone el origen con su nombre', (
    tester,
  ) async {
    final c = container();
    await pumpSheet(
      tester,
      c,
      (context) =>
          PlaceSearchSheet.showOrigin(context, notice: 'No pudimos ubicarte.'),
    );

    // El cartel dice por qué apareció esta hoja: sin eso, pedir el origen
    // después de tocar "¿a dónde vas?" parece la pantalla equivocada.
    expect(find.text('¿De dónde salís?'), findsOneWidget);
    expect(find.text('No pudimos ubicarte.'), findsOneWidget);
    // El GPS sigue estando a un toque: es la respuesta correcta casi siempre.
    expect(find.text('Usar mi ubicación'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'ameghino');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ameghino y Sáenz Peña'));
    await tester.pumpAndSettle();

    final state = c.read(tripSearchProvider);
    expect(state, isA<TripPickingDestination>());
    expect(
      (state as TripPickingDestination).originName,
      'Ameghino y Sáenz Peña',
    );
    expect(state.origin, (lat: -27.4519, lng: -58.9865));

    // Un lugar donde uno ESTUVO PARADO no es un destino reciente: la lista se
    // llama "últimos destinos" y llenarla con orígenes la volvería otra cosa.
    expect(c.read(recentDestinationsProvider), isEmpty);
  });

  testWidgets('eligiendo destino se ve de dónde sale el viaje y se puede '
      'cambiar sin cerrar la hoja', (tester) async {
    final c = container();
    // Como si el GPS hubiera contestado: sin nombre.
    c.read(tripSearchProvider.notifier).startFrom(_gpsPoint);

    await pumpSheet(
      tester,
      c,
      (context) => PlaceSearchSheet.showDestination(context, origin: _gpsPoint),
    );

    expect(find.text('¿A dónde vas?'), findsOneWidget);
    // Sin nombre se dice "mi ubicación": el GPS no devuelve uno y ponerle
    // cualquier otro lo haría parecer un lugar elegido.
    expect(find.text('Desde Mi ubicación'), findsOneWidget);

    await tester.tap(find.text('Cambiar'));
    await tester.pumpAndSettle();

    expect(find.text('¿De dónde salís?'), findsOneWidget);

    await tester.enterText(find.byType(TextField).last, 'french');
    await tester.pumpAndSettle();
    await tester.tap(find.text('French y Güemes'));
    await tester.pumpAndSettle();

    // Volvió al buscador de destino, ya con el origen nuevo: el destino sigue
    // sin elegirse y no hubo que empezar de nuevo.
    expect(find.text('¿A dónde vas?'), findsOneWidget);
    expect(find.text('Desde French y Güemes'), findsOneWidget);
    expect(c.read(tripSearchProvider), isA<TripPickingDestination>());
  });

  group('calle con número de puerta', () {
    // Hallazgo de campo: "Ameghino 1250" no matcheaba nada, porque los datos
    // tienen ESQUINAS, no números de puerta. Para el usuario eso se leía
    // como "la app no conoce mi calle".
    testWidgets('"ameghino 1250" muestra las esquinas de Ameghino, y lo dice', (
      tester,
    ) async {
      final c = container();
      c.read(tripSearchProvider.notifier).startFrom(_gpsPoint);
      await pumpSheet(
        tester,
        c,
        (context) =>
            PlaceSearchSheet.showDestination(context, origin: _gpsPoint),
      );

      await tester.enterText(find.byType(TextField), 'ameghino 1250');
      await tester.pumpAndSettle();

      // La esquina aparece…
      expect(find.text('Ameghino y Sáenz Peña'), findsOneWidget);
      // …y el cartel aclara que el número no se usó: mostrar esquinas como
      // si fueran la dirección exacta sería dejar creer que una de esas ES.
      expect(
        find.textContaining('Los números de puerta no están'),
        findsOneWidget,
      );
      expect(find.textContaining('Nada coincide'), findsNothing);
    });

    testWidgets('un número solo, sin calle, sigue sin inventar nada', (
      tester,
    ) async {
      final c = container();
      c.read(tripSearchProvider.notifier).startFrom(_gpsPoint);
      await pumpSheet(
        tester,
        c,
        (context) =>
            PlaceSearchSheet.showDestination(context, origin: _gpsPoint),
      );

      await tester.enterText(find.byType(TextField), '1250');
      await tester.pumpAndSettle();

      expect(find.textContaining('Nada coincide'), findsOneWidget);
    });

    testWidgets('una búsqueda que matchea entera no pasa por el recorte', (
      tester,
    ) async {
      // "sáenz" matchea directo: ni cartel ni recorte.
      final c = container();
      c.read(tripSearchProvider.notifier).startFrom(_gpsPoint);
      await pumpSheet(
        tester,
        c,
        (context) =>
            PlaceSearchSheet.showDestination(context, origin: _gpsPoint),
      );

      await tester.enterText(find.byType(TextField), 'saenz');
      await tester.pumpAndSettle();

      expect(find.text('Ameghino y Sáenz Peña'), findsOneWidget);
      expect(
        find.textContaining('Los números de puerta no están'),
        findsNothing,
      );
    });
  });

  testWidgets('el destino elegido queda anotado como reciente', (tester) async {
    // El contraste con el origen: acá SÍ se anota.
    final c = container();
    c.read(tripSearchProvider.notifier).startFrom(_gpsPoint);

    await pumpSheet(
      tester,
      c,
      (context) => PlaceSearchSheet.showDestination(context, origin: _gpsPoint),
    );

    await tester.enterText(find.byType(TextField), 'french');
    await tester.pumpAndSettle();
    await tester.tap(find.text('French y Güemes'));
    await tester.pumpAndSettle();

    expect(c.read(tripSearchProvider), isA<TripRoute>());
    expect(
      c.read(recentDestinationsProvider).map((p) => p.name),
      contains('French y Güemes'),
    );
  });
}
