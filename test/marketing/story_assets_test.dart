// Las stories verticales de la prueba cerrada.
//
//   REGEN_STORIES=1 flutter test test/marketing/story_assets_test.dart
//
// Salen en `marketing/assets/stories/`, a 1080 × 1920.
//
// **Por qué en código y no en Canva**: por lo mismo que los carruseles — el
// colectivo de estas piezas es el MISMO `BrandMarkPainter` del ícono de la
// app, así que la cuenta y la tienda no pueden mostrar dos marcas distintas.
// Y cuando cambie un número (los testers que faltan), se cambia un string y
// se corre un comando.
//
// **Por qué existen estas dos y no una.** Con 12 verificadores anotados el
// reloj de los 14 días arranca, pero se cae si alguno se desanota: hacen
// falta las dos cosas a la vez, colchón nuevo y que los que ya están no se
// vayan. Son dos pedidos distintos a dos públicos distintos.
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show FontLoader;
import 'package:flutter_test/flutter_test.dart';
import 'package:rutalibre/app/theme/brand.dart';

const _dir = 'marketing/assets/stories';

/// El lienzo de una story en píxeles lógicos. Con `pixelRatio: 3` da los
/// 1080 × 1920 de Instagram.
const _story = Size(360, 640);

/// Gris de los textos secundarios, el mismo de los carruseles.
const _gris = Color(0xFFA8A8A8);

const _pad = 34.0;

/// El aire que se come la interfaz de Instagram: arriba el nombre de la
/// cuenta y la barra de progreso, abajo la caja de responder. Nada importante
/// puede caer ahí — son las zonas seguras que recomienda la propia app,
/// ~14% arriba y ~20% abajo.
const _zonaArriba = 96.0;
const _zonaAbajo = 128.0;

class _Story {
  const _Story({
    required this.archivo,
    required this.titulo,
    required this.acento,
    required this.cuerpo,
    required this.pie,
  });

  final String archivo;

  /// El titular. `acento` es la parte que va en azul — una sola, y corta:
  /// el acento se usa poco o deja de ser acento.
  final String titulo;
  final String acento;
  final String cuerpo;

  /// El renglón de abajo: qué tiene que hacer el que lo lee.
  final String pie;
}

const _stories = [
  // Para el que todavía no es tester.
  _Story(
    archivo: 's1-faltan-pocos.png',
    titulo: 'Ya somos',
    acento: '12',
    cuerpo:
        'Gracias en serio.\n\nGoogle me pide 12 personas probando la app '
        '14 días seguidos para dejarme publicarla.\n\n'
        'Busco unos pocos más de colchón: si uno se desanota, el '
        'contador vuelve a cero.',
    pie: '¿Tenés Android? Mandame tu Gmail por DM y te sumo.',
  ),
  // Para los 12 que ya están anotados. Es la que evita que el reloj se
  // reinicie, y por eso se repite cada tantos días.
  _Story(
    archivo: 's2-no-te-desanotes.png',
    titulo: 'A los que ya están:',
    acento: '14 días',
    cuerpo:
        'No la desinstales ni salgas de la prueba hasta que salga la '
        'app.\n\nSi alguno se va, el contador de Google arranca de nuevo '
        'y perdemos las dos semanas.\n\n'
        'Usala cuando te tomes el cole: lo raro que veas, decímelo.',
    pie: 'Gracias, en serio. Sin ustedes esto no sale.',
  ),
];

Widget _plate(_Story s) => ColoredBox(
  color: Brand.black,
  child: Padding(
    padding: const EdgeInsets.fromLTRB(_pad, _zonaArriba, _pad, _zonaAbajo),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: '${s.titulo}\n'),
              TextSpan(
                text: s.acento,
                style: const TextStyle(color: Brand.accent),
              ),
            ],
          ),
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 34,
            height: 1.12,
            // Tracking negativo en los títulos, como manda el arte.
            letterSpacing: -1.2,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          s.cuerpo,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            height: 1.45,
            color: _gris,
          ),
        ),
        const Spacer(),
        Text(
          s.pie,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            height: 1.35,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        // La marca abajo, chiquita, como en todas las piezas.
        Row(
          children: [
            const BrandMark(size: 22),
            const SizedBox(width: 8),
            const Text(
              'Ruta Libre',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    ),
  ),
);

/// Carga Inter de verdad: sin esto los textos salen como cuadraditos.
Future<void> _loadInter() async {
  final bytes = File('assets/fonts/Inter-Variable.ttf').readAsBytesSync();
  await (FontLoader(
        'Inter',
      )..addFont(Future.value(ByteData.sublistView(Uint8List.fromList(bytes)))))
      .load();
}

void main() {
  testWidgets('las stories no prometen lo que la app no hace', (tester) async {
    // El mismo guardarraíl que los carruseles y la ficha: una story se
    // comparte suelta, sin contexto, y sobrevive en la galería de alguien.
    final copy = _stories
        .map((s) => '${s.titulo} ${s.acento} ${s.cuerpo} ${s.pie}')
        .join(' ')
        .toLowerCase();
    expect(copy, isNot(contains('tiempo real')));
    expect(copy, isNot(contains('en vivo')));
    expect(copy, isNot(contains('cuándo llega')));
    // Y dicen lo que tienen que decir para servir de algo.
    expect(copy, contains('android'));
    expect(copy, contains('14 días'));
    // Y NADA de emojis: las piezas se rasterizan con Inter, que no tiene
    // glifos de emoji, así que un 🙌 sale dibujado como un cuadradito con
    // la palabra "NO GLYPH" adentro. Pasó, y en una story no se ve hasta
    // que está publicada.
    for (final rune in copy.runes) {
      expect(
        rune,
        lessThan(0x2190),
        reason:
            'el carácter U+${rune.toRadixString(16).toUpperCase()} no lo '
            'dibuja Inter: va a salir como un cuadradito',
      );
    }
  });

  testWidgets(
    'regenera las stories',
    skip: Platform.environment['REGEN_STORIES'] != '1',
    (tester) async {
      await tester.runAsync(_loadInter);

      tester.view
        ..physicalSize = Size(_story.width + 40, _story.height + 40)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      for (final s in _stories) {
        final key = GlobalKey();
        // RepaintBoundary y no PictureRecorder: dentro de `testWidgets`,
        // `Picture.toImage()` no completa nunca y el test se cuelga.
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Center(
              child: RepaintBoundary(
                key: key,
                child: SizedBox.fromSize(size: _story, child: _plate(s)),
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
          expect(image.width, 1080, reason: s.archivo);
          expect(image.height, 1920, reason: s.archivo);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          image.dispose();
          final file = File('$_dir/${s.archivo}');
          await file.parent.create(recursive: true);
          await file.writeAsBytes(bytes!.buffer.asUint8List());
        });
      }

      for (final s in _stories) {
        expect(File('$_dir/${s.archivo}').lengthSync(), greaterThan(1000));
      }
    },
  );
}
