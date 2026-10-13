# Avisos de servicio: paros y desvíos

El cartel rojo que aparece arriba del mapa. Se carga a mano desde Supabase, y
la app lo muestra en cuanto alguien la abre: no hace falta publicar una versión
nueva.

Necesita la migración `0016_service_alerts.sql` aplicada. Sin ella la app
funciona igual, solo que no hay avisos.

## Cargar un aviso

Supabase → **Table Editor** → `service_alerts` → **Insert row**.

| Campo | Qué poner |
|---|---|
| `title` | Lo que se ve en el mapa. Una línea, hasta 90 caracteres. |
| `body` | Opcional. El detalle que se ve al tocar el aviso. |
| `line_codes` | Opcional. Las líneas afectadas como se ven en la app: `{5,102,904A}`. Vacío = todas. |
| `starts_at` | Cuándo empieza a verse. Por defecto, ya. |
| `ends_at` | Cuándo deja de verse. **Ponelo siempre**: un aviso de paro que queda colgado hasta el día siguiente es peor que no avisar. |
| `is_active` | Destildarlo lo apaga en el momento. |

Lo demás (`id`, `created_at`) se completa solo.

O desde el **SQL Editor**:

```sql
-- Paro hasta la medianoche de hoy (hora de Argentina)
insert into public.service_alerts (title, body, ends_at)
values (
  'Paro de la UTA: hoy no hay colectivos urbanos en el Gran Resistencia',
  'La medida es por 24 horas. El 904 Chaco–Corrientes funciona normal.',
  (date_trunc('day', now() at time zone 'America/Argentina/Buenos_Aires')
     + interval '1 day') at time zone 'America/Argentina/Buenos_Aires'
);

-- Desvío por obras, con las líneas afectadas, por una semana
insert into public.service_alerts (title, line_codes, ends_at)
values (
  'La 5 y la 7 se desvían por obras en Av. Sarmiento',
  '{5,7}',
  now() + interval '7 days'
);
```

## Apagar un aviso antes de tiempo

```sql
update public.service_alerts set is_active = false where title like 'Paro%';
```

## Cómo se escribe un aviso

Un aviso se lee en dos segundos y con el colectivo viniendo.

- **Lo que pasa y a quién afecta, nada más.** "Paro de la UTA: hoy no hay
  colectivos urbanos" sí. "Otra vez sin colectivos por culpa de…" no.
- **Nunca culpar a nadie**: ni al gremio, ni a las empresas, ni a la
  Municipalidad, ni al gobierno. Ruta Libre informa; no opina. Es la misma regla
  que para las redes y los mails.
- **Solo lo confirmado.** Un rumor de paro no es un aviso. Si no hay fuente
  firme (el comunicado del gremio, un medio, la Municipalidad), no se carga.
- **Siempre con vencimiento.** Si no se sabe cuándo termina, poné el final del
  día y renovalo a la mañana.

La app muestra el aviso firmado como "Aviso cargado por Ruta Libre. Si en la
calle ves otra cosa, confiá en lo que ves": es lo que es, una persona avisando.

## Qué ve cada uno

- **El más nuevo, arriba del mapa**, y "+1" si hay otro. Tocarlo abre todos los
  vigentes con su detalle.
- **La X lo cierra para siempre en ese teléfono.** Si cambia algo importante,
  cargá un aviso nuevo en vez de editar el viejo: el que lo cerró no vería el
  cambio.
- **Sin conexión no se ve nada.** A propósito: un aviso de paro viejo, mostrado
  de memoria, es peor que ninguno.
- **La base decide qué está vigente**, no el teléfono: un aviso programado para
  mañana no aparece hoy aunque alguien tenga la hora mal puesta.
