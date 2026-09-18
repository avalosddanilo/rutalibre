import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../../app/widgets/staggered_in.dart';
import '../../domain/entities/place.dart';
import '../../domain/entities/stop.dart';
import '../../domain/entities/street_addresses.dart';
import '../providers/location_providers.dart';
import '../providers/transit_providers.dart';
import '../providers/trip_providers.dart';
import '../providers/user_prefs_providers.dart';
import '../utils/address_search.dart';
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
  ///
  /// Devuelve un punto SOLO cuando lo elegido fue una CALLE: una calle entera
  /// no es un destino puntual, así que en vez de fijar el destino en su
  /// mitad —y planificar un viaje a diez cuadras de la casa de alguien— la
  /// hoja se cierra devolviendo el punto para que el mapa vuele ahí y el
  /// usuario marque el lugar exacto con el modo "tocá el mapa" ya activo.
  static Future<MapPoint?> showDestination(
    BuildContext context, {
    required MapPoint origin,
  }) =>
      _show(context, target: PlaceSearchTarget.destination, reference: origin);

  /// "¿De dónde salís?" — el origen a mano, sin depender del GPS.
  static Future<void> showOrigin(BuildContext context, {String? notice}) =>
      _show(context, target: PlaceSearchTarget.origin, notice: notice);

  static Future<MapPoint?> _show(
    BuildContext context, {
    required PlaceSearchTarget target,
    MapPoint? reference,
    String? notice,
  }) => showModalBottomSheet<MapPoint>(
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
    var matches = searchDestinations(
      query: _query,
      places: places,
      stops: stops,
      limit: _maxResults,
    );

    // "Calle + altura" ("9 de Julio 1260"). Primero las ALTURAS mapeadas: el
    // área tiene ~58.000 números de puerta en OpenStreetMap, así que el 5240
    // —o su vecino más cercano— puede ser un punto DE VERDAD. Después, el
    // reintento sin el número: la calle entera y las esquinas, para afinar a
    // ojo o marcar tocando el mapa. Solo como plan B de la búsqueda normal:
    // "Ruta 11" matchea entera y ni pasa por acá — ahí el número es nombre.
    String? numberNote;
    if (matches.isEmpty) {
      final parts = splitStreetAndNumber(_query);
      if (parts != null) {
        // El asset de alturas se carga RECIÉN acá: es el más pesado de la
        // app y solo sirve cuando la consulta trae un número.
        final addresses =
            ref.watch(addressesProvider).value ?? const <StreetAddresses>[];
        final found = searchAddresses(query: _query, streets: addresses);
        final retry = searchDestinations(
          query: parts.street,
          places: places,
          stops: stops,
          limit: _maxResults,
        );
        if (found.isNotEmpty || retry.isNotEmpty) {
          matches = [
            for (final address in found)
              PlaceDestination(
                Place(
                  name: address.displayName,
                  lat: address.point.lat,
                  lng: address.point.lng,
                  kind: PlaceKind.direccion,
                ),
              ),
            ...retry,
          ];
          // El aviso dice EXACTAMENTE qué se está mostrando: un vecino no es
          // la dirección pedida, y una esquina tampoco.
          if (found.isEmpty) {
            numberNote =
                'El ${parts.number} de esa calle no está mapeado: esto es '
                'lo que hay. Elegí lo más cercano, o marcá el punto exacto '
                'tocando el mapa.';
          } else if (!found.first.exact) {
            numberNote =
                'El ${parts.number} justo no está mapeado: esto es lo '
                'mapeado más cerca.';
          }
        }
      }
    }

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
    final results = ListView.separated(
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
    if (numberNote == null) return results;

    // Se DICE qué se está mostrando: un vecino mapeado o una esquina no SON
    // la dirección pedida, y callarlo sería dejar que el usuario lo crea.
    return Column(
      // min y sin Flexible: esto vive dentro de un scroll sin altura acotada
      // (la hoja entera scrollea), y la lista de abajo ya es shrinkWrap.
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
          child: Text(
            numberNote,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        results,
      ],
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
      // Como origen, la calle se toma tal cual: el planificador arranca desde
      // las paradas CERCANAS al punto, así que la mitad de la calle contesta
      // casi lo mismo que la puerta exacta — y "Cambiar" queda a un toque.
      _setOrigin((lat: match.lat, lng: match.lng), name: match.name);
      return;
    }
    // Una CALLE como destino no fija nada: se devuelve el punto para que el
    // mapa vuele ahí y el usuario marque dónde exactamente (ver
    // [showDestination]). Tampoco se anota como reciente — el destino real
    // será el toque en el mapa, no la mitad geométrica de la calle.
    if (match case PlaceDestination(
      :final place,
    ) when place.kind == PlaceKind.calle) {
      Navigator.of(context).pop((lat: match.lat, lng: match.lng));
      return;
    }
    // El pop va PRIMERO y los notifiers se capturan antes: fijar el destino
    // dispara EN EL ACTO el listener del mapa que abre la hoja de viajes, y
    // con esta hoja todavía arriba la de viajes quedaba abajo — y el pop que
    // venía después la mataba A ELLA. En el teléfono: la bandera aparecía y
    // "cómo llegar" no, nunca (hallazgo de campo, dos veces).
    final recents = ref.read(recentDestinationsProvider.notifier);
    final trip = ref.read(tripSearchProvider.notifier);
    Navigator.of(context).pop();
    recents.record((
      id: match.savedId,
      name: match.name,
      lat: match.lat,
      lng: match.lng,
    ));
    trip.setDestination((lat: match.lat, lng: match.lng));
  }

  /// Elegir algo ya guardado. **No se re-anota como reciente**: volver a
  /// tocar el primero de la lista no debería reordenar nada, y si lo hiciera,
  /// la lista se movería sola bajo el dedo cada vez que se usa.
  void _chooseSaved(SavedPlace place) {
    if (_pickingOrigin) {
      _setOrigin((lat: place.lat, lng: place.lng), name: place.name);
      return;
    }
    // Pop primero, por lo mismo que en _choose: fijar el destino abre la
    // hoja de viajes en el acto, y tiene que abrirse ARRIBA de un buscador
    // ya cerrado, no abajo de uno abierto.
    final trip = ref.read(tripSearchProvider.notifier);
    Navigator.of(context).pop();
    trip.setDestination((lat: place.lat, lng: place.lng));
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
  PlaceKind.calle => Icons.signpost_outlined,
  PlaceKind.direccion => Icons.home_outlined,
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
  PlaceKind.calle => 'Calle',
  PlaceKind.direccion => 'Dirección',
  PlaceKind.otro => 'Lugar',
};
