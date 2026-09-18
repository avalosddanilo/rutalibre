/// Si las calles del mapa se están pudiendo bajar o no.
///
/// **Por qué existe.** Un tester reportó "no le dejaba hacer nada": el mapa
/// todo gris, sin calles ni paradas, con el panel funcionando arriba. La app
/// no decía NADA. Los tiles de OpenStreetMap son lo único de la pantalla que
/// necesita red sí o sí —los lugares, las calles y las alturas viajan adentro
/// de la app, y las líneas salen de la cache—, así que sin conexión el mapa
/// queda en blanco y todo lo demás sigue andando. Eso, sin un cartel, se lee
/// como una app rota.
///
/// Es la misma regla del proyecto que el aviso de los horarios: **decir lo que
/// falta antes de que lo descubran**.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Cuántos tiles seguidos tienen que fallar para dar el mapa por caído.
///
/// Uno solo no alcanza: un tile suelto que no llega es normal —se reintenta y
/// además queda tapado por el de al lado— y un cartel que aparece y desaparece
/// molesta más que el hueco. Tres es "no está llegando ninguno".
const _tilesFallados = 3;

final class TileHealth extends Notifier<bool> {
  int _fallas = 0;

  /// Arranca sano: mientras no falle nada, no hay nada que avisar.
  @override
  bool build() => false;

  /// Un tile que no llegó.
  void reportError() {
    _fallas++;
    if (_fallas >= _tilesFallados && !state) state = true;
  }

  /// Un tile que SÍ llegó: la cuenta vuelve a cero y el cartel se va.
  ///
  /// El contador se reinicia entero y no de a uno: volvió la red, y dejar
  /// fallas viejas sumando haría reaparecer el cartel al primer tile perdido
  /// de la próxima hora.
  void reportLoaded() {
    _fallas = 0;
    if (state) state = false;
  }
}

/// True cuando los tiles no están llegando.
final tileHealthProvider = NotifierProvider<TileHealth, bool>(TileHealth.new);
