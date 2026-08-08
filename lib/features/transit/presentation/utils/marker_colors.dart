/// Colores de los marcadores del mapa.
///
/// NO salen del `ColorScheme` a propósito: los tiles de OpenStreetMap son
/// siempre claros, también cuando la app está en modo oscuro, así que un
/// color del tema oscuro (pastel, pensado para fondo negro) queda ilegible
/// justo cuando más se lo necesita.
///
/// **Ninguno puede estar en `linePalette` (`tools/src/line_palette.dart`).**
/// Los colores de línea se asignan por hash del código, así que si un color
/// de marcador está en esa paleta, tarde o temprano una línea cae en él y
/// sus paradas se vuelven indistinguibles de las de "cerca mío". Pasó: el
/// primer intento fue `#00695C`, que es el "verde azulado" de la paleta.
/// `marker_colors_test.dart` lo verifica.
library;

import 'dart:ui';

/// Todas las paradas de la red: la capa de fondo, la que está siempre.
///
/// Gris azulado y apagado A PROPÓSITO. Es contexto, no respuesta: cualquier
/// cosa más fuerte le pelearía el ojo al recorrido elegido y a "cerca mío",
/// que sí contestan una pregunta que el usuario hizo.
const allStopsMarkerColor = Color(0xFF78909C);

/// Paradas del modo "cerca mío".
///
/// Negro de marca: sobre el tema claro es la tinta natural del mapa y no le
/// pelea el color a las líneas, que son la información de verdad. El carmín
/// que se usaba antes leía cada parada como una alerta, cuando una parada
/// cercana es apenas una opción.
const nearbyMarkerColor = Color(0xFF212121);

/// "Acá estás vos". Azul, que es lo que la gente ya espera de un punto de
/// ubicación, y así no se confunde con los marcadores de parada.
const userMarkerColor = Color(0xFF1565C0);

/// El destino elegido en "¿cómo llego?".
///
/// Único color VIVO de los marcadores, y a propósito: es lo único del mapa
/// que puso el usuario a mano, así que tiene que encontrarse de un vistazo
/// entre el trazado y las paradas.
const destinationMarkerColor = Color(0xFFD81B60);
