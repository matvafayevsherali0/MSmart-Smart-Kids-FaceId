// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employees_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmployeesResponse _$EmployeesResponseFromJson(Map<String, dynamic> json) =>
    EmployeesResponse(
      success: json['success'] as bool? ?? false,
      data: json['data'] == null
          ? const EmployeesDataDto()
          : EmployeesDataDto.fromJson(json['data'] as Map<String, dynamic>),
    );

EmployeesDataDto _$EmployeesDataDtoFromJson(Map<String, dynamic> json) =>
    EmployeesDataDto(
      items:
          (json['items'] as List<dynamic>?)
              ?.map(
                (e) => EmployeesDataItemDto.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      meta: json['meta'] == null
          ? const MetaResponse()
          : MetaResponse.fromJson(json['meta'] as Map<String, dynamic>),
    );

EmployeesDataItemDto _$EmployeesDataItemDtoFromJson(
  Map<String, dynamic> json,
) => EmployeesDataItemDto(
  id: json['id'] as String? ?? "",
  fullname: json['fullname'] as String? ?? "",
  phoneNumber: json['phoneNumber'] as String? ?? "",
  jobEntryDate: json['jobEntryDate'] as String? ?? "",
  organizationId: json['organizationId'] as String? ?? "",
  positionId: json['positionId'] as String? ?? "",
  staffType: json['staffType'] as String? ?? "",
  isActive: json['isActive'] as bool? ?? false,
  createdAt: json['createdAt'] as String? ?? "",
  updatedAt: json['updatedAt'] as String? ?? "",
);
