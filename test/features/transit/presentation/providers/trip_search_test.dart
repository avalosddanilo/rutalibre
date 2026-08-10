import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rutalibre/features/transit/presentation/providers/trip_providers.dart';

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

  test('con el modo apagado, poner destino no inventa un viaje', () {
    final c = container();
    c.read(tripSearchProvider.notifier).setDestination(_campus);
    expect(c.read(tripSearchProvider), isA<TripIdle>());
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
