import 'package:equatable/equatable.dart';

/// Errores de DOMINIO: lo único que la capa de presentation puede ver.
///
/// Son valores, no excepciones. Viajan por la izquierda de un
/// `Either<Failure, T>` y la UI decide qué mensaje mostrar según el tipo.
///
/// `sealed` habilita `switch` exhaustivo en presentation: si mañana se agrega
/// un nuevo Failure, el compilador obliga a manejarlo en todos lados.
sealed class Failure extends Equatable {
  const Failure({required this.message});

  /// Mensaje técnico para logging/debug. La UI NO lo muestra tal cual:
  /// mapea el tipo de Failure a un texto localizado.
  final String message;

  @override
  List<Object?> get props => [message];
}

/// El backend (Supabase/PostgREST) respondió con error: 4xx/5xx,
/// RPC inexistente, respuesta malformada, etc.
final class ServerFailure extends Failure {
  const ServerFailure({super.message = 'Error del servidor', this.statusCode});

  /// Código HTTP si está disponible (null para errores sin status).
  final int? statusCode;

  @override
  List<Object?> get props => [message, statusCode];
}

/// La cache local falló o no tiene datos.
///
/// En la estrategia cache-first del MVP este Failure solo llega a la UI
/// cuando ADEMÁS falló la red: cache vacía + sin conexión = primera apertura
/// offline. Es el caso que dispara la pantalla "necesitás conexión una vez".
final class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Error de cache local'});
}

/// No hay conectividad o la request no llegó al servidor
/// (timeout, DNS, avión). Distinto de ServerFailure: acá el server
/// nunca respondió.
final class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'Sin conexión a internet'});
}

/// Los datos recibidos no tienen la forma esperada (JSON inválido,
/// campo faltante, tipo incorrecto). Señal de desfase entre el esquema
/// remoto y los modelos de la app.
final class DataParsingFailure extends Failure {
  const DataParsingFailure({super.message = 'Error al interpretar los datos'});
}
