// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_class_groups_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryClassGroupsResponse _$CategoryClassGroupsResponseFromJson(
  Map<String, dynamic> json,
) => CategoryClassGroupsResponse(
  success: json['success'] as bool? ?? false,
  data: json['data'] == null
      ? const CategoryClassGroupsDataDto()
      : CategoryClassGroupsDataDto.fromJson(
          json['data'] as Map<String, dynamic>,
        ),
);

CategoryClassGroupsDataDto _$CategoryClassGroupsDataDtoFromJson(
  Map<String, dynamic> json,
) => CategoryClassGroupsDataDto(
  items:
      (json['items'] as List<dynamic>?)
          ?.map(
            (e) =>
                CategoryClassGroupItemDto.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  meta: json['meta'] == null
      ? const MetaResponse()
      : MetaResponse.fromJson(json['meta'] as Map<String, dynamic>),
);

CategoryClassGroupItemDto _$CategoryClassGroupItemDtoFromJson(
  Map<String, dynamic> json,
) => CategoryClassGroupItemDto(
  id: json['id'] as String? ?? '',
  name: json['name'] as String? ?? '',
  section: json['section'] as String? ?? '',
  shiftId: json['shiftId'] as String? ?? '',
  curatorId: json['curatorId'] as String?,
  classroomId: json['classroomId'] as String?,
  studentCount: (json['studentCount'] as num?)?.toInt() ?? 0,
  organizationId: json['organizationId'] as String? ?? '',
  shift: json['shift'] == null
      ? const CategoryClassGroupShiftDto()
      : CategoryClassGroupShiftDto.fromJson(
          json['shift'] as Map<String, dynamic>,
        ),
  organization: json['organization'] == null
      ? const CategoryClassGroupOrganizationDto()
      : CategoryClassGroupOrganizationDto.fromJson(
          json['organization'] as Map<String, dynamic>,
        ),
);

CategoryClassGroupShiftDto _$CategoryClassGroupShiftDtoFromJson(
  Map<String, dynamic> json,
) => CategoryClassGroupShiftDto(
  id: json['id'] as String? ?? '',
  name: json['name'] as String? ?? '',
  startTime: json['startTime'] as String? ?? '',
  endTime: json['endTime'] as String? ?? '',
);

CategoryClassGroupOrganizationDto _$CategoryClassGroupOrganizationDtoFromJson(
  Map<String, dynamic> json,
) => CategoryClassGroupOrganizationDto(
  id: json['id'] as String? ?? '',
  name: json['name'] as String? ?? '',
);
