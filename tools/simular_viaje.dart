// Mueve la ubicación simulada de un emulador Android a lo largo de un
// recorrido, para probar la alarma "avisame para bajar" sin tomarse un
// colectivo.
//
//   dart run tools/simular_viaje.dart --desde -58.88943,-27.44430 \
//                                     --hasta -58.97500,-27.45100
//
// Por qué existe: `docs/alarma-pantalla-apagada.md` describe la prueba y
// termina diciendo "reproducir el GPX del 904A a 5x". Esa herramienta no
// existía, y a mano —tirando `adb emu geo fix` de a uno mientras mirás el
// reloj— la prueba no se hace. El paso a paso completo está en ese
// documento.
//
// Qué tiene que pasar: la alarma suena cuando faltan 2 paradas **o** cuando
// estás a menos de 500 m de la parada de bajada, lo que ocurra primero (ver
// `RideProgress.shouldWake`). El script avisa por pantalla cuándo cruza ese
// umbral, así sabés si lo que escuchaste llegó cuando tenía que llegar.
//
// **El orden es longitud, latitud** — así lo pide `adb emu geo fix`, y es la
// forma más fácil de perder media hora. Acá abajo hay un guardarraíl que te
// avisa si el punto cae lejísimos del Gran Resistencia.
import 'dart:io';
import 'dart:math' as math;

/// El centro aproximado del Gran Resistencia, sólo para el guardarraíl de
/// coordenadas invertidas.
const _refLng = -58.9867, _refLat = -27.4512;

/// A partir de acá el script sospecha que invertiste longitud y latitud.
const _radioSospecha = 300000.0;

/// Los dos umbrales de `RideProgress`, en metros. Si cambian allá, cambian
/// acá: este script existe para verificar ESA lógica, no otra.
const _metrosAlarma = 500.0;
const _metrosPrepararse = 250.0;

void main(List<String> args) {
  final a = _Args.parse(args);
  if (a == null) {
    stderr.writeln('''
uso: dart run tools/simular_viaje.dart --desde LNG,LAT --hasta LNG,LAT
                                       [--por LNG,LAT]...   punto intermedio, repetible
                                       [--pasos 40]         en cuántos tramos se parte
                                       [--intervalo 2]      segundos entre fix
                                       [--seco]             no llama a adb, sólo imprime

OJO: primero la LONGITUD y después la LATITUD, como pide `adb emu geo fix`.
En el Gran Resistencia la longitud ronda -58.9 y la latitud -27.4.''');
    exit(2);
  }

  if (!a.seco && !_hayEmulador()) exit(1);

  final ruta = [a.desde, ...a.por, a.hasta];
  for (final p in ruta) {
    final lejos = _metros(p, const _Punto(_refLng, _refLat));
    if (lejos > _radioSospecha) {
      stdout.writeln(
        '⚠ ${p.lng},${p.lat} está a ${(lejos / 1000).round()} km del Gran '
        'Resistencia. ¿No invertiste longitud y latitud?',
      );
    }
  }

  final puntos = _interpolar(ruta, a.pasos);
  final total = _largo(ruta);
  stdout.writeln(
    'Recorrido de ${total.round()} m en ${puntos.length} fix, cada '
    '${a.intervalo} s (~${(puntos.length * a.intervalo / 60).toStringAsFixed(1)} min).',
  );
  stdout.writeln('Destino: ${a.hasta.lng},${a.hasta.lat}');

  // Si cada paso es más largo que esto, el salto se come el umbral: la
  // ubicación pasa de "faltan 600 m" a "faltan 200 m" de un tirón y no hay
  // forma de saber si la alarma llegó a tiempo o tarde. Mejor avisar antes
  // que hacerte perder el viaje entero.
  final paso = total / a.pasos;
  if (paso > 100) {
    stdout.writeln(
      '⚠ cada paso son ${paso.round()} m. Con saltos así no se puede '
      'distinguir si la alarma sonó a tiempo: subí --pasos a '
      '${(total / 80).ceil()} o más.',
    );
  }
  stdout.writeln('');

  var avisoAlarma = false, avisoPrepararse = false;
  for (var i = 0; i < puntos.length; i++) {
    final p = puntos[i];
    final faltan = _metros(p, a.hasta);

    if (!a.seco) {
      final r = Process.runSync('adb', [
        'emu',
        'geo',
        'fix',
        p.lng.toStringAsFixed(6),
        p.lat.toStringAsFixed(6),
      ]);
      if (r.exitCode != 0) {
        stderr.writeln('adb falló: ${r.stderr}');
        exit(1);
      }
    }

    final n = '${i + 1}'.padLeft(3);
    stdout.writeln(
      '$n/${puntos.length}  ${p.lng.toStringAsFixed(6)},'
      '${p.lat.toStringAsFixed(6)}  faltan ${faltan.round()} m',
    );

    // Los dos avisos salen UNA vez, al cruzar. Son el reloj contra el que
    // se compara lo que escuchás: si la alarma suena mucho después de esta
    // línea, llegó tarde, y ese es el bug que esta prueba busca.
    if (!avisoAlarma && faltan < _metrosAlarma) {
      avisoAlarma = true;
      stdout.writeln(
        '    -- acá la alarma TIENE que sonar (menos de '
        '${_metrosAlarma.round()} m)',
      );
    }
    if (!avisoPrepararse && faltan < _metrosPrepararse) {
      avisoPrepararse = true;
      stdout.writeln(
        '    -- acá ya tendría que haber vibrado el "preparate" '
        '(menos de ${_metrosPrepararse.round()} m)',
      );
    }

    if (i < puntos.length - 1) sleep(Duration(seconds: a.intervalo));
  }

  stdout.writeln('\nLlegaste. Si no sonó nada, la alarma no anda.');
}

/// Que haya un emulador escuchando. Un teléfono real NO sirve: `adb emu` es
/// un canal del emulador y en un dispositivo físico falla sin explicar por
/// qué.
bool _hayEmulador() {
  final ProcessResult r;
  try {
    r = Process.runSync('adb', ['devices']);
  } on ProcessException {
    stderr.writeln(
      'No encuentro `adb`. Está en platform-tools del SDK de '
      'Android; agregalo al PATH.',
    );
    return false;
  }
  final salida = '${r.stdout}';
  if (!salida.contains('emulator-')) {
    stderr.writeln(
      'No hay ningún emulador corriendo. `adb emu geo fix` sólo '
      'funciona contra un emulador, no contra un teléfono enchufado.\n'
      '$salida',
    );
    return false;
  }
  return true;
}

class _Punto {
  const _Punto(this.lng, this.lat);
  final double lng, lat;
}

/// Metros en línea recta entre dos puntos (haversine). Es la misma medida
/// que usa `RideProgress.metersToAlight`, así que los números de este
/// script y los de la app son comparables.
double _metros(_Punto a, _Punto b) {
  const r = 6371000.0, g = math.pi / 180;
  final dLat = (b.lat - a.lat) * g, dLng = (b.lng - a.lng) * g;
  final h =
      math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(a.lat * g) *
          math.cos(b.lat * g) *
          math.sin(dLng / 2) *
          math.sin(dLng / 2);
  return 2 * r * math.asin(math.min(1, math.sqrt(h)));
}

double _largo(List<_Punto> ruta) {
  var t = 0.0;
  for (var i = 1; i < ruta.length; i++) {
    t += _metros(ruta[i - 1], ruta[i]);
  }
  return t;
}

/// Parte la ruta en [pasos] puntos repartidos **por distancia**, no por
/// tramo: si un tramo es diez veces más largo que otro, se lleva diez veces
/// más fix. Con el reparto parejo el colectivo "aceleraba" en los tramos
/// cortos y la prueba dejaba de parecerse a un viaje.
List<_Punto> _interpolar(List<_Punto> ruta, int pasos) {
  final total = _largo(ruta);
  if (total == 0) return [ruta.first];
  final salida = <_Punto>[];
  for (var i = 0; i <= pasos; i++) {
    var resta = total * i / pasos;
    for (var s = 1; s < ruta.length; s++) {
      final largo = _metros(ruta[s - 1], ruta[s]);
      if (resta <= largo || s == ruta.length - 1) {
        final f = largo == 0 ? 0.0 : (resta / largo).clamp(0.0, 1.0);
        salida.add(
          _Punto(
            ruta[s - 1].lng + (ruta[s].lng - ruta[s - 1].lng) * f,
            ruta[s - 1].lat + (ruta[s].lat - ruta[s - 1].lat) * f,
          ),
        );
        break;
      }
      resta -= largo;
    }
  }
  return salida;
}

class _Args {
  _Args(
    this.desde,
    this.hasta,
    this.por,
    this.pasos,
    this.intervalo,
    this.seco,
  );
  final _Punto desde, hasta;
  final List<_Punto> por;
  final int pasos, intervalo;
  final bool seco;

  static _Args? parse(List<String> args) {
    _Punto? desde, hasta;
    final por = <_Punto>[];
    var pasos = 40, intervalo = 2, seco = false;
    for (var i = 0; i < args.length; i++) {
      switch (args[i]) {
        case '--desde':
          desde = _punto(args, ++i);
        case '--hasta':
          hasta = _punto(args, ++i);
        case '--por':
          final p = _punto(args, ++i);
          if (p != null) por.add(p);
        case '--pasos':
          pasos = int.tryParse(_valor(args, ++i) ?? '') ?? pasos;
        case '--intervalo':
          intervalo = int.tryParse(_valor(args, ++i) ?? '') ?? intervalo;
        case '--seco':
          seco = true;
        default:
          return null;
      }
    }
    if (desde == null || hasta == null || pasos < 1) return null;
    return _Args(desde, hasta, por, pasos, intervalo, seco);
  }

  static String? _valor(List<String> args, int i) =>
      i < args.length ? args[i] : null;

  static _Punto? _punto(List<String> args, int i) {
    final partes = (_valor(args, i) ?? '').split(',');
    if (partes.length != 2) return null;
    final lng = double.tryParse(partes[0]), lat = double.tryParse(partes[1]);
    if (lng == null || lat == null) return null;
    if (lat < -90 || lat > 90) return null;
    return _Punto(lng, lat);
  }
}
