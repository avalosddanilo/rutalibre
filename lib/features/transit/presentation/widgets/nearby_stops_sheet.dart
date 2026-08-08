import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/widgets/staggered_in.dart';
import '../../domain/entities/nearby_stop.dart';
import '../providers/transit_providers.dart';
import '../utils/failure_message.dart';
import 'stop_details_sheet.dart';

/// Lista de paradas cercanas CON la distancia real en metros.
///
/// La distancia la calcula PostGIS sobre `geography`, así que son metros
/// caminando en línea recta, no una estimación del teléfono.
class NearbyStopsSheet extends ConsumerWidget {
  const NearbyStopsSheet({required this.args, super.key});

  final ({double lat, double lng, int radiusMeters}) args;

  static Future<void> show(
    BuildContext context, {
    required ({double lat, double lng, int radiusMeters}) args,
  }) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => NearbyStopsSheet(args: args),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nearbyAsync = ref.watch(nearbyStopsProvider(args));

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Row(
                children: [
                  const Icon(Icons.my_location),
                  const SizedBox(width: 12),
                  Text(
                    'Paradas cerca tuyo',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            Flexible(
              child: nearbyAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(failureMessage(error), textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      FilledButton.tonal(
                        onPressed: () =>
                            ref.invalidate(nearbyStopsProvider(args)),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
                data: (stops) => stops.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                        child: Text(
                          'No encontramos paradas a menos de '
                          '${args.radiusMeters} m.',
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: stops.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        // Escalonadas: acá el orden ES la información —están
                        // por distancia— y el movimiento lo cuenta solo.
                        itemBuilder: (context, index) => StaggeredIn(
                          index: index,
                          child: _NearbyTile(nearby: stops[index]),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NearbyTile extends ConsumerWidget {
  const _NearbyTile({required this.nearby});

  final NearbyStop nearby;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ListTile(
    leading: CircleAvatar(
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      child: Text(
        nearby.formattedDistance.split(' ').first,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
      ),
    ),
    title: Text(nearby.stop.name, maxLines: 1, overflow: TextOverflow.ellipsis),
    subtitle: Text('A ${nearby.formattedDistance}'),
    trailing: const Icon(Icons.chevron_right),
    onTap: () => StopDetailsSheet.show(
      context,
      ref,
      stop: nearby.stop,
      distanceLabel: 'a ${nearby.formattedDistance}',
    ),
  );
}
