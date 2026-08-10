import 'package:flutter/material.dart';

import '../../domain/entities/reference_stop.dart';
import 'line_badge.dart';
import 'osm_stop_link.dart';

/// Qué líneas paran en una parada de Corrientes capital.
///
/// **Es más chica que `StopDetailsSheet` a propósito, y dice menos.** De
/// estas paradas sabemos dos cosas —dónde están y qué líneas paran— y no
/// tenemos ni los recorridos completos ni el orden de las paradas, así que
/// no se puede ofrecer "¿cómo llego acá?" ni horarios. Una hoja que ofrezca
/// botones que no funcionan es peor que una hoja corta.
class CorrientesStopSheet extends StatelessWidget {
  const CorrientesStopSheet({required this.stop, super.key});

  final ReferenceStop stop;

  static Future<void> show(BuildContext context, ReferenceStop stop) =>
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (context) => CorrientesStopSheet(stop: stop),
      );

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: scheme.primary),
                const SizedBox(width: 12),
                Expanded(child: Text(stop.name, style: textTheme.titleMedium)),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              stop.lines.length == 1 ? 'Acá para:' : 'Acá paran:',
              style: textTheme.labelLarge,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final line in stop.lines)
                  // Sin color propio: en Corrientes no tenemos el color de
                  // cada línea, y pintarlas de un color inventado las haría
                  // parecer las del Gran Resistencia, que sí lo tienen.
                  LineBadge(code: line, colorHex: '#546E7A', size: 38),
              ],
            ),
            const SizedBox(height: 18),
            // La procedencia, dicha sin vueltas. Es lo que separa "la app
            // sabe" de "alguien lo mapeó y puede estar desactualizado".
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 16, color: scheme.outline),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Según OpenStreetMap. Todavía no podemos planificar '
                    'viajes en Corrientes capital: falta la mitad de los '
                    'recorridos en los datos abiertos del municipio.',
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            // Acá el enlace pesa más que en el Gran Resistencia: estas 254
            // paradas no las cruza ningún recorrido nuestro, así que si una no
            // existe más, el único que se puede dar cuenta es quien esté
            // parado en la esquina mirando esta hoja.
            if (stop.osmNodeId case final nodeId?)
              // El tile trae su propio relleno horizontal y esta hoja ya pone
              // 20: se lo saca para que el enlace no quede indentado respecto
              // de todo lo demás.
              ListTileTheme(
                data: const ListTileThemeData(contentPadding: EdgeInsets.zero),
                child: OsmStopLink(osmNodeId: nodeId, explainSource: false),
              ),
          ],
        ),
      ),
    );
  }
}
