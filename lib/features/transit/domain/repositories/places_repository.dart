import '../../../../core/utils/result.dart';
import '../entities/place.dart';

/// Contrato de los lugares. Mismas reglas que `TransitRepository`: nunca
/// lanza, todo error llega como `Failure` adentro del `Either`.
abstract interface class PlacesRepository {
  /// Todos los lugares conocidos.
  ///
  /// **Sin cache propia**: salen de un asset empaquetado, así que leerlos ya
  /// es leer del disco del teléfono. Cachear una cache no aporta nada; lo que
  /// sí importa es no leerlos hasta que alguien los pida, y de eso se encarga
  /// el provider.
  Result<List<Place>> getPlaces();
}
