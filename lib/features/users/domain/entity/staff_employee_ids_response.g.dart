// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_employee_ids_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StaffEmployeeIdsResponse _$StaffEmployeeIdsResponseFromJson(
  Map<String, dynamic> json,
) => StaffEmployeeIdsResponse(
  success: json['success'] as bool? ?? false,
  data:
      (json['data'] as List<dynamic>?)
          ?.map((e) => StaffEmployeeIdDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

StaffEmployeeIdDto _$StaffEmployeeIdDtoFromJson(Map<String, dynamic> json) =>
    StaffEmployeeIdDto(id: json['id'] as String? ?? '');
