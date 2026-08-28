import 'dart:math' as math;

/// Qué clase de lugar es. Define el ícono y sirve para desempatar cuando dos
/// cosas se llaman parecido.
///
/// Es una lista CORTA a propósito: no es una taxonomía de OSM, es "cómo lo
/// nombra la gente cuando dice a dónde va". Nadie dice "voy al
/// `amenity=doctors`", dice "voy al médico".
enum PlaceKind {
  salud,
  educacion,
  compras,
  transporte,
  gobierno,
  plaza,
  deporte,
  cultura,
  iglesia,

  /// Una calle con nombre. No sale de un tag como los demás: la arma
  /// `street_import.dart` desde los ways de OSM, para que "San Juan 5240"
  /// encuentre la calle aunque ninguna parada se llame así.
  calle,
  otro,
}

/// Un lugar al que alguien puede querer ir.
typedef ImportedPlace = ({String name, double lat, double lng, PlaceKind kind});

/// El tag de OSM → nuestra categoría.
///
/// Lo que NO está acá no entra. Es la lista blanca, no una lista negra: OSM
/// tiene miles de valores y la mayoría no son destinos (un buzón, un banco de
/// plaza, una boca de incendio).
const _kindByTag = <String, PlaceKind>{
  'amenity=hospital': PlaceKind.salud,
  'amenity=clinic': PlaceKind.salud,
  'amenity=doctors': PlaceKind.salud,
  'amenity=pharmacy': PlaceKind.salud,
  'amenity=school': PlaceKind.educacion,
  'amenity=university': PlaceKind.educacion,
  'amenity=college': PlaceKind.educacion,
  'amenity=kindergarten': PlaceKind.educacion,
  'shop=mall': PlaceKind.compras,
  'shop=supermarket': PlaceKind.compras,
  'shop=department_store': PlaceKind.compras,
  'amenity=marketplace': PlaceKind.compras,
  'amenity=bus_station': PlaceKind.transporte,
  'public_transport=station': PlaceKind.transporte,
  'amenity=townhall': PlaceKind.gobierno,
  'amenity=police': PlaceKind.gobierno,
  'amenity=courthouse': PlaceKind.gobierno,
  'amenity=post_office': PlaceKind.gobierno,
  'office=government': PlaceKind.gobierno,
  'leisure=park': PlaceKind.plaza,
  'leisure=stadium': PlaceKind.deporte,
  'leisure=sports_centre': PlaceKind.deporte,
  'tourism=museum': PlaceKind.cultura,
  'tourism=attraction': PlaceKind.cultura,
  'amenity=theatre': PlaceKind.cultura,
  'amenity=cinema': PlaceKind.cultura,
  'amenity=library': PlaceKind.cultura,
  'amenity=place_of_worship': PlaceKind.iglesia,
  'amenity=bank': PlaceKind.otro,
  'amenity=community_centre': PlaceKind.otro,
  'landuse=cemetery': PlaceKind.otro,
};

/// El orden en que se miran los tags. Importa cuando un elemento trae varios:
/// un shopping etiquetado `shop=mall` + `amenity=marketplace` es un shopping.
const _tagOrder = [
  'amenity',
  'shop',
  'leisure',
  'tourism',
  'landuse',
  'office',
  'public_transport',
];

PlaceKind? kindFor(Map<String, String> tags) {
  for (final key in _tagOrder) {
    final value = tags[key];
    if (value == null) continue;
    final kind = _kindByTag['$key=$value'];
    if (kind != null) return kind;
  }
  return null;
}

/// Un elemento crudo de Overpass, ya aplanado.
typedef RawPlace = ({
  String? name,
  double? lat,
  double? lng,
  Map<String, String> tags,
});

/// Cuánto tienen que estar cerca dos cosas del mismo nombre para ser la misma.
///
/// 150 m. OSM mapea la misma escuela como el nodo del edificio Y como el way
/// del terreno; las dos vienen en la respuesta y son una sola escuela. Más
/// lejos que eso ya son dos sucursales distintas —"Farmacia del Pueblo" hay
/// una en cada barrio— y las dos tienen que quedar.
const dedupeMeters = 150.0;

/// Área urbana real del Gran Resistencia: (sur, norte, oeste, este).
///
/// El bbox del importador de recorridos es más grande porque tiene que
/// abarcar el corredor hasta Corrientes. Para lugares eso mete cientos de
/// escuelas rurales a 40 km, a las que nadie llega en colectivo urbano.
const urbanBounds = (south: -27.53, north: -27.38, west: -59.08, east: -58.75);

bool insideUrbanArea(double lat, double lng) =>
    lat > urbanBounds.south &&
    lat < urbanBounds.north &&
    lng > urbanBounds.west &&
    lng < urbanBounds.east;

/// Normaliza para comparar nombres: sin tildes, sin puntuación, sin dobles
/// espacios. "Hospital Perrando" y "Hospital  PERRANDO." son el mismo.
String normalizeName(String name) {
  const from = 'áàäâãéèëêíìïîóòöôõúùüûñç';
  const to = 'aaaaaeeeeiiiiooooouuuunc';
  final lower = name.toLowerCase();
  final buffer = StringBuffer();
  for (final rune in lower.runes) {
    final ch = String.fromCharCode(rune);
    final index = from.indexOf(ch);
    final mapped = index >= 0 ? to[index] : ch;
    if (RegExp(r'[a-z0-9 ]').hasMatch(mapped)) {
      buffer.write(mapped);
    } else {
      buffer.write(' ');
    }
  }
  return buffer.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
}

double metersBetween(double lat1, double lng1, double lat2, double lng2) {
  const metersPerDegree = 111320.0;
  final dLat = (lat1 - lat2) * metersPerDegree;
  final dLng = (lng1 - lng2) * metersPerDegree * math.cos(lat1 * math.pi / 180);
  return math.sqrt(dLat * dLat + dLng * dLng);
}

/// Lo que quedó afuera y por qué. Se reporta: un importador que descarta en
/// silencio esconde los errores de la fuente.
typedef PlaceImportReport = ({
  int total,
  int sinNombre,
  int sinCoordenada,
  int categoriaDesconocida,
  int fueraDelArea,
  int duplicados,
});

typedef PlaceImportResult = ({
  List<ImportedPlace> places,
  PlaceImportReport report,
});

/// Filtra, categoriza y deduplica los elementos crudos.
PlaceImportResult buildPlaces(Iterable<RawPlace> raw) {
  var sinNombre = 0;
  var sinCoordenada = 0;
  var categoriaDesconocida = 0;
  var fueraDelArea = 0;
  var duplicados = 0;
  var total = 0;

  final candidates = <ImportedPlace>[];
  for (final element in raw) {
    total++;
    final name = element.name?.trim();
    if (name == null || name.isEmpty) {
      sinNombre++;
      continue;
    }
    final lat = element.lat;
    final lng = element.lng;
    if (lat == null || lng == null || !lat.isFinite || !lng.isFinite) {
      sinCoordenada++;
      continue;
    }
    final kind = kindFor(element.tags);
    if (kind == null) {
      categoriaDesconocida++;
      continue;
    }
    if (!insideUrbanArea(lat, lng)) {
      fueraDelArea++;
      continue;
    }
    candidates.add((name: name, lat: lat, lng: lng, kind: kind));
  }

  // Dedup por nombre normalizado + cercanía. Se agrupa por nombre primero
  // para no comparar todos contra todos: con ~2600 lugares eso son 3,4
  // millones de distancias.
  final byName = <String, List<ImportedPlace>>{};
  final kept = <ImportedPlace>[];
  for (final place in candidates) {
    final key = normalizeName(place.name);
    final sameName = byName.putIfAbsent(key, () => []);
    final isDuplicate = sameName.any(
      (other) =>
          metersBetween(other.lat, other.lng, place.lat, place.lng) <
          dedupeMeters,
    );
    if (isDuplicate) {
      duplicados++;
      continue;
    }
    sameName.add(place);
    kept.add(place);
  }

  // Orden estable: por nombre normalizado. El archivo generado tiene que dar
  // el mismo diff dos corridas seguidas, si no cada regeneración ensucia el
  // repo con 2600 líneas movidas.
  kept.sort((a, b) {
    final byNameCompare = normalizeName(
      a.name,
    ).compareTo(normalizeName(b.name));
    if (byNameCompare != 0) return byNameCompare;
    return a.lat.compareTo(b.lat);
  });

  return (
    places: kept,
    report: (
      total: total,
      sinNombre: sinNombre,
      sinCoordenada: sinCoordenada,
      categoriaDesconocida: categoriaDesconocida,
      fueraDelArea: fueraDelArea,
      duplicados: duplicados,
    ),
  );
}

/// El JSON que se empaqueta con la app.
///
/// Claves de una letra y coordenadas a cinco decimales (~1 m): el archivo se
/// lee entero en memoria y cada byte de más es memoria del teléfono. Con
/// nombres completos serían 240 KB; así queda cerca de la mitad.
Map<String, Object?> encodePlaces(List<ImportedPlace> places) => {
  'v': 1,
  'p': [
    for (final place in places)
      {
        'n': place.name,
        'y': double.parse(place.lat.toStringAsFixed(5)),
        'x': double.parse(place.lng.toStringAsFixed(5)),
        'k': place.kind.name,
      },
  ],
};
