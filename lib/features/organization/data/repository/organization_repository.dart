import '../../../../core/exceptions/failures.dart';
import '../../../../core/utils/either.dart';
import '../../../common/data/data/user_me.dart';
import '../../domain/mapper/organization_mapper.dart';
import '../../domain/repository/organization_repository.dart';
import '../data/organization.dart';
import '../data_source/organization_data_source.dart';

class OrganizationRepositoryImpl extends OrganizationRepository {
  final OrganizationRemoteDataSource _dataSource;
  final OrganizationMapper _mapper;

  OrganizationRepositoryImpl(this._dataSource, this._mapper);

  @override
  Future<Either<Failure, Organization>> getOrganizations({required int page}) async {
    try {
      final response = await _dataSource.getOrganizations(page: page);
      final organizations = _mapper.mapOrganizationResponseToOrganization(response);
      return Right(organizations);
    } catch (e) {
      return Left(AppFailure(errorMessage: """$e"""));
    }
  }

  @override
  Future<Either<Failure, UserMe>> getUserMe() async {
    try {
      final response = await _dataSource.getUserMe();
      final userMe = _mapper.mapUserMeResponseToUserMe(response);
      return Right(userMe);
    } catch (e) {
      return Left(AppFailure(errorMessage: """$e"""));
    }
  }
}
