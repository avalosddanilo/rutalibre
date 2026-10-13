import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/motion.dart';
import '../../../../app/widgets/floating_panel.dart';
import '../../domain/entities/service_alert.dart';
import '../providers/service_alerts_providers.dart';

/// El aviso de servicio vigente (un paro, un desvío), arriba del mapa.
///
/// Uno solo a la vista, el más nuevo: dos carteles apilados sobre el mapa
/// tapan lo que la gente vino a mirar. Tocarlo abre el detalle de todos los
/// vigentes; la X lo cierra para siempre en este teléfono.
class ServiceAlertNotice extends ConsumerWidget {
  const ServiceAlertNotice({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(visibleAlertsProvider);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // AnimatedSize por lo mismo que el resto de la barra: sin transición,
    // lo de abajo pega un salto vertical al aparecer el aviso.
    return AnimatedSize(
      duration: Motion.base,
      curve: Motion.curve,
      alignment: Alignment.topLeft,
      child: alerts.isEmpty
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.only(top: 8),
              child: FloatingPanel(
                color: scheme.errorContainer,
                radius: 12,
                padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
                onTap: () => ServiceAlertsSheet.show(context, alerts),
                child: Row(
                  children: [
                    Icon(
                      Icons.campaign_outlined,
                      size: 20,
                      color: scheme.onErrorContainer,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        alerts.first.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onErrorContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (alerts.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Text(
                          '+${alerts.length - 1}',
                          style: textTheme.labelMedium?.copyWith(
                            color: scheme.onErrorContainer,
                          ),
                        ),
                      ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      color: scheme.onErrorContainer,
                      tooltip: 'Cerrar este aviso',
                      onPressed: () => ref
                          .read(dismissedAlertsProvider.notifier)
                          .dismiss(alerts.first.id),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

/// El detalle de los avisos vigentes.
class ServiceAlertsSheet extends StatelessWidget {
  const ServiceAlertsSheet({required this.alerts, super.key});

  final List<ServiceAlert> alerts;

  static Future<void> show(BuildContext context, List<ServiceAlert> alerts) =>
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (context) => ServiceAlertsSheet(alerts: alerts),
      );

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final alert in alerts) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.campaign_outlined, color: scheme.error),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(alert.title, style: textTheme.titleMedium),
                  ),
                ],
              ),
              if (alert.body != null) ...[
                const SizedBox(height: 8),
                Text(alert.body!, style: textTheme.bodyMedium),
              ],
              if (alert.lineCodes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  alert.lineCodes.length == 1
                      ? 'Línea: ${alert.lineCodes.single}'
                      : 'Líneas: ${alert.lineCodes.join(', ')}',
                  style: textTheme.labelLarge,
                ),
              ],
              if (alert.endsAt case final endsAt?) ...[
                const SizedBox(height: 4),
                Text(
                  'Vale hasta el ${alertDeadline(endsAt)}',
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 20),
            ],
            // Lo que este aviso es, dicho de frente: no sale de ningún dato
            // oficial en tiempo real, lo cargó una persona.
            Text(
              'Aviso cargado por Ruta Libre. Si en la calle ves otra cosa, '
              'confiá en lo que ves.',
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "14/10 a las 22:00", en la hora del teléfono.
String alertDeadline(DateTime endsAt) {
  String two(int n) => n.toString().padLeft(2, '0');
  final local = endsAt.toLocal();
  return '${two(local.day)}/${two(local.month)} a las '
      '${two(local.hour)}:${two(local.minute)}';
}
