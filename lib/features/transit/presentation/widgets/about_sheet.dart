import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/diagnostics/diagnostics_log.dart';

/// La versión instalada ("1.3.0 (6)"), o null si la plataforma no la da.
final appVersionProvider = FutureProvider<String?>((ref) async {
  try {
    final info = await PackageInfo.fromPlatform();
    return '${info.version} (${info.buildNumber})';
  } on Object {
    return null;
  }
});

/// "Acerca de Ruta Libre": versión, web, privacidad y el diagnóstico.
///
/// Se abre tocando la marca arriba del mapa. Existe sobre todo por
/// "Enviar diagnóstico": cuando alguien dice que la alarma no sonó, es la
/// forma de saber qué pasó en SU teléfono sin meter rastreadores. Lo que se
/// manda lo elige la persona y sale por la app que ella elija.
class AboutSheet extends ConsumerWidget {
  const AboutSheet({super.key});

  static const webUrl = 'https://rutalibreapp.com.ar';
  static const privacyUrl =
      'https://avalosddanilo.github.io/rutalibre-privacidad/';

  static Future<void> show(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => const AboutSheet(),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final version = ref.watch(appVersionProvider).value;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ruta Libre', style: theme.textTheme.titleLarge),
            if (version != null)
              Text('Versión $version', style: theme.textTheme.bodySmall),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.public),
              title: const Text('Todas las líneas en la web'),
              subtitle: const Text('rutalibreapp.com.ar'),
              onTap: () => _open(webUrl),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text('Política de privacidad'),
              onTap: () => _open(privacyUrl),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.bug_report_outlined),
              title: const Text('Enviar diagnóstico'),
              subtitle: const Text(
                '¿La alarma no sonó o algo falló? Mandanos el registro de la '
                'app: viaje, alarma, permisos y errores. Nunca tu ubicación.',
              ),
              onTap: () => _share(ref, version),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _clear(context, ref),
                child: const Text('Borrar registro'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _open(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } on Object {
      // Sin navegador no hay nada que hacer; la hoja sigue abierta.
    }
  }

  static Future<void> _share(WidgetRef ref, String? version) async {
    final text = ref.read(diagnosticsLogProvider).export(version: version);
    await SharePlus.instance.share(
      ShareParams(
        text: 'Para: hola@rutalibreapp.com.ar\n\n$text',
        subject: 'Diagnóstico de Ruta Libre',
      ),
    );
  }

  static Future<void> _clear(BuildContext context, WidgetRef ref) async {
    await ref.read(diagnosticsLogProvider).clear();
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Registro borrado')));
  }
}
