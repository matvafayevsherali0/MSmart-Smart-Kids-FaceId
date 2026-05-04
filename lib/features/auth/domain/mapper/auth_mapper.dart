import '../../data/data/logout.dart';
import '../../data/data/sign_in.dart';
import '../entity/logout_response.dart';
import '../entity/sign_in_response.dart';

class AuthMapper {
  SignIn mapSignInResponseToSignIn(SignInResponse response) {
    final data = response.data;
    final user = data?.user;
    return SignIn(
      isSuccess: response.success ?? false,
      id: user?.id ?? "",
      phone: user?.phone ?? "",
      isActive: user?.isActive ?? false,
      accessToken: data?.accessToken ?? "",
      refreshToken: data?.refreshToken ?? "",
    );
  }

  Logout mapLogoutResponseToLogout(LogoutResponse response) {
    return Logout(isSuccess: response.success, message: response.message);
  }
}
