import 'package:flutter_test/flutter_test.dart';
import 'package:rutalibre/features/transit/domain/entities/route_variant.dart';
import 'package:rutalibre/features/transit/domain/entities/stop.dart';
import 'package:rutalibre/features/transit/domain/entities/trip_plan.dart';
import 'package:rutalibre/features/transit/presentation/utils/trip_guidance.dart';

Stop _stop(String name) =>
    Stop(id: 'id-$name', name: name, lat: -27.45, lng: -58.98);

TripLeg _leg({
  String code = '3',
  String board = 'Ameghino y French',
  String alight = 'Perrando',
  int stops = 14,
}) => TripLeg(
  lineId: 'l-$code',
  lineCode: code,
  lineName: 'Línea $code',
  colorHex: '#F57C00',
  networkCode: 'gran-resistencia',
  networkName: 'Gran Resistencia',
  routeVariantId: 'rv-$code',
  variantName: 'Ida',
  branch: null,
  direction: RouteDirection.outbound,
  boardStop: _stop(board),
  alightStop: _stop(alight),
  stopCount: stops,
);

TripPlan _plan({
  required List<TripLeg> legs,
  double walkToBoard = 350,
  double walkFromAlight = 200,
}) => TripPlan(
  legs: legs,
  walkToBoardMeters: walkToBoard,
  walkFromAlightMeters: walkFromAlight,
);

List<GuidanceStep> _steps(TripPlan plan) => guidanceSteps(
  plan: plan,
  originLat: -27.44,
  originLng: -58.97,
  destinationLat: -27.46,
  destinationLng: -58.99,
);

void main() {
  group('viaje directo', () {
    late List<GuidanceStep> steps;

    setUp(() => steps = _steps(_plan(legs: [_leg()])));

    test('los pasos van en el orden en que se hacen', () {
      expect(steps.map((s) => s.runtimeType.toString()), [
        'WalkStep',
        'BoardStep',
        'RideStep',
        'WalkStep',
        'ArrivalStep',
      ]);
    });

    test('cada paso dice qué hacer, en imperativo', () {
      expect(steps[0].title, 'Caminá hasta Ameghino y French');
      expect(steps[1].title, 'Tomá la 3');
      expect(steps[2].title, 'Viajá 14 paradas');
      expect(steps[3].title, 'Caminá hasta tu destino');
      expect(steps.last.title, 'Llegaste');
    });

    test('el paso de viajar NO promete minutos', () {
      // Es lo que más se extraña y lo único que no se puede decir: no
      // sabemos a qué velocidad anda el colectivo.
      final detail = steps[2].detail!;
      expect(detail, isNot(contains('min')));
      expect(detail, isNot(matches(RegExp(r'\d+\s*min'))));
      expect(detail, 'Hasta Perrando');
    });

    test('el mapa mira la parada de subida cuando hay que subirse', () {
      expect(steps[1].focusLat, -27.45);
      expect(steps.last.focusLat, -27.46, reason: 'la llegada mira el destino');
    });
  });

  group('una parada sola se dice en singular', () {
    test('', () {
      final steps = _steps(_plan(legs: [_leg(stops: 1)]));
      expect(steps.firstWhere((s) => s is RideStep).title, 'Viajá 1 parada');
    });
  });

  group('con transbordo', () {
    late List<GuidanceStep> steps;

    setUp(() {
      steps = _steps(
        _plan(
          legs: [
            _leg(alight: 'Plaza 25 de Mayo'),
            _leg(code: '110', board: 'Plaza 25 de Mayo', alight: 'Perrando'),
          ],
        ),
      );
    });

    test('el bajarse y el tomar el otro son UN paso, no dos', () {
      // Son el mismo movimiento y separarlos haría tocar "siguiente" parado
      // en la misma esquina.
      expect(steps.whereType<TransferStep>(), hasLength(1));
      expect(
        steps.whereType<TransferStep>().single.title,
        'Bajate y tomá la 110',
      );
    });

    test('avisa que se paga otro boleto', () {
      // Es el dato que nadie te da y que te deja sin plata a mitad de viaje.
      expect(
        steps.whereType<TransferStep>().single.detail,
        contains('otro boleto'),
      );
    });

    test('hay un paso de viajar por cada tramo', () {
      expect(steps.whereType<RideStep>(), hasLength(2));
    });
  });

  group('caminatas cortas', () {
    test('menos de 50 m NO es un paso: es llegar', () {
      // Un paso que dice "caminá 20 metros" hace perder tiempo, no ayuda.
      final steps = _steps(
        _plan(legs: [_leg()], walkToBoard: 20, walkFromAlight: 15),
      );
      expect(steps.whereType<WalkStep>(), isEmpty);
      expect(steps.map((s) => s.runtimeType.toString()), [
        'BoardStep',
        'RideStep',
        'ArrivalStep',
      ]);
    });

    test('la de ida puede saltarse y la de vuelta no', () {
      final steps = _steps(
        _plan(legs: [_leg()], walkToBoard: 10, walkFromAlight: 400),
      );
      final walks = steps.whereType<WalkStep>();
      expect(walks, hasLength(1));
      expect(walks.single.isFinal, isTrue);
    });
  });

  test('un plan sin tramos no genera pasos', () {
    expect(_steps(_plan(legs: const [])), isEmpty);
  });

  test('siempre termina en "Llegaste"', () {
    for (final plan in [
      _plan(legs: [_leg()]),
      _plan(legs: [_leg(), _leg(code: '110')]),
      _plan(legs: [_leg()], walkToBoard: 0, walkFromAlight: 0),
    ]) {
      expect(_steps(plan).last, isA<ArrivalStep>());
    }
  });
}
