# Horarios

De dónde salen las horas que muestra la pantalla de horarios, y cómo cargar
una línea nueva.

## El problema de fondo

**Ninguna fuente pública publica los horarios del Gran Resistencia.** No hay
GTFS, no hay API, no hay CSV. Lo que existe son imágenes que las empresas
mandan por WhatsApp y que la gente se reenvía. Ver
[propuesta-datos-abiertos.md](propuesta-datos-abiertos.md) — el pedido de
GTFS estático + GTFS-RT a la Secretaría de Transporte es el camino real.

Mientras tanto, esto es el puente: transcribir a mano lo que publican las
empresas, dejando la transcripción **a la vista y versionada** para que
cualquiera pueda revisarla contra la fuente.

## Cómo cargar una línea

1. Escribí un `.txt` en `supabase/seed/horarios/`. Un renglón por
   (recorrido, tipos de día):

   ```
   red | línea | ramal | sentido | tipos de día | salidas
   interurbano-chaco-corrientes | 904 | A | ida | weekday | 05:35, 06:25, 07:15
   ```

   * `ramal` vacío = la línea no tiene ramales.
   * `sentido`: `ida` o `vuelta`.
   * `tipos de día`: `weekday`, `saturday`, `sunday_holiday`. Se unen con
     `+` cuando comparten tabla (`saturday+sunday_holiday`), que es como las
     publican las empresas.
   * Las salidas van como estén en la fuente: el importador las ordena.
     Acepta `05:35` y `05.35` (Ataco Norte usa el punto).
   * Comentarios con `#`. **Poné la fuente y la fecha en el encabezado.**

2. Generá el SQL:

   ```bash
   dart run tools/schedules_import.dart
   ```

3. **Verificá.** El importador imprime cuántas salidas leyó de cada tabla y
   la primera y la última. Compará contra la imagen antes de seguir.

4. Corré `supabase/seed/seed_horarios.sql` en el SQL Editor de Supabase,
   **después** de los seeds de recorridos: los horarios cuelgan de
   `route_variants`. Al final del archivo hay una consulta de control
   comentada que devuelve una fila por tabla cargada.

El SQL es idempotente y **reemplaza** cada (recorrido, tipo de día) entero:
si una empresa saca una salida, desaparece de la base en vez de quedar
colgada.

## Por qué un archivo de texto y no SQL a mano

Por lo mismo que el importador de OSM: [los datos reales se generan, no se
escriben a mano](osm-import.md). Un `insert` por salida son 72 líneas de SQL
que nadie va a leer dos veces; el `.txt` se compara con la foto en dos
minutos. Y si mañana aparece el GTFS, se tira el `.txt` y se cambia el
generador, sin tocar el esquema ni la app.

El parser **aborta** ante cualquier cosa rara (hora fuera de rango, sentido
desconocido, dos tablas para el mismo recorrido y día) en vez de adivinar.
Un horario inventado es peor que no tener horarios: manda a alguien a
esperar un colectivo que no viene.

## Cargado hoy

| Línea | Recorrido | Fuente | Estado |
|---|---|---|---|
| 904 ramal A | Terminal Rcia ↔ Campus UNNE Ctes | Imagen del grupo de WhatsApp "Info Chaco-Corrientes" (ERSA + Ataco Norte), **sin fecha** | ⚠️ Transcripto, **sin verificar contra la empresa** |

## Lo que el esquema todavía no guarda

Salió de mirar las tablas reales, y cada punto es una decisión pendiente:

1. **Los pasos intermedios.** `schedules.departure_time` es UNA hora: la
   salida desde cabecera. Pero la tabla de fin de semana de la 904 publica
   tres (sale de Terminal 06:00, pasa por UNNE Resistencia 06:22, llega a
   UNNE Corrientes 07:30), y quien espera en UNNE Resistencia necesita
   *su* hora, no la de la cabecera. Se arregla con una tabla
   `route_stop_times (schedule_id, stop_id, passes_at)`. Es el cambio de
   esquema más valioso que queda.
2. **Qué empresa hace cada servicio.** En la 904 alternan Ataco Norte y
   ERSA, la fuente lo dice y a la gente le importa. Sería
   `schedules.operator` o una tabla `operators`.
3. **De dónde salió el dato y de cuándo.** Hoy la app muestra con la misma
   cara un horario oficial y una foto de WhatsApp de 2022. Mínimo:
   `source` + `updated_at` por línea, y mostrarlo abajo de la tabla.
4. **Las hojas de servicio.** Lo que publica Ataco Norte para la 902 no es
   una lista de salidas: es una grilla donde cada fila es un coche y las
   columnas son sus vueltas sucesivas, con marcas de "releva línea" /
   "lleva coche" / "retira coche". Para cargarla hay que aplanarla a
   salidas, y hay que entender qué significan las letras S y B (¿ramal?
   ¿terminal?). No la cargues hasta saberlo.
