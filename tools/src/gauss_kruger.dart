/// Reproyección Gauss-Krüger (Transverse Mercator) → WGS84.
///
/// El portal de datos abiertos de Corrientes publica los recorridos en
/// coordenadas PROYECTADAS (Faja 5 del sistema argentino), no en lat/lng.
/// Sin esta conversión los 60 recorridos caen en medio del océano.
///
/// Se resuelve en Dart y no con `ST_Transform` de PostGIS a propósito: el
/// SQL emitido queda en 4326 igual que el de OSM (un solo formato), y no
/// depende de que la base tenga cargado el EPSG 5347 en `spatial_ref_sys`.
///
/// Dart PURO — sin red, sin SQL.
library;

import 'dart:math' as math;

import 'geometry.dart';

/// Parámetros de la Faja 5 argentina (EPSG:5347, POSGAR 2007 / Argentina 5).
///
/// Corrientes y Resistencia caen ambas en esta faja (meridiano central -60°).
class GaussKrugerZone {
  const GaussKrugerZone({
    required this.centralMeridian,
    this.falseEasting = 5500000.0,
    this.falseNorthing = 10001965.7290,
  });

  /// Faja 5: cubre de -60° a -57° de longitud.
  static const faja5 = GaussKrugerZone(centralMeridian: -60);

  final double centralMeridian;
  final double falseEasting;

  /// En el hemisferio sur el norteo se mide desde un origen desplazado para
  /// que nunca sea negativo.
  final double falseNorthing;
}

// Elipsoide GRS80 (el de POSGAR 94 y 2007; difieren en el datum, no en la
// forma — la discrepancia entre ambos es de centímetros a esta escala).
const _a = 6378137.0;
const _f = 1 / 298.257222101;

/// Convierte un punto proyectado a WGS84.
///
/// Verificado contra puntos de control reales: el recorrido "PUERTO -
/// AEROPUERTO" del Aerobus arranca a 620 m del puerto de Corrientes y
/// termina a 580 m del aeropuerto Piragine Niveyro (ver los tests).
GeoPoint gaussKrugerToWgs84(
  double easting,
  double northing, {
  GaussKrugerZone zone = GaussKrugerZone.faja5,
}) {
  const e2 = 2 * _f - _f * _f;
  const ep2 = e2 / (1 - e2);

  final x = easting - zone.falseEasting;
  final y = northing - zone.falseNorthing;

  // Latitud de pie de perpendicular (footpoint latitude).
  final mu =
      y / (_a * (1 - e2 / 4 - 3 * e2 * e2 / 64 - 5 * e2 * e2 * e2 / 256));
  final e1 = (1 - math.sqrt(1 - e2)) / (1 + math.sqrt(1 - e2));
  final phi1 =
      mu +
      (3 * e1 / 2 - 27 * math.pow(e1, 3) / 32) * math.sin(2 * mu) +
      (21 * e1 * e1 / 16 - 55 * math.pow(e1, 4) / 32) * math.sin(4 * mu) +
      (151 * math.pow(e1, 3) / 96) * math.sin(6 * mu) +
      (1097 * math.pow(e1, 4) / 512) * math.sin(8 * mu);

  final sinPhi1 = math.sin(phi1);
  final cosPhi1 = math.cos(phi1);
  final tanPhi1 = math.tan(phi1);

  final c1 = ep2 * cosPhi1 * cosPhi1;
  final t1 = tanPhi1 * tanPhi1;
  final n1 = _a / math.sqrt(1 - e2 * sinPhi1 * sinPhi1);
  final r1 = _a * (1 - e2) / math.pow(1 - e2 * sinPhi1 * sinPhi1, 1.5);
  final d = x / n1;

  final lat =
      phi1 -
      (n1 * tanPhi1 / r1) *
          (d * d / 2 -
              (5 + 3 * t1 + 10 * c1 - 4 * c1 * c1 - 9 * ep2) *
                  math.pow(d, 4) /
                  24 +
              (61 +
                      90 * t1 +
                      298 * c1 +
                      45 * t1 * t1 -
                      252 * ep2 -
                      3 * c1 * c1) *
                  math.pow(d, 6) /
                  720);

  final lng =
      _rad(zone.centralMeridian) +
      (d -
              (1 + 2 * t1 + c1) * math.pow(d, 3) / 6 +
              (5 - 2 * c1 + 28 * t1 - 3 * c1 * c1 + 8 * ep2 + 24 * t1 * t1) *
                  math.pow(d, 5) /
                  120) /
          cosPhi1;

  return (lat: _deg(lat), lng: _deg(lng));
}

double _rad(double degrees) => degrees * math.pi / 180;

double _deg(double radians) => radians * 180 / math.pi;
