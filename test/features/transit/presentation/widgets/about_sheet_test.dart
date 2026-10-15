import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rutalibre/core/diagnostics/diagnostics_log.dart';
import 'package:rutalibre/features/transit/presentation/widgets/about_sheet.dart';
import 'package:rutalibre/features/transit/presentation/widgets/wake_alarm.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Future<DiagnosticsLog> pumpSheet(WidgetTester tester) async {
    final log = DiagnosticsLog(prefs)..record('alarma_armada');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          diagnosticsLogProvider.overrideWithValue(log),
          appVersionProvider.overrideWith((ref) async => '1.3.0 (6)'),
        ],
        child: const MaterialApp(home: Scaffold(body: AboutSheet())),
      ),
    );
    await tester.pumpAndSettle();
    return log;
  }

  testWidgets('dice la versión y promete lo que el registro cumple', (
    tester,
  ) async {
    await pumpSheet(tester);
    expect(find.text('Versión 1.3.0 (6)'), findsOneWidget);
    expect(find.text('Enviar diagnóstico'), findsOneWidget);
    expect(find.textContaining('Nunca tu ubicación'), findsOneWidget);
    expect(find.text('Política de privacidad'), findsOneWidget);
  });

  testWidgets('"Borrar registro" lo deja vacío', (tester) async {
    final log = await pumpSheet(tester);
    expect(log.entries, isNotEmpty);
    await tester.tap(find.text('Borrar registro'));
    await tester.pumpAndSettle();
    expect(log.entries, isEmpty);
    expect(find.text('Registro borrado'), findsOneWidget);
  });

  group('la alarma anota qué pasó con el servicio', () {
    const channel = MethodChannel('rutalibre/alarm');
    tearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );

    test('servicio iniciado', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async => true);
      final log = DiagnosticsLog(prefs);
      await DeviceWakeAlarmGear(log: log).holdTrip();
      await DeviceWakeAlarmGear(log: log).ring();
      expect(log.entries.join('\n'), contains('servicio_viaje iniciado'));
      expect(log.entries.join('\n'), contains('alarma_suena'));
    });

    test('servicio que falla queda anotado con su tipo de error', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            channel,
            (call) async => throw PlatformException(code: 'denegado'),
          );
      final log = DiagnosticsLog(prefs);
      await DeviceWakeAlarmGear(log: log).holdTrip();
      expect(
        log.entries.join('\n'),
        contains('servicio_viaje falló: PlatformException'),
      );
    });
  });
}
