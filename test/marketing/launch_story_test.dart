// La story del día que la app salió a Google Play.
//
//   REGEN_LANZAMIENTO=1 flutter test test/marketing/launch_story_test.dart
//
// Sale en `marketing/assets/stories/s3-ya-salio.png`, a 1080 × 1920.
//
// **Por qué tiene su propio archivo y no entra en `story_assets_test.dart`.**
// Las otras dos stories son de texto: titular, cuerpo, pie. Esta no puede
// serlo. Las de la prueba cerrada le hablaban a gente que YA estaba metida
// en el tema y se tomaba el trabajo de leer; esta le habla a alguien que
// está pasando stories con el pulgar y le da dos segundos.
//
// La primera versión fue de texto y no funcionaba: cuatro párrafos grises
// que nadie lee. Acá el texto es el mínimo —la noticia, qué es, y qué
// hacer— y el peso visual lo lleva la captura de la app andando. Si la
// persona no lee una sola palabra, igual entendió que hay una app de
// colectivos y que ya se puede bajar.
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show FontLoader;
import 'package:flutter_test/flutter_test.dart';
import 'package:rutalibre/app/theme/brand.dart';

const _archivo = 'marketing/assets/stories/s3-ya-salio.png';

/// El lienzo en píxeles lógicos. Con `pixelRatio: 3` da los 1080 × 1920.
const _story = Size(360, 640);

/// El aire que se come la interfaz de Instagram: arriba el nombre de la
/// cuenta y la barra de progreso, abajo la caja de responder. Las mismas
/// zonas seguras que las otras stories.
const _zonaArriba = 96.0;
const _zonaAbajo = 128.0;
const _pad = 34.0;

const _gris = Color(0xFFA8A8A8);

const _titulo = 'Ya salió';
const _bajada = 'Colectivos del Gran Resistencia y Corrientes.';
const _pie = 'Gratis en Google Play';

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
    padding: const EdgeInsets.fromLTRB(_pad, _zonaArriba, _pad, _zonaAbajo),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            BrandMark(size: 24),
            SizedBox(width: 9),
            Text(
              'RUTA LIBRE',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                letterSpacing: 2.2,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        const Text(
          _titulo,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 62,
            height: 1.0,
            letterSpacing: -2.6,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          _bajada,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 17,
            height: 1.35,
            color: _gris,
          ),
        ),
        const SizedBox(height: 20),
        // La captura manda. Recortada arriba y pegada al borde inferior:
        // un teléfono entero y centrado se vería chiquito y lejos; así
        // entra grande y se lee qué es sin esfuerzo.
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              // `cover` para que llene el ancho —con `Align` quedaba del
              // tamaño de una estampilla— y el encuadre corrido hacia
              // abajo, que es donde está la lista de viajes.
              //
              // Encuadrada arriba se veía el mapa y nada más: lindo y
              // mudo. Lo que hace entender la app en dos segundos es ver
              // "6 líneas te llevan directo" con los recorridos listados,
              // así que la story se encuadra ahí y no en el techo.
              image: DecorationImage(
                image: FileImage(File('marketing/capturas/03-como-llego.png')),
                fit: BoxFit.cover,
                alignment: const Alignment(0, 0.45),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Brand.accent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                _pie,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  ),
);

void main() {
  test('la story no promete lo que la app no hace', () {
    final copy = '$_titulo $_bajada $_pie'.toLowerCase();
    for (final prohibida in ['tiempo real', 'en vivo', 'cuándo llega']) {
      expect(
        copy.contains(prohibida),
        isFalse,
        reason: '"$prohibida" es falso',
      );
    }
  });

  test('sin emojis: Inter no los dibuja y salen como cuadraditos', () {
    for (final rune in '$_titulo$_bajada$_pie'.runes) {
      expect(
        rune < 0x2190 || (rune >= 0x2E80 && rune < 0x3000),
        isTrue,
        reason: 'U+${rune.toRadixString(16).toUpperCase()} no lo dibuja Inter',
      );
    }
  });

  testWidgets(
    'regenera la story de lanzamiento',
    skip: Platform.environment['REGEN_LANZAMIENTO'] != '1',
    (tester) async {
      await tester.runAsync(_loadInter);

      // La captura hay que decodificarla a mano: `Image.file` resuelve
      // asíncrono y en un test nadie bombea ese futuro, así que sin esto
      // sale un hueco donde va el teléfono. No lo agarra ningún assert.
      final captura = FileImage(File('marketing/capturas/03-como-llego.png'));
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

      tester.view
        ..physicalSize = Size(_story.width + 40, _story.height + 40)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final key = GlobalKey();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: RepaintBoundary(
              key: key,
              child: SizedBox.fromSize(size: _story, child: _plate()),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 3);
        expect(image.width, 1080);
        expect(image.height, 1920);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        image.dispose();
        await File(_archivo).writeAsBytes(bytes!.buffer.asUint8List());
      });
    },
  );
}
