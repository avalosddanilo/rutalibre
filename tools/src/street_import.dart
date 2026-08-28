import 'place_import.dart';

/// Una calle con nombre, tal como viene de Overpass: el CENTRO de cada way.
///
/// OSM parte una calle en decenas de ways (uno por cada cambio de velocidad,
/// de sentido, de cantidad de carriles…), así que "San Juan" llega como
/// treinta puntos desparramados a lo largo de la calle. Acá no se pide la
/// geometría completa a propósito: para el buscador alcanza con UN punto
/// representativo, y la respuesta con geometría pesa diez veces más.
typedef RawStreet = ({String? name, double? lat, double? lng});

/// Una localidad (nodo `place=city|town|village` de OSM): sirve para
/// distinguir la San Juan de Barranqueras de la San Juan del centro.
typedef Locality = ({String name, double lat, double lng});

typedef StreetImportReport = ({
  int total,
  int sinNombre,
  int sinCoordenada,
  int fueraDelArea,
  int calles,
});

typedef StreetImportResult = ({
  List<ImportedPlace> streets,
  StreetImportReport report,
});

/// De los centros de ways a UNA entrada de buscador por calle y localidad.
///
/// **Existe por una casa concreta que el buscador no encontraba**: "San Juan
/// 5240, Barranqueras". Los datos de paradas nombran esquinas, y en
/// Barranqueras ninguna esquina se llama San Juan — para quien vive ahí, la
/// app "no conocía su calle". Con las calles como entradas propias, buscarla
/// la encuentra; el punto exacto se marca después tocando el mapa.
///
/// El agrupado es por (nombre normalizado, localidad más cercana), no por
/// nombre solo: agrupar por nombre fundiría las dos San Juan en un punto a
/// mitad de camino entre ambas ciudades, que no es ninguna de las dos. El
/// costo es que una avenida que cruza localidades sale una vez por localidad
/// — y eso es una FUNCIÓN: elegir "9 de Julio (Barranqueras)" cae en el tramo
/// de Barranqueras, no en el medio geométrico de 10 km de avenida.
///
/// La localidad asignada es la del CENTRO más cercano, que en los bordes
/// entre ciudades pegadas puede equivocarse de lado. Se banca: el rótulo está
/// para separar homónimas, no para ser un padrón catastral.
StreetImportResult buildStreets(
  Iterable<RawStreet> raw,
  List<Locality> localities,
) {
  var total = 0;
  var sinNombre = 0;
  var sinCoordenada = 0;
  var fueraDelArea = 0;

  // (nombre normalizado, índice de localidad) → centros de ways.
  final groups =
      <(String, int), List<({String name, double lat, double lng})>>{};

  for (final street in raw) {
    total++;
    final name = street.name?.trim();
    if (name == null || name.isEmpty) {
      sinNombre++;
      continue;
    }
    final lat = street.lat;
    final lng = street.lng;
    if (lat == null || lng == null || !lat.isFinite || !lng.isFinite) {
      sinCoordenada++;
      continue;
    }
    if (!insideUrbanArea(lat, lng)) {
      fueraDelArea++;
      continue;
    }
    final key = (normalizeName(name), _nearestLocality(localities, lat, lng));
    groups.putIfAbsent(key, () => []).add((name: name, lat: lat, lng: lng));
  }

  final streets = <ImportedPlace>[];
  for (final entry in groups.entries) {
    final members = entry.value;

    // El punto: el centro de way más cercano al promedio del grupo. El
    // promedio pelado puede caer AFUERA de la calle (una calle en L, o dos
    // homónimas de la misma localidad fundidas en un grupo); un miembro real
    // siempre está sobre el asfalto.
    var avgLat = 0.0;
    var avgLng = 0.0;
    for (final m in members) {
      avgLat += m.lat;
      avgLng += m.lng;
    }
    avgLat /= members.length;
    avgLng /= members.length;
    var best = members.first;
    var bestMeters = metersBetween(best.lat, best.lng, avgLat, avgLng);
    for (final m in members.skip(1)) {
      final meters = metersBetween(m.lat, m.lng, avgLat, avgLng);
      if (meters < bestMeters) {
        best = m;
        bestMeters = meters;
      }
    }

    // El nombre para mostrar: el que más ways usan. La misma calle aparece
    // como "San Juan" en veinte ways y "SAN JUAN" en uno; gana la grafía
    // mayoritaria, no la del way que casualmente vino primero.
    final tally = <String, int>{};
    for (final m in members) {
      tally[m.name] = (tally[m.name] ?? 0) + 1;
    }
    var displayName = members.first.name;
    var bestCount = 0;
    for (final e in tally.entries) {
      if (e.value > bestCount ||
          (e.value == bestCount && e.key.compareTo(displayName) < 0)) {
        displayName = e.key;
        bestCount = e.value;
      }
    }

    final localityIndex = entry.key.$2;
    final label = localityIndex < 0
        ? displayName
        : '$displayName (${localities[localityIndex].name})';

    streets.add((
      name: label,
      lat: best.lat,
      lng: best.lng,
      kind: PlaceKind.calle,
    ));
  }

  // Mismo orden estable que los lugares: regenerar sin cambios en la fuente
  // tiene que dar diff vacío.
  streets.sort((a, b) {
    final byName = normalizeName(a.name).compareTo(normalizeName(b.name));
    if (byName != 0) return byName;
    return a.lat.compareTo(b.lat);
  });

  return (
    streets: streets,
    report: (
      total: total,
      sinNombre: sinNombre,
      sinCoordenada: sinCoordenada,
      fueraDelArea: fueraDelArea,
      calles: streets.length,
    ),
  );
}

/// Índice de la localidad más cercana, o -1 si no hay ninguna (la respuesta
/// de Overpass pudo venir vacía: mejor calles sin rótulo que sin calles).
int _nearestLocality(List<Locality> localities, double lat, double lng) {
  var best = -1;
  var bestMeters = double.infinity;
  for (var i = 0; i < localities.length; i++) {
    final meters = metersBetween(
      localities[i].lat,
      localities[i].lng,
      lat,
      lng,
    );
    if (meters < bestMeters) {
      best = i;
      bestMeters = meters;
    }
  }
  return best;
}
