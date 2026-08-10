import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/schedule.dart';
import '../models/bus_line_model.dart';
import '../models/route_variant_model.dart';
import '../models/schedule_model.dart';
import '../models/stop_model.dart';

/// Contrato de la cache local. Contrato de errores: los getters lanzan
/// [CacheException] ante cache vacía o corrupta — para el repositorio
/// ambas significan lo mismo: "andá a la red".
abstract interface class TransitLocalDataSource {
  Future<List<BusLineModel>> getCachedLines();

  Future<void> cacheLines(List<BusLineModel> lines);

  Future<List<RouteVariantModel>> getCachedRouteVariants(String lineId);

  Future<void> cacheRouteVariants(
    String lineId,
    List<RouteVariantModel> variants,
  );

  Future<List<StopModel>> getCachedStopsForRoute(String routeVariantId);

  Future<void> cacheStopsForRoute(String routeVariantId, List<StopModel> stops);

  Future<List<StopModel>> getCachedAllStops();

  Future<void> cacheAllStops(List<StopModel> stops);

  Future<List<ScheduleModel>> getCachedSchedules({
    required String routeVariantId,
    required DayType dayType,
  });

  Future<void> cacheSchedules({
    required String routeVariantId,
    required DayType dayType,
    required List<ScheduleModel> schedules,
  });

  /// Cuándo se escribió por última vez algo en la cache, o null si nunca.
  ///
  /// Existe para dos cosas: poder DECIRLE al usuario de cuándo son los datos
  /// que está mirando —toda la app es cache-first, así que sin esto no hay
  /// forma de saber si son de hoy o de hace un mes— y para que el repositorio
  /// sepa cuándo conviene refrescarlos.
  ///
  /// Es una sola marca para toda la cache y no una por clave: los datos
  /// estáticos se bajan todos alrededor del mismo momento, y una marca por
  /// entrada sería más precisa sin cambiar ninguna decisión.
  Future<DateTime?> lastSyncedAt();
}

/// Implementación sobre `shared_preferences`: cada lista se guarda como un
/// string JSON bajo una clave versionada.
///
/// Suficiente para el MVP: los datos estáticos completos del Gran
/// Resistencia pesan pocos cientos de KB. Si crecieran (o hiciera falta
/// query local), el reemplazo natural es sqflite/drift — cambiando SOLO
/// esta clase, el resto de la app no se entera.
final class SharedPrefsTransitLocalDataSource
    implements TransitLocalDataSource {
  const SharedPrefsTransitLocalDataSource(
    this._prefs, {
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final SharedPreferences _prefs;

  /// Reloj inyectable: la marca de sincronización se escribe con esto, así
  /// que los tests pueden fijar la fecha en vez de depender de cuándo corren.
  final DateTime Function() _now;

  /// Versionar la clave permite invalidar TODA la cache vieja en un update
  /// de la app cambiando el número (las claves huérfanas quedan muertas).
  ///
  /// v2: las líneas pasaron a traer la red embebida (`networks`) y los
  /// recorridos el ramal (`branch`). Una cache v1 no tiene esos campos: se
  /// descarta entera en vez de confiar en que el parseo falle y caiga por
  /// la rama de "cache corrupta".
  // v3: `networks` del BusLineModel ahora lleva `sort_order` (hace falta
  // para agrupar el listado por red sin intercalar Corrientes con el Gran
  // Resistencia). Sin subir la versión, quien actualiza la app queda con
  // cache v2 y todas las redes empatadas en sortOrder 0.
  //
  // v4: las líneas traen `destinations`. El modelo tolera que falte, así que
  // técnicamente una cache v3 no rompe — pero se degrada justo en lo que la
  // versión nueva vino a arreglar: el buscador seguiría sin encontrar
  // "Sarmiento" hasta que la cache venciera sola. Se descarta y listo.
  //
  // v5: las paradas traen `osm_node_id` (migración 0010). Misma razón que la
  // v4, y acá es peor: la cache de paradas NUNCA vence sola —`getStopsForRoute`
  // y `getAllStops` no vuelven a la red si tienen datos—, así que sin subir la
  // versión el enlace para corregir la parada en OSM no aparecería nunca en un
  // teléfono que ya abrió la app.
  static const _prefix = 'ruta_libre_cache_v5';

  static const _linesKey = '$_prefix/lines';

  static String _variantsKey(String lineId) => '$_prefix/variants/$lineId';

  static String _stopsKey(String routeVariantId) =>
      '$_prefix/stops/$routeVariantId';

  /// El listado completo, para el buscador de destino. Es la entrada más
  /// grande de la cache (~1416 paradas) y la que más paga: sin ella el
  /// buscador no anda sin señal.
  static const _allStopsKey = '$_prefix/stops/all';

  static String _schedulesKey(String routeVariantId, DayType dayType) =>
      '$_prefix/schedules/$routeVariantId/${ScheduleModel.dayTypeToDb(dayType)}';

  /// La marca de "cuándo bajamos esto", en ISO-8601.
  ///
  /// Va dentro del prefijo versionado como todo lo demás: al subir la versión
  /// de la cache, la marca vieja también queda huérfana. Si sobreviviera, la
  /// app diría "datos del 3 de agosto" sobre una cache recién creada.
  static const _syncedAtKey = '$_prefix/synced_at';

  @override
  Future<List<BusLineModel>> getCachedLines() async =>
      _read(_linesKey, BusLineModel.fromJson);

  @override
  Future<void> cacheLines(List<BusLineModel> lines) =>
      _write(_linesKey, lines.map((l) => l.toJson()).toList());

  @override
  Future<List<RouteVariantModel>> getCachedRouteVariants(String lineId) async =>
      _read(_variantsKey(lineId), RouteVariantModel.fromJson);

  @override
  Future<void> cacheRouteVariants(
    String lineId,
    List<RouteVariantModel> variants,
  ) => _write(_variantsKey(lineId), variants.map((v) => v.toJson()).toList());

  @override
  Future<List<StopModel>> getCachedStopsForRoute(String routeVariantId) async =>
      _read(_stopsKey(routeVariantId), StopModel.fromJson);

  @override
  Future<void> cacheStopsForRoute(
    String routeVariantId,
    List<StopModel> stops,
  ) => _write(_stopsKey(routeVariantId), stops.map((s) => s.toJson()).toList());

  @override
  Future<List<StopModel>> getCachedAllStops() async =>
      _read(_allStopsKey, StopModel.fromJson);

  @override
  Future<void> cacheAllStops(List<StopModel> stops) =>
      _write(_allStopsKey, stops.map((s) => s.toJson()).toList());

  @override
  Future<List<ScheduleModel>> getCachedSchedules({
    required String routeVariantId,
    required DayType dayType,
  }) async =>
      _read(_schedulesKey(routeVariantId, dayType), ScheduleModel.fromJson);

  @override
  Future<void> cacheSchedules({
    required String routeVariantId,
    required DayType dayType,
    required List<ScheduleModel> schedules,
  }) => _write(
    _schedulesKey(routeVariantId, dayType),
    schedules.map((s) => s.toJson()).toList(),
  );

  List<T> _read<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    final raw = _prefs.getString(key);
    if (raw == null) {
      throw CacheException('Cache vacía para "$key"');
    }
    try {
      return (jsonDecode(raw) as List<dynamic>)
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Cache corrupta = cache miss: el repositorio irá a red y la
      // sobreescribirá con datos sanos.
      throw CacheException('Cache corrupta para "$key": $e');
    }
  }

  @override
  Future<DateTime?> lastSyncedAt() async {
    final raw = _prefs.getString(_syncedAtKey);
    if (raw == null) return null;
    // Una marca ilegible se trata como ausente: es un dato de adorno y de
    // decisión, no vale tirar una excepción que rompa una pantalla por él.
    return DateTime.tryParse(raw);
  }

  Future<void> _write(String key, List<Map<String, dynamic>> rows) async {
    final ok = await _prefs.setString(key, jsonEncode(rows));
    if (!ok) {
      throw CacheException('No se pudo escribir la cache "$key"');
    }
    // La marca se pone acá y no en cada método: cualquier escritura de datos
    // frescos cuenta como sincronización, y así ninguna se olvida de marcar.
    // Si falla no se lanza: perder la marca es que la app no sepa la fecha,
    // no que se quede sin datos.
    await _prefs.setString(_syncedAtKey, _now().toIso8601String());
  }
}
