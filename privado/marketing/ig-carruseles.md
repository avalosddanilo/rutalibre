# Carruseles de Instagram

Ocho carruseles, **en orden de publicación**. Cada slide está escrito para
**1080 × 1350 px (4:5)**, que es el formato que más pantalla ocupa en el feed.

Los PNG se generan solos, desde el mismo painter de la marca y con las
capturas reales del teléfono:

```bash
REGEN_SOCIAL=1 flutter test test/marketing/social_assets_test.dart
```

Salen en `marketing/assets/`. La fuente de verdad del PNG es el Dart; este
archivo es el guion y el copy de los captions. Si cambiás un texto acá,
cambialo también en `test/marketing/social_assets_test.dart`.

**Regla de oro del slide 1**: tiene que funcionar solo. En el feed se ve nada
más que ese. Si el slide 1 no da ganas de deslizar, el carrusel no existe.

**El orden no es caprichoso.** `C1` es la tesis, `C2` presenta el producto, y
`C3` y `C4` son las dos historias humanas que [`docs/lanzamiento.md`](../docs/lanzamiento.md)
manda contar primero: la alarma y las alturas.

---

## C1 · "Lo que esta app NO hace"

**Va primero.** Es contraintuitivo, es verdad, y es lo único que ninguna otra
app de transporte puede copiar — para copiarlo tendría que dejar de inventar.

| # | Texto |
|---|---|
| 1 | **Lo que esta app de colectivos NO hace** *(el "NO" en azul)* |
| 2 | **No te dice a qué hora llega el colectivo.** No existe ningún dato público de dónde está cada coche. |
| 3 | **No inventa horarios.** Un horario inventado manda a alguien a esperar un colectivo que no viene. |
| 4 | **No tiene publicidad.** Ni una. |
| 5 | **No te pide que te registres.** No hay cuenta, no hay mail, no hay contraseña. |
| 6 | **No te rastrea.** Pide tres permisos y ninguno corre en segundo plano. |
| 7 | **Lo que sí hace:** te dice qué colectivo tomar, en qué esquina subir y en cuál bajar. *(fondo azul — el giro)* |
| 8 | Cierre de marca |

**Caption:**

> Hay apps de colectivos que te dicen que el 3 llega en 7 minutos.
>
> Acá no existe ningún dato público y abierto de dónde está cada colectivo.
> Sin eso, ninguna app independiente puede saberlo de verdad: ese numerito
> sale de estimar sobre un horario que muchas veces tampoco existe.
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

El carrusel de presentación. Explica el producto entero, con capturas reales.

| # | Texto | Captura |
|---|---|---|
| 1 | **¿Cómo llego de acá hasta allá?** | — |
| 2 | **Escribís a dónde vas.** El hospital, la escuela, la plaza — o tu casa, con la altura. | `02-buscador-altura` |
| 3 | **Te dice qué colectivo tomar.** En qué esquina subís y en cuál te bajás. | `03-como-llego` |
| 4 | **Con transbordo, si hace falta.** Sin transbordos la respuesta sería "no hay" 6 de cada 10 veces. | — |
| 5 | **Y después te lleva paso a paso.** Un paso por pantalla, grande, para leerlo parado en la vereda. | `05-guia-caminata` |
| 6 | **Gratis. Sin publicidad. Sin cuenta. Anda sin señal.** | — |
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

## C3 · La alarma para no quedarte dormido

**El mejor de los ocho.** Es la función preferida del que la hizo, tiene una
historia humana atrás ("la hice porque me pasó") y no la tiene ninguna otra
app de colectivos del país.

| # | Texto | Captura |
|---|---|---|
| 1 | **¿Alguna vez te quedaste dormido en el colectivo?** | — |
| 2 | **Y te despertaste en la terminal.** | — |
| 3 | **Antes de arrancar, prendés la alarma.** "Avisame para bajar". Un interruptor y listo. | `08-alarma-armada` |
| 4 | **Dos paradas antes de la tuya, suena.** Dos y no una: entre abrir los ojos y juntar las cosas, una parada es muy justo. Lo dijo la prueba de campo. | — |
| 5 | **Suena fuerte aunque el teléfono esté en silencio.** Con vibración, y la pantalla entera pidiéndote que te bajes. | `09-alarma-sonando` |
| 6 | **Y solo la apaga el botón.** Una alarma que se apaga rozándola medio dormido no despertó a nadie. | — |
| 7 | **Necesita la app abierta.** Con la pantalla apagada todavía no anda. Te lo decimos ahora y no cuando te falle: queda para la 1.1. *(fondo azul)* | — |
| 8 | Cierre de marca | |

> El slide 7 es el que ningún departamento de marketing dejaría pasar, y es
> justamente el que hay que dejar. Alguien que se duerme confiando en una
> alarma que no suena con la pantalla apagada se despierta en la terminal y
> desinstala. Hay un test que verifica que ese slide siga estando.

**Caption:**

> Me quedé dormido en el colectivo y me desperté quién sabe dónde. Así que le
> puse una alarma.
>
> La prendés antes de arrancar el viaje y, dos paradas antes de la tuya, el
> teléfono suena con el tono de alarma del sistema —aunque esté en silencio,
> que arriba del colectivo es exactamente cuándo hace falta—, vibra, y la
> pantalla entera te pide que te bajes. Solo la apaga el botón: una alarma que
> se apaga rozándola medio dormido no despertó a nadie.
>
> Dos paradas y no una, porque entre abrir los ojos y juntar las cosas, una
> parada es muy justo. Eso lo aprendí probándola.
>
> Lo único: necesita la app abierta. Con la pantalla apagada todavía no, y
> prefiero decírtelo ahora. Queda para la próxima versión. 🚌

---

## C4 · "Tu casa tiene altura"

La segunda historia humana: buscaba mi propia casa y la app no la encontraba.
**El ejemplo que se muestra NO es la casa propia**: es "9 de Julio 1260", una
avenida del centro, que es lo que se ve en la captura.

> **Nunca con tu dirección, ni de ejemplo.** Los números del slide 6 son los
> de la captura (9 de Julio: el 1250 no está mapeado, se ofrece el 1260), que
> ya es pública. Si hace falta otro ejemplo, que sea de un lugar público.

| # | Texto | Captura |
|---|---|---|
| 1 | **¿Cómo buscás tu casa en una app de colectivos?** | — |
| 2 | **Las paradas se llaman por esquinas.** Tu casa tiene altura. | — |
| 3 | **Ahora escribís la dirección con el número.** Y cae en la cuadra real. | `02-buscador-altura` |
| 4 | **58.000** números de puerta mapeados en OpenStreetMap, adentro de la app | — |
| 5 | **¿Y si tu número justo no está mapeado?** Te ofrece el más cercano con su número, y te avisa. | — |
| 6 | **Disfrazar el 1260 de 1250 sería mentirte la dirección.** E interpolarla sería inventarla. *(fondo azul)* | — |
| 7 | Cierre de marca | |

**Caption:**

> Buscaba mi propia casa y la app no la encontraba. Porque las paradas se
> nombran por esquinas, y nadie piensa su casa como una esquina.
>
> Ahora escribís la dirección con altura y cae en la cuadra real, gracias a
> las 58.000 direcciones que la comunidad de OpenStreetMap mapeó en el área.
>
> ¿Y si tu número justo no está mapeado? Te ofrece el más cercano con SU
> número y te lo dice. Disfrazar el 1260 de 1250 sería mentirte la dirección,
> e interpolarla sería inventarla. 🚌

---

## C5 · "El cartel para el chofer"

El más visual. Es el que se reenvía por WhatsApp. Resuelve un problema
físico, no digital.

| # | Texto | Captura |
|---|---|---|
| 1 | **De noche, el colectivo no para si nadie le hace señas.** | — |
| 2 | **Y una mano levantada no dice a cuál de los tres que vienen le estás haciendo señas.** | — |
| 3 | *(sin texto — la captura a sangre, la pantalla entera en verde con el 2)* | `07-cartel-chofer` |
| 4 | **Un botón llena la pantalla con el número de tu línea, en su color.** | `06-guia-toma-la-2` |
| 5 | **Y sube el brillo al máximo solo.** Un cartel al 30% de brillo no es un cartel. | — |
| 6 | **La pantalla del teléfono es la superficie más brillante que hay en la vereda.** | — |
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

## C6 · "Faltan 3 paradas para bajarte"

| # | Texto | Captura |
|---|---|---|
| 1 | **Viajar contando esquinas, pegado a la ventanilla.** | — |
| 2 | **Se terminó.** | — |
| 3 | **La app cuenta las paradas que te faltan.** Mientras viajás. | `08-alarma-armada` |
| 4 | **Es geometría, no un horario.** Sigue tu posición contra las paradas del recorrido, en orden. | — |
| 5 | **Si tu posición no cae en el tramo, se calla.** Antes que adivinar, no dice nada. | — |
| 6 | **Y se apaga al cerrar la guía.** Nunca corre en segundo plano. | — |
| 7 | Cierre de marca | |

**Caption:**

> Todos hicimos lo mismo: viajar pegado a la ventanilla contando esquinas para
> no pasarnos.
>
> Con el viaje iniciado, Ruta Libre cuenta las paradas que faltan. No es magia
> ni un horario: es tu posición contra las paradas del recorrido.
>
> Tres reglas honestas 👇
> · Sin GPS no te muestra nada. La guía sigue funcionando igual.
> · Si tu posición no cae en el tramo, se calla. No adivina.
> · Al cerrar la guía el seguimiento muere. Nunca corre en segundo plano.
>
> Y si preferís dormir, está la alarma. 🚌

---

## C7 · "¿Cuánto sale el boleto?"

El más "noticia". Es el que puede levantar un medio local.

| # | Texto |
|---|---|
| 1 | **¿Cuánto sale el boleto hoy?** |
| 2 | **$1.885** · Gran Resistencia |
| 3 | **$1.890** · Interurbano Chaco – Corrientes |
| 4 | **$2.921,10** · ramal del Campus de la UNNE *(fondo azul)* |
| 5 | **Un 55% más caro que el resto del interurbano.** Por eso se muestra aparte. |
| 6 | **Cada tarifa con la fecha desde la que rige y la fuente al lado.** |
| 7 | **Un precio sin fecha es peor que no tener precio.** Alguien llega a la máquina con la plata contada. *(fondo azul)* |
| 8 | Cierre de marca |

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

## C8 · "El mapa es de todos"

Para la comunidad de OpenStreetMap, datos abiertos y prensa. Es el que da
credibilidad y el que consigue que otros hablen de la app.

| # | Texto |
|---|---|
| 1 | **Esta app no tiene un mapa propio.** |
| 2 | **Los recorridos y las paradas son de OpenStreetMap.** Los mapeó gente, a mano. |
| 3 | **1474 paradas · 133 recorridos · 32 líneas** |
| 4 | **Y 2638 paradas que OpenStreetMap no declaraba** las dedujimos de la geometría del recorrido y del lado de la calle. |
| 5 | **¿Encontraste una parada que ya no existe?** La app te abre el nodo en OpenStreetMap para que la corrijas vos. |
| 6 | **El mapa es de todos.** *(fondo azul)* |
| 7 | Cierre de marca |

**Caption:**

> Ruta Libre no inventó un mapa: usa OpenStreetMap, un mapa libre que mapea
> gente común, bajo licencia ODbL. Los recorridos de Corrientes capital salen
> del portal de datos abiertos de la Municipalidad.
>
> Las 58.000 alturas que hacen que tu dirección caiga en la cuadra real
> también salen de ahí: las mapeó gente, gratis.
>
> Por eso, cuando encontrás una parada que ya no existe, la app no te pide que
> nos escribas: te abre el nodo en OpenStreetMap para que lo corrijas.
> Corregido ahí, queda corregido para todos.
>
> Si mapeás en OSM y querés dar una mano con el Gran Resistencia, hablanos. 🚌

---

## Las capturas

Están en `marketing/capturas/`, sacadas del teléfono con la versión final.
Se recortan en el generador con una alineación por slide — **nunca se retoca
una captura para que muestre algo que la app no hace.**

| Archivo | Qué muestra |
|---|---|
| `01-mapa-paradas` | El mapa con las paradas visibles y el panel de líneas |
| `02-buscador-altura` | "9 de julio 1250" y el cartel de que ese número no está mapeado |
| `03-como-llego` | "6 líneas te llevan directo", con los pasos de cada una |
| `04-viaje-elegido` | El recorrido dibujado y el panel con "Iniciar viaje" |
| `05-guia-caminata` | Un paso de la guía: "Caminá hasta…" con los metros que faltan |
| `06-guia-toma-la-2` | "Tomá la 2" con el botón del cartel para el chofer |
| `07-cartel-chofer` | El cartel: la pantalla entera en verde con el 2 |
| `08-alarma-armada` | "Viajá 10 paradas", el contador y el interruptor de la alarma |
| `09-alarma-sonando` | La alarma sonando: "¡Preparate para bajar!" |

Las cuatro que [`docs/lanzamiento.md`](../docs/lanzamiento.md) marca como las
que venden, y que van también a la ficha de Play, son `01`, `04`, `08` y `02`.

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
