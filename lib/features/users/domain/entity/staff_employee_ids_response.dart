import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'staff_employee_ids_response.g.dart';

@JsonSerializable(createToJson: false)
class StaffEmployeeIdsResponse extends Equatable {
  final bool success;
  final List<StaffEmployeeIdDto> data;

  const StaffEmployeeIdsResponse({
    this.success = false,
    this.data = const [],
  });

  factory StaffEmployeeIdsResponse.fromJson(Map<String, dynamic> json) =>
      _$StaffEmployeeIdsResponseFromJson(json);

  @override
  List<Object?> get props => [success, data];
}

@JsonSerializable(createToJson: false)
class StaffEmployeeIdDto extends Equatable {
  final String id;

  const StaffEmployeeIdDto({this.id = ''});

  factory StaffEmployeeIdDto.fromJson(Map<String, dynamic> json) =>
      _$StaffEmployeeIdDtoFromJson(json);

  @override
  List<Object?> get props => [id];
}
