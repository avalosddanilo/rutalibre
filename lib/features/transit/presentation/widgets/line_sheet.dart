import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/widgets/staggered_in.dart';
import '../../domain/entities/bus_line.dart';
import '../../domain/entities/fare.dart';
import '../providers/transit_providers.dart';
import '../providers/user_prefs_providers.dart';
import '../screens/schedules_screen.dart';
import '../utils/display_text.dart';
import '../utils/failure_message.dart';
import '../utils/search_text.dart';
import 'line_badge.dart';

/// Panel inferior del mapa: buscador + listado de líneas, y el detalle de
/// la línea elegida.
///
/// Reemplaza a los chips horizontales: con 20 líneas y 73 recorridos, un
/// carrusel obliga a scrollear a ciegas. Acá se busca por número o por
/// barrio y las líneas quedan agrupadas por red.
class LineSheet extends ConsumerWidget {
  const LineSheet({this.onPlanTrip, super.key});

  /// Arranca "¿cómo llego?". Vive en el mapa —necesita el GPS y el
  /// controller— y llega hasta acá porque ESTE es el lugar donde la pregunta
  /// se hace: el panel de abajo es lo primero que se toca al abrir la app.
  ///
  /// Opcional: sin él el panel sigue funcionando como listado de líneas, que
  /// es lo que hace falta para testearlo suelto.
  final VoidCallback? onPlanTrip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLine = ref.watch(selectedLineProvider);

    return NotificationListener<DraggableScrollableNotification>(
      // El mapa necesita saber cuánto ocupa el panel para encuadrar el
      // trazado en la parte visible y para ubicar los botones flotantes.
      onNotification: (notification) {
        ref.read(sheetExtentProvider.notifier).update(notification.extent);
        return false;
      },
      child: DraggableScrollableSheet(
        // El controller viene de un provider porque hay acciones de afuera
        // que necesitan bajar el panel: al elegir un recorrido —desde acá o
        // desde el detalle de una parada— el trazado tiene que quedar a la
        // vista sin que el usuario arrastre nada.
        controller: ref.watch(lineSheetControllerProvider).draggable,
        initialChildSize: sheetInitialExtent,
        minChildSize: sheetCollapsedExtent,
        maxChildSize: sheetExpandedExtent,
        snap: true,
        snapSizes: const [
          sheetCollapsedExtent,
          sheetInitialExtent,
          sheetExpandedExtent,
        ],
        builder: (context, scrollController) {
          final scheme = Theme.of(context).colorScheme;
          // Material y no DecoratedBox: los ListTile pintan su fondo y su
          // ripple sobre el Material más cercano, y un DecoratedBox con color
          // se los taparía (tocar una línea no daría feedback).
          return Material(
            color: scheme.surface,
            // Elevación moderada y sombra clara: con 8 y la sombra por
            // defecto, el borde de arriba del panel se dibuja como una franja
            // negra dura en vez de despegarse del mapa.
            elevation: 4,
            shadowColor: Colors.black.withValues(alpha: 0.3),
            clipBehavior: Clip.antiAlias,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: selectedLine == null
                ? _LineList(
                    scrollController: scrollController,
                    onPlanTrip: onPlanTrip,
                  )
                : _LineDetail(
                    line: selectedLine,
                    scrollController: scrollController,
                  ),
          );
        },
      ),
    );
  }
}

/// Barra de arrastre. Va DENTRO del scrollable para que se pueda arrastrar
/// el panel desde cualquier punto, no solo desde la lista.
class _Grabber extends StatelessWidget {
  const _Grabber();

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );
}

/// La entrada a "¿cómo llego?", arriba de todo y del tamaño que le
/// corresponde.
///
/// Antes esto era un botón flotante sobre el mapa, uno más en una columna de
/// cinco. Pero de todo lo que hace la app es LO ÚNICO que contesta la
/// pregunta con la que uno la abre —y el propio código lo decía en un
/// comentario mientras lo dibujaba del mismo tamaño que "encuadrar el
/// recorrido"—. Acá arriba no compite con nada y es lo primero que cae bajo
/// el pulgar cuando el panel está abajo.
///
/// No es un `TextField`: escribir se escribe en el buscador que se abre
/// después, con la ubicación ya resuelta. Este es un botón que parece un
/// campo, que es exactamente lo que hacen las apps de viajes.
class _DestinationCta extends StatelessWidget {
  const _DestinationCta({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
      child: Material(
        // `primaryContainer` y no la superficie gris: abajo hay OTRO campo
        // —el de buscar líneas— y con el mismo relleno los dos se leían como
        // dos versiones de lo mismo. El color dice cuál es el camino
        // principal sin tener que explicarlo.
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Row(
              children: [
                Icon(Icons.search, color: scheme.onPrimaryContainer),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '¿A dónde vas?',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward,
                  size: 18,
                  color: scheme.onPrimaryContainer,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LineList extends ConsumerWidget {
  const _LineList({required this.scrollController, this.onPlanTrip});

  final ScrollController scrollController;
  final VoidCallback? onPlanTrip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final linesAsync = ref.watch(linesProvider);
    final query = ref.watch(lineSearchProvider);

    return linesAsync.when(
      loading: () => ListView(
        controller: scrollController,
        children: const [
          _Grabber(),
          SizedBox(height: 40),
          Center(child: CircularProgressIndicator()),
        ],
      ),
      error: (error, _) => ListView(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          const _Grabber(),
          const SizedBox(height: 24),
          Text(failureMessage(error), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Center(
            child: FilledButton.tonal(
              onPressed: () => ref.invalidate(linesProvider),
              child: const Text('Reintentar'),
            ),
          ),
        ],
      ),
      data: (lines) {
        // También por DESTINO, no solo por código y nombre: el nombre es un
        // resumen que a partir del tercer destino dice "y N más", así que
        // buscar "Sarmiento" no encontraba la línea 3 aunque su ramal A
        // termina en el Shopping Sarmiento. Ver `BusLine.destinations`.
        final matching = lines
            .where(
              (line) =>
                  matchesSearch(line.code, query) ||
                  matchesSearch(line.name, query) ||
                  line.destinations.any(
                    (destination) => matchesSearch(destination, query),
                  ),
            )
            .toList();

        // Las favoritas se fijan arriba y SALEN de su grupo de red: eso es lo
        // que significa fijar algo, y verlas dos veces en la misma lista se
        // lee como un error de la app. La estrella prendida explica dónde
        // fueron a parar.
        //
        // **Solo cuando no se está buscando.** Con una búsqueda escrita, lo
        // que manda es lo que se escribió: reordenar los resultados por un
        // criterio que el usuario no acaba de expresar es esconderle lo que
        // pidió.
        final favorites = ref.watch(favoriteLinesProvider);
        final searching = query.trim().isNotEmpty;
        bool isFavorite(BusLine line) =>
            !searching &&
            favorites.contains(
              UserPrefsStore.lineKey(
                networkCode: line.network.code,
                lineCode: line.code,
              ),
            );

        // Se arma una lista plana de encabezados de red + líneas para que
        // todo entre en un solo ListView (y el arrastre del panel funcione).
        final rows = <Widget>[];
        final pinned = matching.where(isFavorite).toList();
        if (pinned.isNotEmpty) {
          rows.add(const _SectionHeader(name: 'Tus favoritas'));
          rows.addAll(pinned.map((line) => _LineTile(line: line)));
        }

        String? currentNetwork;
        for (final line in matching) {
          if (isFavorite(line)) continue;
          if (line.network.code != currentNetwork) {
            currentNetwork = line.network.code;
            rows.add(
              _NetworkHeader(name: line.network.name, code: line.network.code),
            );
          }
          rows.add(_LineTile(line: line));
        }

        return ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.only(bottom: 24),
          itemCount: rows.length + 2,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Grabber(),
                  if (onPlanTrip != null) _DestinationCta(onTap: onPlanTrip!),
                  // Sin rótulo de "o buscá una línea": el campo ya lo dice en
                  // su propio hint, y el panel arranca ocupando un tercio de
                  // la pantalla — cada renglón de cabecera es una línea menos
                  // a la vista sin arrastrar.
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                    child: _SearchField(resultCount: matching.length),
                  ),
                ],
              );
            }
            if (index == 1) {
              if (matching.isNotEmpty) return const SizedBox.shrink();
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Center(
                  child: Text(
                    'Ninguna línea coincide con la búsqueda.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            // La lista entra escalonada: el movimiento cuenta que ACABA de
            // cargar y en qué orden está, en vez de aparecer entera de golpe
            // como si siempre hubiera estado ahí.
            return StaggeredIn(index: index - 2, child: rows[index - 2]);
          },
        );
      },
    );
  }
}

class _SearchField extends ConsumerStatefulWidget {
  const _SearchField({required this.resultCount});

  final int resultCount;

  @override
  ConsumerState<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends ConsumerState<_SearchField> {
  late final TextEditingController _controller = TextEditingController(
    text: ref.read(lineSearchProvider),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Si el estado se limpia desde afuera, el campo lo refleja.
    ref.listen(lineSearchProvider, (previous, next) {
      if (next != _controller.text) _controller.text = next;
    });

    return TextField(
      controller: _controller,
      onChanged: ref.read(lineSearchProvider.notifier).update,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Buscar línea o barrio',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Limpiar',
                onPressed: () {
                  _controller.clear();
                  ref.read(lineSearchProvider.notifier).clear();
                },
              ),
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

/// Encabezado de grupo sin tarifa: el de "Tus favoritas", que junta líneas de
/// redes distintas y por eso no puede llevar un precio.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
    child: Text(
      name.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        letterSpacing: 1,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

class _NetworkHeader extends StatelessWidget {
  const _NetworkHeader({required this.name, required this.code});

  final String name;
  final String code;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final labelStyle = Theme.of(context).textTheme.labelSmall;
    final fare = networkFareFor(code);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              name.toUpperCase(),
              style: labelStyle?.copyWith(
                color: scheme.onSurfaceVariant,
                letterSpacing: 1,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // La tarifa va en el encabezado de la RED y no en cada línea:
          // dentro de una red casi siempre es la misma, y repetirla veinte
          // veces la convierte en ruido. Si alguna línea cobra distinto se
          // dice acá con un "desde", y el número exacto aparece en la
          // pantalla de esa línea.
          if (fare != null)
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: networkHasFareExceptions(code)
                        ? 'desde ${fare.formattedAmount}'
                        : fare.formattedAmount,
                    style: labelStyle?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  // La fecha pegada al precio, siempre. Un precio sin fecha
                  // es peor que no tener precio.
                  TextSpan(
                    text: ' · ${fare.formattedValidity}',
                    style: labelStyle?.copyWith(color: scheme.outline),
                  ),
                ],
              ),
              textAlign: TextAlign.right,
            ),
        ],
      ),
    );
  }
}

class _LineTile extends ConsumerWidget {
  const _LineTile({required this.line});

  final BusLine line;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // `watch` y no `read`: la estrella tiene que cambiar sola cuando la misma
    // línea se marca desde el grupo de favoritas de arriba.
    final favorites = ref.watch(favoriteLinesProvider);
    final isFavorite = favorites.contains(
      UserPrefsStore.lineKey(
        networkCode: line.network.code,
        lineCode: line.code,
      ),
    );

    return ListTile(
      leading: LineBadge(code: line.code, colorHex: line.colorHex),
      title: Text(
        displayText(line.name),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      // La estrella va de trailing y no de leading: el lugar de la izquierda
      // es del número de la línea, que es por lo que se busca. Marcar es una
      // acción de después.
      trailing: IconButton(
        icon: Icon(isFavorite ? Icons.star : Icons.star_border),
        color: isFavorite ? _favoriteColor : null,
        tooltip: isFavorite ? 'Quitar de favoritas' : 'Marcar como favorita',
        onPressed: () => ref
            .read(favoriteLinesProvider.notifier)
            .toggle(networkCode: line.network.code, lineCode: line.code),
      ),
      onTap: () {
        ref.read(selectedLineProvider.notifier).select(line);
        FocusScope.of(context).unfocus();
      },
    );
  }
}

/// El ámbar de las estrellas.
///
/// No sale del `ColorScheme` por lo mismo que el chip de lluvia: el esquema
/// está sembrado del acento de marca y una estrella "marcada" del mismo tono
/// que todo lo demás no se distingue de una sin marcar.
const _favoriteColor = Color(0xFFF9A825);

class _LineDetail extends ConsumerWidget {
  const _LineDetail({required this.line, required this.scrollController});

  final BusLine line;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final variantsAsync = ref.watch(routeVariantsProvider(line.id));
    final selectedVariant = ref.watch(selectedRouteVariantProvider);

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const _Grabber(),
        ListTile(
          leading: LineBadge(code: line.code, colorHex: line.colorHex),
          title: Text(
            displayText(line.name),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(line.network.name),
          trailing: IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Volver al listado',
            onPressed: () =>
                ref.read(selectedLineProvider.notifier).select(null),
          ),
        ),
        const Divider(height: 1),
        variantsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(failureMessage(error), textAlign: TextAlign.center),
                const SizedBox(height: 8),
                FilledButton.tonal(
                  onPressed: () =>
                      ref.invalidate(routeVariantsProvider(line.id)),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
          data: (variants) => Column(
            children: [
              for (final variant in variants)
                ListTile(
                  selected: variant.id == selectedVariant?.id,
                  leading: Icon(
                    variant.direction.isOutbound
                        ? Icons.arrow_forward
                        : Icons.arrow_back,
                  ),
                  title: Text(variant.shortLabel),
                  subtitle: Text(
                    displayText(variant.name),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: variant.id == selectedVariant?.id
                      ? const Icon(Icons.check_circle)
                      : null,
                  onTap: () => ref
                      .read(selectedRouteVariantProvider.notifier)
                      .select(variant),
                ),
              if (selectedVariant != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () =>
                          context.pushNamed(SchedulesScreen.routeName),
                      icon: const Icon(Icons.schedule),
                      label: const Text('Ver horarios'),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
