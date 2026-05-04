import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../../common/domain/entities/meta_response.dart';

part 'category_positions_response.g.dart';

@JsonSerializable(createToJson: false)
class CategoryPositionsResponse extends Equatable {
  final bool success;
  final CategoryPositionsDataDto data;

  const CategoryPositionsResponse({
    this.success = false,
    this.data = const CategoryPositionsDataDto(),
  });

  factory CategoryPositionsResponse.fromJson(Map<String, dynamic> json) =>
      _$CategoryPositionsResponseFromJson(json);

  @override
  List<Object?> get props => [success, data];
}

@JsonSerializable(createToJson: false)
class CategoryPositionsDataDto extends Equatable {
  final List<CategoryPositionItemDto> items;
  final MetaResponse meta;

  const CategoryPositionsDataDto({
    this.items = const [],
    this.meta = const MetaResponse(),
  });

  factory CategoryPositionsDataDto.fromJson(Map<String, dynamic> json) =>
      _$CategoryPositionsDataDtoFromJson(json);

  @override
  List<Object?> get props => [items, meta];
}

@JsonSerializable(createToJson: false)
class CategoryPositionItemDto extends Equatable {
  final String id;
  final String name;
  final CategoryPositionTypeDto type;

  const CategoryPositionItemDto({
    this.id = '',
    this.name = '',
    this.type = const CategoryPositionTypeDto(),
  });

  factory CategoryPositionItemDto.fromJson(Map<String, dynamic> json) =>
      _$CategoryPositionItemDtoFromJson(json);

  @override
  List<Object?> get props => [id, name, type];
}

@JsonSerializable(createToJson: false)
class CategoryPositionTypeDto extends Equatable {
  final String id;
  final String name;

  const CategoryPositionTypeDto({this.id = '', this.name = ''});

  factory CategoryPositionTypeDto.fromJson(Map<String, dynamic> json) =>
      _$CategoryPositionTypeDtoFromJson(json);

  @override
  List<Object?> get props => [id, name];
}
