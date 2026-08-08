# Política de privacidad de Ruta Libre

**Última actualización: 6 de agosto de 2026**

## Lo corto

**Ruta Libre no tiene cuentas, no te registra y no manda tus datos a ninguna
parte.** No hay servidor nuestro que sepa quién sos ni por dónde anduviste.

La app sí guarda algunas cosas **en tu teléfono** para funcionar rápido y sin
señal: los datos del transporte, lo que marcaste como favorito y los últimos
lugares que buscaste. **Nada de eso sale del dispositivo**, y lo borrás cuando
quieras. Está detallado más abajo.

Tu ubicación se usa **solo cuando hacés algo que la necesita**, y no se envía a
nuestros servidores.

## Qué información se usa

### Tu ubicación

**Para qué**: mostrarte las paradas que tenés cerca, calcular a cuánto estás
caminando de una parada, usarla como punto de partida cuando preguntás cómo
llegar a algún lado, y pedir el pronóstico de lluvia de tu zona.

**Cuándo**: para "Cerca mío" y "¿Cómo llego?" la app te pide el permiso y
enciende el GPS. Para la distancia caminando y el aviso de lluvia usa **la
última posición que tu teléfono ya tenía guardada** —no te pide nada ni
enciende el GPS—, y si no hay ninguna, simplemente no muestra ese dato.

Podés usar el mapa, ver los recorridos, las paradas, los horarios y buscar
líneas **sin dar el permiso de ubicación**.

**A dónde va**: no se envía a nuestros servidores para guardarla, no se asocia
a ninguna identidad y no se comparte con nadie.

Dos precisiones que conviene que sepas:

- Para responder "¿qué paradas tengo cerca?" y "¿cómo llego de acá hasta
  allá?", la app le manda **un par de coordenadas** a nuestra base de datos,
  que devuelve las paradas o los recorridos que corresponden. Esas consultas
  **no se asocian a ninguna identidad ni se registran**: no hay cuenta, no hay
  identificador de usuario y no llevamos historial de consultas.
- Para el aviso de lluvia, la app le manda a Open-Meteo **una coordenada
  redondeada a unos 1000 metros** — no tu posición exacta. Esa coordenada
  redondeada **queda guardada en tu teléfono** junto con el pronóstico, para no
  volver a pedirlo cada vez que abrís la app.

## Lo que se guarda en tu teléfono

Todo lo de esta lista vive **únicamente en tu dispositivo**. No se sincroniza,
no se sube a ningún servidor nuestro ni de terceros, y no se incluye en la
copia de seguridad automática de Android.

| Qué | Para qué | Qué contiene |
|---|---|---|
| **Datos del transporte** | Que la app abra al instante y funcione sin señal | Líneas, recorridos, paradas y horarios. Son datos públicos del transporte, no tuyos |
| **Pronóstico de lluvia** | No pedirlo de nuevo cada vez que abrís la app | Las próximas horas de pronóstico y **una coordenada tuya redondeada a ~1 km**, con la hora en que se guardó. Se descarta solo a las pocas horas |
| **Tus favoritos** | Que no tengas que rebuscar la línea o la parada de todos los días | Qué líneas y qué paradas marcaste con la estrella, con el nombre y la ubicación de esas paradas |
| **Tus últimos destinos** | Que no escribas de nuevo el lugar al que vas siempre | **Los últimos 8 lugares** que elegiste como destino, con su nombre y ubicación. Al noveno, el más viejo se borra solo |

**Los últimos dos son datos tuyos, no del transporte**: qué colectivo tomás y a
dónde vas dicen algo sobre vos. Por eso están acá, dichos con todas las letras.
Lo importante es que **nunca salen del teléfono**: no hay a quién mandárselos
porque no hay cuenta ni servidor de usuarios.

**Cómo borrarlos**:

- Los últimos destinos tienen un botón **"Borrar"** dentro de la app, en la
  pantalla de "¿A dónde vas?".
- Los favoritos se quitan tocando la estrella de nuevo.
- Todo junto, de una: desinstalando la app, o desde *Ajustes → Aplicaciones →
  Ruta Libre → Almacenamiento → Borrar datos*.

## Lo que NO se usa

- No hay cuentas ni registro.
- **No se pide ni se guarda tu nombre, correo, teléfono ni ningún dato que
  sirva para identificarte.**
- **No hay publicidad ni rastreadores de terceros.**
- No hay analítica: no medimos qué pantallas mirás ni cuánto usás la app.
- No se accede a tus contactos, fotos, archivos, micrófono ni cámara.
- No hay ningún perfil tuyo en ningún lado: lo que la app guarda no se cruza
  con nada ni se le manda a nadie.

## Servicios de terceros

La app se conecta a estos servicios para funcionar. Cada uno recibe, como
cualquier sitio de internet, la dirección IP desde la que se conecta tu
teléfono:

| Servicio | Para qué | Qué recibe |
|---|---|---|
| **Supabase** | La base con líneas, recorridos, paradas y horarios | Las consultas de la app. Sin identidad asociada |
| **OpenStreetMap** | Las imágenes del mapa | Qué porciones de mapa mirás |
| **Open-Meteo** | El pronóstico de lluvia | Una coordenada redondeada a ~1 km, no tu posición exacta |

Cuando tocás **compartir un viaje**, la app le pasa la acción al menú de
compartir de tu teléfono. Desde ahí manda la app que elijas vos, con sus
propias reglas.

## Permisos que pide la app, y por qué

| Permiso | Para qué | ¿Se puede usar la app sin darlo? |
|---|---|---|
| `INTERNET` | Descargar los datos del transporte y el mapa | No |
| `ACCESS_COARSE_LOCATION` y `ACCESS_FINE_LOCATION` | "Cerca mío", "¿cómo llego?", la distancia caminando y el aviso de lluvia | **Sí.** Todo lo demás funciona igual |

No pedimos ubicación en segundo plano: la app **no puede** saber dónde estás
cuando no la estás usando.

## Menores

La app no está dirigida a menores de 13 años y no recolecta datos de nadie, de
ninguna edad, en ningún servidor.

## Tus derechos

**No tenemos nada tuyo que pedirnos.** No hay servidor con tus datos, así que
no hay nada que podamos borrarte ni entregarte: no existe.

Lo que la app guarda vive en tu teléfono y **lo controlás vos**, sin pedirnos
permiso ni esperar respuesta — ver "Cómo borrarlos" más arriba.

## Cuando esto cambie

Si en algún momento la app empieza a mandar algo a un servidor —por ejemplo, si
se suma la función de reportar dónde está un colectivo, que es un plan a
futuro—, este documento se actualiza **antes** de que salga esa versión, y se
avisa en la ficha de Google Play.

## Contacto

- Responsable: Danilo Nicolás Avalos
- Correo: avalosdanilonicolas@gmail.com

---

## Atribución de datos

Los datos de recorridos y paradas provienen de
[OpenStreetMap](https://www.openstreetmap.org/copyright), bajo licencia
**ODbL**. Los recorridos de Corrientes capital provienen del portal de datos
abiertos de la Municipalidad de la Ciudad de Corrientes. El pronóstico es de
[Open-Meteo](https://open-meteo.com/).
