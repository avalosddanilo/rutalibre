import 'package:flutter_test/flutter_test.dart';
import 'package:rutalibre/features/transit/domain/entities/route_variant.dart';
import 'package:rutalibre/features/transit/domain/entities/stop.dart';
import 'package:rutalibre/features/transit/domain/entities/trip_plan.dart';
import 'package:rutalibre/features/transit/presentation/utils/trip_share_text.dart';

TripLeg _leg({
  required String code,
  String? branch,
  required String board,
  required String alight,
}) => TripLeg(
  lineId: 'l-$code',
  lineCode: code,
  lineName: 'Línea $code',
  colorHex: '#F57C00',
  networkCode: 'gran-resistencia',
  networkName: 'Gran Resistencia',
  routeVariantId: 'rv-$code',
  variantName: 'Ida',
  branch: branch,
  direction: RouteDirection.outbound,
  boardStop: Stop(id: 'b-$code', name: board, lat: -27.45, lng: -58.98),
  alightStop: Stop(id: 'a-$code', name: alight, lat: -27.46, lng: -58.99),
  stopCount: 8,
);

String _share(TripPlan plan) =>
    tripShareText(plan, destinationLat: -27.4546, destinationLng: -58.9913);

void main() {
  group('tripShareText', () {
    test('un viaje directo dice qué línea, dónde subirse y dónde bajarse', () {
      final texto = _share(
        TripPlan(
          walkToBoardMeters: 120,
          walkFromAlightMeters: 200,
          legs: [
            _leg(
              code: '3',
              branch: 'A',
              board: 'Ameghino y Sáenz Peña',
              alight: 'Alberdi y Jujuy',
            ),
          ],
        ),
      );

      expect(texto, contains('Voy en la 3A.'));
      expect(texto, contains('Me tomo la 3A en Ameghino y Sáenz Peña'));
      expect(texto, contains('Me bajo en Alberdi y Jujuy'));
    });

    test('con transbordo nombra las dos y dice dónde se cambia', () {
      final texto = _share(
        TripPlan(
          walkToBoardMeters: 100,
          walkFromAlightMeters: 150,
          legs: [
            _leg(code: '9', board: 'Plaza 25 de Mayo', alight: 'Terminal'),
            _leg(code: '110', board: 'Terminal', alight: 'Los Cisnes'),
          ],
        ),
      );

      expect(texto, contains('Voy en la 9 y después la 110.'));
      expect(texto, contains('Me tomo la 9 en Plaza 25 de Mayo'));
      // El transbordo se dice como CAMBIO, no como una segunda subida
      // suelta: quien lee tiene que entender que es el mismo viaje.
      expect(texto, contains('Me cambio a la 110 en Terminal'));
      expect(texto, contains('Me bajo en Los Cisnes'));
    });

    test('incluye un enlace al destino que se abre en cualquier navegador', () {
      final texto = _share(
        TripPlan(
          walkToBoardMeters: 10,
          walkFromAlightMeters: 10,
          legs: [_leg(code: '3', board: 'A', alight: 'B')],
        ),
      );

      expect(texto, contains('openstreetmap.org'));
      expect(texto, contains('mlat=-27.454600'));
      expect(texto, contains('mlon=-58.991300'));
    });

    test('no promete nada sobre seguridad ni horarios', () {
      final texto = _share(
        TripPlan(
          walkToBoardMeters: 10,
          walkFromAlightMeters: 10,
          legs: [_leg(code: '3', board: 'A', alight: 'B')],
        ),
      ).toLowerCase();

      // Compartir el viaje avisa por dónde andás. No dice a qué hora llegás
      // (no hay horarios de casi ninguna línea) ni que el camino sea seguro.
      expect(texto, isNot(contains('llego a las')));
      expect(texto, isNot(contains('segur')));
    });
  });

  group('osmLink', () {
    test('seis decimales: más no agrega nada y alarga el enlace', () {
      expect(osmLink(-27.4519, -58.9865), contains('mlat=-27.451900'));
      expect(osmLink(-27.4519, -58.9865), contains('#map=17/'));
    });
  });
}
