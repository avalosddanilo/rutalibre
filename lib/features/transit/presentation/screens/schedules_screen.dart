import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../app/widgets/staggered_in.dart';
import '../../../../core/providers/clock_provider.dart';
import '../../domain/entities/fare.dart';
import '../../domain/entities/schedule.dart';
import '../../domain/entities/service_frequency.dart';
import '../providers/transit_providers.dart';
import '../utils/day_type_resolver.dart';
import '../utils/display_text.dart';
import '../utils/failure_message.dart';
import '../widgets/frequency_notice.dart';

/// Tabla de horarios del recorrido seleccionado, por tipo de día.
///
/// El tipo de día arranca en el que corresponde a HOY (feriados incluidos,
/// ver `day_type_resolver.dart`) y el usuario puede cambiarlo a mano —
/// eso también cubre los feriados trasladables que el resolver no conoce.
class SchedulesScreen extends ConsumerStatefulWidget {
  const SchedulesScreen({super.key});

  static const routeName = 'schedules';

  @override
  ConsumerState<SchedulesScreen> createState() => _SchedulesScreenState();
}

class _SchedulesScreenState extends ConsumerState<SchedulesScreen> {
  /// Null hasta que el usuario toque el selector: mientras tanto se usa
  /// el tipo de día de hoy (resuelto en build, donde hay acceso al clock).
  DayType? _userDayType;

  /// Re-renderiza por minuto: sin esto "en 12 min" y el resaltado de la
  /// próxima salida quedan congelados con la hora del primer build (el
  /// caso de uso central de la pantalla es ESPERAR el colectivo). También
  /// re-resuelve el tipo de día al cruzar la medianoche.
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(
      const Duration(minutes: 1),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final line = ref.watch(selectedLineProvider);
    final variant = ref.watch(selectedRouteVariantProvider);
    final now = ref.watch(clockProvider)();
    final todayType = dayTypeFor(now);
    final dayType = _userDayType ?? todayType;

    if (variant == null) {
      // Deep link directo o estado perdido: no hay recorrido elegido.
      return Scaffold(
        appBar: AppBar(title: const Text('Horarios')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Elegí una línea y un recorrido en el mapa para ver sus horarios.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final args = (routeVariantId: variant.id, dayType: dayType);
    final schedulesAsync = ref.watch(schedulesProvider(args));
    // Se resuelve una vez: la usan el renglón de arriba y el cartel de "no
    // tenemos horarios", que necesita saber si arriba hay algo o no para no
    // contradecirlo.
    final frequency = line == null
        ? null
        : frequencyFor(networkCode: line.network.code, lineCode: line.code);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(line == null ? 'Horarios' : 'Línea ${line.code}'),
            Text(
              displayText(variant.name),
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // La tarifa de ESTA línea, que no siempre es la de su red: el 904A
          // sale un 55% más que sus hermanos. Acá se puede dar el número
          // exacto porque la pantalla ya es de una línea sola.
          if (line != null) ...[
            _FareRow(
              fare: fareFor(
                networkCode: line.network.code,
                lineCode: line.code,
              ),
            ),
            // Y cada cuánto tiene que pasar. Va ACÁ arriba y no dentro de la
            // lista de horarios porque tiene que verse justamente cuando la
            // lista está vacía: para el 904B y el 904C es lo único que
            // contesta "¿cuándo pasa?", y hasta ahora la pantalla decía
            // "todavía no tenemos los horarios" teniendo el dato a mano.
            FrequencyRow(frequency: frequency),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: SegmentedButton<DayType>(
              segments: const [
                ButtonSegment(value: DayType.weekday, label: Text('Hábiles')),
                ButtonSegment(value: DayType.saturday, label: Text('Sábados')),
                ButtonSegment(
                  value: DayType.sundayHoliday,
                  label: Text('Dom. y fer.'),
                ),
              ],
              selected: {dayType},
              onSelectionChanged: (selection) =>
                  setState(() => _userDayType = selection.single),
            ),
          ),
          Expanded(
            child: schedulesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        failureMessage(error),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    TextButton(
                      onPressed: () => ref.invalidate(schedulesProvider(args)),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
              data: (schedules) => _ScheduleList(
                schedules: schedules,
                // Resaltar "próxima salida" solo tiene sentido si se está
                // mirando el tipo de día de HOY.
                now: dayType == todayType ? now : null,
                hasRegulatedFrequency: frequency != null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Cuánto sale el boleto de esta línea.
///
/// **El precio y su fecha van juntos y en el mismo renglón, siempre.** No es
/// cosmético: la tarifa cambia varias veces por año y un número suelto se lee
/// como vigente para siempre. Con la fecha al lado, quien lo mira decide solo
/// si confiar.
///
/// Si no tenemos el dato no se dibuja nada. Un "aproximadamente" sería
/// exactamente el error que esto existe para evitar.
class _FareRow extends StatelessWidget {
  const _FareRow({required this.fare});

  final Fare? fare;

  @override
  Widget build(BuildContext context) {
    final fare = this.fare;
    if (fare == null) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppTheme.radius),
        ),
        child: Row(
          children: [
            Icon(
              Icons.confirmation_number_outlined,
              size: 18,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(width: 10),
            Text(
              fare.formattedAmount,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${fare.formattedValidity}\nsegún ${fare.source}',
                style: textTheme.labelSmall?.copyWith(color: scheme.outline),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Estos horarios no están confirmados."
///
/// **Por qué está fijo y no sale de los datos**: hoy el 100% de lo cargado
/// es una transcripción a mano de imágenes que las empresas difunden por
/// WhatsApp (ver `docs/horarios.md`), así que el cartel es exacto para todo
/// lo que hay. El esquema no guarda de dónde salió cada horario ni si
/// alguien lo verificó.
///
/// **Cuándo hay que cambiarlo**: en cuanto entre UN horario confirmado —de
/// la empresa o de un GTFS oficial— este cartel pasa a mentir sobre él. Ahí
/// corresponde una columna `schedules.source` (o `verified_at`) y mostrarlo
/// por línea. Mientras tanto, un cartel de más es mucho mejor que un
/// horario que se presenta como cierto y no lo es: alguien pierde el
/// colectivo o se queda esperando de noche.
class _UnverifiedNotice extends StatelessWidget {
  const _UnverifiedNotice();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: scheme.secondaryContainer,
          borderRadius: BorderRadius.circular(AppTheme.radius),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline,
              size: 20,
              color: scheme.onSecondaryContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Horarios sin confirmar',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: scheme.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Los transcribimos de lo que publican las empresas y no '
                    'los pudimos verificar con ellas. Pueden estar '
                    'desactualizados: llegá unos minutos antes.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleList extends StatelessWidget {
  const _ScheduleList({
    required this.schedules,
    required this.now,
    this.hasRegulatedFrequency = false,
  });

  final List<Schedule> schedules;

  /// Momento actual, o null si la lista no corresponde al día de hoy
  /// (en ese caso no se resalta ninguna salida).
  final DateTime? now;

  /// Si arriba hay un renglón de frecuencia regulada.
  ///
  /// Cambia el cartel de "no tenemos horarios": decir "no sabemos cuándo pasa"
  /// tres centímetros abajo de "cada 12 minutos en hora pico" se lee como que
  /// la app se contradice.
  final bool hasRegulatedFrequency;

  @override
  Widget build(BuildContext context) {
    if (schedules.isEmpty) {
      // Con los datos reales importados de OSM, HOY esto le pasa a todas las
      // líneas: los horarios no los publica ninguna fuente abierta. Decirlo
      // explícito evita que parezca una pantalla rota.
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.schedule,
                size: 48,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                hasRegulatedFrequency
                    ? 'No hay tabla de horarios'
                    : 'Todavía no tenemos los horarios',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                hasRegulatedFrequency
                    ? 'Las horas exactas de salida las aprueba la CNRT y no '
                          'se publican. Lo que sí es oficial es la frecuencia '
                          'de arriba: cada cuánto tiene que pasar.'
                    : 'Los recorridos y las paradas los mapeó la comunidad, '
                          'pero los horarios no están publicados por ninguna '
                          'fuente abierta. Estamos gestionando el acceso.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final nowOffset = now == null
        ? null
        : Duration(hours: now!.hour, minutes: now!.minute);
    final nextIndex = nowOffset == null
        ? -1
        : schedules.indexWhere((s) => s.departureTime >= nowOffset);
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const _UnverifiedNotice(),
        if (nextIndex >= 0)
          _NextDepartureCard(
            schedule: schedules[nextIndex],
            minutesLeft:
                (schedules[nextIndex].departureTime - nowOffset!).inMinutes,
          ),
        if (nowOffset != null && nextIndex == -1)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.nightlight_outlined),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No quedan salidas hoy para este recorrido.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (index, schedule) in schedules.indexed)
              StaggeredIn(
                index: index,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    // Píldora, como todos los chips de la app. Estaba en
                    // radio 10, que no era ni tarjeta ni chip.
                    borderRadius: BorderRadius.circular(AppTheme.pillRadius),
                    color: index == nextIndex
                        ? scheme.primaryContainer
                        : scheme.surfaceContainerHighest,
                  ),
                  child: Text(
                    schedule.formattedTime,
                    style: TextStyle(
                      fontFeatures: const [FontFeature.tabularFigures()],
                      fontWeight: index == nextIndex
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: index == nextIndex
                          ? scheme.onPrimaryContainer
                          : scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _NextDepartureCard extends StatelessWidget {
  const _NextDepartureCard({required this.schedule, required this.minutesLeft});

  final Schedule schedule;
  final int minutesLeft;

  /// "ahora", "en 12 min", "en 2 h 05 min".
  String get _relative {
    if (minutesLeft <= 0) return 'ahora';
    if (minutesLeft < 60) return 'en $minutesLeft min';
    final hours = minutesLeft ~/ 60;
    final minutes = (minutesLeft % 60).toString().padLeft(2, '0');
    return 'en $hours h $minutes min';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.departure_board, color: scheme.onPrimaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Próxima salida: ${schedule.formattedTime}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _relative,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
