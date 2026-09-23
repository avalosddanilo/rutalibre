# La alarma con la pantalla apagada

**Estado: arreglado en el código, SIN verificar en un teléfono.**

La decisión ya no vive en un widget (ver *El arreglo*, más abajo) y hay siete
tests que la disparan **sin dibujar un solo cuadro**, que es la condición que
el teléfono dormido impone. Pero un test no es un teléfono: hasta que no se
repita la prueba del emulador de acá abajo y la alarma suene sola, **esto no
se anuncia en ningún lado**. La copy del interruptor sigue diciendo
"Necesita la app abierta" a propósito.

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

## El arreglo

`lib/features/transit/presentation/providers/wake_alarm_watch.dart`.

1. **Un provider escucha el stream**, no un widget. Los listeners de Riverpod
   corren con el event loop de Dart, no con el scheduler de cuadros: siguen
   andando con la app en segundo plano mientras el proceso viva (y el
   servicio en primer plano garantiza que viva).
2. Ese provider junta lo que antes juntaba el widget —tramo, paradas,
   posición y si la alarma está armada—, calcula `rideProgress` y, cuando
   `shouldWake`, llama **directo** a `wakeScreen()` y `ring()`. Salen por el
   canal nativo, que no depende de Flutter dibujando.
3. `WakeAlarmScreen` pasó a ser consumidora: **ya no hace sonar nada**.
   Dibuja y vibra. Cuando se monta, el teléfono ya está sonando.
4. El renglón en vivo solo registra cuál es el tramo activo (`initState`) y
   muestra la alarma que el provider ya prendió.

**Lo que NO se tocó**: `TripService.kt`, el manifest y los permisos estaban
bien y probados. El problema era todo del lado de Dart.

### Tres trampas de Riverpod que costaron encontrar

Quedan escritas porque las tres estaban calladas y las tres las encontró un
test, no una lectura del código:

* **`ref` no se puede usar en `dispose()`** ni para leer ni para escribir.
  Se guarda el notifier en un campo en `initState`, y la escritura va en un
  `Future.microtask`.
* **Leer un provider por primera vez desde adentro de un listener deja la
  suscripción rota**: no llega un fix más. Por eso la alarma armada se
  `watch`ea en el `build`, no se `read`ea en el callback.
* **Escribir en un provider desde el listener de otro** tira excepción. Por
  eso el fin de la guía lo escucha el propio provider de la alarma en vez de
  que `WakeAlarmNotifier.release()` venga a bajarla.

Y una de Dart, no de Riverpod: **los records comparan por valor**, así que
dos fixes con coordenadas idénticas no son un cambio de estado y el listener
no se dispara. Por eso al armar la alarma se re-evalúa con la última
posición conocida en vez de esperar un fix nuevo, que con el colectivo
parado en un semáforo podía no llegar nunca.

## Los tests

`test/features/transit/presentation/providers/wake_alarm_watch_test.dart`.

**No tiene un solo `testWidgets`, y esa es la prueba.** Sin árbol de
widgets, sin `tester`, sin un cuadro dibujado. Si la alarma suena ahí, suena
con la pantalla apagada; si alguien devuelve la decisión a un widget, se
ponen rojos.

Cubren: que suene en zona de bajada, que encienda la pantalla **antes** de
sonar, que sin armar no despierte a nadie, que el GPS oscilando no la haga
sonar dos veces, que armarla tarde —ya adentro de la zona— dispare igual,
que sin tramo activo no se escuche el GPS (la app no sigue a nadie fuera de
la guía) y que salir de la zona rearme el aviso.

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

**Esta prueba es la que falta.** Mientras no se haga, el estado de arriba
sigue diciendo "sin verificar" y la copy sigue sin prometer nada.

## Lo que esto NO cambia

**La copy pública sigue diciendo "necesita la app abierta", y está bien.**
Nunca se tocó, justamente porque la regla del proyecto es que no se anuncia
lo que no está verificado. Hoy esa frase es verdad. Los ocho lugares a
actualizar, para cuando de verdad funcione, están listados en
`privado/marketing/README.md`.
