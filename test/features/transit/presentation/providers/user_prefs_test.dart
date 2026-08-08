import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rutalibre/core/providers/shared_preferences_provider.dart';
import 'package:rutalibre/features/transit/domain/entities/stop.dart';
import 'package:rutalibre/features/transit/presentation/providers/user_prefs_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

Stop _stop(String id, [String? name]) =>
    Stop(id: id, name: name ?? 'Parada $id', lat: -27.45, lng: -58.98);

void main() {
  late SharedPreferences prefs;

  ProviderContainer container() {
    final c = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(c.dispose);
    return c;
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  group('líneas favoritas', () {
    test('marcar y desmarcar', () async {
      final c = container();
      final notifier = c.read(favoriteLinesProvider.notifier);

      expect(c.read(favoriteLinesProvider), isEmpty);

      await notifier.toggle(networkCode: 'gran-resistencia', lineCode: '3');
      expect(
        notifier.contains(networkCode: 'gran-resistencia', lineCode: '3'),
        isTrue,
      );

      await notifier.toggle(networkCode: 'gran-resistencia', lineCode: '3');
      expect(c.read(favoriteLinesProvider), isEmpty);
    });

    test('la clave lleva la RED: la 3 de una red no marca la 3 de otra', () {
      // El código de línea es único por red, no globalmente. Sin esto,
      // marcar la 3 del Gran Resistencia marcaba la 3 de Corrientes.
      expect(
        UserPrefsStore.lineKey(networkCode: 'gran-resistencia', lineCode: '3'),
        isNot(
          UserPrefsStore.lineKey(
            networkCode: 'corrientes-capital',
            lineCode: '3',
          ),
        ),
      );
    });

    test('sobreviven a cerrar la app', () async {
      await container()
          .read(favoriteLinesProvider.notifier)
          .toggle(networkCode: 'gran-resistencia', lineCode: '110');

      // Contenedor nuevo = la app abriéndose de nuevo con las mismas prefs.
      expect(
        container().read(favoriteLinesProvider),
        contains('gran-resistencia/110'),
      );
    });
  });

  group('paradas favoritas', () {
    test('marcar, desmarcar y persistir', () async {
      final c = container();
      final notifier = c.read(favoriteStopsProvider.notifier);

      await notifier.toggle(_stop('a', 'Ameghino y French'));
      expect(notifier.contains('a'), isTrue);
      expect(c.read(favoriteStopsProvider).single.name, 'Ameghino y French');

      expect(
        container().read(favoriteStopsProvider).single.id,
        'a',
        reason: 'tiene que sobrevivir a cerrar la app',
      );

      await notifier.toggle(_stop('a'));
      expect(c.read(favoriteStopsProvider), isEmpty);
    });

    test('la más nueva queda primera', () async {
      final notifier = container().read(favoriteStopsProvider.notifier);
      await notifier.toggle(_stop('a'));
      await notifier.toggle(_stop('b'));
      expect(container().read(favoriteStopsProvider).map((p) => p.id), [
        'b',
        'a',
      ]);
    });
  });

  group('destinos recientes', () {
    test('el último queda primero', () async {
      final notifier = container().read(recentDestinationsProvider.notifier);
      await notifier.record(savedPlaceOf(_stop('a')));
      await notifier.record(savedPlaceOf(_stop('b')));
      expect(container().read(recentDestinationsProvider).map((p) => p.id), [
        'b',
        'a',
      ]);
    });

    test('repetir un destino lo SUBE, no lo duplica', () async {
      // Una lista con el mismo destino tres veces es una lista inútil.
      final notifier = container().read(recentDestinationsProvider.notifier);
      await notifier.record(savedPlaceOf(_stop('a')));
      await notifier.record(savedPlaceOf(_stop('b')));
      await notifier.record(savedPlaceOf(_stop('a')));

      expect(container().read(recentDestinationsProvider).map((p) => p.id), [
        'a',
        'b',
      ]);
    });

    test('se recuerdan como máximo ${UserPrefsStore.maxRecents}', () async {
      final notifier = container().read(recentDestinationsProvider.notifier);
      for (var i = 0; i < UserPrefsStore.maxRecents + 5; i++) {
        await notifier.record(savedPlaceOf(_stop('parada-$i')));
      }

      final recents = container().read(recentDestinationsProvider);
      expect(recents, hasLength(UserPrefsStore.maxRecents));
      // Se conservan los ÚLTIMOS, no los primeros.
      expect(recents.first.id, 'parada-${UserPrefsStore.maxRecents + 4}');
    });

    test('borrar los deja vacíos, también en disco', () async {
      final notifier = container().read(recentDestinationsProvider.notifier);
      await notifier.record(savedPlaceOf(_stop('a')));
      await notifier.clear();

      expect(container().read(recentDestinationsProvider), isEmpty);
    });
  });

  group('guardado corrupto', () {
    test('NO revienta: se empieza de cero', () async {
      // Perder los favoritos es feo; no abrir la app es peor.
      await prefs.setString('ruta_libre_fav_stops_v1', 'esto no es json');
      await prefs.setString('ruta_libre_recent_dest_v1', '[{"roto":true}]');

      expect(container().read(favoriteStopsProvider), isEmpty);
      expect(container().read(recentDestinationsProvider), isEmpty);
    });
  });
}
