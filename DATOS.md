# Licencia de los datos

**El código es AGPL-3.0 (ver `LICENSE`). Los datos NO.** Son de otra licencia, con
otro dueño, y la atribución es obligatoria — no es una cortesía.

## OpenStreetMap — ODbL 1.0

Los recorridos, las paradas, las calles y los ~58.000 números de puerta salen
de **OpenStreetMap**, y están bajo la
[Open Database License (ODbL) 1.0](https://opendatacommons.org/licenses/odbl/1-0/).

> © Colaboradores de OpenStreetMap

Qué implica, en concreto:

- **Atribuir.** La app lo hace en la pantalla de información y este archivo lo
  hace en el repo.
- **Compartir igual.** Si alguien toma esta base de datos, la modifica y la
  distribuye, la versión modificada también va bajo ODbL.
- **La ODbL cubre la BASE DE DATOS, no el código.** Por eso van separadas:
  son dos licencias con dos alcances distintos, y una versión comercial del
  código (ver `LICENCIA-COMERCIAL.md`) **no** incluye ni puede relicenciar
  los datos de OSM.

## Municipalidad de Corrientes — datos abiertos

Los itinerarios y las paradas de Corrientes capital salen del portal de datos
abiertos del municipio. El servicio WMS declara `AccessConstraints: NONE` y
`Fees: NONE`.

## De dónde NO salen

⚠️ **Ningún dato de este repo se trazó mirando Google Maps**, y no se puede
hacer. Viola los términos de Google y contamina el dataset de OpenStreetMap
para todo el mundo. Las únicas fuentes válidas para aportar un recorrido son
un GPX propio o las imágenes que el editor iD habilita.

## Horarios

Los horarios cargados son los publicados por las empresas y **no están
confirmados con la fuente oficial**. La app lo dice donde se muestran: si un
dato no está verificado, se avisa en vez de estimarlo.
