/// Los tiempos y las curvas de la app, en un solo lugar.
///
/// Por qué existe este archivo: una interfaz se siente "hecha" o "improvisada"
/// según si sus animaciones parecen la misma mano. Con duraciones sueltas por
/// las pantallas (200 acá, 350 allá, `Curves.easeInOut` porque sí) cada
/// transición cuenta un ritmo distinto y el conjunto se lee como parches
/// pegados. Son tres números y dos curvas; el valor está en que sean SIEMPRE
/// los mismos.
///
/// La regla de reparto: la duración la manda cuánto se mueve el elemento, no
/// cuán importante es. Algo que aparece en el lugar es rápido; algo que
/// atraviesa la pantalla necesita más tiempo o se siente arrancado.
library;

import 'package:flutter/animation.dart';

abstract final class Motion {
  /// Cambios en el lugar: un ícono que se cambia por otro, un color, una
  /// opacidad. Tan corto que no se percibe como animación, que es el punto:
  /// solo saca el parpadeo.
  static const quick = Duration(milliseconds: 150);

  /// Lo normal: algo que crece, se acomoda o entra desde cerca. La mayoría
  /// de la app vive acá.
  static const base = Duration(milliseconds: 260);

  /// Recorridos largos: un panel que sube, una pantalla que entra. Menos que
  /// esto se siente apurado y más se siente lento.
  static const long = Duration(milliseconds: 420);

  /// La curva de casi todo. Arranca decidido y frena suave, que es como se
  /// mueven las cosas con masa. `easeInOut` —el default de Flutter— arranca
  /// lento y por eso se siente pesado al tocar.
  static const curve = Curves.easeOutCubic;

  /// Para lo que ENTRA a escena con ganas: un botón que aparece, un cartel
  /// que baja. El pequeño sobrepaso lo hace sentir físico. No usarla para
  /// algo que se va: rebotar al salir se lee como un error.
  static const entrance = Curves.easeOutBack;

  /// Cuánto se corre en el tiempo cada elemento de una lista que entra
  /// escalonada. Más que esto y el último tarda tanto que parece que la
  /// lista se cuelga.
  static const stagger = Duration(milliseconds: 40);

  /// Tope de elementos que se escalonan. El resto entra junto con el último.
  ///
  /// Sin tope, una lista de 40 paradas tardaría 40 × [stagger] = 1,6 s en
  /// terminar de aparecer, y para entonces la persona ya está scrolleando
  /// sobre cosas que todavía se están dibujando.
  static const staggerCap = 8;
}
