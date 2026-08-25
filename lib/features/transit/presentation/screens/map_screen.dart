import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/theme/brand.dart';
import '../../../../app/theme/motion.dart';
import '../../../../app/widgets/floating_panel.dart';
import '../../../../app/widgets/staggered_in.dart';
import '../../../weather/presentation/widgets/rain_chip.dart';
import '../../domain/entities/nearby_stop.dart';
import '../../domain/entities/reference_stop.dart';
import '../../domain/entities/route_variant.dart';
import '../../domain/entities/stop.dart';
import '../../domain/entities/trip_plan.dart';
import '../../domain/usecases/get_nearby_stops.dart';
import '../providers/location_providers.dart';
import '../providers/transit_providers.dart';
import '../providers/trip_providers.dart';
import '../utils/color_hex.dart';
import '../utils/failure_message.dart';
import '../utils/map_safety.dart';
import '../utils/marker_colors.dart';
import '../utils/marker_declutter.dart';
import '../utils/route_segment.dart';
import '../utils/trip_guidance.dart';
import '../utils/trip_share_text.dart';
import '../widgets/corrientes_stop_sheet.dart';
import '../widgets/line_sheet.dart';
import '../widgets/nearby_stops_sheet.dart';
import '../widgets/place_search_sheet.dart';
import '../widgets/stop_details_sheet.dart';
import '../widgets/stop_pin.dart';
import '../widgets/trip_guidance_panel.dart';
import '../widgets/trip_results_sheet.dart';

/// Área tocable mínima de un marcador. Las pautas de accesibilidad piden
/// 44-48 px; el dibujo puede ser más chico (un pin mide 22), el TARGET no:
/// con un target del tamaño del dibujo, dos paradas de la misma cuadra son
/// imposibles de acertar.
const _tapTarget = 44.0;

/// Cuántas paradas vecinas quedan en el mapa al elegir una.
///
/// Elegir una parada es decir "me interesa ESTA": el resto de la docena deja
/// de ser información y pasa a ser ruido. Se dejan las más cercanas a ella
/// para no perder las alternativas de la misma esquina.
const _neighboursWhenSelected = 4;

/// A qué zoom se acerca el mapa al elegir un destino.
///
/// 16 y no 17: a 17 se ve la esquina pero no en qué parte de la ciudad está,
/// y el punto de acercarse es reconocer el lugar. A 16 entra el barrio.
const _destinationZoom = 16.0;

/// A qué zoom mira el mapa cada paso del viaje en curso.
///
/// Más cerca que al elegir destino: acá ya no se está reconociendo el lugar,
/// se está buscando UNA parada en la vereda de enfrente.
const _guidanceZoom = 17.0;

/// Pantalla principal: mapa OSM con el trazado y las paradas del recorrido
/// elegido, modo "cerca mío" y el panel de líneas.
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  /// Plaza 25 de Mayo, Resistencia.
  static const resistenciaCenter = LatLng(-27.4519, -58.9865);

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final _mapController = MapController();

  /// True mientras se espera el GPS (el FAB muestra un spinner).
  bool _locating = false;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  /// Centra el mapa, salvo que la coordenada esté rota.
  ///
  /// Todo lo que mueve la cámara pasa por acá. Un `NaN` que entre —del GPS de
  /// un emulador, de un dato mal parseado— deja el mapa inutilizable para toda
  /// la sesión y llena el log de excepciones; devolver sin hacer nada deja el
  /// mapa donde estaba, que es siempre mejor.
  void _moveTo(double lat, double lng, double zoom) {
    if (!isDrawableLatLng(lat, lng)) return;
    _mapController.move(LatLng(lat, lng), zoom);
  }

  /// Encuadra el trazado completo dejando aire abajo para el panel.
  ///
  /// El padding inferior se adapta al alto real: 220 px fijos en landscape o
  /// split-screen pueden superar el viewport y clavar el zoom en 0
  /// (flutter_map clampa `tamaño - padding` a 0 → "planeta entero").
  void _fitRoute(List<LatLng> points) {
    // Antes de tocar la cámara: descartar lo no dibujable y detectar el caso
    // degenerado. Un solo NaN acá deja el mapa muerto para toda la sesión
    // (ver `map_safety.dart`).
    final fit = fitFor(points);
    switch (fit) {
      case NothingToFit():
        return;
      case CenterOn(:final point):
        _mapController.move(point, 16);
        return;
      case FitAllPoints():
        break;
    }

    final height = MediaQuery.sizeOf(context).height;
    // El panel tapa la parte de abajo del mapa: el trazado tiene que entrar
    // en lo que queda VISIBLE. Se usa la altura real del panel (que cambia
    // al arrastrarlo) y no una constante, pero se limita a la mitad de la
    // pantalla: con el panel expandido al 85% el área visible es tan chica
    // que el encuadre se iría a un zoom absurdo.
    final extent = ref.read(sheetExtentProvider);
    // `isFinite` antes del clamp: el clamp de Dart DEJA PASAR el NaN, porque
    // NaN no es mayor ni menor que nada. Un NaN acá se propaga al padding y de
    // ahí al zoom.
    final sheet = extent.isFinite ? extent.clamp(0.0, 0.5) : 0.0;
    final bottom = math.min(height * 0.45, height * sheet + 24);
    _mapController.fitCamera(
      CameraFit.coordinates(
        coordinates: fit.points,
        padding: EdgeInsets.fromLTRB(40, 40, 40, bottom),
        maxZoom: 17,
      ),
    );
  }

  /// Baja el panel de líneas y RECIÉN AHÍ encuadra el trazado.
  ///
  /// Es lo que se espera al elegir un recorrido: verlo, no tener que
  /// arrastrar el panel a mano. El orden importa — encuadrar con el panel
  /// todavía arriba deja el trazado apretado contra el borde de la pantalla
  /// cuando el panel termina de bajar, porque `_fitRoute` calcula el aire de
  /// abajo con lo que el panel ocupa EN ESE MOMENTO.
  Future<void> _revealRoute(List<LatLng> points) async {
    if (points.isEmpty) return;
    await ref.read(lineSheetControllerProvider).collapse();
    if (!mounted) return;
    _fitRoute(points);
  }

  void _showError(Object error, {VoidCallback? onRetry}) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(failureMessage(error)),
          action: onRetry == null
              ? null
              : SnackBarAction(label: 'Reintentar', onPressed: onRetry),
        ),
      );
  }

  /// True en la transición terminal a error. Cubre las dos secuencias de
  /// Riverpod 3: sin retry (AsyncLoading → AsyncError, previous.isLoading)
  /// y con retry (… → AsyncLoading(error:, retrying:) → AsyncError, donde
  /// previous TAMBIÉN tiene isLoading=true — chequear previous.hasError acá
  /// haría la condición inalcanzable).
  static bool _becameError(
    AsyncValue<Object?>? previous,
    AsyncValue<Object?> next,
  ) => !next.isLoading && next.hasError && (previous?.isLoading ?? true);

  Future<void> _locateAndShowNearby() async {
    setState(() => _locating = true);
    try {
      final fix = await ref.read(locationServiceProvider).currentPosition();
      if (!mounted) return;
      ref.read(nearbyQueryProvider.notifier).show(fix.position);
      _moveTo(fix.position.lat, fix.position.lng, 16);
      if (fix.approximate) {
        // Aviso, no error: con ubicación aproximada (error de ~km) el radio
        // de 500 m busca alrededor del lugar equivocado.
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            const SnackBar(
              content: Text(
                'Tu ubicación es aproximada: activá la ubicación precisa '
                'para que "cerca mío" funcione bien.',
              ),
            ),
          );
      }
    } catch (error) {
      if (!mounted) return;
      _showError(error);
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  /// Arranca "¿cómo llego?": primero de dónde salís, después a dónde vas.
  ///
  /// El origen se intenta con el GPS porque la pregunta que uno hace la
  /// mayoría de las veces es "estoy ACÁ y quiero ir allá", y no hacerla
  /// escribir es todo el valor. Pero el GPS falla —permiso negado, servicio
  /// apagado, un fix que no llega— y antes eso terminaba en un snackbar de
  /// error: la app se quedaba sin contestar su pregunta principal por algo
  /// que tiene una alternativa obvia. Si falla, se elige el origen a mano.
  Future<void> _startTrip() async {
    setState(() => _locating = true);
    LocationFix? fix;
    Object? error;
    try {
      fix = await ref.read(locationServiceProvider).currentPosition();
    } catch (thrown) {
      error = thrown;
    } finally {
      if (mounted) setState(() => _locating = false);
    }
    if (!mounted) return;

    if (fix == null) {
      // El cartel dice POR QUÉ apareció este buscador: sin eso, pedir el
      // origen después de tocar "¿a dónde vas?" parece la pantalla equivocada.
      await PlaceSearchSheet.showOrigin(
        context,
        notice: failureMessage(error!),
      );
      if (!mounted) return;
      // Cancelar el buscador deja el modo apagado: no hay viaje que empezar.
      final origin = switch (ref.read(tripSearchProvider)) {
        TripIdle() => null,
        TripPickingDestination(:final origin) => origin,
        TripRoute(:final origin) => origin,
      };
      if (origin == null) return;
      await _askDestination(origin);
      return;
    }

    final origin = (lat: fix.position.lat, lng: fix.position.lng);
    ref.read(tripSearchProvider.notifier).startFrom(origin);
    await _askDestination(origin);
  }

  /// Con el origen ya puesto: mostrarlo en el mapa y pedir el destino.
  ///
  /// El buscador se abre solo: escribir el destino es el camino corto y el que
  /// funciona aunque uno no tenga ubicado el lugar en el mapa. Cerrarlo deja
  /// el modo activo con el banner de "tocá el mapa", que es la salida para los
  /// destinos que no son una parada.
  Future<void> _askDestination(MapPoint origin) async {
    _moveTo(origin.lat, origin.lng, 14);
    await PlaceSearchSheet.showDestination(context, origin: origin);
  }

  /// Manda el viaje elegido por donde el usuario quiera.
  ///
  /// Con una salida de emergencia: varias apps —Instagram entre ellas— no
  /// aceptan texto plano desde el menú de compartir del sistema y ni siquiera
  /// aparecen en la lista. Eso no lo podemos arreglar desde acá, pero sí
  /// podemos no dejar a nadie sin forma de mandar el mensaje: si el menú se
  /// cierra sin compartir, se ofrece copiarlo y pegarlo a mano.
  Future<void> _shareTrip(TripPlan plan, TripRoute route) async {
    final message = tripShareText(
      plan,
      destinationLat: route.destination.lat,
      destinationLng: route.destination.lng,
    );
    final result = await SharePlus.instance.share(
      ShareParams(text: message, subject: 'Mi viaje en colectivo'),
    );
    if (result.status == ShareResultStatus.success) return;
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('¿No aparece la app donde querés mandarlo?'),
          action: SnackBarAction(
            label: 'Copiar',
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: message));
              if (!mounted) return;
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(content: Text('Mensaje copiado')),
                );
            },
          ),
        ),
      );
  }

  void _showTripResults() {
    final search = ref.read(tripSearchProvider);
    if (search is TripRoute) {
      TripResultsSheet.show(context, query: search.query);
    }
  }

  /// Encuadra el viaje entero: origen, destino y todo el trazado del medio.
  void _fitTrip(TripPlan plan, TripRoute route) {
    _fitRoute([
      LatLng(route.origin.lat, route.origin.lng),
      LatLng(route.destination.lat, route.destination.lng),
      for (final leg in plan.legs) ...[
        LatLng(leg.boardStop.lat, leg.boardStop.lng),
        LatLng(leg.alightStop.lat, leg.alightStop.lng),
      ],
    ]);
  }

  /// Qué dice la etiqueta del encabezado. El viaje le gana al recorrido:
  /// si hay un viaje dibujado, es lo que el usuario está mirando.
  static String? _mapLabel(RouteVariant? variant, TripPlan? trip) {
    if (trip != null) {
      final codes = trip.legs.map((leg) => leg.displayCode).join(' → ');
      return trip.isDirect ? 'Viaje: $codes' : 'Viaje con transbordo: $codes';
    }
    return variant?.name;
  }

  @override
  Widget build(BuildContext context) {
    final selectedLine = ref.watch(selectedLineProvider);
    final selectedVariant = ref.watch(selectedRouteVariantProvider);
    final nearbyQuery = ref.watch(nearbyQueryProvider);
    final tripSearch = ref.watch(tripSearchProvider);
    final selectedTrip = ref.watch(selectedTripProvider);
    final sheetExtent = ref.watch(sheetExtentProvider);
    final scheme = Theme.of(context).colorScheme;
    final routeColor = colorFromHex(selectedLine?.colorHex) ?? scheme.primary;

    // Encuadre automático del trazado al terminar de CARGAR la geometría.
    // Un fallo se muestra con Reintentar: estos family no son autoDispose,
    // así que sin esto el AsyncError quedaría cacheado en silencio y "esa
    // línea no tiene recorrido" para siempre.
    if (selectedVariant != null) {
      final variantId = selectedVariant.id;
      ref.listen(routeGeometryProvider(variantId), (previous, next) {
        final points = next.value;
        if ((previous?.isLoading ?? false) &&
            !next.isLoading &&
            points != null) {
          _revealRoute(points);
        } else if (_becameError(previous, next)) {
          _showError(
            next.error!,
            onRetry: () => ref.invalidate(routeGeometryProvider(variantId)),
          );
        }
      });
      ref.listen(stopsForRouteProvider(variantId), (previous, next) {
        if (_becameError(previous, next)) {
          _showError(
            next.error!,
            onRetry: () => ref.invalidate(stopsForRouteProvider(variantId)),
          );
        }
      });
    }
    // Al cambiar a un recorrido cuya geometría YA está cacheada el listener
    // de arriba no dispara (no hay cambio de estado). Si lo cacheado es un
    // ERROR, re-seleccionar reintenta solo.
    ref.listen(selectedRouteVariantProvider, (previous, next) {
      if (next == null || next.id == previous?.id) return;
      final geometry = ref.read(routeGeometryProvider(next.id));
      if (geometry.hasError && !geometry.isLoading) {
        ref.invalidate(routeGeometryProvider(next.id));
      } else if (geometry.value != null) {
        _revealRoute(geometry.value!);
      } else {
        // La geometría todavía está viajando: se baja el panel YA igual, así
        // el recorrido aparece sobre el mapa despejado en vez de detrás del
        // panel. El encuadre lo hace el listener de arriba cuando llegue.
        ref.read(lineSheetControllerProvider).collapse();
      }
      final stops = ref.read(stopsForRouteProvider(next.id));
      if (stops.hasError && !stops.isLoading) {
        ref.invalidate(stopsForRouteProvider(next.id));
      }
    });

    // Puesto el destino, la hoja de resultados se abre sola: nadie toca el
    // mapa "a ver qué pasa", lo toca para saber cómo llegar.
    ref.listen(tripSearchProvider, (previous, next) {
      if (next is TripRoute && previous is! TripRoute) {
        ref.read(lineSheetControllerProvider).collapse();
        // Primero se ACERCA al destino, y recién después se abre la hoja.
        //
        // Elegir "Hospital Perrando" en una lista y que el mapa no se mueva
        // deja la duda de si entendió cuál: uno eligió un nombre, no un
        // lugar. Con el zoom encima se ve DÓNDE queda —la cuadra, el barrio,
        // qué hay alrededor— antes de ponerse a elegir en qué colectivo ir.
        //
        // Después, al tocar una opción, `_fitTrip` abre la cámara al viaje
        // entero: acercarse y volver a alejarse es el mismo movimiento que
        // hace uno con los dedos, y hace legible el salto.
        _moveTo(next.destination.lat, next.destination.lng, _destinationZoom);
        _showTripResults();
      }
    });
    // Elegido un viaje, se encuadra para verlo entero.
    ref.listen(selectedTripProvider, (previous, next) {
      final search = ref.read(tripSearchProvider);
      if (next != null && next != previous && search is TripRoute) {
        _fitTrip(next, search);
      }
    });

    // Los pasos del viaje en curso, o null si no arrancó. Se calculan acá
    // porque los necesitan tres cosas: el panel, el botón de arrancar y el
    // movimiento de cámara de cada paso.
    final guidanceIndex = ref.watch(tripGuidanceProvider);
    final List<GuidanceStep>? steps =
        (guidanceIndex != null &&
            selectedTrip != null &&
            tripSearch is TripRoute)
        ? guidanceSteps(
            plan: selectedTrip,
            originLat: tripSearch.origin.lat,
            originLng: tripSearch.origin.lng,
            destinationLat: tripSearch.destination.lat,
            destinationLng: tripSearch.destination.lng,
          )
        : null;

    // Cada paso mueve el mapa a donde hay que mirar: la parada donde subís,
    // la de bajada, el destino. Es lo que hace que se sienta una guía y no
    // una lista — el mapa va contando el viaje junto con el texto.
    ref.listen(tripGuidanceProvider, (previous, next) {
      if (next == null || steps == null || steps.isEmpty) {
        return;
      }
      final step = steps[next.clamp(0, steps.length - 1)];
      _moveTo(step.focusLat, step.focusLng, _guidanceZoom);
    });

    final nearbyArgs = nearbyQuery == null
        ? null
        : (
            lat: nearbyQuery.lat,
            lng: nearbyQuery.lng,
            radiusMeters: GetNearbyStopsParams.defaultRadiusMeters,
          );
    if (nearbyArgs != null) {
      ref.listen(nearbyStopsProvider(nearbyArgs), (previous, next) {
        if (_becameError(previous, next)) {
          _showError(
            next.error!,
            onRetry: () => ref.invalidate(nearbyStopsProvider(nearbyArgs)),
          );
        } else if ((previous?.isLoading ?? false) &&
            !next.isLoading &&
            next.hasValue) {
          if (next.value!.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'No encontramos paradas a menos de '
                  '${GetNearbyStopsParams.defaultRadiusMeters} m.',
                ),
              ),
            );
          } else {
            NearbyStopsSheet.show(context, args: nearbyArgs);
          }
        }
      });
    }
    final nearbyStops = nearbyArgs == null
        ? const <NearbyStop>[]
        : ref.watch(nearbyStopsProvider(nearbyArgs)).value ??
              const <NearbyStop>[];

    final routeStops = selectedVariant == null
        ? const <Stop>[]
        : ref.watch(stopsForRouteProvider(selectedVariant.id)).value ??
              const <Stop>[];
    final routePoints = selectedVariant == null
        ? const <LatLng>[]
        : ref.watch(routeGeometryProvider(selectedVariant.id)).value ??
              const <LatLng>[];

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: MapScreen.resistenciaCenter,
              initialZoom: 13,
              minZoom: 9,
              maxZoom: 18,
              // **SIN ROTACIÓN.** El default de flutter_map es
              // `InteractiveFlag.all`, que la incluye: dos dedos apoyados con
              // un poco de ángulo giran el mapa sin que nadie lo pida, y
              // después no hay forma de volver al norte. En una app de
              // colectivos girar el mapa no sirve para nada —las calles se
              // leen igual, los nombres quedan de costado— y encima la
              // cámara rotada es donde la librería hace las cuentas de
              // tiles que reventaban con NaN.
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
              // El toque en el mapa vacío hace dos cosas según el modo. En
              // "¿cómo llego?" pone el destino (por eso el destino puede ser
              // CUALQUIER punto y no solo una parada: uno quiere ir al
              // hospital, no a la parada tal). Si no, deselecciona la parada
              // y vuelven a aparecer todas las cercanas — sin esa salida,
              // elegir una parada era un callejón sin salida.
              // Los marcadores absorben su propio toque, así que esto solo
              // dispara en el mapa vacío.
              onTap: (_, point) {
                // Si la cámara ya está rota, el punto tocado también lo está.
                // Guardarlo como destino haría permanente un estado del que no
                // se sale ni cerrando la hoja.
                if (!isDrawableLatLng(point.latitude, point.longitude)) return;
                if (tripSearch is TripPickingDestination) {
                  ref.read(tripSearchProvider.notifier).setDestination((
                    lat: point.latitude,
                    lng: point.longitude,
                  ));
                  return;
                }
                ref.read(selectedStopProvider.notifier).clear();
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                // Requerido por la política de tiles de OSM.
                userAgentPackageName: 'com.rutalibre.rutalibre',
                // Inyectable para que la pantalla se pueda testear sin red.
                tileProvider: ref.watch(tileProviderFactoryProvider)(),
              ),
              if (routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    // Halo blanco debajo: sobre calles claras u oscuras el
                    // trazado se sigue leyendo.
                    Polyline(
                      points: routePoints,
                      strokeWidth: 8,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                    Polyline(
                      points: routePoints,
                      strokeWidth: 4.5,
                      color: routeColor,
                    ),
                  ],
                ),
              // Abajo de todo lo demás: es el contexto sobre el que se
              // dibujan las respuestas.
              const _CorrientesStopMarkers(),
              _AllStopMarkers(
                drawnElsewhere: [
                  ...routeStops,
                  for (final nearby in nearbyStops) nearby.stop,
                ],
                picking: tripSearch is TripPickingDestination,
              ),
              if (selectedTrip != null) _TripLayers(plan: selectedTrip),
              if (routeStops.isNotEmpty)
                _RouteStopMarkers(stops: routeStops, color: routeColor),
              if (nearbyStops.isNotEmpty)
                _NearbyStopMarkers(stops: nearbyStops),
              if (tripSearch case TripRoute(:final destination))
                MarkerLayer(
                  markers: [
                    _pinMarker(
                      point: LatLng(destination.lat, destination.lng),
                      color: destinationMarkerColor,
                      width: 30,
                      glyph: const Icon(
                        Icons.flag,
                        size: 15,
                        color: Colors.white,
                      ),
                      tooltip: 'A dónde vas',
                      onTap: () => _showTripResults(),
                    ),
                  ],
                ),
              if (nearbyQuery != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(nearbyQuery.lat, nearbyQuery.lng),
                      width: 22,
                      height: 22,
                      child: const DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          // Fijo por lo mismo que el marcador de parada: los
                          // tiles no cambian con el tema de la app.
                          color: userMarkerColor,
                          border: Border.fromBorderSide(
                            BorderSide(color: Colors.white, width: 3),
                          ),
                          boxShadow: [
                            BoxShadow(blurRadius: 4, color: Colors.black38),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              // Vos, moviéndote, SOLO con la guía activa: es la única
              // situación en que la app sigue la posición (ver
              // livePositionProvider — el stream muere solo al cerrar la
              // guía). Ver el propio punto avanzar por el trazado es lo que
              // confirma "voy bien" sin leer nada.
              if (steps != null) const _LiveGuidanceDot(),
            ],
          ),
          _TopBar(
            variantLabel: _mapLabel(selectedVariant, selectedTrip),
            // El pronóstico se pide para donde está la persona si eso ya se
            // sabe, y si no para el centro de Resistencia. `walkOriginProvider`
            // NUNCA pide permiso —usa la última posición que tenga el
            // sistema— así que el chip aparece sin que la app moleste, y el
            // centro de respaldo lo hace aparecer igual en una instalación
            // nueva. Con 20 km entre Resistencia y Corrientes la diferencia
            // puede importar; sin ubicación, la ciudad más poblada es la
            // mejor apuesta.
            rainOrigin: ref.watch(walkOriginProvider).value,
          ),
          if (tripSearch case TripPickingDestination(:final origin))
            _PickDestinationBanner(
              onSearch: () =>
                  PlaceSearchSheet.showDestination(context, origin: origin),
              onCancel: () => ref.read(tripSearchProvider.notifier).clear(),
            ),
          _MapActions(
            locating: _locating,
            showFitRoute: routePoints.isNotEmpty,
            showClearNearby: nearbyQuery != null,
            showTrip: tripSearch is! TripIdle,
            onShareTrip: (selectedTrip != null && tripSearch is TripRoute)
                ? () => _shareTrip(selectedTrip, tripSearch)
                : null,
            // Solo cuando hay un viaje ELEGIDO y todavía no arrancó: mientras
            // la guía corre, el botón sería un "empezar de nuevo" disfrazado.
            onStartGuidance:
                (selectedTrip != null &&
                    tripSearch is TripRoute &&
                    steps == null)
                ? () => ref.read(tripGuidanceProvider.notifier).start()
                : null,
            sheetExtent: sheetExtent,
            onPlanTrip: _startTrip,
            onClearTrip: () => ref.read(tripSearchProvider.notifier).clear(),
            onFitRoute: () => _fitRoute(routePoints),
            onClearNearby: () {
              ref.read(nearbyQueryProvider.notifier).clear();
              // Si no, la parada elegida sobrevive al modo que la mostró y
              // la próxima vez que se active "cerca mío" arranca filtrado
              // por una parada que el usuario ya no tiene en pantalla.
              ref.read(selectedStopProvider.notifier).clear();
            },
            onShowNearbyList: () {
              if (nearbyArgs != null) {
                NearbyStopsSheet.show(context, args: nearbyArgs);
              }
            },
            onLocate: _locateAndShowNearby,
          ),
          // Con el viaje en curso el panel de líneas NO se dibuja: quien está
          // yendo a algún lado no está eligiendo qué colectivo mirar, y dos
          // paneles apilados abajo dejarían el mapa en una franja.
          if (steps == null)
            LineSheet(onPlanTrip: _locating ? null : _startTrip)
          else
            TripGuidancePanel(steps: steps),
        ],
      ),
    );
  }
}

/// El punto "vos" del viaje en curso, alimentado por el GPS en vivo.
///
/// Widget aparte por lo mismo que las otras capas: que el rebuild de cada
/// fix de posición redibuje ESTO y no la pantalla entera. Sin posición
/// (permiso negado, GPS apagado, primer fix que no llegó) no dibuja nada.
class _LiveGuidanceDot extends ConsumerWidget {
  const _LiveGuidanceDot();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final position = ref.watch(livePositionProvider).value;
    if (position == null || !isDrawableLatLng(position.lat, position.lng)) {
      return const SizedBox.shrink();
    }

    return MarkerLayer(
      markers: [
        Marker(
          point: LatLng(position.lat, position.lng),
          width: 22,
          height: 22,
          child: const DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // El mismo azul de "acá estás" del modo cerca mío: es el mismo
              // significado, así que es el mismo color.
              color: userMarkerColor,
              border: Border.fromBorderSide(
                BorderSide(color: Colors.white, width: 3),
              ),
              boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black38)],
            ),
          ),
        ),
      ],
    );
  }
}

/// Un pin de parada listo para el mapa.
///
/// `alignment: Alignment.topCenter` deja el widget entero POR ARRIBA de la
/// coordenada, que es lo que hace que la punta del pin apoye exactamente en
/// la parada. El área tocable sigue siendo de 44 px (pautas de
/// accesibilidad) aunque el dibujo mida menos.
Marker _pinMarker({
  required LatLng point,
  required Color color,
  required String tooltip,
  required VoidCallback onTap,
  double width = StopPin.defaultWidth,
  Widget? glyph,
}) => _markerAt(
  point: point,
  alignment: Alignment.topCenter,
  tooltip: tooltip,
  onTap: onTap,
  // Abajo del todo: la punta del pin tiene que caer en el borde inferior
  // del recuadro, que es donde `topCenter` pone la coordenada.
  child: Align(
    alignment: Alignment.bottomCenter,
    child: StopPin(color: color, width: width, glyph: glyph),
  ),
);

/// Un punto de parada: la alternativa liviana al pin.
///
/// Va CENTRADO en la coordenada (a diferencia del pin, que la señala con la
/// punta), porque un punto no señala: está.
Marker _dotMarker({
  required LatLng point,
  required Color color,
  required String tooltip,
  required VoidCallback onTap,
  double size = StopDot.defaultSize,
}) => _markerAt(
  point: point,
  alignment: Alignment.center,
  tooltip: tooltip,
  onTap: onTap,
  child: Center(
    child: StopDot(color: color, size: size),
  ),
);

Marker _markerAt({
  required LatLng point,
  required Alignment alignment,
  required String tooltip,
  required VoidCallback onTap,
  required Widget child,
}) => Marker(
  point: point,
  alignment: alignment,
  width: _tapTarget,
  height: _tapTarget,
  child: GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: onTap,
    child: Tooltip(message: tooltip, child: child),
  ),
);

/// Todas las paradas de la red: la capa de fondo del mapa.
///
/// Existe porque el mapa arrancaba VACÍO: había que elegir una línea o darle
/// permiso de ubicación para ver una sola parada. Una app de colectivos que no
/// muestra dónde se para hasta que le den el GPS pide algo antes de dar nada.
///
/// Sale de [allStopsProvider] —la misma copia local que usa el buscador de
/// destino, ya cacheada—, así que esta capa también anda sin señal.
class _AllStopMarkers extends ConsumerStatefulWidget {
  const _AllStopMarkers({required this.drawnElsewhere, required this.picking});

  /// Paradas que ya dibuja otra capa (el recorrido elegido, "cerca mío").
  final List<Stop> drawnElsewhere;

  /// Si estamos eligiendo el destino de "¿cómo llego?".
  final bool picking;

  /// Más chico que el punto de "cerca mío": esto es contexto.
  static const _dotSize = 10.0;

  @override
  ConsumerState<_AllStopMarkers> createState() => _AllStopMarkersState();
}

class _AllStopMarkersState extends ConsumerState<_AllStopMarkers> {
  /// El resultado del descongestionado, memorizado.
  ///
  /// `MapCamera.of(context)` hace que esta capa se redibuje en CADA CUADRO
  /// mientras se arrastra el mapa, y el descongestionado recorre las 1416
  /// paradas. Pero su resultado depende SOLO del zoom y del conjunto que
  /// entra —esa es toda la gracia de `worldPixels`—, así que arrastrando no
  /// cambia nada y recalcularlo 60 veces por segundo es trabajo tirado.
  /// Lo que sí hay que rehacer en cada cuadro es el recorte al viewport, que
  /// es barato porque corre sobre lo que sobrevivió, no sobre las 1416.
  List<Stop>? _spread;
  double? _spreadZoom;
  int? _spreadInputs;

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(allStopsProvider).value ?? const <Stop>[];
    if (all.isEmpty) return const SizedBox.shrink();

    final camera = MapCamera.of(context);
    final inputs = Object.hash(
      all.length,
      Object.hashAll(widget.drawnElsewhere.map((stop) => stop.id)),
    );

    if (_spread == null ||
        _spreadZoom != camera.zoom ||
        _spreadInputs != inputs) {
      final taken = {for (final stop in widget.drawnElsewhere) stop.id};
      // Descongestionar PRIMERO y recortar a la pantalla DESPUÉS, nunca al
      // revés. `spreadOutMarkers` trabaja en píxeles absolutos del mundo
      // justo para que su resultado dependa solo del zoom; si acá se filtrara
      // por el viewport antes, al arrastrar el mapa cambiaría el conjunto que
      // compite por cada lugar y las paradas parpadearían.
      //
      // Las paradas que dibuja otra capa se excluyen pero RESERVAN su lugar:
      // si no, un punto de fondo se metería justo abajo de un pin.
      _spread = spreadOutMarkers(
        all.where((stop) => !taken.contains(stop.id)),
        location: _positionOf,
        zoom: camera.zoom,
        reserved: widget.drawnElsewhere.map(_positionOf),
      );
      _spreadZoom = camera.zoom;
      _spreadInputs = inputs;
    }
    final spread = _spread!;

    // Y recortar hace falta igual: acercando el mapa entran casi las 1416, y
    // armar esa lista de marcadores en cada redibujado se siente.
    final bounds = camera.visibleBounds;

    return MarkerLayer(
      markers: [
        for (final stop in spread)
          if (bounds.contains(_positionOf(stop)))
            _dotMarker(
              point: _positionOf(stop),
              color: allStopsMarkerColor,
              size: _AllStopMarkers._dotSize,
              tooltip: stop.name,
              // Eligiendo destino, tocar una parada elige ESA parada como
              // destino en vez de abrir su ficha: en ese modo el toque en el
              // mapa ya significa "quiero ir acá", y que un punto de fondo
              // significara otra cosa sería una trampa.
              onTap: () => widget.picking
                  ? ref.read(tripSearchProvider.notifier).setDestination((
                      lat: stop.lat,
                      lng: stop.lng,
                    ))
                  : StopDetailsSheet.show(context, ref, stop: stop),
            ),
      ],
    );
  }

  static LatLng _positionOf(Stop stop) => LatLng(stop.lat, stop.lng);
}

/// Paradas del recorrido elegido.
///
/// Es un widget propio y no una lista armada en el `build` de la pantalla
/// porque necesita el ZOOM: `MapCamera.of(context)` solo existe dentro de un
/// `FlutterMap` y hace que esta capa —y nada más que esta capa— se redibuje
/// cuando la cámara cambia.
class _RouteStopMarkers extends ConsumerWidget {
  const _RouteStopMarkers({required this.stops, required this.color});

  /// En orden de paso: la primera y la última son las cabeceras.
  final List<Stop> stops;
  final Color color;

  /// Las cabeceras se dibujan un poco más grandes.
  static const _terminalWidth = 28.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zoom = MapCamera.of(context).zoom;

    // Las cabeceras van SIEMPRE: son las que cuentan hacia dónde va el
    // recorrido. Las intermedias compiten por el lugar que queda.
    final hasTerminals = stops.length >= 2;
    final terminals = hasTerminals
        ? [(stops.first, true), (stops.last, false)]
        : const <(Stop, bool)>[];
    final middle = hasTerminals ? stops.sublist(1, stops.length - 1) : stops;

    final visible = spreadOutMarkers(
      middle,
      location: (stop) => LatLng(stop.lat, stop.lng),
      zoom: zoom,
      reserved: [for (final (stop, _) in terminals) LatLng(stop.lat, stop.lng)],
    );

    return MarkerLayer(
      markers: [
        for (final stop in visible)
          _pinMarker(
            point: LatLng(stop.lat, stop.lng),
            color: color,
            tooltip: stop.name,
            onTap: () => StopDetailsSheet.show(context, ref, stop: stop),
          ),
        // Al final para que queden DIBUJADAS ENCIMA de las intermedias.
        for (final (stop, isStart) in terminals)
          _pinMarker(
            point: LatLng(stop.lat, stop.lng),
            color: color,
            width: _terminalWidth,
            glyph: Icon(
              isStart ? Icons.trip_origin : Icons.flag,
              size: _terminalWidth * 0.5,
              color: Colors.white,
            ),
            tooltip: '${isStart ? 'Arranca en' : 'Termina en'}: ${stop.name}',
            onTap: () => StopDetailsSheet.show(context, ref, stop: stop),
          ),
      ],
    );
  }
}

/// Paradas del modo "cerca mío", con UNA protagonista y el resto como
/// alternativas.
///
/// Una docena de pines iguales se lee como una docena de alertas y no dice
/// nada: todas parecen igual de importantes. Acá hay jerarquía —
///
/// * sin parada elegida, la protagonista es LA MÁS CERCANA (que es la
///   respuesta a "¿dónde me subo?") y el resto son puntos chicos;
/// * con una parada elegida, la protagonista es esa y quedan SOLO sus
///   [_neighboursWhenSelected] vecinas más cercanas: el resto de la docena
///   dejó de importar en cuanto el usuario dijo cuál le interesa.
///
/// Elegir una parada del RECORRIDO (que no está en esta lista) no cambia
/// nada acá: se comporta como si no hubiera nada elegido.
class _NearbyStopMarkers extends ConsumerWidget {
  const _NearbyStopMarkers({required this.stops});

  /// Ordenadas por distancia al usuario, la más cercana primero.
  final List<NearbyStop> stops;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedStopProvider)?.id;
    final selectedIndex = stops.indexWhere((n) => n.stop.id == selectedId);

    final NearbyStop leader;
    final List<NearbyStop> others;
    if (selectedIndex >= 0) {
      leader = stops[selectedIndex];
      others = _neighboursOf(leader, stops, _neighboursWhenSelected);
    } else {
      leader = stops.first;
      // Con la docena entera en pantalla sí hace falta descongestionar por
      // zoom; con cinco marcadores no, y esconder uno de cinco confundiría.
      others = spreadOutMarkers(
        stops.skip(1),
        location: _positionOf,
        zoom: MapCamera.of(context).zoom,
        reserved: [_positionOf(leader)],
      );
    }

    return MarkerLayer(
      markers: [
        for (final nearby in others)
          _dotMarker(
            point: _positionOf(nearby),
            color: nearbyMarkerColor,
            tooltip: _labelOf(nearby),
            onTap: () => _open(context, ref, nearby),
          ),
        // Al final para que el pin quede DIBUJADO ENCIMA de los puntos.
        _pinMarker(
          point: _positionOf(leader),
          color: nearbyMarkerColor,
          tooltip: _labelOf(leader),
          onTap: () => _open(context, ref, leader),
        ),
      ],
    );
  }

  static LatLng _positionOf(NearbyStop nearby) =>
      LatLng(nearby.stop.lat, nearby.stop.lng);

  static String _labelOf(NearbyStop nearby) =>
      '${nearby.stop.name} · a ${nearby.formattedDistance}';

  static void _open(BuildContext context, WidgetRef ref, NearbyStop nearby) =>
      StopDetailsSheet.show(
        context,
        ref,
        stop: nearby.stop,
        distanceLabel: 'a ${nearby.formattedDistance}',
      );

  /// Las [count] paradas más cercanas A LA ELEGIDA (no al usuario): son las
  /// alternativas reales de esa esquina.
  static List<NearbyStop> _neighboursOf(
    NearbyStop leader,
    List<NearbyStop> all,
    int count,
  ) => nearestTo(
    all.where((nearby) => nearby.stop.id != leader.stop.id),
    origin: _positionOf(leader),
    location: _positionOf,
    count: count,
  );
}

/// El viaje elegido dibujado en el mapa: el trazado de cada tramo y las
/// paradas donde subirse, cambiarse y bajarse.
///
/// La geometría se pide con `routeGeometryProvider`, el mismo provider que
/// usa el trazado del panel de líneas: un viaje de dos tramos que comparte
/// recorrido con lo que ya estaba dibujado no vuelve a pedir nada.
class _TripLayers extends ConsumerWidget {
  const _TripLayers({required this.plan});

  final TripPlan plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final legColors = [
      for (final leg in plan.legs)
        colorFromHex(leg.colorHex) ?? Theme.of(context).colorScheme.primary,
    ];

    final polylines = <Polyline>[];
    for (var i = 0; i < plan.legs.length; i++) {
      final leg = plan.legs[i];
      final full = ref.watch(routeGeometryProvider(leg.routeVariantId)).value;
      if (full == null || full.isEmpty) continue;
      // SOLO el pedazo que se viaja. Dibujar el recorrido entero no dejaba
      // distinguir "por acá vas" de "por acá pasa el colectivo", que es justo
      // lo que uno abre el mapa a mirar.
      final points = segmentBetween(
        points: full,
        boardLat: leg.boardStop.lat,
        boardLng: leg.boardStop.lng,
        alightLat: leg.alightStop.lat,
        alightLng: leg.alightStop.lng,
      );
      polylines
        ..add(
          Polyline(
            points: points,
            strokeWidth: 8,
            color: Colors.white.withValues(alpha: 0.85),
          ),
        )
        ..add(Polyline(points: points, strokeWidth: 4.5, color: legColors[i]));
    }

    // Las caminatas, punteadas: de donde estás hasta donde subís, y de donde
    // bajás hasta el destino. Es lo que cierra el camino — sin esto el
    // trazado empieza y termina en el aire, a cuadras de los dos extremos.
    final walks = <Polyline>[];
    final search = ref.watch(tripSearchProvider);
    if (search is TripRoute && plan.legs.isNotEmpty) {
      for (final (from, to) in [
        (
          LatLng(search.origin.lat, search.origin.lng),
          LatLng(plan.legs.first.boardStop.lat, plan.legs.first.boardStop.lng),
        ),
        (
          LatLng(plan.legs.last.alightStop.lat, plan.legs.last.alightStop.lng),
          LatLng(search.destination.lat, search.destination.lng),
        ),
      ]) {
        walks.add(
          Polyline(
            points: [from, to],
            strokeWidth: 3,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            // Punteada, y no continua, porque NO es un camino: es la línea
            // recta entre dos puntos. No sabemos por qué vereda se camina y
            // dibujarla entera sería afirmarlo.
            pattern: StrokePattern.dotted(spacingFactor: 2.5),
          ),
        );
      }
    }

    return Stack(
      children: [
        if (walks.isNotEmpty) PolylineLayer(polylines: walks),
        if (polylines.isNotEmpty) PolylineLayer(polylines: polylines),
        MarkerLayer(
          markers: [
            for (var i = 0; i < plan.legs.length; i++) ...[
              // La subida del primer tramo y las bajadas de todos. La subida
              // de un segundo tramo NO se dibuja: es la misma parada donde
              // bajaste del primero, y dos pines encimados no dicen nada.
              if (i == 0)
                _pinMarker(
                  point: LatLng(
                    plan.legs[i].boardStop.lat,
                    plan.legs[i].boardStop.lng,
                  ),
                  color: legColors[i],
                  width: 30,
                  glyph: const Icon(
                    Icons.directions_bus,
                    size: 15,
                    color: Colors.white,
                  ),
                  tooltip:
                      'Tomás la ${plan.legs[i].displayCode} en '
                      '${plan.legs[i].boardStop.name}',
                  onTap: () => StopDetailsSheet.show(
                    context,
                    ref,
                    stop: plan.legs[i].boardStop,
                  ),
                ),
              _pinMarker(
                point: LatLng(
                  plan.legs[i].alightStop.lat,
                  plan.legs[i].alightStop.lng,
                ),
                color: legColors[i],
                width: 30,
                glyph: Icon(
                  // La bajada intermedia es un transbordo, no el final.
                  i == plan.legs.length - 1
                      ? Icons.logout
                      : Icons.transfer_within_a_station,
                  size: 15,
                  color: Colors.white,
                ),
                tooltip: i == plan.legs.length - 1
                    ? 'Bajás en ${plan.legs[i].alightStop.name}'
                    : 'Te cambiás a la ${plan.legs[i + 1].displayCode} en '
                          '${plan.legs[i].alightStop.name}',
                onTap: () => StopDetailsSheet.show(
                  context,
                  ref,
                  stop: plan.legs[i].alightStop,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// Aviso de que el mapa está esperando un toque.
///
/// Va abajo y no arriba: arriba está el encabezado, y sobre todo porque el
/// pulgar tiene que llegar a "Cancelar" sin tapar el mapa que hay que tocar.
class _PickDestinationBanner extends StatelessWidget {
  const _PickDestinationBanner({
    required this.onSearch,
    required this.onCancel,
  });

  /// Vuelve a abrir el buscador. Sin esto, cerrarlo por error dejaba el
  /// mapa como única salida y había que cancelar el modo entero para
  /// recuperar el teclado.
  final VoidCallback onSearch;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 76, left: 12, right: 12),
          // Baja desde arriba al entrar al modo: es una instrucción que
          // aparece de golpe encima del mapa, y sin movimiento se confunde
          // con algo que ya estaba.
          child: StaggeredIn(
            index: 0,
            offset: -16,
            child: FloatingPanel(
              color: scheme.inverseSurface,
              radius: 14,
              padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.touch_app,
                    size: 18,
                    color: scheme.onInverseSurface,
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      'Tocá en el mapa a dónde querés ir',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onInverseSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search, size: 20),
                    color: scheme.inversePrimary,
                    tooltip: 'Buscarlo por nombre',
                    onPressed: onSearch,
                  ),
                  TextButton(
                    onPressed: onCancel,
                    child: Text(
                      'Cancelar',
                      style: TextStyle(color: scheme.inversePrimary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// La marca, arriba a la izquierda.

/// Encabezado flotante: identidad de la app, recorrido activo y el crédito
/// de OSM (obligatorio por la licencia ODbL de los datos y los tiles).
class _TopBar extends StatelessWidget {
  const _TopBar({required this.variantLabel, required this.rainOrigin});

  final String? variantLabel;

  /// Dónde preguntar por la lluvia. Null hasta que se sepa algo de la
  /// ubicación; el chip cae al centro de Resistencia mientras tanto.
  final UserPosition? rainOrigin;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // La escala de texto se acota a 1.3 SOLO en este renglón, y es
            // una decisión de accesibilidad, no en contra: al 200% la chapa
            // de la marca ocupaba casi todo el ancho y al crédito de OSM le
            // quedaban ~40 px — se partía en una letra por renglón, 800 px de
            // alto de sopa de letras. Esto es cromo sobre el mapa, no
            // contenido de lectura; lo que SÍ es contenido (el chip de
            // lluvia, abajo) escala completo porque tiene el ancho entero.
            MediaQuery.withClampedTextScaling(
              maxScaleFactor: 1.3,
              child: Row(
                children: [
                  FloatingPanel(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // La marca, no un ícono de catálogo: es la misma que
                        // el ícono de la app, dibujada por el mismo painter.
                        // Sobre el panel claro la carrocería va en el negro de
                        // marca y los faros en el acento.
                        const BrandMark(
                          size: 20,
                          bodyColor: Brand.black,
                          accentColor: Brand.accent,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Ruta Libre',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Expanded y no Spacer: con el tamaño de fuente accesible el
                  // crédito desbordaba el Row y quedaba RECORTADO. Mostrarlo
                  // entero no es cosmético, es la obligación de atribución de
                  // la licencia ODbL.
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: FloatingPanel(
                        radius: 10,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        child: Text(
                          '© OpenStreetMap contributors',
                          textAlign: TextAlign.right,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // El chip de lluvia va DEBAJO de la marca y no al lado: el
            // renglón de arriba ya se lo pelea con el crédito de OSM, que por
            // licencia tiene que verse entero y con el tamaño de fuente
            // accesible ya venía justo. Abajo tiene todo el ancho para
            // abrirse y sigue estando arriba a la izquierda.
            Align(
              alignment: Alignment.centerLeft,
              child: RainChip(
                lat: rainOrigin?.lat ?? MapScreen.resistenciaCenter.latitude,
                lng: rainOrigin?.lng ?? MapScreen.resistenciaCenter.longitude,
              ),
            ),
            // El cartel del recorrido entra y sale animado: aparece al elegir
            // una línea y desaparece al soltarla, y sin transición el resto de
            // la barra pega un salto vertical.
            AnimatedSize(
              duration: Motion.base,
              curve: Motion.curve,
              alignment: Alignment.topLeft,
              child: variantLabel == null
                  ? const SizedBox(width: double.infinity)
                  : Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: FloatingPanel(
                        color: scheme.secondaryContainer,
                        radius: 12,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        child: Text(
                          variantLabel!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: scheme.onSecondaryContainer),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Un botón de la botonera que aparece y desaparece con el estado del mapa.
///
/// Crece desde la nada con un sobrepaso chico ([Motion.entrance]) y se va sin
/// rebote: rebotar al salir se lee como un error. Cuando no está visible
/// ocupa CERO —no queda un hueco reservado—, así la columna se compacta sola
/// y el `AnimatedSize` de arriba la acomoda.
class _PopIn extends StatelessWidget {
  const _PopIn({required this.visible, required this.child});

  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedScale(
    scale: visible ? 1 : 0,
    duration: Motion.base,
    curve: visible ? Motion.entrance : Motion.curve,
    child: AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: Motion.quick,
      child: visible
          ? Padding(padding: const EdgeInsets.only(bottom: 8), child: child)
          : const SizedBox.shrink(),
    ),
  );
}

/// Botonera flotante, apoyada arriba del panel de líneas.
class _MapActions extends StatelessWidget {
  const _MapActions({
    required this.locating,
    required this.showFitRoute,
    required this.showClearNearby,
    required this.showTrip,
    required this.onShareTrip,
    required this.onStartGuidance,
    required this.sheetExtent,
    required this.onPlanTrip,
    required this.onClearTrip,
    required this.onFitRoute,
    required this.onClearNearby,
    required this.onShowNearbyList,
    required this.onLocate,
  });

  final bool locating;
  final bool showFitRoute;
  final bool showClearNearby;

  /// True con el modo "¿cómo llego?" encendido: el botón de plan cambia por
  /// el de salir, para que el modo nunca quede trabado.
  final bool showTrip;

  /// Null cuando no hay un viaje elegido para compartir.
  final VoidCallback? onShareTrip;

  /// Arranca la guía paso a paso. Null si todavía no hay un viaje elegido o
  /// si ya está en curso.
  final VoidCallback? onStartGuidance;

  /// Fracción de pantalla que ocupa el panel inferior ahora mismo.
  final double sheetExtent;
  final VoidCallback onPlanTrip;
  final VoidCallback onClearTrip;
  final VoidCallback onFitRoute;
  final VoidCallback onClearNearby;

  /// Vuelve a abrir la lista de paradas cercanas. La lista se abre sola
  /// cuando llegan los datos, pero sin esto cerrarla era un camino de ida:
  /// no había forma de recuperarla salvo volver a pedir la ubicación.
  final VoidCallback onShowNearbyList;
  final VoidCallback onLocate;

  @override
  Widget build(BuildContext context) {
    // Los botones siguen al panel: si se quedaran fijos, al expandirlo
    // quedarían tapados.
    final bottom = MediaQuery.sizeOf(context).height * sheetExtent + 12;
    return Positioned(
      right: 12,
      bottom: bottom,
      // AnimatedSize porque los botones aparecen y desaparecen según el
      // estado (hay recorrido, hay "cerca mío", hay viaje): sin esto la
      // columna pega saltos y los de abajo se corren de golpe justo cuando
      // el dedo va hacia ellos.
      child: AnimatedSize(
        duration: Motion.base,
        curve: Motion.curve,
        alignment: Alignment.bottomRight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _PopIn(
              visible: onShareTrip != null,
              child: FloatingActionButton.small(
                heroTag: 'share-trip',
                tooltip: 'Compartir mi viaje',
                onPressed: onShareTrip,
                child: const Icon(Icons.ios_share),
              ),
            ),
            // "Iniciar viaje" NO es un botón chico como los demás: es la
            // acción con la que termina todo el recorrido de la app —buscar,
            // elegir destino, elegir colectivo— y tiene que verse como el
            // final de ese camino, no como una opción más de la columna.
            _PopIn(
              visible: onStartGuidance != null,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: FloatingActionButton.extended(
                  heroTag: 'start-trip',
                  onPressed: onStartGuidance,
                  icon: const Icon(Icons.navigation),
                  label: const Text('Iniciar viaje'),
                ),
              ),
            ),
            _PopIn(
              visible: showFitRoute,
              child: FloatingActionButton.small(
                heroTag: 'fit-route',
                tooltip: 'Encuadrar el recorrido',
                onPressed: onFitRoute,
                child: const Icon(Icons.crop_free),
              ),
            ),
            _PopIn(
              visible: showClearNearby,
              child: FloatingActionButton.small(
                heroTag: 'nearby-list',
                tooltip: 'Ver la lista de paradas cercanas',
                onPressed: onShowNearbyList,
                child: const Icon(Icons.format_list_bulleted),
              ),
            ),
            _PopIn(
              visible: showClearNearby,
              child: FloatingActionButton.small(
                heroTag: 'clear-nearby',
                tooltip: 'Ocultar paradas cercanas',
                onPressed: onClearNearby,
                child: const Icon(Icons.location_off),
              ),
            ),
            FloatingActionButton.small(
              heroTag: 'locate',
              tooltip: 'Paradas cerca mío',
              onPressed: locating ? null : onLocate,
              // AnimatedSwitcher y no un if: el ícono se cambia por la
              // ruedita y al volver, sin el parpadeo de reemplazar el hijo.
              child: AnimatedSwitcher(
                duration: Motion.quick,
                child: locating
                    ? const SizedBox(
                        key: ValueKey('locating'),
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : const Icon(Icons.my_location, key: ValueKey('idle')),
              ),
            ),
            // "¿Cómo llego?" ya NO vive acá: subió al panel de abajo, que es
            // donde se hace la pregunta (ver `_DestinationCta`). Lo único que
            // queda es la salida del modo, y solo mientras el modo está
            // activo — un botón para salir de algo en lo que no estás es
            // ruido en la pantalla más cargada de la app.
            _PopIn(
              visible: showTrip,
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: FloatingActionButton.extended(
                  heroTag: 'trip',
                  tooltip: 'Salir de "cómo llego"',
                  onPressed: onClearTrip,
                  icon: const Icon(Icons.close),
                  label: const Text('Salir'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Las paradas de Corrientes capital.
///
/// Se dibujan **huecas**, distintas de las paradas del Gran Resistencia, y
/// no es decoración: de estas no sabemos el recorrido ni el orden, así que
/// tocarlas abre una hoja más corta y no ofrece "¿cómo llego acá?". Si se
/// vieran iguales, la diferencia de comportamiento se leería como un bug.
///
/// **Solo a partir de [_minZoom].** Es lo que evita que las 254 sumen trabajo
/// cuando se mira la ciudad entera —donde además serían un manchón— y lo que
/// mantiene esta capa gratis en el arranque, que es sobre el Gran Resistencia.
class _CorrientesStopMarkers extends ConsumerStatefulWidget {
  const _CorrientesStopMarkers();

  /// Por debajo de esto son puntitos amontonados que no ayudan a nadie.
  static const _minZoom = 14.5;
  static const _dotSize = 11.0;

  @override
  ConsumerState<_CorrientesStopMarkers> createState() =>
      _CorrientesStopMarkersState();
}

class _CorrientesStopMarkersState
    extends ConsumerState<_CorrientesStopMarkers> {
  /// Los puntos ya construidos, una sola vez.
  ///
  /// `MapCamera.of(context)` hace que esta capa se redibuje en CADA CUADRO
  /// mientras se arrastra el mapa. Sin esto, cada cuadro recorría las 254
  /// paradas construyendo un `LatLng` nuevo por cada una para preguntarle al
  /// viewport si entra — 254 objetos por cuadro, tirados al terminar. Es el
  /// mismo error que `_AllStopMarkers` documenta y evita.
  List<(ReferenceStop, LatLng)>? _points;

  @override
  Widget build(BuildContext context) {
    final camera = MapCamera.of(context);
    if (camera.zoom < _CorrientesStopMarkers._minZoom) {
      return const SizedBox.shrink();
    }

    final stops = ref.watch(corrientesStopsProvider).value ?? const [];
    if (stops.isEmpty) return const SizedBox.shrink();

    final points = _points ??= [
      for (final stop in stops)
        if (isDrawableLatLng(stop.lat, stop.lng))
          (stop, LatLng(stop.lat, stop.lng)),
    ];

    final bounds = camera.visibleBounds;
    final scheme = Theme.of(context).colorScheme;

    return MarkerLayer(
      markers: [
        for (final (stop, point) in points)
          // Lo único que SÍ hay que rehacer por cuadro: el recorte al
          // viewport, que trabaja sobre puntos ya construidos.
          if (bounds.contains(point))
            Marker(
              point: point,
              width: _tapTarget,
              height: _tapTarget,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => CorrientesStopSheet.show(context, stop),
                child: Tooltip(
                  message: '${stop.name} · ${stop.lines.join(", ")}',
                  child: Center(
                    child: Container(
                      width: _CorrientesStopMarkers._dotSize,
                      height: _CorrientesStopMarkers._dotSize,
                      decoration: BoxDecoration(
                        // Hueca: el relleno es el color del mapa, el borde
                        // es lo que se ve.
                        color: scheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: nearbyMarkerColor, width: 2),
                      ),
                    ),
                  ),
                ),
              ),
            ),
      ],
    );
  }
}
