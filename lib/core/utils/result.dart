import 'package:fpdart/fpdart.dart';

import '../errors/failures.dart';

/// Alias del tipo de retorno estándar de todo el dominio.
///
/// `Result<List<BusLine>>` se lee mejor que
/// `Future<Either<Failure, List<BusLine>>>` repetido en cada firma.
typedef Result<T> = Future<Either<Failure, T>>;
