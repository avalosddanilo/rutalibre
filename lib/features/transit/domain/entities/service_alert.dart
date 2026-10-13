import 'package:equatable/equatable.dart';

/// Un aviso de servicio: un paro, un desvío por obras, una línea que no
/// sale. Lo carga a mano quien mantiene la app (ver `docs/avisos.md`).
///
/// **Es lo único de la app que no sale de datos abiertos**, y por eso se
/// presenta como lo que es: un aviso de Ruta Libre, con fecha de vencimiento,
/// y la indicación de que si en la calle se ve otra cosa, manda la calle.
class ServiceAlert extends Equatable {
  const ServiceAlert({
    required this.id,
    required this.title,
    this.body,
    this.lineCodes = const [],
    this.endsAt,
  });

  final String id;

  /// Lo que se ve en el mapa: una línea.
  final String title;

  /// El detalle, al tocarlo. Puede faltar.
  final String? body;

  /// A qué líneas afecta, como se ven en la app. Vacía = a todas.
  final List<String> lineCodes;

  /// Hasta cuándo vale. Null = hasta que se apague a mano.
  final DateTime? endsAt;

  @override
  List<Object?> get props => [id, title, body, lineCodes, endsAt];
}
