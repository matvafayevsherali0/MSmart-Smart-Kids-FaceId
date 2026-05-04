// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_staff_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryStaffResponse _$CategoryStaffResponseFromJson(
  Map<String, dynamic> json,
) => CategoryStaffResponse(
  success: json['success'] as bool? ?? false,
  data: json['data'] == null
      ? const CategoryStaffDataDto()
      : CategoryStaffDataDto.fromJson(json['data'] as Map<String, dynamic>),
);

CategoryStaffDataDto _$CategoryStaffDataDtoFromJson(
  Map<String, dynamic> json,
) => CategoryStaffDataDto(
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => CategoryStaffItemDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  meta: json['meta'] == null
      ? const MetaResponse()
      : MetaResponse.fromJson(json['meta'] as Map<String, dynamic>),
);

CategoryStaffItemDto _$CategoryStaffItemDtoFromJson(
  Map<String, dynamic> json,
) => CategoryStaffItemDto(
  id: json['id'] as String? ?? '',
  fullname: json['fullname'] as String? ?? '',
  phoneNumber: json['phoneNumber'] as String? ?? '',
  jobEntryDate: json['jobEntryDate'] as String? ?? '',
  organizationId: json['organizationId'] as String? ?? '',
  positionId: json['positionId'] as String? ?? '',
  staffType: json['staffType'] as String? ?? '',
  isActive: json['isActive'] as bool? ?? false,
  faceEnrollment: json['faceEnrollment'],
);
