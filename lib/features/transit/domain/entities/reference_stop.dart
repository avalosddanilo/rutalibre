import 'package:equatable/equatable.dart';

/// Una parada que sabemos que existe, pero que NO entra al planificador.
///
/// **Por qué existe una segunda clase de parada.** En Corrientes capital hay
/// 254 paradas mapeadas en OpenStreetMap, con los números de línea que paran
/// en cada una. Pero el dataset municipal de recorridos solo publica 10 de
/// las 22 líneas que esas paradas mencionan, y de las 254 apenas 93 caen a
/// menos de 80 m del recorrido de su propia línea.
///
/// Con datos así de ralos, meterlas al planificador sería peor que no
/// tenerlas: "¿cómo llego?" mandaría a caminar un kilómetro hasta la única
/// parada que conoce, teniendo una en la esquina. Parecería una respuesta y
/// estaría mal.
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
