// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_pupils_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryPupilsResponse _$CategoryPupilsResponseFromJson(
  Map<String, dynamic> json,
) => CategoryPupilsResponse(
  success: json['success'] as bool? ?? false,
  data: json['data'] == null
      ? const CategoryPupilsDataDto()
      : CategoryPupilsDataDto.fromJson(json['data'] as Map<String, dynamic>),
);

CategoryPupilsDataDto _$CategoryPupilsDataDtoFromJson(
  Map<String, dynamic> json,
) => CategoryPupilsDataDto(
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => CategoryPupilItemDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  meta: json['meta'] == null
      ? const MetaResponse()
      : MetaResponse.fromJson(json['meta'] as Map<String, dynamic>),
);

CategoryPupilItemDto _$CategoryPupilItemDtoFromJson(
  Map<String, dynamic> json,
) => CategoryPupilItemDto(
  id: json['id'] as String? ?? '',
  fullname: json['fullname'] as String? ?? '',
  birthday: json['birthday'] as String? ?? '',
  address: json['address'] as String? ?? '',
  photoId: json['photoId'] as String?,
  classGroupId: json['classGroupId'] as String? ?? '',
  organizationId: json['organizationId'] as String? ?? '',
  isActive: json['isActive'] as bool? ?? false,
  enrolledAt: json['enrolledAt'] as String? ?? '',
  faceEnrollment: json['faceEnrollment'],
);
