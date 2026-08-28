import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rutalibre/core/providers/shared_preferences_provider.dart';
import 'package:rutalibre/features/transit/presentation/providers/trip_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  ProviderContainer container() {
    final c = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(c.dispose);
    return c;
  }

  test('arrastrar apaga el seguimiento; el botón lo prende', () {
    final c = container();
    expect(c.read(guidanceCameraFollowProvider), isTrue);

    c.read(guidanceCameraFollowProvider.notifier).disable();
    expect(c.read(guidanceCameraFollowProvider), isFalse);

    c.read(guidanceCameraFollowProvider.notifier).enable();
    expect(c.read(guidanceCameraFollowProvider), isTrue);
  });

  test('cada guía nueva arranca siguiendo, aunque la anterior lo haya '
      'apagado', () async {
    // Correr la cámara en UN viaje no es una preferencia para el siguiente:
    // quien arranca una guía quiere que lo lleven.
    final c = container();
    c.listen(guidanceCameraFollowProvider, (_, _) {});
    c.read(guidanceCameraFollowProvider.notifier).disable();

    c.read(tripGuidanceProvider.notifier).start();
    await Future<void>.delayed(Duration.zero);

    expect(c.read(guidanceCameraFollowProvider), isTrue);
  });
}
