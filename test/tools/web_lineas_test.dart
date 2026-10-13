import 'dart:convert';

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
