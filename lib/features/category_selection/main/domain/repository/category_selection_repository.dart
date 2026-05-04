import '../../../../../core/exceptions/failures.dart';
import '../../../../../core/utils/either.dart';
import '../../data/data/category_class_group.dart';
import '../../data/data/category_position.dart';
import '../../data/data/category_pupil.dart';
import '../../data/data/category_staff.dart';

abstract class CategorySelectionRepository {
  Future<Either<Failure, CategoryClassGroups>> getClassGroups({
    required String organizationId,
    required int page,
  });

  Future<Either<Failure, CategoryPupils>> getPupils({
    required String organizationId,
    required String classGroupId,
    required int page,
    String search = '',
  });

  Future<Either<Failure, CategoryStaff>> getStaff({
    required String organizationId,
    required int page,
    String search = '',
    String positionId = '',
  });

  Future<Either<Failure, CategoryPositions>> getPositions({required int page});
}
