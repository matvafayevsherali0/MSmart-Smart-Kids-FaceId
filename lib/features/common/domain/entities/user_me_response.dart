import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_me_response.g.dart';

@JsonSerializable(createToJson: false)
class UserMeResponse extends Equatable {
  final bool? success;
  final UserMeDataDto? data;

  const UserMeResponse({this.success = false, this.data = const UserMeDataDto()});

  factory UserMeResponse.fromJson(Map<String, dynamic> json) => _$UserMeResponseFromJson(json);

  @override
  List<Object?> get props => [success, data];
}

@JsonSerializable(createToJson: false)
class UserMeDataDto extends Equatable {
  final String? id;
  final String? phone;
  final bool? isActive;
  final String? createdAt;
  final List<UserMeDataOrganizationItem>? organizations;

  const UserMeDataDto({this.id = "", this.phone = "", this.isActive = false, this.createdAt = "", this.organizations = const []});

  factory UserMeDataDto.fromJson(Map<String, dynamic> json) => _$UserMeDataDtoFromJson(json);

  @override
  List<Object?> get props => [id, phone, isActive, createdAt, organizations];
}

@JsonSerializable(createToJson: false)
class UserMeDataOrganizationItem extends Equatable {
  final String? id;
  final String? name;
  final bool? isPrimary;
  final String? positionId;
  final String? positionName;
  final bool? isEducational;

  const UserMeDataOrganizationItem({
    this.id = "",
    this.name = "",
    this.isPrimary = false,
    this.positionId = "",
    this.positionName = "",
    this.isEducational = false,
  });

  factory UserMeDataOrganizationItem.fromJson(Map<String, dynamic> json) => _$UserMeDataOrganizationItemFromJson(json);

  @override
  List<Object?> get props => [id, name, isPrimary, positionId, positionName, isEducational];
}
