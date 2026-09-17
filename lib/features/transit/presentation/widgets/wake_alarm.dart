import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../providers/trip_providers.dart';

/// Lo que la alarma le pide al teléfono, con nombre de lo que hace acá.
///
/// Interfaz y no llamadas directas a los plugins, por lo mismo que
/// `HailBrightness`: los tests verifican que la alarma suena, calla y
/// devuelve la pantalla SIN necesitar la plataforma, y un teléfono donde un
/// plugin falte no puede romper la guía — la alarma que no pudo sonar deja
/// la vibración y el renglón encendido, que ya existían.
abstract interface class WakeAlarmGear {
  /// La pantalla no se apaga sola mientras la alarma esté armada: una alarma
  /// en una pantalla apagada no despierta a nadie (la app queda pausada y el
  /// GPS deja de llegar).
  Future<void> keepScreenOn();

  /// La pantalla vuelve a apagarse como siempre.
  Future<void> allowScreenOff();

  /// El tono de ALARMA del sistema, en loop, por el canal de alarmas: suena
  /// aunque el teléfono esté en silencio — que arriba del colectivo es
  /// exactamente cuándo hace falta.
  Future<void> ring();

  /// Silencio.
  Future<void> silence();

  /// Un "ding" corto al arrancar un viaje, con el sonido de notificación del
  /// sistema. Al revés que [ring], respeta el modo silencio: avisar que algo
  /// empezó no justifica sonar en una reunión.
  Future<void> chime();
}

/// La implementación real: `wakelock_plus` para la pantalla y un canal
/// nativo propio para el tono.
///
/// El tono NO usa un plugin a propósito: lo único que hace falta es "el tono
/// de alarma del sistema, en loop, por el canal de alarmas", que en Android
/// son veinte líneas de `MediaPlayer` (ver `MainActivity.kt`). El plugin que
/// lo hacía compilaba contra Android 33 y rompía el build de release — una
/// dependencia entera, con su riesgo, por veinte líneas que podemos tener en
/// casa. En iOS el canal no existe y el catch lo deja en silencio: la
/// pantalla de alarma y la vibración despiertan igual.
final class DeviceWakeAlarmGear implements WakeAlarmGear {
  const DeviceWakeAlarmGear();

  static const _channel = MethodChannel('rutalibre/alarm');

  @override
  Future<void> keepScreenOn() async {
    try {
      await WakelockPlus.enable();
    } on Object {
      // Sin wakelock la alarma sirve igual mientras la pantalla esté prendida.
    }
  }

  @override
  Future<void> allowScreenOff() async {
    try {
      await WakelockPlus.disable();
    } on Object {
      // Nada que soltar si nunca se pudo agarrar.
    }
  }

  @override
  Future<void> ring() async {
    try {
      await _channel.invokeMethod<void>('ring');
    } on Object {
      // Queda la vibración de la pantalla de alarma, que no pasa por acá.
    }
  }

  @override
  Future<void> silence() async {
    try {
      await _channel.invokeMethod<void>('silence');
    } on Object {
      // Si no llegó a sonar, no hay nada que parar.
    }
  }

  @override
  Future<void> chime() async {
    try {
      await _channel.invokeMethod<void>('chime');
    } on Object {
      // Sin sonido el viaje arranca igual; la vibración ya avisó.
    }
  }
}

final wakeAlarmGearProvider = Provider<WakeAlarmGear>(
  (ref) => const DeviceWakeAlarmGear(),
);

/// Armada o no. La alarma "avisame para bajar" de un viaje guiado.
///
/// Vive en un provider y no en el renglón del contador porque cambiar de
/// paso (o de tramo, en un transbordo) reconstruye el renglón, y una alarma
/// que se desarma sola al tocar "Siguiente" es una alarma en la que no se
/// puede confiar. Queda armada TODO el viaje: en un transbordo hay que
/// bajarse dos veces, y las dos veces cuentan.
final class WakeAlarmNotifier extends Notifier<bool> {
  @override
  bool build() {
    // La guía terminó, por el botón o porque el viaje cambió abajo: pantalla
    // devuelta y silencio, pase lo que pase. Sin esto, "Terminar" con la
    // alarma sonando la dejaría sonando sobre el mapa.
    ref.listen(tripGuidanceProvider, (_, next) {
      if (next == null) release();
    });
    return false;
  }

  Future<void> setArmed(bool armed) async {
    if (state == armed) return;
    state = armed;
    final gear = ref.read(wakeAlarmGearProvider);
    await (armed ? gear.keepScreenOn() : gear.allowScreenOff());
  }

  /// Desarma y devuelve el teléfono como estaba: silencio y pantalla normal.
  Future<void> release() async {
    state = false;
    final gear = ref.read(wakeAlarmGearProvider);
    await gear.silence();
    await gear.allowScreenOff();
  }
}

final wakeAlarmProvider = NotifierProvider<WakeAlarmNotifier, bool>(
  WakeAlarmNotifier.new,
);

/// La pantalla de la alarma sonando: "preparate para bajar", a toda pantalla.
///
/// **Existe porque quedarse dormido arriba del colectivo pasa de verdad.**
/// El renglón en vivo ya vibraba UNA vez al entrar en zona de bajada — bien
/// para quien va mirando el teléfono, invisible para quien se durmió con el
/// teléfono en el bolsillo. Esto es la versión que despierta: el tono de
/// alarma del sistema en loop por el canal de alarmas (suena en silencio),
/// vibración sostenida, y la pantalla —que la alarma armada mantuvo
/// prendida— entera de un color que no es el de ninguna otra pantalla de la
/// app.
///
/// Se apaga SOLO con el botón (o el gesto de atrás): una alarma que se puede
/// apagar sin querer, rozándola medio dormido, no despertó a nadie.
class WakeAlarmScreen extends StatefulWidget {
  const WakeAlarmScreen({
    required this.stopName,
    required this.gear,
    super.key,
  });

  /// Dónde bajarse: lo primero que necesita leer alguien recién despierto.
  final String stopName;

  final WakeAlarmGear gear;

  /// True mientras hay una alarma en pantalla: el GPS oscila y dos fixes
  /// seguidos en zona de bajada no pueden apilar dos alarmas.
  static bool _showing = false;

  /// Solo para tests: desmontar el árbol con la alarma abierta no pasa por
  /// el pop, y el flag quedaría trabado para el test siguiente.
  @visibleForTesting
  static void resetShowingForTest() => _showing = false;

  static Future<void> show(
    BuildContext context, {
    required String stopName,
    required WakeAlarmGear gear,
  }) async {
    if (_showing) return;
    _showing = true;
    try {
      await showDialog<void>(
        context: context,
        useSafeArea: false,
        // Tocar afuera no existe: es pantalla completa. El botón es el único
        // camino (y el gesto de atrás, que pasa por dispose igual).
        barrierDismissible: false,
        builder: (context) => WakeAlarmScreen(stopName: stopName, gear: gear),
      );
    } finally {
      _showing = false;
    }
  }

  @override
  State<WakeAlarmScreen> createState() => _WakeAlarmScreenState();
}

class _WakeAlarmScreenState extends State<WakeAlarmScreen> {
  Timer? _vibration;

  @override
  void initState() {
    super.initState();
    widget.gear.ring();
    // La vibración acompaña al tono, una sacudida por segundo: en el
    // bolsillo, contra la pierna, es lo que se siente antes de oír nada.
    HapticFeedback.heavyImpact();
    _vibration = Timer.periodic(const Duration(seconds: 1), (_) {
      HapticFeedback.heavyImpact();
    });
  }

  @override
  void dispose() {
    // En dispose y no en el onPressed: el gesto de atrás del sistema también
    // cierra esta pantalla y no pasa por ningún botón.
    _vibration?.cancel();
    widget.gear.silence();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.errorContainer,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.notifications_active,
                        size: 72,
                        color: scheme.onErrorContainer,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '¡Preparate para bajar!',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: scheme.onErrorContainer,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Tu parada es ${widget.stopName}.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: scheme.onErrorContainer),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                  child: const Text('Listo, estoy despierto'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
