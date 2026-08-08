import 'package:flutter_test/flutter_test.dart';
import 'package:rutalibre/features/transit/presentation/utils/display_text.dart';

/// El selector de variación de texto (VS15), U+FE0E.
const _vs15 = '\uFE0E';

void main() {
  test('a la flecha doble le pide presentación de TEXTO', () {
    // Sin esto, Android la dibuja como un emoji celeste con otro tamaño y
    // otra línea de base, al lado de la tipografía de la app.
    expect(displayText('Chaco ↔ Corrientes'), 'Chaco ↔$_vs15 Corrientes');
  });

  test('también a la flecha simple', () {
    expect(
      displayText('Ida: Terminal → Campus'),
      'Ida: Terminal →$_vs15 Campus',
    );
  });

  test('NO toca las letras, los números ni la puntuación', () {
    // Poner el selector donde no hace falta es un carácter invisible de más
    // en cadenas que después se comparan o se comparten.
    for (final texto in [
      'Vial y Monte Alto',
      '904B',
      r'$1.885 · vigente desde enero de 2026',
      'Ñandú, Güemes y Perón',
    ]) {
      expect(displayText(texto), texto);
    }
  });

  test('el texto vacío no rompe', () {
    expect(displayText(''), '');
  });

  test('varias flechas en la misma cadena', () {
    expect(displayText('A → B → C'), 'A →$_vs15 B →$_vs15 C');
  });

  test('el contenido no cambia: sacando el selector queda el original', () {
    // Importa porque esta cadena se puede copiar al portapapeles o
    // compartir, y del otro lado tiene que leerse normal.
    const original = 'Chaco ↔ Corrientes por Avenida Sarmiento';
    expect(displayText(original).replaceAll(_vs15, ''), original);
  });
}
