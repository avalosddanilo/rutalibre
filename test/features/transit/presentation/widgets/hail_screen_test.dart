import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rutalibre/features/transit/presentation/widgets/hail_screen.dart';

/// Registra las llamadas en orden, sin plataforma de por medio.
final class _FakeBrightness implements HailBrightness {
  final calls = <String>[];

  @override
  Future<void> boost() async => calls.add('boost');

  @override
  Future<void> restore() async => calls.add('restore');
}

void main() {
  Future<void> open(WidgetTester tester, {String code = '904A'}) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () =>
                    HailScreen.show(context, code: code, colorHex: '#F57C00'),
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
  }

  testWidgets('muestra el número gigante y se cierra tocando', (tester) async {
    await open(tester);

    expect(find.text('904A'), findsOneWidget);
    expect(find.text('Tocá para volver'), findsOneWidget);

    await tester.tap(find.text('904A'));
    await tester.pumpAndSettle();
    expect(find.text('904A'), findsNothing);
  });

  testWidgets('sube el brillo al abrir y lo RESTAURA al cerrar', (
    tester,
  ) async {
    // El orden es el contrato: boost al entrar, restore al salir — nunca al
    // revés, nunca dos veces. Restore va en dispose para cubrir también el
    // botón de atrás del sistema, que no pasa por ningún onTap.
    final brightness = _FakeBrightness();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HailScreen(code: '3', brightness: brightness),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(brightness.calls, ['boost']);

    // Desmontar el cartel = cerrarlo, por el camino que sea.
    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    await tester.pumpAndSettle();

    expect(brightness.calls, ['boost', 'restore']);
  });

  testWidgets('el plugin real ausente no rompe el cartel', (tester) async {
    // En tests no hay implementación de plataforma: el default
    // (ScreenHailBrightness) tiene que tragarse el MissingPluginException y
    // el cartel dibujarse igual. Es el mismo camino de un teléfono raro sin
    // soporte del plugin.
    await open(tester);
    expect(find.text('904A'), findsOneWidget);
  });

  testWidgets('con el texto del sistema al 200% no desborda: se achica', (
    tester,
  ) async {
    // Es un cartel: el número LLENA la pantalla vía FittedBox, así que la
    // escala del sistema no lo puede romper — a lo sumo lo achica.
    tester.view
      ..physicalSize = const Size(360 * 2, 640 * 2)
      ..devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, widget) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: widget!,
        ),
        home: const Scaffold(body: HailScreen(code: '904A')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('904A'), findsOneWidget);
  });
}
