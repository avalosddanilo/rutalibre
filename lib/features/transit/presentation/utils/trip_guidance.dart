/// El viaje partido en pasos, para ir siguiéndolo mientras se hace.
///
/// **Qué NO es esto.** No es el "navegar" de Google Maps: no hay indicaciones
/// giro a giro —no tenemos un motor de ruteo por calles— ni "el colectivo
/// llega en 3 minutos" —no hay posición de las unidades—. Prometer cualquiera
/// de las dos sería inventar.
///
/// Lo que sí es: los cuatro o cinco momentos del viaje, uno por pantalla,
/// grandes, para no tener que releer la lista entera parado en la vereda con
/// el colectivo viniendo. Cada dato es real: los metros los calcula
/// [WalkEstimate], la línea y las paradas salen del planificador, y las
/// paradas que se viajan las cuenta la base.
library;

import '../../domain/entities/trip_plan.dart';
import '../../domain/entities/walk_estimate.dart';

/// Un momento del viaje.
sealed class GuidanceStep {
  const GuidanceStep();

  /// Qué hay que hacer, en imperativo y corto.
  String get title;

  /// El detalle que hace falta para hacerlo. Puede ser null.
  String? get detail;

  /// Dónde mira el mapa en este paso.
  double get focusLat;
  double get focusLng;
}

/// Caminar: del origen a la parada, o de la parada al destino.
final class WalkStep extends GuidanceStep {
  const WalkStep({
    required this.meters,
    required this.toName,
    required this.focusLat,
    required this.focusLng,
    required this.isFinal,
  });

  final double meters;

  /// A dónde se llega caminando. El destino final no tiene nombre de parada,
  /// así que se dice "tu destino".
  final String toName;

  @override
  final double focusLat;
  @override
  final double focusLng;

  /// True en la última caminata, la que termina el viaje.
  final bool isFinal;

  @override
  String get title => 'Caminá hasta $toName';

  @override
  String? get detail => WalkEstimate(meters: meters).label;
}

/// Subirse al colectivo.
final class BoardStep extends GuidanceStep {
  const BoardStep(this.leg);

  final TripLeg leg;

  @override
  String get title => 'Tomá la ${leg.displayCode}';

  @override
  String get detail => 'En ${leg.boardStop.name}';

  @override
  double get focusLat => leg.boardStop.lat;
  @override
  double get focusLng => leg.boardStop.lng;
}

/// Viajar arriba del colectivo.
final class RideStep extends GuidanceStep {
  const RideStep(this.leg);

  final TripLeg leg;

  @override
  String get title =>
      leg.stopCount == 1 ? 'Viajá 1 parada' : 'Viajá ${leg.stopCount} paradas';

  /// **Sin minutos.** Es lo que más se extraña y es lo que no se puede decir:
  /// no sabemos a qué velocidad anda el colectivo. Un número acá manda a
  /// alguien a bajarse antes de tiempo.
  @override
  String get detail => 'Hasta ${leg.alightStop.name}';

  @override
  double get focusLat => leg.alightStop.lat;
  @override
  double get focusLng => leg.alightStop.lng;
}

/// Bajarse, para hacer el transbordo.
final class TransferStep extends GuidanceStep {
  const TransferStep({required this.at, required this.next});

  final TripLeg at;
  final TripLeg next;

  @override
  String get title => 'Bajate y tomá la ${next.displayCode}';

  @override
  String get detail => 'En ${at.alightStop.name} · pagás otro boleto';

  @override
  double get focusLat => at.alightStop.lat;
  @override
  double get focusLng => at.alightStop.lng;
}

/// Llegaste.
final class ArrivalStep extends GuidanceStep {
  const ArrivalStep({required this.focusLat, required this.focusLng});

  @override
  final double focusLat;
  @override
  final double focusLng;

  @override
  String get title => 'Llegaste';

  @override
  String? get detail => null;
}

/// Arma los pasos del viaje, en orden.
///
/// La caminata inicial y la final **se saltean si son de menos de
/// [_skipWalkMeters]**: un paso que dice "caminá 20 metros" es un paso que
/// hace perder tiempo, no que ayuda.
List<GuidanceStep> guidanceSteps({
  required TripPlan plan,
  required double originLat,
  required double originLng,
  required double destinationLat,
  required double destinationLng,
}) {
  if (plan.legs.isEmpty) return const [];

  final steps = <GuidanceStep>[];
  final first = plan.legs.first;

  if (plan.walkToBoardMeters >= _skipWalkMeters) {
    steps.add(
      WalkStep(
        meters: plan.walkToBoardMeters,
        toName: first.boardStop.name,
        focusLat: first.boardStop.lat,
        focusLng: first.boardStop.lng,
        isFinal: false,
      ),
    );
  }

  for (var i = 0; i < plan.legs.length; i++) {
    final leg = plan.legs[i];
    // El "tomá la X" del primer tramo va solo; el de un tramo siguiente va
    // pegado al "bajate", porque es un mismo movimiento y separarlos haría
    // tocar "siguiente" parado en la misma esquina.
    if (i == 0) steps.add(BoardStep(leg));
    steps.add(RideStep(leg));
    if (i < plan.legs.length - 1) {
      steps.add(TransferStep(at: leg, next: plan.legs[i + 1]));
    }
  }

  if (plan.walkFromAlightMeters >= _skipWalkMeters) {
    steps.add(
      WalkStep(
        meters: plan.walkFromAlightMeters,
        toName: 'tu destino',
        focusLat: destinationLat,
        focusLng: destinationLng,
        isFinal: true,
      ),
    );
  }

  steps.add(ArrivalStep(focusLat: destinationLat, focusLng: destinationLng));
  return steps;
}

/// Por debajo de esto, caminar no es un paso: es llegar.
const _skipWalkMeters = 50.0;
