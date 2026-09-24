// La miniatura que se ve cuando alguien comparte el LINK del repositorio.
//
//   REGEN_SOCIAL_PREVIEW=1 flutter test test/marketing/social_preview_test.dart
//
// Sale en `marketing/social-preview.png`, a 1280 × 640.
//
// **Dónde se usa**: GitHub → Settings → General → Social preview. Una vez
// puesta ahí, la levantan LinkedIn, WhatsApp, Twitter, Slack y Discord solos.
// Es una imagen que se define una vez y se ve en todos lados; sin ella,
// GitHub arma una tarjeta genérica con el nombre del repo y poco más.
//
// **Por qué en código y no en Canva**: por lo mismo que los carruseles y las
// stories. El colectivo es el MISMO `BrandMarkPainter` del ícono de la app,
// así que el repo, la tienda y la cuenta no pueden mostrar tres marcas
// distintas. Y cuando cambie un número, se cambia un string y se corre un
// comando.
//
// **1280 × 640 y no otra cosa**: es lo que pide GitHub (2:1). Más chico se ve
// borroso en pantallas densas; con otra proporción, LinkedIn la recorta al
// medio y se come el texto.
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show FontLoader;
import 'package:flutter_test/flutter_test.dart';
import 'package:rutalibre/app/theme/brand.dart';

const _archivo = 'marketing/social-preview.png';

/// El lienzo en píxeles lógicos. Con `pixelRatio: 2` da los 1280 × 640.
const _lienzo = Size(640, 320);

const _gris = Color(0xFFA9A9A9);

/// El título. Lo que la app ES, en una línea.
const _titulo = 'Colectivos del Gran\nResistencia y Corrientes';

/// La frase que diferencia. NO es una lista de funciones a propósito:
/// cualquiera pone "mapa, buscador, horarios"; el criterio no lo copia nadie.
const _bajada =
    'Cuando un dato falta, la app lo dice\n'
    'en vez de estimarlo.';

/// Los tres que hacen que un desarrollador siga leyendo.
const _datos = ['Flutter + Android', '633 tests', 'AGPL-3.0'];

Future<void> _loadInter() async {
  final bytes = File('assets/fonts/Inter-Variable.ttf').readAsBytesSync();
  await (FontLoader(
        'Inter',
      )..addFont(Future.value(ByteData.sublistView(Uint8List.fromList(bytes)))))
      .load();
}

Widget _plate() => ColoredBox(
  color: Brand.black,
  child: Padding(
    padding: const EdgeInsets.fromLTRB(48, 44, 48, 40),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  BrandMark(size: 26),
                  SizedBox(width: 10),
                  Text(
                    'RUTA LIBRE',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      letterSpacing: 2.4,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Text(
                _titulo,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 34,
                  height: 1.14,
                  // Tracking negativo en los títulos, como manda el arte.
                  letterSpacing: -1.2,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                _bajada,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  height: 1.45,
                  color: _gris,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  for (final d in _datos) ...[
                    Text(
                      d,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Brand.accent,
                      ),
                    ),
                    if (d != _datos.last)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          '·',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12.5,
                            color: _gris,
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 28),
        // La captura real, recortada arriba: en una tarjeta de 2:1 un teléfono
        // entero entraría del tamaño de una uña y no se leería nada. Así se
        // ve que es una app de verdad, que es todo lo que tiene que hacer.
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
          child: SizedBox(
            width: 148,
            height: 236,
            child: OverflowBox(
              alignment: Alignment.topCenter,
              maxHeight: 329,
              child: Image.file(
                File('marketing/capturas/01-mapa-paradas.png'),
                width: 148,
                fit: BoxFit.fitWidth,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
        ),
      ],
    ),
  ),
);

void main() {
  test('la miniatura no promete lo que la app no hace', () {
    // El mismo guardarraíl que los carruseles y las stories: esta imagen se
    // comparte suelta, sin contexto, y es lo primero que ve alguien que no
    // conoce el proyecto.
    final copy = '$_titulo $_bajada ${_datos.join(' ')}'.toLowerCase();
    for (final prohibida in ['tiempo real', 'en vivo', 'cuándo llega']) {
      expect(
        copy.contains(prohibida),
        isFalse,
        reason: '"$prohibida" es falso: la app no sabe dónde está el colectivo',
      );
    }
  });

  test('sin emojis: Inter no los dibuja y salen como cuadraditos', () {
    final copy = '$_titulo $_bajada ${_datos.join(' ')}';
    for (final rune in copy.runes) {
      expect(
        rune < 0x2190 || (rune >= 0x2E80 && rune < 0x3000),
        isTrue,
        reason:
            'el carácter U+${rune.toRadixString(16).toUpperCase()} no lo '
            'dibuja Inter: va a salir como un cuadradito',
      );
    }
  });

  test('el PNG está y no está vacío', () {
    final file = File(_archivo);
    expect(
      file.existsSync(),
      isTrue,
      reason:
          'Falta $_archivo. Generalo: REGEN_SOCIAL_PREVIEW=1 flutter test '
          'test/marketing/social_preview_test.dart',
    );
    expect(file.lengthSync(), greaterThan(1000));
  }, skip: Platform.environment['REGEN_SOCIAL_PREVIEW'] == '1');

  testWidgets(
    'regenera la miniatura',
    skip: Platform.environment['REGEN_SOCIAL_PREVIEW'] != '1',
    (tester) async {
      await tester.runAsync(_loadInter);

      tester.view
        ..physicalSize = Size(_lienzo.width + 40, _lienzo.height + 40)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      // La captura hay que DECODIFICARLA a mano. `Image.file` resuelve de
      // forma asíncrona y en un test nadie bombea ese futuro: sin esto el
      // widget se dibuja vacío y la tarjeta sale con un hueco donde iba el
      // teléfono. Pasó, y no se ve en ningún assert: se ve mirando el PNG.
      final captura = FileImage(File('marketing/capturas/01-mapa-paradas.png'));
      await tester.runAsync(() async {
        final stream = captura.resolve(ImageConfiguration.empty);
        final listo = Completer<void>();
        late ImageStreamListener listener;
        listener = ImageStreamListener((_, _) {
          if (!listo.isCompleted) listo.complete();
          stream.removeListener(listener);
        });
        stream.addListener(listener);
        await listo.future;
      });

      final key = GlobalKey();
      // RepaintBoundary y no PictureRecorder: dentro de `testWidgets`,
      // `Picture.toImage()` no completa nunca y el test se cuelga.
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: RepaintBoundary(
              key: key,
              child: SizedBox.fromSize(size: _lienzo, child: _plate()),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 2);
        expect(image.width, 1280);
        expect(image.height, 640);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        image.dispose();
        await File(_archivo).writeAsBytes(bytes!.buffer.asUint8List());
      });

      expect(File(_archivo).lengthSync(), greaterThan(1000));
    },
  );
}
