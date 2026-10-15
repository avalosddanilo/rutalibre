import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tools/src/corrientes_correcciones.dart';
import '../../tools/src/corrientes_import.dart';
import '../../tools/src/corrientes_stops_csv.dart';
import '../../tools/src/sql_emitter.dart' show lineStringWkt;

const _path = 'tools/data/corrientes_correcciones.json';

List<RouteCorrection> _real() => parseCorrections(
  jsonDecode(File(_path).readAsStringSync()) as Map<String, dynamic>,
);

CorrientesVariant _variant(String line, int direction) => CorrientesVariant(
  lineCode: line,
  branch: 'A',
  direction: direction,
  name: 'Ida',
  geometry: const [(lat: -27.0, lng: -58.0), (lat: -27.1, lng: -58.1)],
);

RouteCorrection _correction({List<int> gids = const [1, 2]}) => RouteCorrection(
  lineCode: '102',
  branch: 'A',
  direction: 0,
  validFrom: '2026-08-12',
  source: 'El Litoral',
  streets: 'Trento, Av. Perón',
  reviewed: '2026-10-15',
  stopGids: gids,
  geometry: const [
    (lat: -27.4897, lng: -58.7811),
    (lat: -27.4905, lng: -58.7849),
  ],
);

MunicipalStop _stop(int gid) => (
  gid: gid,
  direction: 0,
  ramalCodes: const ['102-A'],
  point: (lat: -27.49, lng: -58.78),
);

void main() {
  group('el archivo de correcciones', () {
    test('se lee, y cada corrección dice de dónde salió y quién la revisó', () {
      final all = _real();
      expect(all, isNotEmpty);
      for (final c in all) {
        expect(c.source, isNotEmpty, reason: c.label);
        expect(c.reviewed, isNotEmpty, reason: c.label);
        expect(c.stopGids.length, greaterThanOrEqualTo(2), reason: c.label);
      }
    });

    test('una corrección sin fuente no se acepta', () {
      expect(
        () => parseCorrections({
          'recorridos': [
            {
              'linea': '102',
              'ramal': 'A',
              'sentido': 0,
              'vigente_desde': '2026-08-12',
              'calles': 'x',
              'revisado': 'x',
              'paradas': [1, 2],
              'trazado': [
                [-58.78, -27.49],
                [-58.79, -27.49],
              ],
            },
          ],
        }),
        throwsFormatException,
      );
    });
  });

  group('aplicadas al importador', () {
    test('reemplazan el trazado del portal, y nada más', () {
      final result = applyRouteCorrections(
        CorrientesImportResult(
          lines: const [],
          variants: [_variant('102', 0), _variant('103', 0)],
          warnings: const [],
          skipped: const [],
        ),
        [_correction()],
      );
      expect(result.variants[0].geometry.first.lng, -58.7811);
      expect(result.variants[1].geometry, _variant('103', 0).geometry);
    });

    test('si el portal ya no tiene el recorrido, falla en vez de seguir', () {
      expect(
        () => applyRouteCorrections(
          CorrientesImportResult(
            lines: const [],
            variants: [_variant('103', 0)],
            warnings: const [],
            skipped: const [],
          ),
          [_correction()],
        ),
        throwsStateError,
      );
    });

    test('reemplazan la secuencia de paradas y sueltan las que quedan sin '
        'recorrido', () {
      final placed = CorrientesStopsResult(
        stops: [_stop(1), _stop(9)],
        byVariant: const {
          '102/A/0': [1, 9],
        },
        warnings: const [],
      );
      final fixed = applyStopCorrections(
        placed,
        all: [_stop(1), _stop(2), _stop(9)],
        corrections: [_correction()],
      );
      expect(fixed.byVariant['102/A/0'], [1, 2]);
      expect(fixed.stops.map((s) => s.gid), [1, 2]);
    });

    test('una parada que no está en el archivo municipal es un error', () {
      expect(
        () => applyStopCorrections(
          const CorrientesStopsResult(stops: [], byVariant: {}, warnings: []),
          all: [_stop(1)],
          corrections: [
            _correction(gids: [1, 404]),
          ],
        ),
        throwsStateError,
      );
    });
  });

  group('la migración y el seed dicen lo mismo que el archivo', () {
    test('la 0019 es exactamente el SQL que sale de las correcciones', () {
      final migration = File(
        'supabase/migrations/0019_corrientes_102a_106a.sql',
      ).readAsStringSync();
      const open = '-- <correcciones: generado por emitCorrectionsSql';
      const close = '-- </correcciones>';
      final start = migration.indexOf('\n', migration.indexOf(open)) + 1;
      final body = migration.substring(start, migration.indexOf(close));
      expect(body, emitCorrectionsSql(_real()));
    });

    test('el seed tiene el trazado corregido de cada recorrido', () {
      final seed = File('supabase/seed/seed_corrientes.sql').readAsStringSync();
      for (final c in _real()) {
        expect(
          seed,
          contains(lineStringWkt(correctedGeometry(c))),
          reason: c.label,
        );
      }
    });
  });
}
