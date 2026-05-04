import '../../../../core/exceptions/failures.dart';
import '../../../../core/utils/either.dart';
import '../../../common/data/data/user_me.dart';
import '../../data/data/organization.dart';

abstract class OrganizationRepository {
  Future<Either<Failure, Organization>> getOrganizations({required int page});

  Future<Either<Failure, UserMe>> getUserMe();
}
