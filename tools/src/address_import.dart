import 'street_import.dart';
import 'place_import.dart';

/// Un punto con dirección de OSM, ya aplanado: `addr:street` +
/// `addr:housenumber` y su coordenada (el centro, si era un edificio).
typedef RawAddress = ({
  String? street,
  String? housenumber,
  double? lat,
  double? lng,
});

/// Los números de puerta mapeados de UNA calle en UNA localidad, listos
/// para el asset: (número, lat, lng) ordenados por número.
typedef ImportedStreetAddresses = ({
  String street,
  String locality,
  List<(int, double, double)> numbers,
});

typedef AddressImportReport = ({
  int total,
  int sinCalle,
  int sinNumero,
  int sinCoordenada,
  int fueraDelArea,
  int duplicados,
  int calles,
  int numeros,
});

typedef AddressImportResult = ({
  List<ImportedStreetAddresses> streets,
  AddressImportReport report,
});

/// De los puntos con dirección de OSM al índice de alturas del buscador.
///
/// **Existe porque "¿o eso es re exhaustivo?" tenía respuesta: no.** El área
/// tiene ~58.000 direcciones con número mapeadas (importes catastrales a
/// OSM), así que "San Juan 5240" puede caer en la cuadra REAL sin inventar
/// nada — que era la única razón para no hacerlo. Donde el número exacto no
/// está, el buscador ofrece el mapeado más cercano Y LO DICE; interpolar
/// entre dos números sería volver a inventar.
///
/// El agrupado es el mismo de las calles ([buildStreets]): por nombre
/// normalizado + localidad más cercana, porque el 5240 de la San Juan de
/// Barranqueras no tiene nada que ver con la San Juan del centro.
AddressImportResult buildAddresses(
  Iterable<RawAddress> raw,
  List<Locality> localities,
) {
  var total = 0;
  var sinCalle = 0;
  var sinNumero = 0;
  var sinCoordenada = 0;
  var fueraDelArea = 0;
  var duplicados = 0;

  // (calle normalizada, índice de localidad) → puntos numerados.
  final groups =
      <
        (String, int),
        List<({String street, int number, double lat, double lng})>
      >{};

  for (final address in raw) {
    total++;
    final street = address.street?.trim();
    if (street == null || street.isEmpty) {
      sinCalle++;
      continue;
    }
    // El número ENTERO del principio: "5240 bis" cuenta como 5240; "S/N" no
    // cuenta. Cinco dígitos alcanzan — la numeración más alta del área anda
    // por los 9000.
    final number = _leadingNumber(address.housenumber);
    if (number == null) {
      sinNumero++;
      continue;
    }
    final lat = address.lat;
    final lng = address.lng;
    if (lat == null || lng == null || !lat.isFinite || !lng.isFinite) {
      sinCoordenada++;
      continue;
    }
    if (!insideUrbanArea(lat, lng)) {
      fueraDelArea++;
      continue;
    }
    final key = (normalizeName(street), _nearestLocality(localities, lat, lng));
    groups.putIfAbsent(key, () => []).add((
      street: street,
      number: number,
      lat: lat,
      lng: lng,
    ));
  }

  final streets = <ImportedStreetAddresses>[];
  for (final entry in groups.entries) {
    final members = entry.value
      // Orden determinista ANTES de deduplicar: regenerar sin cambios en la
      // fuente tiene que dar diff vacío, y "cuál de los dos 5240 queda" no
      // puede depender del orden en que Overpass contestó.
      ..sort((a, b) {
        final byNumber = a.number.compareTo(b.number);
        if (byNumber != 0) return byNumber;
        final byLat = a.lat.compareTo(b.lat);
        if (byLat != 0) return byLat;
        return a.lng.compareTo(b.lng);
      });

    // Un punto por número: la esquina Y el edificio pueden traer el mismo
    // 5240, y son la misma puerta.
    final numbers = <(int, double, double)>[];
    int? lastNumber;
    for (final m in members) {
      if (m.number == lastNumber) {
        duplicados++;
        continue;
      }
      lastNumber = m.number;
      numbers.add((m.number, m.lat, m.lng));
    }

    // La grafía mayoritaria, como en las calles.
    final tally = <String, int>{};
    for (final m in members) {
      tally[m.street] = (tally[m.street] ?? 0) + 1;
    }
    var displayName = members.first.street;
    var bestCount = 0;
    for (final e in tally.entries) {
      if (e.value > bestCount ||
          (e.value == bestCount && e.key.compareTo(displayName) < 0)) {
        displayName = e.key;
        bestCount = e.value;
      }
    }

    final localityIndex = entry.key.$2;
    streets.add((
      street: displayName,
      locality: localityIndex < 0 ? '' : localities[localityIndex].name,
      numbers: numbers,
    ));
  }

  streets.sort((a, b) {
    final byName = normalizeName(a.street).compareTo(normalizeName(b.street));
    if (byName != 0) return byName;
    return a.locality.compareTo(b.locality);
  });

  var numeros = 0;
  for (final s in streets) {
    numeros += s.numbers.length;
  }

  return (
    streets: streets,
    report: (
      total: total,
      sinCalle: sinCalle,
      sinNumero: sinNumero,
      sinCoordenada: sinCoordenada,
      fueraDelArea: fueraDelArea,
      duplicados: duplicados,
      calles: streets.length,
      numeros: numeros,
    ),
  );
}

int? _leadingNumber(String? housenumber) {
  if (housenumber == null) return null;
  final match = RegExp(r'^\s*(\d{1,5})').firstMatch(housenumber);
  if (match == null) return null;
  return int.parse(match.group(1)!);
}

/// El mismo criterio que las calles (ver [buildStreets]); duplicado corto
/// antes que acoplar los dos módulos por seis líneas.
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

/// El JSON del asset de alturas: claves de una letra y arrays pelados, que
/// con ~58.000 puntos cada byte de más son 58 KB de más.
Map<String, Object?> encodeAddresses(List<ImportedStreetAddresses> streets) => {
  'v': 1,
  's': [
    for (final s in streets)
      [
        s.street,
        s.locality,
        [
          for (final (number, lat, lng) in s.numbers)
            [
              number,
              double.parse(lat.toStringAsFixed(5)),
              double.parse(lng.toStringAsFixed(5)),
            ],
        ],
      ],
  ],
};
