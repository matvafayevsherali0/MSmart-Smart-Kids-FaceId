import '../../../../core/exceptions/failures.dart';
import '../../../../core/utils/either.dart';
import '../../data/data/employee.dart';
import '../../data/data/staff.dart';
import '../../data/data/users.dart';

abstract class UsersRepository {
  Future<Either<Failure, Users>> getUsers({required int page});

  Future<Either<Failure, Staff>> getStaff({required String organizationId, required int page});

  Future<Either<Failure, Employee>> getEmployee({required String organizationId, required int page});

  Future<Either<Failure, List<String>>> getStaffIds({required String organizationId});

  Future<Either<Failure, List<String>>> getEmployeeIds({required String organizationId});
}
