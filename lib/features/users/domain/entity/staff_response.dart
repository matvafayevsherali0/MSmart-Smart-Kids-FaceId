import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../common/domain/entities/meta_response.dart';

part 'staff_response.g.dart';

@JsonSerializable(createToJson: false)
class StaffResponse extends Equatable {
  final bool success;
  final StaffDataDto data;

  const StaffResponse({this.success = false, this.data = const StaffDataDto()});

  factory StaffResponse.fromJson(Map<String, dynamic> json) => _$StaffResponseFromJson(json);

  @override
  List<Object?> get props => [success, data];
}

@JsonSerializable(createToJson: false)
class StaffDataDto extends Equatable {
  final List<StaffDataItemDto> items;
  final MetaResponse meta;

  const StaffDataDto({this.items = const [], this.meta = const MetaResponse()});

  factory StaffDataDto.fromJson(Map<String, dynamic> json) => _$StaffDataDtoFromJson(json);

  @override
  List<Object?> get props => [items, meta];
}

@JsonSerializable(createToJson: false)
class StaffDataItemDto extends Equatable {
  final String id;
  final String fullname;
  final String birthday;
  final String address;
  final String classGroupId;
  final StaffDataItemClassGroupDto classGroup;
  final String organizationId;
  final bool isActive;
  final String enrolledAt;
  final String createdAt;
  final String updatedAt;
  final bool isDeleted;

  const StaffDataItemDto({
    this.id = "",
    this.fullname = "",
    this.birthday = "",
    this.address = "",
    this.classGroupId = "",
    this.classGroup = const StaffDataItemClassGroupDto(),
    this.organizationId = "",
    this.isActive = false,
    this.enrolledAt = "",
    this.createdAt = "",
    this.updatedAt = "",
    this.isDeleted = false,
  });

  factory StaffDataItemDto.fromJson(Map<String, dynamic> json) => _$StaffDataItemDtoFromJson(json);

  @override
  List<Object?> get props =>
      [
        id,
        fullname,
        birthday,
        address,
        classGroupId,
        classGroup,
        organizationId,
        isActive,
        enrolledAt,
        createdAt,
        updatedAt,
        isDeleted,
      ];
}

@JsonSerializable(createToJson: false)
class StaffDataItemClassGroupDto extends Equatable {
  final String id;
  final String name;
  final String section;
  final String curatorId;
  final int studentCount;
  final String organizationId;
  final String createdAt;
  final String updatedAt;
  final bool isDeleted;

  const StaffDataItemClassGroupDto({
    this.id = "",
    this.name = "",
    this.section = "",
    this.curatorId = "",
    this.studentCount = 0,
    this.organizationId = "",
    this.createdAt = "",
    this.updatedAt = "",
    this.isDeleted = false,
  });

  factory StaffDataItemClassGroupDto.fromJson(Map<String, dynamic> json) => _$StaffDataItemClassGroupDtoFromJson(json);

  @override
  List<Object?> get props =>
      [
        id,
        name,
        section,
        curatorId,
        studentCount,
        organizationId,
        createdAt,
        updatedAt,
        isDeleted,
      ];
}