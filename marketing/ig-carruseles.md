# Carruseles de Instagram

Siete carruseles, en orden de publicación. Cada slide está escrito para
**1080 × 1350 px (4:5)**, que es el formato que más pantalla ocupa en el feed.

Los PNG se generan solos, desde el mismo painter de la marca:

```bash
REGEN_SOCIAL=1 flutter test test/marketing/social_assets_test.dart
```

Salen en `marketing/assets/`. La fuente de verdad del PNG es el Dart; este
archivo es el guion y el copy de los captions. Si cambiás un texto acá,
cambialo también en `test/marketing/social_assets_test.dart`.

**Regla de oro del slide 1**: tiene que funcionar solo. En el feed se ve nada
más que ese. Si el slide 1 no da ganas de deslizar, el carrusel no existe.

---

## C1 · "Lo que esta app NO hace"

**Va primero.** Es contraintuitivo, es verdad, y es lo único que ninguna otra
app de transporte puede copiar. Si funciona uno solo, va a ser este.

| # | Texto | Notas de arte |
|---|---|---|
| 1 | **Lo que esta app de colectivos NO hace** | Fondo negro, tipografía grande, nada más. El "NO" en azul. |
| 2 | **No te dice a qué hora llega el colectivo.** Nadie lo sabe: no hay GPS público en la flota. | |
| 3 | **No inventa horarios.** Un horario inventado manda a alguien a esperar un colectivo que no viene. | La segunda frase más chica, en gris. |
| 4 | **No tiene publicidad.** Ni una. | |
| 5 | **No te pide que te registres.** No hay cuenta, no hay mail, no hay contraseña. | |
| 6 | **No te rastrea.** Pide tres permisos y ninguno corre en segundo plano. Tus favoritos viven en tu teléfono. | |
| 7 | **Lo que sí hace:** te dice qué colectivo tomar, en qué esquina subir y en cuál bajar. | Acá cambia el fondo: azul `#1E88E5`, texto blanco. Es el giro del carrusel. |
| 8 | Cierre de marca | |

**Caption:**

> Hay apps de colectivos que te dicen que el 3 llega en 7 minutos.
>
> No pueden saberlo. Acá no hay GPS público en la flota: nadie —ni el
> municipio— sabe dónde está cada colectivo ahora mismo. Ese numerito está
> estimado sobre un horario que muchas veces tampoco existe.
>
> Preferimos decirte "no sabemos" y que llegues a la parada sabiendo que no
> sabés, antes que mandarte a esperar algo que no viene.
>
> Lo que sí sabemos te lo damos entero: qué colectivo tomar, dónde subir,
> dónde bajar, cuánto sale y a cuántas paradas estás de bajarte.
>
> Ruta Libre. Hecha en Resistencia. 🚌

---

## C2 · "¿Cómo llego?"

El carrusel de lanzamiento. Explica el producto entero en seis deslizadas.

| # | Texto | Notas de arte |
|---|---|---|
| 1 | **¿Cómo llego de acá hasta allá?** | La pregunta con la que uno abre una app de colectivos. Grande, centrada. |
| 2 | **Escribís a dónde vas.** El hospital, la facultad, el shopping, la plaza. No hace falta la esquina. | Captura del buscador. |
| 3 | **Te dice qué colectivo tomar.** En qué esquina subís y en cuál te bajás. | Captura del resultado. |
| 4 | **Con transbordo, si hace falta.** Sin transbordos la respuesta sería "no hay" 6 de cada 10 veces. | El "6 de cada 10" grande, en azul. |
| 5 | **Y después te lleva paso a paso.** Un paso por pantalla, grande, para leerlo parado en la vereda. | Captura de la guía. |
| 6 | **Gratis. Sin publicidad. Sin cuenta. Anda sin señal.** | Las cuatro en renglones separados. |
| 7 | Cierre de marca | |

**Caption:**

> Decís a dónde vas y te dice cómo llegar. Eso es todo lo que hace, y lo hace
> con los datos reales de las 32 líneas del Gran Resistencia y Corrientes.
>
> El origen sale del GPS o lo escribís vos, así que también sirve para
> planificar el viaje desde tu casa la noche anterior — o en un teléfono al
> que nunca le diste el permiso de ubicación.
>
> Gratis, sin publicidad y sin cuenta. 🚌

---

## C3 · "Faltan 3 paradas para bajarte"

El "wow". Es la función que hace que alguien se la muestre a otro.

| # | Texto | Notas de arte |
|---|---|---|
| 1 | **Viajar contando esquinas, pegado a la ventanilla.** | Fondo oscuro, tono de ventanilla de noche. |
| 2 | **Se terminó.** | Sola, gigante, centrada. |
| 3 | **La app cuenta las paradas que te faltan.** Mientras viajás. | Captura del renglón "Faltan 3 paradas". |
| 4 | **Cuando falta una, el renglón se enciende y el teléfono vibra una vez.** | El renglón encendido, en azul. |
| 5 | **Es geometría, no un horario.** Sigue tu posición contra las paradas del recorrido, en orden. | |
| 6 | **Si tu posición no cae en el tramo, se calla.** Antes que adivinar, no dice nada. | El "se calla" en azul. |
| 7 | **Y se apaga al cerrar la guía.** Nunca corre en segundo plano. | |
| 8 | Cierre de marca | |

**Caption:**

> Todos hicimos lo mismo: viajar pegado a la ventanilla contando esquinas para
> no pasarnos.
>
> Con el viaje iniciado, Ruta Libre cuenta las paradas que faltan y te avisa
> con una vibración cuando queda una (o cuando estás a menos de 250 m). No es
> magia ni un horario: es tu posición contra las paradas del recorrido.
>
> Tres reglas honestas 👇
> · Sin GPS no te muestra nada. La guía sigue funcionando igual.
> · Si tu posición no cae en el tramo, se calla. No adivina.
> · Al cerrar la guía el seguimiento muere. Nunca corre en segundo plano.
>
> Gratis, sin cuenta y sin publicidad. 🚌

---

## C4 · "El cartel para el chofer"

El más visual de todos. Es el que se reenvía por WhatsApp.

| # | Texto | Notas de arte |
|---|---|---|
| 1 | **De noche, el colectivo no para si nadie le hace señas.** | Fondo casi negro. |
| 2 | **Y una mano levantada no dice a cuál de los tres que vienen le estás haciendo señas.** | |
| 3 | *(sin texto)* | **El cartel**: la pantalla entera con un "3" gigante en el color de la línea. Este slide es la pieza. |
| 4 | **Un botón llena la pantalla con el número de tu línea, en su color.** | |
| 5 | **Y sube el brillo al máximo solo.** Un cartel al 30% de brillo no es un cartel. | |
| 6 | **La pantalla del teléfono es la superficie más brillante que hay en la vereda.** | |
| 7 | Cierre de marca | |

**Caption:**

> Esto no resuelve un problema digital. Resuelve uno físico.
>
> Parada mal iluminada, de noche, vienen tres colectivos y vos levantás la
> mano. ¿A cuál le estás haciendo señas? El chofer tampoco sabe.
>
> Un botón y la pantalla se convierte en un cartel con el número de tu línea,
> en su color y con el brillo al máximo. Al cerrarlo, el brillo vuelve solo a
> como lo tenías.
>
> Está adentro de "Iniciar viaje", mientras esperás — y también en el
> transbordo. 🚌

---

## C5 · "Buscá por lugar, no por esquina"

| # | Texto | Notas de arte |
|---|---|---|
| 1 | **¿Vos sabés en qué esquina queda el Perrando?** | |
| 2 | **No hace falta.** | Sola, grande. |
| 3 | **Escribís "hospital" y aparece.** | Captura del buscador con resultados. |
| 4 | **2612 lugares del Gran Resistencia.** Hospitales, escuelas, plazas, la terminal, el shopping, las facultades. | El número grande, en azul. |
| 5 | **Vienen adentro de la app.** Se buscan sin señal desde el momento en que la instalás. | |
| 6 | **Lugares y paradas salen en la misma lista.** Ordenada por lo que mejor coincide con lo que escribiste. | |
| 7 | Cierre de marca | |

**Caption:**

> Nadie piensa "quiero ir a French y Güemes". Uno piensa "quiero ir al
> Perrando".
>
> 2612 lugares del Gran Resistencia vienen empaquetados adentro de la app:
> hospitales, escuelas, plazas, facultades, la terminal. Se buscan sin señal
> desde el momento en que la instalás, porque no dependen de internet.
>
> Escribís el nombre, elegís de la lista, y te arma el viaje. 🚌

---

## C6 · "¿Cuánto sale el boleto?"

El más "noticia". Es el que puede levantar un medio local.

| # | Texto | Notas de arte |
|---|---|---|
| 1 | **¿Cuánto sale el boleto hoy?** | |
| 2 | **$1.885** · Gran Resistencia | Cifra gigante. |
| 3 | **$1.890** · Interurbano Chaco – Corrientes | Cifra gigante. |
| 4 | **$2.921,10** · ramal del Campus de la UNNE | Cifra gigante, en azul. |
| 5 | **Un 55% más caro que el resto del interurbano.** Por eso se muestra aparte. | |
| 6 | **Cada tarifa con la fecha desde la que rige y la fuente al lado.** | |
| 7 | **Un precio sin fecha es peor que no tener precio.** Alguien llega a la máquina con la plata contada. | Fondo azul. |
| 8 | Cierre de marca | |

> ⚠️ **Antes de publicar**: verificar que las tres tarifas sigan vigentes.
> Al momento de escribir esto: $1.885 desde enero de 2026 (fuente Diario
> Chaco), $1.890 desde marzo de 2026 (fuente El Litoral). Este carrusel
> envejece — es el único que hay que revisar antes de reponerlo.

**Caption:**

> El ramal del Campus de la UNNE sale $2.921,10. El resto del interurbano,
> $1.890. Un 55% más caro por el mismo puente.
>
> En Ruta Libre cada tarifa aparece con la fecha desde la que rige y con la
> fuente al lado. Donde no tenemos el dato confirmado, no mostramos nada: un
> precio "aproximado" es peor que ninguno cuando llegás a la máquina con la
> plata contada.
>
> (Datos al [FECHA]. Si ves uno desactualizado, escribinos y lo corregimos.) 🚌

---

## C7 · "El mapa es de todos"

Para P4: la comunidad de OpenStreetMap, datos abiertos, prensa. Es el que da
credibilidad y el que consigue que otros hablen de la app.

| # | Texto | Notas de arte |
|---|---|---|
| 1 | **Esta app no tiene un mapa propio.** | |
| 2 | **Los recorridos y las paradas son de OpenStreetMap.** Los mapeó gente, a mano. | |
| 3 | **1474 paradas · 133 recorridos · 32 líneas** | Los tres números, grandes. |
| 4 | **Y 2638 paradas que OSM no declaraba** las dedujimos de la geometría del recorrido y del lado de la calle. | |
| 5 | **¿Encontraste una parada que ya no existe?** La app te abre el nodo en OpenStreetMap para que la corrijas vos. | El "vos" en azul. |
| 6 | **El mapa es de todos.** | Sola, grande, fondo azul. |
| 7 | Cierre de marca | |

**Caption:**

> Ruta Libre no inventó un mapa: usa OpenStreetMap, un mapa libre que mapea
> gente común, bajo licencia ODbL. Los recorridos de Corrientes capital salen
> del portal de datos abiertos de la Municipalidad.
>
> Por eso, cuando encontrás una parada que ya no existe, la app no te pide que
> nos escribas: te abre el nodo en OpenStreetMap para que lo corrijas.
> Corregido ahí, queda corregido para todos los que usan ese mapa, no solo
> para nosotros.
>
> Si mapeás en OSM y querés dar una mano con el Gran Resistencia, hablanos. 🚌

---

## Hashtags

No más de 8 por post. Mezclar geográficos (que es donde está la gente) con
temáticos.

**Base, para todos:**
`#Resistencia #Chaco #Corrientes #GranResistencia #Colectivos #TransportePublico`

**Según el post:**
- Lanzamiento / producto: `#RutaLibre #AppArgentina`
- P1 estudiantes: `#UNNE #CampusUNNE #Estudiantes`
- P4 datos abiertos: `#OpenStreetMap #DatosAbiertos #OSM`
- Tarifas: `#Boleto #Tarifa`

**Geográficos largos, para rotar:** `#ResistenciaChaco #CorrientesCapital
#Barranqueras #Fontana #PuertoVilelas #ChacoArgentina`
