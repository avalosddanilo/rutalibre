import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/stop.dart';
import '../../domain/entities/trip_plan.dart';
import '../utils/ride_progress.dart';
import '../widgets/wake_alarm.dart';
import 'location_providers.dart';
import 'trip_providers.dart';
import 'transit_providers.dart';

/// Quién decide que la alarma tiene que sonar.
///
/// **POR QUÉ ESTO NO VIVE EN UN WIDGET.** Vivía. El disparo estaba adentro
/// del `build()` del renglón en vivo, y con la pantalla apagada Flutter deja
/// de dibujar cuadros: las posiciones seguían llegando —el servicio en
/// primer plano se encarga de eso— pero `build()` no corría y la condición
/// nunca se evaluaba. La alarma sonaba recién al encender la pantalla a
/// mano, que es exactamente cuando ya no hace falta. Probado en emulador el
/// 2026-09-21; el diagnóstico completo está en
/// `docs/alarma-pantalla-apagada.md`.
///
/// Los listeners de Riverpod corren con el **event loop de Dart**, no con el
/// scheduler de cuadros. Mientras el proceso viva —y el servicio en primer
/// plano garantiza que viva— este provider evalúa cada fix, dibuje Flutter o
/// no. Por eso también es él quien llama a `wakeScreen()` y `ring()`: esas
/// dos cosas salen por el canal nativo y no dependen de que haya una
/// pantalla montada. Si esperáramos a que el widget se monte para sonar,
/// estaríamos de vuelta en el mismo bug con más pasos.
///
/// El widget quedó de consumidor: mira [wakeAlarmWatchProvider] y dibuja la
/// pantalla roja **cuando puede**. Que no pueda ya no impide que suene.

/// El tramo de colectivo que se está vigilando, o null si no hay viaje.
///
/// Lo setea el renglón en vivo al montarse, porque los pasos del viaje son
/// un parámetro del panel y no un provider: nadie más sabe cuál es el tramo
/// activo. Esa registración sí depende de un cuadro, y está bien — pasa una
/// sola vez, al arrancar el viaje, con la pantalla prendida y la persona
/// mirando. Lo que no podía depender de un cuadro era la DECISIÓN, que es la
/// que ocurre dos horas después con el teléfono en el bolsillo.
final watchedRideLegProvider =
    NotifierProvider<WatchedRideLegNotifier, TripLeg?>(
      WatchedRideLegNotifier.new,
    );

final class WatchedRideLegNotifier extends Notifier<TripLeg?> {
  @override
  TripLeg? build() => null;

  void watch(TripLeg? leg) {
    if (identical(state, leg)) return;
    state = leg;
  }
}

/// Lo que hay que mostrar cuando la alarma está sonando. Null = no suena.
///
/// Clase y no un `bool` porque la pantalla necesita decir DÓNDE bajarse, y
/// leerlo del tramo en el momento de dibujar sería leerlo tarde: para
/// entonces el tramo ya puede haber cambiado.
final class WakeAlarmAlert {
  const WakeAlarmAlert({required this.stopName});

  /// Dónde bajarse: lo primero que necesita leer alguien recién despierto.
  final String stopName;
}

final wakeAlarmWatchProvider =
    NotifierProvider<WakeAlarmWatchNotifier, WakeAlarmAlert?>(
      WakeAlarmWatchNotifier.new,
    );

final class WakeAlarmWatchNotifier extends Notifier<WakeAlarmAlert?> {
  /// Para vibrar UNA vez al entrar en zona de bajada, no en cada fix.
  ///
  /// NO se resetea cuando `shouldPrepare` vuelve a falso, porque el GPS
  /// oscila — un fix a 240 m y el siguiente a 260 harían vibrar el teléfono
  /// en cada vaivén. Solo se rearma al salir de la zona del tramo entero,
  /// que es un cambio de situación real y no ruido.
  bool _prepared = false;

  /// Ídem para la alarma, que suena ANTES ([RideProgress.shouldWake]): a
  /// quien hay que despertar no le alcanza el aviso de "una parada antes".
  bool _woke = false;

  /// Contra qué tramo están puestos los flags de arriba.
  ///
  /// `build()` vuelve a correr también cuando cargan las paradas del
  /// recorrido, no solo cuando cambia el tramo. Resetear los flags ahí a
  /// ciegas podría rearmar una alarma que ya sonó y hacerla sonar dos veces.
  TripLeg? _flagsFor;

  @override
  WakeAlarmAlert? build() {
    // La guía terminó —botón "Terminar", o el viaje cambió abajo—: la
    // alarma se baja sola.
    //
    // Lo escucha ESTE provider en vez de que `WakeAlarmNotifier.release()`
    // venga a bajarla: escribir en un provider desde adentro del listener de
    // otro tira una excepción de Riverpod, que en release se tragaría y
    // dejaría la pantalla roja encima del mapa. De silenciar el tono se
    // sigue encargando `release()`, que ya lo hacía.
    ref.listen(tripGuidanceProvider, (_, next) {
      if (next == null) state = null;
    });

    final leg = ref.watch(watchedRideLegProvider);
    if (leg == null) {
      // Sin viaje no se escucha el GPS. `livePositionProvider` es
      // autoDispose justamente para eso: fuera de la guía la app no sigue a
      // nadie, y suscribirse acá "por las dudas" rompería esa promesa.
      _flagsFor = null;
      return null;
    }

    if (!identical(_flagsFor, leg)) {
      _flagsFor = leg;
      _prepared = false;
      _woke = false;
    }

    final stops = ref.watch(stopsForRouteProvider(leg.routeVariantId)).value;

    // `watch` y NO `read` adentro del callback de abajo, y costó encontrarlo:
    // leer un provider por PRIMERA vez desde adentro de un listener deja la
    // suscripción rota, y a partir de ahí no llega ni un fix más. Hoy en la
    // app no se notaría —el interruptor de la alarma ya lo tiene vivo— pero
    // depender de que otro widget mantenga vivo lo que necesitamos es
    // exactamente la clase de suposición que nos trajo hasta acá.
    //
    // Declararlo como dependencia además reconstruye esto al armar o
    // desarmar, que es lo correcto: los flags no se tocan (los cuida
    // `_flagsFor`), y una alarma que se arma tarde queda escuchando igual.
    final armada = ref.watch(wakeAlarmProvider);

    // Re-evaluar YA con la última posición conocida, sin esperar un fix
    // nuevo. Es el caso de armar la alarma cuando el colectivo ya está
    // llegando: `build()` vuelve a correr al armar, y sin esto habría que
    // esperar a que el GPS mande una posición DISTINTA de la anterior —los
    // records comparan por valor, así que un fix idéntico no notifica—. Con
    // el colectivo parado en un semáforo eso puede no pasar nunca.
    //
    // En un microtask porque tocar `state` adentro del propio `build` no se
    // puede, y con guarda de vida: entre el microtask y ahora el viaje puede
    // haber terminado.
    final ultima = ref.read(livePositionProvider).value;
    if (ultima != null) {
      var vivo = true;
      ref.onDispose(() => vivo = false);
      Future.microtask(() {
        if (!vivo) return;
        _evaluate(leg: leg, stops: stops, armada: armada, position: ultima);
      });
    }

    ref.listen(livePositionProvider, (_, next) {
      // Solo fixes de verdad. Un error del stream conserva el último valor
      // en Riverpod, y actuar sobre eso sería despertar a alguien con una
      // posición vieja.
      //
      // Y no hace falta chequear que el fix esté FRESCO como hace el
      // renglón: acá se reacciona a la EMISIÓN, no al valor guardado, y una
      // emisión recién llegada es fresca por definición.
      if (next is! AsyncData<UserPosition>) return;
      _evaluate(leg: leg, stops: stops, armada: armada, position: next.value);
    });

    return state;
  }

  void _evaluate({
    required TripLeg leg,
    required List<Stop>? stops,
    required bool armada,
    required UserPosition position,
  }) {
    if (stops == null) return;

    final progress = rideProgress(
      routeStops: stops,
      leg: leg,
      lat: position.lat,
      lng: position.lng,
    );

    if (progress == null) {
      // Se salió de la zona del tramo: si vuelve a entrar, puede volver a
      // avisar (bajarse, caminar y volver a subir es raro pero existe).
      _prepared = false;
      _woke = false;
      return;
    }

    if (progress.shouldPrepare && !_prepared) {
      _prepared = true;
      // Háptica y no sonido: arriba del colectivo el teléfono está en la
      // mano o el bolsillo, y un pitido compite con el ruido del motor.
      HapticFeedback.heavyImpact();
    }

    // El flag se consume recién cuando SUENA: si la alarma se arma tarde
    // —ya adentro de la zona—, el próximo fix la dispara igual.
    if (progress.shouldWake && !_woke && armada) {
      _woke = true;
      final gear = ref.read(wakeAlarmGearProvider);
      // Primero encender la pantalla y recién después sonar: al revés, el
      // medio segundo que tarda el tono en arrancar es medio segundo de
      // alguien despertándose a oscuras sin saber por qué.
      gear.wakeScreen();
      gear.ring();
      state = WakeAlarmAlert(stopName: leg.alightStop.name);
    }
  }

  /// Apaga la alarma. La llama la pantalla al cerrarse —por el botón o por
  /// el gesto de atrás— y también [WakeAlarmNotifier.release] al terminar la
  /// guía, que es el caso de "Terminar" con la alarma sonando.
  void dismiss() {
    state = null;
    // Sin guardar por `state == null`: la pantalla llama a esto desde su
    // `dispose`, y tiene que poder apagar el tono aunque el estado ya se
    // haya bajado por otro lado. Silenciar lo que ya está en silencio no
    // hace nada; dejar sonando un tono porque el estado se adelantó, sí.
    ref.read(wakeAlarmGearProvider).silence();
  }
}
