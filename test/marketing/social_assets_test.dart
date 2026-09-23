// Las piezas de la campaña: se verifican siempre, se REGENERAN a pedido.
//
//   flutter test test/marketing/social_assets_test.dart            → verifica
//   REGEN_SOCIAL=1 flutter test test/marketing/social_assets_test.dart → regenera
//
// Es el mismo trato que `test/brand/brand_assets_test.dart`, y por las mismas
// dos razones: rasterizar sesenta y pico de PNG grandes tarda demasiado para
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
// Las capturas de `marketing/capturas/` son del teléfono, de la versión final.
// Se recortan acá con `BoxFit.cover` y una alineación por slide: nunca se
// retoca una captura para que muestre algo que la app no hace.
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
const _capturas = 'marketing/capturas';

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

/// El lienzo de la story, en lógicos: con `pixelRatio: 3` da los
/// **1080 × 1920** del 9:16.
const _story = Size(360, 640);

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

  /// Titular arriba y una captura REAL de la app abajo, recortada.
  captura,

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
      imagen = null,
      alineacion = 0;

  const _Slide.numero(this.titulo, this.cuerpo, {this.fondo = _Fondo.negro})
    : tipo = _Tipo.numero,
      imagen = null,
      alineacion = 0;

  /// Una captura de `marketing/capturas/`. [alineacion] elige QUÉ parte se ve
  /// al recortar: -1 es el borde de arriba de la captura, 1 el de abajo.
  const _Slide.captura(
    this.titulo,
    this.imagen, {
    this.cuerpo,
    this.alineacion = 1,
  }) : tipo = _Tipo.captura,
       fondo = _Fondo.negro;

  const _Slide.cierre()
    : titulo = '',
      cuerpo = null,
      fondo = _Fondo.negro,
      tipo = _Tipo.cierre,
      imagen = null,
      alineacion = 0;

  final String titulo;
  final String? cuerpo;
  final _Fondo fondo;
  final _Tipo tipo;
  final String? imagen;
  final double alineacion;
}

// ─────────────────────────────────────────────────────────────────────────
// El guion
// ─────────────────────────────────────────────────────────────────────────

/// Los ocho carruseles, EN ORDEN DE PUBLICACIÓN.
///
/// El orden no es caprichoso: `c1` es la tesis (lo único que no se puede
/// copiar), `c2` presenta el producto, y `c3` y `c4` son las dos historias
/// que `docs/lanzamiento.md` manda contar primero — la alarma y las alturas.
const _carruseles = <String, List<_Slide>>{
  // C1 · Va primero: es lo único que ninguna otra app de transporte puede
  // copiar, porque para copiarlo tendría que dejar de mentir.
  'c1': [
    _Slide('Lo que esta app de colectivos [[NO]] hace'),
    _Slide(
      'No te dice a qué hora llega el colectivo.',
      cuerpo: 'No existe ningún dato público de dónde está cada coche.',
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

  // C2 · El de lanzamiento. Explica el producto entero, con capturas reales.
  'c2': [
    _Slide('¿Cómo llego de acá hasta allá?'),
    _Slide.captura(
      'Escribís a dónde vas.',
      '02-buscador-altura.png',
      cuerpo: 'El hospital, la escuela, la plaza — o tu casa, con la altura.',
      alineacion: -0.55,
    ),
    _Slide.captura(
      'Te dice qué colectivo tomar.',
      '03-como-llego.png',
      cuerpo: 'En qué esquina subís y en cuál te bajás.',
      alineacion: -0.2,
    ),
    _Slide(
      'Con transbordo, si hace falta.',
      cuerpo:
          'Sin transbordos la respuesta sería «no hay» '
          '[[6 de cada 10 veces]].',
    ),
    _Slide.captura(
      'Y después te lleva paso a paso.',
      '05-guia-caminata.png',
      cuerpo: 'Un paso por pantalla, grande, para leerlo parado en la vereda.',
    ),
    _Slide('Gratis.\nSin publicidad.\nSin cuenta.\n[[Anda sin señal.]]'),
    _Slide.cierre(),
  ],

  // C3 · La alarma. Es la función preferida del que la hizo y la que tiene
  // historia humana atrás — ver el pitch de `docs/lanzamiento.md`.
  'c3': [
    _Slide('¿Alguna vez te quedaste dormido en el colectivo?'),
    _Slide('Y te despertaste en la terminal.'),
    _Slide.captura(
      'Antes de arrancar, prendés la alarma.',
      '08-alarma-armada.png',
      cuerpo: '«Avisame para bajar». Un interruptor y listo.',
    ),
    _Slide(
      '[[Dos paradas]] antes de la tuya, suena.',
      cuerpo:
          'Dos y no una: entre abrir los ojos y juntar las cosas, '
          'una parada es muy justo. Lo dijo la prueba de campo.',
    ),
    _Slide.captura(
      'Suena fuerte aunque el teléfono esté en silencio.',
      '09-alarma-sonando.png',
      cuerpo: 'Con vibración, y la pantalla entera pidiéndote que te bajes.',
      alineacion: -0.1,
    ),
    _Slide(
      'Y solo la apaga el botón.',
      cuerpo:
          'Una alarma que se apaga rozándola medio dormido '
          'no despertó a nadie.',
    ),
    // El slide incómodo. Va adentro del carrusel de la función estrella a
    // propósito: es la marca.
    _Slide(
      'Necesita la app abierta.',
      cuerpo:
          'Con la pantalla apagada todavía no anda. Te lo decimos ahora '
          'y no cuando te falle: queda para la 1.1.',
      fondo: _Fondo.azul,
    ),
    _Slide.cierre(),
  ],

  // C4 · Las alturas. La segunda historia humana del pitch: buscaba mi propia
  // casa y la app no la encontraba.
  'c4': [
    _Slide('¿Cómo buscás tu casa en una app de colectivos?'),
    _Slide(
      'Las paradas se llaman por esquinas.',
      cuerpo: 'Tu casa tiene altura.',
    ),
    _Slide.captura(
      'Ahora escribís la dirección con el número.',
      '02-buscador-altura.png',
      cuerpo: 'Y cae en la cuadra real.',
      alineacion: -0.55,
    ),
    _Slide.numero(
      '58.000',
      'números de puerta mapeados en OpenStreetMap, adentro de la app',
    ),
    _Slide(
      '¿Y si tu número justo no está mapeado?',
      cuerpo: 'Te ofrece el más cercano [[con su número]], y te avisa.',
    ),
    _Slide(
      'Disfrazar el 1260 de 1250 sería mentirte la dirección.',
      cuerpo: 'E interpolarla sería inventarla.',
      fondo: _Fondo.azul,
    ),
    _Slide.cierre(),
  ],

  // C5 · El más visual. Resuelve un problema físico, no digital.
  'c5': [
    _Slide('De noche, el colectivo no para si nadie le hace señas.'),
    _Slide(
      'Y una mano levantada no dice a cuál de los tres que vienen '
      'le estás haciendo señas.',
    ),
    // La captura real del cartel, tal como se ve en la vereda.
    _Slide.captura('', '07-cartel-chofer.png', alineacion: 0),
    _Slide.captura(
      'Un botón llena la pantalla con el número de tu línea, en su color.',
      '06-guia-toma-la-2.png',
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

  // C6 · El contador en vivo. Es geometría, no un horario.
  'c6': [
    _Slide('Viajar contando esquinas, pegado a la ventanilla.'),
    _Slide('Se terminó.'),
    _Slide.captura(
      'La app cuenta las paradas que te faltan.',
      '08-alarma-armada.png',
      cuerpo: 'Mientras viajás.',
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

  // C7 · El más «noticia», y el único que envejece. Ver el aviso en
  // marketing/ig-carruseles.md antes de reponerlo.
  'c7': [
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

  // C8 · Para la comunidad de OSM, datos abiertos y prensa. Es el que
  // consigue que otros hablen de la app.
  'c8': [
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
    'paradas · 133 recorridos · 32 líneas · 58.000 alturas',
  ),
  'p3-permisos': _Slide(
    'Esta app pide [[3 permisos]]. Ninguno corre en segundo plano.',
    cuerpo: 'Internet · Ubicación aproximada · Ubicación precisa',
  ),
  'p4-resistencia': _Slide('Hecha en Resistencia, Chaco.'),
  'p5-alarma': _Slide(
    'Te despierta [[dos paradas]] antes de la tuya.',
    cuerpo: 'Aunque el teléfono esté en silencio.',
  ),
};

// ── Antes de que la app salga ───────────────────────────────────────────

/// Lo que dice el slide de cierre cuando la app ya está en la tienda.
const _cierreTienda = 'Gratis en Google Play';

/// Y lo que dice ANTES de que esté.
///
/// No es "Pronto en Google Play", y a propósito: un carrusel publicado no se
/// puede editar, así que la imagen queda en el perfil para siempre, y en tres
/// semanas "pronto" sería mentira. Lo que vence va en el caption, que sí se
/// edita. En la imagen, solo lo que no vence.
const _cierrePrelanzamiento = '@rutalibre.app';

/// Los carruseles que se publican mientras la app no está en Play, en el
/// orden en que se publican (ver `marketing/calendario.md`). Salen en
/// `prelanzamiento/` con el cierre que no vence. C2 NO está: es la
/// presentación del día que sale, y se publica con el link andando.
const _prelanzamiento = ['c1', 'c4', 'c8', 'c3'];

/// La story para juntar testers de la prueba cerrada.
///
/// Es story y no post a propósito: el pedido dura dos semanas, y un post que
/// dice "buscamos testers" quedaría en el perfil para siempre.
const _testers = (
  rotulo: 'BUSCAMOS TESTERS',
  titulo: '¿La querés probar antes que nadie?',
  porque:
      'Google nos pide 12 personas probándola 14 días antes de dejarnos '
      'publicarla.',
  pasos: [
    (texto: 'Mandanos tu Gmail por DM', nota: null),
    (texto: 'Aceptá la invitación y bajala de Play Store', nota: null),
    (
      texto: 'Dejala instalada 14 días',
      // Es el renglón que más importa: el que la desinstala le reinicia el
      // contador a la prueba entera, y nadie lo sabe si no se lo dicen.
      nota: 'Si la desinstalás, el contador de Google vuelve a cero.',
    ),
  ],
  pie: 'Solo Android · Gratis · Sin publicidad',
);

const _storyTesters = 'prelanzamiento/story-testers.png';

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

/// Todo el texto que queda impreso en la story de testers.
List<String> _textoStory() => [
  _testers.rotulo,
  _testers.titulo,
  _testers.porque,
  for (final paso in _testers.pasos) ...[paso.texto, ?paso.nota],
  _testers.pie,
];

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

/// Un slide entero, listo para rasterizar. [imagenes] trae las capturas ya
/// decodificadas (ver `_cargarCapturas`).
Widget _plate(
  _Slide slide, {
  required int numero,
  required int total,
  required String cierre,
  required Map<String, ui.Image> imagenes,
}) {
  final sobreAzul = slide.fondo == _Fondo.azul;
  final fondo = sobreAzul ? Brand.accent : Brand.black;
  // Sobre el azul no hay acento posible —sería el mismo color del fondo—, así
  // que ahí lo destacado se pinta de negro de marca.
  final acento = sobreAzul ? Brand.black : Brand.accent;

  // El slide de captura tiene su propia composición: el texto arriba y la
  // captura ocupando lo que sobra, sangrada abajo. La captura NO se encoge
  // para entrar entera —a ese tamaño no se leería nada— sino que se recorta
  // por donde dice `alineacion`.
  if (slide.tipo == _Tipo.captura) {
    final imagen = imagenes[slide.imagen!]!;
    // Una captura SIN título va a sangre: es la pieza entera, no la
    // ilustración de una frase. Es lo que necesita el cartel para el chofer,
    // donde la gracia es justamente que la pantalla entera se vuelve cartel —
    // enmarcarlo en negro contaría lo contrario de lo que muestra.
    if (slide.titulo.isEmpty) {
      return SizedBox.expand(
        child: RawImage(
          image: imagen,
          fit: BoxFit.cover,
          alignment: Alignment(0, slide.alineacion),
          filterQuality: FilterQuality.medium,
        ),
      );
    }
    return ColoredBox(
      color: fondo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(_pad, _pad, _pad, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(children: _spans(slide.titulo, acento)),
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 28,
                      height: 1.14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                  ),
                  if (slide.cuerpo != null) ...[
                    const SizedBox(height: 10),
                    Text.rich(
                      TextSpan(children: _spans(slide.cuerpo!, acento)),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                        color: _gris,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),
          ],
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: _pad),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                child: SizedBox.expand(
                  child: RawImage(
                    image: imagen,
                    fit: BoxFit.cover,
                    alignment: Alignment(0, slide.alineacion),
                    filterQuality: FilterQuality.medium,
                  ),
                ),
              ),
            ),
          ),
        ],
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
            style: const TextStyle(
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
    case _Tipo.captura:
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
          // En su lugar va lo único que falta decir: dónde se baja, o —antes
          // de que esté en la tienda— dónde encontrarla.
          if (slide.tipo == _Tipo.cierre)
            Text(
              cierre,
              style: const TextStyle(
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

/// La story para juntar testers, a 9:16.
///
/// Los márgenes de arriba y de abajo son grandes a propósito: Instagram tapa
/// el tope con la barra del perfil y el pie con la de respuesta, así que ahí
/// no puede ir nada que haya que leer.
Widget _storyWidget() => ColoredBox(
  color: Brand.black,
  child: Padding(
    padding: const EdgeInsets.fromLTRB(30, 64, 30, 96),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _pie(sobreAzul: false),
        const SizedBox(height: 28),
        Text(
          _testers.rotulo,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Brand.accent,
            letterSpacing: 1.6,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _testers.titulo,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 32,
            height: 1.1,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -1.4,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _testers.porque,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            height: 1.4,
            fontWeight: FontWeight.w500,
            color: _gris,
          ),
        ),
        const SizedBox(height: 22),
        // Numerados porque SON un orden: sin el Gmail no hay invitación, y
        // sin instalar no cuenta.
        for (final (i, paso) in _testers.pasos.indexed) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Brand.accent,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${i + 1}',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        paso.texto,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 17,
                          height: 1.25,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    if (paso.nota != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        paso.nota!,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                          color: _gris,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
        ],
        const Spacer(),
        Text(
          _testers.pie,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _gris,
          ),
        ),
      ],
    ),
  ),
);

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

/// Decodifica las capturas que usan los slides. También va dentro de
/// `runAsync`: decodificar un PNG lo hace el engine, fuera del reloj falso.
Future<Map<String, ui.Image>> _cargarCapturas(Iterable<String> nombres) async {
  final imagenes = <String, ui.Image>{};
  for (final nombre in nombres) {
    final bytes = File('$_capturas/$nombre').readAsBytesSync();
    final codec = await ui.instantiateImageCodec(bytes);
    imagenes[nombre] = (await codec.getNextFrame()).image;
  }
  return imagenes;
}

typedef _Pieza = ({
  String archivo,
  _Slide slide,
  int numero,
  int total,
  String cierre,
});

/// Los slides de un carrusel, con el nombre de archivo que les toca.
List<_Pieza> _carrusel(
  String codigo, {
  String carpeta = '',
  required String cierre,
}) {
  final slides = _carruseles[codigo]!;
  return [
    for (var i = 0; i < slides.length; i++)
      (
        archivo: '$carpeta$codigo-${(i + 1).toString().padLeft(2, '0')}.png',
        slide: slides[i],
        numero: i + 1,
        total: slides.length,
        cierre: cierre,
      ),
  ];
}

/// Todas las piezas de 4:5, aplanadas: la campaña del lanzamiento y, aparte,
/// los carruseles de antes de que la app salga.
List<_Pieza> _piezas() => [
  for (final codigo in _carruseles.keys)
    ..._carrusel(codigo, cierre: _cierreTienda),
  for (final MapEntry(key: nombre, value: slide) in _posts.entries)
    (
      archivo: '$nombre.png',
      slide: slide,
      numero: 1,
      total: 1,
      cierre: _cierreTienda,
    ),
  for (final codigo in _prelanzamiento)
    ..._carrusel(
      codigo,
      carpeta: 'prelanzamiento/',
      cierre: _cierrePrelanzamiento,
    ),
];

/// Captura [key] a `pixelRatio: 3`, verifica el tamaño y escribe el PNG.
Future<void> _escribir(
  WidgetTester tester,
  GlobalKey key,
  String archivo,
  Size tamano,
) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 3);
    expect(image.width, tamano.width * 3, reason: archivo);
    expect(image.height, tamano.height * 3, reason: archivo);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    final file = File('$_dir/$archivo');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes!.buffer.asUint8List());
  });
}

/// Monta [child] a [tamano] adentro de un RepaintBoundary con [key].
///
/// RepaintBoundary y no PictureRecorder: dentro de `testWidgets`,
/// `Picture.toImage()` no completa nunca y el test se cuelga.
Widget _lienzo(GlobalKey key, Size tamano, Widget child) => Directionality(
  textDirection: TextDirection.ltr,
  child: Center(
    child: RepaintBoundary(
      key: key,
      child: SizedBox.fromSize(size: tamano, child: child),
    ),
  ),
);

void main() {
  final piezas = _piezas();

  test(
    'los PNG de la campaña están y no están vacíos',
    () {
      for (final archivo in [...piezas.map((p) => p.archivo), _storyTesters]) {
        final file = File('$_dir/$archivo');
        expect(
          file.existsSync(),
          isTrue,
          reason:
              'Falta $_dir/$archivo. Generalo: '
              'REGEN_SOCIAL=1 flutter test test/marketing/social_assets_test.dart',
        );
        expect(
          file.lengthSync(),
          greaterThan(1000),
          reason: '$archivo es muy chico',
        );
      }
    },
    skip: Platform.environment['REGEN_SOCIAL'] == '1',
  );

  test('las capturas que usan los slides existen', () {
    // Un slide de captura que apunta a un archivo borrado no falla al
    // generar: falla al rasterizar, cincuenta PNG después.
    for (final pieza in piezas.where((p) => p.slide.imagen != null)) {
      expect(
        File('$_capturas/${pieza.slide.imagen}').existsSync(),
        isTrue,
        reason: 'falta $_capturas/${pieza.slide.imagen}',
      );
    }
  });

  // ── El guardarraíl de honestidad ────────────────────────────────────────
  //
  // Es el mismo de la ficha de Play (`test/store/listing_test.dart`) pero
  // sobre lo que va a quedar dibujado en la imagen. Un slide es más peligroso
  // que la ficha: se comparte suelto, sin el resto del contexto, y sobrevive
  // años en la galería de alguien.

  /// Todo el texto que termina impreso en un PNG.
  final copy = [
    for (final p in piezas) ...[
      _plano(p.slide.titulo),
      _plano(p.slide.cuerpo ?? ''),
    ],
    ..._textoStory(),
  ].join('\n').toLowerCase();

  test('ningún slide promete lo que la app no hace', () {
    // La app NO sabe dónde está el colectivo: no existe ningún feed público y
    // abierto de posición. Se afirma la falta del DATO ABIERTO y nunca que
    // "nadie tiene GPS" — hay unidades que sí lo tienen, ver
    // privado/competencia.md.
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
    // El renglón incómodo. Dice la FALTA DEL DATO ABIERTO y no "nadie tiene
    // GPS": hay unidades con GPS y hay un sistema de arribos montado sobre 16
    // líneas que hoy devuelve 500 (ver privado/competencia.md). Que a otro se le
    // caiga el servidor no nos habilita a decir que no existe.
    expect(c1, contains('no existe ningún dato público'));
    // Y nunca una acusación contra un tercero: eso ya lo prohíbe
    // privado/estrategia.md, y encima sería falso.
    expect(c1, isNot(contains('inventando')));
    expect(c1, isNot(contains('nadie lo sabe')));
  });

  test('el carrusel de la alarma dice su límite', () {
    // La alarma necesita la app abierta. Venderla sin ese renglón es
    // exactamente lo que la app no hace con sus propios datos: alguien se
    // dormiría confiando en algo que, con la pantalla apagada, no suena.
    final c3 = _carruseles['c3']!
        .map((s) => '${s.titulo} ${s.cuerpo ?? ''}')
        .join(' ')
        .toLowerCase();
    expect(c3, contains('necesita la app abierta'));
    expect(c3, contains('1.1'));
  });

  test('lo de antes de salir no dice que la app ya está en la tienda', () {
    // La imagen de un carrusel publicado no se edita: si el cierre dijera
    // "Google Play" o "pronto", sería falso hoy o dentro de tres semanas.
    final cierre = _cierrePrelanzamiento.toLowerCase();
    expect(cierre, isNot(contains('play')));
    expect(cierre, isNot(contains('pronto')));
    // Y C2, la presentación, se guarda para el día que sale.
    expect(_prelanzamiento, isNot(contains('c2')));
  });

  test('la story de testers dice lo que le pide a la gente', () {
    // Un tester que no sabe que tiene que quedarse 14 días la desinstala al
    // tercero y reinicia el contador de la prueba entera. Y uno con iPhone
    // manda su mail para nada.
    final story = _textoStory().join(' ').toLowerCase();
    expect(story, contains('14 días'));
    expect(story, contains('android'));
    expect(story, contains('gmail'));
    expect(story, contains('desinstal'));
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
      late final Map<String, ui.Image> imagenes;
      await tester.runAsync(() async {
        await _loadInter();
        imagenes = await _cargarCapturas({
          for (final p in piezas)
            if (p.slide.imagen != null) p.slide.imagen!,
        });
      });

      // Se limpia antes de escribir, subcarpetas incluidas: si un carrusel
      // pierde un slide, el PNG sobrante se quedaría en la carpeta para
      // siempre y alguien lo subiría.
      final dir = Directory(_dir);
      if (dir.existsSync()) {
        for (final f in dir.listSync(recursive: true)) {
          if (f is File && f.path.endsWith('.png')) f.deleteSync();
        }
      }

      // El lienzo de la vista alcanza para el más grande de los dos formatos.
      tester.view
        ..physicalSize = Size(_story.width + 40, _story.height + 40)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      for (final pieza in piezas) {
        final key = GlobalKey();
        await tester.pumpWidget(
          _lienzo(
            key,
            _feed,
            _plate(
              pieza.slide,
              numero: pieza.numero,
              total: pieza.total,
              cierre: pieza.cierre,
              imagenes: imagenes,
            ),
          ),
        );
        // pixelRatio 3 sobre 360×450 = los 1080×1350 de Instagram.
        await _escribir(tester, key, pieza.archivo, _feed);
      }

      final key = GlobalKey();
      await tester.pumpWidget(_lienzo(key, _story, _storyWidget()));
      // Y sobre 360×640, los 1080×1920 de la story.
      await _escribir(tester, key, _storyTesters, _story);

      for (final archivo in [...piezas.map((p) => p.archivo), _storyTesters]) {
        expect(File('$_dir/$archivo').lengthSync(), greaterThan(1000));
      }
    },
  );
}
