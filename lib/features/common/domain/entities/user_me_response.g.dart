// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_me_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserMeResponse _$UserMeResponseFromJson(Map<String, dynamic> json) =>
    UserMeResponse(
      success: json['success'] as bool? ?? false,
      data: json['data'] == null
          ? const UserMeDataDto()
          : UserMeDataDto.fromJson(json['data'] as Map<String, dynamic>),
    );

UserMeDataDto _$UserMeDataDtoFromJson(Map<String, dynamic> json) =>
    UserMeDataDto(
      id: json['id'] as String? ?? "",
      phone: json['phone'] as String? ?? "",
      isActive: json['isActive'] as bool? ?? false,
      createdAt: json['createdAt'] as String? ?? "",
      organizations:
          (json['organizations'] as List<dynamic>?)
              ?.map(
                (e) => UserMeDataOrganizationItem.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          const [],
    );

UserMeDataOrganizationItem _$UserMeDataOrganizationItemFromJson(
  Map<String, dynamic> json,
) => UserMeDataOrganizationItem(
  id: json['id'] as String? ?? "",
  name: json['name'] as String? ?? "",
  isPrimary: json['isPrimary'] as bool? ?? false,
  positionId: json['positionId'] as String? ?? "",
  positionName: json['positionName'] as String? ?? "",
  isEducational: json['isEducational'] as bool? ?? false,
);
