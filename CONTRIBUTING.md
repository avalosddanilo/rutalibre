# Ruta Libre

App de transporte público del **Gran Resistencia** (Chaco) y **Corrientes
capital**. Flutter + Android. Gratis, sin publicidad, sin cuentas, sin
rastreo. La hace una persona sola.

Este archivo es para que quien llegue no tenga que deducir las reglas del
proyecto leyendo cincuenta archivos. Lo que está acá son decisiones ya
tomadas, no sugerencias.

## La regla que manda sobre todas

**Nunca prometer lo que la app no hace.** La app **no sabe dónde está el
colectivo**: no hay GPS de las unidades, no hay tiempo real, no hay "cuándo
llega". Cada vez que un dato falta, la app lo dice en vez de estimarlo.

Esto no es humildad: es la única ventaja competitiva que tiene el proyecto
frente a las apps oficiales, y la gente la usa parada en una esquina
decidiendo si espera o camina. Un dato inventado ahí no es un bug de
software, es alguien que pierde el colectivo.

Aplica igual al código, a los tests y a cualquier texto que vea el público.
Si una función no está **verificada**, la copy pública no la anuncia —
aunque el código esté hecho y los tests pasen.

El ejemplo vivo está en `docs/alarma-pantalla-apagada.md`: la alarma con la
pantalla apagada NO funciona, el interruptor dice "Necesita la app abierta",
y hay un test que impide que esa frase vuelva a prometer de más.

## Cómo se escribe acá

- **Todo en español rioplatense, con voseo.** Comentarios, nombres de tests,
  mensajes de commit, documentación. El código (identificadores, API de
  Flutter) va en inglés como siempre.
- **Los comentarios explican POR QUÉ, nunca QUÉ.** `// suma 1 al contador`
  no se escribe. `// +1 y no +0: el conteo arranca en la parada de subida,
  que ya cuenta como recorrida` sí. Mirá cualquier archivo de `lib/` antes
  de escribir uno nuevo: la densidad de comentario del proyecto es alta y
  deliberada.
- **Cuando algo se decidió en contra de la opción obvia, se deja escrito por
  qué.** Ejemplos vivos: el tono de alarma es Kotlin propio y no un plugin
  (`MainActivity.kt`); el servicio en primer plano es propio y no el de
  geolocator (`TripService.kt`); R8 está apagado a propósito
  (`build.gradle.kts`). El próximo que lo vea va a querer "arreglarlo".
- **Nada de emojis en assets renderizados.** Las piezas de marketing se
  rasterizan con Inter, que no tiene glifos de emoji: salen como cuadraditos
  con "NO GLYPH" adentro. Hay un test que lo guarda
  (`test/marketing/story_assets_test.dart`).

## Arquitectura

Clean architecture por feature: `presentation → domain ← data`.

```
lib/
  app/        tema, router, widgets compartidos
  core/       config, errores, providers y utilidades transversales
  features/
    transit/  { data, domain, presentation }
    weather/  { data, domain, presentation }
```

- **Riverpod 3**, providers escritos a mano (no codegen).
- **`fpdart`**: los repositorios devuelven `Either<Failure, T>`, no tiran.
- **`domain` no importa nada de infraestructura.** Si `geolocator` o
  `supabase` aparecen en un archivo de `domain/`, está mal ubicado.
- **Tests con `mocktail`.** Hoy son 606 y pasan todos.

## Antes de dar algo por terminado

Los tres, siempre, y en este orden:

```bash
flutter analyze --fatal-infos     # el CI falla con infos, no solo errores
dart format --set-exit-if-changed .
flutter test
```

El CI está pineado a **Flutter 3.44.8 / Dart 3.12.2**. Si tu SDK local es
más nuevo, `dart format` puede dar distinto que el CI: ante la duda, formatear
con la versión del CI. Ya rompió el CI una vez por esto.

Y si tocaste algo de `android/`: **compilá**. Los tests de Dart no ven una
línea de Kotlin.

## Datos

- Los recorridos y paradas salen de **OpenStreetMap**, importados con
  `tools/osm_import.dart`. Los sirve **Supabase** (PostgREST + PostGIS).
- **La `anon key` de Supabase es pública por diseño** y puede estar en el
  repo. La `service_role` **nunca**: ni en el repo, ni en un chat, ni en una
  captura. RLS es lo que protege la base — ver `docs/auditoria-seguridad.md`.
- **⚠️ NUNCA trazar recorridos mirando Google Maps para cargarlos en OSM.**
  Viola los términos de Google y contamina el dataset para todo el mundo.
  Las únicas fuentes válidas son un GPX propio o las imágenes que el editor
  iD habilita. Está en `docs/aportes-de-campo.md` y no es negociable.

## Lo que no se dice nunca, en ningún canal

**Nada en contra de las apps oficiales, de las empresas de colectivos ni del
municipio** — ni en un posteo, ni en un mail, ni contestando una reseña que
los critique a ellos. Son las mismas instituciones a las que el proyecto les
está pidiendo datos abiertos.

Esto también aplica **a este repositorio**, que es público. Un `git log` o un
comentario son un canal como cualquier otro.

Tampoco: fechas prometidas, ni pedirle a nadie que cambie su calificación.

## Dónde está escrito el resto

| Tema | Archivo |
|---|---|
| Publicar en Play, permisos, firma, declaraciones | `docs/publicacion.md` |
| Seguridad y RLS | `docs/auditoria-seguridad.md` |
| Cuota de Supabase y operación | `docs/operaciones.md` |
| Importar datos de OSM | `docs/osm-import.md` |
| Reportes de campo y cómo cargarlos | `docs/aportes-de-campo.md` |
| Licencia de los datos (ODbL de OSM) | `DATOS.md` |
| Licencia comercial y qué pasa con tu PR | `LICENCIA-COMERCIAL.md` |

## `privado/` no está en el repo

Hay referencias en los docs a archivos bajo `privado/` —estrategia de
comunicación, contactos de prensa, borradores de mails sin mandar—. Están en
el disco y **fuera del control de versiones a propósito**, por dos razones:
tienen datos de contacto de terceros que no me corresponde publicar, y son
decisiones comerciales que no hacen al software.

Si clonaste el repo, esa carpeta no va a existir. No falta nada: ningún
build, test ni migración depende de ella.
| Reglas de la copy pública | `marketing/README.md` |

## Estado

Versión `1.0.0+3`, en **prueba cerrada** de Google Play. Todavía no salió a
producción.
