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

## Cómo probarlo — el paso a paso

**Hace falta un EMULADOR, no un teléfono enchufado.** `adb emu geo fix` es un
canal del emulador; contra un dispositivo físico falla sin decir por qué.

### 0 · Antes de empezar

```bash
flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
adb devices        # tiene que listar un emulator-5554
```

### 1 · Ponerte en el arranque del recorrido

```bash
adb emu geo fix -58.88943 -27.44430
```

Longitud primero y latitud después, que es al revés de como lo dice todo el
mundo. Ese punto es el arranque del 904A.

### 2 · Armar el viaje en la app

Destino **"Centenario Shopping Mall"** (a 148 m de la última parada del
904A): tiene que dar un viaje de 5 paradas. Iniciá el viaje y activá
**"Avisame para bajar"**.

### 3 · Anotar las coordenadas de la parada de BAJADA

Las necesita el script. La app ya te las da: tocá la parada de bajada en el
mapa y abrí **"ver en OpenStreetMap"** — la URL que se abre trae la latitud
y la longitud.

Si no las conseguís, usá las del destino: la parada está unos cientos de
metros antes, así que la alarma va a sonar un poco **antes** del cartel que
imprime el script. Eso es esperable, no un error.

### 4 · Verificar que el servicio esté vivo

```bash
adb shell dumpsys activity services com.rutalibre.rutalibre
```

Tiene que aparecer `TripService`. Si no está, la alarma no va a sonar con la
pantalla apagada y el resto de la prueba no significa nada.

### 5 · Apagar la pantalla

```bash
adb shell input keyevent 26
```

**Este es el paso que la prueba viene a hacer.** Con la pantalla prendida la
alarma funcionaba incluso con el bug viejo.

### 6 · Soltar el viaje simulado

```bash
dart run tools/simular_viaje.dart \
  --desde -58.88943,-27.44430 \
  --hasta <lng>,<lat> \
  --pasos 60 --intervalo 2
```

El script imprime cuántos metros faltan en cada fix y avisa, una sola vez,
cuándo cruza los 500 m: **ahí la alarma tiene que sonar.** Si suena mucho
después de ese cartel, llegó tarde, y eso es exactamente el bug que esta
prueba busca.

Avisa solo si los pasos quedaron tan largos que el salto se come el umbral.
Hacele caso: con saltos de 250 m no se puede distinguir "a tiempo" de
"tarde".

### 7 · Qué tiene que pasar

Sin tocar nada, con la pantalla apagada: la pantalla se enciende sola, suena
fuerte aunque el teléfono esté en silencio, y aparece "¡Preparate para
bajar!".

### Si no suena

Lo primero que hay que descartar **no** es la alarma sino el recorrido:
`rideProgress` mide contra los SEGMENTOS entre paradas del tramo y devuelve
`null` si te saliste de la zona — y la línea recta entre dos puntos puede
cortar por fuera del recorrido real. Si eso pasa, la condición nunca se
evalúa y la alarma calla con razón.

La solución es pasarle puntos intermedios sobre la calle por la que va el
colectivo, que se repiten las veces que haga falta:

```bash
dart run tools/simular_viaje.dart --desde A --por B --por C --hasta D
```

Recién si con el recorrido bien seguido tampoco suena, el problema está en
la alarma.

## Lo que esto NO cambia

**La copy pública sigue diciendo "necesita la app abierta", y está bien.**
Nunca se tocó, justamente porque la regla del proyecto es que no se anuncia
lo que no está verificado. Hoy esa frase es verdad. Los ocho lugares a
actualizar, para cuando de verdad funcione, están listados en
`privado/marketing/README.md`.
