import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_response.g.dart';

@JsonSerializable(createToJson: false)
class UserResponse extends Equatable {
  final String? id;
  final String? fullname;
  final String? phone;
  final bool? isActive;
  final String? createdAt;
  final String? updatedAt;

  const UserResponse({this.id = "", this.fullname, this.phone = "", this.isActive = false, this.createdAt = "", this.updatedAt});

  factory UserResponse.fromJson(Map<String, dynamic> json) => _$UserResponseFromJson(json);

  @override
  List<Object?> get props => [id, fullname, phone, isActive, createdAt, updatedAt];
}
