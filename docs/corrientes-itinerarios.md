# Itinerarios oficiales de Corrientes capital

Las calles por las que pasa cada ramal, **según la propia Municipalidad**.

**Fuente**: Municipalidad de la Ciudad de Corrientes,
`https://ciudaddecorrientes.gov.ar/content/linea-<línea>-ramal[-<letra>]`
(la página sin letra es el **Ramal A**).
**Bajado el 2026-09-21.** Transcripción textual, sin corregir.

## Por qué esto importa

`tools/corrientes_import.dart` trae del portal de datos abiertos la
**geometría** de 10 líneas / 60 recorridos. Pero las 254 paradas que OSM
tiene mapeadas en Corrientes mencionan **22 códigos de línea**, y de los 13
que quedaban sin recorrido, **12 tienen su itinerario publicado acá**:

| | |
|---|---|
| Ramales con itinerario en el sitio | 24 |
| De los 13 sin geometría, cubiertos | **12** — 103A, 103B, 104A, 104C, 104D, 105A, 105B, 105C, 106C, 108A, 110A, 110C |
| Sin cubrir | **110B** |

## Qué desbloquea, y qué no

**Lo que NO es**: geometría. Son nombres de calle, no coordenadas. Convertir
una lista de calles en un trazado dibujable exige rutear sobre el callejero y
es exactamente la clase de proceso que se equivoca **en silencio**: sale una
línea dibujada, parece correcta, y va por donde no va.

**Para lo que SÍ sirve, y es lo que más vale**: es la fuente legítima para
**mapear estos recorridos en OpenStreetMap**. Es una publicación oficial de
la Municipalidad — no es Google Maps —, así que usarla para trazar en OSM
está permitido y es lo que hace cualquier mapeador. Y una vez en OSM, el
recorrido le llega a todo el mundo y vuelve solo en la próxima importación,
que es la regla del proyecto (ver `docs/osm-import.md`).

**El uso inmediato y sin riesgo**: contestar "¿por qué calles pasa la 104C?"
con la lista textual y la fuente al lado. Es verdad, es citable, y no
requiere dibujar nada.

## Lo que hay que tener en cuenta al usarlos

- **El original tiene erratas.** Se transcriben tal cual: *"Alberbi"* por
  Alberdi, *"Indenpendencia"*, *"Paisandú"* y *"Paysandú"* en la misma
  línea, *"Sarsfie"* cortado. Corregirlas acá sería inventar; se corrigen al
  trazar, con criterio y dejando constancia.
- **"Calles internas del barrio X" no es una calle.** Aparece en varios
  ramales (Bº Montaña, Esperanza, 250 viviendas, 550 viviendas, 40 viv.).
  Eso no se puede rutear: hay que ir a ver, o preguntar.
- **El 101 Ramal B está cortado en el propio sitio** — el texto termina en
  "PAPA" y "9 DE". No es un error de la transcripción.
- **El 105 Ramal C trae dos itinerarios** en la misma página (barrio 250
  viviendas y barrio Perichón).
- **Los nombres de ramal del sitio no siempre coinciden con los de OSM.** El
  sitio usa A/B/C/D; OSM tiene códigos como `110A`, `110B`, `110C`. Antes de
  dar por equivalente un ramal, comparar el itinerario con las paradas que
  OSM le asigna.

## ⚠️ Licencia

**El sitio no declara licencia**, igual que el portal de datos abiertos (ver
`docs/osm-import.md` → Licencia). Se atribuye la fuente en todos lados y
**queda pendiente confirmarlo con la Municipalidad**. Conviene sumarlo al
mismo pedido que ya está escrito en `docs/mails-para-mandar.md`, junto con el
reclamo por el recurso de paradas que dieron de baja.

---

## Los itinerarios

### 101 — Ramal B
`https://ciudaddecorrientes.gov.ar/content/linea-101-ramal-b`
- **IDA:** RUTA 12 Y AV..RAUL ALFONSIN - CRUCERO GRAL. BELGRANO-PAPA
- **VUELTA:** PUERTO- COSTANERA GRAL SAN MARTIN- TUCUMAN - 9 DE

### 101 — Ramal C
`https://ciudaddecorrientes.gov.ar/content/linea-101-ramal-c`
- **IDA:** Ruta 12 - Av. Centenario - Crucero Gral. Belgrano - Papa Juan Pablo II - Pacheco - Ponce - Lucía y Soto - Ruta 12 - Riachuelo - Rotonda - Ruta 12 - Av. Centenario - Laprida - Laferrere - Laprida - Av. Centenario - Av. Chacabuco - Belgrano - España - San Martín - Buenos Aires - Av. Costanera - Puerto.
- **VUELTA:** Puerto - Salta - 9 de Julio - Santa Fe - Irigoyen - Av. Centenario - Laprida - Laferrere - Laprida - Av. Centenario - Ruta 12 - Crucero Gral. Belgrano - Papa Juan Pablo II - Pacheco - entrada al Ponce - salida por Lucía y Soto - Ruta 12 - Riachuelo.

### 102 — Ramal A
`https://ciudaddecorrientes.gov.ar/content/linea-102-ramal`
- **IDA:** Av. Peron - Ruta 12 - Rotonda - Av. Indenpendencia - Av. Ferre - Av. 3 de abril - La Rioja - Puerto
- **VUELTA:** Puerto - Costanera - Tucuman - 9 de Julio - Santa Fe - H. Irigoyen - Av. Artigas - Av. Ferre - Av. Independencia - Napoles - Av. Peron - Sanchez de Bustamante

### 102 — Ramal B
`https://ciudaddecorrientes.gov.ar/content/linea-102-ramal-b`
- **IDA:** Pitágoras-Medrano-Larrea-Hawái-Las Piedras-Larrea-W. Domínguez-Cazadores Correntinos-Chacabuco-Av. Ferre -Av. 3 de abril-La Rioja-Puerto.
- **VUELTA:** Puerto-Av. Costanera-Tucuman-9 de Julio-Santa Fe-Av.3 de abril-Av. Ferre-Chacabuco-Cazadores Correntinos- W. Domínguez. -Pitágoras.

### 102 — Ramal C
`https://ciudaddecorrientes.gov.ar/content/linea-102-ramal-c`
- **IDA:** Castor de León - 6 de Mayo - Mocito Acuña - Moray - Gral. Madariaga - 6 de Mayo - Mocito Acuña - Ruta Nº5 - Rotonda - Av. Independencia - Av. Ferré - Av. 3 de abril - La Rioja - Plácido Martínez.
- **VUELTA:** Placido Martínez - Córdoba - 9 de Julio - Santa Fe - Av. 3 de abril - Av.Independencia - Rotonda - Ruta Nº5 - Castor de León.

### 103 — Ramal A
`https://ciudaddecorrientes.gov.ar/content/linea-103-ramal`
- **IDA:** Av. Alta Gracia y Los Atacamas, por Av. Alta Gracia -Paysandú-W. Domínguez-Bonastre-Ibera-Paysandú-Rafaela-Av. Estrada-Av. Sarmiento-Av. 3 de abril- España-C Pellegrini-Catamarca-Av. Vera-Puerto.
- **VUELTA:** Puerto-Salta-h. Yrigoyen-Santa Fe-Gutenberg-Ciudad de Arequipa-Casquín-Av. La Paz- Av. Patagonia-Paysandú-Ibera-Bonastre–W.Dominguez-Paysandú-Av. Alta Gracia hasta Los Atacamas.

### 103 — Ramal B
`https://ciudaddecorrientes.gov.ar/content/linea-103-ramal-b`
- **IDA:** De Aguirre y Larratea, calles internas del Bº Dr. Montaña, Larratea, Av. Maipú-España, C. Pellegrini, Catamarca, Av. Vera, Puerto.
- **VUELTA:** Puerto-Salta-H. Yrigoyen-Santa Fe- av. Maipú- Larratea, Aguirre. Para los articulados, liberar los giros de C. Pellegrini / Catamarca - Catamarca/Av. Vera .

### 103 — Ramal C
`https://ciudaddecorrientes.gov.ar/content/linea-103-ramal-c`
- **IDA:** calles internas del barrio Esperanza, sale por calle principal, Av. Maipú, España- C. Pellegrini - Catamarca-Av. Vera - Puerto
- **VUELTA:** Puerto-Salta-H. Yrigoyen-Santa Fe- Av. Maipú, calle de acceso del barrio Esperanza, calles internas.

### 103 — Ramal D
`https://ciudaddecorrientes.gov.ar/content/linea-103-ramal-d`
- **IDA:** calle acceso a Riachuelo - Ruta Nº12 - Av. Maipú - España - C.Pellegrini - La Rioja - Puerto.
- **VUELTA:** Puerto - Salta - H. Irigoyen - Santa Fe - Av. Maipú - Ruta Nº12 - Acceso a Riachuelo.

### 104 — Ramal A
`https://ciudaddecorrientes.gov.ar/content/linea-104-ramal`
- **IDA:** Tte. Ibáñez -Elías Abad-Alberdi-Gutnisky- Juan de Garay- Av. IV Centenario- Colon-Hernandarias-Guastavino-Av. 3 de abril-Buenos Aires- Costanera. Av. Vera-Baibiene-Gdor. López-Cabral- Vélez Sarsfield –A. Justo
- **VUELTA:** A. Justo- Av. Pujol-Paraguay-C. Pellegrini-Salta-Rivadavia-Entre Ríos-Av.3 de abril-Alberdi –Tte. Ibáñez.

### 104 — Ramal B
`https://ciudaddecorrientes.gov.ar/content/linea-104-ramal-b`
- **IDA:** J.R.Vidal y Estocolmo - J.de Garay - Gutnisky - Alberdi - Elías Abad - Av. 3 de abril - San Luis - Rivadavia - Misiones - H.Irigoyen.
- **VUELTA:** España - C.Pellegrini - Salta - San Martín - Chaco - Av. 3 de abril - B. de la Vega - Tte. Ibañez - Elías Abad - Alberdi - Gutnisky - J. de Garay - J.R.Vidal hasta Estocolmo.

### 104 — Ramal C
`https://ciudaddecorrientes.gov.ar/content/linea-104-ramal-c`
- **IDA:** Alta Gracia-Paysandú-W. Domínguez-Igarzabal-Ibera-Paysandu-Rafaela-Taraguí-Av. IV Centenario-Pio XII - Lavalle-Vargas Gómez-Catamarca-Av. Vera-Av. Pujol-Gdor. Pampin-Sargento Cabral-Vélez Sarsfield-Gdor. Ruiz-Félix de Azara-R. Obligado.
- **VUELTA:** R. Obligado-Tellier-Mar del Plata-Zacarías Sánchez -Gdor. Ruiz-Santiago del Estero- J. M. Rolón- Vélez Sarsfield-Sargento Cabral-Gdor Lagraña- JM. Rolón-Av. Pujol-Santa Fe-C. Pellegrini-Salta-Av. 3 de abril- J.R. Vidal-Tte. Ibáñez-Av. Del IV centenario-Ibera-Igarzabal-W Domínguez-Juan de O. Gómez- W Domínguez-Paysandú-Alta Gracia.

### 104 — Ramal D
`https://ciudaddecorrientes.gov.ar/content/linea-104-ramal-d`
- **IDA:** Gutenberg y Cosquín-Paysandú-Rafaela-Av. Del Maestro-Santa Cruz av. Sarmiento-Tte. Cundom- Vargas Gómez-Av. Tte. Ibáñez-Pío XII- Lavalle-Vargas Gómez-Catamarca-Av. Vera-Av. Pujol-Gdor. Pampin-Sargento Cabral-Vélez Sarsfield-.
- **VUELTA:** Vélez Sarsfield-Dr. Felipe Cabral-Santiago del estero-J.M Rolón- Vélez Sarsfield-Sargento Cabral-Gdor. Lagraña- J.MRolónn-Av. Pujol Santa Fe-C Pellegrini-Salta-Av. 3 de Abril-J.R. Vidal-Tte. Ibáñez- Gutenberg-Cosquín.

### 105 — Ramal A
`https://ciudaddecorrientes.gov.ar/content/linea-105-ramal`
- **IDA:** Punta Vidal (Las Dalias) - Bella Vista - Las Gardenias - Av. Libertad - Av. Armenia - Av. Gdor. Ruíz - 19 de mayo - Gregorio Pomar - Av. Centenario - Av. Chacabuco - San Martín - La Rioja - Puerto.
- **VUELTA:** Puerto - Salta - H.Irigoyen - Ayacucho - Av. Centenario - Gregorio Pomar - Virasoro (Rizzuto) - Av. Armenia - Av. Libertad - Las Gardenias - Nity Cigersa - Punta Vidal (Las Dalias).

### 105 — Ramal B
`https://ciudaddecorrientes.gov.ar/content/linea-105-ramal-b`
- **IDA:** Las Margaritas - Calle 32 - Pasionarias - Murcia - Sicilia - Badajos - Argerich - Sheridan - Río Chico - J.R. Fernández - Av. Armenia - Av. Gdor. Ruíz - Cocomarola - Ituzaingo - San Martín - La Rioja - Pueto.
- **VUELTA:** Salta - H.Irigoyen - Ayacucho - Chacabuco - Av. Armenia - J.R.Fernández - Río Chico - Benavidez - Argerich - Murcia - Pasionarias - Calle Nº314 - Las Margaritas - Empedrado.

### 105 — Ramal C
`https://ciudaddecorrientes.gov.ar/content/linea-105-ramal-c`
- **IDA:** calles internas del barrio 250viv.-Rio Chico- Ruta nº 12-Av. libertad-av. Armenia–Gdor. Ruiz- C. Pellegrini--Catamarca-Av. Vera-Puerto.
- **IDA:** calle principal del barrio Perichón - Ruta Nº 12 - Río Chico - calles internas del barrio 250 viviendas - Río Chico - Av. Libertad - Av. Armenia - Av. Gobernador Ruíz - Pellegrini - Catamarca - Av. Vera - La Rioja - Puerto.
- **VUELTA:** Puerto-Salta-H. Yrigoyen-Gral. Roca-9 de Julio-Av. Gdor. Ruiz-Av. Armenia-Av. Libertad-Ruta Nº 12-Rio Chico- calles internas del barrio 250viv.
- **VUELTA:** Puerto - Salta - H. Irigoyen - Roca - Gobernador Ruíz - Av. Armenia - Av. Libertad - Ruta Nº 12 - Río Chico - calles internas del barrio 250 viviendas - Río Chico - Ruta Nº 12 - acceso principal al bº Perichón.

### 106 — Ramal A
`https://ciudaddecorrientes.gov.ar/content/linea-106-ramal`
- **IDA:** Cuba-Trento- Túpac Amarú - Ruta Nº 12 - Av. Perón - Medrano - Av. Independencia - Av. Ferré - Av. 3 de abril - Catamarca - Av. Vera - Puerto.
- **VUELTA:** Puerto - Costanera - Tucumán - 9 de Julio - Santa Fe - Av. 3 de abril - Av. Ferré - Av. Independencia - Rotonda - Ruta Nº 12 - Tupac Amaru - Trento - Cuba.

### 106 — Ramal B
`https://ciudaddecorrientes.gov.ar/content/linea-106-ramal-b`
- **IDA:** Sánchez de Bustamante y Suecia - Ramos Mejía - Tupac Amaru - Sánchez de Bustamante - San Francisco de Asís - Montecarlo - Av. Perón - Gascón - Esmeralda - Montecarlo - Av. Independencia - Av. Ferré - Av. 3 de abril - Catamarca - Av. Vera - Puerto.
- **VUELTA:** Puerto - Costanera - Tucumán - 9 de Julio - Santa Fe - Av. 3 de abril - Av. Ferré - Av. Independencia - Río Juramento - Las Heras - Gascón - Montecarlo - Río de Janeiro - Sánchez de Bustamante - Túpac Amarú - Ramos Mejía - Suecia hasta Sánchez de Bustamante.

### 106 — Ramal C
`https://ciudaddecorrientes.gov.ar/content/linea-106-ramal-c`
- **IDA:** Calles internas del barrio 550 viv.- Frías - Cuba -Turín - San Francisco de Asís - Milán - Av. Perón -Tacuarí - Av. Independencia - Av.Ferré - Av.3 de Abril - Catamarca -Av. Vera - Puerto..
- **VUELTA:** Quintana y Tucuman - 9 de Julio - Santa Fe - Av. 3 de abril - Av. Ferre - Av. Independencia - Güemes - C.Correntinos - Av. Perón - Milán - San Francisco de Asís - Turín - Cuba - Frías - calles internas del Bº 550 viviendas.

### 108 — Ramal A
`https://ciudaddecorrientes.gov.ar/content/linea-108-ramal`
- **IDA:** Av.Cangallo - Av.Frondizi (Medrano) - Loreto - Calle Nº8 - Cuba - Av. Medrano - Larrea - W. Domínguez - Av. C.Correntinos - Av. J.R. Vidal - Av. Chacabuco - Av. Armenia - Av. Gdor. Ruíz - Av. Pujol - Puerto - Costanera - Tucuman - 9 de Julio - Salta - San Martín - Don Bosco - Av. 3 de abril - Cruce bajo el puente - Lavalle y Díaz de Vivar.
- **VUELTA:** Díaz de Vivar y Lavalle - J.R. Vidal - Necochea - Pío XII - Av. 3 de abril - La Rioja - Av. Vera - Av. Pujol - Ayacucho - Av. Chacabuco - Av. J.R. Vidal - Av. C.Correntinos - W. Domínguez - Pitágoras - Frondizi (Medrano) - Cangallo hasta Sánchez de Bustamante.

### 108 — Ramal C
`https://ciudaddecorrientes.gov.ar/content/linea-108-ramal-c`
- **IDA:** calles internas del Bº 40 viv. - Alberto Olmedo - Cangallo - Av. Frondizi (Medrano) - Guayquiraró - calles internas del Bº San Roque - Guayquiraró - Frondizi - Loreto - Calle Nº5 - Cuba - Picasso - Av. J.R.Vidal - Av. Ferre - Av.Artigas - Av. Pujol - Rotonda España - C.Pellegrini.
- **VUELTA:** C.Pellegrini - Salta - H.Irigoyen - La Rioja - 9 de Julio - Rotonda España - Av. Pujol - Av. Artigas - Av. Ferre - Av. J.R.Vidal - Picasso - Cuba - Calle Nº5 - Loreto - Av. Frondizi - Cangallo - Alberto Olmedo hasta las 40 viviendas.

### 109 — Ramal A
`https://ciudaddecorrientes.gov.ar/content/linea-109-ramal`
- **IDA:** Av. Alta Gracia - Av. Maipú - Av. 3 de abril - Catamarca - Bolívar - Gral. Roca - 9 de Julio - Av. Gdor. Ruíz - Av. Armenia - Av. Libertad - Ruta Nº12 - Ruta Prov. Nº 43 - Ruta Prov. Nº 99 calle 20.
- **VUELTA:** Ruta Prov. Nº20 - Ruta Prov.Nº 43 - Ruta Nº12 - Av. Libertad - Av. Armenia - Av. Gdor. Ruíz - C. Pellegrini - Santa Fe - Av. Ferré - Av. Maipú - Av. Alta Gracia.

### 110 — Ramal A
`https://ciudaddecorrientes.gov.ar/content/linea-110-ramal`
- **IDA:** Bº40 viv. - Las Violetas - Av.Libertad - Av.Laprida - Av. Centenario - Av. Chacabuco - Av.J.R.Vidal - Las Heras - Av. Tte. Ibañez - Av.Maipú - Av. El Maestro - Av. Patagonia - Av. Estrada - Av.Tte. Ibañez - Gustavino - Av.3 de abril - Buenos Aires - Bolívar - Rioja - Puerto.
- **VUELTA:** Puerto - Salta - Rivadavia - Entre Rios - Av. 3 de abril - Alberdi - Tte.Ibañez - Elías Abad - Alberdi - Cementerio - Alberdi - La Pampa - Hernandarias - Av. Tte. Ibañez - Av. Estrada - Av.Patagonia - Av. El Maestro - Av. Maipú - Av. Tte. Ibañez - Las Heras - Av.J.R.Vidal - Av. Chacabuco - Av. Centenario - Av. Laprida - Av.Libertad - Las Violetas - 40 viviendas.

### 110 — Ramal C
`https://ciudaddecorrientes.gov.ar/content/linea-110-ramal-c`
- **IDA:** Puerto - Salta - Rivadavia - Entre Ríos - Av. 3 de Abril - Av. Alberdi - Av. Tte. Ibáñez - Av. Sarmiento - Av. Patagonia - Av. Paysandú - Av. Alta Gracia - Av. Maipú - Acceso Santa Catalina – Calle S/N paralela a Nini Flores – Av. Mario Millán Medina – Eustaquio Miño – Av. Mario Millan Medina – Calle S/N paralela a Nini Flores- Pedro Celestino Montenegro – Argentina Rojas – Blas Martínez Riera – Eustaquio Miño – Pedro Celestino Montenegro- Nini Flores
- **VUELTA:** Av. Maipú - Av. Alta Gracia - Av. Paisandú - Rafaela - Av. La Paz - Av. Patagonia - Av. Sarmiento - Tte. Cundom - Vargas Gómez - Av. Tte. Ibañez - Guastavino- Av. 3 de Abril - Buenos Aires - Bolívar - La Rioja

