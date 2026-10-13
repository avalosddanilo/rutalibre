/// Las páginas web de las líneas: una por línea, más el índice.
///
/// **Para qué.** La gente busca en Google "recorrido línea 102 Corrientes" o
/// "qué colectivo me deja en el Perrando" todos los días, y hoy no encuentra
/// nada bueno. Una página por línea, con su recorrido y sus paradas, contesta
/// esa búsqueda y lleva a la app. Sale de los mismos datos que la app, así
/// que no hay nada que mantener a mano.
///
/// **Qué NO dice.** Ni horarios ni frecuencias: no hay una fuente abierta, y
/// la regla de la app vale acá también. Y nada sobre nadie: ni la
/// Municipalidad, ni las empresas, ni el gremio.
///
/// Dart PURO: recibe los datos ya bajados y devuelve los archivos. La
/// descarga está en `tools/web_lineas.dart`.
library;

import 'dart:convert';

/// Una parada, como se ve en la lista.
class WebStop {
  const WebStop({required this.name, required this.lat, required this.lng});

  final String name;
  final double lat;
  final double lng;
}

/// Un recorrido de una línea (un ramal en un sentido).
class WebVariant {
  const WebVariant({
    required this.name,
    required this.branch,
    required this.direction,
    required this.stops,
    required this.geometry,
  });

  final String name;
  final String? branch;

  /// 0 = ida, 1 = vuelta.
  final int direction;

  /// En orden de paso.
  final List<WebStop> stops;

  /// El trazado como pares (lat, lng).
  final List<(double, double)> geometry;
}

/// Una línea con sus recorridos.
class WebLine {
  const WebLine({
    required this.networkCode,
    required this.networkName,
    required this.code,
    required this.name,
    required this.colorHex,
    required this.variants,
  });

  final String networkCode;
  final String networkName;
  final String code;
  final String name;
  final String colorHex;
  final List<WebVariant> variants;

  /// La ruta de la página, relativa a la raíz del sitio.
  String get path => '${networkSlug(networkCode)}/linea-${slug(code)}.html';
}

/// Todo lo que hace falta para armar el sitio.
class WebData {
  const WebData({required this.lines, required this.updatedOn});

  /// En el orden en que se muestran (red y después línea).
  final List<WebLine> lines;

  /// "13/10/2026": de cuándo son los datos.
  final String updatedOn;
}

/// La ficha de Ruta Libre en Google Play.
const playUrl =
    'https://play.google.com/store/apps/details?id=com.rutalibre.rutalibre';

/// Cómo se nombra cada red en la URL. Corto y como lo escribiría alguien.
String networkSlug(String networkCode) => switch (networkCode) {
  'gran-resistencia' => 'resistencia',
  'corrientes-capital' => 'corrientes',
  'interurbano-chaco-corrientes' => 'chaco-corrientes',
  'interurbano-chaco' => 'interurbano-chaco',
  _ => slug(networkCode),
};

/// Cómo se nombra cada red en un título: "Corrientes", no "Corrientes
/// Capital", porque es como se busca.
String networkPlace(String networkCode, String networkName) =>
    switch (networkCode) {
      'gran-resistencia' => 'Resistencia',
      'corrientes-capital' => 'Corrientes',
      'interurbano-chaco-corrientes' => 'Chaco–Corrientes',
      _ => networkName,
    };

/// "904A" → "904a"; "Línea Ñ" → "linea-n". Solo minúsculas, números y guiones.
String slug(String value) {
  const accents = {
    'á': 'a',
    'é': 'e',
    'í': 'i',
    'ó': 'o',
    'ú': 'u',
    'ü': 'u',
    'ñ': 'n',
  };
  final lower = value
      .toLowerCase()
      .split('')
      .map((c) => accents[c] ?? c)
      .join();
  return lower
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
}

/// El sitio entero: ruta relativa → contenido.
///
/// [baseUrl] termina en `/` y es donde va a vivir el sitio (para el sitemap
/// y las URL canónicas, que Google necesita absolutas).
Map<String, String> renderSite(WebData data, {required String baseUrl}) {
  final files = <String, String>{
    'index.html': _index(data, baseUrl),
    'sitemap.xml': _sitemap(data, baseUrl),
    'robots.txt': 'User-agent: *\nAllow: /\nSitemap: ${baseUrl}sitemap.xml\n',
    'estilo.css': _css,
  };
  for (final line in data.lines) {
    files[line.path] = _linePage(line, data, baseUrl);
  }
  return files;
}

// ---------------------------------------------------------------------------
// Páginas
// ---------------------------------------------------------------------------

String _linePage(WebLine line, WebData data, String baseUrl) {
  final place = networkPlace(line.networkCode, line.networkName);
  final title = 'Línea ${line.code} de $place: recorrido y paradas';
  final stopCount = {
    for (final v in line.variants)
      for (final s in v.stops) s.name,
  }.length;
  final description =
      'Recorrido de la línea ${line.code} ($place): ${_text(line.name)}. '
      '$stopCount paradas, ${line.variants.length} '
      '${line.variants.length == 1 ? 'recorrido' : 'recorridos'}. '
      'Gratis en Ruta Libre.';
  final color = _safeColor(line.colorHex);

  final variants = StringBuffer();
  for (final variant in line.variants) {
    variants
      ..writeln('<details class="recorrido">')
      ..writeln(
        '<summary><span class="sentido">'
        '${variant.direction == 1 ? 'Vuelta' : 'Ida'}</span> '
        '${_esc(_text(_variantLabel(variant.name)))} '
        '<span class="cuenta">${variant.stops.length} paradas</span></summary>',
      )
      ..writeln('<ol>');
    for (final stop in variant.stops) {
      variants.writeln('<li>${_esc(stop.name)}</li>');
    }
    variants
      ..writeln('</ol>')
      ..writeln('</details>');
  }

  // El trazado para el mapa: 5 decimales (~1 m) alcanzan y achican la página.
  final shapes = jsonEncode([
    for (final v in line.variants)
      [
        for (final (lat, lng) in v.geometry) [_round(lat), _round(lng)],
      ],
  ]);

  final others = data.lines
      .where((l) => l.networkCode == line.networkCode && l.code != line.code)
      .map(
        (l) =>
            '<a class="chip" href="../${l.path}" style="--c:${_safeColor(l.colorHex)}">${_esc(l.code)}</a>',
      )
      .join(' ');

  return _page(
    title: title,
    description: description,
    canonical: '$baseUrl${line.path}',
    depth: 1,
    head:
        '<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css">',
    body:
        '''
<header class="top"><a href="../index.html" class="marca">Ruta Libre</a></header>
<main>
<p class="red">${_esc(place)}</p>
<h1><span class="badge" style="--c:$color">${_esc(line.code)}</span> Línea ${_esc(line.code)}</h1>
<p class="sub">${_esc(_text(line.name))}</p>
<div id="mapa" aria-label="Mapa del recorrido"></div>
${_cta('¿Qué colectivo te lleva?', 'Ruta Libre te dice qué línea tomar, en qué esquina subir y en cuál bajar. Y te avisa antes de tu parada.')}
<h2>Recorridos y paradas</h2>
<p class="nota">Tocá un recorrido para ver sus paradas, en orden.</p>
$variants
<h2>Otras líneas de ${_esc(place)}</h2>
<p class="chips">$others</p>
</main>
${_footer(data, line.networkCode)}
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<script>
(function () {
  var shapes = $shapes;
  var map = L.map('mapa', { scrollWheelZoom: false });
  map.attributionControl.setPrefix('<a href="https://leafletjs.com">Leaflet</a>');
  L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: 18,
    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
  }).addTo(map);
  var bounds = [];
  shapes.forEach(function (s) {
    if (s.length < 2) return;
    L.polyline(s, { color: '$color', weight: 4, opacity: 0.85 }).addTo(map);
    bounds = bounds.concat(s);
  });
  if (bounds.length) map.fitBounds(bounds, { padding: [16, 16] });
  else map.setView([-27.46, -58.9], 11);
})();
</script>''',
  );
}

String _index(WebData data, String baseUrl) {
  final byNetwork = <String, List<WebLine>>{};
  for (final line in data.lines) {
    byNetwork.putIfAbsent(line.networkCode, () => []).add(line);
  }
  final sections = StringBuffer();
  for (final MapEntry(key: code, value: lines) in byNetwork.entries) {
    final place = networkPlace(code, lines.first.networkName);
    sections
      ..writeln('<h2>${_esc(place)}</h2>')
      ..writeln('<ul class="lineas">');
    for (final line in lines) {
      sections.writeln(
        '<li><a href="${line.path}"><span class="badge" '
        'style="--c:${_safeColor(line.colorHex)}">${_esc(line.code)}</span>'
        '<span>${_esc(_text(line.name))}</span></a></li>',
      );
    }
    sections.writeln('</ul>');
  }

  return _page(
    title: 'Colectivos de Resistencia y Corrientes: recorridos y paradas',
    description:
        'Los recorridos y las paradas de las ${data.lines.length} líneas de '
        'colectivo del Gran Resistencia y Corrientes capital. Y la app gratis '
        'que te dice qué colectivo tomar.',
    canonical: baseUrl,
    depth: 0,
    head: '',
    body:
        '''
<header class="top"><span class="marca">Ruta Libre</span></header>
<main>
<h1>Qué colectivo tomar en <b>Resistencia y Corrientes</b></h1>
<p class="sub">Los recorridos y las paradas de cada línea. Y una app gratis, sin publicidad y sin cuenta, que te dice cuál tomar.</p>
${_cta('Bajala gratis', 'Le decís a dónde vas y te dice qué línea tomar, dónde subir y dónde bajar. Con alarma para no pasarte de parada.')}
$sections
</main>
${_footer(data, null)}''',
  );
}

String _sitemap(WebData data, String baseUrl) {
  final urls = [baseUrl, for (final line in data.lines) '$baseUrl${line.path}'];
  return '<?xml version="1.0" encoding="UTF-8"?>\n'
      '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n'
      '${urls.map((u) => '  <url><loc>${_esc(u)}</loc></url>').join('\n')}\n'
      '</urlset>\n';
}

// ---------------------------------------------------------------------------
// Piezas
// ---------------------------------------------------------------------------

String _page({
  required String title,
  required String description,
  required String canonical,
  required int depth,
  required String head,
  required String body,
}) {
  final up = '../' * depth;
  return '''
<!doctype html>
<html lang="es-AR">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${_esc(title)} | Ruta Libre</title>
<meta name="description" content="${_esc(description)}">
<link rel="canonical" href="${_esc(canonical)}">
<meta property="og:title" content="${_esc(title)}">
<meta property="og:description" content="${_esc(description)}">
<meta property="og:type" content="website">
<meta name="theme-color" content="#161616">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;800&display=swap">
<link rel="stylesheet" href="${up}estilo.css">
$head
</head>
<body>
$body
</body>
</html>
''';
}

String _cta(String title, String text) =>
    '''
<aside class="cta">
<p class="cta-t">${_esc(title)}</p>
<p>${_esc(text)}</p>
<a class="boton" href="$playUrl">Ruta Libre en Google Play</a>
<p class="cta-n">Gratis, sin publicidad y sin cuenta. Para Android.</p>
</aside>''';

String _footer(WebData data, String? networkCode) {
  final sources = switch (networkCode) {
    'corrientes-capital' =>
      'Recorridos y paradas: datos abiertos de la Municipalidad de la Ciudad de Corrientes.',
    null =>
      'Recorridos y paradas: <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> (ODbL) y datos abiertos de la Municipalidad de la Ciudad de Corrientes.',
    _ =>
      'Recorridos y paradas: <a href="https://www.openstreetmap.org/copyright">© colaboradores de OpenStreetMap</a>, licencia ODbL.',
  };
  return '''
<footer>
<p>$sources Datos al ${_esc(data.updatedOn)}.</p>
<p>No mostramos horarios: no se publican en ninguna fuente abierta. Si en la calle ves algo distinto, confiá en lo que ves.</p>
<p><a href="https://instagram.com/rutalibre.app">@rutalibre.app</a></p>
</footer>''';
}

/// "Ida: Laguna Brava ↔ Centro" → "Laguna Brava ↔ Centro": el sentido ya
/// se muestra aparte.
String _variantLabel(String name) => name.replaceFirst(
  RegExp(r'^(Ida|Vuelta)\s*:\s*', caseSensitive: false),
  '',
);

/// Las flechas, como texto y no como emoji (ver `display_text.dart` en la
/// app: Android las dibuja como emoji celeste también en el navegador).
String _text(String value) =>
    value.replaceAllMapped(RegExp('[↔→←]'), (m) => '${m[0]}\u{FE0E}');

String _esc(String value) =>
    const HtmlEscape(HtmlEscapeMode.attribute).convert(value);

/// Un color de la base va adentro de un atributo `style`: solo se acepta
/// `#rrggbb`, cualquier otra cosa cae al azul de la marca.
String _safeColor(String hex) =>
    RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(hex) ? hex : '#1E88E5';

double _round(double v) => (v * 100000).roundToDouble() / 100000;

const _css = '''
:root{--negro:#161616;--azul:#1E88E5;--gris:#6b6b6b;--borde:#e6e6e6}
*{box-sizing:border-box}
body{margin:0;font-family:Inter,system-ui,sans-serif;color:var(--negro);background:#fff;line-height:1.5}
a{color:var(--azul)}
.top{background:var(--negro);padding:12px 16px}
.marca{color:#fff;font-weight:800;letter-spacing:.12em;text-transform:uppercase;text-decoration:none;font-size:14px}
main{max-width:760px;margin:0 auto;padding:16px}
h1{font-size:30px;line-height:1.1;letter-spacing:-.02em;margin:8px 0;display:flex;align-items:center;gap:12px;flex-wrap:wrap}
h1 b{color:var(--azul)}
h2{font-size:20px;margin:32px 0 8px}
.red{margin:16px 0 0;color:var(--gris);font-weight:600;text-transform:uppercase;letter-spacing:.1em;font-size:12px}
.sub{color:#444;font-size:17px;margin:0 0 16px}
.badge{display:inline-flex;min-width:44px;height:36px;padding:0 10px;border-radius:8px;background:var(--c);color:#fff;font-weight:800;align-items:center;justify-content:center;font-size:16px}
#mapa{height:340px;border-radius:12px;border:1px solid var(--borde);margin:8px 0 16px}
.cta{background:var(--negro);color:#fff;border-radius:14px;padding:18px;margin:16px 0}
.cta p{margin:0 0 8px}
.cta-t{font-size:20px;font-weight:800}
.cta-n{color:#bbb;font-size:13px;margin:10px 0 0!important}
.boton{display:inline-block;background:var(--azul);color:#fff;font-weight:600;padding:10px 18px;border-radius:999px;text-decoration:none;margin-top:6px}
.nota{color:var(--gris);font-size:14px;margin:0 0 8px}
.recorrido{border:1px solid var(--borde);border-radius:10px;margin:8px 0;padding:0 12px}
.recorrido summary{cursor:pointer;padding:12px 0;font-weight:600}
.sentido{color:var(--azul);margin-right:4px}
.cuenta{color:var(--gris);font-weight:400;font-size:14px;margin-left:6px}
.recorrido ol{margin:0 0 12px;padding-left:28px}
.recorrido li{padding:2px 0}
.lineas{list-style:none;padding:0;margin:0;display:grid;gap:8px}
.lineas a{display:flex;gap:12px;align-items:center;text-decoration:none;color:var(--negro);border:1px solid var(--borde);border-radius:10px;padding:8px}
.chips{display:flex;flex-wrap:wrap;gap:8px}
.chip{display:inline-block;min-width:44px;text-align:center;padding:6px 10px;border-radius:8px;background:var(--c);color:#fff;font-weight:800;text-decoration:none}
footer{max-width:760px;margin:32px auto 0;padding:16px;color:var(--gris);font-size:13px;border-top:1px solid var(--borde)}
''';

// ---------------------------------------------------------------------------
// Ida y vuelta a JSON, para guardar lo bajado y regenerar sin red
// ---------------------------------------------------------------------------

Map<String, dynamic> webDataToJson(WebData data) => {
  'updated_on': data.updatedOn,
  'lines': [
    for (final l in data.lines)
      {
        'network_code': l.networkCode,
        'network_name': l.networkName,
        'code': l.code,
        'name': l.name,
        'color_hex': l.colorHex,
        'variants': [
          for (final v in l.variants)
            {
              'name': v.name,
              'branch': v.branch,
              'direction': v.direction,
              'stops': [
                for (final s in v.stops)
                  {'name': s.name, 'lat': s.lat, 'lng': s.lng},
              ],
              'geometry': [
                for (final (lat, lng) in v.geometry) [lat, lng],
              ],
            },
        ],
      },
  ],
};

WebData webDataFromJson(Map<String, dynamic> json) => WebData(
  updatedOn: json['updated_on'] as String,
  lines: [
    for (final l in (json['lines'] as List).cast<Map<String, dynamic>>())
      WebLine(
        networkCode: l['network_code'] as String,
        networkName: l['network_name'] as String,
        code: l['code'] as String,
        name: l['name'] as String,
        colorHex: l['color_hex'] as String,
        variants: [
          for (final v in (l['variants'] as List).cast<Map<String, dynamic>>())
            WebVariant(
              name: v['name'] as String,
              branch: v['branch'] as String?,
              direction: (v['direction'] as num).toInt(),
              stops: [
                for (final s
                    in (v['stops'] as List).cast<Map<String, dynamic>>())
                  WebStop(
                    name: s['name'] as String,
                    lat: (s['lat'] as num).toDouble(),
                    lng: (s['lng'] as num).toDouble(),
                  ),
              ],
              geometry: [
                for (final p in (v['geometry'] as List).cast<List<dynamic>>())
                  ((p[0] as num).toDouble(), (p[1] as num).toDouble()),
              ],
            ),
        ],
      ),
  ],
);
