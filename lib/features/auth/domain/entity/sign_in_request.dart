import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sign_in_request.g.dart';

@JsonSerializable()
class SignInRequest extends Equatable {
  final String phone;
  final String password;
  final String fcmToken;

  const SignInRequest({
    required this.phone,
    required this.password,
    required this.fcmToken,
  });

  factory SignInRequest.fromJson(Map<String, dynamic> json) =>
      _$SignInRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SignInRequestToJson(this);

  @override
  List<Object?> get props => [phone, password, fcmToken];
}
