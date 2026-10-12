/// Partir un script SQL en pedazos que entren en el SQL Editor de Supabase.
///
/// **Por qué existe.** `seed_corrientes.sql` pesa 1,5 MB y el editor web no
/// lo acepta de una. Sin `psql` en la máquina, la única vía es pegarlo por
/// partes.
///
/// **La regla que lo hace seguro: no se reescribe nada.** Se corta sólo
/// ENTRE sentencias, nunca adentro de una, así que lo que corre en la base
/// es exactamente el SQL original. Eso es verificable sin una base de
/// datos: [partirSentencias] es sin pérdida — concatenar lo que devuelve da
/// el archivo original byte por byte, y hay un test que lo exige.
///
/// **Lo que sí cambia, y hay que saberlo.** El original es UNA transacción
/// (`begin` … `commit`); partido, cada parte es su propia transacción. Entre
/// parte y parte la base queda con una carga a medias. Para un script hecho
/// de upserts y de "borrar y volver a cargar" eso se arregla corriendo todo
/// de nuevo desde la parte 1; para cualquier otro script, NO usar esto sin
/// pensarlo.
library;

/// Una sentencia tal cual estaba en el archivo, con los comentarios y los
/// espacios que la preceden. La última puede no tener `;` (lo que sobra al
/// final del archivo, típicamente comentarios).
typedef Sentencia = String;

/// Corta [sql] en sentencias, respetando comillas y comentarios: un `;`
/// adentro de `'texto; con punto y coma'`, de un `"identificador"` o de un
/// comentario no corta nada.
///
/// No entiende dollar-quoting (`$$ … $$`). Si el archivo lo usa, se rechaza
/// en vez de cortar mal: es el tipo de error que no avisa.
List<Sentencia> partirSentencias(String sql) {
  if (sql.contains(r'$$')) {
    throw const FormatException(
      r'El script usa dollar-quoting ($$): este partidor no lo entiende.',
    );
  }
  final salida = <Sentencia>[];
  var inicio = 0;
  var i = 0;
  while (i < sql.length) {
    final c = sql[i];
    if (c == "'" || c == '"') {
      // Las comillas se escapan duplicándose (''), y eso es cerrar y volver
      // a abrir: recorrer hasta la próxima comilla igual alcanza.
      final cierre = sql.indexOf(c, i + 1);
      if (cierre < 0) throw FormatException('Comilla sin cerrar', sql, i);
      i = cierre + 1;
    } else if (c == '-' && i + 1 < sql.length && sql[i + 1] == '-') {
      final fin = sql.indexOf('\n', i);
      i = fin < 0 ? sql.length : fin + 1;
    } else if (c == '/' && i + 1 < sql.length && sql[i + 1] == '*') {
      final fin = sql.indexOf('*/', i + 2);
      if (fin < 0) throw FormatException('Comentario sin cerrar', sql, i);
      i = fin + 2;
    } else if (c == ';') {
      salida.add(sql.substring(inicio, i + 1));
      inicio = i + 1;
      i++;
    } else {
      i++;
    }
  }
  if (inicio < sql.length) salida.add(sql.substring(inicio));
  return salida;
}

/// El texto de la sentencia sin comentarios ni espacios, en minúsculas.
/// Sirve para reconocerla, no para correrla.
String nucleo(Sentencia s) => s
    .split('\n')
    .map((l) => l.trimLeft().startsWith('--') ? '' : l)
    .join('\n')
    .trim()
    .toLowerCase();

bool _esControlDeTransaccion(Sentencia s) {
  final n = nucleo(s).replaceAll(';', '').trim();
  return n == 'begin' || n == 'commit';
}

/// True si la sentencia es sólo comentarios o espacios (lo que sobra al
/// final del archivo).
bool esVacia(Sentencia s) => nucleo(s).replaceAll(';', '').trim().isEmpty;

/// Las partes listas para pegar, cada una envuelta en su propio
/// `begin` / `commit`. El `begin` y el `commit` del original se sacan: si
/// quedaran, el `begin` iría a parar adentro de la primera parte y el
/// `commit` a la última, y las del medio correrían sin transacción.
///
/// Una sentencia nunca se parte: si sola supera [maxBytes], va sola en su
/// parte y queda más grande que el límite.
List<String> armarPartes(
  List<Sentencia> sentencias, {
  required int maxBytes,
  String Function(int numero, int total)? encabezado,
}) {
  final cuerpo = sentencias
      .where((s) => !_esControlDeTransaccion(s) && !esVacia(s))
      .toList();
  final grupos = <List<Sentencia>>[];
  var actual = <Sentencia>[];
  var tam = 0;
  for (final s in cuerpo) {
    final n = s.length;
    if (actual.isNotEmpty && tam + n > maxBytes) {
      grupos.add(actual);
      actual = [];
      tam = 0;
    }
    actual.add(s);
    tam += n;
  }
  if (actual.isNotEmpty) grupos.add(actual);

  return [
    for (var i = 0; i < grupos.length; i++)
      '${encabezado?.call(i + 1, grupos.length) ?? ''}'
          'begin;\n'
          '${grupos[i].join()}\n'
          'commit;\n',
  ];
}

/// Qué hace una parte, para poder verificar las cuentas antes de pegarla:
/// cuántos `insert` por tabla, cuántos `update` y `delete`.
Map<String, int> resumen(String parte) {
  final cuenta = <String, int>{};
  for (final s in partirSentencias(parte)) {
    final n = nucleo(s);
    final m = RegExp(
      r'^(insert into|update|delete from)\s+([\w.]+)',
    ).firstMatch(n);
    if (m == null) continue;
    final clave = '${m.group(1)!.split(' ').first} ${m.group(2)}';
    cuenta[clave] = (cuenta[clave] ?? 0) + 1;
  }
  return cuenta;
}
