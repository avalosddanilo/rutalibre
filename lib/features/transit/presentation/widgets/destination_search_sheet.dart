import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../../app/widgets/staggered_in.dart';
import '../../domain/entities/place.dart';
import '../../domain/entities/stop.dart';
import '../providers/transit_providers.dart';
import '../providers/trip_providers.dart';
import '../providers/user_prefs_providers.dart';
import '../utils/destination_search.dart';
import '../utils/failure_message.dart';

/// "¿A dónde vas?" — elegir el destino escribiendo.
///
/// Hasta que existió esto, "¿cómo llego?" obligaba a ubicar el destino a ojo
/// en el mapa. Sirve si uno ya sabe dónde queda; no sirve para nada si uno
/// quiere ir a "Ameghino y Sáenz Peña" y no lo tiene ubicado.
///
/// Busca sobre la copia local de las 1416 paradas
/// ([allStopsProvider]), así que responde por tecla y SIN SEÑAL — que es
/// donde se usa, arriba del colectivo.
///
/// Tocar el mapa sigue estando: es la salida para los destinos que no son
/// una parada (una casa, una plaza). Las dos conviven porque contestan
/// preguntas distintas.
class DestinationSearchSheet extends ConsumerStatefulWidget {
  const DestinationSearchSheet({required this.origin, super.key});

  /// De dónde sale el viaje. Se usa para mostrar a qué distancia queda cada
  /// resultado: "Ameghino y French" no dice nada, "a 3,2 km" sí.
  final MapPoint origin;

  static Future<void> show(BuildContext context, {required MapPoint origin}) =>
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (context) => DestinationSearchSheet(origin: origin),
      );

  @override
  ConsumerState<DestinationSearchSheet> createState() =>
      _DestinationSearchSheetState();
}

class _DestinationSearchSheetState
    extends ConsumerState<DestinationSearchSheet> {
  final _controller = TextEditingController();
  String _query = '';

  /// Tope de resultados. Buscar "avenida" matchea cientos de esquinas y
  /// ninguna lista de cientos se lee: quien no encuentra lo suyo en los
  /// primeros, escribe una letra más.
  static const _maxResults = 40;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stopsAsync = ref.watch(allStopsProvider);

    return Padding(
      // Deja lugar al teclado: sin esto la hoja queda tapada justo cuando
      // uno empieza a escribir.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Row(
                  children: [
                    const Icon(Icons.flag),
                    const SizedBox(width: 12),
                    Text(
                      '¿A dónde vas?',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  onChanged: (value) => setState(() => _query = value),
                  decoration: InputDecoration(
                    hintText: 'Calle, esquina o lugar',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close),
                            tooltip: 'Limpiar',
                            onPressed: () {
                              _controller.clear();
                              setState(() => _query = '');
                            },
                          ),
                    // Sin `border` ni `isDense` propios: el relleno, el radio
                    // y el foco los pone `inputDecorationTheme`. Este campo
                    // tenía radio 12 cuando el resto de la app usa 16, que
                    // es justo lo que el tema vino a terminar.
                  ),
                ),
              ),
              Flexible(
                child: stopsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, _) => Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          failureMessage(error),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        FilledButton.tonal(
                          onPressed: () => ref.invalidate(allStopsProvider),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                  data: _buildResults,
                ),
              ),
              const Divider(height: 1),
              // El mapa nunca deja de ser una opción: hay destinos que no son
              // una parada (una casa, una plaza, la cancha).
              ListTile(
                leading: const Icon(Icons.touch_app),
                title: const Text('Elegirlo tocando el mapa'),
                subtitle: const Text('Para un lugar que no es una parada'),
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResults(List<Stop> stops) {
    if (_query.trim().isEmpty) return _buildShortcuts();

    // Los lugares pueden no haber cargado todavía (o fallar, si el asset
    // viniera roto): en ese caso se busca solo en paradas, que es exactamente
    // como funcionaba antes. Una función que suma no puede romper la que ya
    // estaba.
    final places = ref.watch(placesProvider).value ?? const <Place>[];
    final matches = searchDestinations(
      query: _query,
      places: places,
      stops: stops,
      limit: _maxResults,
    );

    if (matches.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Text(
          'Nada coincide con "$_query".',
          textAlign: TextAlign.center,
        ),
      );
    }

    const distance = Distance();
    final origin = LatLng(widget.origin.lat, widget.origin.lng);

    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.only(bottom: 8),
      itemCount: matches.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final match = matches[index];
        final meters = distance.as(
          LengthUnit.Meter,
          origin,
          LatLng(match.lat, match.lng),
        );
        // Qué ES cada resultado se dice con el ícono y con una palabra, no con
        // encabezados de sección: los resultados vienen ordenados por qué tan
        // bien matchean, y agruparlos por tipo rompería justamente ese orden.
        final (icon, label) = switch (match) {
          PlaceDestination(:final place) => (
            _placeIcon(place.kind),
            _placeLabel(place.kind),
          ),
          StopDestination() => (Icons.directions_bus_outlined, 'Parada'),
        };
        // Escalonadas como el resto de las listas. Acá el escalonado hace
        // algo más: los resultados aparecen mientras se escribe, y el
        // movimiento distingue "llegaron resultados nuevos" de "la lista
        // siempre estuvo así".
        return StaggeredIn(
          index: index,
          child: ListTile(
            leading: Icon(icon),
            title: Text(
              match.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            // Qué es + a qué distancia. Dos esquinas se pueden llamar parecido
            // y esto dice cuál es cuál sin abrir el mapa.
            subtitle: Text('$label · a ${_formatMeters(meters)}'),
            onTap: () => _choose(match),
          ),
        );
      },
    );
  }

  /// Lo que se ve ANTES de escribir: lo marcado y lo último elegido.
  ///
  /// Antes acá había un cartel explicando cómo buscar. Estaba bien la primera
  /// vez y sobraba las otras cincuenta — y el que toma el mismo colectivo
  /// todos los días va siempre a los mismos tres lugares. Si todavía no hay
  /// nada guardado, vuelve el cartel: un espacio vacío no enseña nada.
  Widget _buildShortcuts() {
    final favorites = ref.watch(favoriteStopsProvider);
    final recents = ref.watch(recentDestinationsProvider);

    if (favorites.isEmpty && recents.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Text(
          'Escribí una calle o una esquina. Por ejemplo: "Ameghino", '
          '"25 de Mayo y French".',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }

    // Las favoritas primero: son una decisión explícita del usuario. Los
    // recientes son una deducción nuestra, y una deducción no le gana a algo
    // que la persona dijo.
    final rows = <Widget>[
      if (favorites.isNotEmpty)
        ..._section(title: 'Guardadas', icon: Icons.star, places: favorites),
      if (recents.isNotEmpty)
        ..._section(
          title: 'Últimos destinos',
          icon: Icons.history,
          // Sin repetir lo que ya está arriba como favorito.
          places: recents
              .where((r) => favorites.every((f) => f.id != r.id))
              .toList(),
          onClear: () => ref.read(recentDestinationsProvider.notifier).clear(),
        ),
    ];

    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.only(bottom: 8),
      children: rows,
    );
  }

  List<Widget> _section({
    required String title,
    required IconData icon,
    required List<SavedPlace> places,
    VoidCallback? onClear,
  }) {
    if (places.isEmpty) return const [];
    return [
      Padding(
        padding: EdgeInsets.fromLTRB(20, 12, onClear == null ? 20 : 8, 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  letterSpacing: 1,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (onClear != null)
              TextButton(onPressed: onClear, child: const Text('Borrar')),
          ],
        ),
      ),
      for (var i = 0; i < places.length; i++)
        StaggeredIn(
          index: i,
          child: ListTile(
            leading: Icon(icon),
            title: Text(
              places[i].name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => _chooseSaved(places[i]),
          ),
        ),
    ];
  }

  /// Elegir un resultado: se anota como destino reciente y se cierra.
  void _choose(Destination match) {
    ref.read(recentDestinationsProvider.notifier).record((
      id: match.savedId,
      name: match.name,
      lat: match.lat,
      lng: match.lng,
    ));
    ref.read(tripSearchProvider.notifier).setDestination((
      lat: match.lat,
      lng: match.lng,
    ));
    Navigator.of(context).pop();
  }

  /// Elegir algo ya guardado. **No se re-anota como reciente**: volver a
  /// tocar el primero de la lista no debería reordenar nada, y si lo hiciera,
  /// la lista se movería sola bajo el dedo cada vez que se usa.
  void _chooseSaved(SavedPlace place) {
    ref.read(tripSearchProvider.notifier).setDestination((
      lat: place.lat,
      lng: place.lng,
    ));
    Navigator.of(context).pop();
  }
}

String _formatMeters(double meters) {
  if (meters < 1000) return '${meters.round()} m';
  return '${(meters / 1000).toStringAsFixed(1).replaceAll('.', ',')} km';
}

/// El ícono de cada clase de lugar. Se lee antes que el texto: en una lista
/// de veinte resultados, el ícono es lo que separa "el hospital" de "la
/// escuela de al lado del hospital" sin tener que leer.
IconData _placeIcon(PlaceKind kind) => switch (kind) {
  PlaceKind.salud => Icons.local_hospital_outlined,
  PlaceKind.educacion => Icons.school_outlined,
  PlaceKind.compras => Icons.shopping_cart_outlined,
  PlaceKind.transporte => Icons.directions_bus_filled_outlined,
  PlaceKind.gobierno => Icons.account_balance_outlined,
  PlaceKind.plaza => Icons.park_outlined,
  PlaceKind.deporte => Icons.sports_soccer_outlined,
  PlaceKind.cultura => Icons.theater_comedy_outlined,
  PlaceKind.iglesia => Icons.church_outlined,
  PlaceKind.otro => Icons.place_outlined,
};

/// Una palabra, no la categoría técnica. "Salud" y no "amenity=hospital".
String _placeLabel(PlaceKind kind) => switch (kind) {
  PlaceKind.salud => 'Salud',
  PlaceKind.educacion => 'Educación',
  PlaceKind.compras => 'Compras',
  PlaceKind.transporte => 'Transporte',
  PlaceKind.gobierno => 'Trámites',
  PlaceKind.plaza => 'Plaza',
  PlaceKind.deporte => 'Deporte',
  PlaceKind.cultura => 'Cultura',
  PlaceKind.iglesia => 'Templo',
  PlaceKind.otro => 'Lugar',
};
