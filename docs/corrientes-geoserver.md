# El GeoServer del municipio de Corrientes

**Los datos existen, están completos, actualizados y son de ellos.** Este
documento dice exactamente qué hay y cómo se llama cada cosa, que es lo que
convierte un pedido vago en uno que se puede contestar en cinco minutos.

Relevado el **2026-09-21**.

## Qué es

La IDE municipal (`gis.ciudaddecorrientes.gov.ar/idemcc/`) es un visor
Leaflet sobre un **GeoServer**. El visor anterior
(`/gis/transporte_urbano/`) declara sus capas en `capas/publico.js`, y de ahí
sale el inventario: **39 capas en el espacio de nombres `transporte`**.

Endpoint:

```
https://gisdesa.ciudaddecorrientes.gov.ar:8282/geoserver/wms
```

**El WMS está abierto y responde** (`GetCapabilities` verificado el
2026-09-21 desde un navegador en Corrientes). De su propia metadata sale
todo lo que sigue.

### Tres cosas del GetCapabilities que valen oro

**1. El servicio declara que no tiene restricciones.**

```xml
<Fees>NONE</Fees>
<AccessConstraints>NONE</AccessConstraints>
```

Ojo con cómo se usa esto: **no es una licencia** —no dice CC-BY ni dominio
público— y no reemplaza la respuesta del municipio. Pero es una declaración
formal, hecha por ellos, en el estándar OGC, de que el servicio no tiene
costo ni restricciones de acceso. Es el argumento más fuerte que tenemos
para pedir que lo digan explícito.

**2. Hay un espacio de nombres llamado `wfs_idemcc`.**

Además de `transporte:`, varias capas están duplicadas en un workspace cuyo
nombre es, literalmente, **WFS**: `wfs_idemcc:vw_paradas_colectivos`,
`wfs_idemcc:vw_recorrido_total_colectivo`, `wfs_idemcc:vw_recorrido_campus`.

Alguien preparó esas capas *para servirlas por WFS*. El servicio está
apagado, pero la intención quedó escrita en el nombre. Eso convierte el
pedido en "terminen algo que ya empezaron".

**3. El contacto real, que no estaba en ningún lado.**

> Dirección General de S.I.G. — Municipalidad de Corrientes
> Brasil 1282, Corrientes (3400)

Es el área que administra estos datos. Mucho mejor que la casilla genérica
de datos abiertos, que no contestó.

### Y una validación que no esperábamos

El `EX_GeographicBoundingBox` de `transporte:vw_paradas_colectivos` es
**-58.8550 / -58.7147 · -27.5835 / -27.4118**.

El CSV archivado de 2022 (`docs/corrientes-paradas-archivadas.md`) da
**-58.8544 / -58.7164 · -27.5826 / -27.4121**.

Coinciden hasta la tercera decimal. **La copia archivada y la capa viva son
prácticamente el mismo conjunto de paradas**, lo que refuerza lo ya medido:
ese dato de 2022 sigue vigente.

## El inventario completo

### Las dos que resuelven todo

| Capa | Qué es |
|---|---|
| `transporte:vw_paradas_colectivos` | **Las paradas de colectivo urbano.** Es el recurso que el portal de datos dio de baja, vivo y mantenido. |
| `transporte:vw_recorrido_total_colectivo` | El recorrido total de colectivos. |

### Los 29 recorridos por ramal

`transporte:recorrido_ramal_…` — `101_B`, `101_C`, `102_A`, `102_B`, `102_C`,
`103_A`, `103_B`, `103_C_directo`, `103_C_esperanza_montania`, `103_D`,
`104_A`, `104_B`, `104_C`, `104_D`, `105_A`, `105_B`, `105_C_250_viv`,
`105_C_perichon`, `106_A`, `106_B`, `106_C`, `106_D`, `108_AB`, `108_C`,
`109_A_Laguna_Soto`, `109_B_Yecoha`, `110_A`, `110_B`,
`110_C_sta_catalina`.

**Están los 13 que nos faltaban**, el `110_B` incluido — el que ninguna otra
fuente tenía. Y hay uno que no conocíamos: `106_D`.

Los nombres coinciden con los ramales del seed actual (`C 250 VIV.`,
`C PERICHON`, `B YECOHA`, `A LAGUNA SOTO`, `C SANTA CATALINA`), así que el
empalme con lo que ya tenemos es directo.

### Los interurbanos Chaco–Corrientes

| Capa | |
|---|---|
| `transporte:vw_paradas_barranqueras` · `vw_recorrido_barranqueras` | La que cruza a **Barranqueras** |
| `transporte:vw_paradas_campus` · `vw_recorrido_campus` | La del **Campus** |
| `transporte:vw_paradas_sarmiento` · `vw_recorrido_sarmiento` | La **Sarmiento** |

Son los cruces del puente, con paradas de los dos lados.

### De yapa

`transporte:vw_puntos_recarga_sube` — los puntos de recarga SUBE.

## Por qué no se bajó nada: **el WFS está apagado**

Probado desde un navegador en Corrientes, el 2026-09-21. El servidor
responde, y responde bien:

```xml
<ows:ExceptionText>org.geoserver.platform.ServiceException:
  Service WFS is disabled</ows:ExceptionText>
```

**Eso es lo mejor que podía pasar**, y conviene entender por qué:

- **No es el firewall.** No es un permiso, no es una licencia, no es que
  no tengan los datos. El GeoServer contesta con su propio formato de error
  (`ows:ExceptionReport`), o sea que está vivo, sano y atendiendo.
- **Es una casilla.** En GeoServer, WFS se prende desde *Services → WFS →
  Enable WFS*. Un tilde. No hay que exportar nada, ni mantener nada, ni
  subir nada a ningún portal.
- **El WMS sí funciona** — de hecho es lo que dibuja el visor. Pero WMS
  devuelve imágenes: sirve para ver, no para obtener coordenadas.

Desde el contenedor de desarrollo hay además dos muros propios que no son de
ellos: un WAF que bloquea el `GetCapabilities` por HTTP (`403`, event type
`signature`) y un certificado que no valida por HTTPS. **No se evade un
firewall**: lo que corresponde es pedir, y ahora se puede pedir con una
precisión que no teníamos.

## Lo que hay que pedir

En el mismo mail de `docs/mails-para-mandar.md`. Cualquiera de las tres
formas sirve, de menos a más trabajo para ellos:

1. **Habilitar WFS** (*Services → WFS → Enable WFS*), aunque sea solo para
   el workspace `wfs_idemcc`, que ya está armado para eso. Es la opción que
   menos les cuesta —un tilde— y la mejor para los dos: cero trabajo
   recurrente y los datos quedan siempre al día sin que nadie los exporte a
   mano nunca más.
2. **Un export de GeoJSON o shapefile** de `vw_paradas_colectivos` y de los
   `recorrido_ramal_*`.
3. **Republicar el recurso de paradas** en el portal de datos abiertos, que
   es de donde lo sacaron.

Y en las tres: **decir la licencia**, que sigue sin figurar.

## Lo que ya se recuperó del archivo

El visor de 2020 (`/gis/emergencia/`) tenía sus capas exportadas como
GeoJSON dentro de archivos `.js`, y el Internet Archive las conserva. Son
**11 ramales** (101B, 101C, 102A, 102B, 102C, 103B, 106A, 109A, 110A, 110B,
+ Servicio de Combis) en WGS84, con `ramal`, `nombre`, `descrip` (IDA/VUELTA)
y `LINEA`.

De los 13 ramales que nos faltan aporta solo tres —**103B, 110A y 110B**—,
pero el **110B** es el que no tenía absolutamente ninguna otra fuente.

```bash
curl -sSL -o 110B.js \
  "https://web.archive.org/web/20200219id_/http://gis.ciudaddecorrientes.gov.ar/gis/emergencia/layers/110B_5.js"
```

Es de **2020** y sin licencia declarada: vale lo mismo que se dijo en
`docs/corrientes-paradas-archivadas.md`. **No se usa hasta preguntar.**
