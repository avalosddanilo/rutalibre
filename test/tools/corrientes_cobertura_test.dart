// ¿Por qué Corrientes capital NO entra al planificador?
//
// **Por qué este test existe.** La respuesta estaba escrita en
// `reference_stop.dart` con un número medido: "de las 254 paradas apenas 93
// caen a menos de 80 m del recorrido de su propia línea". Ese número estaba
// MAL: se había medido la distancia de cada parada al VÉRTICE más cercano
// del trazado, no al segmento. En una cuadra recta larga el trazado tiene dos
// vértices —uno en cada esquina— y una parada en el medio queda a cien metros
// del vértice más cercano estando a tres metros de la línea.
//
// Medido como corresponde, con `distanceToSegmentMeters` —que ya estaba en
// `tools/src/geometry.dart`—, no son 93 sino 202, y la mediana de distancia
// es de 5 metros. Las paradas de OSM y los recorridos del municipio encajan
// casi perfecto.
//
// **La decisión no cambia, pero el motivo sí.** Corrientes sigue afuera del
// planificador, y este test fija la razón verdadera: la cobertura de paradas
// en OSM es MUY despareja. La 104 tiene una parada cada 61 metros; la 101
// tiene UNA parada en doce kilómetros y el Aerobus ninguna. Con eso, "¿cómo
// llego?" contestaría bien para la 104 y mandaría a caminar kilómetros para
// todo lo demás.
//
// Y eso es una diferencia que importa: el motivo viejo ("los datos no
// encajan") no tenía arreglo. El verdadero sí lo tiene, y es concreto —
// mapear paradas en OSM, línea por línea. Cada línea que llega a densidad
// usable es una línea que puede entrar.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tools/src/geometry.dart';

/// Umbral con el que se decide si una parada "es" de un recorrido. El mismo
/// espíritu que el importador del Gran Resistencia, que descarta a 250 m.
const _cerca = 80.0;

/// Los recorridos del seed, agrupados por código de línea.
Map<String, List<List<GeoPoint>>> _recorridos() {
  final sql = File('supabase/seed/seed_corrientes.sql').readAsStringSync();
  final re = RegExp(
    r"l\.code = '([^']+)'\),[\s\S]*?st_geomfromtext\('LINESTRING\(([^)]*)\)'",
  );
  final out = <String, List<List<GeoPoint>>>{};
  for (final m in re.allMatches(sql)) {
    final puntos = <GeoPoint>[];
    for (final par in m.group(2)!.split(',')) {
      final xy = par.trim().split(' ');
      if (xy.length == 2) {
        // El WKT va (lng lat), al revés que todo lo demás del proyecto.
        puntos.add((lat: double.parse(xy[1]), lng: double.parse(xy[0])));
      }
    }
    if (puntos.length >= 2) {
      (out[m.group(1)!] ??= []).add(puntos);
    }
  }
  return out;
}

typedef _Parada = ({String nombre, GeoPoint punto, List<String> lineas});

List<_Parada> _paradas() {
  final json =
      jsonDecode(File('assets/corrientes_stops.json').readAsStringSync())
          as Map<String, dynamic>;
  return [
    for (final row in json['s'] as List<dynamic>)
      if (row case {
        'n': final String n,
        'y': final num y,
        'x': final num x,
        'l': final List<dynamic> l,
      })
        (
          nombre: n,
          punto: (lat: y.toDouble(), lng: x.toDouble()),
          lineas: [for (final e in l) '$e'],
        ),
  ];
}

double _distanciaARuta(GeoPoint p, List<GeoPoint> ruta) {
  var min = double.infinity;
  for (var i = 0; i < ruta.length - 1; i++) {
    final d = distanceToSegmentMeters(p, ruta[i], ruta[i + 1]);
    if (d < min) min = d;
  }
  return min;
}

void main() {
  late Map<String, List<List<GeoPoint>>> recorridos;
  late List<_Parada> paradas;

  setUpAll(() {
    recorridos = _recorridos();
    paradas = _paradas();
  });

  /// La distancia de una parada al recorrido más cercano de una de SUS
  /// líneas, o null si ninguna de sus líneas tiene recorrido publicado.
  double? mejorDistancia(_Parada p) {
    double? mejor;
    for (final linea in p.lineas) {
      for (final ruta in recorridos[linea] ?? const <List<GeoPoint>>[]) {
        final d = _distanciaARuta(p.punto, ruta);
        if (mejor == null || d < mejor) mejor = d;
      }
    }
    return mejor;
  }

  test('el seed y el asset siguen siendo los medidos', () {
    expect(paradas, hasLength(254));
    expect(recorridos.keys.length, 10, reason: 'líneas con recorrido');
    expect(
      recorridos.values.fold(0, (n, v) => n + v.length),
      60,
      reason: 'recorridos',
    );
  });

  test('las paradas SÍ encajan con los recorridos — no eran 93', () {
    final medidas = [for (final p in paradas) ?mejorDistancia(p)]..sort();

    // El número que estaba escrito era 93 de 254. Es más del doble.
    final cerca = medidas.where((d) => d <= _cerca).length;
    expect(
      cerca,
      greaterThanOrEqualTo(200),
      reason:
          'si esto baja, o cambió el asset o alguien volvió a medir contra '
          'los vértices en vez de los segmentos',
    );

    // Y no encajan "justo": encajan casi exacto.
    final mediana = medidas[medidas.length ~/ 2];
    expect(mediana, lessThan(10), reason: 'mediana en metros');
  });

  test('la razón real: la cobertura de OSM es despareja por línea', () {
    // Paradas a <= 80 m de cada línea. Es lo que decide si un viaje por esa
    // línea se puede armar o hay que adivinar dónde se baja la gente.
    final porLinea = <String, int>{};
    for (final linea in recorridos.keys) {
      porLinea[linea] = paradas.where((p) {
        if (!p.lineas.contains(linea)) return false;
        return recorridos[linea]!.any(
          (r) => _distanciaARuta(p.punto, r) <= _cerca,
        );
      }).length;
    }

    // Una sola línea concentra más de la mitad de las paradas de la ciudad.
    expect(porLinea['104'], greaterThan(100));

    // Y la mayoría de las líneas no llega ni a cinco paradas en más de diez
    // kilómetros de recorrido. Ahí está el "no se puede planificar".
    final pobres = porLinea.values.where((n) => n < 5).length;
    expect(
      pobres,
      greaterThanOrEqualTo(4),
      reason:
          'el día que esto baje a 0, Corrientes puede entrar al planificador '
          'y este test hay que reescribirlo — que es exactamente la idea',
    );
  });

  test('49 paradas son de líneas que el municipio ni publica', () {
    // El otro agujero, y este no lo arregla mapear en OSM: son ramales
    // (103A, 104C, 110B…) cuyo recorrido el portal municipal no publica.
    final sinRecorrido = paradas.where((p) => mejorDistancia(p) == null).length;
    expect(sinRecorrido, 49);
  });
}
