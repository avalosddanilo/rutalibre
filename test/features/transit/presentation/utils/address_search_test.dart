import 'package:flutter_test/flutter_test.dart';
import 'package:rutalibre/features/transit/domain/entities/street_addresses.dart';
import 'package:rutalibre/features/transit/presentation/utils/address_search.dart';

const _sanJuanBarranqueras = StreetAddresses(
  street: 'San Juan',
  locality: 'Barranqueras',
  numbers: [
    AddressPoint(number: 5200, lat: -27.47643, lng: -58.92416),
    AddressPoint(number: 5249, lat: -27.47692, lng: -58.92359),
    AddressPoint(number: 5250, lat: -27.47698, lng: -58.92375),
  ],
);

const _sanJuanResistencia = StreetAddresses(
  street: 'San Juan',
  locality: 'Resistencia',
  numbers: [AddressPoint(number: 450, lat: -27.436, lng: -58.986)],
);

const _colon = StreetAddresses(
  street: 'Cristóbal Colón',
  locality: 'Resistencia',
  numbers: [AddressPoint(number: 1200, lat: -27.44, lng: -58.99)],
);

const _streets = [_sanJuanBarranqueras, _sanJuanResistencia, _colon];

void main() {
  group('splitStreetAndNumber', () {
    test('parte la calle de la altura', () {
      expect(splitStreetAndNumber('san juan 5240'), (
        street: 'san juan',
        number: 5240,
      ));
    });

    test('sin número al final, null: no es una consulta de altura', () {
      expect(splitStreetAndNumber('san juan'), isNull);
      expect(splitStreetAndNumber('5240'), isNull);
    });
  });

  group('searchAddresses', () {
    test('el número exacto, si está mapeado, es LA respuesta', () {
      final matches = searchAddresses(
        query: 'san juan 5200',
        streets: _streets,
      );

      expect(matches.first.exact, isTrue);
      expect(matches.first.displayName, 'San Juan 5200 (Barranqueras)');
      expect(matches.first.point.lat, -27.47643);
    });

    test('sin el exacto, el mapeado más cercano — con SU número, no el '
        'pedido', () {
      // El 5240 no está; el 5249 queda a una casa. Mostrarlo como "5240"
      // sería mentir la dirección.
      final matches = searchAddresses(
        query: 'san juan 5240',
        streets: _streets,
      );

      expect(matches.first.exact, isFalse);
      expect(matches.first.point.number, 5249);
      expect(matches.first.displayName, 'San Juan 5249 (Barranqueras)');
    });

    test('más lejos que una cuadra y media de numeración, nada', () {
      // El 9000 de una calle que llega al 5250 no es "el vecino": es otra
      // parte de la ciudad que no existe. Ofrecerla confundiría.
      final matches = searchAddresses(
        query: 'san juan 9000',
        streets: _streets,
      );

      expect(matches, isEmpty);
    });

    test('la calle homónima de la otra localidad también aparece, después', () {
      final matches = searchAddresses(query: 'san juan 450', streets: _streets);

      // El 450 exacto está en Resistencia; Barranqueras ni aparece (su
      // número más cercano, 5200, queda a miles).
      expect(matches.single.displayName, 'San Juan 450 (Resistencia)');
    });

    test('"colon 1200" encuentra "Cristóbal Colón": palabra por palabra y '
        'sin tildes', () {
      final matches = searchAddresses(query: 'colon 1200', streets: _streets);

      expect(matches.single.displayName, 'Cristóbal Colón 1200 (Resistencia)');
    });
  });
}
