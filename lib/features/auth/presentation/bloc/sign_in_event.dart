part of 'sign_in_bloc.dart';

@immutable
sealed class SignInEvent extends Equatable {
  const SignInEvent();

  @override
  List<Object?> get props => [];
}

class SignInWithLogin extends SignInEvent {
  final String login;
  final String password;
  final VoidCallback onSuccess;
  final Function(String error) onError;

  const SignInWithLogin({
    required this.login,
    required this.password,
    required this.onSuccess,
    required this.onError,
  });

  @override
  List<Object?> get props => [login, password, onSuccess, onError];
}

class HideEyeSignInEvent extends SignInEvent {
  const HideEyeSignInEvent();
}

class IsDisableButtonSignInWithLogin extends SignInEvent {
  final String login;
  final String password;

  const IsDisableButtonSignInWithLogin({
    required this.login,
    required this.password,
  });

  @override
  List<Object?> get props => [login, password];
}
