# Campaña de Ruta Libre

Todo lo que hace falta para lanzar la app en Instagram y TikTok: la estrategia,
los siete carruseles, los ocho guiones de video, el calendario y las 56 piezas
de arte ya rasterizadas.

## Por dónde empezar

| Archivo | Qué es |
|---|---|
| [`estrategia.md`](estrategia.md) | **Leer esto primero.** Posicionamiento, público, los cinco mensajes, el tono y —lo más importante— las tres frases que no se escriben nunca. |
| [`ig-carruseles.md`](ig-carruseles.md) | Los 7 carruseles slide por slide, con su caption y sus hashtags. |
| [`tiktok-guiones.md`](tiktok-guiones.md) | Los 8 videos con tiempos, texto en pantalla, voz y notas de rodaje. Sirven igual para Reels. |
| [`ig-posts-y-stories.md`](ig-posts-y-stories.md) | Los posts sueltos, las stories, la bio, los highlights y las respuestas guardadas. |
| [`calendario.md`](calendario.md) | Qué se publica cada día, anclado al día del lanzamiento. |
| `assets/` | Los 56 PNG, a 1080 × 1350, listos para subir. |

## Las piezas

Están todas generadas en `assets/`. Se regeneran con:

```bash
REGEN_SOCIAL=1 flutter test test/marketing/social_assets_test.dart
```

- `c1-01.png` … `c7-07.png` — los siete carruseles, en orden de deslizado
- `p1-frase.png`, `p2-numeros.png`, `p3-permisos.png`, `p4-resistencia.png` — los posts de imagen única

## Por qué el arte se dibuja en Dart

Porque el colectivo de estos slides es el **mismo `BrandMarkPainter`** del
ícono de la app (`lib/app/theme/brand.dart`). No hay forma de que la campaña y
la tienda muestren dos marcas distintas, ni de que alguien exporte una versión
"parecida" desde otro programa.

Y porque cuando aumente el boleto, corregir el precio del carrusel C6 es
cambiar un string en `test/marketing/social_assets_test.dart` y correr un
comando — no buscar un archivo de diseño que quedó en la computadora de
alguien.

El guion vive en el markdown; **lo que queda dibujado en el PNG vive en el
Dart**. Si cambiás un texto, cambialo en los dos lados.

## El guardarraíl

`test/marketing/social_assets_test.dart` corre en cada `flutter test` y
verifica tres cosas sobre el texto que va impreso en las imágenes:

1. **Ningún slide promete lo que la app no hace** — nada de "tiempo real",
   "en vivo" ni "sabé cuándo llega". La app no sabe dónde está el colectivo.
2. **El carrusel C1 sigue diciendo la tesis** — si alguien le saca el slide
   incómodo, la campaña pierde lo único que no se puede copiar.
3. **Cada carrusel cierra con la marca** y no pasa de 10 slides.

Es el mismo criterio que `test/store/listing_test.dart` aplica sobre la ficha
de Play. Un slide es más peligroso que la ficha: se comparte suelto, sin
contexto, y sobrevive años en la galería de alguien.

## Lo que falta antes de publicar

- [ ] **Las 4 capturas de pantalla de la app.** Es el único bloqueante real:
      sin ellas no se pueden armar los carruseles C2, C3 y C5 completos, y
      tampoco se puede terminar la ficha de Play. El guion de las capturas
      está en [`../docs/publicacion.md`](../docs/publicacion.md).
- [ ] Crear las cuentas de Instagram y TikTok.
- [ ] Publicar la app y poner el link de Play en la bio.
- [ ] Verificar las tarifas del carrusel C6 antes de subirlo.
