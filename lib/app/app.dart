import 'package:flutter/material.dart';

import 'router/app_router.dart';
import 'theme/app_theme.dart';

/// Raíz de la app. Sin lógica: composición de router y theme.
class RutaLibreApp extends StatelessWidget {
  const RutaLibreApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'Ruta Libre',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: ThemeMode.system,
    routerConfig: appRouter,
  );
}
