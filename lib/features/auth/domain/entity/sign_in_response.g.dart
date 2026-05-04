// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_in_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignInResponse _$SignInResponseFromJson(Map<String, dynamic> json) =>
    SignInResponse(
      success: json['success'] as bool? ?? false,
      data: json['data'] == null
          ? const SignInDataDto()
          : SignInDataDto.fromJson(json['data'] as Map<String, dynamic>),
    );

SignInDataDto _$SignInDataDtoFromJson(Map<String, dynamic> json) =>
    SignInDataDto(
      user: json['user'] == null
          ? const UserResponse()
          : UserResponse.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['accessToken'] as String? ?? "",
      refreshToken: json['refreshToken'] as String? ?? "",
    );
