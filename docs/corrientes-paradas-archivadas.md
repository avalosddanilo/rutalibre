# Las paradas de Corrientes que el municipio dio de baja

**Existen, están completas, y siguen siendo válidas.** Este documento es el
hallazgo y la evidencia; la decisión de usarlas o no está al final y **no
está tomada**.

## Qué apareció

`docs/osm-import.md` decía, desde el principio: *"Sin paradas: ese recurso
fue dado de baja del portal"*. Es cierto hoy, pero el recurso **estuvo**
publicado y el Internet Archive lo tiene.

```
https://web.archive.org/web/20220625135303id_/https://datos.ciudaddecorrientes.gov.ar/dataset/bd941d41-8906-4494-9e31-135d4c309de2/resource/a8d8893c-4e50-497f-85e8-4e57de960e2c/download/paradas-colectivos.csv
```

Fijate el id del dataset: `bd941d41-…` es **el mismo** del que sale hoy la
geometría de los recorridos. Son las paradas oficiales que acompañaban a
esos recorridos.

| | |
|---|---|
| Paradas | **1437** |
| Ramales | **28** (entre 60 y 137 paradas cada uno) |
| Columnas | `gid`, `tipo_recorrido` (IDA/VUELTA), `cantidad_paradas`, `linea_ramal`, `lng`, `lat` |
| Proyección | **WGS84 directo** — no hay que reproyectar nada |
| Foto del | 2022-06-25 |

Para comparar: OpenStreetMap tiene **254** paradas en Corrientes. Esto es
**5,6 veces más**, y con el ramal y el sentido de cada una.

**Incluye el 110B**, que es el único ramal que ni el dataset de recorridos ni
el sitio de itinerarios cubrían.

Y los nombres de ramal **coinciden con los del seed actual**:
`105-C-250VIV` ↔ `C 250 VIV.`, `109-B-YECOHA` ↔ `B YECOHA`,
`103-C-ESPERANZA-MONTAÑA` ↔ `C Bo ESPERANZA Bo DR. MONTAÑA`.

## La pregunta importante: ¿2022 sigue sirviendo en 2026?

Los recorridos que usa la app se extrajeron el **2026-08-05**. Las paradas
son de **2022-06-25**. Cuatro años de diferencia es motivo suficiente para
desconfiar, así que se midió cada parada contra la geometría actual de su
propia línea, punto a segmento.

**2492 pares (parada, línea): mediana de 5 metros. 96 % a menos de 80 m.**

Por ramal, 24 de 28 dan 96-100 % a menos de 80 m con medianas de 2 a 8
metros. Las paradas de 2022 caen **arriba** de los recorridos de 2026.

### La única anomalía, y por qué no es un problema

`108-A-B` da mediana de 396 m y solo 30 % cerca. No es que el dato esté mal:
**el seed solo tiene el 108 ramal C**. Esas 122 paradas son de los ramales A
y B, y se midieron contra la única geometría que hay, que es la de otro
ramal. Es el mismo agujero que ya conocíamos, visto desde el otro lado.

## Lo que esto desbloquearía

Con 1437 paradas oficiales, con ramal y sentido, **el planificador en
Corrientes capital pasa de imposible a posible**. El motivo que hoy lo
bloquea —cobertura despareja, ver `test/tools/corrientes_cobertura_test.dart`—
deja de aplicar: acá no hay líneas con una parada en doce kilómetros.

Faltaría **ordenar las paradas sobre el recorrido**, que es exactamente lo
que ya hace `tools/osm_import.dart` para el Gran Resistencia proyectándolas
sobre el trazado cosido. El problema ya está resuelto una vez.

## ⚠️ Por qué esto NO se hizo todavía

Tres reparos, y ninguno es técnico:

1. **El municipio lo dio de baja.** Que un organismo retire un recurso es una
   señal, y no sabemos de qué. Puede ser una migración de portal, puede ser
   que lo consideraran desactualizado. Usar un dato que el propio publicador
   sacó de circulación merece preguntarle primero — sobre todo cuando la
   medición de arriba sugiere que está perfectamente vigente y el retiro
   parece administrativo.
2. **Sigue sin declarar licencia**, igual que todo lo del portal. Que esté en
   el Internet Archive no cambia eso: el archivo conserva el dato, no le
   inventa una licencia.
3. **Es de 2022.** La medición dice que sirve, pero lo correcto es pedir la
   versión actual, no consagrar una foto vieja.

Los tres se resuelven con **el mismo mail que ya está pendiente** en
`docs/mails-para-mandar.md`. Conviene sumar, textual:

> Vimos que el recurso de paradas (`paradas-colectivos.csv`) del dataset de
> transporte urbano ya no está en el portal. ¿Sigue vigente? ¿Hay una versión
> actualizada que podamos usar? Y aprovechamos para consultar bajo qué
> licencia se publican los datos del portal, porque no figura.

**Regla del proyecto que aplica**: pedirlo antes de usarlo no es burocracia.
Es la misma razón por la que no se traza desde Google Maps.

## Cómo reproducir todo esto

El CSV **no se commitea** a propósito: es un recurso retirado y sin licencia
declarada. Se baja cuando se necesita:

```bash
curl -sSL -o paradas_ctes.csv \
  "https://web.archive.org/web/20220625135303id_/https://datos.ciudaddecorrientes.gov.ar/dataset/bd941d41-8906-4494-9e31-135d4c309de2/resource/a8d8893c-4e50-497f-85e8-4e57de960e2c/download/paradas-colectivos.csv"
```

La medición de distancias se hace igual que en
`test/tools/corrientes_cobertura_test.dart`: parsear las `LINESTRING` del
seed y usar `distanceToSegmentMeters` de `tools/src/geometry.dart`. **Punto a
segmento, no al vértice** — medir contra vértices es el error que ya nos hizo
escribir un número equivocado una vez.

## De yapa: Barranqueras y Sarmiento

En el mismo portal, archivadas, hay dos cosas más que no son de Corrientes:

| Archivo | Qué es | Foto del |
|---|---|---|
| `vw_paradas_barranqueras_*.csv` + `vw_recorrido_barranqueras_*.csv` | Paradas y recorrido de **Barranqueras (Chaco)**, con sentido y ubicación en texto | 2026-01 (datos 2025-10) |
| `paradas_sarmiento.csv` + `recorridos_sarmiento.csv` | La línea **Sarmiento**, que cruza a Chaco (aparece "Bº San Pedro Pescador, Chaco") | 2022-06 |

Son chicos (148 y 33 paradas) y del lado del Gran Resistencia, donde ya
tenemos cobertura de OSM. Quedan anotados por si sirven para contrastar.
