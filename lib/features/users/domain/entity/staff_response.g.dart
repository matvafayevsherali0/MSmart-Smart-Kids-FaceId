// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StaffResponse _$StaffResponseFromJson(Map<String, dynamic> json) =>
    StaffResponse(
      success: json['success'] as bool? ?? false,
      data: json['data'] == null
          ? const StaffDataDto()
          : StaffDataDto.fromJson(json['data'] as Map<String, dynamic>),
    );

StaffDataDto _$StaffDataDtoFromJson(Map<String, dynamic> json) => StaffDataDto(
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => StaffDataItemDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  meta: json['meta'] == null
      ? const MetaResponse()
      : MetaResponse.fromJson(json['meta'] as Map<String, dynamic>),
);

StaffDataItemDto _$StaffDataItemDtoFromJson(Map<String, dynamic> json) =>
    StaffDataItemDto(
      id: json['id'] as String? ?? "",
      fullname: json['fullname'] as String? ?? "",
      birthday: json['birthday'] as String? ?? "",
      address: json['address'] as String? ?? "",
      classGroupId: json['classGroupId'] as String? ?? "",
      classGroup: json['classGroup'] == null
          ? const StaffDataItemClassGroupDto()
          : StaffDataItemClassGroupDto.fromJson(
              json['classGroup'] as Map<String, dynamic>,
            ),
      organizationId: json['organizationId'] as String? ?? "",
      isActive: json['isActive'] as bool? ?? false,
      enrolledAt: json['enrolledAt'] as String? ?? "",
      createdAt: json['createdAt'] as String? ?? "",
      updatedAt: json['updatedAt'] as String? ?? "",
      isDeleted: json['isDeleted'] as bool? ?? false,
    );

StaffDataItemClassGroupDto _$StaffDataItemClassGroupDtoFromJson(
  Map<String, dynamic> json,
) => StaffDataItemClassGroupDto(
  id: json['id'] as String? ?? "",
  name: json['name'] as String? ?? "",
  section: json['section'] as String? ?? "",
  curatorId: json['curatorId'] as String? ?? "",
  studentCount: (json['studentCount'] as num?)?.toInt() ?? 0,
  organizationId: json['organizationId'] as String? ?? "",
  createdAt: json['createdAt'] as String? ?? "",
  updatedAt: json['updatedAt'] as String? ?? "",
  isDeleted: json['isDeleted'] as bool? ?? false,
);
