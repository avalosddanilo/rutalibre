# Ficha de Google Play — textos listos para pegar

Todo lo de acá va tal cual en Play Console. Los límites de caracteres son los
de Google y están verificados: hay un test que los cuenta
(`test/store/listing_test.dart`), así que si alguien alarga un texto de más, el
CI lo dice antes que el formulario.

**Lo que NO está acá**: las capturas de pantalla, que necesitan el teléfono.

---

## Nombre de la aplicación (máx. 30)

```
Ruta Libre
```

## Descripción corta (máx. 80)

Es lo que se lee en el listado, antes de entrar. Dice la ciudad porque es lo
primero que alguien necesita saber para decidir si la app le sirve.

```
Colectivos del Gran Resistencia y Corrientes: paradas, recorridos y cómo llegar
```

## Descripción completa (máx. 4000)

Empieza por lo que la app contesta, no por lo que la app "es". Y dice lo que
falta: alguien que baja una app de colectivos esperando horarios y no los
encuentra deja una reseña de una estrella, y con razón.

```
Ruta Libre contesta la pregunta con la que uno abre una app de colectivos:
¿cómo llego de acá hasta allá?

Es gratuita, no tiene publicidad, no pide que te registres y funciona sin
señal.

CÓMO LLEGO
Decís a dónde vas y te dice qué colectivo tomar, en qué esquina subir y en
cuál bajar. Con viajes directos y con un transbordo, porque sin transbordos la
respuesta sería "no hay" 6 de cada 10 veces. El origen sale del GPS o lo
escribís vos, así que también podés planificar el viaje desde tu casa la noche
anterior.

Y cuando ya elegiste, "Iniciar viaje" te lleva paso a paso, con el mapa
siguiéndote y un contador en vivo de cuántas paradas faltan para bajarte. Un
paso por pantalla, grande, para leerlo parado en la vereda.

PARA NO QUEDARTE DORMIDO
La alarma "avisame para bajar": la pantalla no se apaga y, dos paradas antes
de la tuya, suena el tono de alarma del teléfono —aunque esté en silencio— y
vibra hasta que la apagues. Para el que viaja cansado, que somos todos.

BUSCÁ POR LUGAR, POR CALLE O POR DIRECCIÓN
El hospital, la escuela, el shopping, la plaza. Y tu casa: escribís "9 de
Julio 1260" y cae en la cuadra real. Miles de lugares, calles y números de
puerta vienen adentro de la app, así que se buscan sin señal desde que la
instalás.

EL MAPA
Las paradas se ven de entrada, sin pedirte el GPS ni obligarte a elegir una
línea. Tocás cualquiera y te dice qué colectivos pasan por ahí y a cuánto
llegás caminando. Elegís una línea y ves su recorrido dibujado.

1474 paradas y 133 recorridos del Gran Resistencia, y las 254 paradas de
Corrientes capital con las líneas que paran en cada una.

CUÁNTO SALE
La tarifa de cada línea, siempre con la fecha desde la que rige y con la
fuente al lado. Un precio sin fecha es peor que no tener precio.

EL RESTO
- Paradas cerca tuyo, con la distancia real en metros
- Cartel para el chofer: el número de la línea a toda pantalla y brillo, para
  parar el colectivo de noche
- El viaje sobrevive a cerrar la app: al reabrir te ofrece retomarlo
- Favoritos: la línea y la parada de todos los días quedan a mano
- Aviso de lluvia, con la probabilidad para tu zona
- Modo oscuro
- Abre al instante: los datos quedan guardados en el teléfono

QUÉ FALTA, DICHO DE FRENTE
Los horarios no los publica ninguna fuente abierta. Están cargados los de un
solo ramal (904A, Terminal Resistencia - Campus UNNE) y los transcribimos de
lo que publicó la empresa, sin poder confirmarlos. Para los tres ramales del
904 sí se muestra la frecuencia que fija la norma de su permiso: cada cuánto
tiene que pasar, citando la resolución.

Preferimos decir "no sabemos" antes que inventar un horario. Un horario
inventado manda a alguien a esperar un colectivo que no viene.

Dentro de Corrientes capital todavía no se puede planificar un viaje: el
municipio publica 10 de las 22 líneas que circulan, y con media red la
respuesta sería adivinada. Está pedido.

DE DÓNDE SALEN LOS DATOS
Los recorridos y las paradas son de OpenStreetMap, mapeados por la comunidad,
bajo licencia ODbL. Los recorridos de Corrientes salen del portal de datos
abiertos de la Municipalidad de la Ciudad de Corrientes. Si encontrás una
parada que ya no existe, la app te deja abrirla en OpenStreetMap para
corregirla: el mapa es de todos.

TU PRIVACIDAD
No hay cuentas ni registro. No hay publicidad ni rastreadores. No medimos qué
pantallas mirás. Tu ubicación se usa solo cuando hacés algo que la necesita, y
no se guarda en ningún servidor. Los favoritos y los últimos destinos viven en
tu teléfono y no salen de ahí.

Hecha en Resistencia, Chaco.
```

## Novedades de esta versión (máx. 500)

```
Primera versión.

Mapa con las paradas visibles de entrada, buscador por lugar, calle y
dirección con altura ("9 de Julio 1260"), "¿cómo llego?" con transbordos, guía
paso a paso con contador de paradas en vivo y alarma para no quedarte
dormido. Tarifas con fecha y fuente. Horarios del 904A y frecuencia regulada
del 904.

Sin publicidad, sin cuenta y funciona sin señal.
```

---

## Campos de selección

| Campo | Valor |
|---|---|
| Categoría | Mapas y navegación |
| Etiquetas | Transporte público, Mapas, Viajes |
| Correo de contacto | avalosdanilonicolas@gmail.com |
| Sitio web | *(opcional)* la URL de la política de privacidad |
| Clasificación de contenido | Sin contenido sensible — ver el cuestionario |
| Anuncios | **No contiene anuncios** |
| Compras en la app | **No** |

Para el formulario de **Seguridad de los datos** y el resto del proceso, ver
[`publicacion.md`](publicacion.md).

---

## Por qué la descripción dice lo que falta

Es contraintuitivo para una ficha de tienda, pero es lo que más cuida la
reputación de la app: quien la baja esperando la tabla de horarios de su línea
y no la encuentra deja una estrella y no vuelve. Diciéndolo antes, el que la
instala sabe qué está bajando — y el que necesitaba horarios no la instala y no
se enoja.

Es la misma regla que la app aplica adentro: cada dato con su fecha y su
fuente, y "no sabemos" cuando no se sabe.
