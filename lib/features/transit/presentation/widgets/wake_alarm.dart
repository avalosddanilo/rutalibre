import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../providers/trip_providers.dart';
import '../providers/wake_alarm_watch.dart';

/// Lo que la alarma le pide al teléfono, con nombre de lo que hace acá.
///
/// Interfaz y no llamadas directas a los plugins, por lo mismo que
/// `HailBrightness`: los tests verifican que la alarma suena, calla y
/// devuelve la pantalla SIN necesitar la plataforma, y un teléfono donde un
/// plugin falte no puede romper la guía — la alarma que no pudo sonar deja
/// la vibración y el renglón encendido, que ya existían.
abstract interface class WakeAlarmGear {
  /// Mantiene el viaje vivo mientras la alarma esté armada, **aunque el
  /// usuario apague la pantalla**.
  ///
  /// En Android eso es un servicio en primer plano de tipo `location`: sin
  /// él, el sistema congela el proceso al apagarse la pantalla y el GPS deja
  /// de llegar, así que la alarma nunca se entera de que llegaste. Ver
  /// `TripService.kt`.
  ///
  /// Devuelve **true si lo consiguió**. False es el mundo de la 1.0 —iOS, o
  /// un Android que rechazó el servicio— donde la alarma sigue andando pero
  /// necesita la pantalla prendida; el que devuelve false ya dejó puesto el
  /// wakelock que la sostiene.
  Future<bool> holdTrip();

  /// Suelta todo: se va el servicio, se va el wakelock, el teléfono vuelve a
  /// ser del usuario.
  Future<void> releaseTrip();

  /// Enciende la pantalla y se muestra sobre el bloqueo.
  ///
  /// Se llama al SONAR, no al armar: es lo que convierte "suena en el
  /// bolsillo" en "suena y además hay algo para leer cuando lo sacás".
  Future<void> wakeScreen();

  /// El tono de ALARMA del sistema, en loop, por el canal de alarmas: suena
  /// aunque el teléfono esté en silencio — que arriba del colectivo es
  /// exactamente cuándo hace falta.
  Future<void> ring();

  /// Silencio.
  Future<void> silence();

  /// Un "ding" corto al arrancar un viaje: el sonido propio de la app
  /// (`tools/trip_start_chime.dart`), no el del sistema, que en muchos
  /// teléfonos es feo. Al revés que [ring], respeta el modo silencio: avisar
  /// que algo empezó no justifica sonar en una reunión.
  Future<void> chime();
}

/// La implementación real: un canal nativo propio para el servicio, la
/// pantalla y el tono, con `wakelock_plus` como única red.
///
/// El tono NO usa un plugin a propósito: lo único que hace falta es "el tono
/// de alarma del sistema, en loop, por el canal de alarmas", que en Android
/// son veinte líneas de `MediaPlayer` (ver `MainActivity.kt`). El plugin que
/// lo hacía compilaba contra Android 33 y rompía el build de release — una
/// dependencia entera, con su riesgo, por veinte líneas que podemos tener en
/// casa. En iOS el canal no existe y el catch lo deja en silencio: la
/// pantalla de alarma y la vibración despiertan igual.
///
/// Lo mismo vale para el servicio: donde no hay canal, [holdTrip] devuelve
/// false y cae al wakelock, que es exactamente como funcionaba la 1.0.
final class DeviceWakeAlarmGear implements WakeAlarmGear {
  const DeviceWakeAlarmGear();

  static const _channel = MethodChannel('rutalibre/alarm');

  @override
  Future<bool> holdTrip() async {
    var servicio = false;
    try {
      servicio = await _channel.invokeMethod<bool>('holdTrip') ?? false;
    } on Object {
      // iOS no tiene el canal, y un Android puede rechazar el servicio.
      servicio = false;
    }
    if (!servicio) {
      // La red de la 1.0: sin servicio, la única forma de que el GPS siga
      // llegando es que la pantalla no se apague. Peor, pero funciona.
      try {
        await WakelockPlus.enable();
      } on Object {
        // Y sin wakelock, la alarma sirve mientras la app esté adelante.
      }
    }
    return servicio;
  }

  @override
  Future<void> releaseTrip() async {
    // Los dos, siempre y sin preguntar cuál se usó: el estado de "qué agarré"
    // se puede perder (la actividad se recrea al rotar) y lo que NO se puede
    // es dejar el servicio corriendo o la pantalla clavada prendida.
    try {
      await _channel.invokeMethod<void>('releaseTrip');
    } on Object {
      // Parar lo que no arrancó no es un problema.
    }
    try {
      await WakelockPlus.disable();
    } on Object {
      // Nada que soltar si nunca se pudo agarrar.
    }
  }

  @override
  Future<void> wakeScreen() async {
    try {
      await _channel.invokeMethod<void>('wakeScreen');
    } on Object {
      // Sin pantalla encendida quedan el tono y la vibración.
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
    armed ? await gear.holdTrip() : await gear.releaseTrip();
  }

  /// Desarma y devuelve el teléfono como estaba: silencio y pantalla normal.
  Future<void> release() async {
    state = false;
    // Bajar la pantalla roja no se hace desde acá: lo hace
    // `WakeAlarmWatchNotifier`, que escucha el fin de la guía igual que este
    // notifier. Escribir en otro provider desde adentro de un listener tira
    // una excepción de Riverpod.
    final gear = ref.read(wakeAlarmGearProvider);
    await gear.silence();
    await gear.releaseTrip();
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
/// vibración sostenida, y la pantalla —que [WakeAlarmGear.wakeScreen]
/// enciende, aunque estuviera apagada y bloqueada— entera de un color que no
/// es el de ninguna otra pantalla de la app.
///
/// Se apaga SOLO con el botón (o el gesto de atrás): una alarma que se puede
/// apagar sin querer, rozándola medio dormido, no despertó a nadie.
class WakeAlarmScreen extends ConsumerStatefulWidget {
  const WakeAlarmScreen({required this.stopName, super.key});

  /// Dónde bajarse: lo primero que necesita leer alguien recién despierto.
  final String stopName;

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
        builder: (context) => WakeAlarmScreen(stopName: stopName),
      );
    } finally {
      _showing = false;
    }
  }

  @override
  ConsumerState<WakeAlarmScreen> createState() => _WakeAlarmScreenState();
}

class _WakeAlarmScreenState extends ConsumerState<WakeAlarmScreen> {
  Timer? _vibration;

  /// El notifier guardado, porque `ref` en `dispose()` ya no es seguro: para
  /// entonces el widget está desmontándose y su BuildContext no sirve.
  /// Riverpod lo dice con todas las letras si uno lo intenta.
  late final WakeAlarmWatchNotifier _watch;

  @override
  void initState() {
    super.initState();
    _watch = ref.read(wakeAlarmWatchProvider.notifier);
    // ESTA PANTALLA NO HACE SONAR NADA, y no es un olvido.
    //
    // Encender la pantalla y arrancar el tono los hace
    // `WakeAlarmWatchNotifier` cuando decide que la alarma tiene que sonar,
    // porque salen por el canal nativo y no dependen de que Flutter esté
    // dibujando. Si el tono esperara a que este widget se monte, con la
    // pantalla apagada no sonaría nunca — que es exactamente el bug que
    // estamos arreglando. Ver `docs/alarma-pantalla-apagada.md`.
    //
    // Para cuando este initState corre, el teléfono ya está sonando y la
    // pantalla ya se encendió sola. Lo único que falta es la vibración.
    //
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
    // En un microtask porque Riverpod prohíbe modificar un provider desde
    // `dispose` —el árbol todavía se está desmontando—. El retraso es de
    // microsegundos y el tono se apaga igual; hacerlo derecho acá tira una
    // excepción que en release se tragaría, dejando la alarma sonando
    // encima del mapa.
    Future.microtask(_watch.dismiss);
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
