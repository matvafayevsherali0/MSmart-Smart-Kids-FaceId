import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../common/domain/entities/meta_response.dart';

part 'employees_response.g.dart';

@JsonSerializable(createToJson: false)
class EmployeesResponse extends Equatable {
  final bool success;
  final EmployeesDataDto data;

  const EmployeesResponse({this.success = false, this.data = const EmployeesDataDto()});

  factory EmployeesResponse.fromJson(Map<String, dynamic> json) => _$EmployeesResponseFromJson(json);

  @override
  List<Object?> get props => [success, data];
}

@JsonSerializable(createToJson: false)
class EmployeesDataDto extends Equatable {
  final List<EmployeesDataItemDto> items;
  final MetaResponse meta;

  const EmployeesDataDto({this.items = const [], this.meta = const MetaResponse()});

  factory EmployeesDataDto.fromJson(Map<String, dynamic> json) => _$EmployeesDataDtoFromJson(json);

  @override
  List<Object?> get props => [items, meta];
}

@JsonSerializable(createToJson: false)
class EmployeesDataItemDto extends Equatable {
  final String id;
  final String fullname;
  final String phoneNumber;
  final String jobEntryDate;
  final String organizationId;
  final String positionId;
  final String staffType;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  const EmployeesDataItemDto({
    this.id = "",
    this.fullname = "",
    this.phoneNumber = "",
    this.jobEntryDate = "",
    this.organizationId = "",
    this.positionId = "",
    this.staffType = "",
    this.isActive = false,
    this.createdAt = "",
    this.updatedAt = "",
  });

  factory EmployeesDataItemDto.fromJson(Map<String, dynamic> json) => _$EmployeesDataItemDtoFromJson(json);

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
    createdAt,
    updatedAt,
  ];
}