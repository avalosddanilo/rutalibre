# Campaña de Ruta Libre

Todo lo que hace falta para lanzar la app en Instagram y TikTok: la estrategia,
los ocho carruseles, los nueve guiones de video, el calendario y las 64 piezas
de arte ya rasterizadas con las capturas reales del teléfono.

**Esta carpeta cuelga de [`docs/lanzamiento.md`](../docs/lanzamiento.md)**, que
es el plan del primer mes y el que manda: ahí están el keystore, el AAB, la
prueba cerrada de 14 días y los trámites. Acá está qué se publica y cuándo.

## Por dónde empezar

| Archivo | Qué es |
|---|---|
| [`estrategia.md`](estrategia.md) | **Leer esto primero.** Posicionamiento, público, los cinco mensajes, las dos historias humanas, el tono y las tres frases que no se escriben nunca. |
| [`ig-carruseles.md`](ig-carruseles.md) | Los 8 carruseles slide por slide, con su caption y sus hashtags. |
| [`tiktok-guiones.md`](tiktok-guiones.md) | Los 9 videos con tiempos, texto en pantalla, voz y notas de rodaje. Sirven igual para Reels. |
| [`ig-posts-y-stories.md`](ig-posts-y-stories.md) | Los posts sueltos, las stories, la bio, los highlights y las respuestas guardadas. |
| [`calendario.md`](calendario.md) | Qué se publica cada día, colgado de los 14 días de prueba cerrada. |
| `assets/` | Las piezas para cuando la app esté en Play, a 1080 × 1350. |
| `assets/prelanzamiento/` | **Lo que se sube ANTES de que salga**: C1, C4, C8 y C3 con un cierre que no dice "Google Play", y la story para juntar testers. |
| `capturas/` | Las 9 capturas del teléfono, de la versión final. |

## Lo primero de todo: el video

`docs/lanzamiento.md` pide **un** video, y tiene razón: uno bien hecho sirve
para Instagram, TikTok, WhatsApp, el posteo personal y para mandarle a los
medios. Es la pieza de mayor rendimiento de toda la campaña.

El guion está en [`tiktok-guiones.md`](tiktok-guiones.md) como **T0 · El
video**: pantalla grabada del flujo entero — busco una dirección con altura →
elijo el viaje → iniciar → el contador bajando → la alarma sonando.

## Las piezas

```bash
REGEN_SOCIAL=1 flutter test test/marketing/social_assets_test.dart
```

- `c1-*` … `c8-*` — los ocho carruseles, en orden de deslizado
- `p1-frase`, `p2-numeros`, `p3-permisos`, `p4-resistencia`, `p5-alarma` — los posts de imagen única

El orden de los carruseles no es caprichoso: **C1** es la tesis (lo único que
no se puede copiar), **C2** presenta el producto, y **C3** (la alarma) y
**C4** (las alturas) son las dos historias humanas que el plan de
lanzamiento manda contar primero.

## Por qué el arte se dibuja en Dart

Porque el colectivo de estos slides es el **mismo `BrandMarkPainter`** del
ícono de la app (`lib/app/theme/brand.dart`). No hay forma de que la campaña y
la tienda muestren dos marcas distintas, ni de que alguien exporte una versión
"parecida" desde otro programa.

Y porque cuando aumente el boleto, corregir el precio del carrusel C7 es
cambiar un string en `test/marketing/social_assets_test.dart` y correr un
comando — no buscar un archivo de diseño que quedó en la computadora de
alguien.

El guion vive en el markdown; **lo que queda dibujado en el PNG vive en el
Dart**. Si cambiás un texto, cambialo en los dos lados.

Las capturas se recortan en el generador con una alineación por slide. **Nunca
se retoca una captura para que muestre algo que la app no hace.**

## El guardarraíl

`test/marketing/social_assets_test.dart` corre en cada `flutter test` y
verifica el texto que va impreso en las imágenes:

1. **Ningún slide promete lo que la app no hace** — nada de "tiempo real",
   "en vivo" ni "sabé cuándo llega". La app no sabe dónde está el colectivo.
2. **El carrusel C1 sigue diciendo la tesis** — si alguien le saca el slide
   incómodo, la campaña pierde lo único que no se puede copiar.
3. **El carrusel de la alarma dice su límite** — que necesita la app abierta.
   Venderla sin ese renglón haría que alguien se durmiera confiando en algo
   que, con la pantalla apagada, no suena.

   > **⚠️ Este renglón NO caduca todavía, y ahora sabemos por qué.** Se
   > probó en emulador el 2026-09-21: el servicio en primer plano funciona,
   > pero la alarma igual no suena hasta encender la pantalla. La función
   > **no está terminada**. Diagnóstico y plan en
   > `docs/alarma-pantalla-apagada.md`.
   >
   > Hasta que las dos cosas estén, **la copy pública no se toca**: decir que
   > anda con la pantalla apagada antes de verlo andar es exactamente la
   > clase de promesa que esta lista existe para impedir, y el que se
   > duerme confiando en ella se pasa de parada igual.
   >
   > Cuando esté verificado, lo que hay que actualizar es: este renglón, el
   > slide 7 y el pie de `ig-carruseles.md`, los dos pasajes de
   > `ig-posts-y-stories.md`, los dos de `tiktok-guiones.md`, la regla de
   > `estrategia.md`, la ficha de Play (`docs/ficha-play.md`) y la respuesta
   > «La alarma no sonó» de `docs/resenas.md`.
4. **Cada carrusel cierra con la marca** y no pasa de 10 slides.
5. **Las capturas que usan los slides existen** — un slide que apunta a un
   archivo borrado no falla al generar, falla cincuenta PNG después.

Es el mismo criterio que `test/store/listing_test.dart` aplica sobre la ficha
de Play. Un slide es más peligroso que la ficha: se comparte suelto, sin
contexto, y sobrevive años en la galería de alguien.

## Lo que falta antes de publicar

- [ ] **Grabar T0**, el video del flujo completo. Es lo primero.
- [ ] Crear las cuentas de Instagram y TikTok — el día 1 de la prueba cerrada,
      no el día del lanzamiento.
- [ ] Poner el link de Play en la bio cuando la app salga.
- [ ] Verificar las tarifas del C7 antes de subirlo.
