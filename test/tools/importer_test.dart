import 'package:flutter_test/flutter_test.dart';

import '../../tools/src/geometry.dart';
import '../../tools/src/importer.dart';
import '../../tools/src/sql_emitter.dart';

/// Nodos de una grilla chica: 0.001° ≈ 111 m, suficiente para separar
/// paradas distintas sin que el colapsado de plataformas las una.
Map<int, GeoPoint> _nodes() => {
  for (var i = 1; i <= 20; i++) i: (lat: -27.45, lng: -58.98 + i * 0.001),
  // 101 está a ~5 m del nodo 1: es su plataforma PTv2.
  101: (lat: -27.45, lng: -58.98 + 0.001 + 0.00005),
};

OsmRelation _relation({
  required int id,
  required String ref,
  String? name,
  List<int> wayIds = const [1],
  List<(int, String)> stops = const [],
}) => OsmRelation(
  id: id,
  tags: {'route': 'bus', 'ref': ref, 'name': ?name},
  members: [
    for (final (node, role) in stops)
      OsmMember(type: 'node', ref: node, role: role),
    for (final way in wayIds) OsmMember(type: 'way', ref: way, role: ''),
  ],
);

OsmInput _input(
  List<OsmRelation> relations, {
  Map<int, List<int>>? ways,
  Map<int, Map<String, String>>? tags,
  Map<int, GeoPoint> extraNodes = const {},
}) => OsmInput(
  relations: relations,
  wayNodes:
      ways ??
      {
        1: [1, 2, 3, 4],
        2: [4, 5, 6],
      },
  nodePoints: {..._nodes(), ...extraNodes},
  nodeTags: tags ?? const {},
);

/// El way 1 va de oeste a este por la latitud -27.45, así que manejando por
/// la derecha el lado bueno es el SUR (latitud más negativa).
/// 0.00015° ≈ 17 m: adentro de los 25 m de tolerancia, y lejos de los 8 m
/// que se perdonan hacia la izquierda.
const _rightSideStop = (lat: -27.45015, lng: -58.9775);
const _leftSideStop = (lat: -27.44985, lng: -58.9775);

void main() {
  group('filtrado de relations', () {
    test('descarta las que no tienen ref (larga distancia) y lo reporta', () {
      final result = buildImport(
        _input([
          OsmRelation(
            id: 1,
            tags: const {'route': 'bus', 'name': 'Buenos Aires - Corrientes'},
            members: const [OsmMember(type: 'way', ref: 1, role: '')],
          ),
          _relation(id: 2, ref: '110', name: '110 Ida A - B'),
        ]),
      );

      expect(result.variants, hasLength(1));
      expect(result.skipped, hasLength(1));
      expect(result.skipped.single, contains('Buenos Aires'));
    });

    test('descarta las que quedan sin geometría', () {
      final result = buildImport(
        _input([
          _relation(id: 1, ref: '110', name: '110 Ida A - B', wayIds: [99]),
        ]),
      );
      expect(result.variants, isEmpty);
      expect(result.skipped.single, contains('sin geometría'));
    });
  });

  group('paradas que OSM no declara', () {
    // El agujero que arregla esto: la 110 y la 204 pasan por Avenida San
    // Martín y no figuraban en paradas donde el 206 y el 207 sí, porque
    // nadie las agregó como miembros de la relation. Depender de eso es
    // depender de que un voluntario haya hecho un trabajo repetitivo 3261
    // veces sin saltearse ninguna.
    test('se adopta la que el trazado deja a su DERECHA', () {
      final result = buildImport(
        _input(
          [_relation(id: 1, ref: '110', name: '110 Ida A - B')],
          extraNodes: const {201: _rightSideStop},
          tags: const {
            201: {'highway': 'bus_stop'},
          },
        ),
      );

      expect(result.variants.single.stopOsmIds, contains(201));
      expect(
        result.warnings.join(' '),
        contains('se INFIRIERON de la geometría'),
      );
    });

    test('NO se adopta la de enfrente, que es del que va en contramano', () {
      final result = buildImport(
        _input(
          [_relation(id: 1, ref: '110', name: '110 Ida A - B')],
          extraNodes: const {202: _leftSideStop},
          tags: const {
            202: {'highway': 'bus_stop'},
          },
        ),
      );

      expect(result.variants.single.stopOsmIds, isNot(contains(202)));
    });

    test('no inventa: solo usa nodos que ya son parada en OSM', () {
      final result = buildImport(
        _input(
          [_relation(id: 1, ref: '110', name: '110 Ida A - B')],
          extraNodes: const {201: _rightSideStop},
          // Mismo lugar, pero sin tags de parada: es un poste cualquiera.
          tags: const {
            201: {'amenity': 'bench'},
          },
        ),
      );

      expect(result.variants.single.stopOsmIds, isEmpty);
    });
  });

  group('líneas', () {
    test('los ramales se agrupan bajo UNA línea', () {
      final result = buildImport(
        _input([
          _relation(id: 1, ref: '3A', name: '3A Ida Vial - Shopping'),
          _relation(id: 2, ref: '3A', name: '3A Vuelta Shopping - Vial'),
          _relation(id: 3, ref: '3B', name: '3B Ida Vial - Los Troncos'),
          _relation(id: 4, ref: '3B', name: '3B Vuelta Los Troncos - Vial'),
        ]),
      );

      expect(result.lines, hasLength(1));
      expect(result.lines.single.code, '3');
      expect(result.variants, hasLength(4));
      expect(result.variants.map((v) => v.branch).toSet(), {'A', 'B'});
    });

    test('el nombre de la línea sale de la cabecera común y los destinos', () {
      final result = buildImport(
        _input([
          _relation(id: 1, ref: '3A', name: '3A Ida Vial - Shopping'),
          _relation(id: 2, ref: '3B', name: '3B Ida Vial - Los Troncos'),
        ]),
      );
      expect(result.lines.single.name, 'Vial ↔ Los Troncos / Shopping');
    });

    test('las líneas se separan por red', () {
      final result = buildImport(
        _input([
          _relation(id: 1, ref: '110', name: '110 Ida A - B'),
          _relation(
            id: 2,
            ref: 'Tirol A',
            name: 'Resistencia - Puerto Tirol Ida',
          ),
        ]),
      );
      expect(result.lines.map((l) => l.networkCode).toSet(), {
        'gran-resistencia',
        // Puerto Tirol no cruza a Corrientes: red propia.
        'interurbano-chaco',
      });
    });

    test('cruzando a Corrientes cada ramal es una línea', () {
      final result = buildImport(
        _input([
          _relation(id: 1, ref: '904B Ida', name: 'Chaco - Corrientes directo'),
          _relation(
            id: 2,
            ref: '904C Ida',
            name: 'Chaco - Corrientes x Barranqueras',
          ),
        ]),
      );

      // Dos LÍNEAS, no una con dos ramales: son servicios distintos y el
      // pasajero los pide por separado.
      expect(result.lines.map((l) => l.code).toSet(), {'904B', '904C'});
      expect(result.variants.every((v) => v.branch == null), isTrue);
    });

    test('el corredor a Corrientes se nombra como lo pide la gente', () {
      final result = buildImport(
        _input([
          _relation(id: 1, ref: '904B Ida', name: 'Chaco - Corrientes directo'),
        ]),
      );

      final line = result.lines.single;
      // OSM lo llama "directo"; en la calle es "el Sarmiento" porque va por
      // Avenida Sarmiento. Y "Sarmiento" tiene que ser buscable.
      expect(line.name, 'Chaco ↔ Corrientes por Avenida Sarmiento');
      expect(line.destinations, contains('Sarmiento'));
    });

    test('el color es estable entre corridas', () {
      final first = buildImport(
        _input([_relation(id: 1, ref: '110', name: '110 Ida A - B')]),
      );
      final second = buildImport(
        _input([_relation(id: 1, ref: '110', name: '110 Ida A - B')]),
      );
      expect(first.lines.single.colorHex, second.lines.single.colorHex);
    });
  });

  group('sentido', () {
    test('cuando falta, se asigna por descarte dentro del ramal', () {
      final result = buildImport(
        _input([
          _relation(id: 1, ref: '904A'), // sin nombre → sentido desconocido
          _relation(id: 2, ref: '904A'),
        ]),
      );

      expect(result.variants.map((v) => v.direction).toList(), [0, 1]);
      expect(
        result.warnings.where((w) => w.contains('por descarte')),
        hasLength(2),
      );
    });

    test('respeta el sentido declarado y completa el que falta', () {
      final result = buildImport(
        _input([
          _relation(id: 1, ref: '5A', name: '5A Vuelta B - A'),
          _relation(id: 2, ref: '5A'), // desconocido
        ]),
      );

      final byId = {for (final v in result.variants) v.osmRelationId: v};
      expect(byId[1]!.direction, 1);
      expect(byId[2]!.direction, 0);
    });
  });

  group('paradas', () {
    test('colapsa el par stop_position + platform de la misma parada', () {
      final result = buildImport(
        _input(
          [
            _relation(
              id: 1,
              ref: '110',
              name: '110 Ida A - B',
              stops: [(1, 'stop'), (101, 'platform'), (2, 'stop')],
            ),
          ],
          tags: {
            101: {'name': 'Plaza 25 de Mayo', 'public_transport': 'platform'},
          },
        ),
      );

      // Los nodos 1 y 101 están a 5 m: es una sola parada.
      expect(result.variants.single.stopOsmIds, [101, 2]);
      expect(
        result.stops.firstWhere((s) => s.osmNodeId == 101).name,
        'Plaza 25 de Mayo',
      );
    });

    test('no repite una parada por la que se pasa dos veces (circular)', () {
      final result = buildImport(
        _input([
          _relation(
            id: 1,
            ref: '110',
            name: '110 Ida A - B',
            wayIds: [1, 2], // el trazado llega hasta el nodo 6
            stops: [(1, 'stop'), (5, 'stop'), (6, 'stop'), (1, 'stop')],
          ),
        ]),
      );
      // `route_stops` tiene unique(variant, stop): la repetición rompería.
      expect(result.variants.single.stopOsmIds, [1, 5, 6]);
    });

    test('ordena por avance sobre el TRAZADO, no por el orden de miembros', () {
      // En los datos reales de OSM los miembros vienen en bloques (todas
      // las plataformas y después todas las posiciones), no en orden de
      // paso: confiar en ese orden dejaba secuencias yendo y viniendo.
      final result = buildImport(
        _input([
          _relation(
            id: 1,
            ref: '110',
            name: '110 Ida A - B',
            wayIds: [1, 2],
            // Deliberadamente desordenados respecto del recorrido.
            stops: [(6, 'stop'), (2, 'stop'), (4, 'stop')],
          ),
        ]),
      );
      expect(result.variants.single.stopOsmIds, [2, 4, 6]);
    });

    test('descarta una parada que quedó lejísimos del trazado', () {
      // Un error de tagueo no debe inventar una secuencia que no existe.
      final result = buildImport(
        _input([
          _relation(
            id: 1,
            ref: '110',
            name: '110 Ida A - B',
            // El trazado llega al nodo 4; el 20 está a ~1,8 km de ahí.
            stops: [(2, 'stop'), (20, 'stop')],
          ),
        ]),
      );
      expect(result.variants.single.stopOsmIds, [2]);
    });

    test('parada sin nombre queda igual usable', () {
      final result = buildImport(
        _input([
          _relation(
            id: 1,
            ref: '110',
            name: '110 Ida A - B',
            stops: [(3, 'stop')],
          ),
        ]),
      );
      expect(result.stops.single.name, 'Parada sin nombre');
    });

    test('sin nombre pero con ref usa el ref', () {
      final result = buildImport(
        _input(
          [
            _relation(
              id: 1,
              ref: '110',
              name: '110 Ida A - B',
              stops: [(3, 'stop')],
            ),
          ],
          tags: {
            3: {'ref': 'A-42'},
          },
        ),
      );
      expect(result.stops.single.name, 'Parada A-42');
    });

    test('unifica la misma parada usada por DOS recorridos distintos, uno '
        'por la calzada y el otro por la vereda', () {
      // Es el caso que el colapsado por recorrido no podía ver: si la 110
      // usa el `stop_position` y la 111 usa el `platform` de la misma
      // esquina, la tabla `stops` terminaba con dos paradas a 5 m.
      final result = buildImport(
        _input(
          [
            _relation(
              id: 1,
              ref: '110',
              name: '110 Ida A - B',
              stops: [(1, 'stop'), (2, 'stop')],
            ),
            _relation(
              id: 2,
              ref: '111',
              name: '111 Ida A - B',
              stops: [(101, 'platform'), (2, 'stop')],
            ),
          ],
          tags: {
            1: {'public_transport': 'stop_position', 'ref': 'C001'},
            101: {'public_transport': 'platform', 'name': 'Plaza 25 de Mayo'},
          },
        ),
      );

      final parada = result.stops.firstWhere((s) => s.osmNodeId == 101);
      expect(result.stops.map((s) => s.osmNodeId), [2, 101]);
      // Gana la plataforma (la vereda), pero el nombre y el código de la
      // concesionaria se juntan de los DOS nodos: quedarse con uno solo
      // perdía la mitad de la información.
      expect(parada.name, 'Plaza 25 de Mayo');
      expect(parada.description, 'Parada C001');
      for (final variant in result.variants) {
        expect(variant.stopOsmIds, [101, 2]);
      }
      expect(
        result.warnings,
        contains(startsWith('1 nodos de OSM eran una segunda representación')),
      );
    });
  });

  group('SQL generado', () {
    test('es una sola transacción y respeta el orden de dependencias', () {
      final result = buildImport(
        _input([
          _relation(
            id: 1,
            ref: '110',
            name: '110 Ida A - B',
            stops: [(1, 'stop'), (5, 'stop')],
          ),
        ]),
      );
      final sql = emitSql(result, generatedAt: '2026-08-05T00:00:00Z');

      expect(sql, contains('begin;'));
      expect(sql.trimRight(), contains('commit;'));
      expect(
        sql.indexOf('into public.lines'),
        lessThan(sql.indexOf('into public.route_variants')),
      );
      expect(
        sql.indexOf('into public.stops'),
        lessThan(sql.indexOf('into public.route_stops')),
      );
      expect(sql, contains('on conflict'));
    });

    test('escapa las comillas simples de los nombres', () {
      expect(sqlString("Barrio D'Onofrio"), "'Barrio D''Onofrio'");
      expect(sqlString(null), 'null');
    });

    test('el WKT usa el orden lng lat (no al revés)', () {
      final wkt = lineStringWkt(const [
        (lat: -27.45, lng: -58.98),
        (lat: -27.46, lng: -58.99),
      ]);
      expect(wkt, 'LINESTRING(-58.980000 -27.450000, -58.990000 -27.460000)');
    });

    test('deja el diagnóstico como comentarios al final', () {
      final result = buildImport(
        _input([
          OsmRelation(
            id: 9,
            tags: const {'route': 'bus', 'name': 'Corrientes - Mocoretá'},
            members: const [OsmMember(type: 'way', ref: 1, role: '')],
          ),
          _relation(id: 1, ref: '110', name: '110 Ida A - B'),
        ]),
      );
      final sql = emitSql(result, generatedAt: '2026-08-05T00:00:00Z');
      expect(sql, contains('DIAGNÓSTICO'));
      expect(sql, contains('Mocoretá'));
    });
  });
}
