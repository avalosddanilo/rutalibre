import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/place.dart';
import '../../domain/repositories/places_repository.dart';
import '../datasources/places_asset_datasource.dart';

final class PlacesRepositoryImpl implements PlacesRepository {
  const PlacesRepositoryImpl(this._dataSource);

  final PlacesDataSource _dataSource;

  @override
  Result<List<Place>> getPlaces() async {
    try {
      return Right(await _dataSource.getPlaces());
    } on AppException catch (e) {
      // Solo puede ser ParsingException, y solo por un error de build. Se
      // mapea igual para no dejar un `catch` que miente sobre lo que atrapa.
      return Left(
        e is ParsingException
            ? DataParsingFailure(message: e.message)
            : ServerFailure(message: e.message),
      );
    }
  }
}
