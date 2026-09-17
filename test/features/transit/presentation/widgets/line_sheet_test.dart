import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rutalibre/core/errors/failures.dart';
import 'package:rutalibre/core/providers/clock_provider.dart';
import 'package:rutalibre/core/providers/shared_preferences_provider.dart';
import 'package:rutalibre/features/transit/domain/entities/bus_line.dart';
import 'package:rutalibre/features/transit/domain/entities/route_variant.dart';
import 'package:rutalibre/features/transit/domain/entities/transit_network.dart';
import 'package:rutalibre/features/transit/domain/repositories/transit_repository.dart';
import 'package:rutalibre/features/transit/presentation/providers/transit_providers.dart';
import 'package:rutalibre/features/transit/presentation/utils/display_text.dart';
import 'package:rutalibre/features/transit/presentation/widgets/line_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockRepo extends Mock implements TransitRepository {}

const _granRes = TransitNetwork(
  code: 'gran-resistencia',
  name: 'Gran Resistencia',
);
const _interurbano = TransitNetwork(
  code: 'interurbano-chaco-corrientes',
  name: 'Chaco – Corrientes',
);

const _lines = [
  BusLine(
    id: 'l3',
    code: '3',
    name: 'Vial ↔ Monte Alto',
    colorHex: '#F57C00',
    network: _granRes,
    sortOrder: 3,
  ),
  BusLine(
    id: 'l110',
    code: '110',
    name: 'La Toma ↔ Los Cisnes',
    colorHex: '#D32F2F',
    network: _granRes,
    sortOrder: 110,
  ),
  BusLine(
    id: 'lt',
    code: 'Tirol',
    name: 'Resistencia ↔ Puerto Tirol',
    colorHex: '#0288D1',
    network: _interurbano,
    sortOrder: 9084,
  ),
];

const _variants = [
  RouteVariant(
    id: 'rv1',
    lineId: 'l3',
    name: 'Vial → Monte Alto',
    branch: 'A',
    direction: RouteDirection.outbound,
    isActive: true,
  ),
  RouteVariant(
    id: 'rv2',
    lineId: 'l3',
    name: 'Monte Alto → Vial',
    branch: 'A',
    direction: RouteDirection.inbound,
    isActive: true,
  ),
];

ProviderContainer _container(
  TransitRepository repo,
  SharedPreferences prefs, {
  DateTime? syncedAt,
}) {
  final container = ProviderContainer(
    retry: (retryCount, error) => null,
    overrides: [
      transitRepositoryProvider.overrideWithValue(repo),
      // El panel lee las líneas favoritas para fijarlas arriba, así que ahora
      // necesita las preferencias igual que en la app real.
      sharedPreferencesProvider.overrideWithValue(prefs),
      // De cuándo son los datos guardados. Se sobreescribe el provider y no
      // las prefs para no atar el test al nombre de la clave de la cache.
      lastSyncProvider.overrideWith((ref) async => syncedAt),
      clockProvider.overrideWithValue(() => DateTime(2026, 8, 10, 12)),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

Widget _app(ProviderContainer container, {VoidCallback? onPlanTrip}) =>
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: Scaffold(
          body: Stack(children: [LineSheet(onPlanTrip: onPlanTrip)]),
        ),
      ),
    );

void main() {
  late _MockRepo repo;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    repo = _MockRepo();
    when(() => repo.getLines()).thenAnswer((_) async => const Right(_lines));
    when(
      () => repo.getRouteVariants('l3'),
    ).thenAnswer((_) async => const Right(_variants));
  });

  testWidgets('"¿a dónde vas?" es lo primero del panel y arranca el viaje', (
    tester,
  ) async {
    // La pregunta con la que uno abre la app tiene que estar arriba de todo,
    // no ser un botón flotante más en una columna de cinco.
    var started = 0;
    await tester.pumpWidget(
      _app(_container(repo, prefs), onPlanTrip: () => started++),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('¿A dónde vas?'));
    await tester.pumpAndSettle();
    expect(started, 1);
  });

  testWidgets('sin forma de planificar, el panel no ofrece hacerlo', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_container(repo, prefs)));
    await tester.pumpAndSettle();

    expect(find.text('¿A dónde vas?'), findsNothing);
  });

  testWidgets('lista las líneas agrupadas por red', (tester) async {
    await tester.pumpWidget(_app(_container(repo, prefs)));
    await tester.pumpAndSettle();

    expect(find.text(displayText('Vial ↔ Monte Alto')), findsOneWidget);
    expect(find.text(displayText('La Toma ↔ Los Cisnes')), findsOneWidget);
    expect(find.text('GRAN RESISTENCIA'), findsOneWidget);

    // La red interurbana queda abajo del panel: hay que scrollear.
    await tester.scrollUntilVisible(
      find.text(displayText('CHACO – CORRIENTES')),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text(displayText('CHACO – CORRIENTES')), findsOneWidget);
    expect(
      find.text(displayText('Resistencia ↔ Puerto Tirol')),
      findsOneWidget,
    );
  });

  testWidgets('con la letra al 200% el nombre de la red no se parte letra por '
      'letra', (tester) async {
    // El hallazgo de campo, en el teléfono de una persona que agranda la
    // letra para poder leer: el precio con su fecha ocupaba el renglón y el
    // nombre quedaba en tres letras de ancho — "GRA / N RE / SIST / ENC / IA".
    tester.view
      ..physicalSize = const Size(360 * 3, 800 * 3)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: _container(repo, prefs),
        child: MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: const Scaffold(body: Stack(children: [LineSheet()])),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final name = find.text('GRAN RESISTENCIA');
    expect(name, findsOneWidget);
    // El nombre tiene el renglón entero para él, y a lo sumo se parte por
    // PALABRA ("GRAN / RESISTENCIA": dos renglones de 32 px). Con el bug
    // medía 480 px de alto: quince renglones de tres letras.
    final size = tester.getSize(name);
    expect(size.width, greaterThan(200));
    expect(size.height, lessThanOrEqualTo(64));
  });

  testWidgets('el buscador filtra por número de línea', (tester) async {
    await tester.pumpWidget(_app(_container(repo, prefs)));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '110');
    await tester.pumpAndSettle();

    expect(find.text(displayText('La Toma ↔ Los Cisnes')), findsOneWidget);
    expect(find.text(displayText('Vial ↔ Monte Alto')), findsNothing);
  });

  testWidgets('el buscador ignora tildes al filtrar por nombre', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_container(repo, prefs)));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'tirol');
    await tester.pumpAndSettle();

    expect(
      find.text(displayText('Resistencia ↔ Puerto Tirol')),
      findsOneWidget,
    );
    expect(find.text(displayText('Vial ↔ Monte Alto')), findsNothing);
  });

  testWidgets('sin coincidencias avisa en vez de mostrar una lista vacía', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_container(repo, prefs)));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'zzzz');
    await tester.pumpAndSettle();

    expect(
      find.text('Ninguna línea coincide con la búsqueda.'),
      findsOneWidget,
    );
  });

  testWidgets('elegir una línea muestra sus recorridos', (tester) async {
    final container = _container(repo, prefs);
    await tester.pumpWidget(_app(container));
    await tester.pumpAndSettle();

    await tester.tap(find.text(displayText('Vial ↔ Monte Alto')));
    await tester.pumpAndSettle();

    expect(find.text('Ramal A · Ida'), findsOneWidget);
    expect(find.text('Ramal A · Vuelta'), findsOneWidget);
    expect(container.read(selectedLineProvider)?.code, '3');
  });

  testWidgets('el error de líneas ofrece Reintentar y se recupera', (
    tester,
  ) async {
    var calls = 0;
    when(() => repo.getLines()).thenAnswer((_) async {
      calls++;
      return calls == 1 ? const Left(NetworkFailure()) : const Right(_lines);
    });

    await tester.pumpWidget(_app(_container(repo, prefs)));
    await tester.pumpAndSettle();

    expect(find.textContaining('Sin conexión'), findsOneWidget);

    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(find.text(displayText('Vial ↔ Monte Alto')), findsOneWidget);
  });

  group('de cuándo son los datos', () {
    /// El pie está al final de la lista: hay que scrollear para verlo, igual
    /// que en la app.
    Future<void> scrollToFooter(WidgetTester tester) =>
        tester.scrollUntilVisible(
          find.textContaining('Datos guardados en el teléfono'),
          120,
          scrollable: find.byType(Scrollable).first,
        );

    testWidgets('lo de hoy se dice "hoy", que no obliga a hacer la cuenta', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(_container(repo, prefs, syncedAt: DateTime(2026, 8, 10, 7))),
      );
      await tester.pumpAndSettle();
      await scrollToFooter(tester);

      expect(find.text('Datos guardados en el teléfono · hoy'), findsOneWidget);
    });

    testWidgets('más atrás gana la fecha', (tester) async {
      await tester.pumpWidget(
        _app(_container(repo, prefs, syncedAt: DateTime(2026, 7, 28, 7))),
      );
      await tester.pumpAndSettle();
      await scrollToFooter(tester);

      expect(
        find.text('Datos guardados en el teléfono · 28/7/2026'),
        findsOneWidget,
      );
    });

    testWidgets('sin marca no dice nada: es el primer arranque', (
      tester,
    ) async {
      // Los datos vienen de la red y todavía no se guardó nada. Inventar una
      // fecha ahí sería peor que no decir nada.
      await tester.pumpWidget(_app(_container(repo, prefs)));
      await tester.pumpAndSettle();

      expect(find.textContaining('Datos guardados'), findsNothing);
    });
  });
}
