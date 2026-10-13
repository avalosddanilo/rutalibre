import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/shared_preferences_provider.dart';
import '../../data/datasources/service_alerts_datasource.dart';
import '../../domain/entities/service_alert.dart';
import 'transit_providers.dart';

final serviceAlertsDataSourceProvider = Provider<ServiceAlertsDataSource>(
  (ref) => SupabaseServiceAlertsDataSource(ref.watch(supabaseClientProvider)),
);

/// Los avisos vigentes, siempre de la red.
///
/// **No se cachean** a propósito: un aviso de paro de ayer mostrado hoy sin
/// señal es peor que ningún aviso. Y **nunca falla**: sin conexión, con la
/// base sin la migración 0016 o con cualquier otro error, no hay aviso y el
/// mapa sigue como siempre. Esto es un extra; no puede ser lo que rompa la
/// pantalla principal.
final serviceAlertsProvider = FutureProvider<List<ServiceAlert>>((ref) async {
  try {
    return await ref.watch(serviceAlertsDataSourceProvider).getCurrent();
  } on Object {
    return const [];
  }
});

/// Los avisos que el usuario ya cerró, en el teléfono.
class DismissedAlertsNotifier extends Notifier<Set<String>> {
  static const _key = 'ruta_libre_dismissed_alerts_v1';

  /// Los ids se acumulan de a uno y los avisos vencen solos: con guardar los
  /// últimos veinte alcanza para no volver a mostrar uno cerrado.
  static const _keep = 20;

  @override
  Set<String> build() =>
      ref.watch(sharedPreferencesProvider).getStringList(_key)?.toSet() ?? {};

  Future<void> dismiss(String id) async {
    final next = [...state.where((other) => other != id), id];
    final kept = next.length > _keep ? next.sublist(next.length - _keep) : next;
    state = kept.toSet();
    await ref.read(sharedPreferencesProvider).setStringList(_key, kept);
  }
}

final dismissedAlertsProvider =
    NotifierProvider<DismissedAlertsNotifier, Set<String>>(
      DismissedAlertsNotifier.new,
    );

/// Los avisos vigentes que el usuario todavía no cerró, el más nuevo primero.
final visibleAlertsProvider = Provider<List<ServiceAlert>>((ref) {
  final dismissed = ref.watch(dismissedAlertsProvider);
  final alerts = ref.watch(serviceAlertsProvider).value ?? const [];
  return [
    for (final alert in alerts)
      if (!dismissed.contains(alert.id)) alert,
  ];
});
