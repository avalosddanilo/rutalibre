import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/widgets/staggered_in.dart';
import '../../domain/entities/bus_line.dart';
import '../../domain/entities/route_at_stop.dart';
import '../../domain/entities/stop.dart';
import '../../domain/entities/walk_estimate.dart';
import '../providers/location_providers.dart';
import '../providers/transit_providers.dart';
import '../providers/trip_providers.dart';
import '../providers/user_prefs_providers.dart';
import '../utils/display_text.dart';
import '../utils/failure_message.dart';
import 'line_badge.dart';
import 'place_search_sheet.dart';

/// "A 350 m · unos 6 min caminando", desde donde está el usuario.
///
/// Contesta lo primero que uno se pregunta al tocar una parada en el mapa:
/// si le llega a pie o no. La distancia sola no alcanza — "350 m" obliga a
/// hacer la cuenta mental que este renglón ya hizo.
///
/// **Si no hay ubicación, no dibuja NADA.** No pide permiso, no muestra un
/// error ni un lugar vacío: sin GPS la hoja se ve exactamente como antes.
/// Un dato que adorna no puede romper la pantalla ni interrumpir a nadie
/// con un diálogo (ver [walkOriginProvider]).
class _WalkFromHere extends ConsumerWidget {
  const _WalkFromHere({required this.stop, required this.distanceLabel});

  final Stop stop;

  /// "a 120 m" cuando la hoja se abrió desde "cerca mío" — esa distancia la
  /// calculó PostGIS. Se usa de RESPALDO: si no hay ubicación para estimar
  /// el tiempo, al menos se dice a qué distancia está.
  final String? distanceLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // `.value` y no `.when`: mientras carga tampoco hay que mostrar nada.
    // Es un renglón que aparece si aparece.
    final origin = ref.watch(walkOriginProvider).value;
    final scheme = Theme.of(context).colorScheme;

    final String text;
    if (origin != null) {
      text = WalkEstimate.between(
        fromLat: origin.lat,
        fromLng: origin.lng,
        toLat: stop.lat,
        toLng: stop.lng,
      ).label;
    } else if (distanceLabel != null) {
      text = 'A ${distanceLabel!.replaceFirst(RegExp('^a '), '')}';
    } else {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 6),
      child: Row(
        children: [
          Icon(Icons.directions_walk, size: 18, color: scheme.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

/// "¿Cómo llego acá?" — el botón que faltaba.
///
/// La hoja contestaba "qué colectivos pasan por esta parada", que es media
/// pregunta. La otra media es cómo llegar hasta ella, y el planificador ya
/// estaba: acá solo se le pasa el GPS como origen y esta parada como
/// destino.
///
/// Tiene estado propio porque esperar el GPS tarda y hay que mostrarlo: sin
/// el spinner el botón parece que no hizo nada.
class _PlanTripHereButton extends ConsumerStatefulWidget {
  const _PlanTripHereButton({required this.stop});

  final Stop stop;

  @override
  ConsumerState<_PlanTripHereButton> createState() =>
      _PlanTripHereButtonState();
}

class _PlanTripHereButtonState extends ConsumerState<_PlanTripHereButton> {
  bool _locating = false;

  Future<void> _plan() async {
    final stop = widget.stop;
    // Se toma ANTES del await: después de cerrar la hoja este `context` ya
    // no sirve para nada.
    final navigator = Navigator.of(context);

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
      // Sin GPS esto era un snackbar de error y nada más: quien negó el
      // permiso no podía planificar un viaje nunca. El origen se elige a
      // mano y el viaje se calcula igual.
      await PlaceSearchSheet.showOrigin(
        context,
        notice: failureMessage(error!),
      );
      if (!mounted) return;
      // Canceló el buscador: la hoja de la parada queda como estaba.
      if (ref.read(tripSearchProvider) is TripIdle) return;
    } else {
      ref.read(tripSearchProvider.notifier).startFrom((
        lat: fix.position.lat,
        lng: fix.position.lng,
      ));
    }

    // Cerrar PRIMERO: el resultado del viaje abre su propia hoja, y dos
    // modales apilados obligan a tocar "atrás" dos veces para volver al
    // mapa que uno quería ver.
    navigator.pop();
    ref.read(tripSearchProvider.notifier).setDestination((
      lat: stop.lat,
      lng: stop.lng,
    ));
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: FilledButton.tonalIcon(
      onPressed: _locating ? null : _plan,
      icon: _locating
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            )
          : const Icon(Icons.alt_route),
      label: const Text('¿Cómo llego acá?'),
    ),
  );
}

/// Hoja modal con el detalle de una parada: su nombre, QUÉ COLECTIVOS PASAN
/// por ahí y cómo llegar hasta ella.
///
/// "Qué pasa por acá" es la pregunta de quien ya está parado en la vereda, y
/// la que ninguna app oficial del Gran Resistencia contesta de un toque.
/// "¿Cómo llego acá?" es la del que todavía está en su casa.
class StopDetailsSheet extends ConsumerWidget {
  const StopDetailsSheet({required this.stop, this.distanceLabel, super.key});

  final Stop stop;

  /// "a 120 m", cuando se abre desde el modo "cerca mío".
  final String? distanceLabel;

  /// Abre la hoja para [stop] y la deja marcada como la parada elegida.
  ///
  /// La marca NO se limpia al cerrar la hoja: el sentido de elegir una
  /// parada es que el mapa se calme alrededor de ella, y eso tiene que
  /// seguir valiendo cuando uno cierra la hoja para mirar el mapa. Se limpia
  /// tocando el mapa, eligiendo otra parada o apagando "cerca mío".
  static Future<void> show(
    BuildContext context,
    WidgetRef ref, {
    required Stop stop,
    String? distanceLabel,
  }) {
    ref.read(selectedStopProvider.notifier).select(stop);
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) =>
          StopDetailsSheet(stop: stop, distanceLabel: distanceLabel),
    );
  }

  /// Selecciona la línea y el recorrido tocados y cierra la hoja, para que
  /// el mapa de atrás muestre el trazado.
  ///
  /// `RouteAtStop` es un modelo de LECTURA: trae los ids pero no las
  /// entidades, así que hay que resolverlas contra los providers. Si algo no
  /// está (cache a medio cargar), no se hace nada en vez de dejar la
  /// selección a medias.
  static Future<void> _showOnMap(
    BuildContext context,
    WidgetRef ref,
    RouteAtStop route,
  ) async {
    final lines = ref.read(linesProvider).value;
    if (lines == null) return;

    BusLine? line;
    for (final candidate in lines) {
      if (candidate.id == route.lineId) {
        line = candidate;
        break;
      }
    }
    if (line == null) return;

    // Elegir línea limpia el recorrido elegido: primero la línea, después
    // el recorrido.
    ref.read(selectedLineProvider.notifier).select(line);

    try {
      final variants = await ref.read(routeVariantsProvider(line.id).future);
      for (final variant in variants) {
        if (variant.id == route.routeVariantId) {
          ref.read(selectedRouteVariantProvider.notifier).select(variant);
          break;
        }
      }
    } on Object {
      // Si los recorridos no cargan, queda seleccionada la línea: el panel
      // de abajo muestra el error y ofrece reintentar.
    }

    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routesAsync = ref.watch(routesForStopProvider(stop.id));
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: ConstrainedBox(
        // El mismo tope que las otras hojas sobre el mapa: siempre queda
        // mapa a la vista dando contexto de dónde está la parada, y tres
        // hojas que se abren a alturas distintas se sienten de tres apps.
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: scheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stop.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        // La distancia ya NO va acá: la dice el renglón de
                        // abajo, que además le suma el tiempo. Repetirla
                        // sería decir dos veces lo mismo con distinto
                        // formato.
                        if (stop.description != null)
                          Text(
                            stop.description!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                  // Marcar la parada de todos los días. Es la que uno vuelve
                  // a buscar cada mañana, y sin esto hay que encontrarla en
                  // el mapa otra vez.
                  _FavoriteStopButton(stop: stop),
                ],
              ),
            ),
            _WalkFromHere(stop: stop, distanceLabel: distanceLabel),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: _PlanTripHereButton(stop: stop),
            ),
            Flexible(
              child: routesAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(failureMessage(error), textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      FilledButton.tonal(
                        onPressed: () =>
                            ref.invalidate(routesForStopProvider(stop.id)),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
                data: (routes) {
                  if (routes.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.fromLTRB(24, 8, 24, 32),
                      child: Text(
                        'Todavía no tenemos registrado qué líneas paran acá.',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(bottom: 16),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                        child: Text(
                          routes.length == 1
                              ? 'Pasa 1 recorrido'
                              : 'Pasan ${routes.length} recorridos',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                      // Escalonadas como las demás listas de la app. Acá el
                      // orden también es información: los recorridos vienen
                      // agrupados por línea, y el movimiento cuenta que la
                      // respuesta llegó (esta lista sale de una consulta que
                      // tarda, no estaba ahí desde antes).
                      for (final (index, route) in routes.indexed)
                        StaggeredIn(
                          index: index,
                          child: ListTile(
                            // Tocar un recorrido lo dibuja en el mapa. Sin
                            // esto el ListTile prometía una acción que no
                            // existía: se veía tocable y no pasaba nada.
                            onTap: () => _showOnMap(context, ref, route),
                            leading: LineBadge(
                              code: route.displayCode,
                              colorHex: route.colorHex,
                              size: 36,
                            ),
                            title: Text(
                              displayText(route.lineName),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              route.variantName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Icon(
                              route.direction.isOutbound
                                  ? Icons.arrow_forward
                                  : Icons.arrow_back,
                              size: 18,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// La estrella que marca una parada como favorita.
///
/// Widget aparte y no un `IconButton` suelto porque necesita `ref` y la hoja
/// que lo contiene ya es bastante larga.
class _FavoriteStopButton extends ConsumerWidget {
  const _FavoriteStopButton({required this.stop});

  final Stop stop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoriteStopsProvider);
    final isFavorite = favorites.any((place) => place.id == stop.id);

    return IconButton(
      icon: Icon(isFavorite ? Icons.star : Icons.star_border),
      // Ámbar y no el acento de marca: el esquema está sembrado del acento,
      // así que una estrella marcada de ese color no se distingue de una sin
      // marcar. Es el mismo criterio que el chip de lluvia.
      color: isFavorite ? const Color(0xFFF9A825) : null,
      tooltip: isFavorite ? 'Quitar de favoritas' : 'Guardar esta parada',
      onPressed: () => ref.read(favoriteStopsProvider.notifier).toggle(stop),
    );
  }
}
