/// Lector de CSV con comillas.
///
/// Hace falta uno propio porque el CSV de Corrientes mete la geometría
/// completa (`LINESTRING(x y, x y, ...)`) dentro de un campo entrecomillado:
/// partir por comas a lo bruto destroza el archivo.
///
/// Dart PURO — sin dependencias.
library;

/// Parte una línea de CSV respetando comillas dobles.
///
/// Sigue RFC 4180 en lo que importa acá: `""` dentro de un campo
/// entrecomillado es una comilla literal.
List<String> parseCsvLine(String line) {
  final fields = <String>[];
  final buffer = StringBuffer();
  var inQuotes = false;

  for (var i = 0; i < line.length; i++) {
    final char = line[i];
    if (char == '"') {
      if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
        buffer.write('"');
        i++;
      } else {
        inQuotes = !inQuotes;
      }
    } else if (char == ',' && !inQuotes) {
      fields.add(buffer.toString());
      buffer.clear();
    } else {
      buffer.write(char);
    }
  }
  fields.add(buffer.toString());
  return fields;
}

/// Un CSV ya parseado, accesible por nombre de columna.
///
/// Acceder por nombre y no por índice evita que agregar una columna en el
/// origen rompa el importer en silencio.
class CsvTable {
  CsvTable(this.headers, this.rows);

  factory CsvTable.parse(String content) {
    // Tolera \n y \r\n sin arrastrar dart:convert.
    final lines = content
        .split('\n')
        .map((l) => l.endsWith('\r') ? l.substring(0, l.length - 1) : l)
        .toList();
    if (lines.isEmpty) return CsvTable(const [], const []);
    final headers = parseCsvLine(
      lines.first,
    ).map((h) => h.trim()).toList(growable: false);
    final rows = <List<String>>[];
    for (var i = 1; i < lines.length; i++) {
      if (lines[i].trim().isEmpty) continue;
      rows.add(parseCsvLine(lines[i]));
    }
    return CsvTable(headers, rows);
  }

  final List<String> headers;
  final List<List<String>> rows;

  /// Valor de [column] en [row], o '' si la columna no existe o la fila
  /// viene corta.
  String value(List<String> row, String column) {
    final index = headers.indexOf(column);
    if (index < 0 || index >= row.length) return '';
    return row[index].trim();
  }

  /// Falla ruidosamente si el origen cambió de forma.
  void requireColumns(List<String> required) {
    final missing = required.where((c) => !headers.contains(c)).toList();
    if (missing.isNotEmpty) {
      throw FormatException(
        'Al CSV le faltan columnas: ${missing.join(', ')}. '
        'Tiene: ${headers.join(', ')}',
      );
    }
  }
}
