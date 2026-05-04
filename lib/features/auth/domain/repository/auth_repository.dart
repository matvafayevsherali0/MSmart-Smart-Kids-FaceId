
import '../../../../core/exceptions/failures.dart';
import '../../../../core/utils/either.dart';
import '../../data/data/logout.dart';
import '../../data/data/sign_in.dart';
import '../entity/sign_in_request.dart';

abstract class AuthRepository {
  Future<Either<Failure, SignIn>> signIn({
    required SignInRequest signInRequest,
  });

  Future<Either<Failure, Logout>> logout();
}
