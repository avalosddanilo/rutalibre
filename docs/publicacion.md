# Publicar Ruta Libre en Google Play

Todo lo que hay que hacer para sacar la v1.0.0, en orden. Lo que dice
**"lo hacés vos"** requiere credenciales o el teléfono, y no está automatizado
a propósito.

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
| Capturas | Mínimo 2 de teléfono. **Es lo único que falta y necesita el teléfono** |
| Categoría | Mapas y navegación (o Viajes y guías locales) |
| Clasificación de contenido | Cuestionario. Sin contenido sensible |
| **Seguridad de los datos** | Ver abajo — es el que más se equivoca |

### Qué capturas sacar

Cuatro alcanzan, y en este orden —la primera es la que decide la instalación:

1. El mapa con las paradas visibles y el panel abajo.
2. El resultado de "¿cómo llego?" con un viaje elegido dibujado.
3. Un paso de "Iniciar viaje" (la guía grande).
4. El detalle de una parada con "qué colectivos pasan por acá".

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

## 7. Después de publicar

- Subí a **prueba interna** primero, instalá desde ahí y recién después promové
  a producción.
- Cada versión nueva necesita **`versionCode` mayor**: se sube tocando
  `version:` en `pubspec.yaml` (`1.0.0+1` → `1.0.1+2`).
- **Guardá el keystore.** Otra vez: sin él no hay actualizaciones nunca más.

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
- [ ] Keystore generado y guardado *(vos)*
- [ ] `android/key.properties` creado *(vos)*
- [ ] Política de privacidad publicada en una URL *(vos)*
- [ ] APK de release probado en el teléfono *(vos)*
- [ ] AAB firmado y verificado con `keytool -printcert` *(vos)*
- [ ] Capturas de pantalla *(vos — necesitan el teléfono)*
- [ ] Formulario de seguridad de los datos *(vos)*
- [x] Transbordo de `plan_trip` verificado contra la base real: 124 transbordos
      auditados, 0 rotos (`dart run tools/verify_transfers.dart`, 2026-08-25)
- [x] Migración `0010` corrida en el Dashboard (2026-08-25)
- [ ] Verificaciones de RLS en el dashboard de Supabase *(vos)* — las 5 de
      [`auditoria-seguridad.md`](auditoria-seguridad.md), S2
- [ ] Alerta de uso de Supabase al 50% y 80% *(vos)* — S4 de la misma
      auditoría. Es lo único que avisa de un abuso de cuota antes de que
      llegue el resumen de la tarjeta
