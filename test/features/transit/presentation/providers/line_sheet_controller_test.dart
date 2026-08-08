import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rutalibre/features/transit/presentation/providers/transit_providers.dart';

/// Panel mínimo con la misma configuración de alturas que `LineSheet`, para
/// probar el controlador sin levantar el mapa entero (que necesitaría
/// mockear los tiles de OSM).
Widget _sheet(LineSheetController controller, {required double initial}) =>
    MaterialApp(
      home: Scaffold(
        body: DraggableScrollableSheet(
          controller: controller.draggable,
          initialChildSize: initial,
          minChildSize: sheetCollapsedExtent,
          maxChildSize: sheetExpandedExtent,
          builder: (context, scrollController) =>
              ListView(controller: scrollController),
        ),
      ),
    );

void main() {
  group('LineSheetController', () {
    testWidgets('collapse() baja el panel a su mínimo', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final controller = container.read(lineSheetControllerProvider);

      await tester.pumpWidget(_sheet(controller, initial: sheetExpandedExtent));
      expect(controller.draggable.size, closeTo(sheetExpandedExtent, 0.01));

      final collapsing = controller.collapse();
      await tester.pumpAndSettle();
      await collapsing;

      expect(controller.draggable.size, closeTo(sheetCollapsedExtent, 0.01));
    });

    testWidgets('collapse() no hace nada si ya estaba abajo', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final controller = container.read(lineSheetControllerProvider);

      await tester.pumpWidget(
        _sheet(controller, initial: sheetCollapsedExtent),
      );

      await controller.collapse();
      await tester.pumpAndSettle();

      expect(controller.draggable.size, closeTo(sheetCollapsedExtent, 0.01));
    });

    test('collapse() no explota si el panel todavía no se montó', () async {
      // Pasa de verdad: elegir un recorrido dispara el colapso, y animar un
      // DraggableScrollableController sin adjuntar TIRA.
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await expectLater(
        container.read(lineSheetControllerProvider).collapse(),
        completes,
      );
    });
  });
}
