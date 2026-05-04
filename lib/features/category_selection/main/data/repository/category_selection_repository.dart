import '../../../../../core/exceptions/failures.dart';
import '../../../../../core/utils/either.dart';
import '../data/category_class_group.dart';
import '../data/category_position.dart';
import '../data/category_pupil.dart';
import '../data/category_staff.dart';

import '../../domain/mapper/category_selection_mapper.dart';
import '../../domain/repository/category_selection_repository.dart';
import '../data_source/category_selection_data_source.dart';

class CategorySelectionRepositoryImpl extends CategorySelectionRepository {
  final CategorySelectionRemoteDataSource _dataSource;
  final CategorySelectionMapper _mapper;

  CategorySelectionRepositoryImpl(this._dataSource, this._mapper);

  @override
  Future<Either<Failure, CategoryClassGroups>> getClassGroups({
    required String organizationId,
    required int page,
  }) async {
    try {
      final response = await _dataSource.getClassGroups(
        organizationId: organizationId,
        page: page,
      );
      return Right(_mapper.mapClassGroupsResponseToClassGroups(response));
    } catch (e) {
      return Left(AppFailure(errorMessage: '$e'));
    }
  }

  @override
  Future<Either<Failure, CategoryPupils>> getPupils({
    required String organizationId,
    required String classGroupId,
    required int page,
    String search = '',
  }) async {
    try {
      final response = await _dataSource.getPupils(
        organizationId: organizationId,
        classGroupId: classGroupId,
        page: page,
        search: search,
      );
      return Right(_mapper.mapPupilsResponseToPupils(response));
    } catch (e) {
      return Left(AppFailure(errorMessage: '$e'));
    }
  }

  @override
  Future<Either<Failure, CategoryStaff>> getStaff({
    required String organizationId,
    required int page,
    String search = '',
    String positionId = '',
  }) async {
    try {
      final response = await _dataSource.getStaff(
        organizationId: organizationId,
        page: page,
        search: search,
        positionId: positionId,
      );
      return Right(_mapper.mapStaffResponseToStaff(response));
    } catch (e) {
      return Left(AppFailure(errorMessage: '$e'));
    }
  }

  @override
  Future<Either<Failure, CategoryPositions>> getPositions({
    required int page,
  }) async {
    try {
      final response = await _dataSource.getPositions(page: page);
      return Right(_mapper.mapPositionsResponseToPositions(response));
    } catch (e) {
      return Left(AppFailure(errorMessage: '$e'));
    }
  }
}
