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

  test('lejos en distancia pero cerca en paradas: manda la distancia', () {
    // A 200 m de la bajada el contador diría "faltan 1", pero aunque dijera
    // más, <250 m ya es zona de prepararse.
    final progress = _at(_routeStops[6].lng - 0.002);
    expect(progress!.shouldPrepare, isTrue);
  });

  test('lejos de TODO el tramo se calla: mejor nada que adivinar', () {
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
