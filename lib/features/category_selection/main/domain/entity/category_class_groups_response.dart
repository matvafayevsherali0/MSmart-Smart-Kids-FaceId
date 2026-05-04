import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../../common/domain/entities/meta_response.dart';

part 'category_class_groups_response.g.dart';

@JsonSerializable(createToJson: false)
class CategoryClassGroupsResponse extends Equatable {
  final bool success;
  final CategoryClassGroupsDataDto data;

  const CategoryClassGroupsResponse({
    this.success = false,
    this.data = const CategoryClassGroupsDataDto(),
  });

  factory CategoryClassGroupsResponse.fromJson(Map<String, dynamic> json) =>
      _$CategoryClassGroupsResponseFromJson(json);

  @override
  List<Object?> get props => [success, data];
}

@JsonSerializable(createToJson: false)
class CategoryClassGroupsDataDto extends Equatable {
  final List<CategoryClassGroupItemDto> items;
  final MetaResponse meta;

  const CategoryClassGroupsDataDto({
    this.items = const [],
    this.meta = const MetaResponse(),
  });

  factory CategoryClassGroupsDataDto.fromJson(Map<String, dynamic> json) =>
      _$CategoryClassGroupsDataDtoFromJson(json);

  @override
  List<Object?> get props => [items, meta];
}

@JsonSerializable(createToJson: false)
class CategoryClassGroupItemDto extends Equatable {
  final String id;
  final String name;
  final String section;
  final String shiftId;
  final String? curatorId;
  final String? classroomId;
  final int studentCount;
  final String organizationId;
  final CategoryClassGroupShiftDto shift;
  final CategoryClassGroupOrganizationDto organization;

  const CategoryClassGroupItemDto({
    this.id = '',
    this.name = '',
    this.section = '',
    this.shiftId = '',
    this.curatorId,
    this.classroomId,
    this.studentCount = 0,
    this.organizationId = '',
    this.shift = const CategoryClassGroupShiftDto(),
    this.organization = const CategoryClassGroupOrganizationDto(),
  });

  factory CategoryClassGroupItemDto.fromJson(Map<String, dynamic> json) =>
      _$CategoryClassGroupItemDtoFromJson(json);

  @override
  List<Object?> get props => [
    id,
    name,
    section,
    shiftId,
    curatorId,
    classroomId,
    studentCount,
    organizationId,
    shift,
    organization,
  ];
}

@JsonSerializable(createToJson: false)
class CategoryClassGroupShiftDto extends Equatable {
  final String id;
  final String name;
  final String startTime;
  final String endTime;

  const CategoryClassGroupShiftDto({
    this.id = '',
    this.name = '',
    this.startTime = '',
    this.endTime = '',
  });

  factory CategoryClassGroupShiftDto.fromJson(Map<String, dynamic> json) =>
      _$CategoryClassGroupShiftDtoFromJson(json);

  @override
  List<Object?> get props => [id, name, startTime, endTime];
}

@JsonSerializable(createToJson: false)
class CategoryClassGroupOrganizationDto extends Equatable {
  final String id;
  final String name;

  const CategoryClassGroupOrganizationDto({this.id = '', this.name = ''});

  factory CategoryClassGroupOrganizationDto.fromJson(
    Map<String, dynamic> json,
  ) => _$CategoryClassGroupOrganizationDtoFromJson(json);

  @override
  List<Object?> get props => [id, name];
}
