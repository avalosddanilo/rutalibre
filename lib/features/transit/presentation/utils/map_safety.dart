/// Filtros para que NUNCA le llegue una coordenada rota a `flutter_map`.
///
/// **Por qué existe este archivo.** En el teléfono apareció un crash en cadena
/// dentro de la librería:
///
/// ```
/// Unsupported operation: Infinity or NaN toInt
///   double.floor → DiscreteTileRange.fromPixelBounds → TileRangeCalculator
/// The north latitude can't be bigger than 90.0: NaN
/// ```
///
/// Lo que pasa ahí es que un `NaN` entra a la cámara del mapa —como centro, o
/// como esquina de un encuadre— y a partir de ese momento **toda** cuenta de
/// tiles da `NaN`. No es un error que se recupere solo: el mapa queda muerto y
/// el log se llena hasta que se cierra la app.
///
/// Contra eso, validar en el borde es más barato y más seguro que perseguir de
/// dónde salió el `NaN`: si nada roto entra, nada revienta adentro.
library;

import 'package:latlong2/latlong.dart';

/// True si la coordenada se puede dibujar.
///
/// Rechaza `NaN` e `Infinity` —el caso que rompía— y también lo que está fuera
/// del planeta: una latitud de 91 no es un error de punto flotante, pero
/// `LatLngBounds` la rechaza con una excepción igual de fatal.
bool isDrawableLatLng(double lat, double lng) =>
    lat.isFinite && lng.isFinite && lat.abs() <= 90 && lng.abs() <= 180;

/// Los puntos que se pueden dibujar, en orden.
List<LatLng> drawablePoints(Iterable<LatLng> points) => [
  for (final p in points)
    if (isDrawableLatLng(p.latitude, p.longitude)) p,
];

/// Qué hacer para encuadrar [points].
sealed class MapFit {
  const MapFit();
}

/// No hay nada dibujable: no tocar la cámara.
final class NothingToFit extends MapFit {
  const NothingToFit();
}

/// Todos los puntos caen prácticamente en el mismo lugar: hay que CENTRAR, no
/// encuadrar.
///
/// Encuadrar un rectángulo de tamaño cero hace que la librería divida por cero
/// para sacar el zoom. Según qué padding haya, eso da `Infinity` —que el
/// `clamp` acomoda— o `0/0 = NaN`, que el `clamp` de Dart **deja pasar tal
/// cual** porque `NaN` no es mayor ni menor que nada. Ese `NaN` es el que
/// termina en el crash de arriba.
final class CenterOn extends MapFit {
  const CenterOn(this.point);

  final LatLng point;
}

/// Hay extensión real: se puede encuadrar.
final class FitAllPoints extends MapFit {
  const FitAllPoints(this.points);

  final List<LatLng> points;
}

/// Cuánta diferencia de grados hace falta para que encuadrar tenga sentido.
///
/// ~1 metro. Por debajo de eso el rectángulo es tan chico que el zoom que sale
/// no significa nada, y es donde aparecen las divisiones por cero.
const _degenerateDegrees = 0.00001;

/// Decide cómo encuadrar, descartando lo que no se puede dibujar.
MapFit fitFor(Iterable<LatLng> points) {
  final usable = drawablePoints(points);
  if (usable.isEmpty) return const NothingToFit();

  var minLat = usable.first.latitude;
  var maxLat = minLat;
  var minLng = usable.first.longitude;
  var maxLng = minLng;
  for (final p in usable) {
    if (p.latitude < minLat) minLat = p.latitude;
    if (p.latitude > maxLat) maxLat = p.latitude;
    if (p.longitude < minLng) minLng = p.longitude;
    if (p.longitude > maxLng) maxLng = p.longitude;
  }

  final degenerate =
      maxLat - minLat < _degenerateDegrees &&
      maxLng - minLng < _degenerateDegrees;
  return degenerate ? CenterOn(usable.first) : FitAllPoints(usable);
}
