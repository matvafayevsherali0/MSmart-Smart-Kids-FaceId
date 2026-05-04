import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../common/domain/entities/user_response.dart';

part 'sign_in_response.g.dart';

@JsonSerializable(createToJson: false)
class SignInResponse extends Equatable {
  final bool? success;
  final SignInDataDto? data;

  const SignInResponse({
    this.success = false,
    this.data = const SignInDataDto(),
  });

  factory SignInResponse.fromJson(Map<String, dynamic> json) => _$SignInResponseFromJson(json);

  @override
  List<Object?> get props => [success, data];
}

@JsonSerializable(createToJson: false)
class SignInDataDto extends Equatable {
  final UserResponse? user;
  final String? accessToken;
  final String? refreshToken;

  const SignInDataDto({
    this.user = const UserResponse(),
    this.accessToken = "",
    this.refreshToken = "",
  });

  factory SignInDataDto.fromJson(Map<String, dynamic> json) => _$SignInDataDtoFromJson(json);

  @override
  List<Object?> get props => [user, accessToken, refreshToken];
}
