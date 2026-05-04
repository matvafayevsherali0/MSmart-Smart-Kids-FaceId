// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_users_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetUsersResponse _$GetUsersResponseFromJson(Map<String, dynamic> json) =>
    GetUsersResponse(
      success: json['success'] as bool?,
      data: json['data'] == null
          ? null
          : GetUsersDto.fromJson(json['data'] as Map<String, dynamic>),
    );

GetUsersDto _$GetUsersDtoFromJson(Map<String, dynamic> json) => GetUsersDto(
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => UserResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'] == null
      ? null
      : MetaResponse.fromJson(json['meta'] as Map<String, dynamic>),
);
