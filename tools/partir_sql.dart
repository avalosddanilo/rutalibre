// Parte un script SQL en pedazos que entren en el SQL Editor de Supabase.
//
//   dart run tools/partir_sql.dart supabase/seed/seed_corrientes.sql
//
// Deja las partes en `build/sql/` (gitignoreado: son copias, no van al
// repo) y muestra qué hace cada una. Se pegan EN ORDEN, de a una.
//
// No reescribe nada: corta entre sentencias. La lógica y por qué es seguro,
// en `tools/src/partir_sql.dart`.
import 'dart:io';

import 'src/partir_sql.dart';

/// Tamaño máximo de cada parte. El editor no aceptó 1,5 MB; con 240 KB el
/// seed de Corrientes queda en 7 partes. Si el editor rechaza una, bajarlo.
const _maxBytesPorDefecto = 240000;

void main(List<String> args) {
  final archivos = args.where((a) => !a.startsWith('--')).toList();
  final maxArg = args.firstWhere(
    (a) => a.startsWith('--max='),
    orElse: () => '',
  );
  final maxBytes = maxArg.isEmpty
      ? _maxBytesPorDefecto
      : int.parse(maxArg.substring('--max='.length));
  if (archivos.length != 1) {
    stderr.writeln(
      'uso: dart run tools/partir_sql.dart ARCHIVO.sql [--max=240000]',
    );
    exit(2);
  }

  final origen = File(archivos.single);
  final sql = origen.readAsStringSync();
  final sentencias = partirSentencias(sql);

  // El control que hace confiable todo lo demás: el corte no perdió ni
  // agregó un solo carácter.
  if (sentencias.join() != sql) {
    stderr.writeln(
      'ERROR: al volver a unir las sentencias no da el archivo '
      'original. No se genera nada.',
    );
    exit(1);
  }

  final base = origen.uri.pathSegments.last.replaceAll('.sql', '');
  final partes = armarPartes(
    sentencias,
    maxBytes: maxBytes,
    encabezado: (n, total) =>
        '-- $base — parte $n de $total.\n'
        '-- Generado por tools/partir_sql.dart. Pegar EN ORDEN, de a una.\n'
        '-- Si una falla, avisá antes de seguir: se arregla corriendo todo\n'
        '-- de nuevo desde la parte 1, no repitiendo sólo la que falló.\n\n',
  );

  final dir = Directory('build/sql')..createSync(recursive: true);
  for (final f in dir.listSync().whereType<File>()) {
    if (f.uri.pathSegments.last.startsWith('$base.parte')) f.deleteSync();
  }

  final total = <String, int>{};
  for (var i = 0; i < partes.length; i++) {
    final nombre = '$base.parte${(i + 1).toString().padLeft(2, '0')}.sql';
    File('${dir.path}/$nombre').writeAsStringSync(partes[i]);
    final r = resumen(partes[i]);
    r.forEach((k, v) => total[k] = (total[k] ?? 0) + v);
    final kb = (partes[i].length / 1024).round();
    stdout.writeln(
      '$nombre  ${kb.toString().padLeft(4)} KB  '
      '${r.entries.map((e) => '${e.value} ${e.key}').join(', ')}',
    );
  }
  stdout.writeln(
    '\nTotal: ${total.entries.map((e) => '${e.value} ${e.key}').join(', ')}',
  );
  stdout.writeln('Partes en ${dir.path}/');
}
