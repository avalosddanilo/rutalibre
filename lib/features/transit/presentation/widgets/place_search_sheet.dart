import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../../app/widgets/staggered_in.dart';
import '../../domain/entities/place.dart';
import '../../domain/entities/stop.dart';
import '../providers/location_providers.dart';
import '../providers/transit_providers.dart';
import '../providers/trip_providers.dart';
import '../providers/user_prefs_providers.dart';
import '../utils/destination_search.dart';
import '../utils/failure_message.dart';

/// Qué punta del viaje se está eligiendo.
///
/// Cambia el título, el atajo de arriba y qué pasa al tocar un resultado.
/// **Nada más**: la lista, el orden y los atajos guardados son los mismos
/// porque el problema es el mismo —decir un punto del mapa escribiendo— y
/// dos buscadores distintos para la misma tarea se ven como dos bugs.
enum PlaceSearchTarget { origin, destination }

/// Elegir una punta del viaje escribiendo: "¿a dónde vas?" o "¿de dónde
/// salís?".
///
/// Hasta que existió esto, "¿cómo llego?" obligaba a ubicar el destino a ojo
/// en el mapa. Sirve si uno ya sabe dónde queda; no sirve para nada si uno
/// quiere ir a "Ameghino y Sáenz Peña" y no lo tiene ubicado.
///
/// Busca sobre la copia local de las paradas ([allStopsProvider]) y los
/// lugares empaquetados ([placesProvider]), así que responde por tecla y SIN
/// SEÑAL — que es donde se usa, arriba del colectivo.
///
/// Tocar el mapa sigue estando para el destino: es la salida para los que no
/// son una parada (una casa, una plaza). Las dos conviven porque contestan
/// preguntas distintas.
class PlaceSearchSheet extends ConsumerStatefulWidget {
  const PlaceSearchSheet({
    required this.target,
    this.reference,
    this.notice,
    super.key,
  });

  final PlaceSearchTarget target;

  /// Desde dónde se miden las distancias de los resultados: "Ameghino y
  /// French" no dice nada, "a 3,2 km" sí.
  ///
  /// Null las apaga. Eligiendo ORIGEN se apagan a propósito: la única
  /// referencia disponible sería el origen que se está por reemplazar, y "a
  /// 3,2 km" de un punto que la persona quiere cambiar no informa nada.
  final MapPoint? reference;

  /// Cartel de por qué se está eligiendo a mano ("no pudimos ubicarte").
  ///
  /// Sin esto, un buscador de origen que aparece solo después de tocar
  /// "¿a dónde vas?" se lee como que la app se equivocó de pantalla.
  final String? notice;

  /// "¿A dónde vas?" — el destino, con [origin] como referencia de distancias.
  static Future<void> showDestination(
    BuildContext context, {
    required MapPoint origin,
  }) =>
      _show(context, target: PlaceSearchTarget.destination, reference: origin);

  /// "¿De dónde salís?" — el origen a mano, sin depender del GPS.
  static Future<void> showOrigin(BuildContext context, {String? notice}) =>
      _show(context, target: PlaceSearchTarget.origin, notice: notice);

  static Future<void> _show(
    BuildContext context, {
    required PlaceSearchTarget target,
    MapPoint? reference,
    String? notice,
  }) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) =>
        PlaceSearchSheet(target: target, reference: reference, notice: notice),
  );

  @override
  ConsumerState<PlaceSearchSheet> createState() => _PlaceSearchSheetState();
}

class _PlaceSearchSheetState extends ConsumerState<PlaceSearchSheet> {
  final _controller = TextEditingController();
  String _query = '';

  /// True mientras se espera el GPS del atajo "usar mi ubicación".
  bool _locating = false;

  /// Tope de resultados. Buscar "avenida" matchea cientos de esquinas y
  /// ninguna lista de cientos se lee: quien no encuentra lo suyo en los
  /// primeros, escribe una letra más.
  static const _maxResults = 40;

  bool get _pickingOrigin => widget.target == PlaceSearchTarget.origin;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stopsAsync = ref.watch(allStopsProvider);
    // El origen se lee del estado y no del parámetro: cambiarlo desde esta
    // misma hoja tiene que refrescar el encabezado y las distancias sin
    // cerrarla.
    final search = ref.watch(tripSearchProvider);
    final reference = _pickingOrigin ? null : _originOf(search);

    return Padding(
      // Deja lugar al teclado: sin esto la hoja queda tapada justo cuando
      // uno empieza a escribir.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.8,
          ),
          // Toda la hoja en UN scroll, como las demás: con el texto del
          // sistema al 200% la parte fija sola (título, origen, campo y
          // atajos) superaba el tope de la hoja. A escala normal, idéntico.
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Row(
                  children: [
                    Icon(_pickingOrigin ? Icons.trip_origin : Icons.flag),
                    const SizedBox(width: 12),
                    // Expanded: al 200% de texto el título no entra al lado
                    // del ícono y desbordaba. Prefiere partirse en dos
                    // renglones antes que romperse.
                    Expanded(
                      child: Text(
                        _pickingOrigin ? '¿De dónde salís?' : '¿A dónde vas?',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.notice != null) _Notice(text: widget.notice!),
              // Eligiendo destino, DE DÓNDE se sale va a la vista y se puede
              // cambiar. Es lo único que vuelve planificable un viaje que uno
              // no está empezando en este momento — desde el sillón, la noche
              // anterior— y la salida para el teléfono que no da el GPS.
              if (!_pickingOrigin && search is! TripIdle)
                _OriginRow(
                  label: _originLabel(search),
                  onChange: _changeOrigin,
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
              // Eligiendo origen, el GPS va PRIMERO: sigue siendo la respuesta
              // correcta la mayoría de las veces, y quien llegó acá porque
              // falló necesita poder reintentarlo sin salir.
              if (_pickingOrigin)
                ListTile(
                  leading: _locating
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: Center(
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                              ),
                            ),
                          ),
                        )
                      : const Icon(Icons.my_location),
                  title: const Text('Usar mi ubicación'),
                  onTap: _locating ? null : _useCurrentLocation,
                ),
              stopsAsync.when(
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
                        onPressed: () => ref.invalidate(allStopsProvider),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
                data: (stops) => _buildResults(stops, reference),
              ),
              // El mapa nunca deja de ser una opción PARA EL DESTINO: hay
              // destinos que no son una parada (una casa, una plaza, la
              // cancha). Para el origen no se ofrece: el planificador arranca
              // desde las paradas cercanas, así que la esquina de al lado
              // contesta lo mismo que el patio exacto, y un segundo modo de
              // "tocá el mapa" pediría otro banner y otro estado.
              if (!_pickingOrigin) ...[
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.touch_app),
                  title: const Text('Elegirlo tocando el mapa'),
                  subtitle: const Text('Para un lugar que no es una parada'),
                  onTap: () => Navigator.of(context).pop(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResults(List<Stop> stops, MapPoint? reference) {
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
    final from = reference == null
        ? null
        : LatLng(reference.lat, reference.lng);

    // Sin scroll propio: scrollea la hoja entera (ver el ListView del build).
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 8),
      itemCount: matches.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final match = matches[index];
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
        final meters = from == null
            ? null
            : distance.as(LengthUnit.Meter, from, LatLng(match.lat, match.lng));
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
            subtitle: Text(
              meters == null ? label : '$label · a ${_formatMeters(meters)}',
            ),
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
          // Eligiendo origen la lista es la misma pero significa otra cosa:
          // de donde uno vuelve es, casi siempre, adonde fue.
          title: _pickingOrigin ? 'Últimos lugares' : 'Últimos destinos',
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
      physics: const NeverScrollableScrollPhysics(),
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

  /// Elegir un resultado de la búsqueda.
  ///
  /// Como destino se anota además en los recientes. Como origen NO: la lista
  /// se llama "últimos destinos" y llenarla con lugares donde uno ESTUVO
  /// parado la volvería otra cosa.
  void _choose(Destination match) {
    if (_pickingOrigin) {
      _setOrigin((lat: match.lat, lng: match.lng), name: match.name);
      return;
    }
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
    if (_pickingOrigin) {
      _setOrigin((lat: place.lat, lng: place.lng), name: place.name);
      return;
    }
    ref.read(tripSearchProvider.notifier).setDestination((
      lat: place.lat,
      lng: place.lng,
    ));
    Navigator.of(context).pop();
  }

  void _setOrigin(MapPoint point, {String? name}) {
    ref.read(tripSearchProvider.notifier).setOrigin(point, name: name);
    Navigator.of(context).pop();
  }

  /// El GPS, desde el buscador de origen.
  ///
  /// Si falla, el aviso va en un snackbar y la hoja QUEDA ABIERTA: acá la
  /// alternativa —escribir el lugar— está a la vista, así que cerrar dejaría
  /// a la persona sin la salida que ya tenía en pantalla.
  Future<void> _useCurrentLocation() async {
    setState(() => _locating = true);
    try {
      final fix = await ref.read(locationServiceProvider).currentPosition();
      if (!mounted) return;
      _setOrigin((lat: fix.position.lat, lng: fix.position.lng));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(failureMessage(error))));
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  /// Abre el buscador de origen ARRIBA de este, sin cerrarlo: al volver, esta
  /// hoja ya muestra el origen nuevo y el destino sigue sin elegirse. Cerrar
  /// y reabrir haría perder lo escrito y devolvería a la persona al mapa.
  Future<void> _changeOrigin() =>
      PlaceSearchSheet.showOrigin(context).then((_) {
        if (mounted) setState(() {});
      });

  static MapPoint? _originOf(TripSearch search) => switch (search) {
    TripIdle() => null,
    TripPickingDestination(:final origin) => origin,
    TripRoute(:final origin) => origin,
  };

  static String _originLabel(TripSearch search) => switch (search) {
    TripIdle() => 'Mi ubicación',
    TripPickingDestination(:final originName) => originName ?? 'Mi ubicación',
    TripRoute(:final originName) => originName ?? 'Mi ubicación',
  };
}

/// "Desde: X · Cambiar", arriba del campo de búsqueda.
class _OriginRow extends StatelessWidget {
  const _OriginRow({required this.label, required this.onChange});

  final String label;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 8, 4),
      child: Row(
        children: [
          Icon(Icons.trip_origin, size: 16, color: scheme.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Desde $label',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(onPressed: onChange, child: const Text('Cambiar')),
        ],
      ),
    );
  }
}

/// Por qué se está eligiendo el origen a mano.
class _Notice extends StatelessWidget {
  const _Notice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.secondaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 18,
                color: scheme.onSecondaryContainer,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
