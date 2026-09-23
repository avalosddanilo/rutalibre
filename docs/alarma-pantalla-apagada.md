# La alarma con la pantalla apagada: qué falta

**Estado: NO funciona.** El servicio en primer plano está hecho y anda, pero
la alarma no suena hasta que alguien prende la pantalla. Este documento es el
diagnóstico completo para poder retomarlo sin repetir el trabajo.

Probado el **2026-09-21** en un emulador Android (targetSdk 36) con el
recorrido del 904A reproducido por GPX.

## Qué se probó y qué dio

| Qué | Resultado |
|---|---|
| `TripService` arranca | ✅ `isForeground=true`, `types=0x00000008` (LOCATION), notificación en el canal `rutalibre.viaje` |
| Los permisos | ✅ `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION` y `FOREGROUND_SERVICE_LOCATION`, los tres `granted=true` |
| El GPS sigue llegando | ✅ `ProviderRequest[@+2s0ms, HIGH_ACCURACY, WorkSource{com.rutalibre.rutalibre}]`, con posiciones entregadas |
| **La alarma suena con la pantalla apagada** | ❌ **No.** Suena recién al encender la pantalla a mano |

O sea: **la cañería funciona y la decisión no se toma.**

## La causa

El disparo vive adentro del árbol de widgets, en
`_LiveRideRowState.build()` de `trip_guidance_panel.dart`:

```dart
if (progress.shouldWake && !_woke && ref.read(wakeAlarmProvider)) {
  _woke = true;
  WidgetsBinding.instance.addPostFrameCallback((_) { ...show... });
}
```

**Con la pantalla apagada Flutter deja de dibujar cuadros.** El stream de
posición sigue emitiendo —el servicio en primer plano se encarga de eso— y
Riverpod marca el widget como sucio, pero `build()` no corre hasta que haya
un cuadro. Y no lo hay. La condición nunca se evalúa.

Al encender la pantalla, Flutter reanuda, `build()` corre con la última
posición, `shouldWake` ya es verdadero, y la alarma suena. Exactamente lo
observado.

**El servicio en primer plano era necesario pero no suficiente.** Mantiene el
proceso vivo y el GPS llegando; no hace que la UI piense.

## Qué hay que hacer

Sacar la decisión de la capa que se duerme.

1. **Un provider que escuche el stream**, no un widget. Los listeners de
   Riverpod corren con el event loop de Dart, no con el scheduler de cuadros:
   siguen andando con la app en segundo plano mientras el proceso viva (y el
   servicio garantiza que viva).
2. Ese provider combina lo que hoy junta el widget —tramo, paradas, posición
   y si la alarma está armada—, calcula `rideProgress` y, cuando
   `shouldWake`, llama **directo** a `WakeAlarmGear.wakeScreen()` y `ring()`.
   El sonido y el encendido salen del canal nativo, que no depende de Flutter
   dibujando.
3. El widget pasa a ser consumidor: muestra la pantalla roja cuando puede,
   leyendo un estado "hay una alarma sonando", en vez de decidirlo él.
4. Los flags `_woke` y `_alerted` se mudan con la lógica. Ojo con el reseteo
   al salir de la zona del tramo, que hoy vive en el mismo `build()`.

**Lo que NO hay que tocar**: `TripService.kt`, el manifest y los permisos
están bien y probados. El problema es del lado de Dart.

## Cómo probarlo cuando esté

Lo que ya está armado y sirve para repetir la prueba:

```powershell
# 1. Ubicación en el arranque del recorrido
adb emu geo fix -58.88943 -27.44430

# 2. En la app: destino "Centenario Shopping Mall" (a 148 m de la última
#    parada del 904A). Tiene que dar un viaje de 5 paradas.
# 3. Iniciar viaje, activar "Avisame para bajar".
# 4. Apagar la pantalla del emulador.
# 5. Reproducir el GPX del 904A a 5x.

# Verificar que el servicio esté vivo:
adb shell dumpsys activity services com.rutalibre.rutalibre
```

La alarma tiene que sonar **sin tocar nada**, con la pantalla apagada, cuando
falten dos paradas.

## Lo que esto NO cambia

**La copy pública sigue diciendo "necesita la app abierta", y está bien.**
Nunca se tocó, justamente porque la regla del proyecto es que no se anuncia
lo que no está verificado. Hoy esa frase es verdad. Los ocho lugares a
actualizar, para cuando de verdad funcione, están listados en
`privado/marketing/README.md`.
