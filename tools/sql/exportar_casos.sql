-- 300 viajes entre paradas al azar (semilla fija: siempre los mismos) con
-- lo que contesta plan_trip_v2. Ver tools/comparar_planificador.dart.
select setseed(0.42) \gset
with p as (
    select row_number() over () as i,
           st_y(a.geom::geometry) as olat, st_x(a.geom::geometry) as olng,
           st_y(b.geom::geometry) as dlat, st_x(b.geom::geometry) as dlng
      from (select geom, row_number() over (order by random()) r
              from public.stops where is_active) a
      join (select geom, row_number() over (order by random()) r
              from public.stops where is_active) b on a.r = b.r
     limit 300
)
select json_agg(json_build_object(
           'i', i,
           'o', json_build_array(olat, olng),
           'd', json_build_array(dlat, dlng),
           'sql', public.plan_trip_v2(olat, olng, dlat, dlng))
       order by i)
  from p;
