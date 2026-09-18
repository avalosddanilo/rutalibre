import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rutalibre/core/providers/shared_preferences_provider.dart';
import 'package:rutalibre/features/transit/domain/entities/place.dart';
import 'package:rutalibre/features/transit/domain/entities/stop.dart';
import 'package:rutalibre/features/transit/domain/entities/street_addresses.dart';
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

  ProviderContainer container({
    List<Place> places = const [],
    List<StreetAddresses> addresses = const [],
  }) {
    final c = ProviderContainer(
      overrides: [
        allStopsProvider.overrideWith((ref) async => _stops),
        placesProvider.overrideWith((ref) async => places),
        // Siempre sobreescrito: sin esto, los tests de "calle + número"
        // leerían el asset REAL de alturas y quedarían atados a lo que OSM
        // tenga mapeado el día de la regeneración.
        addressesProvider.overrideWith((ref) async => addresses),
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
      // …y el cartel aclara que ese número no está: mostrar esquinas como
      // si fueran la dirección exacta sería dejar creer que una de esas ES.
      expect(find.textContaining('no está mapeado'), findsOneWidget);
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
      expect(find.textContaining('no está mapeado'), findsNothing);
    });
  });

  group('alturas mapeadas', () {
    // El caso que motivó todo esto: una casa con altura, en una calle que se
    // repite en dos localidades. El área tiene ~58.000 números de puerta en
    // OSM, así que la altura puede caer en la cuadra REAL — y donde el número
    // justo no está, se ofrece el mapeado más cercano y SE DICE.
    const sanJuan = StreetAddresses(
      street: 'San Juan',
      locality: 'Barranqueras',
      numbers: [
        AddressPoint(number: 5200, lat: -27.47643, lng: -58.92416),
        AddressPoint(number: 5249, lat: -27.47692, lng: -58.92359),
      ],
    );

    testWidgets('el número exacto aparece como dirección, sin carteles', (
      tester,
    ) async {
      final c = container(addresses: const [sanJuan]);
      c.read(tripSearchProvider.notifier).startFrom(_gpsPoint);
      await pumpSheet(
        tester,
        c,
        (context) =>
            PlaceSearchSheet.showDestination(context, origin: _gpsPoint),
      );

      await tester.enterText(find.byType(TextField), 'san juan 5200');
      await tester.pumpAndSettle();

      expect(find.text('San Juan 5200 (Barranqueras)'), findsOneWidget);
      expect(find.textContaining('Dirección'), findsWidgets);
      // Exacto = sin aviso: no hay nada que aclarar.
      expect(find.textContaining('no está mapeado'), findsNothing);
    });

    testWidgets('sin el exacto: el vecino mapeado, con SU número y el aviso', (
      tester,
    ) async {
      final c = container(addresses: const [sanJuan]);
      c.read(tripSearchProvider.notifier).startFrom(_gpsPoint);
      await pumpSheet(
        tester,
        c,
        (context) =>
            PlaceSearchSheet.showDestination(context, origin: _gpsPoint),
      );

      await tester.enterText(find.byType(TextField), 'san juan 5240');
      await tester.pumpAndSettle();

      // El 5249 con su número real — nunca disfrazado de 5240 — y el cartel
      // que dice qué se está mostrando.
      expect(find.text('San Juan 5249 (Barranqueras)'), findsOneWidget);
      expect(find.textContaining('El 5240 justo no está'), findsOneWidget);
    });

    testWidgets('elegir la dirección fija el destino y queda de reciente', (
      tester,
    ) async {
      // A diferencia de la CALLE (que manda al mapa a marcar), la dirección
      // ES un punto: se elige y el viaje se planifica. Y queda anotada — la
      // casa de uno es el reciente más reciente que existe.
      final c = container(addresses: const [sanJuan]);
      c.read(tripSearchProvider.notifier).startFrom(_gpsPoint);
      await pumpSheet(
        tester,
        c,
        (context) =>
            PlaceSearchSheet.showDestination(context, origin: _gpsPoint),
      );

      await tester.enterText(find.byType(TextField), 'san juan 5200');
      await tester.pumpAndSettle();
      await tester.tap(find.text('San Juan 5200 (Barranqueras)'));
      await tester.pumpAndSettle();

      final state = c.read(tripSearchProvider);
      expect(state, isA<TripRoute>());
      expect((state as TripRoute).destination, (
        lat: -27.47643,
        lng: -58.92416,
      ));
      expect(
        c.read(recentDestinationsProvider).map((p) => p.name),
        contains('San Juan 5200 (Barranqueras)'),
      );
    });
  });

  group('calles', () {
    // La calle de una casa real que el buscador no encontraba: en
    // Barranqueras ninguna ESQUINA se llama San Juan, así que las paradas no
    // alcanzaban. Las calles entran como entradas propias del asset.
    const street = Place(
      name: 'San Juan (Barranqueras)',
      lat: -27.47276,
      lng: -58.92749,
      kind: PlaceKind.calle,
    );

    testWidgets('como destino NO fija nada: devuelve el punto para que el '
        'mapa vuele ahí', (tester) async {
      final c = container(places: const [street]);
      c.read(tripSearchProvider.notifier).startFrom(_gpsPoint);

      MapPoint? focus;
      await pumpSheet(tester, c, (context) {
        PlaceSearchSheet.showDestination(
          context,
          origin: _gpsPoint,
        ).then((value) => focus = value);
      });

      // Con número de puerta y todo: el recorte lo saca y la calle aparece.
      await tester.enterText(find.byType(TextField), 'san juan 5240');
      await tester.pumpAndSettle();
      expect(find.text('San Juan (Barranqueras)'), findsOneWidget);
      // El renglón dice que es una calle, no un lugar puntual.
      expect(find.textContaining('Calle'), findsWidgets);

      await tester.tap(find.text('San Juan (Barranqueras)'));
      await tester.pumpAndSettle();

      // La hoja devolvió el punto de la calle…
      expect(focus, (lat: street.lat, lng: street.lng));
      // …pero el destino NO se fijó: una calle entera no es un punto, y
      // fijarlo en su mitad planificaría un viaje a cuadras de la casa. El
      // modo "tocá el mapa" sigue activo para marcar el lugar exacto.
      expect(c.read(tripSearchProvider), isA<TripPickingDestination>());
      // Tampoco es un "último destino": el destino real será el toque.
      expect(c.read(recentDestinationsProvider), isEmpty);
    });

    testWidgets('como origen se toma directo, con su nombre', (tester) async {
      // Para el origen alcanza: el planificador arranca desde las paradas
      // CERCANAS al punto, y "Cambiar" queda a un toque.
      final c = container(places: const [street]);
      await pumpSheet(
        tester,
        c,
        (context) => PlaceSearchSheet.showOrigin(context),
      );

      await tester.enterText(find.byType(TextField), 'san juan');
      await tester.pumpAndSettle();
      await tester.tap(find.text('San Juan (Barranqueras)'));
      await tester.pumpAndSettle();

      final state = c.read(tripSearchProvider);
      expect(state, isA<TripPickingDestination>());
      expect(
        (state as TripPickingDestination).originName,
        'San Juan (Barranqueras)',
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
