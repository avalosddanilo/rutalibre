/// Cómo le dice la gente a los lugares, cuando no es como se llaman.
///
/// **Por qué existe.** El buscador encuentra por el nombre de OpenStreetMap,
/// y la mayoría de las veces alcanza: "perrando", "domo", "cocomarola". Pero
/// algunos lugares se dicen por la sigla o por el apodo, y ahí el nombre
/// oficial no ayuda:
///
/// - "utn" no encontraba la facultad (se llama "Universidad Tecnológica
///   Nacional - …"); salía una calle Gutnisky.
/// - "unne" daba 21 resultados y los primeros eran bibliotecas.
/// - "terminal" ponía "La Terminal" (un consultorio) antes que las dos
///   terminales de ómnibus.
///
/// **Cómo se usa.** La clave es lo que se escribe, normalizado (minúsculas,
/// sin tildes, ver `normalizeForSearch`). El valor son nombres EXACTOS de
/// `assets/places.json`, en el orden en que tienen que salir. Hay un test que
/// verifica que cada nombre exista: si un día OSM renombra un lugar, el test
/// avisa en vez de que el apodo deje de andar callado.
///
/// **Qué NO va acá:** lo que ya se encuentra por el nombre, y lugares que no
/// están en los datos. Un apodo apunta a un lugar de OSM; no inventa uno.
const placeAliases = <String, List<String>>{
  'utn': [
    'Universidad Tecnológica Nacional - Facultad Regional Resistencia',
    'Anexo Universidad Tecnológica Nacional Facultad Regional Resistencia',
  ],
  'unne': [
    'Campus Resistencia Universidad Nacional del Nordeste',
    'Campus Deodoro Roca',
    'Campus Sargento Cabral',
    'Rectorado UNNE',
  ],
  'ucp': ['Universidad de la Cuenca del Plata'],
  // Sin esto salían primero las bibliotecas y, con "facu", la calle
  // Facundo. Las facultades de la UNNE en Resistencia (Humanidades,
  // Ingeniería, Arquitectura, Económicas) no están mapeadas una por una:
  // están dentro del campus. Humanidades y Sociales figuran en OSM en el
  // campus Sargento Cabral de Corrientes; hasta confirmarlo, no se empujan.
  'facultad': [
    'Universidad Tecnológica Nacional - Facultad Regional Resistencia',
    'Campus Resistencia Universidad Nacional del Nordeste',
    'Facultad de Medicina',
    'Facultad de Derecho y Ciencias Sociales y Políticas',
    'Facultad de Ciencias Exactas, Naturales y Agrimensura',
    'Facultad de Odontología',
    'Facultad de Ciencias Veterinarias',
    'Facultad de Ciencias Agrarias',
  ],
  'terminal': [
    'Estación Terminal de Omnibus',
    'Terminal de  Ómnibus Corrientes Capital',
  ],
  // El Hospital Llano figura en OSM con el nombre de la persona, sin la
  // palabra "hospital".
  'hospital llano': ['Ángela Iglesias De Llano'],
  'llano': ['Ángela Iglesias De Llano'],
};
