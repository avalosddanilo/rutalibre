import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rutalibre/core/providers/shared_preferences_provider.dart';
import 'package:rutalibre/features/transit/data/models/stop_model.dart';
import 'package:rutalibre/features/transit/data/models/trip_plan_model.dart';
import 'package:rutalibre/features/transit/domain/entities/route_variant.dart';
import 'package:rutalibre/features/transit/presentation/providers/trip_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _casa = (lat: -27.4869, lng: -58.9469);
const _plaza = (lat: -27.4519, lng: -58.9865);
const _campus = (lat: -27.4699, lng: -58.7823);

void main() {
  ProviderContainer container() {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    return c;
  }

  test('startFrom deja el origen puesto y el destino sin elegir', () {
    final c = container();
    c.read(tripSearchProvider.notifier).startFrom(_casa);

    final state = c.read(tripSearchProvider);
    expect(state, isA<TripPickingDestination>());
    expect((state as TripPickingDestination).origin, _casa);
    // Sin nombre: el origen salió del GPS. Ver TripPickingDestination.
    expect(state.originName, isNull);
  });

  test('el nombre del origen viaja hasta el viaje armado', () {
    // Es lo único que permite DECIR de dónde sale el viaje. Sin esto, un
    // viaje planificado desde el sillón se ve idéntico a uno desde el GPS.
    final c = container();
    c.read(tripSearchProvider.notifier).startFrom(_casa, name: 'Mi casa');
    c.read(tripSearchProvider.notifier).setDestination(_campus);

    final state = c.read(tripSearchProvider) as TripRoute;
    expect(state.originName, 'Mi casa');
    expect(state.origin, _casa);
    expect(state.destination, _campus);
  });

  test('setOrigin conserva el destino y recalcula la consulta', () {
    // El caso que esto viene a resolver: el destino ya está elegido y lo que
    // estaba mal era de dónde salías. Perder el destino ahí obligaría a
    // buscarlo de nuevo.
    final c = container();
    final notifier = c.read(tripSearchProvider.notifier);
    notifier.startFrom(_casa);
    notifier.setDestination(_campus);

    notifier.setOrigin(_plaza, name: 'Plaza 25 de Mayo');

    final state = c.read(tripSearchProvider) as TripRoute;
    expect(state.destination, _campus);
    expect(state.origin, _plaza);
    expect(state.originName, 'Plaza 25 de Mayo');
    expect(state.query.originLat, _plaza.lat);
    expect(state.query.destLat, _campus.lat);
  });

  test('setOrigin con el modo apagado lo arranca pidiendo destino', () {
    // Es el camino de "el GPS falló": no hay nada empezado y el origen llega
    // escrito a mano.
    final c = container();
    c.read(tripSearchProvider.notifier).setOrigin(_casa, name: 'Mi casa');

    final state = c.read(tripSearchProvider);
    expect(state, isA<TripPickingDestination>());
    expect((state as TripPickingDestination).originName, 'Mi casa');
  });

  test('startFrom SÍ descarta el destino anterior', () {
    // La diferencia con setOrigin, y la razón de que existan las dos:
    // "¿a dónde vas?" empieza un viaje nuevo.
    final c = container();
    final notifier = c.read(tripSearchProvider.notifier);
    notifier.startFrom(_casa);
    notifier.setDestination(_campus);

    notifier.startFrom(_plaza);

    expect(c.read(tripSearchProvider), isA<TripPickingDestination>());
  });

  test('pickAnotherDestination conserva el origen y su nombre', () {
    final c = container();
    final notifier = c.read(tripSearchProvider.notifier);
    notifier.startFrom(_casa, name: 'Mi casa');
    notifier.setDestination(_campus);

    notifier.pickAnotherDestination();

    final state = c.read(tripSearchProvider) as TripPickingDestination;
    expect(state.origin, _casa);
    expect(state.originName, 'Mi casa');
  });

  group('swap — "¿y para volver?"', () {
    test('da vuelta origen y destino, y la query cambia con ellos', () {
      final c = container();
      final notifier = c.read(tripSearchProvider.notifier);
      notifier.startFrom(_casa);
      notifier.setDestination(_campus);

      notifier.swap();

      final state = c.read(tripSearchProvider) as TripRoute;
      expect(state.origin, _campus);
      expect(state.destination, _casa);
      expect(state.query.originLat, _campus.lat);
      expect(state.query.destLat, _casa.lat);
    });

    test('pierde el nombre del origen a propósito', () {
      // El origen nuevo es el destino viejo, del que solo hay coordenada.
      // Mentirle un nombre sería peor que no tenerlo.
      final c = container();
      final notifier = c.read(tripSearchProvider.notifier);
      notifier.startFrom(_casa, name: 'Mi casa');
      notifier.setDestination(_campus);

      notifier.swap();

      expect((c.read(tripSearchProvider) as TripRoute).originName, isNull);
    });

    test('suelta el viaje elegido: era de la ida', () {
      final c = container();
      final notifier = c.read(tripSearchProvider.notifier);
      notifier.startFrom(_casa);
      notifier.setDestination(_campus);

      notifier.swap();

      expect(c.read(selectedTripProvider), isNull);
    });

    test('sin destino todavía, no hace nada', () {
      final c = container();
      c.read(tripSearchProvider.notifier).startFrom(_casa);

      c.read(tripSearchProvider.notifier).swap();

      expect(c.read(tripSearchProvider), isA<TripPickingDestination>());
    });
  });

  test('con el modo apagado, poner destino no inventa un viaje', () {
    final c = container();
    c.read(tripSearchProvider.notifier).setDestination(_campus);
    expect(c.read(tripSearchProvider), isA<TripIdle>());
  });

  group('el viaje activo sobrevive a cerrar la app', () {
    // El pozo de batería del colectivo: Android mata la app con la guía
    // abierta, y al reabrir el viaje tiene que poder levantarse del teléfono
    // sin volver a consultar a Supabase.
    TripPlanModel plan() => TripPlanModel(
      walkToBoardMeters: 100,
      walkFromAlightMeters: 50,
      legs: [
        TripLegModel(
          lineId: 'l3',
          lineCode: '3',
          lineName: 'Línea 3',
          colorHex: '#F57C00',
          networkCode: 'gran-resistencia',
          networkName: 'Gran Resistencia',
          routeVariantId: 'rv1',
          variantName: 'Ida',
          branch: 'A',
          direction: RouteDirection.outbound,
          boardStop: const StopModel(
            id: 's1',
            name: 'A',
            lat: -27.45,
            lng: -58.98,
          ),
          alightStop: const StopModel(
            id: 's2',
            name: 'B',
            lat: -27.46,
            lng: -58.97,
          ),
          stopCount: 8,
        ),
      ],
    );

    Future<ProviderContainer> storeContainer() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final c = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(c.dispose);
      return c;
    }

    Future<void> startGuidedTrip(ProviderContainer c) async {
      c.read(tripSearchProvider.notifier)
        ..startFrom(_casa, name: 'Mi casa')
        ..setDestination(_campus);
      c.read(selectedTripProvider.notifier).select(plan());
      c.read(tripGuidanceProvider.notifier).start();
      // Los guardados son fire-and-forget: se les da un turno.
      await Future<void>.delayed(Duration.zero);
    }

    test('iniciar la guía CONGELA el viaje: puntas, plan y paso', () async {
      final c = await storeContainer();
      await startGuidedTrip(c);

      final saved = await c.read(activeTripStoreProvider).load();
      expect(saved, isNotNull);
      expect(saved!.stepIndex, 0);
      expect(saved.originName, 'Mi casa');
      expect(saved.destinationLat, _campus.lat);
      expect(saved.plan.legs.single.routeVariantId, 'rv1');
    });

    test('avanzar de paso actualiza el guardado', () async {
      final c = await storeContainer();
      await startGuidedTrip(c);

      c.read(tripGuidanceProvider.notifier).next(5);
      c.read(tripGuidanceProvider.notifier).next(5);
      await Future<void>.delayed(Duration.zero);

      expect((await c.read(activeTripStoreProvider).load())!.stepIndex, 2);
    });

    test('terminar la guía descarta el guardado: ese viaje ya fue', () async {
      final c = await storeContainer();
      await startGuidedTrip(c);

      c.read(tripGuidanceProvider.notifier).stop();
      await Future<void>.delayed(Duration.zero);

      expect(await c.read(activeTripStoreProvider).load(), isNull);
    });

    test('salir del modo "¿cómo llego?" también lo descarta', () async {
      final c = await storeContainer();
      await startGuidedTrip(c);

      c.read(tripSearchProvider.notifier).clear();
      await Future<void>.delayed(Duration.zero);

      expect(await c.read(activeTripStoreProvider).load(), isNull);
    });

    test('restore arma el viaje EN UNA transición, sin pasar por '
        '"eligiendo destino"', () async {
      // El mapa lee la transición "eligiendo → armado" como "la persona
      // acaba de elegir: abrile la hoja de opciones". Retomar no es elegir:
      // si restore pasara por ahí, la hoja —con su consulta a la red, que
      // sin señal es un cartel de error— taparía la guía restaurada.
      final c = await storeContainer();
      final transitions = <TripSearch>[];
      c.listen(tripSearchProvider, (_, next) => transitions.add(next));

      c
          .read(tripSearchProvider.notifier)
          .restore(origin: _casa, destination: _campus, originName: 'Mi casa');

      expect(transitions, hasLength(1));
      final state = transitions.single as TripRoute;
      expect(state.origin, _casa);
      expect(state.destination, _campus);
      expect(state.originName, 'Mi casa');
    });

    test('startAt retoma en el paso guardado, no en el cero', () async {
      final c = await storeContainer();
      c.read(tripSearchProvider.notifier)
        ..startFrom(_casa)
        ..setDestination(_campus);
      c.read(selectedTripProvider.notifier).select(plan());

      c.read(tripGuidanceProvider.notifier).startAt(3);

      expect(c.read(tripGuidanceProvider), 3);
    });
  });

  test('clear apaga el modo', () {
    final c = container();
    final notifier = c.read(tripSearchProvider.notifier);
    notifier.startFrom(_casa);
    notifier.setDestination(_campus);

    notifier.clear();

    expect(c.read(tripSearchProvider), isA<TripIdle>());
    expect(c.read(selectedTripProvider), isNull);
  });
}
