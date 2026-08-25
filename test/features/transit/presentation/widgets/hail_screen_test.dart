import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rutalibre/features/transit/presentation/widgets/hail_screen.dart';

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
