// Las piezas de la campaña: se verifican siempre, se REGENERAN a pedido.
//
//   flutter test test/marketing/social_assets_test.dart            → verifica
//   REGEN_SOCIAL=1 flutter test test/marketing/social_assets_test.dart → regenera
//
// Es el mismo trato que `test/brand/brand_assets_test.dart`, y por las mismas
// dos razones: rasterizar cincuenta y pico de PNG grandes tarda demasiado para
// hacerlo antes de cada commit, y aun así el test tiene que FALLAR si alguien
// borra una pieza o si nunca se generaron.
//
// **Por qué el arte de las redes se dibuja en Dart y no en un editor.** Porque
// el colectivo de estos slides es el MISMO `BrandMarkPainter` del ícono de la
// app: no hay forma de que la campaña y la tienda muestren dos marcas
// distintas. Y porque el día que aumente el boleto, corregir el precio es
// cambiar un string acá y correr un comando — no abrir un archivo de diseño
// que quedó en la computadora de alguien.
//
// El guion, los captions y los hashtags viven en `marketing/ig-carruseles.md`.
// Esto es la fuente de verdad de lo que queda dibujado en el PNG.
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show FontLoader;
import 'package:flutter_test/flutter_test.dart';
import 'package:rutalibre/app/theme/brand.dart';

const _dir = 'marketing/assets';

/// El lienzo del carrusel, en píxeles lógicos. Con `pixelRatio: 3` da los
/// **1080 × 1350** que pide Instagram para el 4:5, que es el formato que más
/// pantalla ocupa en el feed.
const _feed = Size(360, 450);

/// Gris de los textos secundarios. Sobre el negro de marca, el blanco al 100%
/// en dos tamaños distintos se lee como un error de jerarquía: el cuerpo va
/// más apagado a propósito.
const _gris = Color(0xFFA8A8A8);

/// El aire de los bordes. Generoso: en el feed, un texto que roza el borde se
/// lee como una captura de pantalla y no como una pieza.
const _pad = 34.0;

// ─────────────────────────────────────────────────────────────────────────
// El modelo de un slide
// ─────────────────────────────────────────────────────────────────────────

enum _Fondo { negro, azul }

enum _Tipo {
  /// Titular y, opcionalmente, un cuerpo abajo.
  texto,

  /// Una cifra gigante con su etiqueta. Para tarifas y para los números de
  /// la red.
  numero,

  /// El cartel para el chofer: la pantalla entera con el número de la línea.
  /// Va sin marca ni contador — es una foto de la app, no una placa.
  cartel,

  /// El cierre de marca con el que termina cada carrusel.
  cierre,
}

/// Un slide.
///
/// En [titulo] y en [cuerpo], lo que va entre `[[` y `]]` se pinta con el
/// acento de la marca. Es la única forma de destacar que se usa: una palabra
/// o un número por slide, nunca dos.
class _Slide {
  const _Slide(this.titulo, {this.cuerpo, this.fondo = _Fondo.negro})
    : tipo = _Tipo.texto,
      colorCartel = null;

  const _Slide.numero(this.titulo, this.cuerpo, {this.fondo = _Fondo.negro})
    : tipo = _Tipo.numero,
      colorCartel = null;

  const _Slide.cartel(this.titulo, this.colorCartel)
    : cuerpo = null,
      fondo = _Fondo.negro,
      tipo = _Tipo.cartel;

  const _Slide.cierre()
    : titulo = '',
      cuerpo = null,
      fondo = _Fondo.negro,
      tipo = _Tipo.cierre,
      colorCartel = null;

  final String titulo;
  final String? cuerpo;
  final _Fondo fondo;
  final _Tipo tipo;
  final Color? colorCartel;
}

// ─────────────────────────────────────────────────────────────────────────
// El guion
// ─────────────────────────────────────────────────────────────────────────

/// Los siete carruseles, en orden de publicación.
const _carruseles = <String, List<_Slide>>{
  // C1 · Va primero: es lo único que ninguna otra app de transporte puede
  // copiar, porque para copiarlo tendría que dejar de mentir.
  'c1': [
    _Slide('Lo que esta app de colectivos [[NO]] hace'),
    _Slide(
      'No te dice a qué hora llega el colectivo.',
      cuerpo: 'Nadie lo sabe: no hay GPS público en la flota.',
    ),
    _Slide(
      'No inventa horarios.',
      cuerpo:
          'Un horario inventado manda a alguien a esperar '
          'un colectivo que no viene.',
    ),
    _Slide('No tiene publicidad.', cuerpo: 'Ni una.'),
    _Slide(
      'No te pide que te registres.',
      cuerpo: 'No hay cuenta, no hay mail, no hay contraseña.',
    ),
    _Slide(
      'No te rastrea.',
      cuerpo:
          'Pide tres permisos y ninguno corre en segundo plano. '
          'Tus favoritos viven en tu teléfono.',
    ),
    _Slide(
      'Lo que sí hace: te dice qué colectivo tomar, en qué esquina subir '
      'y en cuál bajar.',
      fondo: _Fondo.azul,
    ),
    _Slide.cierre(),
  ],

  // C2 · El de lanzamiento. Explica el producto entero en seis deslizadas.
  'c2': [
    _Slide('¿Cómo llego de acá hasta allá?'),
    _Slide(
      'Escribís a dónde vas.',
      cuerpo:
          'El hospital, la facultad, el shopping, la plaza. '
          'No hace falta la esquina.',
    ),
    _Slide(
      'Te dice qué colectivo tomar.',
      cuerpo: 'En qué esquina subís y en cuál te bajás.',
    ),
    _Slide(
      'Con transbordo, si hace falta.',
      cuerpo:
          'Sin transbordos la respuesta sería «no hay» '
          '[[6 de cada 10 veces]].',
    ),
    _Slide(
      'Y después te lleva paso a paso.',
      cuerpo: 'Un paso por pantalla, grande, para leerlo parado en la vereda.',
    ),
    _Slide('Gratis.\nSin publicidad.\nSin cuenta.\n[[Anda sin señal.]]'),
    _Slide.cierre(),
  ],

  // C3 · El «wow»: la función que hace que alguien se la muestre a otro.
  'c3': [
    _Slide('Viajar contando esquinas, pegado a la ventanilla.'),
    _Slide('Se terminó.'),
    _Slide(
      'La app cuenta las paradas que te faltan.',
      cuerpo: 'Mientras viajás.',
    ),
    _Slide(
      'Cuando falta una, el renglón se enciende y el teléfono [[vibra]] '
      'una vez.',
    ),
    _Slide(
      'Es geometría, no un horario.',
      cuerpo: 'Sigue tu posición contra las paradas del recorrido, en orden.',
    ),
    _Slide(
      'Si tu posición no cae en el tramo, [[se calla]].',
      cuerpo: 'Antes que adivinar, no dice nada.',
    ),
    _Slide(
      'Y se apaga al cerrar la guía.',
      cuerpo: 'Nunca corre en segundo plano.',
    ),
    _Slide.cierre(),
  ],

  // C4 · El más visual. Resuelve un problema físico, no digital.
  'c4': [
    _Slide('De noche, el colectivo no para si nadie le hace señas.'),
    _Slide(
      'Y una mano levantada no dice a cuál de los tres que vienen '
      'le estás haciendo señas.',
    ),
    // El «3» es la línea 3 del Gran Resistencia, con su color de la paleta
    // del importador.
    _Slide.cartel('3', Color(0xFF388E3C)),
    _Slide(
      'Un botón llena la pantalla con el número de tu línea, en su color.',
    ),
    _Slide(
      'Y sube el brillo al máximo solo.',
      cuerpo: 'Un cartel al 30% de brillo no es un cartel.',
    ),
    _Slide(
      'La pantalla del teléfono es la superficie más brillante que hay '
      'en la vereda.',
    ),
    _Slide.cierre(),
  ],

  // C5 · La puerta de entrada: nadie piensa en esquinas.
  'c5': [
    _Slide('¿Vos sabés en qué esquina queda el Perrando?'),
    _Slide('No hace falta.'),
    _Slide('Escribís «hospital» y aparece.'),
    _Slide.numero('2612', 'lugares del Gran Resistencia, adentro de la app'),
    _Slide(
      'Hospitales, escuelas, plazas, la terminal, el shopping, '
      'las facultades.',
      cuerpo: 'Se buscan [[sin señal]] desde el momento en que la instalás.',
    ),
    _Slide(
      'Lugares y paradas salen en la misma lista.',
      cuerpo: 'Ordenada por lo que mejor coincide con lo que escribiste.',
    ),
    _Slide.cierre(),
  ],

  // C6 · El más «noticia», y el único que envejece. Ver el aviso en
  // marketing/ig-carruseles.md antes de reponerlo.
  'c6': [
    _Slide('¿Cuánto sale el boleto hoy?'),
    _Slide.numero('\$1.885', 'Gran Resistencia'),
    _Slide.numero('\$1.890', 'Interurbano Chaco – Corrientes'),
    _Slide.numero(
      '\$2.921,10',
      'ramal del Campus de la UNNE',
      fondo: _Fondo.azul,
    ),
    _Slide(
      'Un [[55% más caro]] que el resto del interurbano.',
      cuerpo: 'Por eso se muestra aparte.',
    ),
    _Slide('Cada tarifa con la fecha desde la que rige y la fuente al lado.'),
    _Slide(
      'Un precio sin fecha es peor que no tener precio.',
      cuerpo: 'Alguien llega a la máquina con la plata contada.',
      fondo: _Fondo.azul,
    ),
    _Slide.cierre(),
  ],

  // C7 · Para la comunidad de OSM, datos abiertos y prensa. Es el que
  // consigue que otros hablen de la app.
  'c7': [
    _Slide('Esta app no tiene un mapa propio.'),
    _Slide(
      'Los recorridos y las paradas son de OpenStreetMap.',
      cuerpo: 'Los mapeó gente, a mano.',
    ),
    _Slide.numero('1474', 'paradas · 133 recorridos · 32 líneas'),
    _Slide(
      'Y 2638 paradas que OpenStreetMap no declaraba',
      cuerpo:
          'las dedujimos de la geometría del recorrido y del lado '
          'de la calle.',
    ),
    _Slide(
      '¿Encontraste una parada que ya no existe?',
      cuerpo:
          'La app te abre el nodo en OpenStreetMap para que la corrijas '
          '[[vos]].',
    ),
    _Slide('El mapa es de todos.', fondo: _Fondo.azul),
    _Slide.cierre(),
  ],
};

/// Los posts de imagen única. Son el relleno con sentido entre carrusel y
/// carrusel.
const _posts = <String, _Slide>{
  'p1-frase': _Slide(
    'Preferimos decir [[«no sabemos»]] antes que inventar un horario.',
  ),
  'p2-numeros': _Slide.numero(
    '1474',
    'paradas · 133 recorridos · 32 líneas · 2612 lugares',
  ),
  'p3-permisos': _Slide(
    'Esta app pide [[3 permisos]]. Ninguno corre en segundo plano.',
    cuerpo: 'Internet · Ubicación aproximada · Ubicación precisa',
  ),
  'p4-resistencia': _Slide('Hecha en Resistencia, Chaco.'),
};

// ─────────────────────────────────────────────────────────────────────────
// El dibujo
// ─────────────────────────────────────────────────────────────────────────

/// Parte [raw] en tramos, pintando con [acento] lo que venga entre `[[` y
/// `]]`.
List<TextSpan> _spans(String raw, Color acento) {
  final spans = <TextSpan>[];
  final marca = RegExp(r'\[\[(.+?)\]\]', dotAll: true);
  var i = 0;
  for (final m in marca.allMatches(raw)) {
    if (m.start > i) spans.add(TextSpan(text: raw.substring(i, m.start)));
    spans.add(
      TextSpan(
        text: m.group(1),
        style: TextStyle(color: acento),
      ),
    );
    i = m.end;
  }
  if (i < raw.length) spans.add(TextSpan(text: raw.substring(i)));
  return spans;
}

/// El texto sin las marcas de acento. Es lo que el guardarraíl de honestidad
/// lee, porque `[[` y `]]` no se imprimen.
String _plano(String raw) => raw.replaceAll(RegExp(r'\[\[|\]\]'), '');

/// El pie de cada slide: la marca chiquita y el nombre.
///
/// Va en TODOS los slides menos el cartel. En el feed, un carrusel se ve
/// deslizado y salteado: si la marca está solo en el último, los seis
/// primeros son de nadie.
Widget _pie({required bool sobreAzul, String? derecha}) => Row(
  children: [
    BrandMark(
      size: 17,
      bodyColor: Colors.white,
      // Sobre el azul, los faros azules desaparecen: se pintan del negro de
      // marca, que es el otro color de la casa.
      accentColor: sobreAzul ? Brand.black : Brand.accent,
    ),
    const SizedBox(width: 7),
    const Text(
      'Ruta Libre',
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: -0.2,
      ),
    ),
    const Spacer(),
    if (derecha != null)
      Text(
        derecha,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white.withValues(alpha: sobreAzul ? 0.75 : 0.45),
        ),
      ),
  ],
);

/// Un slide entero, listo para rasterizar.
Widget _plate(_Slide slide, {required int numero, required int total}) {
  final sobreAzul = slide.fondo == _Fondo.azul;
  final fondo = sobreAzul ? Brand.accent : Brand.black;
  // Sobre el azul no hay acento posible —sería el mismo color del fondo—, así
  // que ahí lo destacado se pinta de negro de marca.
  final acento = sobreAzul ? Brand.black : Brand.accent;

  if (slide.tipo == _Tipo.cartel) {
    // El cartel es una foto de la app, no una placa de campaña: sin marca,
    // sin contador y sin margen. Tiene que verse exactamente como se ve en
    // la vereda.
    return ColoredBox(
      color: slide.colorCartel!,
      child: Center(
        child: FittedBox(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              slide.titulo,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 300,
                height: 1,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  final Widget centro;
  switch (slide.tipo) {
    case _Tipo.cierre:
      centro = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BrandMark(size: 76),
          const SizedBox(height: 26),
          const Text(
            'Ruta Libre',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 46,
              height: 1.05,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -1.6,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Colectivos del Gran Resistencia\ny Corrientes',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 19,
              height: 1.35,
              fontWeight: FontWeight.w500,
              color: _gris,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Sin publicidad · Sin cuenta\nAnda sin señal',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 17,
              height: 1.35,
              fontWeight: FontWeight.w700,
              color: Brand.accent,
            ),
          ),
        ],
      );

    case _Tipo.numero:
      centro = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // La cifra manda: se estira hasta el ancho disponible y el resto de
          // la composición se acomoda abajo.
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              slide.titulo,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 96,
                height: 1,
                fontWeight: FontWeight.w800,
                color: sobreAzul ? Colors.white : Brand.accent,
                letterSpacing: -4,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            slide.cuerpo ?? '',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 21,
              height: 1.35,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      );

    case _Tipo.texto:
    case _Tipo.cartel:
      centro = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(children: _spans(slide.titulo, acento)),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 37,
              height: 1.15,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -1.3,
            ),
          ),
          if (slide.cuerpo != null) ...[
            const SizedBox(height: 22),
            Text.rich(
              TextSpan(children: _spans(slide.cuerpo!, acento)),
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                height: 1.4,
                fontWeight: FontWeight.w500,
                color: sobreAzul ? Colors.white : _gris,
              ),
            ),
          ],
        ],
      );
  }

  return ColoredBox(
    color: fondo,
    child: Padding(
      padding: const EdgeInsets.all(_pad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: centro),
          // El cierre no lleva el pie: ya tiene la marca grande arriba, y
          // repetirla chiquita abajo la muestra dos veces en el mismo slide.
          // En su lugar va lo único que falta decir, que es dónde se baja.
          if (slide.tipo == _Tipo.cierre)
            const Text(
              'Gratis en Google Play',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.2,
              ),
            )
          else
            _pie(
              sobreAzul: sobreAzul,
              // El primer slide invita a deslizar; los del medio dicen dónde
              // estás.
              derecha: total == 1
                  ? null
                  : numero == 1
                  ? 'deslizá →'
                  : '$numero/$total',
            ),
        ],
      ),
    ),
  );
}

/// Carga Inter de verdad para rasterizar.
///
/// **Sin esto los slides salen con cuadraditos**: en `flutter test` la fuente
/// por defecto dibuja cada glifo como una caja llena. Va DENTRO de
/// `tester.runAsync` — es el mismo gotcha que `toImage`, ver
/// `test/brand/brand_assets_test.dart`.
Future<void> _loadInter() async {
  final bytes = File('assets/fonts/Inter-Variable.ttf').readAsBytesSync();
  await (FontLoader(
        'Inter',
      )..addFont(Future.value(ByteData.sublistView(Uint8List.fromList(bytes)))))
      .load();
}

/// Todas las piezas, por nombre de archivo.
Map<String, Widget> _piezas() {
  final piezas = <String, Widget>{};
  _carruseles.forEach((carrusel, slides) {
    for (var i = 0; i < slides.length; i++) {
      final n = (i + 1).toString().padLeft(2, '0');
      piezas['$carrusel-$n.png'] = _plate(
        slides[i],
        numero: i + 1,
        total: slides.length,
      );
    }
  });
  _posts.forEach((nombre, slide) {
    piezas['$nombre.png'] = _plate(slide, numero: 1, total: 1);
  });
  return piezas;
}

void main() {
  final piezas = _piezas();

  test(
    'los PNG de la campaña están y no están vacíos',
    () {
      for (final nombre in piezas.keys) {
        final file = File('$_dir/$nombre');
        expect(
          file.existsSync(),
          isTrue,
          reason:
              'Falta $_dir/$nombre. Generalo: '
              'REGEN_SOCIAL=1 flutter test test/marketing/social_assets_test.dart',
        );
        expect(
          file.lengthSync(),
          greaterThan(1000),
          reason: '$nombre es muy chico',
        );
      }
    },
    skip: Platform.environment['REGEN_SOCIAL'] == '1',
  );

  // ── El guardarraíl de honestidad ────────────────────────────────────────
  //
  // Es el mismo de la ficha de Play (`test/store/listing_test.dart`) pero
  // sobre lo que va a quedar dibujado en la imagen. Un slide es más peligroso
  // que la ficha: se comparte suelto, sin el resto del contexto, y sobrevive
  // años en la galería de alguien.

  /// Todo el texto que termina impreso en un PNG.
  final copy = [
    for (final slides in _carruseles.values)
      for (final s in slides) ...[_plano(s.titulo), _plano(s.cuerpo ?? '')],
    for (final s in _posts.values) ...[
      _plano(s.titulo),
      _plano(s.cuerpo ?? ''),
    ],
  ].join('\n').toLowerCase();

  test('ningún slide promete lo que la app no hace', () {
    // La app NO sabe dónde está el colectivo: no hay GPS público en la flota.
    // Prometerlo consigue una instalación y pierde a la persona para siempre.
    expect(copy, isNot(contains('tiempo real')));
    expect(copy, isNot(contains('en vivo')));
    // «cuándo llega/pasa» es la promesa que no se puede cumplir. Ojo: el
    // carrusel C1 dice «no te dice a qué hora llega», que es lo contrario,
    // así que se busca la forma afirmativa.
    expect(copy, isNot(contains('sabé cuándo')));
    expect(copy, isNot(contains('a qué hora pasa')));
  });

  test('el carrusel de la tesis sigue diciendo la tesis', () {
    // Si alguien «mejora» C1 sacándole el slide incómodo, la campaña pierde
    // lo único que no se puede copiar.
    final c1 = _carruseles['c1']!
        .map((s) => '${s.titulo} ${s.cuerpo ?? ''}')
        .join(' ')
        .toLowerCase();
    expect(c1, contains('no inventa horarios'));
    expect(c1, contains('no hay gps público en la flota'));
  });

  test('cada carrusel cierra con la marca', () {
    _carruseles.forEach((nombre, slides) {
      expect(
        slides.last.tipo,
        _Tipo.cierre,
        reason: 'el carrusel $nombre no termina con el slide de marca',
      );
      // Instagram admite hasta 20; más de 10 no los desliza nadie.
      expect(slides.length, lessThanOrEqualTo(10), reason: nombre);
    });
  });

  testWidgets(
    'regenera los PNG de la campaña',
    timeout: const Timeout(Duration(minutes: 20)),
    skip: Platform.environment['REGEN_SOCIAL'] != '1',
    (tester) async {
      await tester.runAsync(_loadInter);

      tester.view
        ..physicalSize = Size(_feed.width + 40, _feed.height + 40)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      for (final entry in piezas.entries) {
        final key = GlobalKey();
        // RepaintBoundary y no PictureRecorder: dentro de `testWidgets`,
        // `Picture.toImage()` no completa nunca y el test se cuelga.
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Center(
              child: RepaintBoundary(
                key: key,
                child: SizedBox.fromSize(size: _feed, child: entry.value),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        await tester.runAsync(() async {
          // pixelRatio 3 sobre 360×450 = los 1080×1350 de Instagram.
          final image = await boundary.toImage(pixelRatio: 3);
          expect(image.width, 1080, reason: entry.key);
          expect(image.height, 1350, reason: entry.key);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          image.dispose();
          final file = File('$_dir/${entry.key}');
          await file.parent.create(recursive: true);
          await file.writeAsBytes(bytes!.buffer.asUint8List());
        });
      }

      for (final nombre in piezas.keys) {
        expect(File('$_dir/$nombre').lengthSync(), greaterThan(1000));
      }
    },
  );
}
