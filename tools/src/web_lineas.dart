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

/// Archivos fijos del sitio: ruta publicada → archivo del repo. Los copia
/// `tools/web_lineas.dart`; acá solo se nombran, para que las páginas y la
/// copia no se desencuentren.
const webAssets = {
  'img/logo-192.png': 'tools/web_assets/logo-192.png',
  'img/logo-64.png': 'tools/web_assets/logo-64.png',
  'img/captura-viaje.webp': 'tools/web_assets/captura-viaje.webp',
  'img/google-play.png': 'tools/web_assets/google-play.png',
  'img/compartir.jpg': 'tools/web_assets/compartir.jpg',
};

/// La imagen para compartir de la portada y la de cada línea (1200×630). Se
/// sacan de [renderOgTemplates] con un navegador sin pantalla; si no hay
/// navegador, cada página usa `img/compartir.jpg`.
const ogIndexPath = 'og/inicio.png';
String ogLinePath(WebLine line) =>
    'og/${networkSlug(line.networkCode)}-linea-${slug(line.code)}.png';

/// El sitio entero: ruta relativa → contenido.
///
/// [baseUrl] termina en `/` y es donde va a vivir el sitio (para el sitemap
/// y las URL canónicas, que Google necesita absolutas). [ogImages] son las
/// imágenes para compartir que SÍ se generaron: una página cuya imagen no
/// está ahí usa la genérica, nunca un link roto.
Map<String, String> renderSite(
  WebData data, {
  required String baseUrl,
  Set<String> ogImages = const {},
}) {
  String og(String path) =>
      '$baseUrl${ogImages.contains(path) ? path : 'img/compartir.jpg'}';
  final files = <String, String>{
    'index.html': _index(data, baseUrl, og(ogIndexPath)),
    'sitemap.xml': _sitemap(data, baseUrl),
    'robots.txt': 'User-agent: *\nAllow: /\nSitemap: ${baseUrl}sitemap.xml\n',
    'estilo.css': _css,
  };
  for (final line in data.lines) {
    files[line.path] = _linePage(line, data, baseUrl, og(ogLinePath(line)));
  }
  return files;
}

/// Las plantillas de las imágenes para compartir: ruta del PNG → HTML de
/// 1200×630. Usan `inter.ttf` y `logo.png` de la misma carpeta, así la
/// imagen sale igual con o sin red.
Map<String, String> renderOgTemplates(WebData data) => {
  ogIndexPath: _ogPage(
    badge: null,
    title: 'Qué colectivo tomar en <b>Resistencia y Corrientes</b>',
    sub: 'Recorridos, paradas y una app gratis que te dice cuál tomar.',
  ),
  for (final line in data.lines)
    ogLinePath(line): _ogPage(
      badge: (line.code, _safeColor(line.colorHex)),
      title:
          'Línea ${_esc(line.code)} de '
          '${_esc(networkPlace(line.networkCode, line.networkName))}',
      sub: '${_esc(_text(line.name))}. Recorrido y paradas.',
    ),
};

// ---------------------------------------------------------------------------
// Páginas
// ---------------------------------------------------------------------------

String _linePage(WebLine line, WebData data, String baseUrl, String ogImage) {
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

  // Un botón y un panel por recorrido. Sin JavaScript se ven todos los
  // paneles, uno abajo del otro; con JavaScript, el elegido.
  final tabs = StringBuffer();
  final panels = StringBuffer();
  for (final (i, variant) in line.variants.indexed) {
    final sense = variant.direction == 1 ? 'Vuelta' : 'Ida';
    // Hay recorridos que en OSM se llaman solo "Ida" o "Vuelta": sin esto
    // la pestaña decía "Ida Ida".
    final rawLabel = _variantLabel(variant.name);
    final label =
        RegExp(
          r'^\s*(ida|vuelta)?\s*$',
          caseSensitive: false,
        ).hasMatch(rawLabel)
        ? ''
        : rawLabel;
    tabs.writeln(
      '<button class="tab" type="button" data-i="$i" aria-pressed="${i == 0}">'
      '<span class="sentido">$sense</span> ${_esc(_text(_tabLabel(label)))}'
      '</button>',
    );
    panels
      ..writeln('<section class="rec" data-i="$i">')
      ..writeln(
        '<h3><span class="sentido">$sense</span> ${_esc(_text(label))} '
        '<span class="cuenta">${variant.stops.length} paradas</span></h3>',
      )
      ..writeln('<ol class="paradas">');
    for (final stop in variant.stops) {
      panels.writeln('<li>${_esc(stop.name)}</li>');
    }
    panels
      ..writeln('</ol>')
      ..writeln('</section>');
  }

  // El trazado y las paradas para el mapa: 5 decimales (~1 m) alcanzan y
  // achican la página.
  final shapes = jsonEncode([
    for (final v in line.variants)
      {
        'l': [
          for (final (lat, lng) in v.geometry) [_round(lat), _round(lng)],
        ],
        'p': [
          for (final s in v.stops) [_round(s.lat), _round(s.lng), s.name],
        ],
      },
  ]).replaceAll('<', r'\u003c');

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
    ogImage: ogImage,
    depth: 1,
    head:
        '<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css">',
    body:
        '''
${_header(1)}
<section class="hero hero-linea" style="--c:$color">
<div class="ancho">
<p class="migas"><a href="../index.html">Líneas</a> · ${_esc(place)}</p>
<h1><span class="badge grande">${_esc(line.code)}</span> Línea ${_esc(line.code)}</h1>
<p class="sub">${_esc(_text(line.name))}</p>
<p class="datos">$stopCount paradas · ${line.variants.length} ${line.variants.length == 1 ? 'recorrido' : 'recorridos'}</p>
</div>
</section>
<main class="ancho">
<div id="mapa" aria-label="Mapa del recorrido"></div>
<h2>Recorridos y paradas</h2>
${line.variants.length > 1 ? '<div class="tabs" role="group" aria-label="Recorridos">\n$tabs</div>' : ''}
<div class="recs" style="--c:$color">
$panels</div>
${_cta(1, '¿Qué colectivo te lleva?', 'Ruta Libre te dice qué línea tomar, en qué esquina subir y en cuál bajar. Y te avisa antes de tu parada.')}
<h2>Otras líneas de ${_esc(place)}</h2>
<p class="chips">$others</p>
</main>
${_footer(data, line.networkCode)}
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<script>
(function () {
  var data = $shapes, color = '$color', onShow = function () {};
  // Las pestañas y las paradas no dependen del mapa: si Leaflet no carga
  // (CDN caído, red mala), la página se sigue leyendo entera.
  function show(i) {
    document.querySelectorAll('.tab').forEach(function (b) { b.setAttribute('aria-pressed', String(+b.dataset.i === i)); });
    document.querySelectorAll('.rec').forEach(function (r) { r.classList.toggle('activo', +r.dataset.i === i); });
    onShow(i);
  }
  document.querySelectorAll('.tab').forEach(function (b) {
    b.addEventListener('click', function () { show(+b.dataset.i); });
  });
  show(0);
  document.documentElement.classList.add('js');
  if (!window.L) return;
  var map = L.map('mapa', { scrollWheelZoom: false });
  map.attributionControl.setPrefix('<a href="https://leafletjs.com">Leaflet</a>');
  L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: 18,
    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
  }).addTo(map);
  var layers = data.map(function (v) {
    var g = L.layerGroup().addTo(map);
    if (v.l.length > 1) g.line = L.polyline(v.l, { color: color, weight: 4, opacity: 0.25 }).addTo(g);
    g.stops = v.p.map(function (s) {
      return L.circleMarker([s[0], s[1]], { radius: 5, color: '#fff', weight: 2, fillColor: color, fillOpacity: 1 })
        .bindTooltip(s[2]);
    });
    return g;
  });
  var all = [];
  data.forEach(function (v) { all = all.concat(v.l.length ? v.l : v.p.map(function (s) { return [s[0], s[1]]; })); });
  function fit() {
    map.invalidateSize();
    if (all.length) map.fitBounds(all, { padding: [16, 16] });
    else map.setView([-27.46, -58.9], 11);
  }
  fit();
  // El CSS de Leaflet puede llegar después: con el tamaño ya bien, se
  // vuelve a encuadrar.
  window.addEventListener('load', fit);
  onShow = function (i) {
    layers.forEach(function (g, j) {
      if (g.line) g.line.setStyle({ opacity: j === i ? 0.95 : 0.2, weight: j === i ? 5 : 3 });
      g.stops.forEach(function (m) { if (j === i) m.addTo(g); else g.removeLayer(m); });
      if (j === i && g.line) g.line.bringToFront();
    });
  };
  onShow(+(document.querySelector('.tab[aria-pressed="true"]') || { dataset: { i: 0 } }).dataset.i);
})();
</script>''',
  );
}

String _index(WebData data, String baseUrl, String ogImage) {
  final byNetwork = <String, List<WebLine>>{};
  for (final line in data.lines) {
    byNetwork.putIfAbsent(line.networkCode, () => []).add(line);
  }

  final tabs = StringBuffer(
    '<button class="tab" type="button" data-red="" aria-pressed="true">Todas</button>\n',
  );
  final sections = StringBuffer();
  for (final MapEntry(key: code, value: lines) in byNetwork.entries) {
    final place = networkPlace(code, lines.first.networkName);
    final red = networkSlug(code);
    tabs.writeln(
      '<button class="tab" type="button" data-red="$red" aria-pressed="false">${_esc(place)}</button>',
    );
    sections
      ..writeln('<section class="red-lineas" data-red="$red">')
      ..writeln('<h3>${_esc(place)}</h3>')
      ..writeln('<ul class="lineas">');
    for (final line in lines) {
      // Lo que se busca: el número y el nombre, sin tildes ni mayúsculas.
      final search = _plain('${line.code} ${line.name} $place');
      sections.writeln(
        '<li data-q="${_esc(search)}"><a href="${line.path}">'
        '<span class="badge" style="--c:${_safeColor(line.colorHex)}">${_esc(line.code)}</span>'
        '<span>${_esc(_text(line.name))}</span></a></li>',
      );
    }
    sections
      ..writeln('</ul>')
      ..writeln('</section>');
  }

  final faq = [
    (
      '¿Ruta Libre es gratis?',
      'Sí. Gratis, sin publicidad y sin cuenta: la bajás y la usás.',
    ),
    (
      '¿Me avisa cuándo bajarme?',
      'Sí. Activás "Avisame para bajar" y, antes de tu parada, suena fuerte '
          'aunque el teléfono esté en silencio o con la pantalla apagada.',
    ),
    (
      '¿Tiene los horarios de los colectivos?',
      'No. Los horarios de las líneas urbanas no se publican en ninguna fuente '
          'abierta, y preferimos no inventarlos: un horario inventado te manda a '
          'esperar un colectivo que no viene.',
    ),
    (
      '¿Funciona sin señal?',
      'Los recorridos, las paradas y el buscador quedan guardados en el '
          'teléfono y andan sin señal.',
    ),
    ('¿Hay para iPhone?', 'Por ahora, solo para Android.'),
    (
      '¿De dónde salen los recorridos?',
      'De OpenStreetMap, el mapa que hace la comunidad, y de los datos '
          'abiertos de la Municipalidad de la Ciudad de Corrientes.',
    ),
  ];
  final faqHtml = faq
      .map(
        (q) =>
            '<details class="faq"><summary>${_esc(q.$1)}</summary><p>${_esc(q.$2)}</p></details>',
      )
      .join('\n');
  final faqLd = jsonEncode({
    '@context': 'https://schema.org',
    '@type': 'FAQPage',
    'mainEntity': [
      for (final (q, a) in faq)
        {
          '@type': 'Question',
          'name': q,
          'acceptedAnswer': {'@type': 'Answer', 'text': a},
        },
    ],
  }).replaceAll('<', r'\u003c');

  final features = [
    (
      _iconRoute,
      'Cómo llego',
      'Decís a dónde vas y te dice qué colectivo tomar, en qué esquina subir y en cuál bajar. Con transbordo si hace falta, también entre Resistencia y Corrientes.',
    ),
    (
      _iconAlarm,
      'Alarma para bajar',
      'Te avisa antes de tu parada, aunque tengas el celu en el bolsillo con la pantalla apagada.',
    ),
    (
      _iconOffline,
      'Anda sin señal',
      'Los recorridos, las paradas y el buscador quedan en el teléfono.',
    ),
    (
      _iconWarning,
      'Avisos de paros y desvíos',
      'Si hay paro o un desvío, lo ves arriba del mapa apenas abrís la app.',
    ),
  ];
  final featuresHtml = features
      .map(
        (f) =>
            '<li><span class="ico">${f.$1}</span><h3>${_esc(f.$2)}</h3><p>${_esc(f.$3)}</p></li>',
      )
      .join('\n');

  return _page(
    title: 'Colectivos de Resistencia y Corrientes: recorridos y paradas',
    description:
        'Los recorridos y las paradas de las ${data.lines.length} líneas de '
        'colectivo del Gran Resistencia y Corrientes capital. Y la app gratis '
        'que te dice qué colectivo tomar.',
    canonical: baseUrl,
    ogImage: ogImage,
    depth: 0,
    head: '<script type="application/ld+json">$faqLd</script>',
    body:
        '''
${_header(0)}
<section class="hero">
<div class="ancho hero-grid">
<div>
<h1>Qué colectivo tomar en <b>Resistencia y Corrientes</b></h1>
<p class="sub">Le decís a dónde vas y te dice qué línea tomar, dónde subir y dónde bajar. Gratis, sin publicidad y sin cuenta.</p>
<a class="play" href="$playUrl"><img src="img/google-play.png" alt="Disponible en Google Play" width="194" height="75"></a>
</div>
<div class="tel"><img src="img/captura-viaje.webp" alt="Ruta Libre mostrando un viaje en la línea 2 sobre el mapa" width="540" height="1200"></div>
</div>
</section>
<main class="ancho">
<ul class="features">
$featuresHtml
</ul>
<h2 id="lineas">Las ${data.lines.length} líneas</h2>
<div class="buscar"><span class="ico">$_iconSearch</span><input id="q" type="search" placeholder="Buscá por número, barrio o lugar" aria-label="Buscar línea" autocomplete="off"></div>
<div class="tabs" role="group" aria-label="Ciudad">
$tabs</div>
<div id="lineas-lista">
$sections</div>
<p id="nada" class="nota" hidden>Ninguna línea coincide. Probá con el número o con un barrio.</p>
${_cta(0, 'Bajala gratis', 'Le decís a dónde vas y te dice qué línea tomar, dónde subir y dónde bajar. Con alarma para no pasarte de parada.')}
<h2>Preguntas frecuentes</h2>
$faqHtml
</main>
${_footer(data, null)}
<script>
(function () {
  var q = document.getElementById('q'), red = '';
  var items = document.querySelectorAll('.lineas li');
  var secs = document.querySelectorAll('.red-lineas');
  function norm(s) { return s.toLowerCase().normalize('NFD').replace(/[\\u0300-\\u036f]/g, ''); }
  function apply() {
    var t = norm(q.value.trim()), visibles = 0;
    secs.forEach(function (sec) {
      var any = 0;
      sec.querySelectorAll('li').forEach(function (li) {
        var ok = (!red || sec.dataset.red === red) && (!t || li.dataset.q.indexOf(t) >= 0);
        li.hidden = !ok; if (ok) any++;
      });
      sec.hidden = !any; visibles += any;
    });
    document.getElementById('nada').hidden = visibles > 0;
  }
  q.addEventListener('input', apply);
  document.querySelectorAll('.tabs .tab').forEach(function (b) {
    b.addEventListener('click', function () {
      red = b.dataset.red;
      document.querySelectorAll('.tabs .tab').forEach(function (o) { o.setAttribute('aria-pressed', String(o === b)); });
      apply();
    });
  });
})();
</script>''',
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
  required String ogImage,
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
<meta property="og:url" content="${_esc(canonical)}">
<meta property="og:image" content="${_esc(ogImage)}">
<meta property="og:image:width" content="1200">
<meta property="og:image:height" content="630">
<meta property="og:locale" content="es_AR">
<meta property="og:site_name" content="Ruta Libre">
<meta name="twitter:card" content="summary_large_image">
<meta name="theme-color" content="#161616">
<link rel="icon" type="image/png" href="${up}img/logo-64.png">
<link rel="apple-touch-icon" href="${up}img/logo-192.png">
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

String _header(int depth) {
  final up = '../' * depth;
  return '''
<header class="top"><div class="ancho top-in">
<a href="${up}index.html" class="marca"><img src="${up}img/logo-64.png" alt="" width="32" height="32"> Ruta Libre</a>
<a class="mini" href="$playUrl">Bajala gratis</a>
</div></header>''';
}

String _cta(int depth, String title, String text) {
  final up = '../' * depth;
  return '''
<aside class="cta">
<img class="cta-logo" src="${up}img/logo-192.png" alt="" width="64" height="64">
<div>
<p class="cta-t">${_esc(title)}</p>
<p>${_esc(text)}</p>
<a class="play" href="$playUrl"><img src="${up}img/google-play.png" alt="Disponible en Google Play" width="168" height="65"></a>
<p class="cta-n">Gratis, sin publicidad y sin cuenta. Para Android.</p>
</div>
</aside>''';
}

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
<footer><div class="ancho">
<p>$sources Datos al ${_esc(data.updatedOn)}.</p>
<p>No mostramos horarios: no se publican en ninguna fuente abierta. Si en la calle ves algo distinto, confiá en lo que ves.</p>
<p><a href="https://instagram.com/rutalibre.app">@rutalibre.app</a> · © 2026 Danilo Avalos · <a href="https://github.com/avalosddanilo/rutalibre">código abierto</a></p>
</div></footer>''';
}

String _ogPage({
  required (String, String)? badge,
  required String title,
  required String sub,
}) =>
    '''
<!doctype html><html><head><meta charset="utf-8"><style>
@font-face{font-family:Inter;src:url(inter.ttf);font-weight:100 900}
*{margin:0;box-sizing:border-box}
html,body{width:1200px;height:630px;overflow:hidden}
body{background:#161616;color:#fff;font-family:Inter,sans-serif;padding:72px 80px;display:flex;flex-direction:column;justify-content:space-between}
.b{display:inline-flex;align-items:center;justify-content:center;min-width:150px;height:120px;padding:0 28px;border-radius:24px;background:var(--c);font-weight:800;font-size:76px;letter-spacing:-2px;margin-bottom:32px}
h1{font-size:${badge == null ? 76 : 68}px;line-height:1.05;letter-spacing:-2.5px;font-weight:800;max-width:1000px}
h1 b{color:#4FA3F7}
p{color:#A8A8A8;font-size:34px;margin-top:20px;max-width:1000px;font-weight:600;overflow:hidden;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical}
.pie{display:flex;align-items:center;gap:18px;font-size:32px;font-weight:800}
.pie img{width:64px;height:64px;border-radius:16px}
.pie span{margin-left:auto;color:#4FA3F7;font-weight:600;font-size:28px}
</style></head><body>
<div>${badge == null ? '' : '<div class="b" style="--c:${badge.$2}">${_esc(badge.$1)}</div>'}
<h1>$title</h1>
<p>$sub</p></div>
<div class="pie"><img src="logo.png" alt=""> Ruta Libre <span>rutalibreapp.com.ar</span></div>
</body></html>''';

/// "Ida: Laguna Brava ↔ Centro" → "Laguna Brava ↔ Centro": el sentido ya
/// se muestra aparte.
String _variantLabel(String name) => name.replaceFirst(
  RegExp(r'^(Ida|Vuelta)\s*:\s*', caseSensitive: false),
  '',
);

/// Lo corto para un botón: "Carpincho Macho → Villa Prosperidad (ramal A)"
/// → "→ Villa Prosperidad (ramal A)". Hacia dónde va es lo que distingue.
String _tabLabel(String label) {
  final i = label.indexOf('→');
  return i < 0 ? label : label.substring(i).trim();
}

/// Las flechas, como texto y no como emoji (ver `display_text.dart` en la
/// app: Android las dibuja como emoji celeste también en el navegador).
String _text(String value) =>
    value.replaceAllMapped(RegExp('[↔→←]'), (m) => '${m[0]}\u{FE0E}');

/// Para buscar: minúsculas y sin tildes, como lo escribe alguien apurado.
String _plain(String value) {
  const accents = {'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u', 'ü': 'u'};
  return value
      .toLowerCase()
      .split('')
      .map((c) => accents[c] ?? c)
      .join()
      .replaceAll(RegExp('[↔→←]'), ' ');
}

String _esc(String value) =>
    const HtmlEscape(HtmlEscapeMode.attribute).convert(value);

/// Un color de la base va adentro de un atributo `style`: solo se acepta
/// `#rrggbb`, cualquier otra cosa cae al azul de la marca.
String _safeColor(String hex) =>
    RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(hex) ? hex : '#1E88E5';

double _round(double v) => (v * 100000).roundToDouble() / 100000;

// Íconos de Material Icons (Apache 2.0), en línea para no pedir nada más.
String _svg(String d) =>
    '<svg viewBox="0 0 24 24" width="24" height="24" aria-hidden="true"><path fill="currentColor" d="$d"/></svg>';
final _iconRoute = _svg(
  'M21.71 11.29l-9-9a.996.996 0 00-1.41 0l-9 9a.996.996 0 000 1.41l9 9c.39.39 1.02.39 1.41 0l9-9a.996.996 0 000-1.41zM14 14.5V12h-4v3H8v-4c0-.55.45-1 1-1h5V7.5l3.5 3.5-3.5 3.5z',
);
final _iconAlarm = _svg(
  'M22 5.72l-4.6-3.86-1.29 1.53 4.6 3.86L22 5.72zM7.88 3.39L6.6 1.86 2 5.71l1.29 1.53 4.59-3.85zM12.5 8H11v6l4.75 2.85.75-1.23-4-2.37V8zM12 4c-4.97 0-9 4.03-9 9s4.02 9 9 9c4.97 0 9-4.03 9-9s-4.03-9-9-9zm0 16c-3.87 0-7-3.13-7-7s3.13-7 7-7 7 3.13 7 7-3.13 7-7 7z',
);
final _iconOffline = _svg(
  'M19.35 10.04C18.67 6.59 15.64 4 12 4c-1.48 0-2.85.43-4.01 1.17l1.46 1.46C10.21 6.23 11.08 6 12 6c3.04 0 5.5 2.46 5.5 5.5v.5H19c1.66 0 3 1.34 3 3 0 1.13-.64 2.11-1.56 2.62l1.45 1.45C23.16 18.16 24 16.68 24 15c0-2.64-2.05-4.78-4.65-4.96zM3 5.27l2.75 2.74C2.56 8.15 0 10.77 0 14c0 3.31 2.69 6 6 6h11.73l2 2L21 20.73 4.27 4 3 5.27zM7.73 10l8 8H6c-2.21 0-4-1.79-4-4s1.79-4 4-4h1.73z',
);
final _iconWarning = _svg('M1 21h22L12 2 1 21zm12-3h-2v-2h2v2zm0-4h-2v-4h2v4z');
final _iconSearch = _svg(
  'M15.5 14h-.79l-.28-.27A6.471 6.471 0 0016 9.5 6.5 6.5 0 109.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z',
);

const _css = '''
:root{--negro:#161616;--azul:#1E88E5;--azul-claro:#4FA3F7;--gris:#6b6b6b;--borde:#e6e6e6;--fondo:#fff;--texto:#161616;--tarjeta:#f6f7f9}
@media (prefers-color-scheme:dark){:root{--fondo:#0f0f0f;--texto:#f2f2f2;--gris:#a8a8a8;--borde:#2a2a2a;--tarjeta:#1b1b1b;--azul:#4FA3F7}}
*{box-sizing:border-box}
html{-webkit-text-size-adjust:100%}
body{margin:0;font-family:Inter,system-ui,sans-serif;color:var(--texto);background:var(--fondo);line-height:1.5}
a{color:var(--azul)}
img{max-width:100%;height:auto}
.ancho{max-width:960px;margin:0 auto;padding:0 16px}
.top{background:var(--negro);position:sticky;top:0;z-index:1000}
.top-in{display:flex;align-items:center;justify-content:space-between;height:56px}
.marca{display:flex;align-items:center;gap:10px;color:#fff;font-weight:800;text-decoration:none;font-size:18px;letter-spacing:-.02em}
.marca img{border-radius:8px}
.mini{color:#fff;background:var(--azul);padding:7px 14px;border-radius:999px;font-weight:600;font-size:14px;text-decoration:none}
.hero{background:var(--negro);color:#fff;padding:32px 0 40px}
.hero-grid{display:grid;gap:24px;align-items:center}
@media (min-width:760px){.hero-grid{grid-template-columns:1.2fr .8fr}}
.hero h1{font-size:clamp(34px,8vw,56px);line-height:1.05;letter-spacing:-.035em;margin:0 0 12px;font-weight:800}
.hero h1 b{color:var(--azul-claro)}
.hero .sub{color:#d0d0d0;font-size:18px;margin:0 0 16px;max-width:560px}
.play img{display:block}
.tel{justify-self:center;width:min(260px,70vw);aspect-ratio:9/20;border-radius:36px;border:10px solid #2b2b2b;overflow:hidden;background:#000;box-shadow:0 24px 60px rgba(0,0,0,.5)}
.tel img{width:100%;height:100%;object-fit:cover;display:block}
main{padding-top:8px;padding-bottom:16px}
h2{font-size:26px;letter-spacing:-.02em;margin:40px 0 12px}
h3{margin:0}
.features{list-style:none;padding:0;margin:24px 0 0;display:grid;gap:12px}
@media (min-width:760px){.features{grid-template-columns:1fr 1fr}}
.features li{background:var(--tarjeta);border-radius:16px;padding:18px}
.features h3{font-size:18px;margin:8px 0 4px}
.features p{margin:0;color:var(--gris)}
.ico{display:inline-flex;color:var(--azul)}
.features .ico{background:rgba(30,136,229,.12);border-radius:12px;padding:8px}
.buscar{display:flex;align-items:center;gap:8px;border:2px solid var(--borde);border-radius:14px;padding:0 12px;background:var(--fondo)}
.buscar:focus-within{border-color:var(--azul)}
.buscar input{flex:1;border:0;outline:0;background:transparent;color:var(--texto);font:inherit;font-size:17px;padding:14px 0}
.tabs{display:flex;gap:8px;overflow-x:auto;padding:12px 0 4px;scrollbar-width:none}
.tab{flex:none;border:1px solid var(--borde);background:var(--fondo);color:var(--texto);border-radius:999px;padding:8px 14px;font:inherit;font-weight:600;font-size:14px;cursor:pointer}
.tab[aria-pressed="true"]{background:var(--azul);border-color:var(--azul);color:#fff}
.tab .sentido{opacity:.75}
.tab[aria-pressed="true"] .sentido{color:#fff;opacity:.85}
.red-lineas h3{font-size:14px;text-transform:uppercase;letter-spacing:.08em;color:var(--gris);margin:20px 0 8px}
.lineas{list-style:none;padding:0;margin:0;display:grid;gap:8px}
@media (min-width:760px){.lineas{grid-template-columns:1fr 1fr}}
.lineas a{display:flex;gap:12px;align-items:center;text-decoration:none;color:var(--texto);background:var(--tarjeta);border-radius:12px;padding:10px;height:100%}
.lineas a:hover{outline:2px solid var(--azul)}
.badge{display:inline-flex;flex:none;min-width:48px;height:40px;padding:0 10px;border-radius:10px;background:var(--c);color:#fff;font-weight:800;align-items:center;justify-content:center;font-size:17px}
.nota{color:var(--gris);font-size:14px}
.cta{display:flex;gap:16px;align-items:flex-start;background:var(--negro);color:#fff;border-radius:20px;padding:22px;margin:40px 0 8px}
.cta-logo{border-radius:16px;flex:none}
.cta p{margin:0 0 8px}
.cta-t{font-size:22px;font-weight:800;letter-spacing:-.02em}
.cta-n{color:#bbb;font-size:13px;margin:8px 0 0!important}
.faq{border-bottom:1px solid var(--borde)}
.faq summary{cursor:pointer;padding:14px 0;font-weight:600;font-size:17px}
.faq p{margin:0 0 14px;color:var(--gris)}
.hero-linea{border-top:6px solid var(--c);padding:24px 0 28px}
.migas{margin:0 0 10px;font-size:14px;color:#bbb}
.migas a{color:#fff}
.hero-linea h1{display:flex;align-items:center;gap:14px;font-size:clamp(30px,7vw,46px);margin:0 0 6px}
.badge.grande{min-width:64px;height:56px;font-size:26px;border-radius:14px}
.hero-linea .sub{margin:0}
.datos{color:#bbb;font-size:14px;margin:8px 0 0}
#mapa{height:min(60vh,460px);border-radius:16px;margin:16px 0 0;background:var(--tarjeta);z-index:0;overflow:hidden;position:relative}
.rec h3{font-size:17px;margin:12px 0}
.sentido{color:var(--azul);font-weight:800}
.cuenta{color:var(--gris);font-weight:400;font-size:14px;margin-left:6px}
.js .rec{display:none}.js .rec.activo{display:block}
.paradas{list-style:none;margin:0;padding:0 0 0 26px;position:relative}
.paradas::before{content:"";position:absolute;left:8px;top:12px;bottom:12px;width:4px;border-radius:2px;background:var(--c)}
.paradas li{position:relative;padding:7px 0}
.paradas li::before{content:"";position:absolute;left:-23px;top:13px;width:10px;height:10px;border-radius:50%;background:var(--fondo);border:3px solid var(--c)}
.paradas li:first-child,.paradas li:last-child{font-weight:800}
.paradas li:first-child::before,.paradas li:last-child::before{background:var(--c)}
.chips{display:flex;flex-wrap:wrap;gap:8px}
.chip{display:inline-block;min-width:48px;text-align:center;padding:8px 10px;border-radius:10px;background:var(--c);color:#fff;font-weight:800;text-decoration:none}
footer{background:var(--negro);color:#a8a8a8;font-size:13px;margin-top:40px;padding:24px 0}
footer a{color:#fff}
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
