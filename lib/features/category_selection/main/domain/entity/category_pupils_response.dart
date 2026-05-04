import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../../common/domain/entities/meta_response.dart';

part 'category_pupils_response.g.dart';

@JsonSerializable(createToJson: false)
class CategoryPupilsResponse extends Equatable {
  final bool success;
  final CategoryPupilsDataDto data;

  const CategoryPupilsResponse({
    this.success = false,
    this.data = const CategoryPupilsDataDto(),
  });

  factory CategoryPupilsResponse.fromJson(Map<String, dynamic> json) =>
      _$CategoryPupilsResponseFromJson(json);

  @override
  List<Object?> get props => [success, data];
}

@JsonSerializable(createToJson: false)
class CategoryPupilsDataDto extends Equatable {
  final List<CategoryPupilItemDto> items;
  final MetaResponse meta;

  const CategoryPupilsDataDto({
    this.items = const [],
    this.meta = const MetaResponse(),
  });

  factory CategoryPupilsDataDto.fromJson(Map<String, dynamic> json) =>
      _$CategoryPupilsDataDtoFromJson(json);

  @override
  List<Object?> get props => [items, meta];
}

@JsonSerializable(createToJson: false)
class CategoryPupilItemDto extends Equatable {
  final String id;
  final String fullname;
  final String birthday;
  final String address;
  final String? photoId;
  final String classGroupId;
  final String organizationId;
  final bool isActive;
  final String enrolledAt;
  final Object? faceEnrollment;

  const CategoryPupilItemDto({
    this.id = '',
    this.fullname = '',
    this.birthday = '',
    this.address = '',
    this.photoId,
    this.classGroupId = '',
    this.organizationId = '',
    this.isActive = false,
    this.enrolledAt = '',
    this.faceEnrollment,
  });

  factory CategoryPupilItemDto.fromJson(Map<String, dynamic> json) =>
      _$CategoryPupilItemDtoFromJson(json);

  @override
  List<Object?> get props => [
    id,
    fullname,
    birthday,
    address,
    photoId,
    classGroupId,
    organizationId,
    isActive,
    enrolledAt,
    faceEnrollment,
  ];
}
