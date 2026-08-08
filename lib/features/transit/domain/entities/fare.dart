/// Cuánto sale el boleto, con la fecha desde la que rige y de dónde salió.
///
/// **La fecha no es un adorno: es parte del dato.** Un precio sin fecha es
/// peor que no tener precio — el que lo lee no puede saber si le sirve, y en
/// un país donde la tarifa se actualiza varias veces por año va a estar mal
/// la mayor parte del tiempo. Por eso [validFrom] y [source] son `required`:
/// no se puede construir una tarifa anónima ni sin fecha.
///
/// Es la misma honestidad que con los horarios. Ahí el problema era mandar a
/// alguien a esperar un colectivo que no viene; acá es que llegue a la
/// máquina con la plata contada.
class Fare {
  const Fare({
    required this.amount,
    required this.validFrom,
    required this.source,
  });

  /// En pesos. `double` y no centavos enteros porque hay tarifas con
  /// decimales de verdad: el ramal del Campus sale $2.921,10.
  final double amount;

  /// Desde cuándo rige. Se muestra el mes y el año, no el día: nadie decide
  /// nada con "desde el 12 de enero", y prometer esa precisión obliga a tener
  /// el día exacto de cada aumento.
  final DateTime validFrom;

  /// De dónde salió el número. Va a la vista para que se pueda ir a
  /// verificarlo — no hay fuente oficial abierta de tarifas, así que lo mejor
  /// disponible es la prensa local, y decirlo es parte de ser honesto.
  final String source;

  /// "$1.885" o "$2.921,10", en formato argentino: punto para los miles,
  /// coma para los decimales. Los centavos solo aparecen si no son cero.
  String get formattedAmount {
    final cents = ((amount - amount.truncate()) * 100).round();
    final whole = amount.truncate().toString();
    final withDots = whole.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
      (m) => '${m[1]}.',
    );
    return cents == 0
        ? '\$$withDots'
        : '\$$withDots,${cents.toString().padLeft(2, '0')}';
  }

  /// "vigente desde enero de 2026".
  String get formattedValidity =>
      'vigente desde ${_months[validFrom.month - 1]} de ${validFrom.year}';

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

/// Las tarifas conocidas, por red.
///
/// **Vive en el código y no en la base a propósito.** La base parecía el
/// lugar obvio —cambiar un precio sin publicar una versión nueva— pero no
/// funciona: `getLines` es cache-first y, una vez que la cache tiene datos,
/// NUNCA vuelve a la red. Un precio actualizado en Supabase no le llegaría
/// jamás a quien ya abrió la app. Hacerlo llegar exigiría subir la versión de
/// la cache, que es publicar una versión igual. Entre dos caminos que cuestan
/// lo mismo, gana el simple.
final _networkFares = <String, Fare>{
  'gran-resistencia': Fare(
    amount: 1885,
    validFrom: _enero2026,
    source: 'Diario Chaco',
  ),
  'interurbano-chaco-corrientes': Fare(
    amount: 1890,
    validFrom: _marzo2026,
    source: 'El Litoral',
  ),
};

/// Tarifas que NO son la de su red, por línea.
///
/// El 904A cuesta un 55% más que sus hermanos: no es el mismo servicio con
/// otro recorrido, es un viaje bastante más largo —hasta el Campus de la UNNE
/// en Corrientes— y se cobra distinto. Mostrar $1.890 para los tres sería
/// errarle por mil pesos justo en el que más sale.
///
/// La clave es `red/línea` porque el código de línea es único POR RED, no
/// globalmente.
final _lineFares = <String, Fare>{
  'interurbano-chaco-corrientes/904A': Fare(
    amount: 2921.10,
    validFrom: _marzo2026,
    source: 'El Litoral',
  ),
};

// Con nombre para no repetir el literal en cada entrada. `final` y no
// `const` porque `DateTime` no tiene constructor const — que es también la
// razón por la que las tablas de arriba tampoco pueden serlo.
final _enero2026 = DateTime(2026, 1);
final _marzo2026 = DateTime(2026, 3);

/// La tarifa de una línea, o null si no la sabemos.
///
/// **Null es una respuesta válida y frecuente**: de las cuatro redes solo dos
/// tienen tarifa confirmada. Para Corrientes capital y el interurbano del
/// Chaco no hay dato, y la pantalla no muestra nada — inventar un precio
/// "aproximado" sería exactamente el error que este archivo existe para
/// evitar.
Fare? fareFor({required String networkCode, required String lineCode}) =>
    _lineFares['$networkCode/$lineCode'] ?? _networkFares[networkCode];

/// La tarifa general de una red, ignorando las líneas que cobran distinto.
Fare? networkFareFor(String networkCode) => _networkFares[networkCode];

/// True si dentro de la red hay alguna línea que cobra otra cosa. La pantalla
/// lo usa para no dar por buena una tarifa "de la red" que no vale para todas.
bool networkHasFareExceptions(String networkCode) =>
    _lineFares.keys.any((key) => key.startsWith('$networkCode/'));
