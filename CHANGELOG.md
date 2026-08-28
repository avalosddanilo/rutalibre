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
- **Las 254 paradas de Corrientes capital**, con su esquina y las 22 líneas que
  paran en cada una. Se dibujan con un marcador **hueco**, distinto del de las
  del Gran Resistencia, porque hacen algo distinto: abren una hoja corta que
  dice qué líneas paran ahí y de dónde sale el dato. No entran al
  planificador —medido: solo 93 de las 254 caen a menos de 80 m del recorrido
  de su propia línea— y verse iguales haría leer esa diferencia como un bug.

### Buscar

- **Buscador de líneas** por número, barrio o **destino**, ignorando tildes:
  "peron" encuentra "Barrio Perón".
- Líneas agrupadas por red: Gran Resistencia, Interurbano Chaco,
  Chaco ↔ Corrientes y Corrientes capital.
- **Buscador de destino** sobre una copia local de las 1474 paradas: responde
  por tecla y **funciona sin señal**, que es donde se usa.
- **Las calles también se buscan**, rotuladas por localidad: "san juan"
  ofrece la San Juan de Barranqueras Y la del centro de Resistencia, que no
  son la misma calle (~2900 calles de OSM en el mismo asset de lugares).
  Elegir una como destino no adivina el punto: el mapa vuela a la calle y el
  lugar exacto lo marcás vos tocando.
- **Los números de puerta no existen en los datos, y se dice**: "Ameghino
  1250" no muere en "nada coincide" — se busca sin el número y el cartel
  aclara que lo que se muestra son las esquinas y la calle, no esa dirección.

### Viajes

- **"¿Cómo llego?"**: de dónde estás a dónde vas, con viajes directos y de un
  transbordo. Sin transbordos la respuesta sería "no hay" 6 de cada 10 veces.
- Una opción por línea, no por ramal: el pasajero piensa en "la 9".
- El destino es **cualquier punto del mapa**, no solo una parada.
- **El origen no es solo el GPS**: se elige a mano escribiendo el lugar, y se
  puede cambiar sin empezar de nuevo. Así se planifica un viaje desde el
  sillón la noche anterior, y la app contesta igual en un teléfono al que se
  le negó el permiso de ubicación — antes eso terminaba en un cartel de error
  y la pregunta principal quedaba sin respuesta.
- **"Iniciar viaje"**: la guía paso a paso, un paso por pantalla y grande, para
  leerla parada en la vereda con el colectivo viniendo. Caminá hasta tal
  parada, tomá la 3, viajá 14 paradas, bajate, caminá hasta tu destino,
  llegaste. El mapa se mueve a donde hay que mirar en cada paso.
  **No dice minutos**: no sabemos a qué velocidad anda el colectivo, y un
  número ahí hace que alguien se baje antes de tiempo. Los pasos se avanzan a
  mano, no con el GPS: un paso que salta cuando no correspondía es peor que
  ninguno.
- **"Faltan 3 paradas para bajarte", en vivo.** Con la guía abierta, la app
  sigue tu posición y la cuenta contra las paradas en orden del recorrido: es
  geometría, no un horario inventado. Cuando queda una parada —o menos de 250
  metros— el renglón se enciende y el teléfono **vibra una vez**: se acabó
  viajar pegado a la ventanilla contando esquinas. En las caminatas dice los
  metros que faltan, y tu punto azul avanza por el trazado. Tres reglas
  honestas: si no hay GPS no se muestra nada (la guía funciona igual que
  siempre), si tu posición no cae en el tramo el contador **se calla** en vez
  de adivinar, y el seguimiento **muere solo** al cerrar la guía — nunca corre
  de fondo.
- **Alarma "avisame para bajar", por si te dormís.** Pasa de verdad: uno se
  duerme arriba del colectivo y se despierta en la terminal. Con la guía
  andando y el contador en vivo, un interruptor arma la alarma: la pantalla
  deja de apagarse sola y, al entrar en zona de bajada, suena **el tono de
  alarma del sistema en loop por el canal de alarmas** —o sea, aunque el
  teléfono esté en silencio, que arriba del colectivo es exactamente cuándo
  hace falta— con vibración sostenida y la pantalla entera pidiendo bajarse.
  Solo la apaga el botón: una alarma que se apaga rozándola medio dormido no
  despertó a nadie. Es opt-in por viaje y queda armada en los transbordos
  (hay que bajarse dos veces). Su límite honesto: necesita la app abierta —
  la versión que sigue con la pantalla apagada pide un servicio en primer
  plano de Android y queda para la 1.1.
- El mapa dibuja **el camino que hacés vos**, recortado entre la parada donde
  subís y la donde bajás, no el recorrido entero de la línea.
- Al elegir el destino el mapa **se acerca a él** antes de ofrecer los viajes:
  uno eligió un nombre de una lista, y verlo en su cuadra es lo que confirma
  que era ese.
- **Compartir el viaje** por donde sea, con enlace al destino en OpenStreetMap.
- **"¿Y para volver?"**: un toque invierte origen y destino y la lista de
  viajes se recalcula sola. La vuelta puede ser otro colectivo —o el mismo por
  otra calle— y por eso no alcanza con leer la ida al revés.
- **Cartel para el chofer**: esperando el colectivo (y en el transbordo), un
  botón llena la pantalla con el número de la línea en su color. De noche, en
  una parada mal iluminada, la pantalla del teléfono es la superficie más
  brillante de la vereda — y una mano levantada no dice a cuál de los tres
  que vienen le estás haciendo señas.
- **El viaje sobrevive a cerrar la app.** Si Android mata la app —o se apaga
  el teléfono— con la guía andando, al reabrir aparece "Tenías un viaje en
  curso · Retomar": el viaje entero se levanta del teléfono, sin volver a
  consultar a la base y sin señal. Se ofrece hasta tres horas después —ningún
  viaje del Gran Resistencia dura más— y retomar es una decisión tuya, nunca
  automática: la app no puede saber si seguís arriba del colectivo.

### Paradas

- **"¿Qué colectivos pasan por acá?"** tocando cualquier parada.
- **"A cuánto llego caminando"** desde tu ubicación, con distancia y tiempo
  estimado.
- **"¿Cómo llego acá?"** para planificar el viaje hasta esa parada.
- **"¿Ya no existe, o está en otra esquina?"**: un enlace al nodo de la parada
  en OpenStreetMap. Es la única forma real de arreglar una parada que se
  levantó y el mapa todavía dibuja: ningún dato nuestro la distingue de una
  vigente, así que se dice de dónde sale y se deja el camino abierto para
  corregirla. También en las paradas de Corrientes, donde pesa más porque no
  las cruza ningún recorrido nuestro.
- **Cerca mío** por GPS, con la distancia real calculada en el servidor.

### Horarios

- Por tipo de día, con los **feriados argentinos** resueltos solos (incluye los
  movibles por computus) y la próxima salida resaltada, refrescada por minuto.
- **Cartel de "sin confirmar"**: los horarios se transcriben de lo que publican
  las empresas y no están verificados con ellas.
- Cargados los de la **904A** (Terminal Resistencia ↔ Campus UNNE Corrientes).
  El resto de las líneas todavía no tiene horarios: no hay fuente pública.
- **"Cada cuánto pasa"** en los tres ramales del 904, con la norma al lado: el
  pliego que rige el permiso de la línea fija un servicio cada 50 a 100 minutos
  en el ramal A, cada 10 a 12 en el B y cada 12 a 15 en el C, en hora pico.
  Es lo único oficial que existe sobre cuándo pasa el colectivo, y se muestra
  por lo que es: **una obligación de la empresa, no una medición de la calle**,
  y no un horario — no dice a qué hora sale el primero ni qué horas son "pico",
  que la norma no define. Tocándolo se explica entero, con la resolución citada.
  Para las otras 29 líneas no se muestra nada: no hay norma publicada y
  estimarla por el largo del recorrido sería inventar un horario con otro
  nombre.

### Otras

- **Buscá por LUGAR, no por esquina**: el hospital, la escuela, el shopping,
  la plaza. 2612 lugares del Gran Resistencia empaquetados con la app, así
  que anda sin señal desde la instalación. Los lugares y las paradas salen en
  una sola lista, ordenada por qué tan bien coincide con lo que escribiste.
- **Cuánto sale el boleto**, siempre con la fecha desde la que rige y con la
  fuente al lado: $1.885 en el Gran Resistencia y $1.890 en el interurbano,
  salvo el ramal del Campus de la UNNE, que sale $2.921,10 —un 55% más— y por
  eso se muestra aparte. Donde no hay dato confirmado no se muestra nada: un
  precio "aproximado" es peor que ninguno cuando alguien llega a la máquina
  con la plata contada.
- **Favoritos y últimos destinos**: estrella en cada línea y en cada parada.
  Las líneas marcadas quedan **fijadas arriba** del panel, y el buscador de
  destino abre con lo guardado y los últimos ocho lugares en vez de un cartel.
  Nada de esto sale del teléfono.
- **Tipografía propia** (Inter): elegida por los números, que es casi todo lo
  que la app muestra de reojo.
- **Aviso por lluvia**: un chip chico arriba a la izquierda del mapa con la
  probabilidad de lluvia. Tocándolo cuenta que con lluvia suele haber menos
  unidades y demoras. El reclamo se gradúa con la intensidad —una llovizna no
  afirma que haya menos coches— y nunca dice cuántos hay *ahora*: esa fuente
  no existe. Si no llueve, el chip no aparece.
- Modo oscuro.
- **Arranque instantáneo**: todo lo estático se guarda en el teléfono, así que
  a partir de la segunda vez la app abre sin esperar la red. Y **dice de cuándo
  son esos datos** al pie del panel: es lo que hace que la app ande sin señal,
  pero también significa que lo que estás mirando puede tener semanas, y sin la
  fecha un recorrido viejo y uno de hoy se ven igual.
- Lo guardado **se refresca solo** cuando pasa una semana: se sigue mostrando la
  copia al instante y la actualización baja de fondo para la próxima vez. Antes
  la copia no se renovaba nunca, así que corregir un dato exigía publicar una
  versión de la app.

### Datos

- **1474 paradas, 133 recorridos y 32 líneas** de OpenStreetMap y del portal
  de datos abiertos de la Municipalidad de Corrientes.
- Las paradas que OSM no declara se **infieren de la geometría** del recorrido
  y del lado de la calle: 2638 inferidas contra 3261 declaradas.
- Paradas duplicadas unificadas (una parada física, un solo registro).
- Aparte de esas, **254 paradas de Corrientes capital** y **2612 lugares** del
  Gran Resistencia van empaquetados con la app: andan sin señal desde la
  instalación y no dependen de la base.

### Se sabe que falta

- **Horarios de casi todas las líneas.** No los publica ninguna fuente abierta;
  el pedido formal está en `docs/propuesta-datos-abiertos.md`.
- **"¿Cómo llego?" no funciona dentro de Corrientes capital.** Las paradas se
  ven y se puede consultar qué líneas paran en cada una, pero no se puede
  planificar un viaje: el dataset municipal publica 10 de las 22 líneas que
  circulan, y sin la red completa la respuesta sería adivinada. Los 12 códigos
  que faltan están pedidos en `docs/mails-para-mandar.md`.
- Las paradas que ya no existen en la realidad pero OSM todavía mapea son
  indistinguibles de las vigentes. Ahora se pueden corregir en OSM desde la
  app, pero el cambio recién se ve cuando reimportamos los datos: no hay
  reportes dentro de la app todavía.
- Los tiles del mapa se ven claros también en modo oscuro.

[1.0.0]: https://github.com/avalosddanilo/rutalibre/releases/tag/v1.0.0
