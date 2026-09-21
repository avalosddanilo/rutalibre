import 'package:equatable/equatable.dart';

/// Una parada que sabemos que existe, pero que NO entra al planificador.
///
/// **Por qué existe una segunda clase de parada.** En Corrientes capital hay
/// 254 paradas mapeadas en OpenStreetMap, con los números de línea que paran
/// en cada una. Pero el dataset municipal de recorridos solo publica 10 de
/// las 22 líneas que esas paradas mencionan.
///
/// **Las paradas sí encajan con los recorridos**: 202 de las 254 caen a menos
/// de 80 m del recorrido de una de sus líneas, con una mediana de 5 m. (Una
/// versión anterior de este comentario decía 93, medido contra el VÉRTICE más
/// cercano del trazado en vez del segmento — ver
/// `test/tools/corrientes_cobertura_test.dart`.)
///
/// Lo que falta es **cobertura pareja**. La 104 tiene una parada cada 61 m;
/// la 101 tiene UNA en doce kilómetros y el Aerobus ninguna. Meterlas al
/// planificador así contestaría bien para la 104 y mandaría a caminar
/// kilómetros para el resto: parecería una respuesta y estaría mal.
///
/// La diferencia importa, porque este motivo SÍ tiene arreglo: mapear paradas
/// en OSM, línea por línea. Cada línea que llegue a densidad usable es una
/// línea que puede entrar.
///
/// Entonces se muestran por lo que SON: dónde parar y qué líneas paran ahí.
/// Es lo que contesta la pregunta de quien está parado en la vereda en
/// Corrientes, donde hasta ahora el mapa no tenía ni una parada dibujada.
class ReferenceStop extends Equatable {
  const ReferenceStop({
    required this.name,
    required this.lat,
    required this.lng,
    required this.lines,
    this.osmNodeId,
  });

  /// La esquina, derivada del callejero. En OSM estas paradas no tienen
  /// nombre propio: tienen la lista de líneas.
  final String name;

  final double lat;
  final double lng;

  /// Los códigos de línea que paran acá, tal como los declara OpenStreetMap.
  final List<String> lines;

  /// El nodo de OSM del que salió. Ver `Stop.osmNodeId`: acá pesa todavía más
  /// porque estas paradas no las verifica nadie más que quien las use.
  ///
  /// Nullable solo por las versiones viejas del asset (`v: 1` no lo traía).
  final int? osmNodeId;

  @override
  List<Object?> get props => [name, lat, lng, lines, osmNodeId];
}
