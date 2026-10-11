// La foto de perfil y la portada de destacadas de Instagram.
//
//   REGEN_PERFIL=1 flutter test test/marketing/profile_assets_test.dart
//
// Salen en `marketing/assets/`.
//
// **Por qué la marca va INVERTIDA acá y no como el ícono de la app.** El
// ícono de la tienda es bondi blanco sobre negro, y está bien: en el cajón
// de aplicaciones se ve a 48 px sobre el fondo del launcher, que cada uno
// tiene distinto, y el negro lo recorta.
//
// En el feed de Instagram el avatar se ve a ~40 px sobre fondo BLANCO, y
// ahí el negro juega en contra: el parabrisas y el cartel de destino están
// hechos como agujeros —para que sobrevivan a la capa monocroma de Android
// 13+— así que sobre negro el calado se pierde y a ese tamaño queda una
// mancha oscura sin forma. Con el fondo azul lleno, el avatar se lee como
// un punto azul reconocible y el bondi blanco conserva el calado.
//
// No es una marca distinta: es el MISMO `BrandMarkPainter`, con los colores
// dados vuelta. Los faros quedan del azul del fondo a propósito, así se leen
// como dos agujeros más y no como manchas de otro color.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rutalibre/app/theme/brand.dart';

const _dir = 'marketing/assets';

/// El lienzo del avatar en píxeles lógicos. Con `pixelRatio: 3` da los
/// 1080 × 1080 que Instagram guarda.
const _avatar = Size(360, 360);

/// El lienzo de la portada de destacada: 9:16, como una story.
const _portada = Size(360, 640);

/// Cuánto del LADO ocupa la altura del colectivo en el avatar.
///
/// Instagram recorta el avatar al círculo inscripto en el cuadrado, así que
/// lo que tiene que entrar no es la marca sino su círculo CIRCUNSCRIPTO, que
/// mide ~1.13 veces su lado (manda la esquina de abajo, por donde asoman las
/// ruedas). Con 0.56 ese círculo ocupa 0.56 × 1.13 ≈ 0.63 del diámetro: la
/// marca llena el avatar sin tocar el borde, y queda un 18% de aire por lado
/// que hace que el recorte se vea intencional y no apretado.
const _escalaAvatar = 0.56;

/// Y en la portada de destacada. Va chica porque Instagram recorta un
/// círculo del CENTRO de una imagen 9:16, y el diámetro de ese círculo es
/// bastante menor que el ancho. 0.27 del ancho ≈ 290 px reales, que entra
/// con margen en cualquier recorte razonable.
const _escalaPortada = 0.27;

/// El círculo circunscrito de la marca, en veces su lado. Sale de la
/// geometría de `BrandMarkPainter` y está documentado igual en
/// `test/brand/brand_assets_test.dart`.
const _circunscripto = 1.13;

/// La marca invertida: carrocería blanca, y los faros del color del fondo
/// para que se lean como agujeros.
Widget _marca(double lado, double escala) => ColoredBox(
  color: Brand.accent,
  child: Center(
    child: BrandMark(
      size: lado * escala,
      bodyColor: Colors.white,
      accentColor: Brand.accent,
    ),
  ),
);

Future<void> _rasterizar(
  WidgetTester tester,
  Size lienzo,
  Widget hijo,
  String archivo,
  Size esperado,
) async {
  final key = GlobalKey();
  // RepaintBoundary y no PictureRecorder: dentro de `testWidgets`,
  // `Picture.toImage()` no completa nunca y el test se cuelga.
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: RepaintBoundary(
          key: key,
          child: SizedBox.fromSize(size: lienzo, child: hijo),
        ),
      ),
    ),
  );
  await tester.pump();

  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 3);
    expect(image.width, esperado.width.toInt(), reason: archivo);
    expect(image.height, esperado.height.toInt(), reason: archivo);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    final file = File('$_dir/$archivo');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes!.buffer.asUint8List());
  });
}

void main() {
  // Este test se corre SIEMPRE, no sólo al regenerar: es la cuenta que
  // decide si el recorte circular de Instagram se come las ruedas. Si
  // alguien sube la escala "para que se vea más grande", acá se entera.
  test('la marca entra entera en el recorte circular del avatar', () {
    final ocupa = _escalaAvatar * _circunscripto;
    expect(
      ocupa,
      lessThan(0.75),
      reason:
          'el círculo circunscrito de la marca ocupa el ${(ocupa * 100).round()}% '
          'del diámetro: queda apretado contra el borde del recorte',
    );
    expect(
      ocupa,
      greaterThan(0.5),
      reason:
          'la marca ocupa sólo el ${(ocupa * 100).round()}% del diámetro: a 40 px '
          'en el feed no se va a leer',
    );
  });

  testWidgets(
    'regenera la foto de perfil y la portada de destacadas',
    skip: Platform.environment['REGEN_PERFIL'] != '1',
    (tester) async {
      tester.view
        ..physicalSize = const Size(700, 700)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await _rasterizar(
        tester,
        _avatar,
        _marca(_avatar.width, _escalaAvatar),
        'perfil-ig.png',
        const Size(1080, 1080),
      );
      await _rasterizar(
        tester,
        _portada,
        _marca(_portada.width, _escalaPortada),
        'destacada-portada.png',
        const Size(1080, 1920),
      );

      for (final f in ['perfil-ig.png', 'destacada-portada.png']) {
        expect(File('$_dir/$f').lengthSync(), greaterThan(1000), reason: f);
      }
    },
  );
}
