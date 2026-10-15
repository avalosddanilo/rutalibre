import '../../domain/entities/route_variant.dart';
import 'display_text.dart';

/// Un recorrido dicho como lo dice alguien en la parada: hacia dónde va.
///
/// **Por qué existe.** La lista de recorridos de una línea decía "Ramal A ·
/// Ida" y abajo "Ida: Barrio 17 de Octubre → Hipermercado Libertad". Un
/// amigo que la vio preguntó "explicame cómo va eso, porque no entiendo".
/// "Ida", "vuelta" y "ramal" son palabras de quien arma los datos; en la
/// parada la pregunta es una sola: ¿este va para donde yo voy?
///
/// **De dónde sale.** Del nombre del recorrido, que viene en formatos
/// distintos según la fuente:
/// - OSM: "Ida: Barrio Vial → Monte Alto", a veces con "(ramal A)" al final.
/// - Corrientes: "Ida: Bº Cremonte ↔ Riachuelo ↔ Puerto" — la doble flecha
///   ahí también va en orden: el último es hacia donde va.
/// - Sin flecha: "Ida: Colonia Benítez", "Ida: Chaco - Corrientes directo",
///   o solo "Ida". Ahí no se sabe el destino y no se inventa: se muestra lo
///   que hay, y el sentido abajo para distinguir las dos puntas.
class VariantText {
  const VariantText({required this.title, this.from, this.direction});

  /// "Hacia Hipermercado Libertad", o lo que diga el nombre si no tiene
  /// destino claro.
  final String title;

  /// "Barrio 17 de Octubre": de dónde sale, si el nombre lo dice.
  final String? from;

  /// "Ida" o "Vuelta", SOLO cuando el nombre no dice hacia dónde va: es lo
  /// único que separa las dos puntas de "Ida: Colonia Benítez".
  final String? direction;

  /// La línea de abajo: "Desde Barrio 17 de Octubre", más lo que se le
  /// agregue ("Ramal A").
  String? detail({String? extra}) {
    final parts = [if (from != null) 'Desde $from' else ?direction, ?extra];
    return parts.isEmpty ? null : parts.join(' · ');
  }
}

final _directionPrefix = RegExp(
  r'^(ida|vuelta)\b\s*:?\s*',
  caseSensitive: false,
);
final _branchSuffix = RegExp(
  r'\s*(\(ramal [^)]*\)|\bramal [a-z0-9]+)$',
  caseSensitive: false,
);
final _arrows = RegExp(r'\s*[→↔]\s*');

VariantText describeVariant(String name, RouteDirection direction) {
  final rest = name
      .trim()
      .replaceFirst(_directionPrefix, '')
      .replaceFirst(_branchSuffix, '')
      .trim();
  final stops = [
    for (final part in rest.split(_arrows))
      if (part.trim().isNotEmpty) part.trim(),
  ];
  if (stops.length >= 2) {
    return VariantText(
      title: 'Hacia ${displayText(stops.last)}',
      from: displayText(stops.first),
    );
  }
  return VariantText(
    title: rest.isEmpty ? direction.label : displayText(rest),
    direction: rest.isEmpty ? null : direction.label,
  );
}

/// "Ramal A", solo si la línea tiene más de un ramal: en una línea de un
/// solo recorrido, el ramal no distingue nada y es una palabra más para
/// entender.
///
/// Algunos ramales de Corrientes vienen como "C DIRECTO" o "C Bo ESPERANZA Bo
/// DR. MONTAÑA": se muestra la letra, que es lo que dice el cartel del
/// colectivo; lo demás ya lo dice el destino.
String? branchLabel(String? branch, {required bool lineHasBranches}) {
  if (branch == null || !lineHasBranches) return null;
  final letter = branch.trim().split(RegExp(r'\s+')).first;
  return letter.isEmpty ? null : 'Ramal $letter';
}
