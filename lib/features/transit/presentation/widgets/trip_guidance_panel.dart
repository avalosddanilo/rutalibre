import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../app/theme/motion.dart';
import '../providers/trip_providers.dart';
import '../utils/trip_guidance.dart';
import 'line_badge.dart';

/// El viaje paso a paso, uno por pantalla.
///
/// **Reemplaza al panel de líneas mientras dura.** No conviven: quien está
/// yendo a algún lado no está eligiendo qué colectivo mirar, y dos paneles
/// apilados abajo dejarían el mapa en una franja.
///
/// El paso se avanza A MANO. Podría avanzarse solo con el GPS —cuando te
/// acercás a la parada— pero eso pide seguir la posición todo el viaje, que
/// es batería y permisos, y equivocarse ahí es peor que no hacerlo: un paso
/// que salta solo cuando no correspondía deja a alguien mirando la
/// indicación equivocada arriba del colectivo.
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
