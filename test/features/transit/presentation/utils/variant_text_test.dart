import 'package:flutter_test/flutter_test.dart';
import 'package:rutalibre/features/transit/domain/entities/route_variant.dart';
import 'package:rutalibre/features/transit/presentation/utils/display_text.dart';
import 'package:rutalibre/features/transit/presentation/utils/variant_text.dart';

const _ida = RouteDirection.outbound;
const _vuelta = RouteDirection.inbound;

/// Sin el selector invisible de `displayText`, para comparar fácil.
String _plain(String s) => s.replaceAll('︎', '');

void main() {
  group('hacia dónde va, con los nombres que hay en la base', () {
    // Todos estos son nombres reales de route_variants.
    final cases = <(String, RouteDirection, String, String?)>[
      // OSM, Gran Resistencia: la línea 9 que no entendió el amigo.
      (
        'Ida: Barrio 17 de Octubre → Hipermercado Libertad',
        _ida,
        'Hacia Hipermercado Libertad',
        'Desde Barrio 17 de Octubre',
      ),
      (
        'Vuelta: Hipermercado Libertad → Villa Don Alberto',
        _vuelta,
        'Hacia Villa Don Alberto',
        'Desde Hipermercado Libertad',
      ),
      // Con el ramal repetido al final.
      (
        'Ida: Carpincho Macho → Villa Prosperidad (ramal A)',
        _ida,
        'Hacia Villa Prosperidad',
        'Desde Carpincho Macho',
      ),
      (
        'Ida: Resistencia → Puerto Tirol Ramal B',
        _ida,
        'Hacia Puerto Tirol',
        'Desde Resistencia',
      ),
      // El 904B después de la 0020: la "Ida" va de Corrientes a Resistencia.
      (
        'Ida: Corrientes → Resistencia, directo',
        _ida,
        'Hacia Resistencia, directo',
        'Desde Corrientes',
      ),
      // Corrientes: doble flecha, y a veces una parada en el medio.
      (
        'Vuelta: Puerto ↔ Riachuelo ↔ Cremonte',
        _vuelta,
        'Hacia Cremonte',
        'Desde Puerto',
      ),
      // Sin destino claro: se muestra lo que hay, con el sentido abajo.
      ('Ida: Colonia Benítez', _ida, 'Colonia Benítez', 'Ida'),
      ('Vuelta: Colonia Benítez', _vuelta, 'Colonia Benítez', 'Vuelta'),
      (
        'Ida: Chaco - Corrientes directo',
        _ida,
        'Chaco - Corrientes directo',
        'Ida',
      ),
      ('Ida', _ida, 'Ida', null),
    ];

    for (final (name, direction, title, detail) in cases) {
      test(name, () {
        final text = describeVariant(name, direction);
        expect(_plain(text.title), title);
        expect(text.detail(), detail);
      });
    }
  });

  test('las flechas que quedan se ven como texto, no como emoji', () {
    // "Chaco ↔ Corrientes" sin destino claro no existe, pero un nombre con
    // una flecha suelta sí podría: pasa por displayText igual.
    final text = describeVariant('Ida: A → B', _ida);
    expect(text.title, displayText('Hacia B'));
  });

  group('el ramal', () {
    test('solo si la línea tiene más de uno', () {
      expect(branchLabel('A', lineHasBranches: true), 'Ramal A');
      expect(branchLabel('A', lineHasBranches: false), isNull);
      expect(branchLabel(null, lineHasBranches: true), isNull);
    });

    test('de los ramales largos de Corrientes, la letra del cartel', () {
      expect(
        branchLabel('C Bo ESPERANZA Bo DR. MONTAÑA', lineHasBranches: true),
        'Ramal C',
      );
      expect(branchLabel('A COLECTORA', lineHasBranches: true), 'Ramal A');
    });

    test('va al lado de "Desde …"', () {
      final text = describeVariant('Ida: Vial → Monte Alto', _ida);
      expect(text.detail(extra: 'Ramal C'), 'Desde Vial · Ramal C');
    });
  });
}
