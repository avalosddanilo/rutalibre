/// Arregla los caracteres que Android dibuja como EMOJI A COLOR.
///
/// **El problema.** Los nombres de las líneas y los recorridos vienen con
/// flechas: "Chaco ↔ Corrientes", "Ida: Terminal → Campus". En Android, `↔`
/// (U+2194) tiene una presentación de emoji definida por Unicode, y el
/// sistema la elige: en vez de una flechita fina del mismo color que el texto
/// aparece un emoji celeste, con otro tamaño y otra línea de base. Al lado de
/// una tipografía cuidada canta como un moco.
///
/// **La solución.** El propio Unicode tiene el interruptor: el selector de
/// variación **U+FE0E** pegado atrás de un carácter dice "este quiero verlo
/// como TEXTO, no como emoji". Es el mecanismo estándar y no cambia el
/// significado ni el contenido — la cadena sigue diciendo lo mismo, y quien
/// la copie al portapapeles se lleva la flecha de siempre.
///
/// **Por qué acá y no en los datos.** Podría arreglarse en el seed, pero eso
/// obligaría a regenerar 890 KB de SQL y a correrlo a mano en Supabase para
/// arreglar algo que es puramente de cómo se DIBUJA. La base guarda el texto;
/// la pantalla decide cómo se ve.
library;

/// Selector de variación de texto (VS15). Invisible, sin ancho.
const _textPresentation = '︎';

/// Los caracteres que Android puede llegar a dibujar como emoji.
///
/// Lista corta y explícita en vez de un rango: recorrer todos los símbolos
/// con presentación de emoji le pondría el selector a cosas que hoy se ven
/// bien, y cada uno agregado es un carácter más en cadenas que se comparan.
const _emojiRisk = {'↔', '→', '←', '↕', '▶', '◀', '⬅', '➡', '⚠', '✔', '✖'};

/// El mismo texto, pero pidiendo que los símbolos se dibujen como texto.
///
/// Se aplica al MOSTRAR. No se guarda así ni se compara así: `searchText` y
/// los favoritos siguen trabajando con la cadena original.
String displayText(String value) {
  if (value.isEmpty) return value;
  final buffer = StringBuffer();
  for (final rune in value.runes) {
    final char = String.fromCharCode(rune);
    buffer.write(char);
    if (_emojiRisk.contains(char)) buffer.write(_textPresentation);
  }
  return buffer.toString();
}
