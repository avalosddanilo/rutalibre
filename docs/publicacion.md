# Publicar Ruta Libre en Google Play

Todo lo que hay que hacer para sacar la v1.0.0, en orden. Lo que dice
**"lo hacés vos"** requiere credenciales o el teléfono, y no está automatizado
a propósito.

## El orden, en una pantalla

La regla que manda los tiempos: **las cuentas personales de Play creadas
después del 13/11/2023 tienen que correr una prueba cerrada con 12 testers
anotados 14 días SEGUIDOS antes de poder pedir producción.** No hay atajo,
así que el día 0 termina con la prueba cerrada ANDANDO y esos 14 días se
usan para el resto.

| # | Paso | Cuándo | Dónde está |
|---|---|---|---|
| 1 | Keystore + `key.properties` (+ **backup en dos lados**) | día 0 | §2 y §3 |
| 2 | AAB firmado y verificado con `keytool -printcert` | día 0 | §5 |
| 3 | Política de privacidad en una URL pública | día 0 | §4 |
| 4 | Crear la app en Play Console y cargar la ficha | día 0 | §6 |
| 5 | Capturas (**ya están sacadas**: `marketing/capturas/`) | día 0 | §6 |
| 6 | Formulario de seguridad de datos + clasificación | día 0 | §6 |
| 7 | **Prueba cerrada**: subir el AAB y anotar 15-20 testers | día 0 | §7 |
| 8 | Esperar 14 días con 12+ testers sin desanotarse | días 1-14 | §7 |
| 9 | Pedir acceso a producción, subir el AAB, revisión | día 15 | §7 |
| 10 | Publicar y difundir | al aprobar | `lanzamiento.md` |

El plan de esos 14 días —los mails, el video, los grupos, la prensa— está en
[`lanzamiento.md`](lanzamiento.md). Las emergencias, en
[`operaciones.md`](operaciones.md).

---

## 1. Lo que ya está resuelto

| Punto | Estado |
|---|---|
| Nombre visible | **Ruta Libre** (`android:label` y `CFBundleDisplayName`) |
| `applicationId` | `com.rutalibre.rutalibre` — **no se puede cambiar** después de publicar |
| Ícono | Generado desde `BrandMarkPainter`, con capa adaptable y monocroma (Android 13+) |
| Splash | `flutter_native_splash`, fondo `#161616`, con variante para Android 12+ |
| `versionCode` / `versionName` | Salen de `version:` en `pubspec.yaml` (hoy `1.0.0+1` → `versionName 1.0.0`, `versionCode 1`) |
| minSdk / targetSdk | 24 / 36 |
| Permisos | Verificados sobre el manifest **fusionado**: solo `INTERNET`, `ACCESS_COARSE_LOCATION` y `ACCESS_FINE_LOCATION`. Ningún plugin agrega otros |
| Config de firma | `build.gradle.kts` lee `android/key.properties` (que está en `.gitignore`) |

### Por qué esos tres permisos y no menos

- **`INTERNET`**: sin esto no hay datos ni mapa. El template de Flutter solo lo
  declara en debug; el manifest de `main` lo declara explícito para que el
  build de release tenga red.
- **`ACCESS_FINE_LOCATION`** + **`ACCESS_COARSE_LOCATION`**: para "cerca mío",
  el origen del viaje y la distancia caminando. Desde Android 12 **hay que
  declarar las dos**: pedir solo la fina sin la aproximada no funciona.
- **No hay ubicación en segundo plano**, y no la va a haber: es lo que
  dispararía una revisión extra de Google con video justificativo.

> El manifest declara además un bloque `<queries>` con `VIEW` sobre `https`,
> para abrir el nodo de la parada en OpenStreetMap. **No es un permiso** y no
> cambia nada de lo que hay que declarar en la ficha: `<queries>` solo dice qué
> apps de otros puede VER la nuestra, que es lo que Android 11+ exige para
> abrir un enlace. Los permisos siguen siendo tres.

---

## 2. Generar el keystore — **lo hacés vos**

⚠️ **Esta clave es para siempre.** Si la perdés, **no podés volver a publicar
actualizaciones de esta app** con ese `applicationId`. Guardá el `.jks` y las
contraseñas en un gestor de contraseñas y en una copia aparte.

Desde la raíz del repo:

```bash
keytool -genkey -v -keystore ~/ruta-libre-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Te va a pedir una contraseña y algunos datos (nombre, organización, ciudad).
Podés dejar casi todo vacío salvo el nombre.

> `keytool` viene con el JDK. Si no lo encuentra, está dentro de Android
> Studio: `C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe`.

**No guardes el `.jks` dentro del repo.** `.gitignore` ya bloquea `*.jks`,
`*.keystore` y `android/key.properties`, pero lo más seguro es que viva fuera.

---

## 3. Armar `android/key.properties` — **lo hacés vos**

Creá el archivo `android/key.properties` con este contenido, reemplazando los
valores:

```properties
storePassword=LA-CONTRASEÑA-DEL-KEYSTORE
keyPassword=LA-CONTRASEÑA-DE-LA-CLAVE
keyAlias=upload
storeFile=C:/Users/TU-USUARIO/ruta-libre-upload.jks
```

Detalles que hacen fallar el build si se pasan por alto:

- `storeFile` con **barras normales** (`/`), también en Windows.
- Ruta **absoluta**, o relativa a `android/`.
- Sin comillas y **sin espacios** alrededor del `=`.

Para confirmar que Gradle lo tomó: si el archivo **no** existe, el build de
release usa la clave de debug y Play lo rechaza. Se verifica en el paso 5.

---

## 4. Política de privacidad — **lo hacés vos** (pero ya está escrita)

Google **exige una URL pública** porque la app pide ubicación.

El texto está completo y al día en
[`politica-de-privacidad.md`](politica-de-privacidad.md) —contacto incluido— y
**ya está armado como página web lista para publicar** en
[`site/privacidad/index.html`](../site/privacidad/index.html): un solo archivo,
sin dependencias, con modo claro y oscuro. Se abre en el navegador para verlo.

Dos formas de darle una URL, de menos a más trabajo:

1. **Un repo público aparte** (recomendado). Creá `rutalibre-privacidad`, subí
   ese `index.html` en la raíz y activá GitHub Pages. Queda
   `https://<tu-usuario>.github.io/rutalibre-privacidad/`.
2. **GitHub Pages en este repo.** ⚠️ **Ojo con esto**: si apuntás Pages a la
   carpeta `/docs`, se publica TODO lo que hay ahí — incluida la auditoría de
   seguridad y los borradores de los mails. Si vas por acá, servís `site/` con
   una Action, no `/docs`.

Después, pegá la URL en Play Console → *Contenido de la aplicación → Política de
privacidad*.

> **Antes de hacer público el repo del código**, revisá qué hay en `docs/`:
> `auditoria-seguridad.md` describe la superficie de ataque del proyecto y
> `mails-para-mandar.md` tiene borradores dirigidos a personas con nombre y
> apellido. Ninguno de los dos tiene secretos, pero ninguno de los dos fue
> escrito para leerse de afuera.

---

## 5. Generar el AAB firmado — **lo hacés vos**

El AAB es lo que sube a Play (el APK sirve para probar a mano).

```bash
flutter build appbundle --release --dart-define-from-file=env.json
```

⚠️ **El `--dart-define-from-file=env.json` no es opcional.** Sin él la app
compila igual pero **crashea al abrir**: `main()` verifica que estén las claves
de Supabase y aborta con un mensaje explícito. No hay forma de que Play detecte
esto — te enterarías por las reseñas.

El archivo queda en:

```
build/app/outputs/bundle/release/app-release.aab
```

### Verificar que quedó firmado con TU clave (no con la de debug)

```bash
keytool -printcert -jarfile build/app/outputs/bundle/release/app-release.aab
```

El `CN=` tiene que ser el nombre que pusiste al generar el keystore. Si dice
`CN=Android Debug`, `key.properties` no se leyó — revisá la ruta de
`storeFile`.

### Probar el release antes de subirlo

```bash
flutter build apk --release --dart-define-from-file=env.json
```

E instalá `build/app/outputs/flutter-apk/app-release.apk` en el teléfono. Un
build de release puede romperse donde el de debug anda (el árbol de íconos se
poda distinto, por ejemplo). **Probalo antes de subir, no después.**

---

## 6. Ficha de Play Console — **lo hacés vos**

**Los textos ya están escritos y con los caracteres contados**:
[`ficha-play.md`](ficha-play.md). Se copian y se pegan.

| Campo | Qué hace falta |
|---|---|
| Nombre | Ruta Libre |
| Descripción corta | ✅ en [`ficha-play.md`](ficha-play.md) |
| Descripción completa | ✅ en [`ficha-play.md`](ficha-play.md) |
| Novedades de la versión | ✅ en [`ficha-play.md`](ficha-play.md) |
| Ícono de la ficha | 512×512 PNG. Sale de `assets/branding/icon.png` (1024×1024, redimensionar) |
| Gráfico destacado | ✅ `assets/branding/feature_graphic.png`, 1024×500 exactos. Se regenera con `REGEN_BRAND=1 flutter test test/brand/brand_assets_test.dart` |
| Capturas | ✅ **Ya sacadas**, 1080×2400, en `marketing/capturas/` |
| Categoría | Mapas y navegación (o Viajes y guías locales) |
| Clasificación de contenido | Cuestionario. Sin contenido sensible |
| **Seguridad de los datos** | Ver abajo — es el que más se equivoca |

### Qué capturas subir

Ya están sacadas de la app real en `marketing/capturas/`. Cuatro alcanzan, y
este orden es el que vende —la primera decide la instalación:

1. `01-mapa-paradas.png` — el mapa con las paradas y el panel abajo.
2. `03-como-llego.png` — "6 líneas te llevan directo", con el paso a paso.
3. `08-alarma-armada.png` — "Faltan 10 paradas" en vivo + el interruptor.
4. `09-alarma-sonando.png` — "¡Preparate para bajar!", la que se recuerda.

Si entran más, sumar `04-viaje-elegido` (el recorrido dibujado con "Iniciar
viaje") y `07-cartel-chofer` (el número gigante).

### Formulario de "Seguridad de los datos"

Lo que corresponde declarar, según lo que la app hace de verdad:

- **¿Recolecta datos?** → *La app recolecta ubicación aproximada y precisa.*
- **¿Se transmiten a terceros?** → **Sí** (las coordenadas van a la base para
  resolver la consulta).
- **¿Se almacenan?** → **No.** Las coordenadas se usan para resolver la
  consulta y no se guardan ni se asocian a una identidad.
- **¿Es obligatoria?** → **No.** La app funciona sin el permiso.
- **¿Para qué?** → *Funcionalidad de la aplicación.*
- **¿Hay cuentas / identificadores de usuario?** → **No.**

Declarar de menos acá es motivo de suspensión. Si dudás entre dos opciones,
elegí la que declara más.

---

## 7. La prueba cerrada — el paso que marca el calendario

**Cuenta personal creada después del 13/11/2023 = prueba cerrada obligatoria
antes de producción**: 12 testers como mínimo, anotados **14 días corridos**.
(Era 20 testers hasta diciembre de 2024.) Nada de esto se puede acelerar
pagando ni pidiéndolo amablemente, así que arranca el día 0.

1. Play Console → **Prueba → Prueba cerrada** → crear la versión y subir el
   AAB.
2. Crear una lista de testers **por correo electrónico** y agregar 15-20
   personas. Doce es el mínimo legal: **hay que llevar margen**, porque el
   que desinstala o se desanota te rompe la racha y el contador vuelve a
   empezar.
3. Mandarles el enlace de aceptación. **Anotarse no es instalar**: cada
   persona tiene que (a) aceptar la invitación, (b) instalar desde Play y
   (c) **quedarse anotada las dos semanas**. El mensaje de WhatsApp para
   pedirlo está en [`lanzamiento.md`](lanzamiento.md).
4. A los dos días, verificar en Play Console cuántos hay anotados de verdad.
   Si son menos de 15, reclutar más ahí mismo.
5. Durante los 14 días: mirar **Calidad → Android vitals** (cierres y ANR) y
   arreglar solo lo grave. Se puede subir un AAB nuevo a la prueba sin
   reiniciar el contador de días.
6. Cumplidos los 14 días con 12+ anotados, en el panel aparece **"Solicitar
   acceso a producción"**. Google pregunta qué aprendiste de la prueba:
   contestar con la verdad —los hallazgos de campo están en el CHANGELOG—.
7. Aprobado eso: subir el AAB a **producción**, completar el lanzamiento y
   esperar la revisión (de horas a unos días).

## 8. Después de publicar

- Cada versión nueva necesita **`versionCode` mayor**: se sube tocando
  `version:` en `pubspec.yaml` (`1.0.0+1` → `1.0.1+2`).
- **Guardá el keystore.** Otra vez: sin él no hay actualizaciones nunca más.
- Contestá todas las reseñas, las malas primero. El resto del primer mes
  está en [`lanzamiento.md`](lanzamiento.md).

---

## Estado del checklist

- [x] Ícono, splash y nombre
- [x] `versionCode` / `versionName` cableados a `pubspec.yaml`
- [x] Permisos mínimos, verificados sobre el manifest fusionado
- [x] Config de firma leyendo `key.properties`, con `.gitignore` cubriendo las claves
- [x] Política de privacidad escrita, al día y armada como página web
- [x] CHANGELOG de la v1.0
- [x] Textos de la ficha, con los caracteres contados por un test
- [x] Gráfico destacado 1024×500, generado en código
- [x] Capturas de pantalla, de la app real (`marketing/capturas/`, 2026-08-28)
- [x] Migración `0011` corrida en el Dashboard (2026-08-28) — el planificador
      contesta los viajes cortos en menos de un segundo
- [ ] Keystore generado y guardado *(vos)* ← **es el bloqueante de todo**
- [ ] `android/key.properties` creado *(vos)*
- [ ] Política de privacidad publicada en una URL *(vos)*
- [ ] APK de release probado en el teléfono *(vos)*
- [ ] AAB firmado y verificado con `keytool -printcert` *(vos)*
- [ ] Formulario de seguridad de los datos *(vos)*
- [ ] Prueba cerrada creada con 15-20 testers *(vos)* — §7, el reloj de los
      14 días no arranca hasta que estén anotados
- [x] Transbordo de `plan_trip` verificado contra la base real: 124 transbordos
      auditados, 0 rotos (`dart run tools/verify_transfers.dart`, 2026-08-25)
- [x] Migración `0010` corrida en el Dashboard (2026-08-25)
- [ ] Verificaciones de RLS en el dashboard de Supabase *(vos)* — las 5 de
      [`auditoria-seguridad.md`](auditoria-seguridad.md), S2
- [ ] Alerta de uso de Supabase al 50% y 80% *(vos)* — S4 de la misma
      auditoría. Es lo único que avisa de un abuso de cuota antes de que
      llegue el resumen de la tarjeta
