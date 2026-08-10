import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/service_frequency.dart';

/// "Cada 10 a 12 min en hora pico" — la frecuencia REGULADA de la línea.
///
/// Es la mejor respuesta que hay hoy a "¿cuándo pasa?" para las líneas sin
/// horarios cargados, y la única que se puede dar con una fuente oficial
/// arriba de la mesa. Pero es un dato delicado y por eso el renglón se toca:
/// atrás hay tres cosas que decir y que no entran en una línea —que es una
/// obligación y no una medición, que el pliego no define qué horas son "pico",
/// y de qué norma sale—, y decirlas a medias sería peor que no decirlas.
///
/// Si la línea no tiene banda regulada no dibuja nada. Estimar una a partir
/// del largo del recorrido sería inventar un horario con otro nombre.
class FrequencyRow extends StatelessWidget {
  const FrequencyRow({required this.frequency, super.key});

  final ServiceFrequency? frequency;

  @override
  Widget build(BuildContext context) {
    final frequency = this.frequency;
    if (frequency == null) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Material(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _showDetails(context, frequency),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Icon(Icons.av_timer, size: 18, color: scheme.onSurfaceVariant),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        frequency.shortBand,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        // "Frecuencia regulada" y no "frecuencia": la palabra
                        // sola se leería como "cada 12 minutos viene uno".
                        'frecuencia regulada ${frequency.scope}',
                        style: textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  frequency.formattedValidity,
                  style: textTheme.labelSmall?.copyWith(color: scheme.outline),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(width: 6),
                Icon(Icons.info_outline, size: 16, color: scheme.outline),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void _showDetails(BuildContext context, ServiceFrequency frequency) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      // Son cinco párrafos: en una pantalla corta —landscape, o el texto del
      // sistema agrandado— no entran. Sin esto la hoja desborda y el último
      // párrafo, que es justamente la fuente, no se puede leer.
      isScrollControlled: true,
      builder: (context) => _FrequencyDetails(frequency: frequency),
    );
  }
}

/// Todo lo que el renglón no puede decir.
///
/// El orden es a propósito: primero qué significa el número, después qué NO
/// significa. Quien cierra la hoja después del primer párrafo se queda con la
/// idea correcta.
class _FrequencyDetails extends StatelessWidget {
  const _FrequencyDetails({required this.frequency});

  final ServiceFrequency frequency;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: ConstrainedBox(
        // El mismo tope que el resto de las hojas de la app.
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.7,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.av_timer, color: scheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Frecuencia regulada',
                      style: textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'La norma que rige el permiso de esta línea exige un servicio '
                '${frequency.formattedBand} ${frequency.scope}.',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Text(
                // La distinción que hace que este dato sea honesto y no una
                // promesa: es lo que la empresa DEBE hacer.
                'Es lo que la empresa está obligada a cumplir, no una medición '
                'de lo que pasa hoy en la calle.',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Tampoco es un horario: no dice a qué hora sale el primero ni el '
                'último, qué pasa fuera de la hora pico, ni qué horas son "pico" '
                '— la norma no lo define. Los cuadros horarios reales existen, '
                'los aprueba la CNRT y no se publican.',
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              // La fuente al final y completa: es lo que separa este número de
              // un rumor, y tiene que poder verificarlo cualquiera.
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.gavel, size: 16, color: scheme.outline),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Fuente: ${frequency.source}. '
                      '${frequency.permitNote}',
                      style: textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
