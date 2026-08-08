import 'package:flutter_test/flutter_test.dart';

import '../../tools/src/route_parser.dart';

/// Todos los casos salen de los datos REALES del Gran Resistencia en OSM.
void main() {
  group('splitCodeAndBranch', () {
    test('número + letra = línea + ramal', () {
      expect(splitCodeAndBranch('3A'), (code: '3', branch: 'A'));
      expect(splitCodeAndBranch('106C'), (code: '106', branch: 'C'));
      expect(splitCodeAndBranch('8D'), (code: '8', branch: 'D'));
    });

    test('solo número = línea sin ramal', () {
      expect(splitCodeAndBranch('101'), (code: '101', branch: null));
      expect(splitCodeAndBranch('204'), (code: '204', branch: null));
    });

    test('nombre + letra suelta = ramal ("Tirol A")', () {
      expect(splitCodeAndBranch('Tirol A'), (code: 'Tirol', branch: 'A'));
    });

    test('código con guion no se parte ("RES-CB")', () {
      expect(splitCodeAndBranch('RES-CB'), (code: 'RES-CB', branch: null));
    });
  });

  group('parseRoute: sentido', () {
    test('lo toma del nombre', () {
      final ida = parseRoute(
        osmRelationId: 1,
        ref: '3A',
        name: '3A Ida Vial - Shopping Sarmiento',
      );
      expect(ida.direction, ParsedDirection.outbound);

      final vuelta = parseRoute(
        osmRelationId: 2,
        ref: '3A',
        name: '3A Vuelta Shopping Sarmiento - Barrio Vial',
      );
      expect(vuelta.direction, ParsedDirection.inbound);
    });

    test('lo toma del ref cuando el nombre no lo dice ("904B Ida")', () {
      final parsed = parseRoute(
        osmRelationId: 3,
        ref: '904B Ida',
        name: 'Chaco - Corrientes directo',
      );
      expect(parsed.direction, ParsedDirection.outbound);
      expect(parsed.lineCode, '904');
      expect(parsed.branch, 'B');
    });

    test('sentido al final del nombre ("... Puerto Tirol Vuelta")', () {
      final parsed = parseRoute(
        osmRelationId: 4,
        ref: 'Tirol A',
        name: 'Resistencia - Puerto Tirol Vuelta',
      );
      expect(parsed.direction, ParsedDirection.inbound);
      expect(parsed.lineCode, 'Tirol');
      expect(parsed.branch, 'A');
      expect(parsed.origin, 'Resistencia');
      expect(parsed.destination, 'Puerto Tirol');
    });

    test('null cuando no hay ningún indicio', () {
      final parsed = parseRoute(osmRelationId: 5, ref: '904A', name: null);
      expect(parsed.direction, isNull);
    });
  });

  group('parseRoute: el nombre le gana al ref cuando se contradicen', () {
    test('ref=207 con nombre "206 Vuelta ..." se importa como 206', () {
      // Caso REAL en OSM: la relation 5427218 está tagueada ref=207 pero se
      // llama "206 Vuelta Resistencia - Barranqueras". Confiar en el ref
      // metería el recorrido en la línea equivocada.
      final parsed = parseRoute(
        osmRelationId: 6,
        ref: '207',
        name: '206 Vuelta Resistencia - Barranqueras',
      );
      expect(parsed.lineCode, '206');
      expect(parsed.direction, ParsedDirection.inbound);
      expect(parsed.warnings, hasLength(1));
      expect(parsed.warnings.single, contains('no coincide'));
    });

    test('sin contradicción no hay advertencia', () {
      final parsed = parseRoute(
        osmRelationId: 7,
        ref: '207',
        name: '207 Ida Fontana - Barranqueras',
      );
      expect(parsed.lineCode, '207');
      expect(parsed.warnings, isEmpty);
    });
  });

  group('parseRoute: extremos y nombre del recorrido', () {
    test('separa cabecera y destino del nombre', () {
      final parsed = parseRoute(
        osmRelationId: 8,
        ref: '110',
        name: '110 Ida Los Cisnes - La Toma',
      );
      expect(parsed.origin, 'Los Cisnes');
      expect(parsed.destination, 'La Toma');
      expect(parsed.variantName, 'Ida: Los Cisnes → La Toma');
    });

    test('cae a los tags from/to si el nombre no alcanza', () {
      final parsed = parseRoute(
        osmRelationId: 9,
        ref: '101',
        name: '101 Ida',
        fromTag: 'Barranqueras',
        toTag: 'Barrio Santa Inés',
      );
      expect(parsed.origin, 'Barranqueras');
      expect(parsed.destination, 'Barrio Santa Inés');
      expect(parsed.variantName, 'Ida: Barranqueras → Barrio Santa Inés');
    });

    test('sin extremos usa lo que quede del nombre', () {
      final parsed = parseRoute(
        osmRelationId: 10,
        ref: 'RES-CB',
        name: 'Colonia Benítez Ida',
      );
      expect(parsed.lineCode, 'RES-CB');
      expect(parsed.variantName, 'Ida: Colonia Benítez');
    });

    test('sin nombre ni tags igual produce algo mostrable', () {
      final parsed = parseRoute(osmRelationId: 11, ref: '904A', name: null);
      expect(parsed.variantName, 'Recorrido');
    });
  });

  group('red y orden', () {
    test('la que cruza a Corrientes tiene su propia red', () {
      expect(networkCodeFor('904'), networkChacoCorrientes);
    });

    test('el interurbano que NO sale del Chaco va aparte', () {
      // Colonia Benítez y Puerto Tirol estaban metidos en la red
      // "Chaco – Corrientes" y no cruzan el Paraná: quien abre esa red
      // quiere cruzar, no ir a Puerto Tirol.
      expect(networkCodeFor('Tirol'), networkInterurbanoChaco);
      expect(networkCodeFor('RES-CB'), networkInterurbanoChaco);
    });

    test('las urbanas van al Gran Resistencia', () {
      expect(networkCodeFor('3'), networkGranResistencia);
      expect(networkCodeFor('110'), networkGranResistencia);
    });

    test('orden natural: 3 antes que 110, nominales al final', () {
      expect(sortOrderFor('3'), lessThan(sortOrderFor('110')));
      expect(sortOrderFor('9'), lessThan(sortOrderFor('12')));
      expect(sortOrderFor('110'), lessThan(sortOrderFor('Tirol')));
    });

    test('un código con letra cae junto a su número, no al final', () {
      // Desde que el interurbano promueve el ramal a línea existen "904A",
      // "904B" y "904C", y tienen que quedar juntos y en orden.
      expect(sortOrderFor('904'), lessThan(sortOrderFor('904A')));
      expect(sortOrderFor('904A'), lessThan(sortOrderFor('904B')));
      expect(sortOrderFor('904C'), lessThan(sortOrderFor('905')));
      expect(sortOrderFor('904C'), lessThan(sortOrderFor('Tirol')));
    });
  });

  group('identidad de línea', () {
    test('cruzando el puente el ramal ES la línea', () {
      // "Chaco – Corrientes directo" y "por Barranqueras" son servicios
      // distintos, no dos formas de tomarse el mismo colectivo.
      expect(lineIdentityFor('904', 'B'), (lineCode: '904B', branch: null));
    });

    test('en el Gran Resistencia el ramal sigue siendo ramal', () {
      // La regla de siempre: nadie espera "la 3A", espera la 3.
      expect(lineIdentityFor('3', 'A'), (lineCode: '3', branch: 'A'));
    });

    test('sin ramal no cambia nada', () {
      expect(lineIdentityFor('904', null), (lineCode: '904', branch: null));
      expect(lineIdentityFor('110', null), (lineCode: '110', branch: null));
    });
  });
}
