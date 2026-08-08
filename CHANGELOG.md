# Changelog

Formato basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/).
Versionado según [SemVer](https://semver.org/lang/es/).

## [1.0.0] — sin publicar

Primera versión. Transporte público del **Gran Resistencia** (Chaco) y
**Corrientes capital**, con datos reales, sin publicidad y sin cuenta.

### Mapa y recorridos

- Mapa de OpenStreetMap con el crédito de la licencia ODbL siempre visible.
- **Las paradas se ven de entrada**, sin pedir el GPS ni elegir una línea: el
  mapa nunca arranca vacío.
- Trazado de cada recorrido con halo blanco, para que se lea sobre calles
  claras y oscuras, y encuadre automático al elegirlo.
- Paradas como pines tocables, con las **cabeceras marcadas** y
  descongestionado por zoom: encuadrado entero se ven ~15 de las 47 de un
  recorrido, y todas a partir del zoom 16. Nada se pierde, se acerca y aparecen.

### Buscar

- **Buscador de líneas** por número, barrio o **destino**, ignorando tildes:
  "peron" encuentra "Barrio Perón".
- Líneas agrupadas por red: Gran Resistencia, Interurbano Chaco,
  Chaco ↔ Corrientes y Corrientes capital.
- **Buscador de destino** sobre una copia local de las 1474 paradas: responde
  por tecla y **funciona sin señal**, que es donde se usa.

### Viajes

- **"¿Cómo llego?"**: de dónde estás a dónde vas, con viajes directos y de un
  transbordo. Sin transbordos la respuesta sería "no hay" 6 de cada 10 veces.
- Una opción por línea, no por ramal: el pasajero piensa en "la 9".
- El destino es **cualquier punto del mapa**, no solo una parada.
- **Compartir el viaje** por donde sea, con enlace al destino en OpenStreetMap.

### Paradas

- **"¿Qué colectivos pasan por acá?"** tocando cualquier parada.
- **"A cuánto llego caminando"** desde tu ubicación, con distancia y tiempo
  estimado.
- **"¿Cómo llego acá?"** para planificar el viaje hasta esa parada.
- **Cerca mío** por GPS, con la distancia real calculada en el servidor.

### Horarios

- Por tipo de día, con los **feriados argentinos** resueltos solos (incluye los
  movibles por computus) y la próxima salida resaltada, refrescada por minuto.
- **Cartel de "sin confirmar"**: los horarios se transcriben de lo que publican
  las empresas y no están verificados con ellas.
- Cargados los de la **904A** (Terminal Resistencia ↔ Campus UNNE Corrientes).
  El resto de las líneas todavía no tiene horarios: no hay fuente pública.

### Otras

- **Buscá por LUGAR, no por esquina**: el hospital, la escuela, el shopping,
  la plaza. 2612 lugares del Gran Resistencia empaquetados con la app, así
  que anda sin señal desde la instalación. Los lugares y las paradas salen en
  una sola lista, ordenada por qué tan bien coincide con lo que escribiste.
- **Tipografía propia** (Inter): elegida por los números, que es casi todo lo
  que la app muestra de reojo.
- **Aviso por lluvia**: un chip chico arriba a la izquierda del mapa con la
  probabilidad de lluvia. Tocándolo cuenta que con lluvia suele haber menos
  unidades y demoras. El reclamo se gradúa con la intensidad —una llovizna no
  afirma que haya menos coches— y nunca dice cuántos hay *ahora*: esa fuente
  no existe. Si no llueve, el chip no aparece.
- Modo oscuro.
- **Arranque instantáneo**: todo lo estático se guarda en el teléfono, así que
  a partir de la segunda vez la app abre sin esperar la red.

### Datos

- **1474 paradas, 133 recorridos y 32 líneas** de OpenStreetMap y del portal
  de datos abiertos de la Municipalidad de Corrientes.
- Las paradas que OSM no declara se **infieren de la geometría** del recorrido
  y del lado de la calle: 2638 inferidas contra 3261 declaradas.
- Paradas duplicadas unificadas (una parada física, un solo registro).

### Se sabe que falta

- **Horarios de casi todas las líneas.** No los publica ninguna fuente abierta;
  el pedido formal está en `docs/propuesta-datos-abiertos.md`.
- **Paradas de Corrientes capital**: solo hay trazados, el portal dio de baja
  ese recurso.
- Las paradas que ya no existen en la realidad pero OSM todavía mapea son
  indistinguibles de las vigentes.
- Los tiles del mapa se ven claros también en modo oscuro.

[1.0.0]: https://github.com/rutalibre/rutalibre/releases/tag/v1.0.0
