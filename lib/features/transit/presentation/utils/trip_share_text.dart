/// El texto que se manda al compartir un viaje.
///
/// Está separado de la pantalla porque es lo único de esta función que se
/// puede testear: abrir el menú de compartir del sistema no se testea, pero
/// que el mensaje diga bien dónde te subís y dónde te bajás, sí.
///
/// Para qué sirve compartir un viaje: es la respuesta honesta al miedo de
/// viajar de noche. No promete seguridad ni marca barrios; le avisa a
/// alguien de confianza por dónde vas a andar. Es lo que la gente ya hace
/// por WhatsApp, escrito solo.
library;

import '../../domain/entities/trip_plan.dart';

/// Mensaje listo para mandar por WhatsApp o donde sea.
///
/// [destinationLat]/[destinationLng] son el punto al que va la persona, no
/// la última parada: se agrega un enlace a OpenStreetMap para que quien lo
/// recibe pueda ver EN UN MAPA a dónde va, sin instalar nada.
///
/// El enlace es a OSM y no a Google Maps por coherencia: los datos de esta
/// app son de OpenStreetMap y el crédito ya es una obligación de licencia.
/// Abre en cualquier navegador.
String tripShareText(
  TripPlan plan, {
  required double destinationLat,
  required double destinationLng,
}) {
  final lines = <String>[
    plan.isDirect
        ? 'Voy en la ${plan.legs.single.displayCode}.'
        : 'Voy en la ${plan.legs.map((leg) => leg.displayCode).join(' y después la ')}.',
  ];

  for (var i = 0; i < plan.legs.length; i++) {
    final leg = plan.legs[i];
    lines.add(
      i == 0
          ? '· Me tomo la ${leg.displayCode} en ${leg.boardStop.name}'
          : '· Me cambio a la ${leg.displayCode} en ${leg.boardStop.name}',
    );
    lines.add('· Me bajo en ${leg.alightStop.name}');
  }

  lines
    ..add('')
    ..add('A dónde voy: ${osmLink(destinationLat, destinationLng)}')
    ..add('Enviado desde Ruta Libre');

  return lines.join('\n');
}

/// Enlace a un punto en openstreetmap.org, con el marcador puesto.
///
/// Seis decimales son ~10 cm: más no agrega nada y alarga el enlace.
String osmLink(double lat, double lng) {
  final latText = lat.toStringAsFixed(6);
  final lngText = lng.toStringAsFixed(6);
  return 'https://www.openstreetmap.org/?mlat=$latText&mlon=$lngText#map=17/$latText/$lngText';
}
