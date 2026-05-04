import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../../common/domain/entities/meta_response.dart';

part 'category_staff_response.g.dart';

@JsonSerializable(createToJson: false)
class CategoryStaffResponse extends Equatable {
  final bool success;
  final CategoryStaffDataDto data;

  const CategoryStaffResponse({
    this.success = false,
    this.data = const CategoryStaffDataDto(),
  });

  factory CategoryStaffResponse.fromJson(Map<String, dynamic> json) =>
      _$CategoryStaffResponseFromJson(json);

  @override
  List<Object?> get props => [success, data];
}

@JsonSerializable(createToJson: false)
class CategoryStaffDataDto extends Equatable {
  final List<CategoryStaffItemDto> items;
  final MetaResponse meta;

  const CategoryStaffDataDto({
    this.items = const [],
    this.meta = const MetaResponse(),
  });

  factory CategoryStaffDataDto.fromJson(Map<String, dynamic> json) =>
      _$CategoryStaffDataDtoFromJson(json);

  @override
  List<Object?> get props => [items, meta];
}

@JsonSerializable(createToJson: false)
class CategoryStaffItemDto extends Equatable {
  final String id;
  final String fullname;
  final String phoneNumber;
  final String jobEntryDate;
  final String organizationId;
  final String positionId;
  final String staffType;
  final bool isActive;
  final Object? faceEnrollment;

  const CategoryStaffItemDto({
    this.id = '',
    this.fullname = '',
    this.phoneNumber = '',
    this.jobEntryDate = '',
    this.organizationId = '',
    this.positionId = '',
    this.staffType = '',
    this.isActive = false,
    this.faceEnrollment,
  });

  factory CategoryStaffItemDto.fromJson(Map<String, dynamic> json) =>
      _$CategoryStaffItemDtoFromJson(json);

  @override
  List<Object?> get props => [
    id,
    fullname,
    phoneNumber,
    jobEntryDate,
    organizationId,
    positionId,
    staffType,
    isActive,
    faceEnrollment,
  ];
}
