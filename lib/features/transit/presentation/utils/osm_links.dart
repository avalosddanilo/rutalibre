/// El enlace público al nodo de OpenStreetMap de una parada.
///
/// **Por qué la página del nodo y no el editor** (`/edit?node=<id>`): el
/// editor exige cuenta y sesión abierta, y en un teléfono es casi inusable.
/// La página del nodo se lee sin cuenta, muestra las etiquetas y el historial
/// —o sea que se puede VERIFICAR antes de tocar nada— y desde ahí se llega a
/// editar. Alguien que solo quiere avisar "esto ya no existe" tiene que poder
/// mirar primero.
///
/// `www.` explícito: openstreetmap.org sin el subdominio redirige, y una
/// redirección de más en una conexión de datos flaca es medio segundo que no
/// hace falta gastar.
Uri osmNodeUrl(int nodeId) =>
    Uri.parse('https://www.openstreetmap.org/node/$nodeId');
