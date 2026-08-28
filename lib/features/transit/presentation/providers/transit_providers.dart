import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/providers/clock_provider.dart';
import '../../../../core/providers/shared_preferences_provider.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/datasources/corrientes_stops_datasource.dart';
import '../../data/datasources/places_asset_datasource.dart';
import '../../data/datasources/transit_local_datasource.dart';
import '../../data/datasources/transit_remote_datasource.dart';
import '../../data/repositories/places_repository_impl.dart';
import '../../data/repositories/transit_repository_impl.dart';
import '../../domain/entities/bus_line.dart';
import '../../domain/entities/nearby_stop.dart';
import '../../domain/entities/place.dart';
import '../../domain/entities/street_addresses.dart';
import '../../domain/entities/reference_stop.dart';
import '../../domain/entities/route_at_stop.dart';
import '../../domain/entities/route_variant.dart';
import '../../domain/entities/schedule.dart';
import '../../domain/entities/stop.dart';
import '../../domain/repositories/places_repository.dart';
import '../../domain/repositories/transit_repository.dart';
import '../../domain/usecases/get_all_stops.dart';
import '../../domain/usecases/get_lines.dart';
import '../../domain/usecases/get_nearby_stops.dart';
import '../../domain/usecases/get_route_variants.dart';
import '../../domain/usecases/get_routes_for_stop.dart';
import '../../domain/usecases/get_schedules.dart';
import '../../domain/usecases/get_stops_for_route.dart';
import '../../domain/usecases/plan_trip.dart';

/// Composition root del feature transit: acá (y SOLO acá) presentation
/// conoce la capa data para cablear las implementaciones concretas.
///
/// Sin codegen a propósito: providers manuales alcanzan para el MVP y
/// eliminan build_runner del ciclo de desarrollo. Si el grafo crece,
/// migrar a riverpod_annotation es mecánico.

// ---------------------------------------------------------------------------
// Infraestructura (candidatos a graduarse a core/network cuando otro
// feature los necesite)
// ---------------------------------------------------------------------------

final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

// ---------------------------------------------------------------------------
// Data layer
// ---------------------------------------------------------------------------

final transitRemoteDataSourceProvider = Provider<TransitRemoteDataSource>(
  (ref) => SupabaseTransitRemoteDataSource(ref.watch(supabaseClientProvider)),
);

final transitLocalDataSourceProvider = Provider<TransitLocalDataSource>(
  (ref) => SharedPrefsTransitLocalDataSource(
    ref.watch(sharedPreferencesProvider),
    now: ref.watch(clockProvider),
  ),
);

final transitRepositoryProvider = Provider<TransitRepository>(
  (ref) => TransitRepositoryImpl(
    remoteDataSource: ref.watch(transitRemoteDataSourceProvider),
    localDataSource: ref.watch(transitLocalDataSourceProvider),
    // El mismo reloj que el resto de la app: decide si la cache está vieja.
    now: ref.watch(clockProvider),
  ),
);

// ---------------------------------------------------------------------------
// Usecases
// ---------------------------------------------------------------------------

final getLinesProvider = Provider<GetLines>(
  (ref) => GetLines(ref.watch(transitRepositoryProvider)),
);

final getRouteVariantsProvider = Provider<GetRouteVariants>(
  (ref) => GetRouteVariants(ref.watch(transitRepositoryProvider)),
);

final getStopsForRouteProvider = Provider<GetStopsForRoute>(
  (ref) => GetStopsForRoute(ref.watch(transitRepositoryProvider)),
);

final getNearbyStopsProvider = Provider<GetNearbyStops>(
  (ref) => GetNearbyStops(ref.watch(transitRepositoryProvider)),
);

final getSchedulesProvider = Provider<GetSchedules>(
  (ref) => GetSchedules(ref.watch(transitRepositoryProvider)),
);

final getRoutesForStopProvider = Provider<GetRoutesForStop>(
  (ref) => GetRoutesForStop(ref.watch(transitRepositoryProvider)),
);

final planTripProvider = Provider<PlanTrip>(
  (ref) => PlanTrip(ref.watch(transitRepositoryProvider)),
);

final getAllStopsProvider = Provider<GetAllStops>(
  (ref) => GetAllStops(ref.watch(transitRepositoryProvider)),
);

// ---------------------------------------------------------------------------
// Estado de selección de la UI
//
// Notifier y no StateProvider: StateProvider quedó "legacy" en Riverpod 3
// (movido a flutter_riverpod/legacy.dart); Notifier compila igual en 2.x
// y 3.x.
// ---------------------------------------------------------------------------

final selectedLineProvider = NotifierProvider<SelectedLineNotifier, BusLine?>(
  SelectedLineNotifier.new,
);

final class SelectedLineNotifier extends Notifier<BusLine?> {
  @override
  BusLine? build() => null;

  /// Elegir línea invalida el recorrido seleccionado: el anterior
  /// pertenecía a otra línea.
  void select(BusLine? line) {
    state = line;
    ref.read(selectedRouteVariantProvider.notifier).select(null);
  }
}

/// Alturas a las que engancha el panel inferior, como fracción de la
/// pantalla. Viven acá y no en el widget porque el mapa también las necesita:
/// el encuadre del trazado y los botones flotantes tienen que esquivar al
/// panel, y si cada uno usa su propia constante se desincronizan.
const sheetCollapsedExtent = 0.14;
const sheetInitialExtent = 0.34;
const sheetExpandedExtent = 0.85;

/// Cuánto de la pantalla ocupa AHORA el panel inferior.
///
/// Lo publica el propio panel mientras el usuario lo arrastra. Sin esto, el
/// encuadre del recorrido asumía siempre el 34% y con el panel expandido
/// dibujaba el trazado entero debajo del panel.
final sheetExtentProvider = NotifierProvider<SheetExtentNotifier, double>(
  SheetExtentNotifier.new,
);

final class SheetExtentNotifier extends Notifier<double> {
  @override
  double build() => sheetInitialExtent;

  void update(double extent) {
    if ((extent - state).abs() > 0.005) state = extent;
  }
}

final selectedRouteVariantProvider =
    NotifierProvider<SelectedRouteVariantNotifier, RouteVariant?>(
      SelectedRouteVariantNotifier.new,
    );

final class SelectedRouteVariantNotifier extends Notifier<RouteVariant?> {
  @override
  RouteVariant? build() => null;

  void select(RouteVariant? variant) => state = variant;
}

/// La parada que el usuario está mirando ahora, o null.
///
/// Existe para que el mapa pueda BAJAR EL RUIDO alrededor de lo que a uno le
/// importa: elegida una parada, "cerca mío" deja de dibujar la docena entera
/// y muestra solo esa y sus vecinas. La abre `StopDetailsSheet.show`.
final selectedStopProvider = NotifierProvider<SelectedStopNotifier, Stop?>(
  SelectedStopNotifier.new,
);

final class SelectedStopNotifier extends Notifier<Stop?> {
  @override
  Stop? build() => null;

  void select(Stop? stop) => state = stop;

  void clear() => state = null;
}

/// Controlador del panel de líneas.
///
/// Vive en un provider y no en el State de `LineSheet` porque hay acciones
/// de OTRAS pantallas que necesitan bajarlo: elegir una línea desde el
/// detalle de una parada tiene que dejar el recorrido A LA VISTA, y no
/// obligar a arrastrar el panel a mano.
final lineSheetControllerProvider = Provider<LineSheetController>((ref) {
  final controller = LineSheetController();
  ref.onDispose(controller.dispose);
  return controller;
});

/// Envuelve al `DraggableScrollableController` del panel de líneas.
///
/// La envoltura no es ceremonia: concentra en un solo lugar el guard de
/// "todavía no se montó" (animar un controller sin adjuntar TIRA) y a qué
/// altura se considera bajado.
final class LineSheetController {
  final draggable = DraggableScrollableController();

  /// Baja el panel a su mínimo para que se vea el mapa.
  ///
  /// Devuelve cuando terminó la animación: quien encuadra un trazado tiene
  /// que esperarla, porque el encuadre depende de cuánto tapa el panel.
  Future<void> collapse() async {
    if (!draggable.isAttached) return;
    if (draggable.size <= sheetCollapsedExtent + 0.01) return;
    await draggable.animateTo(
      sheetCollapsedExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void dispose() => draggable.dispose();
}

/// Texto del buscador de líneas. Con 20 líneas y 73 recorridos, encontrar
/// "la 110" scrolleando es peor que escribir "110".
final lineSearchProvider = NotifierProvider<LineSearchNotifier, String>(
  LineSearchNotifier.new,
);

final class LineSearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) => state = query;

  void clear() => state = '';
}

// ---------------------------------------------------------------------------
// Datos para la UI
//
// Patrón: los usecases devuelven Either; acá el Left se RELANZA como error
// para que AsyncValue lo capture. La UI recibe el Failure tipado en
// AsyncValue.error y decide el mensaje. Un solo mundo de errores en
// presentation: AsyncValue.
//
// Estos FutureProviders NO son autoDispose a propósito: funcionan como
// cache en memoria por argumento (además de la cache en disco del
// repositorio). EXCEPCIÓN: nearbyStopsProvider — ver su doc.
// ---------------------------------------------------------------------------

/// Todas las paradas, para el buscador de destino.
///
/// NO es autoDispose a propósito: es la lista más grande que maneja la app
/// (~1416 paradas) y el buscador se abre y se cierra seguido. Descartarla al
/// cerrar la hoja significaría releer y reparsear el JSON entero cada vez
/// que alguien vuelve a buscar.
final allStopsProvider = FutureProvider<List<Stop>>((ref) async {
  final result = await ref.watch(getAllStopsProvider)(const NoParams());
  return result.fold((failure) => throw failure, (stops) => stops);
});

/// De cuándo son los datos guardados en el teléfono, o null si no se sabe.
///
/// Alimenta el pie del panel de líneas. `null` es normal en el primer arranque:
/// todavía no se escribió nada en la cache.
final lastSyncProvider = FutureProvider<DateTime?>(
  (ref) => ref.watch(transitLocalDataSourceProvider).lastSyncedAt(),
);

final linesProvider = FutureProvider<List<BusLine>>((ref) async {
  final result = await ref.watch(getLinesProvider)(const NoParams());
  return result.fold((failure) => throw failure, (lines) => lines);
});

final routeVariantsProvider = FutureProvider.family<List<RouteVariant>, String>(
  (ref, lineId) async {
    final result = await ref.watch(getRouteVariantsProvider)(
      GetRouteVariantsParams(lineId: lineId),
    );
    return result.fold((failure) => throw failure, (variants) => variants);
  },
);

final stopsForRouteProvider = FutureProvider.family<List<Stop>, String>((
  ref,
  routeVariantId,
) async {
  final result = await ref.watch(getStopsForRouteProvider)(
    GetStopsForRouteParams(routeVariantId: routeVariantId),
  );
  return result.fold((failure) => throw failure, (stops) => stops);
});

final schedulesProvider =
    FutureProvider.family<
      List<Schedule>,
      ({String routeVariantId, DayType dayType})
    >((ref, args) async {
      final result = await ref.watch(getSchedulesProvider)(
        GetSchedulesParams(
          routeVariantId: args.routeVariantId,
          dayType: args.dayType,
        ),
      );
      return result.fold((failure) => throw failure, (schedules) => schedules);
    });

/// Paradas cercanas del modo "cerca mío" de MapScreen: `nearbyQueryProvider`
/// (location_providers.dart) provee la posición vía `LocationService` y este
/// provider resuelve las paradas. El record como argumento de family
/// funciona porque los records tienen == estructural.
///
/// `autoDispose` a propósito (única excepción de la sección): la regla
/// "getNearbyStops va SIEMPRE a red" aplica también a la cache en memoria.
/// Los watch de MapScreen lo mantienen vivo mientras el modo está activo;
/// al limpiar la query se descarta — cada activación pide datos frescos y
/// un error no queda cacheado para siempre. Además evita acumular una
/// entrada de family por cada fix de GPS distinto.
final nearbyStopsProvider = FutureProvider.autoDispose
    .family<List<NearbyStop>, ({double lat, double lng, int radiusMeters})>((
      ref,
      args,
    ) async {
      final result = await ref.watch(getNearbyStopsProvider)(
        GetNearbyStopsParams(
          lat: args.lat,
          lng: args.lng,
          radiusMeters: args.radiusMeters,
        ),
      );
      return result.fold((failure) => throw failure, (stops) => stops);
    });

/// Recorridos que pasan por una parada. `autoDispose` porque se consulta al
/// tocar UNA parada: retener una entrada por cada una de las 1579 paradas
/// que el usuario toque en la sesión no tiene sentido.
final routesForStopProvider = FutureProvider.autoDispose
    .family<List<RouteAtStop>, String>((ref, stopId) async {
      final result = await ref.watch(getRoutesForStopProvider)(
        GetRoutesForStopParams(stopId: stopId),
      );
      return result.fold((failure) => throw failure, (routes) => routes);
    });

/// Trazado del recorrido como puntos listos para `Polyline`.
///
/// DECISIÓN (documentada en la arquitectura base): la geometría NO pasa por
/// domain — es un dato de representación que solo le importa al mapa. Este
/// provider llama directo al RPC `get_route_geojson` y parsea el GeoJSON.
/// Riverpod lo cachea en memoria por variantId; si en Fase 2 hace falta
/// persistirlo offline, se muda al repositorio sin tocar la pantalla.
final routeGeometryProvider = FutureProvider.family<List<LatLng>, String>((
  ref,
  routeVariantId,
) async {
  final client = ref.watch(supabaseClientProvider);

  // Esta es la ÚNICA consulta que no baja a la capa de datos: la geometría no
  // pasa por el dominio, se pide cruda y se dibuja. Pero el `try` sí hace
  // falta, y no por miedo a un crash —Riverpod atrapa cualquier cosa y el
  // mapa usa `.value ?? const []`, así que lo peor que pasaba era no dibujar
  // el trazado—. Hace falta por el TIPO del error: un `TypeError` no es un
  // `Failure`, así que el `retry` de main.dart no lo excluye y Riverpod lo
  // reintentaba diez veces con backoff (~38 s) contra un servidor que iba a
  // contestar exactamente lo mismo. Convertirlo en `Failure` lo corta en el
  // primer intento y además le da a la UI un texto que se puede leer.
  try {
    final dynamic geojson = await client.rpc<dynamic>(
      'get_route_geojson',
      params: {'variant_id': routeVariantId},
    );
    if (geojson == null) {
      return const [];
    }
    final coordinates =
        (geojson as Map<String, dynamic>)['coordinates'] as List<dynamic>;
    return coordinates.map((point) {
      final pair = point as List<dynamic>;
      // GeoJSON es [lng, lat]; LatLng es (lat, lng). El gotcha clásico.
      return LatLng((pair[1] as num).toDouble(), (pair[0] as num).toDouble());
    }).toList();
  } on PostgrestException catch (e) {
    throw ServerFailure(
      message: e.message,
      statusCode: int.tryParse(e.code ?? ''),
    );
  } on SocketException {
    throw const NetworkFailure();
  } on TimeoutException {
    throw const NetworkFailure();
  } catch (e) {
    // Todo lo demás es la respuesta con otra forma de la esperada: un cast
    // que no cierra, un arreglo más corto. Es exactamente lo que
    // `DataParsingFailure` significa.
    throw DataParsingFailure(message: 'El trazado llegó con otro formato: $e');
  }
});

// ---------------------------------------------------------------------------
// Lugares (hospitales, escuelas, plazas…) para el buscador de destino
// ---------------------------------------------------------------------------

final placesDataSourceProvider = Provider<PlacesDataSource>(
  (ref) => const AssetPlacesDataSource(),
);

final placesRepositoryProvider = Provider<PlacesRepository>(
  (ref) => PlacesRepositoryImpl(ref.watch(placesDataSourceProvider)),
);

/// Fábrica del `TileProvider` del mapa.
///
/// Existe para poder TESTEAR la pantalla del mapa: el provider por defecto
/// sale a la red por cada tile, y en un widget test cada request devuelve
/// 400 y llena la corrida de excepciones. Los tests lo sobreescriben con un
/// provider que sirve una imagen fija; la app no nota la diferencia.
///
/// Es una fábrica y no una instancia porque `TileLayer` toma posesión del
/// provider que recibe (lo cierra al desmontarse) y un singleton compartido
/// se cerraría con el primer mapa que muera.
final tileProviderFactoryProvider = Provider<TileProvider Function()>(
  (ref) => NetworkTileProvider.new,
);

/// Los lugares y las calles, leídos del asset.
///
/// **`keepAlive` sin `autoDispose`**: se parsean una vez y después se usan
/// en cada tecla del buscador. Soltarlos al cerrar la hoja obligaría a
/// releer y reparsear el asset cada vez que alguien vuelve a abrir "¿a
/// dónde vas?".
///
/// Lo que SÍ importa es que esto no se toque hasta que alguien busque un
/// destino: el asset no se lee en el arranque, que es lo que lo hace gratis.
final placesProvider = FutureProvider<List<Place>>((ref) async {
  final result = await ref.watch(placesRepositoryProvider).getPlaces();
  return result.fold((failure) => throw failure, (places) => places);
});

/// Las alturas (números de puerta por calle), leídas de su propio asset.
///
/// Todavía más perezoso que [placesProvider]: es el archivo más pesado de la
/// app (~58.000 puntos) y el buscador lo pide RECIÉN cuando la consulta
/// termina en un número. Quien nunca escribe una altura nunca lo paga.
final addressesProvider = FutureProvider<List<StreetAddresses>>((ref) async {
  final result = await ref.watch(placesRepositoryProvider).getAddresses();
  return result.fold((failure) => throw failure, (addresses) => addresses);
});

/// Las paradas de Corrientes capital, que no entran al planificador.
///
/// Ver `ReferenceStop` para por qué son una clase aparte. `keepAlive` por lo
/// mismo que los lugares: se parsean una vez y se dibujan en cada cuadro del
/// mapa mientras se mira Corrientes.
final corrientesStopsProvider = FutureProvider<List<ReferenceStop>>((
  ref,
) async {
  try {
    return await const AssetCorrientesStopsDataSource().getStops();
  } on AppException {
    // Que falte el asset NO puede romper el mapa: se dibuja sin las paradas
    // de Corrientes, exactamente como antes de que existieran.
    return const [];
  }
});
