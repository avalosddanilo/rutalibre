// Los PNG de la marca: se verifican siempre, se REGENERAN a pedido.
//
//   flutter test test/brand/brand_assets_test.dart            → verifica
//   REGEN_BRAND=1 flutter test test/brand/brand_assets_test.dart → regenera
//
// Después de regenerar, los íconos reales salen de:
//   dart run flutter_launcher_icons
//   dart run flutter_native_splash:create
//
// Por qué no regenera siempre: rasterizar tres PNG de 1024 px tarda, y
// `flutter test` se corre antes de cada commit. Y por qué igual vive acá y
// no en un script suelto: así el test FALLA si alguien borra un asset o si
// el ícono nunca se generó, en vez de descubrirlo en la tienda.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rutalibre/app/theme/brand.dart';

const _dir = 'assets/branding';

/// Lado del recuadro que se captura, en píxeles lógicos. Con
/// `pixelRatio: 4` da los 1024 px que piden flutter_launcher_icons y la
/// App Store.
const _side = 256.0;

// Las tres escalas de abajo son fracciones del lado del cuadrado, y como la
// marca llega arriba y abajo de su lienzo, son directamente la ALTURA del
// colectivo sobre la altura del ícono.
//
// Dos de ellas se calculan contra un círculo, no contra un cuadrado, porque
// eso es lo que recortan tanto el ícono adaptable como el splash de Android
// 12+. El círculo circunscrito de la marca mide ~1.13 veces su lado (manda la
// esquina de abajo, donde asoman las ruedas), así que el tope es
// `zona segura / 1.13`.

/// Cuánto ocupa la marca en el ícono a sangre. Acá no hay círculo: solo las
/// esquinas redondeadas de iOS y Android, y las esquinas del ícono están
/// vacías.
const _fullBleedScale = 0.70;

/// Y cuánto en el ícono adaptable de Android. Zona segura del 66% → tope
/// 0.66/1.13 ≈ 0.58, y de ahí para abajo por el parallax: el launcher mueve
/// la capa de adelante y lo que se salga desaparece.
const _adaptiveScale = 0.50;

/// Cuánto ocupa la marca en el splash. MÁS que en el ícono adaptable y no es
/// un descuido: el splash de Android 12+ recorta a un círculo fijo (con
/// `icon_background_color`, 640 px de diámetro sobre un lienzo de 960 → 66%)
/// pero NO tiene parallax, así que alcanza con entrar en el círculo.
/// Reusar acá la escala del ícono adaptable —que es lo que había— regalaba
/// ese margen y dejaba la marca chiquita justo en la única pantalla donde es
/// lo único que se ve.
const _splashScale = 0.56;

/// La marca centrada sobre un fondo. `background` null = transparente, que
/// es lo que necesitan la capa de adelante del ícono adaptable y el splash.
Widget _plate({
  required double scale,
  Color? background,
  Color bodyColor = Colors.white,
  Color accentColor = Brand.accent,
}) => ColoredBox(
  color: background ?? const Color(0x00000000),
  child: Center(
    child: BrandMark(
      size: _side * scale,
      bodyColor: bodyColor,
      accentColor: accentColor,
    ),
  ),
);

void main() {
  final assets = {
    // A sangre, fondo negro completo y SIN esquinas redondeadas: las ponen
    // iOS y Android por su cuenta, y redondearlas acá las redondearía dos
    // veces.
    'icon.png': _plate(scale: _fullBleedScale, background: Brand.black),
    // Capa de adelante del ícono adaptable: el fondo lo pone el sistema con
    // el color declarado en pubspec.
    'icon_foreground.png': _plate(scale: _adaptiveScale),
    'splash.png': _plate(scale: _splashScale),
    // Capa monocroma (íconos temáticos de Android 13+): el launcher la pinta
    // TODA de un color y solo conserva el alfa, así que acá lo único que
    // importa es la silueta. Todo blanco opaco — los faros se funden con la
    // carrocería y el colectivo se sigue leyendo por el cartel, el parabrisas
    // y las ruedas, que son agujeros y no color (ver `BrandMarkPainter`).
    'icon_monochrome.png': _plate(
      scale: _adaptiveScale,
      bodyColor: Colors.white,
      accentColor: Colors.white,
    ),
  };

  test(
    'los PNG de la marca están y no están vacíos',
    () {
      for (final name in assets.keys) {
        final file = File('$_dir/$name');
        expect(
          file.existsSync(),
          isTrue,
          reason:
              'Falta $_dir/$name. Regeneralo: '
              'REGEN_BRAND=1 flutter test test/brand/brand_assets_test.dart',
        );
        expect(
          file.lengthSync(),
          greaterThan(1000),
          reason: '$name es muy chico',
        );
      }
    },
    skip: Platform.environment['REGEN_BRAND'] == '1',
  );

  testWidgets(
    'regenera los PNG de la marca',
    timeout: const Timeout(Duration(minutes: 10)),
    skip: Platform.environment['REGEN_BRAND'] != '1',
    (tester) async {
      tester.view
        ..physicalSize = const Size(_side + 40, _side + 40)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      for (final entry in assets.entries) {
        final key = GlobalKey();
        // Se captura con RepaintBoundary y no con PictureRecorder: dentro de
        // testWidgets, `Picture.toImage()` no completa nunca (nadie pumpea
        // el frame que lo resuelve) y el test se cuelga hasta el timeout.
        await tester.pumpWidget(
          Center(
            child: RepaintBoundary(
              key: key,
              child: SizedBox.square(dimension: _side, child: entry.value),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        // `runAsync` es obligatorio: rasterizar y codificar el PNG lo hace el
        // engine fuera del reloj falso de los tests. Sin esto el `await`
        // nunca vuelve y el test se cuelga hasta el timeout.
        await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 4);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          image.dispose();
          final file = File('$_dir/${entry.key}');
          await file.parent.create(recursive: true);
          await file.writeAsBytes(bytes!.buffer.asUint8List());
        });
      }

      for (final name in assets.keys) {
        expect(File('$_dir/$name').lengthSync(), greaterThan(1000));
      }
    },
  );
}
