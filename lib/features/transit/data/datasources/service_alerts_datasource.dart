import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/service_alert.dart';

/// Los avisos de servicio vigentes (migración 0016).
abstract interface class ServiceAlertsDataSource {
  Future<List<ServiceAlert>> getCurrent();
}

/// Contra la tabla `service_alerts`. La policy de la base ya filtra los
/// vigentes —activos, empezados y sin vencer—, así que acá no se repite la
/// regla: una sola fuente de verdad, y un reloj mal puesto en el teléfono
/// no puede mostrar un aviso vencido.
final class SupabaseServiceAlertsDataSource implements ServiceAlertsDataSource {
  const SupabaseServiceAlertsDataSource(this._client);

  final SupabaseClient _client;

  /// Más de tres avisos a la vez no se leen: si hubiera más, sobran.
  static const _limit = 3;

  @override
  Future<List<ServiceAlert>> getCurrent() async {
    final rows = await _client
        .from('service_alerts')
        .select('id, title, body, line_codes, ends_at')
        .order('starts_at', ascending: false)
        .limit(_limit);
    return [for (final row in rows) serviceAlertFromJson(row)];
  }
}

/// Una fila de `service_alerts` a la entidad.
ServiceAlert serviceAlertFromJson(Map<String, dynamic> json) => ServiceAlert(
  id: json['id'] as String,
  title: json['title'] as String,
  body: switch (json['body']) {
    final String body when body.trim().isNotEmpty => body.trim(),
    _ => null,
  },
  lineCodes: [
    for (final code in (json['line_codes'] as List<dynamic>?) ?? const [])
      if (code is String && code.trim().isNotEmpty) code.trim(),
  ],
  endsAt: switch (json['ends_at']) {
    final String raw => DateTime.tryParse(raw)?.toLocal(),
    _ => null,
  },
);
