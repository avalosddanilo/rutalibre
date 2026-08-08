import 'package:go_router/go_router.dart';

import '../../features/transit/presentation/screens/map_screen.dart';
import '../../features/transit/presentation/screens/schedules_screen.dart';

/// Rutas declarativas de la app (deep links gratis).
final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      name: 'map',
      builder: (context, state) => const MapScreen(),
    ),
    GoRoute(
      path: '/schedules',
      name: SchedulesScreen.routeName,
      builder: (context, state) => const SchedulesScreen(),
    ),
  ],
);
