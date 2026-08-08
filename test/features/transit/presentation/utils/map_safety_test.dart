import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:rutalibre/features/transit/presentation/utils/map_safety.dart';

/// **`LatLng` NO valida nada**: acepta NaN, Infinity y latitudes de 91 sin
/// chistar. Por eso un dato roto puede viajar adentro de un `LatLng` hasta el
/// fondo de flutter_map, y por eso existe `map_safety.dart`.
LatLng _raw(double lat, double lng) => LatLng(lat, lng);

void main() {
  group('isDrawableLatLng', () {
    test('lo normal pasa', () {
      expect(isDrawableLatLng(-27.4519, -58.9865), isTrue);
      expect(isDrawableLatLng(0, 0), isTrue);
      expect(isDrawableLatLng(90, 180), isTrue);
    });

    test('NaN e Infinity NO pasan: son los que rompían el mapa', () {
      expect(isDrawableLatLng(double.nan, -58.9), isFalse);
      expect(isDrawableLatLng(-27.4, double.nan), isFalse);
      expect(isDrawableLatLng(double.infinity, 0), isFalse);
      expect(isDrawableLatLng(0, double.negativeInfinity), isFalse);
      expect(isDrawableLatLng(double.nan, double.nan), isFalse);
    });

    test('fuera del planeta tampoco: LatLngBounds lo rechaza igual', () {
      expect(isDrawableLatLng(91, 0), isFalse);
      expect(isDrawableLatLng(-91, 0), isFalse);
      expect(isDrawableLatLng(0, 181), isFalse);
    });
  });

  group('fitFor', () {
    test('sin puntos no se toca la cámara', () {
      expect(fitFor(const []), isA<NothingToFit>());
    });

    test('con TODOS los puntos rotos tampoco', () {
      // El caso del crash: si acá se devolviera un encuadre, el NaN entraría
      // igual a la librería.
      expect(
        fitFor([_raw(double.nan, double.nan), _raw(double.infinity, 0)]),
        isA<NothingToFit>(),
      );
    });

    test('un punto roto entre buenos se DESCARTA, no invalida el resto', () {
      final fit = fitFor([
        LatLng(-27.45, -58.98),
        _raw(double.nan, -58.99),
        LatLng(-27.47, -58.99),
      ]);
      expect(fit, isA<FitAllPoints>());
      expect((fit as FitAllPoints).points, hasLength(2));
    });

    test('un solo punto se CENTRA, no se encuadra', () {
      // Encuadrar un rectángulo de tamaño cero es la división por cero que
      // termina en NaN.
      final fit = fitFor([LatLng(-27.45, -58.98)]);
      expect(fit, isA<CenterOn>());
      expect((fit as CenterOn).point.latitude, -27.45);
    });

    test('puntos prácticamente iguales también se centran', () {
      // Un recorrido cuya geometría colapsó en un punto: pasa con datos
      // importados mal, y no tiene por qué tirar la app.
      final fit = fitFor([
        LatLng(-27.45, -58.98),
        LatLng(-27.450001, -58.980001),
      ]);
      expect(fit, isA<CenterOn>());
    });

    test('con extensión real se encuadra', () {
      final fit = fitFor([LatLng(-27.45, -58.98), LatLng(-27.47, -58.99)]);
      expect(fit, isA<FitAllPoints>());
      expect((fit as FitAllPoints).points, hasLength(2));
    });

    test('alcanza con que UNA de las dos dimensiones tenga extensión', () {
      // Un recorrido perfectamente norte-sur: la longitud no varía, pero la
      // latitud sí y encuadrar tiene sentido.
      expect(
        fitFor([LatLng(-27.45, -58.98), LatLng(-27.47, -58.98)]),
        isA<FitAllPoints>(),
      );
    });
  });
}
