import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rutalibre/features/transit/domain/entities/place.dart';
import 'package:rutalibre/features/transit/domain/entities/stop.dart';
import 'package:rutalibre/features/transit/presentation/utils/destination_search.dart';
import 'package:rutalibre/features/transit/presentation/utils/place_aliases.dart';
import 'package:rutalibre/features/transit/presentation/utils/search_text.dart';

Place _place(String name) =>
    Place(name: name, lat: -27.45, lng: -58.98, kind: PlaceKind.otro);

List<String> _names(List<Destination> results) => [
  for (final r in results) r.name,
];

/// Los lugares de verdad, del asset que empaqueta la app.
List<Place> _realPlaces() {
  final json =
      jsonDecode(File('assets/places.json').readAsStringSync())
          as Map<String, dynamic>;
  return [
    for (final p in (json['p'] as List).cast<Map<String, dynamic>>())
      Place(
        name: p['n'] as String,
        lat: (p['y'] as num).toDouble(),
        lng: (p['x'] as num).toDouble(),
        kind: PlaceKind.parse(p['k'] as String),
      ),
  ];
}

void main() {
  const aliases = {
    'terminal': ['Terminal Resistencia', 'Terminal Corrientes'],
    'hospital llano': ['Hospital de la señora Llano'],
  };
  final places = [
    _place('La Terminal'),
    _place('Terminal Corrientes'),
    _place('Terminal Resistencia'),
    _place('Hospital de la señora Llano'),
    _place('Hospital Perrando'),
    _place('La Rioja'),
  ];

  List<String> search(String query) => _names(
    searchDestinations(
      query: query,
      places: places,
      stops: const [Stop(id: 's', name: 'Terminal', lat: 0, lng: 0)],
      aliases: aliases,
    ),
  );

  test('un apodo pone sus lugares arriba, en su orden', () {
    final results = search('terminal');
    expect(results.take(2), ['Terminal Resistencia', 'Terminal Corrientes']);
    // Lo demás sigue estando, más abajo.
    expect(results, containsAll(['La Terminal', 'Terminal']));
  });

  test('alcanza con el comienzo, desde la tercera letra', () {
    expect(search('ter').first, 'Terminal Resistencia');
    expect(search('te').first, isNot('Terminal Resistencia'));
  });

  test('una palabra suelta no dispara un apodo de dos', () {
    // "hospital" tiene que ordenar como siempre, no subir al Llano.
    expect(search('hospital').first, 'Hospital Perrando');
    expect(search('hospital ll').first, 'Hospital de la señora Llano');
  });

  test('lo que no es apodo se encuentra como antes', () {
    expect(search('perrando'), ['Hospital Perrando']);
  });

  group('con los lugares de verdad', () {
    final real = _realPlaces();
    final names = {for (final p in real) p.name};

    test('cada nombre de un apodo existe en assets/places.json', () {
      for (final MapEntry(key: alias, value: targets) in placeAliases.entries) {
        expect(
          alias,
          normalizeForSearch(alias),
          reason: 'la clave va normalizada',
        );
        for (final target in targets) {
          expect(names, contains(target), reason: 'apodo "$alias"');
        }
      }
    });

    List<String> first(String query, int n) => _names(
      searchDestinations(query: query, places: real, stops: const []),
    ).take(n).toList();

    test('"utn" es la facultad, no la calle Gutnisky', () {
      expect(
        first('utn', 1).single,
        'Universidad Tecnológica Nacional - Facultad Regional Resistencia',
      );
    });

    test('"unne" son los campus, no las bibliotecas', () {
      expect(first('unne', 2), [
        'Campus Resistencia Universidad Nacional del Nordeste',
        'Campus Deodoro Roca',
      ]);
    });

    test('"facu" son las facultades, no bibliotecas ni la calle Facundo', () {
      final results = first('facu', placeAliases['facultad']!.length + 1);
      expect(results.first, startsWith('Universidad Tecnológica Nacional'));
      expect(
        results.where(
          (n) => n.startsWith('Biblioteca') || n.startsWith('Facundo'),
        ),
        isEmpty,
      );
    });

    test('"terminal" son las dos terminales de ómnibus', () {
      expect(first('terminal', 2), [
        'Estación Terminal de Omnibus',
        'Terminal de  Ómnibus Corrientes Capital',
      ]);
    });
  });
}
