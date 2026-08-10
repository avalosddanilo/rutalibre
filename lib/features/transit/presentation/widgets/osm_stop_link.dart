import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/osm_links.dart';

/// "¿Ya no existe esta parada?" — el enlace al nodo en OpenStreetMap.
///
/// **Por qué esto existe.** Las paradas salen de OSM, y una que se levantó en
/// la realidad pero que OSM todavía mapea es indistinguible de una vigente:
/// ningún dato nuestro la delata. El pase de unificación limpia lo que se
/// puede deducir; esto no se puede deducir. Las dos únicas salidas son que
/// alguien lo corrija en OSM o un sistema de reportes de usuarios (Fase 2), y
/// la primera cuesta un `ListTile`.
///
/// No es un botón de "reportar": no hay a dónde reportar. Es el enlace al
/// dato de origen, dicho como lo que es.
class OsmStopLink extends StatelessWidget {
  const OsmStopLink({
    required this.osmNodeId,
    this.explainSource = true,
    super.key,
  });

  final int osmNodeId;

  /// Si el renglón explica de dónde salen los datos.
  ///
  /// Se apaga donde la hoja YA lo dice —la de Corrientes abre con "Según
  /// OpenStreetMap"— porque repetirlo a dos renglones de distancia se lee como
  /// que la app duda de sí misma.
  final bool explainSource;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(
        Icons.edit_location_alt_outlined,
        color: scheme.onSurfaceVariant,
      ),
      title: Text(
        explainSource
            ? 'Ver esta parada en OpenStreetMap'
            : '¿Ya no existe, o está en otra esquina?',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      subtitle: Text(
        explainSource
            ? '¿Ya no existe, o está en otra esquina? Los datos del mapa '
                  'salen de ahí y cualquiera puede corregirlos.'
            : 'Corregila en OpenStreetMap: cualquiera puede.',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Icon(Icons.open_in_new, size: 18, color: scheme.outline),
      onTap: () => _open(context),
    );
  }

  /// Abre el navegador, y si no se puede, copia el enlace.
  ///
  /// **Sin `canLaunchUrl`**: en Android 11+ esa consulta depende de que el
  /// manifest declare visibilidad del intent, así que puede contestar "no" en
  /// un teléfono donde `launchUrl` funciona perfecto. Se intenta y se maneja
  /// el fracaso, que además cubre el caso real de un teléfono sin navegador.
  ///
  /// El plan B es el mismo que en compartir el viaje: nadie se queda sin
  /// forma de llegar al dato.
  Future<void> _open(BuildContext context) async {
    final url = osmNodeUrl(osmNodeId);
    final messenger = ScaffoldMessenger.of(context);

    var opened = false;
    try {
      opened = await launchUrl(url, mode: LaunchMode.externalApplication);
    } on Object {
      opened = false;
    }
    if (opened) return;

    await Clipboard.setData(ClipboardData(text: url.toString()));
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        const SnackBar(
          content: Text('No se pudo abrir el navegador: copiamos el enlace.'),
        ),
      );
  }
}
