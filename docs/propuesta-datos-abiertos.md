# Datos abiertos de transporte para el Gran Resistencia

**Propuesta de colaboración — Ruta Libre**
Danilo Avalos · Resistencia, Chaco

> Documento de trabajo para la reunión con la Secretaría de Transporte.
> Ajustar nombres, fechas y datos de contacto antes de presentarlo.

---

## En una línea

Pido que la provincia **publique los datos del transporte metropolitano en
formato GTFS** —el estándar internacional— para que el Gran Resistencia
aparezca en Google Maps y cualquier vecino pueda construir sobre ellos.

No pido exclusividad, ni dinero, ni acceso a sistemas internos.

---

## Qué hay hecho hoy

Una app funcionando, construida sin presupuesto y sin pedirle nada a nadie:

- **20 líneas y 73 recorridos** del Gran Resistencia con su trazado sobre el
  mapa
- **1.579 paradas** georreferenciadas
- **"¿Qué colectivos pasan por acá?"** tocando cualquier parada
- **Paradas cerca mío** por GPS, con la distancia en metros
- Arranque instantáneo: los listados de líneas, recorridos, paradas y
  horarios quedan guardados en el teléfono y se muestran sin esperar a la
  red. **Sin publicidad y sin registro**

Los datos salen de **OpenStreetMap**, mapeado por la comunidad y con licencia
abierta. Es lo mejor disponible públicamente, y aun así tiene huecos: hay
recorridos con tramos sin mapear y la mayoría de las paradas no tiene nombre.

**Lo que no existe en ninguna fuente pública: los horarios.**

---

## El pedido concreto

### 1. GTFS estático

El paquete estándar con líneas, paradas, recorridos y **frecuencias por franja
horaria y tipo de día**. Un archivo, actualizado cuando cambie el servicio.

### 2. GTFS-Realtime (`VehiclePositions`)

La posición de las unidades en tiempo real.

Entendemos que la flota ya cuenta con seguimiento satelital, porque las
aplicaciones oficiales muestran el arribo de las unidades. Si es así, el
trabajo no es instrumentar los vehículos —lo más caro— sino agregar un
exportador que traduzca las posiciones que ya se reciben al formato
GTFS-Realtime y las publique en un endpoint de lectura.

### Por qué GTFS y no un formato a medida

GTFS es el estándar que consumen **Google Maps, Moovit, Apple Maps** y
cualquier app de movilidad del mundo. Publicarlo no es un favor a un
desarrollador: es la vía por la que el transporte del Gran Resistencia
**aparece en Google Maps**.

Hoy, un turista, un estudiante que llega de otra provincia o un vecino que no
conoce el recorrido **no encuentra el colectivo en Google Maps**, porque el
dato no está publicado en el formato que Google lee.

---

## Qué gana la provincia

| | |
|---|---|
| **Visibilidad** | El transporte metropolitano aparece en Google Maps y Moovit sin costo ni desarrollo. |
| **Transparencia** | Cumple con la política de datos abiertos que ya aplican otras jurisdicciones. |
| **Ecosistema** | Estudiantes de la UNNE y de la UTN pueden construir sobre datos públicos. Cada app que nazca suma, y ninguna le cuesta un peso al Estado. |
| **Cero riesgo operativo** | Es un feed de solo lectura. No toca los sistemas de gestión ni la recaudación. |
| **Costo** | Prácticamente nulo: el dato ya se produce; falta exportarlo. |

**Esto no reemplaza ni compite con la app oficial.** Que los datos sean
públicos hace que la app oficial siga siendo la oficial, y que además existan
otras opciones para quien las quiera.

---

## Ya se hizo en Argentina

- **Ciudad de Buenos Aires** publica su GTFS de colectivos, y con eso Google y
  Moovit muestran el transporte porteño.
  <https://data.buenosaires.gob.ar/dataset/colectivos-gtfs>
- **Córdoba** publica el GTFS del transporte urbano en su portal de gobierno
  abierto.
  <https://gobiernoabierto.cordoba.gob.ar/data/datos-abiertos/categoria/transporte-urbano/gtfs-de-la-ciudada-de-cordoba/3319>
- **Corrientes capital**, del otro lado del puente, ya publica los recorridos
  de sus diez líneas urbanas en su portal de datos abiertos.
  <https://datos.ciudaddecorrientes.gov.ar/dataset?tags=colectivos>

Publicar los datos del Gran Resistencia lo pondría a la par de esas
ciudades.

---

## Cómo seguimos

1. **Publicar el GTFS estático** en el portal de datos de la provincia, con
   una licencia abierta explícita.
2. **Exponer el GTFS-RT** de posiciones, aunque sea con acceso por clave al
   principio.
3. **Registrar el feed** ante Google Maps y Moovit (es un trámite gratuito;
   puedo acompañarlo).

Si hace falta, puedo colaborar sin costo en la especificación técnica del
feed y en validarlo con las herramientas oficiales de GTFS.

---

## Sobre el proyecto

Ruta Libre es un proyecto propio, sin fines comerciales por ahora, con el
código versionado y la arquitectura documentada. No busca reemplazar al
servicio oficial: busca que la información del transporte público sea
**pública de verdad**.

**Contacto:** *(completar: mail / teléfono)*
**Código:** *(completar: link al repositorio, si se decide hacerlo público)*

---

*Los datos de mapa y recorridos actuales provienen de OpenStreetMap,
© OpenStreetMap contributors, bajo licencia ODbL.*
