// El contrato entre los seeds y las migraciones: todo `on conflict` de un
// seed tiene que tener una restricción única que lo respalde.
//
// **Por qué existe.** La migración 0013 creó el índice único de
// `stops.source_ref` PARCIAL (`where source_ref is not null`), y el seed de
// Corrientes —generado en el mismo commit— hacía `on conflict (source_ref)`
// sin repetir esa condición. Postgres no puede usar un índice parcial como
// blanco de un `on conflict` si la sentencia no la repite, y falla con
// 42P10. Ningún test lo veía porque el seed nunca se había corrido contra
// una base con la 0013: se descubrió aplicándolo en producción (sin daño,
// porque el seed es una transacción y se deshizo entero).
//
// Este test lee el SQL de los dos lados y lo cruza, sin base de datos. No
// es un parser de SQL: entiende lo que estas migraciones usan —`create
// unique index`, `primary key`, `unique` de tabla y de columna, y `drop
// constraint`— y nada más. Si alguien agrega otra forma, el test va a dar
// un falso rojo, que es el lado correcto para equivocarse.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Una restricción única: tabla, columnas (o expresiones) y la condición
/// del índice parcial, o '' si no es parcial.
typedef Clave = ({String tabla, String columnas, String condicion});

String _norm(String s) => s
    .toLowerCase()
    .replaceAll('public.', '')
    .replaceAll(RegExp(r'\s+'), ' ')
    .replaceAll('( ', '(')
    .replaceAll(' )', ')')
    .trim();

String _sinComentarios(String sql) =>
    sql.split('\n').map((l) => l.replaceFirst(RegExp(r'--.*$'), '')).join('\n');

/// Lo que hay entre el paréntesis que abre en [desde] y el que lo cierra,
/// respetando paréntesis anidados (`coalesce(branch, '')`).
String _entreParentesis(String s, int desde) {
  var nivel = 0;
  for (var i = desde; i < s.length; i++) {
    if (s[i] == '(') nivel++;
    if (s[i] == ')' && --nivel == 0) return s.substring(desde + 1, i);
  }
  throw FormatException('Paréntesis sin cerrar', s, desde);
}

Set<Clave> _clavesDeLasMigraciones() {
  final claves = <String, Clave>{}; // por nombre, para poder borrarlas
  final archivos =
      Directory('supabase/migrations')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.sql'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  for (final f in archivos) {
    final sql = _sinComentarios(f.readAsStringSync()).toLowerCase();

    // create table public.x ( ... );
    for (final m in RegExp(
      r'create table (?:if not exists )?(?:public\.)?(\w+)\s*\(',
    ).allMatches(sql)) {
      final tabla = m.group(1)!;
      final cuerpo = _entreParentesis(sql, m.end - 1);
      // Partir por comas de primer nivel.
      final partes = <String>[];
      var nivel = 0, ini = 0;
      for (var i = 0; i < cuerpo.length; i++) {
        if (cuerpo[i] == '(') nivel++;
        if (cuerpo[i] == ')') nivel--;
        if (cuerpo[i] == ',' && nivel == 0) {
          partes.add(cuerpo.substring(ini, i));
          ini = i + 1;
        }
      }
      partes.add(cuerpo.substring(ini));
      for (final p in partes.map((p) => p.trim())) {
        final tablaNivel = RegExp(r'^(primary key|unique)\s*\(').firstMatch(p);
        if (tablaNivel != null) {
          final cols = _entreParentesis(p, tablaNivel.end - 1);
          final nombre = tablaNivel.group(1) == 'primary key'
              ? '${tabla}_pkey'
              : '${tabla}_${cols.replaceAll(RegExp(r'[\s,]+'), '_')}_key';
          claves[nombre] = (tabla: tabla, columnas: _norm(cols), condicion: '');
          continue;
        }
        final columna = RegExp(r'^(\w+)\s').firstMatch(p)?.group(1);
        if (columna == null) continue;
        if (RegExp(r'\bprimary key\b').hasMatch(p)) {
          claves['${tabla}_pkey'] = (
            tabla: tabla,
            columnas: columna,
            condicion: '',
          );
        } else if (RegExp(r'\bunique\b').hasMatch(p)) {
          claves['${tabla}_${columna}_key'] = (
            tabla: tabla,
            columnas: columna,
            condicion: '',
          );
        }
      }
    }

    // create unique index [if not exists] nombre on public.x (cols) [where ...];
    for (final m in RegExp(
      r'create unique index (?:if not exists )?(\w+)\s+on (?:public\.)?(\w+)\s*\(',
    ).allMatches(sql)) {
      final cols = _entreParentesis(sql, m.end - 1);
      final resto = sql.substring(m.end - 1 + cols.length + 2);
      final fin = resto.indexOf(';');
      final cola = (fin < 0 ? resto : resto.substring(0, fin)).trim();
      final condicion = cola.startsWith('where ') ? cola.substring(6) : '';
      claves[m.group(1)!] = (
        tabla: m.group(2)!,
        columnas: _norm(cols),
        condicion: _norm(condicion),
      );
    }

    for (final m in RegExp(
      r'drop (?:constraint|index) (?:if exists )?(\w+)',
    ).allMatches(sql)) {
      claves.remove(m.group(1));
    }
  }
  return claves.values.toSet();
}

/// Los blancos de `on conflict` de un seed: (tabla, columnas, condición).
Set<Clave> _blancosDelSeed(File f) {
  final sql = _sinComentarios(f.readAsStringSync()).toLowerCase();
  final blancos = <Clave>{};
  for (final m in RegExp(r'insert into (?:public\.)?(\w+)\b').allMatches(sql)) {
    final fin = sql.indexOf(';', m.end);
    final sentencia = sql.substring(m.start, fin < 0 ? sql.length : fin);
    final oc = RegExp(r'on conflict\s*\(').firstMatch(sentencia);
    if (oc == null) continue;
    final cols = _entreParentesis(sentencia, oc.end - 1);
    final resto = sentencia.substring(oc.end - 1 + cols.length + 2);
    final hasta = RegExp(r'\bdo\b').firstMatch(resto)!.start;
    final cola = resto.substring(0, hasta).trim();
    blancos.add((
      tabla: m.group(1)!,
      columnas: _norm(cols),
      condicion: _norm(cola.startsWith('where ') ? cola.substring(6) : ''),
    ));
  }
  return blancos;
}

void main() {
  final claves = _clavesDeLasMigraciones();

  test('el índice de source_ref es parcial (el caso que originó esto)', () {
    expect(
      claves,
      contains((
        tabla: 'stops',
        columnas: 'source_ref',
        condicion: 'source_ref is not null',
      )),
    );
  });

  final seeds =
      Directory('supabase/seed')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.sql'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  for (final seed in seeds) {
    test(
      'cada on conflict de ${seed.uri.pathSegments.last} tiene respaldo',
      () {
        for (final b in _blancosDelSeed(seed)) {
          final candidatas = claves.where(
            (c) => c.tabla == b.tabla && c.columnas == b.columnas,
          );
          expect(
            candidatas,
            isNotEmpty,
            reason:
                'on conflict ${b.columnas} en ${b.tabla}: ninguna '
                'restricción única de las migraciones tiene esas columnas',
          );
          // Un índice parcial sólo se puede usar si la sentencia repite su
          // condición. Uno completo se puede usar siempre.
          final usable = candidatas.any(
            (c) => c.condicion.isEmpty || c.condicion == b.condicion,
          );
          expect(
            usable,
            isTrue,
            reason:
                'on conflict ${b.columnas} en ${b.tabla}: el índice es '
                'parcial (where ${candidatas.first.condicion}) y la sentencia '
                'no repite la condición — Postgres falla con 42P10',
          );
        }
      },
    );
  }
}
