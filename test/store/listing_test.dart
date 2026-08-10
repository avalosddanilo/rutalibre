// Los textos de la ficha de Play viven en `docs/ficha-play.md` y tienen
// límites de caracteres que los impone Google. Este test los cuenta.
//
// **Por qué un test y no confiar en el formulario**: Play Console recorta o
// rechaza al pegar, con el navegador abierto y a mitad de la publicación. Es
// mucho mejor enterarse ahora — y sobre todo, que se entere el que edite el
// texto dentro de seis meses.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Los topes de Google, por título de sección del documento.
const _limits = {
  'Nombre de la aplicación': 30,
  'Descripción corta': 80,
  'Descripción completa': 4000,
  'Novedades de esta versión': 500,
};

/// El primer bloque ``` que aparece después de cada `## `.
Map<String, String> _blocksByHeading(String markdown) {
  final blocks = <String, String>{};
  String? heading;
  var inBlock = false;
  final buffer = StringBuffer();

  for (final line in markdown.split('\n')) {
    if (line.startsWith('## ')) {
      // El título viene con el límite entre paréntesis: se corta ahí.
      heading = line.substring(3).split('(').first.trim();
      continue;
    }
    if (line.trimRight() == '```') {
      if (inBlock) {
        if (heading != null && !blocks.containsKey(heading)) {
          blocks[heading] = buffer.toString().trimRight();
        }
        buffer.clear();
        inBlock = false;
      } else {
        inBlock = true;
      }
      continue;
    }
    if (inBlock) buffer.writeln(line);
  }
  return blocks;
}

void main() {
  late Map<String, String> blocks;

  setUpAll(() {
    blocks = _blocksByHeading(File('docs/ficha-play.md').readAsStringSync());
  });

  test('están los cuatro textos de la ficha', () {
    // Si alguien renombra una sección, esto lo dice en vez de dejar de
    // verificar el texto en silencio.
    for (final heading in _limits.keys) {
      expect(
        blocks[heading],
        isNotNull,
        reason: 'falta la sección "$heading" en docs/ficha-play.md',
      );
      expect(blocks[heading]!.trim(), isNotEmpty, reason: heading);
    }
  });

  test('ninguno pasa el límite de caracteres de Google', () {
    _limits.forEach((heading, limit) {
      final text = blocks[heading] ?? '';
      expect(
        text.length,
        lessThanOrEqualTo(limit),
        reason:
            '"$heading" tiene ${text.length} caracteres y el tope es $limit. '
            'Play lo rechaza al pegarlo.',
      );
    });
  });

  test('la descripción corta no promete lo que la app no hace', () {
    // Guardarraíl de honestidad, que es la regla del proyecto: la app NO tiene
    // los horarios (hay uno de 32 líneas) ni el colectivo en tiempo real.
    final corta = blocks['Descripción corta']!.toLowerCase();
    expect(corta, isNot(contains('horario')));
    expect(corta, isNot(contains('tiempo real')));
    expect(corta, isNot(contains('en vivo')));
  });

  test('la descripción completa dice qué falta', () {
    // Quien baja una app de colectivos esperando la tabla de horarios y no la
    // encuentra deja una estrella. Decirlo antes es lo que evita eso, así que
    // el aviso no puede desaparecer sin que nadie se entere.
    final completa = blocks['Descripción completa']!;
    expect(completa, contains('QUÉ FALTA'));
    expect(completa, contains('ninguna fuente abierta'));
    // Y la regla del proyecto, con todas las letras.
    expect(completa, contains('no sabemos'));
  });
}
