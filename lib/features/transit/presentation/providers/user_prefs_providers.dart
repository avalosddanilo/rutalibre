import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/providers/shared_preferences_provider.dart';
import '../../domain/entities/stop.dart';

/// Un lugar guardado: una parada que el usuario marcó o a la que ya fue.
///
/// **Se guarda una COPIA, no un id.** Podría guardarse solo el `stop_id` y
/// resolverlo contra la copia local de paradas, pero entonces un favorito
/// dejaría de existir cada vez que una parada se da de baja en un reimport —
/// y las paradas se dan de baja seguido (ver la sección 5 del seed). Una
/// copia congelada envejece; un id roto desaparece sin explicación.
typedef SavedPlace = ({String id, String name, double lat, double lng});

SavedPlace savedPlaceOf(Stop stop) =>
    (id: stop.id, name: stop.name, lat: stop.lat, lng: stop.lng);

/// Lo que el usuario marcó y por dónde anduvo, en el teléfono.
///
/// **No pasa por el dominio ni por un repositorio.** Es la misma categoría
/// que la geolocalización: estado del DISPOSITIVO y del usuario, sin ninguna
/// regla de transporte adentro. Meterlo en `domain/` obligaría a inventar
/// usecases que no deciden nada.
///
/// **Nada de esto sale del teléfono.** No hay cuenta, no hay servidor, no se
/// sincroniza. Se borra desinstalando la app.
class UserPrefsStore {
  const UserPrefsStore(this._prefs);

  final SharedPreferences _prefs;

  /// Las claves llevan versión por lo mismo que la cache: si cambia la forma
  /// de lo guardado, se sube el número en vez de romperle los favoritos a
  /// quien actualiza.
  static const _favoriteLinesKey = 'ruta_libre_fav_lines_v1';
  static const _favoriteStopsKey = 'ruta_libre_fav_stops_v1';
  static const _recentDestinationsKey = 'ruta_libre_recent_dest_v1';

  /// Cuántos destinos recientes se recuerdan.
  ///
  /// Ocho y no cincuenta: esto existe para que el que va siempre al mismo
  /// lado no tenga que escribir, no para llevarle un historial. Una lista
  /// larga se vuelve otra cosa para buscar dentro, que es exactamente el
  /// problema que venía a resolver.
  static const maxRecents = 8;

  // -------------------------------------------------------------------------
  // Líneas favoritas
  // -------------------------------------------------------------------------

  /// La clave de una línea favorita.
  ///
  /// Lleva la red adentro **porque el código de línea es único POR RED, no
  /// globalmente**: sin esto, marcar la 3 del Gran Resistencia marcaría
  /// también la 3 de Corrientes capital.
  static String lineKey({
    required String networkCode,
    required String lineCode,
  }) => '$networkCode/$lineCode';

  Set<String> favoriteLines() =>
      _prefs.getStringList(_favoriteLinesKey)?.toSet() ?? {};

  Future<void> saveFavoriteLines(Set<String> keys) =>
      _prefs.setStringList(_favoriteLinesKey, keys.toList());

  // -------------------------------------------------------------------------
  // Paradas favoritas y destinos recientes
  // -------------------------------------------------------------------------

  List<SavedPlace> favoriteStops() => _readPlaces(_favoriteStopsKey);

  Future<void> saveFavoriteStops(List<SavedPlace> places) =>
      _writePlaces(_favoriteStopsKey, places);

  List<SavedPlace> recentDestinations() => _readPlaces(_recentDestinationsKey);

  Future<void> saveRecentDestinations(List<SavedPlace> places) =>
      _writePlaces(_recentDestinationsKey, places);

  List<SavedPlace> _readPlaces(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return const [];
    try {
      return [
        for (final item in jsonDecode(raw) as List<dynamic>)
          if (item case {
            'id': final String id,
            'name': final String name,
            'lat': final num lat,
            'lng': final num lng,
          })
            (id: id, name: name, lat: lat.toDouble(), lng: lng.toDouble()),
      ];
    } catch (_) {
      // Guardado corrupto o de una versión vieja: se empieza de cero. Perder
      // los favoritos es feo, pero mucho menos que no abrir.
      return const [];
    }
  }

  Future<void> _writePlaces(String key, List<SavedPlace> places) =>
      _prefs.setString(
        key,
        jsonEncode([
          for (final p in places)
            {'id': p.id, 'name': p.name, 'lat': p.lat, 'lng': p.lng},
        ]),
      );
}

final userPrefsStoreProvider = Provider<UserPrefsStore>(
  (ref) => UserPrefsStore(ref.watch(sharedPreferencesProvider)),
);

/// Las líneas marcadas como favoritas, por clave `red/línea`.
class FavoriteLinesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => ref.watch(userPrefsStoreProvider).favoriteLines();

  bool contains({required String networkCode, required String lineCode}) =>
      state.contains(
        UserPrefsStore.lineKey(networkCode: networkCode, lineCode: lineCode),
      );

  Future<void> toggle({
    required String networkCode,
    required String lineCode,
  }) async {
    final key = UserPrefsStore.lineKey(
      networkCode: networkCode,
      lineCode: lineCode,
    );
    final next = {...state};
    if (!next.remove(key)) next.add(key);
    // El estado se actualiza ANTES de escribir: la estrellita tiene que
    // responder en el mismo cuadro que el toque. Si el disco falla, lo peor
    // que pasa es que el favorito no sobreviva a cerrar la app.
    state = next;
    await ref.read(userPrefsStoreProvider).saveFavoriteLines(next);
  }
}

final favoriteLinesProvider =
    NotifierProvider<FavoriteLinesNotifier, Set<String>>(
      FavoriteLinesNotifier.new,
    );

/// Las paradas marcadas como favoritas, de la más nueva a la más vieja.
class FavoriteStopsNotifier extends Notifier<List<SavedPlace>> {
  @override
  List<SavedPlace> build() => ref.watch(userPrefsStoreProvider).favoriteStops();

  bool contains(String stopId) => state.any((p) => p.id == stopId);

  Future<void> toggle(Stop stop) async {
    final next = [...state];
    final index = next.indexWhere((p) => p.id == stop.id);
    if (index >= 0) {
      next.removeAt(index);
    } else {
      next.insert(0, savedPlaceOf(stop));
    }
    state = next;
    await ref.read(userPrefsStoreProvider).saveFavoriteStops(next);
  }
}

final favoriteStopsProvider =
    NotifierProvider<FavoriteStopsNotifier, List<SavedPlace>>(
      FavoriteStopsNotifier.new,
    );

/// Los últimos destinos elegidos en "¿cómo llego?".
class RecentDestinationsNotifier extends Notifier<List<SavedPlace>> {
  @override
  List<SavedPlace> build() =>
      ref.watch(userPrefsStoreProvider).recentDestinations();

  /// Anota un destino. Si ya estaba, **sube al principio en vez de
  /// duplicarse**: el lugar al que uno vuelve es justamente el que tiene que
  /// quedar arriba, y una lista con el mismo destino tres veces es una lista
  /// inútil.
  ///
  /// Toma un [SavedPlace] y no un `Stop` porque un destino también puede ser
  /// un LUGAR —el hospital, el shopping—, que no tiene id de parada.
  Future<void> record(SavedPlace place) async {
    final next = [place, ...state.where((p) => p.id != place.id)];
    if (next.length > UserPrefsStore.maxRecents) {
      next.removeRange(UserPrefsStore.maxRecents, next.length);
    }
    state = next;
    await ref.read(userPrefsStoreProvider).saveRecentDestinations(next);
  }

  Future<void> clear() async {
    state = const [];
    await ref.read(userPrefsStoreProvider).saveRecentDestinations(const []);
  }
}

final recentDestinationsProvider =
    NotifierProvider<RecentDestinationsNotifier, List<SavedPlace>>(
      RecentDestinationsNotifier.new,
    );
