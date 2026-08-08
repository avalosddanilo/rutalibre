/// Normalización de texto para buscar líneas.
///
/// Buscar "peron" tiene que encontrar "Barrio Perón": en el Gran Resistencia
/// medio callejero lleva tilde y nadie la escribe al teclear apurado en la
/// parada.
library;

const _accented = 'áàäâãéèëêíìïîóòöôõúùüûñç';
const _plain = 'aaaaaeeeeiiiiooooouuuunc';

/// Minúsculas, sin tildes y sin espacios de más.
String normalizeForSearch(String value) {
  final lower = value.toLowerCase().trim();
  final buffer = StringBuffer();
  for (final rune in lower.runes) {
    final char = String.fromCharCode(rune);
    final index = _accented.indexOf(char);
    buffer.write(index >= 0 ? _plain[index] : char);
  }
  return buffer.toString().replaceAll(RegExp(r'\s+'), ' ');
}

/// True si [haystack] contiene [needle] ignorando tildes y mayúsculas.
bool matchesSearch(String haystack, String needle) {
  final query = normalizeForSearch(needle);
  if (query.isEmpty) return true;
  return normalizeForSearch(haystack).contains(query);
}
