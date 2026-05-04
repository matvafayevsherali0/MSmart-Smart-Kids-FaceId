import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'hikvision_user.g.dart';

@JsonSerializable(createToJson: false)
class HikvisionUser extends Equatable {
  final String employeeNo;
  final String name;
  final String userType;
  final String doorRight;

  const HikvisionUser({
    required this.employeeNo,
    required this.name,
    required this.userType,
    required this.doorRight,
  });

  factory HikvisionUser.fromJson(Map<String, dynamic> json) => _$HikvisionUserFromJson(json);

  @override
  List<Object?> get props => [employeeNo, name, userType, doorRight];
}

