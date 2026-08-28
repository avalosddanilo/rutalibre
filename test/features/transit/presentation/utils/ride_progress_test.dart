import 'package:flutter_test/flutter_test.dart';
import 'package:rutalibre/features/transit/domain/entities/route_variant.dart';
import 'package:rutalibre/features/transit/domain/entities/stop.dart';
import 'package:rutalibre/features/transit/domain/entities/trip_plan.dart';
import 'package:rutalibre/features/transit/presentation/utils/ride_progress.dart';

/// Un recorrido recto hacia el este, con paradas cada ~200 m.
///
/// A esta latitud, 0.002 de longitud ≈ 198 m: números redondos para razonar
/// las distancias de los casos.
final _routeStops = [
  for (var i = 0; i < 8; i++)
    Stop(
      id: 's$i',
      name: 'Parada $i',
      lat: -27.4519,
      lng: -58.9865 + i * 0.002,
    ),
];

TripLeg _leg({int board = 1, int alight = 6}) => TripLeg(
  lineId: 'l1',
  lineCode: '3',
  lineName: 'Línea 3',
  colorHex: '#111111',
  networkCode: 'gran-resistencia',
  networkName: 'Gran Resistencia',
  routeVariantId: 'rv1',
  variantName: 'Ida',
  branch: 'A',
  direction: RouteDirection.outbound,
  boardStop: _routeStops[board],
  alightStop: _routeStops[alight],
  stopCount: alight - board,
);

RideProgress? _at(double lng, {TripLeg? leg}) => rideProgress(
  routeStops: _routeStops,
  leg: leg ?? _leg(),
  lat: -27.4519,
  lng: lng,
);

void main() {
  test('parado en una parada del medio, cuenta las que faltan hasta bajar', () {
    // En la parada 3, bajando en la 6: faltan 3.
    final progress = _at(_routeStops[3].lng);
    expect(progress!.stopsRemaining, 3);
    expect(progress.shouldPrepare, isFalse);
  });

  test('entre dos paradas gana la más cercana', () {
    // 60 m después de la parada 3 (de 198 m entre paradas): sigue siendo la 3.
    final progress = _at(_routeStops[3].lng + 0.0006);
    expect(progress!.stopsRemaining, 3);
  });

  test('a una parada de bajar, avisa que hay que prepararse', () {
    final progress = _at(_routeStops[5].lng);
    expect(progress!.stopsRemaining, 1);
    expect(progress.shouldPrepare, isTrue);
  });

  test('en la parada de bajada dice cero y sigue avisando', () {
    final progress = _at(_routeStops[6].lng);
    expect(progress!.stopsRemaining, 0);
    expect(progress.metersToAlight, lessThan(30));
    expect(progress.shouldPrepare, isTrue);
  });

  test('la ALARMA suena una parada antes que el aviso discreto', () {
    // A dos paradas de bajar: quien mira el teléfono todavía no necesita
    // nada (shouldPrepare false), pero a quien hay que DESPERTAR ya le
    // corre el reloj — entre abrir los ojos y juntar sus cosas, avisar a
    // una parada quedaba "muy justo" (prueba de campo, textual).
    final progress = _at(_routeStops[4].lng);
    expect(progress!.stopsRemaining, 2);
    expect(progress.shouldPrepare, isFalse);
    expect(progress.shouldWake, isTrue);

    // A tres, ni una ni la otra.
    final far = _at(_routeStops[3].lng);
    expect(far!.shouldWake, isFalse);
  });

  test('lejos en distancia pero cerca en paradas: manda la distancia', () {
    // A 200 m de la bajada el contador diría "faltan 1", pero aunque dijera
    // más, <250 m ya es zona de prepararse.
    final progress = _at(_routeStops[6].lng - 0.002);
    expect(progress!.shouldPrepare, isTrue);
  });

  test('lejos del tramo entero se calla: mejor nada que adivinar', () {
    // 2 km al este de la última parada del tramo.
    expect(_at(_routeStops[7].lng + 0.02), isNull);
  });

  test('las paradas FUERA del tramo no cuentan', () {
    // Parado en la parada 0 (antes de subir, a 198 m de la de subida): la
    // más cercana DEL TRAMO es la 1, así que dice el total del tramo — y no
    // matchea la 0, que no es parte del viaje.
    final progress = _at(_routeStops[0].lng);
    expect(progress!.stopsRemaining, 5);
  });

  test('si la parada de subida o bajada no está en la lista, null', () {
    final foreign = _leg().copyWithBoard(
      const Stop(id: 'otra', name: 'De otro recorrido', lat: -27.4, lng: -58.9),
    );
    expect(
      rideProgress(
        routeStops: _routeStops,
        leg: foreign,
        lat: -27.4519,
        lng: _routeStops[3].lng,
      ),
      isNull,
    );
  });

  test('un tramo dado vuelta (bajada antes que subida) es null', () {
    expect(_at(_routeStops[3].lng, leg: _leg(board: 6, alight: 1)), isNull);
  });

  test('EL PUENTE: entre dos paradas lejanas, el contador sigue vivo', () {
    // Barranqueras → Corrientes: ~1,7 km sin ninguna parada. Medido contra
    // paradas, el punto medio quedaba a >400 m de todas y el contador
    // desaparecía EN EL MEDIO del tramo más largo de la red — y al volver a
    // aparecer, vibraba por segunda vez. Contra los segmentos, estar sobre
    // el camino es estar en el viaje.
    final bridge = [
      for (var i = 0; i < 4; i++)
        Stop(id: 'b$i', name: 'P$i', lat: -27.4519, lng: -58.9865 + i * 0.002),
      // La otra orilla: 1,7 km después de la última de este lado.
      Stop(id: 'b4', name: 'Orilla', lat: -27.4519, lng: -58.9805 + 0.0172),
      Stop(id: 'b5', name: 'Centro', lat: -27.4519, lng: -58.9785 + 0.0172),
    ];
    final leg = TripLeg(
      lineId: 'l904',
      lineCode: '904C',
      lineName: '904 por Barranqueras',
      colorHex: '#111111',
      networkCode: 'interurbano-chaco-corrientes',
      networkName: 'Chaco ↔ Corrientes',
      routeVariantId: 'rv904',
      variantName: 'Ida',
      branch: 'C',
      direction: RouteDirection.outbound,
      boardStop: bridge[1],
      alightStop: bridge[5],
      stopCount: 4,
    );

    // En pleno puente: a mitad de camino entre la parada 3 y la orilla.
    final midBridge = rideProgress(
      routeStops: bridge,
      leg: leg,
      lat: -27.4519,
      lng: (bridge[3].lng + bridge[4].lng) / 2,
    );
    expect(midBridge, isNotNull, reason: 'el contador no puede esfumarse');
    expect(midBridge!.stopsRemaining, 2);
  });

  test('lejos del CAMINO (no solo de las paradas) sigue callándose', () {
    // 500 m perpendicular al recorrido: eso sí es no estar en el viaje.
    expect(
      rideProgress(
        routeStops: _routeStops,
        leg: _leg(),
        lat: -27.4519 + 0.0045,
        lng: _routeStops[3].lng,
      ),
      isNull,
    );
  });

  test('la cache de OTRA generación de datos se detecta y calla', () {
    // Tras un reimport, el recorrido puede tener más (o menos) paradas que
    // cuando el planificador armó el tramo. Contar contra esa secuencia
    // diría "faltan 6" abajo de un paso que dice "viajá 4". stopCount es la
    // promesa del planificador: si no cierra, silencio.
    final legOtraGeneracion = _leg(); // stopCount real: 5 (board 1 → alight 6)
    final conParadaNueva = [
      ..._routeStops.sublist(0, 4),
      // El reimport metió una parada nueva en el medio.
      Stop(id: 'nueva', name: 'Nueva', lat: -27.4519, lng: -58.9795),
      ..._routeStops.sublist(4),
    ];
    expect(
      rideProgress(
        routeStops: conParadaNueva,
        leg: legOtraGeneracion,
        lat: -27.4519,
        lng: _routeStops[3].lng,
      ),
      isNull,
    );
  });

  test('una lista de paradas vacía es null, no una excepción', () {
    // Cache a medio cargar o recorrido sin paradas: el contador se calla.
    expect(
      rideProgress(routeStops: const [], leg: _leg(), lat: -27.45, lng: -58.98),
      isNull,
    );
  });

  test('el fix basura del GPS —(0,0), el golfo de Guinea— se calla', () {
    // Algunos GPS emiten (0,0) mientras buscan señal. Queda a miles de km de
    // toda parada del tramo, así que cae por la regla de lejanía: null.
    expect(
      rideProgress(routeStops: _routeStops, leg: _leg(), lat: 0, lng: 0),
      isNull,
    );
  });
}

extension on TripLeg {
  TripLeg copyWithBoard(Stop stop) => TripLeg(
    lineId: lineId,
    lineCode: lineCode,
    lineName: lineName,
    colorHex: colorHex,
    networkCode: networkCode,
    networkName: networkName,
    routeVariantId: routeVariantId,
    variantName: variantName,
    branch: branch,
    direction: direction,
    boardStop: stop,
    alightStop: alightStop,
    stopCount: stopCount,
  );
}
