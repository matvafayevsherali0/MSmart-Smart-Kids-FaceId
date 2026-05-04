
import '../../../../core/exceptions/failures.dart';
import '../../../../core/utils/either.dart';
import '../../domain/mapper/users_mapper.dart';
import '../../domain/repository/users_repository.dart';
import '../data/employee.dart';
import '../data/staff.dart';
import '../data/users.dart';
import '../data_source/users_data_source.dart';

class UsersRepositoryImpl extends UsersRepository {
  final UsersRemoteDataSource _dataSource;
  final UsersMapper _mapper;

  UsersRepositoryImpl(this._dataSource, this._mapper);

  @override
  Future<Either<Failure, Users>> getUsers({required int page}) async {
    try {
      final response = await _dataSource.getUsers(page: page);
      final users = _mapper.mapGetUsersResponseToUsers(response);
      return Right(users);
    } catch (e) {
      return Left(AppFailure(errorMessage: """$e"""));
    }
  }

  @override
  Future<Either<Failure, Employee>> getEmployee({required String organizationId, required int page}) async {
    try {
      final response = await _dataSource.getEmployees(organizationId: organizationId, page: page);
      final employee = _mapper.mapEmployeeResponseToEmployee(response);
      return Right(employee);
    } catch (e) {
      return Left(AppFailure(errorMessage: """$e"""));
    }
  }

  @override
  Future<Either<Failure, Staff>> getStaff({required String organizationId, required int page}) async {
    try {
      final response = await _dataSource.getStaff(organizationId: organizationId, page: page);
      final staff = _mapper.mapStaffResponseToStaff(response);
      return Right(staff);
    } catch (e) {
      return Left(AppFailure(errorMessage: """$e"""));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getStaffIds({
    required String organizationId,
  }) async {
    try {
      final response = await _dataSource.getStaffIds(
        organizationId: organizationId,
      );
      final ids = _mapper.mapStaffEmployeeIdsResponseToIdList(response);
      return Right(ids);
    } catch (e) {
      return Left(AppFailure(errorMessage: """$e"""));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getEmployeeIds({
    required String organizationId,
  }) async {
    try {
      final response = await _dataSource.getEmployeeIds(
        organizationId: organizationId,
      );
      final ids = _mapper.mapStaffEmployeeIdsResponseToIdList(response);
      return Right(ids);
    } catch (e) {
      return Left(AppFailure(errorMessage: """$e"""));
    }
  }
}
