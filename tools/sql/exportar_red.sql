-- La red, como la arma la app: get_planner_network() (0021), las paradas
-- de get_all_stops() y las líneas con su red. Ver
-- tools/comparar_planificador.dart.
select json_build_object(
    'network', public.get_planner_network(),
    'stops', public.get_all_stops(),
    'lines', (select json_agg(json_build_object(
                  'id', l.id, 'code', l.code, 'name', l.name,
                  'color_hex', l.color_hex,
                  'network_code', n.code, 'network_name', n.name))
                from public.lines l
                join public.networks n on n.id = l.network_id));
