-- ====================================================================
-- 0009 — Los destinos de cada línea, y separar el interurbano
--
-- Dos problemas distintos que se arreglan juntos porque los dos son
-- "la línea que buscás está, pero no la encontrás".
--
-- 1. `lines.name` es un RESUMEN que entra en un renglón: a partir del
--    tercer destino dice "y N más". La línea 3 termina en el Shopping
--    Sarmiento y su nombre guardado es
--    'Vial ↔ Los Troncos / Monte Alto y 1 más' — buscar "Sarmiento" no
--    la encontraba. Truncar es una decisión de PANTALLA; la base tiene
--    que guardar la lista completa y que cada pantalla decida cuánto
--    muestra.
--
-- 2. La red 'interurbano-chaco-corrientes' juntaba tres líneas de las
--    cuales DOS no cruzan a Corrientes: Colonia Benítez y Puerto Tirol
--    están en Chaco. Quien abre "Chaco – Corrientes" quiere cruzar el
--    Paraná, no ir a Puerto Tirol.
--
-- Idempotente y tolerante a que falte una migración anterior, porque
-- estas se corren A MANO y sin orden garantizado.
-- ====================================================================

begin;

-- ------------------------------------------------------------
-- 1. Los destinos completos de cada línea
-- ------------------------------------------------------------
alter table public.lines
    add column if not exists destinations text[] not null default '{}';

comment on column public.lines.destinations is
    'Todas las cabeceras y destinos de la línea, la primera es el tronco. '
    '`name` es un resumen de esto que entra en un renglón; esta lista es la '
    'que hace que el buscador encuentre un destino que el nombre tapa.';

-- ------------------------------------------------------------
-- 2. La red interurbana que NO sale de la provincia
-- ------------------------------------------------------------
insert into public.networks (code, name, city, sort_order) values
    ('interurbano-chaco', 'Interurbano Chaco', 'Chaco', 2)
on conflict (code) do update
    set name = excluded.name,
        city = excluded.city,
        sort_order = excluded.sort_order,
        is_active = true;

-- La que ya existía se queda SOLO con lo que de verdad cruza a Corrientes,
-- y se corre un lugar para que el orden quede
-- Gran Resistencia → Interurbano Chaco → Chaco ↔ Corrientes → Corrientes.
update public.networks
   set name = 'Chaco ↔ Corrientes',
       city = 'Resistencia ↔ Corrientes',
       sort_order = 3
 where code = 'interurbano-chaco-corrientes';

update public.networks
   set sort_order = 4
 where code = 'corrientes-capital';

-- Mudanza de las dos líneas que estaban mal clasificadas.
--
-- Va por código y no por nombre porque el nombre lo reescribe cada
-- reimportación. Y no falla si no están: en una base donde todavía no se
-- corrió el seed, esto simplemente no toca ninguna fila.
update public.lines l
   set network_id = (select id from public.networks
                      where code = 'interurbano-chaco')
  from public.networks n
 where l.network_id = n.id
   and n.code = 'interurbano-chaco-corrientes'
   and l.code in ('RES-CB', 'Tirol');

commit;

-- ====================================================================
-- Después de esta migración conviene RECORRER los seeds
-- (seed_gran_resistencia.sql y seed_corrientes.sql): son los que llenan
-- `destinations`. Sin eso la columna queda vacía y el buscador sigue
-- encontrando solo lo que diga el nombre — que es como está hoy, así que
-- no rompe nada mientras tanto.
-- ====================================================================
