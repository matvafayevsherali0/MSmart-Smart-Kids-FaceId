part of 'sign_in_bloc.dart';

@immutable
class SignInState extends Equatable {
  final bool isHidePassword;
  final bool isLoading;
  final bool isDisable;

  const SignInState({
    this.isHidePassword = true,
    this.isLoading = false,
    this.isDisable = false,
  });

  SignInState copyWith({
    bool? isHidePassword,
    bool? isLoading,
    bool? isDisable,
  }) {
    return SignInState(
      isHidePassword: isHidePassword ?? this.isHidePassword,
      isLoading: isLoading ?? this.isLoading,
      isDisable: isDisable ?? this.isDisable,
    );
  }

  @override
  List<Object?> get props => [isHidePassword, isLoading, isDisable];
}
