import '../../domain/entities/bus_line.dart';
import '../../domain/entities/transit_network.dart';

/// DTO de `lines`. Extiende la entidad: un modelo ES una BusLine con
/// conocimiento extra de serialización (snake_case de Postgres ↔ Dart).
///
/// `fromJson` acepta tanto la respuesta de Supabase como el JSON de la
/// cache local: son el mismo formato a propósito (ver `toJson`).
///
/// La red llega EMBEBIDA (`networks: {code, name}`) porque el select del
/// datasource remoto la trae con un join de PostgREST; así una línea se
/// resuelve en un solo viaje.
final class BusLineModel extends BusLine {
  const BusLineModel({
    required super.id,
    required super.code,
    required super.name,
    required super.colorHex,
    required super.network,
    super.sortOrder,
    super.destinations,
  });

  factory BusLineModel.fromJson(Map<String, dynamic> json) => BusLineModel(
    id: json['id'] as String,
    code: json['code'] as String,
    name: json['name'] as String,
    colorHex: json['color_hex'] as String,
    // `sort_order` puede faltar en cache vieja (v1) — no vale invalidar
    // toda la cache por un campo de presentación.
    sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    // Igual que `sort_order`: puede faltar (base sin la migración 0009, o
    // cache anterior). Vacío significa "no sé los destinos", y la búsqueda
    // cae al nombre — que es exactamente como funcionaba antes.
    destinations: switch (json['destinations']) {
      final List<dynamic> list => list.map((e) => e.toString()).toList(),
      _ => const <String>[],
    },
    network: _networkFromJson(json['networks']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'name': name,
    'destinations': destinations,
    'color_hex': colorHex,
    'sort_order': sortOrder,
    'networks': {
      'code': network.code,
      'name': network.name,
      'sort_order': network.sortOrder,
    },
  };

  static TransitNetwork _networkFromJson(Object? raw) {
    // PostgREST devuelve el join embebido como objeto; si el día de mañana
    // llega como lista de un elemento, se toma el primero.
    final map = switch (raw) {
      Map<String, dynamic> map => map,
      List<dynamic> list when list.isNotEmpty =>
        list.first as Map<String, dynamic>,
      _ => null,
    };
    if (map == null) {
      throw const FormatException('lines.networks ausente en la respuesta');
    }
    return TransitNetwork(
      code: map['code'] as String,
      name: map['name'] as String,
      // Puede faltar en cache vieja: 0 es un default sano (todas las redes
      // empatan y desempata el código).
      sortOrder: (map['sort_order'] as num?)?.toInt() ?? 0,
    );
  }
}
