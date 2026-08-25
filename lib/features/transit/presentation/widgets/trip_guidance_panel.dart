import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../app/theme/motion.dart';
import '../../domain/entities/trip_plan.dart';
import '../providers/location_providers.dart';
import '../providers/transit_providers.dart';
import '../providers/trip_providers.dart';
import '../utils/ride_progress.dart';
import '../utils/trip_guidance.dart';
import 'hail_screen.dart';
import 'line_badge.dart';

/// El viaje paso a paso, uno por pantalla.
///
/// **Reemplaza al panel de líneas mientras dura.** No conviven: quien está
/// yendo a algún lado no está eligiendo qué colectivo mirar, y dos paneles
/// apilados abajo dejarían el mapa en una franja.
///
/// El paso se avanza A MANO, aunque la guía sí sigue tu posición (ver
/// [livePositionProvider]). La distinción importa: la posición se usa para
/// INFORMAR —"faltan 3 paradas", "faltan 120 m"— y nunca para decidir por
/// vos. Un paso que salta solo cuando no correspondía deja a alguien mirando
/// la indicación equivocada arriba del colectivo; un renglón informativo
/// equivocado se ignora y ya.
class TripGuidancePanel extends ConsumerWidget {
  const TripGuidancePanel({required this.steps, super.key});

  final List<GuidanceStep> steps;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(tripGuidanceProvider);
    if (index == null || steps.isEmpty) return const SizedBox.shrink();

    final safeIndex = index.clamp(0, steps.length - 1);
    final step = steps[safeIndex];
    final isLast = safeIndex == steps.length - 1;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Material(
            color: scheme.surface,
            elevation: 6,
            shadowColor: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(AppTheme.radius),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cuántos pasos faltan, en barritas. Un "3 de 5" obliga a
                  // hacer la cuenta; las barritas se leen sin leer.
                  Row(
                    children: [
                      for (var i = 0; i < steps.length; i++) ...[
                        if (i > 0) const SizedBox(width: 4),
                        Expanded(
                          child: AnimatedContainer(
                            duration: Motion.base,
                            curve: Motion.curve,
                            height: 3,
                            decoration: BoxDecoration(
                              color: i <= safeIndex
                                  ? scheme.primary
                                  : scheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StepIcon(step: step),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Grande: esto se lee de un vistazo, parado en la
                            // vereda, sin anteojos.
                            Text(
                              step.title,
                              style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (step.detail != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                step.detail!,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  // El renglón EN VIVO: solo en los pasos donde la posición
                  // agrega algo (viajar y caminar). Si no hay GPS no se
                  // dibuja nada y el paso queda como siempre.
                  if (step case final RideStep ride)
                    _LiveRideRow(leg: ride.leg),
                  if (step case final WalkStep walk) _LiveWalkRow(step: walk),
                  // El cartel para el chofer, en los pasos donde hay que
                  // PARAR un colectivo: esperándolo, y en el transbordo (el
                  // que se para es el siguiente). De noche, la pantalla es
                  // la superficie más brillante de la vereda.
                  if (step case final BoardStep board)
                    _HailButton(leg: board.leg),
                  if (step case final TransferStep transfer)
                    _HailButton(leg: transfer.next),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () =>
                            ref.read(tripGuidanceProvider.notifier).stop(),
                        child: Text(isLast ? 'Listo' : 'Terminar'),
                      ),
                      const Spacer(),
                      if (safeIndex > 0)
                        IconButton(
                          tooltip: 'Paso anterior',
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => ref
                              .read(tripGuidanceProvider.notifier)
                              .previous(),
                        ),
                      const SizedBox(width: 4),
                      if (!isLast)
                        FilledButton.icon(
                          onPressed: () => ref
                              .read(tripGuidanceProvider.notifier)
                              .next(steps.length),
                          icon: const Icon(Icons.arrow_forward, size: 18),
                          label: const Text('Siguiente'),
                        ),
                    ],
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

/// Abre el cartel de la línea a pantalla completa.
class _HailButton extends StatelessWidget {
  const _HailButton({required this.leg});

  final TripLeg leg;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 10),
    child: SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => HailScreen.show(
          context,
          code: leg.displayCode,
          colorHex: leg.colorHex,
        ),
        icon: const Icon(Icons.front_hand, size: 18),
        label: const Text('Cartel para el chofer'),
      ),
    ),
  );
}

/// "Faltan 3 paradas" en vivo, con el aviso de bajada.
///
/// **Es la respuesta a "¿y cuándo me bajo?" sin inventar horarios.** No
/// sabemos a qué velocidad va el colectivo, pero la posición contra las
/// paradas EN ORDEN del recorrido es geometría: se muestra cuántas faltan, y
/// cuando queda una (o menos de 250 m) el renglón se enciende y el teléfono
/// vibra UNA vez. Es lo que evita viajar pegado a la ventanilla contando
/// esquinas — que es exactamente como se viaja en una ciudad que no es la
/// tuya.
///
/// Si no hay GPS, no hay permiso o la posición no cae en el tramo, no se
/// dibuja NADA: el paso queda con su texto de siempre. Un contador que
/// adivina es peor que ningún contador.
class _LiveRideRow extends ConsumerStatefulWidget {
  const _LiveRideRow({required this.leg});

  final TripLeg leg;

  @override
  ConsumerState<_LiveRideRow> createState() => _LiveRideRowState();
}

class _LiveRideRowState extends ConsumerState<_LiveRideRow> {
  /// Para vibrar UNA vez al entrar en zona de bajada, no en cada fix.
  bool _alerted = false;

  @override
  Widget build(BuildContext context) {
    final position = ref.watch(livePositionProvider).value;
    final stops = ref
        .watch(stopsForRouteProvider(widget.leg.routeVariantId))
        .value;
    if (position == null || stops == null) return const SizedBox.shrink();

    final progress = rideProgress(
      routeStops: stops,
      leg: widget.leg,
      lat: position.lat,
      lng: position.lng,
    );
    if (progress == null) {
      // Se salió de la zona del tramo: si vuelve a entrar, puede volver a
      // avisar (bajarse, caminar y volver a subir es raro pero existe).
      _alerted = false;
      return const SizedBox.shrink();
    }

    final prepare = progress.shouldPrepare;
    if (prepare && !_alerted) {
      _alerted = true;
      // Háptica y no sonido: arriba del colectivo el teléfono está en la
      // mano o el bolsillo, y un pitido compite con el ruido del motor.
      HapticFeedback.heavyImpact();
    } else if (!prepare) {
      _alerted = false;
    }

    final scheme = Theme.of(context).colorScheme;
    final text = switch (progress.stopsRemaining) {
      0 => 'Bajate en esta parada',
      1 => 'La próxima es la tuya — preparate',
      final n => 'Faltan $n paradas',
    };

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: AnimatedContainer(
        duration: Motion.base,
        curve: Motion.curve,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: prepare
              ? scheme.primaryContainer
              : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppTheme.radius),
        ),
        child: Row(
          children: [
            Icon(
              prepare ? Icons.notifications_active : Icons.gps_fixed,
              size: 18,
              color: prepare
                  ? scheme.onPrimaryContainer
                  : scheme.onSurfaceVariant,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: prepare ? FontWeight.w700 : FontWeight.w500,
                  color: prepare
                      ? scheme.onPrimaryContainer
                      : scheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Faltan ~120 m" en vivo, en los pasos de caminata.
///
/// Mismo contrato que el contador de paradas: aparece si hay posición y se
/// calla si no. El "~" no es decorativo — es línea recta, no la vereda.
class _LiveWalkRow extends ConsumerWidget {
  const _LiveWalkRow({required this.step});

  final WalkStep step;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final position = ref.watch(livePositionProvider).value;
    if (position == null) return const SizedBox.shrink();

    final meters = const Distance().as(
      LengthUnit.Meter,
      LatLng(position.lat, position.lng),
      LatLng(step.focusLat, step.focusLng),
    );
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(Icons.gps_fixed, size: 16, color: scheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            meters < 1000
                ? 'Faltan ~${meters.round()} m'
                : 'Faltan ~${(meters / 1000).toStringAsFixed(1).replaceAll('.', ',')} km',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

/// El ícono del paso. Para los que son de colectivo se usa la chapa de la
/// línea con su color, que es lo que uno busca con la vista en la calle.
class _StepIcon extends StatelessWidget {
  const _StepIcon({required this.step});

  final GuidanceStep step;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // El tramo cuyo colectivo hay que mirar en este paso, si es uno de esos.
    // En el transbordo se muestra el ramal SIGUIENTE: el que ya se viajó no
    // sirve para nada, el que hay que buscar con la vista es el otro.
    final leg = switch (step) {
      BoardStep(:final leg) => leg,
      RideStep(:final leg) => leg,
      TransferStep(:final next) => next,
      WalkStep() || ArrivalStep() => null,
    };
    if (leg != null) {
      return LineBadge(code: leg.displayCode, colorHex: leg.colorHex, size: 40);
    }

    final icon = step is ArrivalStep ? Icons.flag : Icons.directions_walk;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: scheme.onSurfaceVariant),
    );
  }
}
