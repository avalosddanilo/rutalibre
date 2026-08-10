import 'package:flutter_test/flutter_test.dart';
import 'package:rutalibre/features/transit/data/datasources/transit_local_datasource.dart';
import 'package:rutalibre/features/transit/data/models/stop_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _stops = [
  StopModel(id: 's1', name: 'Ameghino y French', lat: -27.45, lng: -58.98),
];

final _momento = DateTime(2026, 8, 10, 9, 30);

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  SharedPrefsTransitLocalDataSource source({DateTime? now}) =>
      SharedPrefsTransitLocalDataSource(prefs, now: () => now ?? _momento);

  test('sin nada escrito, no hay fecha de sincronización', () async {
    expect(await source().lastSyncedAt(), isNull);
  });

  test('escribir datos deja la marca de CUÁNDO se escribieron', () async {
    // Es lo que permite decirle al usuario de cuándo son los datos que está
    // mirando: toda la app es cache-first y sin esto no hay forma de saberlo.
    final local = source();
    await local.cacheAllStops(_stops);

    expect(await local.lastSyncedAt(), _momento);
  });

  test('cualquier escritura cuenta, no solo la de paradas', () async {
    final local = source();
    await local.cacheStopsForRoute('rv1', _stops);
    expect(await local.lastSyncedAt(), _momento);
  });

  test('la marca se actualiza al reescribir', () async {
    final despues = DateTime(2026, 8, 17, 8);
    await source().cacheAllStops(_stops);
    await source(now: despues).cacheAllStops(_stops);

    expect(await source().lastSyncedAt(), despues);
  });

  test('una marca ilegible se trata como ausente y no tira', () async {
    // Es un dato de adorno y de decisión: romper una pantalla por él sería
    // desproporcionado.
    SharedPreferences.setMockInitialValues({
      'ruta_libre_cache_v5/synced_at': 'no es una fecha',
    });
    final dirty = await SharedPreferences.getInstance();

    expect(
      await SharedPrefsTransitLocalDataSource(dirty).lastSyncedAt(),
      isNull,
    );
  });
}
