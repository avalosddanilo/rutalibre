import '../../domain/entities/place.dart';
import '../../domain/entities/stop.dart';
import 'place_aliases.dart';
import 'search_text.dart';

/// Un resultado del buscador de destino: un lugar o una parada.
///
/// Los dos contestan la misma pregunta —"¿a dónde vas?"— y por eso van en una
/// sola lista en vez de en dos pestañas. Pestañas obligarían a adivinar de
/// antemano si lo que uno busca "es un lugar" o "es una parada", que es
/// exactamente lo que el usuario no sabe ni tiene por qué saber.
sealed class Destination {
  const Destination();

  String get name;
  double get lat;
  double get lng;

  /// Clave estable para "últimos destinos".
  ///
  /// Las paradas tienen uuid; los lugares no tienen id de ninguna base, así
  /// que se arma con nombre y coordenada. El prefijo evita que un lugar y una
  /// parada que casualmente compartan cadena se pisen entre sí.
  String get savedId;
}

final class PlaceDestination extends Destination {
  const PlaceDestination(this.place);

  final Place place;

  @override
  String get name => place.name;
  @override
  double get lat => place.lat;
  @override
  double get lng => place.lng;

  @override
  String get savedId =>
      'place:${place.name}@${place.lat.toStringAsFixed(5)},'
      '${place.lng.toStringAsFixed(5)}';
}

final class StopDestination extends Destination {
  const StopDestination(this.stop);

  final Stop stop;

  @override
  String get name => stop.name;
  @override
  double get lat => stop.lat;
  @override
  double get lng => stop.lng;

  @override
  String get savedId => 'stop:${stop.id}';
}

/// Qué tan bien matchea, de mejor a peor. El orden del enum ES la prioridad.
enum _MatchQuality {
  /// Lo escrito es el apodo del lugar: "utn", "unne", "terminal" (ver
  /// `place_aliases.dart`). Va primero porque es justo el caso en que el
  /// nombre oficial no ayuda.
  alias,

  /// El nombre EMPIEZA con lo escrito: "hosp" → "Hospital Perrando".
  prefix,

  /// Alguna palabra del nombre empieza con lo escrito: "perrando" →
  /// "Hospital Perrando". Es el caso más común de verdad, porque la gente
  /// escribe la parte distintiva y no el genérico de adelante.
  wordPrefix,

  /// Aparece en el medio de una palabra. Último recurso.
  contains,
}

/// "la terminal", "el llano": el artículo no ayuda a buscar.
final _article = RegExp(r'^(el|la|los|las) (.+)$');

_MatchQuality? _bestQuality(String name, String query, String bare) {
  final full = _quality(name, query);
  if (bare == query) return full;
  final withoutArticle = _quality(name, bare);
  if (full == null) return withoutArticle;
  if (withoutArticle == null) return full;
  return full.index <= withoutArticle.index ? full : withoutArticle;
}

/// Los lugares que nombra un apodo, con su orden: el apodo entero, o su
/// comienzo desde la tercera letra ("ter" ya es "terminal"). El comienzo
/// tiene que tener las mismas palabras: "hospital" solo no es "hospital
/// llano", pero "hospital ll" sí.
Map<String, int> _aliasRanks(String bare, Map<String, List<String>> aliases) {
  final words = bare.split(' ').length;
  final ranks = <String, int>{};
  for (final MapEntry(key: alias, value: names) in aliases.entries) {
    final startsLike =
        bare.length >= 3 &&
        alias.startsWith(bare) &&
        alias.split(' ').length == words;
    if (alias == bare || startsLike) {
      for (final name in names) {
        ranks.putIfAbsent(name, () => ranks.length);
      }
    }
  }
  return ranks;
}

_MatchQuality? _quality(String name, String normalizedQuery) {
  final haystack = normalizeForSearch(name);
  if (haystack.startsWith(normalizedQuery)) return _MatchQuality.prefix;
  for (final word in haystack.split(' ')) {
    if (word.startsWith(normalizedQuery)) return _MatchQuality.wordPrefix;
  }
  return haystack.contains(normalizedQuery) ? _MatchQuality.contains : null;
}

/// Busca en lugares y paradas a la vez, ordenado por qué tan bien matchea.
///
/// **Los lugares le ganan a las paradas a igualdad de match**, y no al revés:
/// quien escribe "perrando" quiere el hospital, no la parada que alguien
/// bautizó "Perrando". La parada sigue estando más abajo para el que la
/// quiera.
///
/// A igualdad de todo lo demás gana el nombre MÁS CORTO: entre "Escuela 123"
/// y "Escuela 123 Anexo Barrio Tal", el que escribió "escuela 123" quería la
/// primera.
///
/// Un apodo ("utn", "unne") pone sus lugares arriba de todo, en el orden de
/// [aliases]; el resto sigue saliendo abajo como siempre.
List<Destination> searchDestinations({
  required String query,
  required List<Place> places,
  required List<Stop> stops,
  int limit = 40,
  Map<String, List<String>> aliases = placeAliases,
}) {
  final normalized = normalizeForSearch(query);
  if (normalized.isEmpty) return const [];
  final bare = _article.firstMatch(normalized)?.group(2) ?? normalized;
  final aliasRanks = _aliasRanks(bare, aliases);

  // El tercer campo ordena dentro de cada calidad: el largo del nombre, o
  // el lugar en la lista del apodo.
  final scored = <(_MatchQuality, bool isStop, int order, Destination)>[];

  void consider(Destination destination, {required bool isStop}) {
    final quality = _bestQuality(destination.name, normalized, bare);
    if (quality == null) return;
    scored.add((quality, isStop, destination.name.length, destination));
  }

  for (final place in places) {
    final rank = aliasRanks[place.name];
    if (rank != null) {
      scored.add((_MatchQuality.alias, false, rank, PlaceDestination(place)));
    } else {
      consider(PlaceDestination(place), isStop: false);
    }
  }
  for (final stop in stops) {
    consider(StopDestination(stop), isStop: true);
    // La descripción de la parada ("Parada C03253") no se busca: es el código
    // interno de la concesionaria y matchea números sueltos con cualquier
    // cosa. El nombre derivado de la esquina es lo que la gente reconoce.
  }

  scored.sort((a, b) {
    final byQuality = a.$1.index.compareTo(b.$1.index);
    if (byQuality != 0) return byQuality;
    final byType = (a.$2 ? 1 : 0).compareTo(b.$2 ? 1 : 0);
    if (byType != 0) return byType;
    final byOrder = a.$3.compareTo(b.$3);
    if (byOrder != 0) return byOrder;
    return a.$4.name.compareTo(b.$4.name);
  });

  return [for (final entry in scored.take(limit)) entry.$4];
}
