import 'package:flutter_test/flutter_test.dart';
import 'package:rutalibre/features/transit/presentation/utils/osm_links.dart';

void main() {
  test('el enlace apunta al nodo público de OSM', () {
    expect(
      osmNodeUrl(2286343843).toString(),
      'https://www.openstreetmap.org/node/2286343843',
    );
  });

  test(
    'https y host exacto: no es un enlace que se pueda armar a mano mal',
    () {
      final url = osmNodeUrl(1);
      expect(url.scheme, 'https');
      expect(url.host, 'www.openstreetmap.org');
      // Un id de OSM entra en int64 y los de Corrientes ya pasan los 2.000
      // millones: si esto se hubiera tipado como int32 en algún puente, se
      // notaría acá.
      expect(osmNodeUrl(9007199254740991).path, '/node/9007199254740991');
    },
  );
}
