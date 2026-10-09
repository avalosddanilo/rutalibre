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
//
// **La segunda versión tampoco funcionaba, y por un motivo concreto.** La
// captura entraba como un rectángulo blanco a sangre, sin teléfono y
// cortada a la mitad de una frase arriba y de otra abajo: se leía como una
// captura rota, no como una app. Y era la captura equivocada —la lista de
// viajes, que es siete renglones de letra chica que a tamaño de story no
// lee nadie—. Abajo quedaba además un quinto de la pieza en negro vacío.
//
// Esta versión cambia esas tres cosas:
//
//   · La captura va DENTRO de un teléfono dibujado, que se corta contra el
//     borde de abajo. Un marco con bisel convierte un rectángulo en un
//     objeto, y el corte contra el borde se lee como intencional en vez de
//     como un error de encuadre.
//   · Es `06-guia-toma-la-2`, no la lista: tiene mapa —con eso solo ya
//     sabés en medio segundo que es una app de colectivos— y una sola
//     instrucción corta y grande, "Tomá la 2", que es el producto entero
//     en tres palabras.
//   · Nada flota en el medio: el texto arriba, el teléfono llenando abajo.
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

/// El aire que se come la interfaz de Instagram arriba: el nombre de la
/// cuenta y la barra de progreso. La misma zona segura que las otras
/// stories.
///
/// Abajo hay otra, de 128, y acá no figura como constante porque ya no
/// hay nada que ubicar contra ella: el teléfono se corta contra el borde
/// del lienzo a propósito y lo único que cae en esos 128 px finales es
/// mapa, que no es información. Lo que sí tenía que respetarla —el
/// cartel "Tomá la 2"— dejó de estar en la pieza por ese motivo; está
/// contado en `_encuadre`.
const _zonaArriba = 96.0;
const _pad = 34.0;

const _gris = Color(0xFFA8A8A8);

const _titulo = 'Ya salió';
const _bajada = 'Colectivos del Gran Resistencia y Corrientes.';
const _pie = 'Gratis en Google Play';

/// La captura que va adentro del teléfono.
///
/// Es la del mapa con el cartel "Tomá la 2" y no la lista de viajes: a
/// tamaño de story la lista son siete renglones de 11 px que no lee nadie,
/// mientras que acá el mapa se reconoce de un vistazo y la instrucción son
/// tres palabras grandes.
const _captura = 'marketing/capturas/06-guia-toma-la-2.png';

/// El teléfono, en píxeles lógicos. 250 de ancho sobre un lienzo de 360 es
/// el 69%: lo bastante grande para que se lea la pantalla, y deja la
/// columna de texto respirando arriba.
const _anchoTel = 250.0;

/// Dónde empieza el teléfono. Desde acá hasta abajo de todo: NO termina,
/// se corta contra el borde del lienzo. Un teléfono entero y centrado se
/// vería chico y lejos; cortado contra el borde se lee como que sigue.
const _topeTel = 330.0;

/// El encuadre vertical de la captura dentro del marco. Con `cover` la
/// imagen entra más alta que la ventana, y este número elige qué franja se
/// ve: -1.0 el techo de la pantalla, 1.0 el piso.
///
/// **Por qué el mapa y no el cartel "Tomá la 2".** Encuadrado abajo, el
/// cartel caía en los últimos 130 px del lienzo, y ahí Instagram dibuja la
/// caja de "Enviar mensaje": lo único legible de la captura quedaba tapado
/// por la interfaz, y encima cortado al medio. Subirlo no se podía —el
/// cartel está al pie de la captura, así que para dejarlo arriba habría
/// que mostrar lo que hay abajo de él, que es la barra de Android—.
///
/// Así que la pantalla muestra mapa y nada más. Un mapa no tiene un
/// renglón que se pueda cortar mal: se lee entero a cualquier altura y
/// dice "esto es una app de colectivos" antes que cualquier frase. El
/// mensaje lo llevan el titular y el botón, que están arriba y a salvo.
///
/// En -0.85 la franja arranca justo debajo de la barra de estado del
/// teléfono, así que entran las chapitas de la propia app —"Ruta Libre",
/// "OpenStreetMap contributors"— y después el mapa hasta el borde.
const _encuadre = -0.85;

Future<void> _loadInter() async {
  final bytes = File('assets/fonts/Inter-Variable.ttf').readAsBytesSync();
  await (FontLoader(
        'Inter',
      )..addFont(Future.value(ByteData.sublistView(Uint8List.fromList(bytes)))))
      .load();
}

/// El teléfono: bisel oscuro, borde apenas más claro que el fondo y la
/// captura adentro. Sólo tiene esquinas redondeadas ARRIBA — abajo no hay
/// esquina porque abajo no hay final, se corta contra el borde.
Widget _telefono() => Container(
  width: _anchoTel,
  decoration: const BoxDecoration(
    color: Color(0xFF0B0B0B),
    borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
    border: Border(
      top: BorderSide(color: Color(0xFF343434), width: 2),
      left: BorderSide(color: Color(0xFF343434), width: 2),
      right: BorderSide(color: Color(0xFF343434), width: 2),
    ),
    boxShadow: [
      BoxShadow(
        color: Color(0xB3000000),
        blurRadius: 44,
        offset: Offset(0, 16),
      ),
    ],
  ),
  padding: const EdgeInsets.fromLTRB(7, 7, 7, 0),
  child: ClipRRect(
    borderRadius: const BorderRadius.vertical(top: Radius.circular(27)),
    child: Image(
      image: FileImage(File(_captura)),
      fit: BoxFit.cover,
      alignment: const Alignment(0, _encuadre),
    ),
  ),
);

Widget _plate() => ColoredBox(
  color: Brand.black,
  child: Stack(
    children: [
      // El resplandor azul detrás del teléfono. Sin esto el negro queda
      // plano y el teléfono parece pegado encima en vez de estar ahí.
      Positioned(
        left: (360 - 520) / 2,
        top: _topeTel - 170,
        child: Container(
          width: 520,
          height: 520,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [Color(0x5C1E88E5), Color(0x001E88E5)],
            ),
          ),
        ),
      ),
      // El teléfono, centrado y cortado contra el borde de abajo.
      Positioned(
        left: (360 - _anchoTel) / 2,
        top: _topeTel,
        bottom: 0,
        child: _telefono(),
      ),
      // El texto, arriba a la izquierda. Va último para quedar por encima
      // del resplandor.
      Positioned(
        left: _pad,
        right: _pad,
        top: _zonaArriba,
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
            const SizedBox(height: 26),
            const Text(
              _titulo,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 58,
                height: 1.0,
                letterSpacing: -2.4,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              _bajada,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 17,
                height: 1.35,
                color: _gris,
              ),
            ),
            const SizedBox(height: 22),
            // El botón va ACÁ y no abajo de todo: abajo lo taparía el
            // teléfono, y encima del teléfono taparía el cartel que es
            // justo lo que la captura vino a mostrar.
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
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
      ),
    ],
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
      final captura = FileImage(File(_captura));
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
