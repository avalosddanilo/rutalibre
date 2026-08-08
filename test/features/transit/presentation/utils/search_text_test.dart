import 'package:flutter_test/flutter_test.dart';
import 'package:rutalibre/features/transit/presentation/utils/search_text.dart';

void main() {
  group('normalizeForSearch', () {
    test('baja a minúsculas y saca tildes', () {
      expect(normalizeForSearch('Barrio PERÓN'), 'barrio peron');
      expect(normalizeForSearch('Fontana'), 'fontana');
    });

    test('normaliza la ñ y la ç', () {
      expect(normalizeForSearch('Ñandú'), 'nandu');
    });

    test('colapsa espacios de más', () {
      expect(normalizeForSearch('  Puerto   Vilelas '), 'puerto vilelas');
    });
  });

  group('matchesSearch', () {
    test('encuentra sin tilde lo que está escrito con tilde', () {
      // El caso real: nadie escribe "Perón" con tilde en la parada.
      expect(matchesSearch('Barrio Perón ↔ Puerto Vilelas', 'peron'), isTrue);
    });

    test('encuentra por número de línea', () {
      expect(matchesSearch('110', '110'), isTrue);
      expect(matchesSearch('110', '11'), isTrue);
    });

    test('una búsqueda vacía no filtra nada', () {
      expect(matchesSearch('cualquier cosa', ''), isTrue);
      expect(matchesSearch('cualquier cosa', '   '), isTrue);
    });

    test('no encuentra lo que no está', () {
      expect(matchesSearch('Fontana ↔ Barranqueras', 'corrientes'), isFalse);
    });
  });
}
