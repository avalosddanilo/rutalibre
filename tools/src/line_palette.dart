/// Colores de las líneas.
///
/// OSM casi no trae `colour` (2 de 85 relations en el Gran Resistencia), así
/// que el importer asigna uno. Requisitos: DETERMINISTA (la misma línea sale
/// del mismo color en cada reimportación, si no el mapa "cambia de colores"
/// entre updates) y legible sobre los tiles claros de OSM.
library;

/// Paleta elegida a mano: tonos saturados y oscuros que contrastan con el
/// gris/beige del mapa, y suficientemente distintos entre sí como para
/// distinguir dos recorridos que comparten avenida.
const linePalette = <String>[
  '#D32F2F', // rojo
  '#1976D2', // azul
  '#388E3C', // verde
  '#F57C00', // naranja
  '#7B1FA2', // violeta
  '#00838F', // petróleo
  '#C2185B', // fucsia
  '#5D4037', // marrón
  '#455A64', // gris azulado
  '#AFB42B', // oliva
  '#0288D1', // celeste oscuro
  '#E64A19', // teja
  '#512DA8', // índigo
  '#00695C', // verde azulado
  '#AD1457', // bordó
  '#F9A825', // ámbar oscuro
];

/// Color estable para un código de línea.
///
/// Se usa un hash del código (y no el índice en la lista de líneas) para que
/// agregar la línea 7 mañana no le cambie el color a la 8.
String colorForLine(String lineCode) {
  var hash = 0;
  for (final unit in lineCode.codeUnits) {
    hash = (hash * 31 + unit) & 0x7FFFFFFF;
  }
  return linePalette[hash % linePalette.length];
}
