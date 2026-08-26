import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/clock_provider.dart';
import '../../../../core/providers/shared_preferences_provider.dart';
import '../../data/datasources/active_trip_store.dart';
import '../../domain/entities/trip_plan.dart';
import '../../domain/usecases/plan_trip.dart';
import 'transit_providers.dart';

/// Un punto del mapa. Record y no `LatLng` para que el estado del modo no
/// dependa del paquete de mapas (misma razón que `Stop.lat/lng`), y porque
/// los records tienen == estructural: sirven de argumento de family.
typedef MapPoint = ({double lat, double lng});

// ---------------------------------------------------------------------------
// Estado del modo "¿cómo llego?"
//
// Sealed y no un puñado de nullables: los tres estados tienen datos
// distintos, y "destino sin origen" no existe. Con nullables sueltos esa
// combinación imposible habría que chequearla en cada pantalla.
// ---------------------------------------------------------------------------

sealed class TripSearch {
  const TripSearch();
}

/// El modo está apagado.
final class TripIdle extends TripSearch {
  const TripIdle();
}

/// Ya sabemos de dónde salís; falta que digas a dónde vas.
final class TripPickingDestination extends TripSearch {
  const TripPickingDestination(this.origin, {this.originName});

  final MapPoint origin;

  /// Cómo se llama el origen, para poder DECIRLO: "Desde: Hospital Perrando".
  ///
  /// Null significa "mi ubicación": el GPS no devuelve un nombre, y ponerle
  /// uno lo haría parecer un lugar que la persona eligió.
  final String? originName;
}

/// Origen y destino puestos: hay viaje que buscar.
final class TripRoute extends TripSearch {
  const TripRoute({
    required this.origin,
    required this.destination,
    this.originName,
  });

  final MapPoint origin;
  final MapPoint destination;

  /// Ver [TripPickingDestination.originName].
  final String? originName;

  /// Argumento de `tripPlansProvider`. Se arma acá para que la pantalla no
  /// tenga que desarmar el estado a mano en cada uso.
  TripQuery get query => (
    originLat: origin.lat,
    originLng: origin.lng,
    destLat: destination.lat,
    destLng: destination.lng,
  );
}

final tripSearchProvider = NotifierProvider<TripSearchNotifier, TripSearch>(
  TripSearchNotifier.new,
);

final class TripSearchNotifier extends Notifier<TripSearch> {
  @override
  TripSearch build() => const TripIdle();

  /// Arranca el modo DE CERO: hay origen y no hay destino.
  ///
  /// Distinto de [setOrigin], que cambia de dónde salís conservando a dónde
  /// vas: esto empieza un viaje nuevo y descarta el destino anterior.
  void startFrom(MapPoint origin, {String? name}) =>
      state = TripPickingDestination(origin, originName: name);

  /// Cambia el origen conservando el destino, si ya había uno.
  ///
  /// Existe porque el origen NO siempre es el GPS: se puede planificar un
  /// viaje desde el sillón, o desde un teléfono al que se le negó el permiso
  /// de ubicación. Con el destino ya puesto, cambiar el origen recalcula el
  /// viaje —la query del provider cambia— sin hacer empezar de nuevo.
  void setOrigin(MapPoint origin, {String? name}) {
    state = switch (state) {
      TripIdle() || TripPickingDestination() => TripPickingDestination(
        origin,
        originName: name,
      ),
      TripRoute(:final destination) => TripRoute(
        origin: origin,
        destination: destination,
        originName: name,
      ),
    };
  }

  /// Pone el destino. Sin origen no hace nada: tocar el mapa con el modo
  /// apagado no puede inventar un viaje.
  void setDestination(MapPoint destination) {
    final origin = _origin;
    if (origin == null) return;
    state = TripRoute(
      origin: origin.point,
      destination: destination,
      originName: origin.name,
    );
  }

  /// Da vuelta el viaje: el destino pasa a ser el origen y viceversa.
  ///
  /// Es la pregunta que sigue a cualquier viaje: "¿y para volver?". Sin esto
  /// había que salir del modo, esperar el GPS o buscar el origen a mano, y
  /// volver a elegir el destino — para pedir EXACTAMENTE el viaje inverso.
  ///
  /// El nombre del origen se pierde a propósito: el origen nuevo es el
  /// destino viejo, del que solo tenemos la coordenada. Mentirle un nombre
  /// sería peor que no tenerlo.
  void swap() {
    if (state case TripRoute(:final origin, :final destination)) {
      state = TripRoute(origin: destination, destination: origin);
      // El viaje que estaba elegido era de la IDA: dejarlo dibujado sobre la
      // lista de la vuelta mezclaría los dos viajes en el mapa.
      ref.read(selectedTripProvider.notifier).select(null);
    }
  }

  /// Vuelve a pedir destino conservando el origen — para "elegir otro
  /// destino" sin tener que volver a esperar el GPS.
  void pickAnotherDestination() {
    final origin = _origin;
    if (origin == null) return;
    state = TripPickingDestination(origin.point, originName: origin.name);
  }

  /// El origen vigente, o null con el modo apagado.
  ({MapPoint point, String? name})? get _origin => switch (state) {
    TripIdle() => null,
    TripPickingDestination(:final origin, :final originName) => (
      point: origin,
      name: originName,
    ),
    TripRoute(:final origin, :final originName) => (
      point: origin,
      name: originName,
    ),
  };

  void clear() {
    state = const TripIdle();
    ref.read(selectedTripProvider.notifier).select(null);
  }
}

/// Argumentos de la consulta. Record por el == estructural del family.
typedef TripQuery = ({
  double originLat,
  double originLng,
  double destLat,
  double destLng,
});

/// Los viajes posibles entre dos puntos, del mejor al peor.
///
/// `autoDispose`, como `nearbyStopsProvider` y por lo mismo: la respuesta
/// depende de dos puntos arbitrarios, así que cachearla en memoria acumula
/// una entrada por cada destino que el usuario toque y no acierta nunca dos
/// veces. Los watch de la pantalla lo mantienen vivo mientras hace falta.
final tripPlansProvider = FutureProvider.autoDispose
    .family<List<TripPlan>, TripQuery>((ref, query) async {
      final result = await ref.watch(planTripProvider)(
        PlanTripParams(
          originLat: query.originLat,
          originLng: query.originLng,
          destLat: query.destLat,
          destLng: query.destLng,
        ),
      );
      return result.fold((failure) => throw failure, (plans) => plans);
    });

/// El viaje que se está mirando en el mapa, o null.
final selectedTripProvider = NotifierProvider<SelectedTripNotifier, TripPlan?>(
  SelectedTripNotifier.new,
);

final class SelectedTripNotifier extends Notifier<TripPlan?> {
  @override
  TripPlan? build() => null;

  /// Elegir un viaje apaga la selección de línea: si no, el mapa dibuja el
  /// trazado del panel Y el del viaje, y no se entiende cuál es cuál.
  void select(TripPlan? plan) {
    state = plan;
    if (plan != null) {
      ref.read(selectedLineProvider.notifier).select(null);
    }
  }
}

/// En qué paso del viaje está el usuario, o null si todavía no arrancó.
///
/// Null y no `-1`: "no empezó" y "está en el paso cero" son estados
/// distintos, y el mapa dibuja cosas distintas en cada uno.
final activeTripStoreProvider = Provider<ActiveTripStore>(
  (ref) => ActiveTripStore(
    ref.watch(sharedPreferencesProvider),
    now: ref.watch(clockProvider),
  ),
);

/// El viaje que quedó a medio hacer la última vez que la app se cerró.
///
/// Se lee UNA vez al arrancar. Null es lo normal: no había viaje, venció
/// (más de tres horas) o no se pudo leer. El mapa lo usa para ofrecer
/// retomarlo — ofrecer, no retomarlo solo: la app no puede saber si el
/// viaje sigue pasando o si te bajaste hace una hora.
final savedTripProvider = FutureProvider<ActiveTrip?>(
  (ref) => ref.watch(activeTripStoreProvider).load(),
);

final tripGuidanceProvider = NotifierProvider<TripGuidanceNotifier, int?>(
  TripGuidanceNotifier.new,
);

final class TripGuidanceNotifier extends Notifier<int?> {
  @override
  int? build() {
    // Cambiar de viaje —o salir del modo "¿cómo llego?"— corta la guía. Si
    // no, se seguiría el paso 3 de un viaje que ya no está dibujado. Y un
    // viaje que se corta deja de estar "activo": el guardado se limpia para
    // que al reabrir la app no se ofrezca retomar algo que se abandonó.
    ref.listen(selectedTripProvider, (_, _) {
      if (state != null) _discard();
      state = null;
    });
    ref.listen(tripSearchProvider, (_, next) {
      if (next is! TripRoute) {
        if (state != null) _discard();
        state = null;
      }
    });
    return null;
  }

  void start() {
    state = 0;
    _persist();
  }

  /// Arranca en un paso puntual: el camino de RETOMAR un viaje guardado.
  void startAt(int stepIndex) {
    state = stepIndex < 0 ? 0 : stepIndex;
    _persist();
  }

  void stop() {
    state = null;
    _discard();
  }

  /// Avanza sin pasarse del último paso. El tope lo pone quien llama, que es
  /// el único que sabe cuántos pasos tiene ESTE viaje.
  void next(int stepCount) {
    final current = state;
    if (current == null) return;
    if (current + 1 < stepCount) {
      state = current + 1;
      _saveStep();
    }
  }

  void previous() {
    final current = state;
    if (current != null && current > 0) {
      state = current - 1;
      _saveStep();
    }
  }

  /// Congela el viaje entero en el teléfono, para que sobreviva a que
  /// Android mate la app o se acabe la batería a mitad de camino.
  ///
  /// Sin await y tragándose los errores, los tres: es una red de seguridad,
  /// y una red de seguridad que puede hacer caer la guía por un disco lleno
  /// no es una red de seguridad.
  void _persist() {
    final plan = ref.read(selectedTripProvider);
    final search = ref.read(tripSearchProvider);
    final step = state;
    if (plan == null || search is! TripRoute || step == null) return;
    ref
        .read(activeTripStoreProvider)
        .save(
          ActiveTrip(
            plan: plan,
            originLat: search.origin.lat,
            originLng: search.origin.lng,
            destinationLat: search.destination.lat,
            destinationLng: search.destination.lng,
            originName: search.originName,
            stepIndex: step,
          ),
        )
        .catchError((_) {});
  }

  void _saveStep() {
    final step = state;
    if (step == null) return;
    ref.read(activeTripStoreProvider).saveStep(step).catchError((_) {});
  }

  void _discard() {
    ref.read(activeTripStoreProvider).clear().catchError((_) {});
    // Sin esto, el provider del viaje guardado retendría el valor viejo y el
    // cartel de "retomar" aparecería justo al TERMINAR un viaje.
    ref.invalidate(savedTripProvider);
  }
}
