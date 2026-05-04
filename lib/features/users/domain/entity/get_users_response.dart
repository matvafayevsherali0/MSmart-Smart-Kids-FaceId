import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../common/domain/entities/meta_response.dart';
import '../../../common/domain/entities/user_response.dart';

part 'get_users_response.g.dart';

@JsonSerializable(createToJson: false)
class GetUsersResponse extends Equatable {
  final bool? success;
  final GetUsersDto? data;

  const GetUsersResponse({this.success, this.data});

  factory GetUsersResponse.fromJson(Map<String, dynamic> json) => _$GetUsersResponseFromJson(json);

  @override
  List<Object?> get props => [success, data];
}

@JsonSerializable(createToJson: false)
class GetUsersDto extends Equatable {
  final List<UserResponse>? items;
  final MetaResponse? meta;

  const GetUsersDto({this.items, this.meta});

  factory GetUsersDto.fromJson(Map<String, dynamic> json) => _$GetUsersDtoFromJson(json);

  @override
  List<Object?> get props => [items, meta];
}
