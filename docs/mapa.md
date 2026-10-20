# El mapa base

Desde la 1.3 las calles del mapa viajan adentro de la app. Este documento
explica qué hay, de dónde sale y cómo se actualiza.

## Por qué

Hasta la 1.2 el mapa se bajaba de `tile.openstreetmap.org`, de a pedacitos
(tiles), cada vez que alguien lo miraba. Tres problemas:

1. **Sin señal, mapa gris.** Justo en la parada, que es donde más falta hace.
   El planificador ya anda sin conexión; el mapa tiene que acompañar.
2. **La política de esos servidores.** La
   [Tile Usage Policy](https://operations.osmfoundation.org/policies/tiles/)
   prohíbe guardar tiles para usarlos sin conexión y avisa que pueden cortarle
   el acceso a una app sin previo aviso. Es un servicio donado; no está hecho
   para que una app con miles de usuarios cuelgue de él. (flutter_map imprime
   el mismo aviso en cada corrida de los tests.)
3. **Los datos de quien usa la app.** Cada vistazo al mapa los gastaba.

## Qué hay

| Archivo | Qué es | Peso |
|---|---|---|
| `assets/map/gran-resistencia-corrientes.pmtiles` | Las calles, en tiles vectoriales (formato [PMTiles](https://docs.protomaps.com/pmtiles/)), zoom 0 a 15 | ~5,2 MB |
| `assets/map/estilo-claro.json` | Cómo se dibuja: colores, grosores, nombres (estilo MapLibre) | ~64 KB |
| `assets/map/estilo-oscuro.json` | Lo mismo, para el modo oscuro | ~64 KB |

- **Qué cubre:** el rectángulo `-59.15,-27.62,-58.64,-27.27` (oeste, sur,
  este, norte): todos los recorridos de la base con unos 4 km de margen. El
  mapa no deja llevar el centro afuera de ahí (`MapScreen.coveredArea`). Si
  un recorrido nuevo se sale, hay que ampliar el rectángulo **y** regenerar.
- **Más allá del zoom 15** la librería agranda los tiles del 15: las calles
  se siguen viendo nítidas porque son vectores, no imágenes.
- **Los nombres** los dibuja Flutter con la fuente del sistema: no hacen falta
  archivos de fuentes ni pedidos por red.
- **Sin íconos de lugares** (el estilo no tiene `sprite`): los nombres de
  hospitales, escuelas y plazas sí aparecen. Lo que importa en el mapa son las
  paradas, que dibuja la app.

## Los colores

Son los de Protomaps con colores propios encima (`propios` en
`tools/mapa/estilo.mjs`). El criterio, en orden:

1. **Que las líneas manden.** Verdes, agua y edificios apagados: el color de
   cada línea tiene que ser lo que más se ve. Con los verdes originales, la
   plaza 25 de Mayo le competía al recorrido que pasa por al lado.
2. **Que las calles se lean al sol**, en la parada: bordes de calle marcados
   y nombres oscuros.
3. **Que uno se ubique.** Avenidas blancas; rutas y puente en crema.
4. **Que se vea Ruta Libre.** El oscuro usa el negro de la marca (`#161616`).

Para cambiar un color, se toca `propios` y se regenera (ver abajo). Mirarlo
siempre con una línea de color claro encima (la 9, `#AFB42B`): es la que
primero se pierde.

## Cómo funciona en la app

- `lib/features/transit/data/map/bundled_map.dart` lee el archivo de los
  assets a memoria y se lo da al lector de PMTiles de
  [`flutter_map_vector_tiles`](https://pub.dev/packages/flutter_map_vector_tiles)
  a través de un cliente HTTP falso que contesta pedidos por rango desde esos
  bytes. Así se reusa el lector del paquete, que está probado, sin red.
- `bundledMapProvider` lo carga una vez. Si falla (no debería: son assets),
  queda en `null`, se anota en el diagnóstico, y el mapa vuelve a los tiles
  de OSM por red como en la 1.2.
- `map_screen.dart` pone `VectorTileLayer` con el estilo claro u oscuro según
  el tema.

## Cómo se regenera

Cada tanto (cada 6 meses alcanza, o cuando alguien avise de calles nuevas
que no aparecen) conviene actualizar los datos.

```sh
# 1. La herramienta: go-pmtiles (un binario, sin instalar nada más)
#    https://github.com/protomaps/go-pmtiles/releases

# 2. El recorte. Protomaps publica el planeta entero cada día; `extract`
#    baja solo lo que cae en el rectángulo (unos 5 MB, no el planeta).
#    Las fechas disponibles: https://maps.protomaps.com/builds/
pmtiles extract https://build.protomaps.com/AAAAMMDD.pmtiles \
  assets/map/gran-resistencia-corrientes.pmtiles \
  --bbox=-59.15,-27.62,-58.64,-27.27 --maxzoom=15

# 3. Los estilos, con la MISMA fecha (entra en la identidad del tema).
npm i --no-save @protomaps/basemaps@5.1.0
node tools/mapa/estilo.mjs AAAA-MM-DD

# 4. Los tests: que el archivo cubra las puntas de la red y que los estilos
#    se lean sin avisos.
flutter test test/features/transit/data/map/
```

Si se cambia la versión de `@protomaps/basemaps`, revisar que el archivo y
el estilo sigan siendo compatibles (la versión del esquema de tiles de
Protomaps tiene que coincidir; ver su documentación).

## Licencias

- **Los datos** son de OpenStreetMap, licencia
  [ODbL](https://www.openstreetmap.org/copyright). La app muestra
  "© OpenStreetMap contributors" sobre el mapa, siempre entero.
- **Los estilos** salen de
  [protomaps/basemaps](https://github.com/protomaps/basemaps) (BSD-3), con
  colores propios.
- **El paquete** `flutter_map_vector_tiles` es BSD-3.

## Corregir el mapa

Si falta una calle o un nombre está mal, se corrige en OpenStreetMap
(cualquiera puede, con una cuenta gratis) y aparece en la app en la próxima
regeneración. **Nunca** se copian datos de Google Maps a OSM: su licencia no
lo permite y OSM borra esos aportes.
