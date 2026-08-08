import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../app/theme/motion.dart';
import '../../../../app/widgets/floating_panel.dart';
import '../../../../core/providers/clock_provider.dart';
import '../../domain/entities/rain_forecast.dart';
import '../providers/weather_providers.dart';
import '../utils/rain_advisory.dart';

/// El indicador de lluvia del mapa, arriba a la izquierda.
///
/// Cerrado es una gotita y un porcentaje. Tocándolo se abre y cuenta qué
/// significa eso para el colectivo.
///
/// **Por qué chiquito y por qué se abre en vez de decirlo todo de una**: la
/// probabilidad es lo único que se mira de reojo, y ocupa cuatro caracteres.
/// La advertencia es una frase que hay que leer, y una frase permanente
/// arriba del mapa se vuelve parte del decorado a los dos días. Cerrado no
/// tapa nada; abierto tapa un rato porque lo pediste vos.
///
/// **Si no se espera lluvia no aparece**, y si el pronóstico falla —sin
/// señal, servicio caído— tampoco: no saber si llueve no puede romperle la
/// pantalla a alguien que está tratando de tomarse un colectivo.
class RainChip extends ConsumerStatefulWidget {
  const RainChip({required this.lat, required this.lng, super.key});

  final double lat;
  final double lng;

  @override
  ConsumerState<RainChip> createState() => _RainChipState();
}

class _RainChipState extends ConsumerState<RainChip> {
  /// Estado de UI puro y de un solo widget: no va a un provider. Riverpod es
  /// para el estado de la app, no para si una tarjeta está abierta.
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final forecast = ref
        .watch(rainForecastProvider(coarsePoint(widget.lat, widget.lng)))
        .value;
    if (forecast == null) return const SizedBox.shrink();

    final advisory = rainAdvisory(forecast, ref.watch(clockProvider)());
    if (advisory == null) return const SizedBox.shrink();

    final dark = Theme.of(context).brightness == Brightness.dark;
    final accent = dark ? _darkAccent : _lightAccent;
    final textTheme = Theme.of(context).textTheme;

    // El aire de arriba lo pone el chip y no quien lo ubica, porque el chip
    // es lo único que sabe si se va a dibujar: un Padding afuera dejaría
    // ocho píxeles de hueco los días de sol.
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Semantics(
        button: true,
        // El lector de pantalla se lleva la frase entera aunque el chip esté
        // cerrado: para alguien que no ve el mapa, "60%" solo no dice nada.
        label: advisory.hasProbability
            ? '${advisory.probabilityPercent}% de probabilidad de lluvia. '
                  '${advisory.headline} ${advisory.detail}'
            : '${advisory.headline} ${advisory.detail}',
        child: ExcludeSemantics(
          // El radio se ANIMA con la apertura: cerrado es una píldora, porque
          // es un chip; abierto tiene que ser una tarjeta, porque una píldora
          // de cuatro renglones se ve como un globo de historieta. Sin animar
          // el radio pega un salto justo cuando el alto está creciendo, que
          // es donde más se nota. `TweenAnimationBuilder` a mano, como el
          // resto de las animaciones de la app.
          child: TweenAnimationBuilder<double>(
            tween: Tween(
              end: _expanded ? AppTheme.radius : AppTheme.pillRadius,
            ),
            duration: Motion.base,
            curve: Motion.curve,
            builder: (context, radius, child) => FloatingPanel(
              radius: radius,
              padding: const EdgeInsets.fromLTRB(10, 7, 12, 7),
              onTap: () => setState(() => _expanded = !_expanded),
              child: child!,
            ),
            child: AnimatedSize(
              duration: Motion.base,
              curve: Motion.curve,
              alignment: Alignment.topLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        // Dos gotas cuando llueve en serio y una cuando
                        // chispea: la intensidad se lee sin abrir nada.
                        advisory.intensity == RainIntensity.strong
                            ? Icons.grain
                            : Icons.water_drop_outlined,
                        size: 15,
                        color: accent,
                      ),
                      if (advisory.hasProbability) ...[
                        const SizedBox(width: 5),
                        Text(
                          '${advisory.probabilityPercent}%',
                          style: textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                      const SizedBox(width: 4),
                      // La flechita es lo único que avisa que esto se toca. Sin
                      // ella el chip se lee como un cartel y nadie lo abre.
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: Motion.base,
                        curve: Motion.curve,
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          size: 15,
                          color: textTheme.labelMedium?.color?.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_expanded)
                    ConstrainedBox(
                      // Tope duro para que abierto siga siendo un cartelito y
                      // no una pantalla: sobre un teléfono chico, sin esto el
                      // texto se estira hasta el borde y tapa media ciudad.
                      constraints: const BoxConstraints(maxWidth: 200),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6, right: 2),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '${advisory.headline} ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              TextSpan(text: advisory.detail),
                            ],
                          ),
                          style: textTheme.bodySmall,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// El ámbar de la gotita.
///
/// **No sale del `ColorScheme`.** El esquema está sembrado del acento de
/// marca, así que sus colores son todos variaciones del mismo tono y el
/// indicador quedaría indistinguible del panel que lo rodea. Ámbar es el
/// único color de la app que significa "ojo" sin significar "error" — el
/// rojo diría que algo se rompió, y no se rompió nada: llueve.
///
/// No hace falta cruzarlo contra `linePalette` como a los de
/// `marker_colors.dart`: es el tinte de un ícono dentro de un panel, no un
/// marcador sobre el mapa, así que no compite con ningún recorrido.
const _lightAccent = Color(0xFFB26A00);
const _darkAccent = Color(0xFFFFB74D);
