# Frecuencias oficiales del 904 (y por qué no alcanzan para armar horarios)

Buscando fuentes públicas de horarios apareció algo mejor que un rumor y peor
que un GTFS: **el pliego que rige el permiso del 904 es público, es citable y
fija una banda de frecuencias**. No fija horas de salida. Este documento deja
asentado qué dice exactamente, de dónde sale y hasta dónde se puede usar.

## La cadena normativa, entera

| Norma | Fecha | Qué hace |
|---|---|---|
| **Resolución 141-E/2017** SECGT#MTR | 19/12/2017 | Aprueba el **Pliego de Condiciones Particulares** del concurso de la **Línea 904** (Anexo II, `IF-2017-33615527-APN-SECGT#MTR`). Además adjudica la **Línea 902** a ATACO NORTE S.A.C.I. |
| **Resolución 7-E/2018** | 18/01/2018 | Autoriza a **Puerto Tirol SRL** en forma **precaria**, obligada a los parámetros del Anexo II de la 141/2017 |
| **Resolución 55/2018** SECGT#MTR | 04/04/2018 | Permiso precario — es el "Último Anexo" que la Nación publica como recorrido vigente |
| **Resolución 113/2018** SECGT#MTR | 17/07/2018 | **Adjudica el 904 a ERSA URBANO S.A. por DIEZ (10) años**, *"de conformidad con las especificaciones y parámetros operativos establecidos en el PLIEGO DE CONDICIONES PARTICULARES"* de la 141/2017 |

El permiso figura como **DEFINITIVO y vigente** en el listado oficial
`permisos_vigentes_de_lineas_urbanas_-junio_2024.pdf` del Ministerio de
Transporte. Corre hasta 2028.

**Traducción**: las frecuencias del Anexo II de la 141/2017 **no son un
antecedente histórico, son la condición del permiso que ERSA opera hoy.**

## Lo que dice el Anexo II, textual

> **Horarios.** Los servicios comunes básicos se prestarán durante las
> VEINTICUATRO (24) horas del día, previa aprobación de los cuadros horarios
> por la COMISIÓN NACIONAL DE REGULACIÓN DEL TRANSPORTE […]. Dicha frecuencia
> responde al siguiente detalle […]:
>
> - **Recorrido A**: no podrá ser superior a UN (1) servicio cada CINCUENTA
>   (50) minutos ni inferior a CIEN (100) minutos […], con parque máximo y
>   mínimo respectivamente, en las denominadas horas pico.
> - **Recorrido B**: no podrá ser superior a UN (1) servicio cada DIEZ (10)
>   minutos ni inferior a DOCE (12) minutos […], con parque máximo y mínimo
>   respectivamente, en las denominadas horas pico.
> - **Recorrido C**: no podrá ser superior a UN (1) servicio cada DOCE (12)
>   minutos ni inferior a QUINCE (15) minutos, con parque máximo y mínimo
>   respectivamente, en las denominadas horas pico.
>
> **Material Rodante.** Parque máximo: TRECE (13) vehículos. Parque mínimo:
> DIEZ (10) vehículos.

### Las tres cosas que el documento tiene mal

No son erratas de la transcripción: están en el original firmado.

1. **"ni inferior a CIEN (100) minutos *segundos*"** — dice las dos unidades,
   en A y en B. En C ya no.
2. **"superior"/"inferior" están al revés de como se leen.** Un servicio cada
   50 minutos es un intervalo MENOR que uno cada 100. Se entiende recién con
   el final del renglón: *"con parque máximo y mínimo respectivamente"* — con
   los 13 coches se cumple el extremo corto, con 10 el largo. Es una banda de
   intervalos, no un piso y un techo de frecuencia.
3. **El parque figura una sola vez para los tres recorridos.** Con 13 coches
   no se sostiene el B cada 10 minutos *y* el C cada 12 *y* el A cada 50 al
   mismo tiempo: un round trip Resistencia–Corrientes ronda los 70 minutos.
   O el parque es por recorrido y el pliego no lo aclara, o el número está
   mal. **No se puede deducir cuál.**

## Por qué esto NO se convierte en la tabla `schedules`

Una banda regulatoria dice *cada cuánto*, nunca *a qué hora*. Aunque la banda
fuera perfecta, sigue faltando la hora de la primera salida, la de la última,
dónde empieza y termina la "hora pico" —que el pliego no define— y qué pasa
sábados, domingos y feriados. **Inventar salidas a partir de esto sería
exactamente lo que la regla del proyecto prohíbe**: un horario inventado manda
a alguien a esperar un colectivo que no viene.

Los cuadros horarios reales existen, pero **los aprueba la CNRT y no los
publica**. Eso refuerza el pedido de `docs/propuesta-datos-abiertos.md`: lo que
falta no es que el dato exista, es que sea abierto.

### Lo que sí se puede mostrar

La banda, **citada y fechada**, como respuesta a "¿cada cuánto pasa?" cuando no
hay horarios cargados. Es verificable, tiene fuente y es honesta:

> Frecuencia regulada: 1 servicio cada 10 a 12 minutos en hora pico.
> Fuente: Anexo II, Resolución 141/2017 — condición del permiso de ERSA.

## De yapa: el documento oficial confirma nuestros ramales

El recorrido publicado por la Nación
(`argentina.gob.ar/sites/default/files/recorridos_web_0/904 - ERSA.pdf`)
describe los tres servicios así:

| Ramal | Descripción oficial | Cabeceras oficiales | Lo que teníamos |
|---|---|---|---|
| **A** | *(ver nota)* | Terminal de Ómnibus de Resistencia ↔ Campus UNNE | "por el Campus de la UNNE" ✅ |
| **B** | **por AVENIDA SARMIENTO** | UNNE (Resistencia) ↔ Puerto de Corrientes | "por Avenida Sarmiento" ✅ |
| **C** | **por BARRANQUERAS** | UNNE (Resistencia) ↔ Puerto de Corrientes | "por Barranqueras" ✅ |

Los tres coinciden. Vale la pena subrayarlo porque **B y C se habían decidido
midiendo geometría contra el callejero, no leyendo un papel**: el 904B tenía
117 de 487 vértices sobre Avenida Sarmiento y pasaba a 5,4 km de Barranqueras;
el 904C, cero sobre esa avenida y 450 m de Barranqueras. El documento oficial
apareció después y dijo lo mismo. La regla de `lineIdentityFor` —que cruzando
el puente el ramal SÍ es la línea— queda respaldada por la fuente.

> **Nota sobre el ramal A.** El PDF oficial lo rotula *"Recorrido A por
> BARRANQUERAS"*, pero su propio itinerario no pasa por Barranqueras: va por
> Mac Lean, Alvear, Vedia, Mendoza, Cervantes, Las Heras, Franklin, Alberdi,
> Juan B. Justo, Frondizi, 9 de Julio, Diagonal Eva Perón, San Martín, Puente
> Belgrano y sigue por Corrientes hasta el Campus. Es un copiar-pegar del
> ramal C en el rótulo. **Le creemos al itinerario, no a la etiqueta** — igual
> que el importador de OSM le cree al `name` antes que al `ref`.

También cierra otra punta: la 141/2017 adjudica la **Línea 902 a ATACO NORTE
S.A.C.I.**, que es la empresa de la foto de horarios del 902. Y el Recorrido A
—Terminal Resistencia ↔ Campus UNNE— es el de la otra foto, la que ya está
cargada en `seed_horarios.sql`.

## El marco cambió en 2024

El **Decreto 830/2024** (16/09/2024) **abrogó el Decreto 656/94**, que era el
marco bajo el cual se dictó este pliego. El 830/2024 mantiene la categoría
—su artículo 21 sigue previendo *"frecuencias horarias límites, máximas y
mínimas"* para los servicios públicos— y su artículo 2 sigue alcanzando a los
servicios interprovinciales urbanos y suburbanos del interior del país, que es
donde cae el 904 (Unidad Administrativa N° 5).

**Lo que no se verificó**: si los parámetros del 904 fueron reemitidos bajo el
marco nuevo. El listado de permisos vigentes de junio de 2024 es anterior al
decreto. Antes de mostrar la banda en la app conviene chequearlo, o fecharla
explícitamente como lo que es: la condición del permiso **según el pliego de
2017**.

## Fuentes

- [Resolución 141-E/2017 — Boletín Oficial, 21/12/2017](https://www.boletinoficial.gob.ar/detalleAviso/primera/176455/20171221)
  (Anexo II descargable desde esa misma página)
- [Resolución 113/2018 — Boletín Oficial, 19/07/2018](https://www.boletinoficial.gob.ar/detalleAviso/primera/188257/20180719)
- [Recorridos oficiales del 904 — ERSA URBANO S.A.](https://www.argentina.gob.ar/sites/default/files/recorridos_web_0/904%20-%20ERSA.pdf)
- [Permisos vigentes de líneas urbanas, junio 2024](https://www.argentina.gob.ar/sites/default/files/permisos_vigentes_de_lineas_urbanas_-junio_2024.pdf)
- [Decreto 830/2024 — texto](https://www.argentina.gob.ar/normativa/nacional/decreto-830-2024-404098/texto)
- [Resolución 7-E/2018, permiso precario a Puerto Tirol SRL](https://www.ellitoral.com.ar/corrientes/2018-1-23-10-55-0-autorizaron-a-una-empresa-chaquena-a-hacer-del-recorrido-entre-corrientes-y-resistencia)
  (cobertura de El Litoral)
