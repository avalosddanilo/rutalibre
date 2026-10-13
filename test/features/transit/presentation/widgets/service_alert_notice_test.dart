import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rutalibre/core/providers/shared_preferences_provider.dart';
import 'package:rutalibre/features/transit/data/datasources/service_alerts_datasource.dart';
import 'package:rutalibre/features/transit/domain/entities/service_alert.dart';
import 'package:rutalibre/features/transit/presentation/providers/service_alerts_providers.dart';
import 'package:rutalibre/features/transit/presentation/widgets/service_alert_notice.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class _FakeSource implements ServiceAlertsDataSource {
  _FakeSource(this.result);

  final Future<List<ServiceAlert>> Function() result;

  @override
  Future<List<ServiceAlert>> getCurrent() => result();
}

const _paro = ServiceAlert(
  id: 'a1',
  title: 'Paro de la UTA: hoy no hay colectivos urbanos',
  body: 'Afecta a todas las líneas urbanas del Gran Resistencia.',
);

const _desvio = ServiceAlert(
  id: 'a2',
  title: 'La 5 se desvía por obras en Av. Sarmiento',
  lineCodes: ['5'],
);

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  ProviderContainer container(Future<List<ServiceAlert>> Function() result) {
    final c = ProviderContainer(
      retry: (retryCount, error) => null,
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        serviceAlertsDataSourceProvider.overrideWithValue(_FakeSource(result)),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  Future<void> pump(WidgetTester tester, ProviderContainer c) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(home: Scaffold(body: ServiceAlertNotice())),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('serviceAlertFromJson', () {
    test('lee una fila completa', () {
      final alert = serviceAlertFromJson({
        'id': 'x',
        'title': 'Desvío',
        'body': '  Por obras.  ',
        'line_codes': ['5', ' 102 ', ''],
        'ends_at': '2026-10-14T01:00:00+00:00',
      });
      expect(alert.body, 'Por obras.');
      expect(alert.lineCodes, ['5', '102']);
      expect(alert.endsAt, isNotNull);
    });

    test('lo opcional puede faltar', () {
      final alert = serviceAlertFromJson({
        'id': 'x',
        'title': 'Paro',
        'body': '   ',
        'line_codes': null,
        'ends_at': null,
      });
      expect(alert.body, isNull);
      expect(alert.lineCodes, isEmpty);
      expect(alert.endsAt, isNull);
    });
  });

  testWidgets('sin avisos no ocupa lugar', (tester) async {
    await pump(tester, container(() async => const []));
    expect(find.byIcon(Icons.campaign_outlined), findsNothing);
  });

  testWidgets('sin conexión (o sin la tabla) no hay aviso y no rompe', (
    tester,
  ) async {
    await pump(tester, container(() async => throw Exception('sin red')));
    expect(find.byIcon(Icons.campaign_outlined), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('muestra el más nuevo y cuántos más hay', (tester) async {
    await pump(tester, container(() async => const [_paro, _desvio]));
    expect(find.text(_paro.title), findsOneWidget);
    expect(find.text(_desvio.title), findsNothing);
    expect(find.text('+1'), findsOneWidget);
  });

  testWidgets('tocarlo abre el detalle, con de dónde sale el aviso', (
    tester,
  ) async {
    await pump(tester, container(() async => const [_paro, _desvio]));
    await tester.tap(find.text(_paro.title));
    await tester.pumpAndSettle();

    expect(find.text(_paro.body!), findsOneWidget);
    expect(find.text(_desvio.title), findsOneWidget);
    expect(find.text('Línea: 5'), findsOneWidget);
    expect(find.textContaining('confiá en lo que ves'), findsOneWidget);
  });

  testWidgets('la X lo cierra, y queda cerrado al volver a abrir la app', (
    tester,
  ) async {
    await pump(tester, container(() async => const [_paro]));
    await tester.tap(find.byTooltip('Cerrar este aviso'));
    await tester.pumpAndSettle();
    expect(find.text(_paro.title), findsNothing);

    // "Volver a abrir": un contenedor nuevo con las mismas preferencias.
    await pump(tester, container(() async => const [_paro]));
    expect(find.text(_paro.title), findsNothing);
  });

  test('la fecha de vencimiento se lee en la hora del teléfono', () {
    expect(alertDeadline(DateTime(2026, 10, 14, 22, 5)), '14/10 a las 22:05');
  });
}
