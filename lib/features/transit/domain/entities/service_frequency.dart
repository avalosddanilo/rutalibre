/// Cada cuánto TIENE QUE pasar un servicio, según la norma que rige el
/// permiso de la línea.
///
/// **Es lo único oficial que apareció sobre cuándo pasa el colectivo.** No hay
/// fuente pública de horarios en el Gran Resistencia (ver
/// `docs/propuesta-datos-abiertos.md`), pero el pliego que rige el permiso del
/// 904 sí es público y citable: fija una **banda de intervalos** por ramal.
/// Toda la cadena normativa, con las tres erratas que trae el original, está
/// en `docs/frecuencias-oficiales.md`.
///
/// **Una banda dice CADA CUÁNTO, nunca A QUÉ HORA**, y por eso esto no es —ni
/// puede volverse— la tabla `schedules`. Falta la hora de la primera salida,
/// la de la última, qué pasa fuera de la hora pico y qué horas son "pico",
/// que el pliego no define. Inventar salidas a partir de esto sería
/// exactamente lo que la regla del proyecto prohíbe: un horario inventado
/// manda a alguien a esperar un colectivo que no viene.
///
/// Y una distinción que la pantalla tiene que hacer explícita: esto es lo que
/// la empresa está **obligada** a cumplir, que no siempre es lo que hace.
class ServiceFrequency {
  const ServiceFrequency({
    required this.shortestMinutes,
    required this.longestMinutes,
    required this.scope,
    required this.source,
    required this.permitNote,
    required this.validFrom,
  });

  /// Extremo CORTO de la banda, en minutos: el que se cumple con el parque
  /// máximo de coches.
  final int shortestMinutes;

  /// Extremo LARGO, con el parque mínimo.
  ///
  /// El original escribe "no podrá ser superior a X ni inferior a Y" con
  /// superior/inferior invertidos respecto de cómo se leen —un servicio cada
  /// 50 minutos es un intervalo MENOR que uno cada 100— y se entiende recién
  /// con el final del renglón: "con parque máximo y mínimo respectivamente".
  /// Acá los campos se llaman por lo que son para que nadie lo vuelva a
  /// desenredar.
  final int longestMinutes;

  /// Cuándo rige la banda: "en hora pico". El pliego **no define** qué horas
  /// son, y eso se dice donde se muestra.
  final String scope;

  /// La norma exacta, para poder ir a verificarla.
  final String source;

  /// Por qué esa norma sigue valiendo hoy y no es un antecedente histórico.
  final String permitNote;

  /// La fecha de la norma. Va siempre a la vista, igual que con la tarifa: un
  /// dato de 2017 presentado sin fecha se lee como si fuera de hoy.
  final DateTime validFrom;

  /// "cada 10 a 12 minutos", o "cada 12 minutos" si la banda es un solo valor.
  String get formattedBand => shortestMinutes == longestMinutes
      ? 'cada $shortestMinutes minutos'
      : 'cada $shortestMinutes a $longestMinutes minutos';

  /// Versión corta para el renglón, donde el espacio es poco.
  String get shortBand => shortestMinutes == longestMinutes
      ? 'cada $shortestMinutes min'
      : 'cada $shortestMinutes a $longestMinutes min';

  /// "según el pliego de diciembre de 2017".
  String get formattedValidity =>
      'según el pliego de ${_months[validFrom.month - 1]} de ${validFrom.year}';

  static const _months = [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];
}

/// El pliego del 904: Anexo II de la Resolución 141-E/2017 SECGT#MTR.
///
/// ERSA URBANO S.A. tiene la línea adjudicada por diez años desde la
/// Res. 113/2018, *"de conformidad con las especificaciones y parámetros
/// operativos establecidos en el PLIEGO"*, y el permiso figura como definitivo
/// y vigente en el listado del Ministerio de Transporte. O sea: la banda no es
/// historia, es la condición de lo que opera hoy.
///
/// **Lo que no se verificó** —y por eso la fecha va SIEMPRE a la vista— es si
/// los parámetros fueron reemitidos bajo el Decreto 830/2024, que abrogó el
/// marco bajo el cual se dictó este pliego.
final _pliego904 = (
  source: 'el Anexo II de la Res. 141/2017',
  permitNote:
      'Es la condición del permiso con el que ERSA opera el 904, '
      'adjudicado hasta 2028.',
  validFrom: DateTime(2017, 12),
);

ServiceFrequency _band({required int shortest, required int longest}) =>
    ServiceFrequency(
      shortestMinutes: shortest,
      longestMinutes: longest,
      scope: 'en hora pico',
      source: _pliego904.source,
      permitNote: _pliego904.permitNote,
      validFrom: _pliego904.validFrom,
    );

/// Las frecuencias reguladas que conocemos, por `red/línea`.
///
/// **Son tres de treinta y dos líneas, y así queda.** La clave lleva la red
/// porque el código de línea es único por red y no globalmente (la 3 del Gran
/// Resistencia y la 3 de Corrientes existen las dos). Para todo lo demás no
/// hay norma publicada que fije intervalos, y estimar una a partir de la
/// longitud del recorrido sería inventar el dato que este archivo existe para
/// no inventar.
final _lineFrequencies = <String, ServiceFrequency>{
  // Terminal de Ómnibus de Resistencia ↔ Campus UNNE Corrientes.
  'interurbano-chaco-corrientes/904A': _band(shortest: 50, longest: 100),
  // UNNE Resistencia ↔ Puerto de Corrientes, por Avenida Sarmiento.
  'interurbano-chaco-corrientes/904B': _band(shortest: 10, longest: 12),
  // UNNE Resistencia ↔ Puerto de Corrientes, por Barranqueras.
  'interurbano-chaco-corrientes/904C': _band(shortest: 12, longest: 15),
};

/// La frecuencia regulada de una línea, o null si no hay norma que la fije.
///
/// Null es la respuesta abrumadoramente más común y es correcta: la pantalla
/// simplemente no dibuja nada.
ServiceFrequency? frequencyFor({
  required String networkCode,
  required String lineCode,
}) => _lineFrequencies['$networkCode/$lineCode'];
