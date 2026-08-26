import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/widgets/staggered_in.dart';
import '../../domain/entities/fare.dart';
import '../../domain/entities/service_frequency.dart';
import '../../domain/entities/trip_plan.dart';
import '../../domain/entities/walk_estimate.dart';
import '../providers/trip_providers.dart';
import '../utils/color_hex.dart';
import '../utils/display_text.dart';
import '../utils/failure_message.dart';
import '../utils/trip_share_text.dart';
import 'line_badge.dart';

/// Las formas de llegar del origen al destino, de la mejor a la peor.
///
/// Cada opción se lee como se la contaría alguien en la calle: "tomate la 3
/// en tal esquina, bajate en tal otra". Por eso el orden de lectura es
/// caminata → colectivo → caminata, y no una tabla de datos.
class TripResultsSheet extends ConsumerWidget {
  const TripResultsSheet({required this.query, super.key});

  final TripQuery query;

  static Future<void> show(BuildContext context, {required TripQuery query}) =>
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (context) => TripResultsSheet(query: query),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final search = ref.watch(tripSearchProvider);
    // La query VIVA y no la del momento de abrir: "invertir el viaje" cambia
    // el estado con la hoja abierta, y una hoja clavada en la query vieja
    // mostraría la ida con el botón de la vuelta recién tocado.
    final liveQuery = switch (search) {
      TripRoute(:final query) => query,
      _ => query,
    };
    final plansAsync = ref.watch(tripPlansProvider(liveQuery));
    // Solo cuando el origen se eligió A MANO. Con el GPS no hace falta
    // decirlo —es lo que todo el mundo asume— pero un viaje calculado desde
    // un punto que la persona escribió hace media hora no se entiende sin
    // esto, y menos todavía si la respuesta es "no encontramos cómo llegar".
    final originName = switch (search) {
      TripRoute(:final originName) => originName,
      _ => null,
    };

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 8, 8),
              child: Row(
                children: [
                  const Icon(Icons.alt_route),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Cómo llegar',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  // "¿Y para volver?" es la pregunta que sigue a cualquier
                  // viaje. Un toque da vuelta origen y destino y la lista se
                  // recalcula sola — la vuelta puede ser OTRO colectivo, o el
                  // mismo por otra calle, y por eso no alcanza con releer la
                  // ida al revés.
                  // PERO NO con la guía andando: invertir suelta el viaje
                  // elegido, y soltar el viaje mata la guía y borra su
                  // guardado — un toque, sin confirmación, arriba del
                  // colectivo. "Para volver" es de después de llegar.
                  if (ref.watch(tripGuidanceProvider) == null)
                    IconButton(
                      icon: const Icon(Icons.swap_vert),
                      tooltip: 'Invertir el viaje (para volver)',
                      onPressed: () =>
                          ref.read(tripSearchProvider.notifier).swap(),
                    ),
                ],
              ),
            ),
            if (originName != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.trip_origin,
                      size: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Desde $originName',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            // El aviso de lluvia NO se repite acá: vive en el chip del mapa,
            // que esta hoja no tapa (llega hasta el 70% de la pantalla). Dos
            // avisos del mismo hecho a treinta píxeles uno del otro se leen
            // como un error de la app, no como énfasis.
            Flexible(
              child: plansAsync.when(
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
                            ref.invalidate(tripPlansProvider(liveQuery)),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
                data: (plans) =>
                    plans.isEmpty ? const _NoTrips() : _TripList(plans: plans),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Vacío NO es un error: puede que de verdad no haya cómo, y decirlo con
/// claridad (y por qué) es mejor que un cartel genérico.
class _NoTrips extends StatelessWidget {
  const _NoTrips();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.wrong_location_outlined,
          size: 40,
          color: Theme.of(context).colorScheme.outline,
        ),
        const SizedBox(height: 12),
        Text(
          'No encontramos cómo llegar con un colectivo ni con un transbordo.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Puede que no haya paradas cerca de alguna de las dos puntas, o '
          'que el viaje necesite más de un transbordo.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    ),
  );
}

class _TripList extends ConsumerWidget {
  const _TripList({required this.plans});

  final List<TripPlan> plans;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final directCount = plans.where((p) => p.isDirect).length;

    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: plans.length + 1,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              directCount == 0
                  ? 'Sin línea directa: todas necesitan un transbordo'
                  : directCount == 1
                  ? '1 línea te lleva directo'
                  : '$directCount líneas te llevan directo',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          );
        }
        // Escalonados: los viajes vienen ordenados de mejor a peor, y que
        // aparezcan en ese orden lo dice sin escribirlo.
        return StaggeredIn(
          index: index - 1,
          child: _TripTile(plan: plans[index - 1]),
        );
      },
    );
  }
}

class _TripTile extends ConsumerWidget {
  const _TripTile({required this.plan});

  final TripPlan plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final selected = ref.watch(selectedTripProvider) == plan;
    final search = ref.watch(tripSearchProvider);

    return InkWell(
      // Tocar un viaje lo dibuja en el mapa y cierra la hoja: la respuesta
      // útil es el mapa, no la lista.
      onTap: () {
        ref.read(selectedTripProvider.notifier).select(plan);
        Navigator.of(context).pop();
      },
      child: Container(
        color: selected
            ? scheme.secondaryContainer.withValues(alpha: 0.4)
            : null,
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                for (var i = 0; i < plan.legs.length; i++) ...[
                  if (i > 0) ...[
                    const SizedBox(width: 6),
                    Icon(
                      Icons.arrow_right_alt,
                      size: 18,
                      color: scheme.outline,
                    ),
                    const SizedBox(width: 6),
                  ],
                  LineBadge(
                    code: plan.legs[i].displayCode,
                    colorHex: plan.legs[i].colorHex,
                    size: 34,
                  ),
                ],
                const Spacer(),
                _Chip(
                  icon: Icons.directions_walk,
                  label: plan.formattedWalk,
                  emphasis: plan.walkTotalMeters > 800,
                ),
                // Compartir va ACÁ y no solo en el botón flotante del mapa:
                // ese aparecía únicamente después de TOCAR una opción, así
                // que quien miraba la lista y cerraba nunca lo veía. Éste
                // está justo al lado del viaje que uno está leyendo.
                if (search is TripRoute)
                  IconButton(
                    icon: const Icon(Icons.ios_share, size: 20),
                    tooltip: 'Compartir este viaje',
                    onPressed: () => SharePlus.instance.share(
                      ShareParams(
                        text: tripShareText(
                          plan,
                          destinationLat: search.destination.lat,
                          destinationLng: search.destination.lng,
                        ),
                        subject: 'Mi viaje en colectivo',
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            _TripSummary(plan: plan),
            const SizedBox(height: 10),
            for (var i = 0; i < plan.legs.length; i++)
              _LegSteps(leg: plan.legs[i], isFirst: i == 0),
            const SizedBox(height: 2),
            _Step(
              icon: Icons.flag,
              color: scheme.outline,
              text:
                  'Caminás ${_meters(plan.walkFromAlightMeters)} '
                  'hasta tu destino',
            ),
          ],
        ),
      ),
    );
  }
}

/// Los pasos de un tramo: dónde subirse, cuánto viajar, dónde bajarse.
class _LegSteps extends StatelessWidget {
  const _LegSteps({required this.leg, required this.isFirst});

  final TripLeg leg;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    final color = colorFromHex(leg.colorHex) ?? Theme.of(context).primaryColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Step(
          icon: isFirst
              ? Icons.directions_walk
              : Icons.transfer_within_a_station,
          color: Theme.of(context).colorScheme.outline,
          text: isFirst
              ? 'Tomás la ${leg.displayCode} en ${leg.boardStop.name}'
              : 'Te cambiás a la ${leg.displayCode} en la misma parada',
        ),
        _Step(
          icon: Icons.directions_bus,
          color: color,
          text: leg.stopCount == 1
              ? 'Viajás 1 parada'
              : 'Viajás ${leg.stopCount} paradas',
          subtitle: displayText(leg.variantName),
        ),
        _Step(
          icon: Icons.logout,
          color: color,
          text: 'Bajás en ${leg.alightStop.name}',
        ),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.icon,
    required this.color,
    required this.text,
    this.subtitle,
  });

  final IconData icon;
  final Color color;
  final String text;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text, style: Theme.of(context).textTheme.bodyMedium),
              if (subtitle != null)
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label, this.emphasis = false});

  final IconData icon;
  final String label;

  /// Resalta cuando el número deja de ser un detalle y pasa a ser un
  /// problema — una caminata de más de ocho cuadras hay que verla venir.
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final foreground = emphasis
        ? scheme.onErrorContainer
        : scheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: emphasis
            ? scheme.errorContainer
            : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: foreground),
          ),
        ],
      ),
    );
  }
}

String _meters(double meters) {
  if (meters < 1000) return '${meters.round()} m';
  return '${(meters / 1000).toStringAsFixed(1).replaceAll('.', ',')} km';
}

/// El resumen del viaje en un renglón: caminata, paradas y cuánto sale.
///
/// **Lo que NO dice, y es lo que más se extraña: cuánto tarda.** Google Maps
/// pone "25 min" porque sabe a qué velocidad va el colectivo y cada cuánto
/// pasa. Nosotros no tenemos ninguna de las dos cosas —hay horarios de UNA
/// línea de 32, y frecuencia regulada de tres ramales del 904, que además es
/// una obligación y no una medición—, así que un tiempo total sería un número
/// inventado con cara de dato. Se dice lo que sí se sabe: los metros son
/// reales, las paradas las cuenta la base, y la tarifa y la frecuencia tienen
/// fecha y fuente.
///
/// La suma de tarifas es el dato que nadie te avisa: **con transbordo pagás
/// dos boletos**.
class _TripSummary extends StatelessWidget {
  const _TripSummary({required this.plan});

  final TripPlan plan;

  /// La suma de las tarifas del viaje, o null si falta alguna.
  ///
  /// Null y no "lo que se conozca": mostrar $1.885 en un viaje con transbordo
  /// del que solo sabemos una de las dos tarifas sería decirle a alguien que
  /// le alcanza con eso.
  Fare? get _total {
    var amount = 0.0;
    DateTime? oldest;
    String? source;
    for (final leg in plan.legs) {
      final fare = fareFor(
        networkCode: leg.networkCode,
        lineCode: leg.lineCode,
      );
      if (fare == null) return null;
      amount += fare.amount;
      // Se muestra la fecha MÁS VIEJA de las dos: es hasta cuándo se puede
      // garantizar que el total esté bien.
      if (oldest == null || fare.validFrom.isBefore(oldest)) {
        oldest = fare.validFrom;
        source = fare.source;
      }
    }
    if (oldest == null || source == null) return null;
    return Fare(amount: amount, validFrom: oldest, source: source);
  }

  /// La frecuencia regulada, **solo en viajes directos**.
  ///
  /// Con transbordo hay dos líneas y dos bandas distintas (o una sola, que es
  /// peor): un "cada 12 a 15 min" suelto al lado de dos números de línea no
  /// dice de cuál de los dos habla. Y la espera de un viaje con transbordo no
  /// es ninguna de las dos bandas, es la suma de dos esperas.
  ServiceFrequency? get _frequency {
    if (!plan.isDirect) return null;
    final leg = plan.legs.single;
    return frequencyFor(networkCode: leg.networkCode, lineCode: leg.lineCode);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final style = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant);
    final walk = WalkEstimate(meters: plan.walkTotalMeters);
    final stops = plan.totalStopCount;
    final total = _total;
    final frequency = _frequency;

    return DefaultTextStyle.merge(
      style: style,
      child: Wrap(
        spacing: 10,
        runSpacing: 2,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _SummaryBit(
            icon: Icons.directions_walk,
            text: walk.formattedDuration,
          ),
          _SummaryBit(
            icon: Icons.directions_bus_outlined,
            text: stops == 1 ? '1 parada' : '$stops paradas',
          ),
          if (total != null)
            _SummaryBit(
              icon: Icons.confirmation_number_outlined,
              // "x2" hace visible lo que nadie te avisa: con transbordo se
              // pagan dos boletos.
              text: plan.isDirect
                  ? total.formattedAmount
                  : '${total.formattedAmount} (2 boletos)',
              emphasis: !plan.isDirect,
            ),
          // Cada cuánto pasa, cuando la norma lo fija. Es lo más cerca de
          // "cuánto vas a esperar" que se puede decir sin inventar, y acá
          // llega el que nunca abre la pantalla de horarios. "En hora pico"
          // no se abrevia: sin eso el número promete todo el día.
          if (frequency != null)
            _SummaryBit(
              icon: Icons.av_timer,
              text: '${frequency.shortBand} en hora pico',
            ),
        ],
      ),
    );
  }
}

class _SummaryBit extends StatelessWidget {
  const _SummaryBit({
    required this.icon,
    required this.text,
    this.emphasis = false,
  });

  final IconData icon;
  final String text;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 15,
          color: emphasis ? scheme.error : scheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: emphasis
              ? TextStyle(color: scheme.error, fontWeight: FontWeight.w600)
              : null,
        ),
      ],
    );
  }
}
