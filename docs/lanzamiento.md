# El plan del primer mes: de acá a publicada (y con gente usándola)

La cuenta de Play ya está pagada. Lo que manda los tiempos es una regla de
Google: las cuentas personales nuevas tienen que correr una **prueba cerrada
con al menos 12 testers anotados 14 días SEGUIDOS** antes de poder pedir
acceso a producción. No hay atajo — así que la prueba cerrada arranca HOY y
esos 14 días se usan para todo lo demás.

Los textos ya están escritos: la ficha en [`ficha-play.md`](ficha-play.md)
(con test que cuenta los caracteres), el proceso completo en
[`publicacion.md`](publicacion.md), las emergencias en
[`operaciones.md`](operaciones.md).

---

## HOY (día 0) — destrabar el reloj de los 14 días

Nada de esta lista puede esperar, porque todo lo demás espera a esto.

1. **Keystore definitivo.** Generarlo con contraseña nueva (la anterior
   quedó expuesta en una captura), crear `android/key.properties`, y hacer
   **DOS copias de seguridad** (pendrive + Drive). Sin ese archivo no se
   actualiza la app nunca más.
2. **Compilar el AAB** (Play no acepta APK para publicar):
   ```bash
   flutter build appbundle --release --dart-define-from-file=env.json
   ```
   Sale en `build/app/outputs/bundle/release/app-release.aab`.
3. **La política de privacidad online.** Repo público aparte + GitHub Pages
   sirviendo `site/privacidad/index.html` (los pasos exactos en
   `publicacion.md`; NUNCA apuntar Pages a /docs). Anotar la URL.
4. **Crear la app en Play Console** y cargar: ficha (copiar y pegar de
   `ficha-play.md`), formulario de seguridad de datos y clasificación de
   contenido (respuestas en `publicacion.md`), URL de privacidad.
5. **Capturas**: 4 mínimo, del teléfono con la versión final. Las cuatro que
   venden: (a) el mapa con las paradas, (b) "¿cómo llego?" con un viaje
   dibujado, (c) la guía paso a paso con el contador "Faltan 3 paradas",
   (d) el buscador encontrando una dirección con altura —una pública,
   nunca la tuya—. Sin datos personales a la vista.
6. **Crear la PRUEBA CERRADA** (Testing → Closed testing), subir el AAB, y
   crear una lista de testers por mail.
7. **Reclutar 15–20 testers** (12 es el mínimo: llevar margen, porque el que
   se desanota te resetea la cuenta). Familia, amigos, compañeros. El
   mensaje de WhatsApp:

   > ¿Me das una mano con algo que hice? Es una app de colectivos de
   > Resistencia y Corrientes — gratis, sin publicidad. Google me pide 12
   > personas probándola 14 días antes de dejarme publicarla. Solo
   > necesito que entres a este enlace, aceptes ser tester, la instales
   > desde Play **y no la desinstales por dos semanas**. Usala cuando
   > tomes el cole si querés — cualquier cosa rara que veas, me la decís
   > y la arreglo. ¡Gracias!

   Regla de oro: **no alcanza con que acepten** — tienen que quedar
   anotados los 14 días corridos. Avisarles que no se desanoten.

## Días 1–14 — la prueba cerrada (y la artillería lista)

**Con los testers:**
- Día 2: confirmar uno por uno que aceptaron y la instalaron (Play Console
  muestra cuántos hay anotados). Si hay menos de 15, reclutar más YA.
- Cada 2–3 días: mirar Play Console → Calidad → Android vitals (cierres
  inesperados y ANR). Preguntar en el grupo qué les molestó.
- Arreglar solo lo grave. Lo cosmético se anota para la 1.1 — cada AAB
  nuevo en la prueba está bien, pero no hace falta uno por día.

**Mientras tanto (esto es lo que hace que el lanzamiento no sea un tuit al
vacío):**
- **Mandar los dos mails** de `privado/mails-para-mandar.md`
  (municipalidad de Corrientes y empresa). Mandarlos ANTES del lanzamiento:
  si después hay prensa, el reclamo por los datos ya está hecho y con fecha.
- **Crear el Instagram de la app** (@rutalibre.app o similar): foto = ícono,
  bio = "Colectivos del Gran Resistencia y Corrientes. Gratis, sin
  publicidad. 🚌". Tres posteos preparados en borrador: la presentación, la
  alarma, las alturas.
- **Grabar UN video** de 30–60 segundos con el teléfono: pantalla grabada
  del flujo completo (busco una dirección → elijo el viaje → iniciar → contador →
  alarma sonando). Ese video ES la publicidad: sirve para Instagram, TikTok,
  WhatsApp y para mandarle a los medios.
- **Escribir la lista de difusión**: está empezada en
  `privado/difusion.md` — los medios con lo que se pudo verificar, la
  receta para buscar los grupos de Facebook el mismo día, y el texto adaptado
  por grupo. Lo que falta ahí son mails de redacción que hay que conseguir a
  mano.

## Día 15–16 — pedir producción

Con 12+ testers cumpliendo 14 días corridos, en el Dashboard aparece
**"Solicitar acceso a producción"**. Google hace unas preguntas sobre qué
aprendiste de la prueba: contestar con la verdad, que es abundante (los
hallazgos de campo están en el CHANGELOG: la alarma llegaba tarde y se
adelantó, el buscador no encontraba direcciones y se agregaron 58.000
alturas, etc.). Aprobado eso, subir el AAB final a **Producción** y mandarlo
a revisión. La revisión tarda de horas a unos días.

## Un supuesto que conviene tener claro: nadie usa ninguna app

SITAM está caída hace rato (no muestra recorridos, tocar una parada no lista
líneas, no hay GPS) y, sobre todo, **la gente de acá no usa ninguna app para
el colectivo**: pregunta. Eso significa que **nadie va a buscar "colectivos
Resistencia" en Play**, así que la ficha no nos trae usuarios sola. Todo el
tráfico va a venir de que alguien le pase el enlace a alguien.

Consecuencia práctica para este plan, no para el discurso:

- El video de 30–60 segundos y el enlace de Play son **el** canal. Todo lo
  demás existe para que circulen.
- Pedirle a cada tester que se la muestre a UNA persona en vivo, en la
  parada, con el teléfono en la mano. Vale más que un posteo.
- A los medios se les cuenta el problema (no existe el dato), nunca "la app
  oficial no anda": eso convierte la nota en una pelea y nos quema con la
  Secretaría a la que le pedimos los horarios.

## La semana del lanzamiento (cuando Play apruebe)

El orden importa: primero lo propio, después los grupos, después la prensa —
así cuando la prensa mire, ya hay gente usándola y opinando.

1. **Día L**: publicar. Probar el enlace de Play en un teléfono ajeno.
2. **Día L**: el posteo personal (Facebook + Instagram + estado de WhatsApp)
   con el video. Pedirle a los testers que compartan — son 15 personas que
   ya la usan y eso vale más que cualquier aviso.
3. **Día L+1**: los grupos de Facebook e Instagram locales. Un grupo por
   vez, con el texto adaptado (en el de Barranqueras, arrancar por las
   alturas; en el de la UNNE, por el 904 al campus). Nunca el mismo texto
   calcado en todos: huele a spam y los admins lo borran.
4. **Día L+2**: los medios. El mensaje corto (abajo). Los medios locales
   VIVEN de historias así: pibe de acá hace gratis lo que no existía.

### El posteo (borrador — ajustalo a tu voz)

> Hice una app 🚌
>
> Se llama **Ruta Libre** y contesta la pregunta de siempre: ¿cómo llego de
> acá hasta allá en colectivo? Gran Resistencia y Corrientes: todas las
> paradas, los recorridos, qué línea tomar, dónde subir y dónde bajar — y
> una guía en vivo que te va diciendo cuántas paradas faltan.
>
> Mi función preferida: la **alarma para no quedarte dormido**. Dos paradas
> antes de la tuya, el teléfono suena y vibra hasta que lo apagues, aunque
> esté en silencio. La hice porque me pasó.
>
> Es gratis, sin publicidad, sin registro, y funciona sin señal.
>
> La hice yo solo, acá en Resistencia. Si la probás y algo no anda, decime:
> lo arreglo. [enlace de Play]

### El mensaje a los medios (mail o DM)

> Hola, soy Danilo Avalos, de Resistencia. Acabo de publicar **Ruta Libre**,
> una aplicación gratuita y sin publicidad para el transporte público del
> Gran Resistencia y Corrientes: mapa de las 1400+ paradas, "¿cómo llego?"
> con transbordos, guía paso a paso con contador de paradas en vivo, alarma
> para no quedarse dormido en el colectivo, y buscador por dirección con
> altura ("9 de Julio 1260"). La hice solo, con datos abiertos de
> OpenStreetMap y del municipio de Corrientes.
>
> Les escribo porque creo que a sus lectores/oyentes les sirve, y porque
> hay un tema de fondo: los horarios de los colectivos no los publica
> ninguna fuente oficial, y con datos abiertos la app podría dar mucho más.
> Si les interesa nota, tengo video del funcionamiento y estoy disponible.
> [enlace de Play]

## Qué decir cuando te llamen (y qué no)

**El pitch de 30 segundos**: "Es una app gratis y sin publicidad para saber
cómo moverte en colectivo por el Gran Resistencia y Corrientes: qué línea
tomar, dónde subir, dónde bajar, con una guía que te sigue durante el viaje
y una alarma por si te dormís. La hice solo, con datos abiertos, porque no
existía y la necesitaba yo."

**Las dos historias humanas** (los periodistas necesitan historias, no
funciones):
1. *La alarma*: "Me quedé dormido en el colectivo y me desperté quién sabe
   dónde. Le puse una alarma que suena dos paradas antes de la tuya aunque
   el teléfono esté en silencio. La probé yo."
2. *Las alturas*: "Buscaba mi propia casa y la app no la encontraba,
   porque las paradas se nombran por esquinas.
   Hoy podés escribir la dirección con altura y cae en la cuadra real,
   gracias a 58.000 direcciones que la comunidad de OpenStreetMap mapeó."
   **La dirección no se dice.** La historia funciona igual sin el número, y
   una nota sale publicada con tu nombre al lado.

**Decir siempre**:
- Gratis, sin publicidad, sin cuenta, funciona sin señal. Nadie rastrea nada.
- Los datos son de OpenStreetMap (comunidad, licencia ODbL) y del portal de
  datos abiertos de Corrientes — dar el crédito EN VOZ ALTA, es de ley y
  además es la mejor parte de la historia.
- **El pedido**: "lo que le falta a la app no es programación, son datos:
  los horarios no los publica nadie. Si el municipio o las empresas los
  publicaran como datos abiertos, los cargo en una semana." La prensa es la
  palanca más grande que vas a tener para esto — usala.

**No decir nunca**:
- No prometer colectivos en tiempo real ni horarios que no están: la
  honestidad de la app ES la marca. "Preferimos decir no sabemos antes que
  inventar" queda mejor que cualquier promesa.
- No hablar mal de las empresas ni del municipio: mañana les vas a pedir
  datos. Postura: "quiero colaborar, no competir".
- No dar números de usuarios que no tenés, ni fechas de funciones que no
  empezaste.
- Tu dirección: ni la calle ni la altura, aunque sea el ejemplo perfecto.
  La historia de las alturas funciona igual sin ella, y una nota sale
  publicada con tu nombre al lado.

## Semana 4 — después del ruido

- **Reseñas**: contestar TODAS desde Play Console, las malas primero, con
  la misma voz honesta ("tenés razón, no está; está pedido/anotado"). Una
  mala reseña bien contestada suma más que una buena. Los textos ya están
  escritos en `privado/resenas.md`, incluidas las cinco que seguro van
  a llegar.
- **Métricas**, dos veces por semana y no más: instalaciones (Play),
  cierres inesperados (vitals), uso de Supabase (con las alertas al 50/80%
  puestas). Los umbrales y qué hacer si se acercan: `operaciones.md`.
- **Insistir con los mails** si no contestaron (a los 15 días, reenvío
  cortés con la novedad: "la app ya está publicada y salió en [medio]").
- **Anotar TODO lo que pida la gente** en ARCHITECTURE → Pendientes de la
  1.1. No prometer fechas; elegir por frecuencia del pedido. Las mejores
  funciones de la 1.0 salieron de quejas de la calle.
- **La 1.1 se decide a fin de mes** con esa lista. Candidata firme: la
  alarma con pantalla apagada. Pero que decida la calle.

## Resumen en una línea por semana

| Semana | Qué pasa |
|---|---|
| 0 (hoy) | Keystore + AAB + ficha + privacidad + **prueba cerrada con 15-20 testers** |
| 1–2 | Los 14 días corren solos; mails mandados, video grabado, difusión lista |
| 3 | Producción aprobada → publicar → posteo → grupos → medios |
| 4 | Contestar reseñas, mirar métricas, juntar pedidos, decidir la 1.1 |
