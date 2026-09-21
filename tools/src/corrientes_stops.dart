/// Las paradas de Corrientes capital, que el importador de recorridos tira.
///
/// **Por qué existe este archivo.** `osm_import.dart` arma las paradas
/// recorriendo `usedStopIds`: solo entran las que pertenecen a un recorrido
/// de OSM. Las líneas urbanas de Corrientes NO están mapeadas como relations
/// —el lado correntino de OSM solo tiene micros de larga distancia—, así que
/// sus 279 paradas se descartaban enteras aunque estuvieran ahí, bajadas y
/// con nombre.
///
/// **⚠️ Este importador quedó superado.** Desde que
/// `tools/corrientes_import.dart --con-paradas` carga las **1437 paradas
/// oficiales del municipio** —con ramal, sentido y orden sobre el
/// recorrido—, estas 254 de OSM son un subconjunto peor: menos, sin orden y
/// sin sentido. Ver `docs/osm-import.md`.
///
/// **Queda pendiente decidir qué pasa con el asset**: si las dos capas se
/// dibujan a la vez, en Corrientes se ven paradas duplicadas. Lo más
/// probable es que haya que retirarlo. No se tocó todavía porque es un
/// cambio de la app, no del importador.
///
/// (El comentario anterior justificaba dejarlas fuera del planificador con
/// un número mal medido —"solo 93 de 254"—, que en realidad son 202. El
/// error y su causa están en `test/tools/corrientes_cobertura_test.dart`.)
library;

/// El número de línea sale del NOMBRE de la parada.
///
/// Así está mapeado el lado correntino: la parada no tiene nombre propio,
/// tiene la lista de líneas que paran ahí — "102", "108A", "Parada 105, 109".
final _lineCodePattern = RegExp(r'\d{2,3}[A-Z]?');

/// Una parada de referencia: dónde está y qué líneas paran.
typedef ReferenceStop = ({
  int osmId,
  String name,
  double lat,
  double lng,
  List<String> lines,
});

/// Un nodo crudo de Overpass.
typedef RawStop = ({int id, double? lat, double? lng, String? name});

/// Al este de esto es Corrientes: el puente Belgrano cruza cerca de -58.85.
const corrientesWestBound = -58.85;

typedef CorrientesStopsReport = ({
  int total,
  int fueraDeCorrientes,
  int sinLineas,
  int sinNombreDerivado,
});

typedef CorrientesStopsResult = ({
  List<ReferenceStop> stops,
  CorrientesStopsReport report,
});

/// Los códigos de línea que menciona el nombre de una parada, en orden y sin
/// repetir.
List<String> lineCodesIn(String name) {
  final seen = <String>{};
  for (final match in _lineCodePattern.allMatches(name)) {
    seen.add(match[0]!);
  }
  return seen.toList()..sort();
}

/// Arma las paradas de referencia de Corrientes.
///
/// [deriveName] recibe el punto y devuelve la esquina, o null si no hay
/// calles cerca. Se inyecta para no arrastrar el índice de calles hasta acá:
/// este archivo es lógica pura y se testea sin bajar 6 MB de callejero.
CorrientesStopsResult buildCorrientesStops(
  Iterable<RawStop> raw, {
  required String? Function(double lat, double lng) deriveName,
}) {
  var total = 0;
  var fueraDeCorrientes = 0;
  var sinLineas = 0;
  var sinNombreDerivado = 0;

  final stops = <ReferenceStop>[];
  for (final node in raw) {
    total++;
    final lat = node.lat;
    final lng = node.lng;
    if (lat == null ||
        lng == null ||
        !lat.isFinite ||
        !lng.isFinite ||
        lng <= corrientesWestBound) {
      fueraDeCorrientes++;
      continue;
    }

    final lines = lineCodesIn(node.name ?? '');
    if (lines.isEmpty) {
      // Sin líneas no aporta nada: sería un punto en el mapa que no contesta
      // la única pregunta que justifica dibujarlo.
      sinLineas++;
      continue;
    }

    // El nombre de OSM es la lista de líneas, no un nombre. Se busca la
    // esquina en el callejero, que es como la gente ubica una parada.
    final derived = deriveName(lat, lng);
    if (derived == null) sinNombreDerivado++;

    stops.add((
      osmId: node.id,
      name: derived ?? 'Parada de ${lines.join(", ")}',
      lat: lat,
      lng: lng,
      lines: lines,
    ));
  }

  // Orden estable para que regenerar el asset no ensucie el diff.
  stops.sort((a, b) => a.osmId.compareTo(b.osmId));

  return (
    stops: stops,
    report: (
      total: total,
      fueraDeCorrientes: fueraDeCorrientes,
      sinLineas: sinLineas,
      sinNombreDerivado: sinNombreDerivado,
    ),
  );
}

/// El JSON que se empaqueta con la app. Claves de una letra por lo mismo que
/// en los lugares: el archivo se lee entero en memoria.
Map<String, Object?> encodeCorrientesStops(List<ReferenceStop> stops) => {
  // v2: se agrega `i`, el nodo de OSM. Es lo que permite ofrecer "corregila
  // en OpenStreetMap" desde la parada: estas 254 salen todas de un nodo real
  // y son justamente las que nadie más va a verificar.
  'v': 2,
  's': [
    for (final stop in stops)
      {
        'i': stop.osmId,
        'n': stop.name,
        'y': double.parse(stop.lat.toStringAsFixed(5)),
        'x': double.parse(stop.lng.toStringAsFixed(5)),
        'l': stop.lines,
      },
  ],
};
