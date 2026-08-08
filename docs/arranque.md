# Arranque en frío del mapa

Auditoría hecha para cerrar la v1.0. La conclusión corta: **el camino crítico
está bien y no hay nada riesgoso que tocar antes de publicar**, pero hay un
costo que crece con el uso y conviene atacar después.

## Qué pasa entre tocar el ícono y ver el mapa

1. **`main()`** verifica que estén las claves de Supabase y aborta con un
   mensaje explícito si faltan.
2. **`SharedPreferences.getInstance()` y `Supabase.initialize()` corren en
   paralelo** (un `record.wait`). Ninguna de las dos depende de la otra, así
   que serializarlas sería regalar tiempo. **Ninguna toca la red.**
3. **`runApp`** y el mapa dibuja: los tiles de OpenStreetMap salen a buscarse
   solos y el resto de las capas se pintan cuando llegan.

**Nada bloquea el primer cuadro esperando la red.** Se verificó leyendo cada
`ref.watch` de `map_screen.dart`: todos usan `.value ?? const []`, así que un
provider que todavía carga dibuja una capa vacía en vez de un spinner sobre
toda la pantalla. La lista de líneas muestra su spinner *dentro* del panel.

A partir de la segunda apertura, **todo lo estático sale de la cache del
teléfono** (`_cacheFirst`: si la cache no está vacía, responde y no va a la
red). La app abre sin conexión.

## Lo que ya está optimizado

- **El descongestionado de las 1474 paradas se memoiza por zoom**
  (`_AllStopMarkers`). Depende solo del zoom a propósito —usa píxeles absolutos
  del mundo—, así que arrastrar el mapa no lo recalcula. Lo único que corre en
  cada cuadro es el recorte al viewport, que trabaja sobre lo que sobrevivió al
  descongestionado y no sobre las 1474.
- **Las paradas se dibujan sin pedir el GPS**: el mapa no arranca vacío ni
  espera un permiso.

## El costo que crece: la cache en SharedPreferences

Medido sobre los datos reales:

| Entrada de la cache | Tamaño |
|---|---|
| `all_stops` (las 1474 paradas) | **≈ 267 KB** |
| Paradas por recorrido, si se abren los 73 | **≈ 436 KB más** |

`SharedPreferences.getInstance()` **carga el archivo entero en memoria** y está
en el camino crítico, antes del primer cuadro. Hoy son ~267 KB en el peor caso
de una instalación nueva, que se parsean en pocos milisegundos y no se notan.
El problema es que **crece con el uso**: quien abra muchos recorridos puede
llegar a ~700 KB, y eso sí se empieza a sentir al abrir.

### Qué NO se hizo, y por qué

Cambiar el almacenamiento **antes de publicar** sería mover la pieza de la que
depende que la app abra rápido y funcione sin señal, sin poder probarlo en un
teléfono. No vale el riesgo para un costo que hoy no se nota.

### La propuesta, para después de la v1

`ARCHITECTURE.md` ya lo anticipa: *"si la cache crece, el reemplazo es drift/sqflite
cambiando solo esa clase"*. Concretamente:

- Reemplazar `SharedPrefsTransitLocalDataSource` por una implementación sobre
  **sqflite** o sobre archivos sueltos. El contrato `TransitLocalDataSource` no
  cambia, así que **no se toca nada más de la app**.
- Ganancia: el arranque deja de pagar por datos que todavía no se usan, y cada
  entrada se lee cuando hace falta.
- Alternativa más chica: migrar a **`SharedPreferencesAsync`**, que no carga
  todo de una. Menos trabajo, menos ganancia.

**Cómo saber si hace falta**: medir con `flutter run --profile` y mirar el
tiempo hasta el primer cuadro con la cache llena (después de abrir varios
recorridos). Si pasa de ~500 ms, es esto.

## Lo que hay que medir en un teléfono de verdad

Esta auditoría es **estática**: se leyó el código y se midieron los datos, pero
no se cronometró la app en un dispositivo. Antes de dar el arranque por bueno:

```bash
flutter run --profile --dart-define-from-file=env.json
```

Y mirar en el DevTools el tiempo hasta el primer cuadro, dos veces: con la app
recién instalada y después de haber navegado un rato.
