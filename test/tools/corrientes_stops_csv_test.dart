// Las paradas de Corrientes: emparejar el ramal y ordenarlas sobre el
// trazado.
//
// **Los dos errores caros que estos tests vigilan**, los dos ya cometidos:
//
// 1. **Emparejar mal el ramal.** El CSV dice `105-C-250VIV` y el dataset de
//    recorridos dice `C 250 VIV.`. Meter una parada en el ramal equivocado
//    es mandar a alguien a esperar donde no pasa. Antes de este test, la
//    lista de candidatos venía con duplicados (uno por sentido) y el
//    emparejamiento "por prefijo único" no encontraba nunca nada único:
//    cuatro ramales se caían en silencio.
//
// 2. **Medir contra los vértices y no contra los segmentos.** Es el mismo
//    error que ya dio un número equivocado en `reference_stop.dart` (ver
//    `corrientes_cobertura_test.dart`). Acá se verifica que una parada en
//    mitad de una cuadra recta y larga se ubique bien.
import 'package:flutter_test/flutter_test.dart';

import '../../tools/src/corrientes_import.dart';
import '../../tools/src/corrientes_stops_csv.dart';

CorrientesVariant _variant(
  String line,
  String? branch,
  int direction,
  List<(double, double)> pts,
) => CorrientesVariant(
  lineCode: line,
  branch: branch,
  direction: direction,
  name: '$line ${branch ?? ""} ${direction == 0 ? "ida" : "vuelta"}',
  geometry: [for (final p in pts) (lat: p.$1, lng: p.$2)],
);

/// Una avenida recta de norte a sur, con UN solo vértice en cada punta.
List<(double, double)> get _avenidaRecta => [
  (-27.4600, -58.8300),
  (-27.4500, -58.8300),
];

void main() {
  group('matchBranch', () {
    const ramales105 = ['A', 'A COLECTORA', 'B', 'C 250 VIV.', 'C PERICHON'];

    test('empareja exacto ignorando espacios, puntos y mayúsculas', () {
      expect(matchBranch('105-C-250VIV', '105', ramales105), 'C 250 VIV.');
      expect(matchBranch('105-C-PERICHON', '105', ramales105), 'C PERICHON');
    });

    test('con dos que empiezan igual, gana el exacto y no el prefijo', () {
      // "A" también es prefijo de "A COLECTORA": si ganara el prefijo, las
      // paradas del ramal A se irían a la colectora.
      expect(matchBranch('105-A', '105', ramales105), 'A');
    });

    test('prefijo único cuando no hay exacto', () {
      expect(
        matchBranch('109-A', '109', ['A LAGUNA SOTO', 'B YECOHA']),
        'A LAGUNA SOTO',
      );
      expect(
        matchBranch('110-C', '110', ['A', 'B', 'C SANTA CATALINA']),
        'C SANTA CATALINA',
      );
    });

    test('por palabras cuando el nombre difiere pero se solapa', () {
      expect(
        matchBranch('103-C-ESPERANZA-MONTAÑA', '103', [
          'A',
          'B',
          'C Bo ESPERANZA Bo DR. MONTAÑA',
          'C DIRECTO',
          'D',
        ]),
        'C Bo ESPERANZA Bo DR. MONTAÑA',
      );
    });

    test('devuelve null antes que adivinar', () {
      // El 108 solo publica el ramal C: las paradas del A y el B NO se
      // meten ahí. Quedarse sin paradas es mejor que ponerlas en otra línea.
      expect(matchBranch('108-A-B', '108', ['C']), isNull);
      // Y una fila basura del dataset no empareja con nada.
      expect(matchBranch('VUELTA-ORIGINAL', 'VUELTA', ['A']), isNull);
    });

    test('no empareja si la línea no es la misma', () {
      expect(matchBranch('104-A', '105', ramales105), isNull);
    });
  });

  group('projectOnRoute', () {
    test('una parada en mitad de una cuadra larga cae en el medio', () {
      // Sin vértice intermedio: medir contra el vértice más cercano daría
      // ~550 m y la parada se descartaría. Contra el segmento da ~0.
      final ruta = [for (final p in _avenidaRecta) (lat: p.$1, lng: p.$2)];
      final (along, offset) = projectOnRoute((
        lat: -27.4550,
        lng: -58.8300,
      ), ruta);
      expect(offset, lessThan(5));
      expect(along, closeTo(556, 40)); // media cuadra de 0,01° de latitud
    });

    test('mide la distancia perpendicular, no al vértice', () {
      final ruta = [for (final p in _avenidaRecta) (lat: p.$1, lng: p.$2)];
      // 0,0005° de longitud al costado, en el medio del tramo.
      final (_, offset) = projectOnRoute((lat: -27.4550, lng: -58.8295), ruta);
      expect(offset, closeTo(49, 10));
    });
  });

  group('parseMunicipalStops', () {
    test('lee el formato con comillas simples adentro del campo', () {
      final (stops, warnings) = parseMunicipalStops(
        "gid,'tipo_recorrido','cantidad_paradas','linea_ramal','lng','lat'\n"
        "1,'VUELTA',1,'105-A','-58.77','-27.44'\n"
        "2,'IDA',2,'105-A 105-C-250VIV','-58.78','-27.46'\n",
      );
      expect(warnings, isEmpty);
      expect(stops, hasLength(2));
      expect(stops.first.direction, 1);
      expect(stops.last.direction, 0);
      expect(stops.last.ramalCodes, ['105-A', '105-C-250VIV']);
      expect(stops.last.point.lat, -27.46);
    });

    test('un sentido desconocido se reporta y no se inventa', () {
      final (stops, warnings) = parseMunicipalStops(
        "gid,'tipo_recorrido','cantidad_paradas','linea_ramal','lng','lat'\n"
        "7,'CIRCULAR',1,'105-A','-58.77','-27.44'\n",
      );
      expect(stops, isEmpty);
      expect(warnings.single, contains('CIRCULAR'));
    });
  });

  group('placeStops', () {
    List<MunicipalStop> stopsEn(List<(int, double)> lats) => [
      for (final (gid, lat) in lats)
        (
          gid: gid,
          direction: 0,
          ramalCodes: const ['9-A'],
          point: (lat: lat, lng: -58.8300),
        ),
    ];

    test('ordena por avance sobre el trazado, no por el archivo', () {
      // Llegan desordenadas a propósito: 3 antes que 1.
      final result = placeStops(
        stops: stopsEn([(3, -27.4520), (1, -27.4580), (2, -27.4550)]),
        variants: [_variant('9', 'A', 0, _avenidaRecta)],
      );
      expect(result.byVariant['9/A/0'], [1, 2, 3]);
    });

    test('una parada lejos del recorrido NO entra', () {
      final result = placeStops(
        stops: [
          ...stopsEn([(1, -27.4580), (2, -27.4550)]),
          (
            gid: 99,
            direction: 0,
            ramalCodes: const ['9-A'],
            point: (lat: -27.4550, lng: -58.8400), // ~1 km al oeste
          ),
        ],
        variants: [_variant('9', 'A', 0, _avenidaRecta)],
      );
      expect(result.byVariant['9/A/0'], [1, 2]);
      expect(result.stops.map((s) => s.gid), [1, 2]);
    });

    test(
      'el sentido importa: una parada de ida no va al recorrido de vuelta',
      () {
        final result = placeStops(
          stops: stopsEn([(1, -27.4580), (2, -27.4550)]),
          variants: [
            _variant('9', 'A', 0, _avenidaRecta),
            _variant('9', 'A', 1, _avenidaRecta),
          ],
        );
        expect(result.byVariant['9/A/0'], [1, 2]);
        expect(result.byVariant.containsKey('9/A/1'), isFalse);
      },
    );

    test('un ramal sin recorrido publicado se reporta y no se fuerza', () {
      final result = placeStops(
        stops: [
          for (final gid in [1, 2])
            (
              gid: gid,
              direction: 0,
              ramalCodes: const ['9-Z'],
              point: (lat: -27.4550, lng: -58.8300),
            ),
        ],
        variants: [_variant('9', 'A', 0, _avenidaRecta)],
      );
      expect(result.byVariant, isEmpty);
      expect(result.stops, isEmpty);
      expect(result.warnings.join(' '), contains('9-Z'));
    });

    test('no se emiten paradas que no entraron en ningún recorrido', () {
      // Porque la sección 5 del seed del Gran Resistencia desactiva toda
      // parada sin recorrido: quedarían muertas en la tabla.
      final result = placeStops(
        stops: stopsEn([(1, -27.4580)]),
        variants: [_variant('9', 'A', 0, _avenidaRecta)],
      );
      // Una sola parada no arma secuencia (hace falta al menos un par).
      expect(result.byVariant, isEmpty);
      expect(result.stops, isEmpty);
    });
  });
}
