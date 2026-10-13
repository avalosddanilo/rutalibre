// La política de privacidad tiene que nombrar cada permiso que pide la app.
//
// Por qué existe: la 1.1 sumó la alarma con la pantalla apagada (cuatro
// permisos nuevos) y la política siguió diciendo "la app no puede saber
// dónde estás cuando no la estás usando". Nadie lo vio hasta que la versión
// ya estaba en revisión, con una declaración de servicio en primer plano que
// decía lo contrario. El revisor de Google compara las dos cosas.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final manifest = File(
    'android/app/src/main/AndroidManifest.xml',
  ).readAsStringSync();
  final policy = File('docs/politica-de-privacidad.md').readAsStringSync();

  final permissions = {
    for (final m in RegExp(
      r'<uses-permission[^>]*android:name="android\.permission\.(\w+)"',
    ).allMatches(manifest))
      m.group(1)!,
  };

  test('el manifest pide permisos (si no, el test no prueba nada)', () {
    expect(permissions, contains('ACCESS_FINE_LOCATION'));
  });

  for (final permission in permissions) {
    test('la política explica $permission', () {
      expect(
        policy,
        contains('`$permission`'),
        reason:
            'AndroidManifest.xml pide $permission y '
            'docs/politica-de-privacidad.md no lo menciona',
      );
    });
  }

  test('no promete que nunca hay ubicación con la pantalla apagada', () {
    // Con la alarma prendida, la hay. Decir lo contrario es lo que la
    // política decía hasta la 1.1.
    expect(policy, isNot(contains('nunca corre en segundo plano')));
  });
}
