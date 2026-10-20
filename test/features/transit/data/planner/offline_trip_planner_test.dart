import 'package:flutter_test/flutter_test.dart';
import 'package:rutalibre/features/transit/data/models/trip_plan_model.dart';
import 'package:rutalibre/features/transit/data/planner/offline_trip_planner.dart';

// Una red chiquita sobre una recta este-oeste en Resistencia: cada parada a
// ~100 m de la anterior (0,001° de longitud son ~99 m a esta latitud).
const _lat = -27.45;
PlannerStop _stop(String id, double lng, {double lat = _lat}) =>
    PlannerStop(id: id, name: 'Parada $id', lat: lat, lng: lng);

const _gr = PlannerLine(
  id: 'l-a',
  code: 'A',
  name: 'Línea A',
  colorHex: '#E53935',
  networkCode: 'gran-resistencia',
  networkName: 'Gran Resistencia',
);
const _grB = PlannerLine(
  id: 'l-b',
  code: 'B',
  name: 'Línea B',
  colorHex: '#1E88E5',
  networkCode: 'gran-resistencia',
  networkName: 'Gran Resistencia',
);

PlannerVariant _variant(
  String id,
  String lineId,
  List<String> stops, {
  List<double>? dist,
}) => PlannerVariant(
  id: id,
  lineId: lineId,
  name: 'Ida: X → Y',
  branch: null,
  direction: 0,
  stopIds: stops,
  distM: dist ?? [for (var i = 0; i < stops.length; i++) i * 100.0],
);

List<Map<String, dynamic>> _plan(
  PlannerNetwork net,
  (double, double) from,
  (double, double) to,
) => planTripOffline(
  net,
  originLat: from.$1,
  originLng: from.$2,
  destLat: to.$1,
  destLng: to.$2,
);

List<String> _codes(Map<String, dynamic> trip) => [
  for (final l in (trip['legs'] as List).cast<Map<String, dynamic>>())
    l['line_code'] as String,
];

void main() {
  test('mide como PostGIS sobre el elipsoide (al milímetro, más o menos)', () {
    // Valores de st_distance(geography) en una base con PostGIS 3.
    expect(
      distanceM(-27.4512, -58.9867, -27.4530, -58.9820),
      closeTo(505.622, 0.05),
    );
    expect(
      distanceM(-27.4633, -58.8380, -27.45686, -59.02214),
      closeTo(18215.809, 2),
    );
  });

  group('un colectivo', () {
    final net = PlannerNetwork(
      stops: [
        _stop('s1', -58.980),
        _stop('s2', -58.979),
        _stop('s3', -58.978),
        _stop('s4', -58.970),
      ],
      lines: [_gr],
      variants: [
        _variant('va', 'l-a', ['s1', 's2', 's3', 's4']),
      ],
    );

    test('arma el viaje y el JSON lo lee el mismo parser que el servidor', () {
      final trips = _plan(net, (_lat, -58.980), (_lat, -58.970));
      expect(trips, hasLength(1));
      final plan = TripPlanModel.fromJson(trips.single);
      expect(plan.legs.single.lineCode, 'A');
      expect(plan.legs.single.stopCount, 3);
      expect(plan.legs.single.boardStop.id, 's1');
      expect(plan.legs.single.alightStop.id, 's4');
    });

    test('al revés del recorrido no hay viaje: el colectivo no vuelve', () {
      expect(_plan(net, (_lat, -58.970), (_lat, -58.980)), isEmpty);
    });

    test('lejos de toda parada no inventa nada', () {
      expect(_plan(net, (_lat, -58.900), (_lat, -58.970)), isEmpty);
    });

    test('un recorrido con una parada que el teléfono no tiene no se usa', () {
      final hueco = PlannerNetwork(
        stops: [_stop('s1', -58.980), _stop('s4', -58.970)],
        lines: [_gr],
        variants: [
          _variant('va', 'l-a', ['s1', 'falta', 's4']),
        ],
      );
      expect(_plan(hueco, (_lat, -58.980), (_lat, -58.970)), isEmpty);
    });
  });

  group('con transbordo', () {
    // A va de s1 a s3; B sale de t1, a 100 m de s3, y llega a t3.
    final net = PlannerNetwork(
      stops: [
        _stop('s1', -58.990),
        _stop('s2', -58.985),
        _stop('s3', -58.980),
        _stop('t1', -58.979),
        _stop('t2', -58.974),
        _stop('t3', -58.969),
      ],
      lines: [_gr, _grB],
      variants: [
        _variant('va', 'l-a', ['s1', 's2', 's3']),
        _variant('vb', 'l-b', ['t1', 't2', 't3']),
      ],
    );

    test('caminando hasta otra parada, y dice cuánto', () {
      final trips = _plan(net, (_lat, -58.990), (_lat, -58.969));
      expect(trips, hasLength(1));
      expect(_codes(trips.single), ['A', 'B']);
      expect(trips.single['transfer_walk_m'], closeTo(99, 2));
    });

    test('a más de 250 m no hay transbordo', () {
      final lejos = PlannerNetwork(
        stops: [
          _stop('s1', -58.990),
          _stop('s3', -58.980),
          _stop('t1', -58.977), // ~297 m de s3
          _stop('t3', -58.969),
        ],
        lines: [_gr, _grB],
        variants: [
          _variant('va', 'l-a', ['s1', 's3']),
          _variant('vb', 'l-b', ['t1', 't3']),
        ],
      );
      expect(_plan(lejos, (_lat, -58.990), (_lat, -58.969)), isEmpty);
    });

    test('los directos van primero, aunque tarden más', () {
      final conDirecto = PlannerNetwork(
        stops: net.stops.values.toList(),
        lines: [
          _gr,
          _grB,
          const PlannerLine(
            id: 'l-c',
            code: 'C',
            name: 'Línea C',
            colorHex: null,
            networkCode: 'gran-resistencia',
            networkName: 'Gran Resistencia',
          ),
        ],
        variants: [
          ...net.variants,
          // Un directo que da toda la vuelta: más lento, igual primero.
          _variant(
            'vc',
            'l-c',
            ['s1', 's2', 's3', 't1', 't2', 't3'],
            dist: [0, 2000, 4000, 6000, 8000, 10000],
          ),
        ],
      );
      final trips = _plan(conDirecto, (_lat, -58.990), (_lat, -58.969));
      expect(_codes(trips.first), ['C']);
      expect(_codes(trips[1]), ['A', 'B']);
    });
  });

  group('el 904 y el río', () {
    const n904 = PlannerLine(
      id: 'l-904',
      code: '904A',
      name: 'Chaco ↔ Corrientes',
      colorHex: null,
      networkCode: crossRiverNetwork,
      networkName: 'Chaco ↔ Corrientes',
    );
    const n904b = PlannerLine(
      id: 'l-904b',
      code: '904B',
      name: 'Chaco ↔ Corrientes',
      colorHex: null,
      networkCode: crossRiverNetwork,
      networkName: 'Chaco ↔ Corrientes',
    );
    // c1 y c2 en el Chaco (al oeste de -58.86); k1 en Corrientes.
    final net = PlannerNetwork(
      stops: [
        _stop('c1', -58.990),
        _stop('c2', -58.985),
        _stop('k1', -58.840),
        _stop('k2', -58.835),
      ],
      lines: [n904, n904b],
      variants: [
        _variant('v904', 'l-904', ['c1', 'c2', 'k1']),
        _variant('v904b', 'l-904b', ['k1', 'k2', 'c2']),
      ],
    );

    test(
      'para ir de una parada del Chaco a otra del Chaco, el 904 no sirve',
      () {
        // Solo el 904A, que pasa por las dos: sube y baja del mismo lado.
        final soloA = PlannerNetwork(
          stops: net.stops.values.toList(),
          lines: [n904],
          variants: [net.variants.first],
        );
        expect(_plan(soloA, (_lat, -58.990), (_lat, -58.985)), isEmpty);
      },
    );

    test('para cruzar, sí', () {
      expect(_codes(_plan(net, (_lat, -58.990), (_lat, -58.840)).single), [
        '904A',
      ]);
    });

    test('nunca dos tramos del 904 seguidos: es cruzar y volver', () {
      // c1 → k1 en el 904A y k1 → c2 en el 904B volvería al Chaco.
      final trips = _plan(net, (_lat, -58.990), (_lat, -58.985));
      expect(trips, isEmpty);
    });
  });
}
