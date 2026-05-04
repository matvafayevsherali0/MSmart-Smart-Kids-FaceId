
import '../../../../core/exceptions/failures.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entity/sign_in_request.dart';
import '../../domain/mapper/auth_mapper.dart';
import '../../domain/repository/auth_repository.dart';
import '../data/logout.dart';
import '../data/sign_in.dart';
import '../datasource/auth_data_source.dart';
import '../locale_data_source/auth_local_data_source.dart';

class AuthRepositoryImpl extends AuthRepository {
  final AuthRemoteDataSource _dataSource;
  final AuthLocalDataSource _localDataSource;
  final AuthMapper _mapper;

  AuthRepositoryImpl(this._dataSource, this._localDataSource, this._mapper);

  @override
  Future<Either<Failure, SignIn>> signIn({
    required SignInRequest signInRequest,
  }) async {
    try {
      final response = await _dataSource.signIn(signInRequest: signInRequest);
      final signIn = _mapper.mapSignInResponseToSignIn(response);
      await _localDataSource.saveTokens(
        accessToken: signIn.accessToken,
        refreshToken: signIn.refreshToken,
      );
      return Right(signIn);
    } catch (e) {
      return Left(AppFailure(errorMessage: '$e'));
    }
  }

  @override
  Future<Either<Failure, Logout>> logout() async {
    try {
      final response = await _dataSource.logout();
      final logout = _mapper.mapLogoutResponseToLogout(response);
      await _localDataSource.clearSession();
      return Right(logout);
    } catch (e) {
      return Left(AppFailure(errorMessage: '$e'));
    }
  }
}
