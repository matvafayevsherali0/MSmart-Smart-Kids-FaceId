import 'package:equatable/equatable.dart';

class SignIn extends Equatable {
  final bool isSuccess;
  final String id;
  final String phone;
  final bool isActive;
  final String accessToken;
  final String refreshToken;

  const SignIn({
    required this.isSuccess,
    required this.id,
    required this.phone,
    required this.isActive,
    required this.accessToken,
    required this.refreshToken,
  });

  @override
  List<Object?> get props => [
        isSuccess,
        id,
        phone,
        isActive,
        accessToken,
        refreshToken,
      ];
}
