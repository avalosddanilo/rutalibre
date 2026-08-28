import '../../domain/entities/street_addresses.dart';
import 'search_text.dart';

/// Una consulta "calle + altura", partida: "san juan 5240" → ("san juan",
/// 5240). Null si la consulta no termina en un número.
({String street, int number})? splitStreetAndNumber(String query) {
  final match = RegExp(r'^(.*\S)\s+(\d{1,5})\s*$').firstMatch(query.trim());
  if (match == null) return null;
  return (street: match.group(1)!, number: int.parse(match.group(2)!));
}

/// Un número de puerta encontrado para una consulta con altura.
class AddressMatch {
  const AddressMatch({
    required this.street,
    required this.point,
    required this.requested,
  });

  final StreetAddresses street;
  final AddressPoint point;

  /// El número que la persona escribió, que puede no ser el que se encontró.
  final int requested;

  /// Si el punto ES el número pedido o solo el mapeado más cercano.
  bool get exact => point.number == requested;

  /// "San Juan 5249 (Barranqueras)" — SIEMPRE con el número del PUNTO, no el
  /// pedido: mostrar "5240" sobre la coordenada del 5249 sería mentir la
  /// dirección por una casa de diferencia.
  String get displayName => street.locality.isEmpty
      ? '${street.street} ${point.number}'
      : '${street.street} ${point.number} (${street.locality})';
}

/// Hasta cuánto puede desviarse el número mapeado más cercano del pedido.
///
/// 150 de numeración ≈ una cuadra y media acá (la numeración avanza ~100
/// por cuadra). Más lejos que eso ya no es "tu casa, la puerta de al lado":
/// es otra cuadra, y ofrecerla como si fuera la dirección confundiría más
/// de lo que ayuda — para eso está la calle entera con el mapa.
const nearestNumberTolerance = 150;

/// Busca la altura en las calles con números mapeados.
///
/// La calle se matchea con el mismo espíritu del buscador general: igual,
/// por prefijo, o palabra por palabra ("colon" encuentra "Cristóbal Colón").
/// El número: exacto si está; si no, el mapeado más cercano dentro de
/// [nearestNumberTolerance]. Puede devolver varias — una por localidad,
/// cuando la calle existe en más de una — ordenadas por qué tan bien matchea
/// la calle y qué tan cerca quedó el número.
List<AddressMatch> searchAddresses({
  required String query,
  required List<StreetAddresses> streets,
  int limit = 4,
}) {
  final parts = splitStreetAndNumber(query);
  if (parts == null) return const [];
  final normalizedQuery = normalizeForSearch(parts.street);
  if (normalizedQuery.isEmpty) return const [];

  final scored = <(int, int, AddressMatch)>[];
  for (final street in streets) {
    final rank = _streetRank(
      normalizeForSearch(street.street),
      normalizedQuery,
    );
    if (rank == null) continue;
    final point = _nearestNumber(street.numbers, parts.number);
    if (point == null) continue;
    final delta = (point.number - parts.number).abs();
    if (delta > nearestNumberTolerance) continue;
    scored.add((
      rank,
      delta,
      AddressMatch(street: street, point: point, requested: parts.number),
    ));
  }

  scored.sort((a, b) {
    final byRank = a.$1.compareTo(b.$1);
    if (byRank != 0) return byRank;
    final byDelta = a.$2.compareTo(b.$2);
    if (byDelta != 0) return byDelta;
    return a.$3.street.locality.compareTo(b.$3.street.locality);
  });

  return [for (final entry in scored.take(limit)) entry.$3];
}

/// Qué tan bien matchea la calle, de mejor a peor; null si no matchea.
int? _streetRank(String street, String query) {
  if (street == query) return 0;
  if (street.startsWith(query)) return 1;
  // Palabra por palabra: cada palabra de la consulta tiene que ser prefijo
  // de ALGUNA palabra del nombre. "colon" → "cristobal colon"; "j roca" →
  // "julio argentino roca". Es lo que salva escribir el nombre a medias.
  final streetWords = street.split(' ');
  final allMatch = query
      .split(' ')
      .every((q) => streetWords.any((w) => w.startsWith(q)));
  return allMatch ? 2 : null;
}

/// El punto con el número más cercano al pedido. [numbers] viene ordenado.
AddressPoint? _nearestNumber(List<AddressPoint> numbers, int requested) {
  if (numbers.isEmpty) return null;
  AddressPoint? best;
  var bestDelta = 1 << 30;
  for (final point in numbers) {
    final delta = (point.number - requested).abs();
    if (delta < bestDelta) {
      best = point;
      bestDelta = delta;
    }
    // Ordenados: cuando el número ya pasó al pedido y la distancia empieza a
    // crecer, no va a mejorar.
    if (point.number > requested && delta > bestDelta) break;
  }
  return best;
}
