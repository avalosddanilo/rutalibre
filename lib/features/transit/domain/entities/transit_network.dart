import 'package:equatable/equatable.dart';

/// La red de transporte a la que pertenece una línea.
///
/// Existe porque el código de línea NO es único en el universo: el Gran
/// Resistencia y Corrientes capital pueden tener los dos una "línea 3". Es
/// único dentro de su red.
///
/// Sin `id` a propósito: la UI agrupa y filtra por `code`, y el uuid de la
/// base es un detalle de persistencia que el dominio no necesita.
class TransitNetwork extends Equatable {
  const TransitNetwork({
    required this.code,
    required this.name,
    this.sortOrder = 0,
  });

  /// Identificador estable: 'gran-resistencia', 'corrientes-capital'.
  final String code;

  /// Nombre mostrable: "Gran Resistencia".
  final String name;

  /// Orden de presentación entre redes. Sin esto las líneas de dos redes se
  /// intercalan al ordenar por código (el Gran Resistencia y Corrientes
  /// tienen los dos una 101, una 104, una 106 y una 110), y el listado
  /// agrupado por red queda con encabezados alternados.
  final int sortOrder;

  @override
  List<Object?> get props => [code, name, sortOrder];
}
