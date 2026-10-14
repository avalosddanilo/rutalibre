import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tools/src/web_lineas.dart';

WebData _data({
  String stopName = 'La Rioja y Junín',
  String color = '#E64A19',
}) => WebData(
  updatedOn: '13/10/2026',
  lines: [
    WebLine(
      networkCode: 'corrientes-capital',
      networkName: 'Corrientes Capital',
      code: '102',
      name: 'Laguna Brava ↔ Centro',
      colorHex: color,
      variants: [
        WebVariant(
          name: 'Ida: Laguna Brava ↔ Centro',
          branch: 'C',
          direction: 0,
          stops: [
            const WebStop(
              name: 'Pedro Araoz y Avenida Independencia',
              lat: -27.48308,
              lng: -58.792402,
            ),
            WebStop(name: stopName, lat: -27.4678, lng: -58.8380),
          ],
          geometry: const [(-27.48308, -58.792402), (-27.4678, -58.838)],
        ),
      ],
    ),
    const WebLine(
      networkCode: 'interurbano-chaco-corrientes',
      networkName: 'Chaco ↔ Corrientes',
      code: '904A',
      name: 'Chaco ↔ Corrientes por el Campus',
      colorHex: '#7B1FA2',
      variants: [],
    ),
  ],
);

void main() {
  const base = 'https://avalosddanilo.github.io/rutalibre/';

  test('las URL son cortas y como se escriben', () {
    expect(_data().lines.first.path, 'corrientes/linea-102.html');
    expect(_data().lines.last.path, 'chaco-corrientes/linea-904a.html');
    expect(slug('Línea Ñandú 3'), 'linea-nandu-3');
  });

  test('una página por línea, el índice, el sitemap y robots', () {
    final files = renderSite(_data(), baseUrl: base);
    expect(
      files.keys,
      containsAll([
        'index.html',
        'sitemap.xml',
        'robots.txt',
        'estilo.css',
        'corrientes/linea-102.html',
        'chaco-corrientes/linea-904a.html',
      ]),
    );
    expect(files['sitemap.xml'], contains('${base}corrientes/linea-102.html'));
    expect(files['robots.txt'], contains('${base}sitemap.xml'));
  });

  test(
    'la página de la línea tiene título para buscar y todas sus paradas',
    () {
      final page = renderSite(
        _data(),
        baseUrl: base,
      )['corrientes/linea-102.html']!;
      expect(
        page,
        contains('<title>Línea 102 de Corrientes: recorrido y paradas'),
      );
      expect(page, contains('<li>Pedro Araoz y Avenida Independencia</li>'));
      expect(page, contains('<li>La Rioja y Junín</li>'));
      expect(
        page,
        contains('rel="canonical" href="${base}corrientes/linea-102.html"'),
      );
      // El sentido se muestra aparte: no "Ida Ida: …".
      expect(page, isNot(contains('Ida: Laguna')));
    },
  );

  test('lleva a la app y no promete horarios', () {
    final page = renderSite(
      _data(),
      baseUrl: base,
    )['corrientes/linea-102.html']!;
    expect(page, contains(playUrl));
    expect(page, contains('No mostramos horarios'));
    expect(page, isNot(contains('cada ')), reason: 'nada de frecuencias');
  });

  test('un nombre de parada con HTML se escapa, no se ejecuta', () {
    final page = renderSite(
      _data(stopName: '<script>alert(1)</script>'),
      baseUrl: base,
    )['corrientes/linea-102.html']!;
    expect(page, isNot(contains('<script>alert(1)</script>')));
    expect(page, contains('&lt;script&gt;'));
  });

  test('un color raro de la base no entra al style', () {
    final page = renderSite(
      _data(color: 'red;background:url(x)'),
      baseUrl: base,
    )['corrientes/linea-102.html']!;
    expect(page, isNot(contains('url(x)')));
    expect(page, contains('--c:#1E88E5'));
  });

  test('un nombre de parada tampoco puede cortar el script del mapa', () {
    final page = renderSite(
      _data(stopName: '</script><img src=x onerror=alert(1)>'),
      baseUrl: base,
    )['corrientes/linea-102.html']!;
    // En el JSON del mapa los "<" van escapados: el navegador no ve un
    // </script> que cierre el bloque antes de tiempo.
    expect(page, isNot(contains('</script><img')));
    expect(page, contains(r'</script>'));
  });

  test('cada página tiene imagen para compartir, y nunca un link roto', () {
    final sinOg = renderSite(_data(), baseUrl: base);
    expect(
      sinOg['corrientes/linea-102.html'],
      contains('og:image" content="${base}img/compartir.jpg"'),
    );

    final line = _data().lines.first;
    final conOg = renderSite(
      _data(),
      baseUrl: base,
      ogImages: {ogLinePath(line), ogIndexPath},
    );
    expect(
      conOg['corrientes/linea-102.html'],
      contains('og:image" content="$base${ogLinePath(line)}"'),
    );
    expect(
      conOg['index.html'],
      contains('og:image" content="$base$ogIndexPath"'),
    );
    // El 904A no tiene imagen propia: usa la genérica.
    expect(
      conOg['chaco-corrientes/linea-904a.html'],
      contains('og:image" content="${base}img/compartir.jpg"'),
    );
  });

  test('hay una plantilla de imagen por línea y una para la portada', () {
    final templates = renderOgTemplates(_data());
    expect(templates.keys, hasLength(3));
    expect(templates[ogLinePath(_data().lines.first)], contains('Línea 102'));
    expect(templates[ogIndexPath], contains('Resistencia y Corrientes'));
  });

  test('la portada tiene buscador, pestañas por ciudad y preguntas', () {
    final index = renderSite(_data(), baseUrl: base)['index.html']!;
    expect(index, contains('id="q" type="search"'));
    expect(index, contains('data-red="corrientes"'));
    expect(index, contains('"@type":"FAQPage"'));
    // Lo que se busca va sin tildes ni mayúsculas, como se escribe apurado.
    expect(index, contains('data-q="102 laguna brava'));
  });

  test('una línea con varios recorridos tiene una pestaña por recorrido', () {
    final data = _data();
    final line = data.lines.first;
    final twoWays = WebData(
      updatedOn: data.updatedOn,
      lines: [
        WebLine(
          networkCode: line.networkCode,
          networkName: line.networkName,
          code: line.code,
          name: line.name,
          colorHex: line.colorHex,
          variants: [
            line.variants.first,
            WebVariant(
              name: 'Vuelta: Centro → Laguna Brava',
              branch: 'C',
              direction: 1,
              stops: line.variants.first.stops.reversed.toList(),
              geometry: line.variants.first.geometry.reversed.toList(),
            ),
          ],
        ),
      ],
    );
    final page = renderSite(
      twoWays,
      baseUrl: base,
    )['corrientes/linea-102.html']!;
    expect('class="tab"'.allMatches(page), hasLength(2));
    expect(page, contains('<span class="sentido">Vuelta</span> →'));
  });

  test('un recorrido que se llama solo "Ida" no dice "Ida Ida"', () {
    final data = _data();
    final line = data.lines.first;
    final page = renderSite(
      WebData(
        updatedOn: data.updatedOn,
        lines: [
          WebLine(
            networkCode: line.networkCode,
            networkName: line.networkName,
            code: line.code,
            name: line.name,
            colorHex: line.colorHex,
            variants: [
              for (final name in ['Ida', 'Vuelta: Centro → Laguna Brava'])
                WebVariant(
                  name: name,
                  branch: null,
                  direction: name == 'Ida' ? 0 : 1,
                  stops: line.variants.first.stops,
                  geometry: line.variants.first.geometry,
                ),
            ],
          ),
        ],
      ),
      baseUrl: base,
    )['corrientes/linea-102.html']!;
    expect(page, isNot(contains('Ida</span> Ida')));
    expect(page, contains('<span class="sentido">Ida</span> </button>'));
  });

  test('los archivos fijos del sitio existen en el repo', () {
    for (final source in webAssets.values) {
      expect(File(source).existsSync(), isTrue, reason: source);
    }
  });

  test('ida y vuelta por JSON no pierde nada', () {
    final again = webDataFromJson(
      jsonDecode(jsonEncode(webDataToJson(_data()))) as Map<String, dynamic>,
    );
    expect(
      renderSite(again, baseUrl: base),
      renderSite(_data(), baseUrl: base),
    );
  });
}
