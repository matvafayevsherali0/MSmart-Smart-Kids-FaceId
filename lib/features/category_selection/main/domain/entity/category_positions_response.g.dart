// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_positions_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryPositionsResponse _$CategoryPositionsResponseFromJson(
  Map<String, dynamic> json,
) => CategoryPositionsResponse(
  success: json['success'] as bool? ?? false,
  data: json['data'] == null
      ? const CategoryPositionsDataDto()
      : CategoryPositionsDataDto.fromJson(json['data'] as Map<String, dynamic>),
);

CategoryPositionsDataDto _$CategoryPositionsDataDtoFromJson(
  Map<String, dynamic> json,
) => CategoryPositionsDataDto(
  items:
      (json['items'] as List<dynamic>?)
          ?.map(
            (e) => CategoryPositionItemDto.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  meta: json['meta'] == null
      ? const MetaResponse()
      : MetaResponse.fromJson(json['meta'] as Map<String, dynamic>),
);

CategoryPositionItemDto _$CategoryPositionItemDtoFromJson(
  Map<String, dynamic> json,
) => CategoryPositionItemDto(
  id: json['id'] as String? ?? '',
  name: json['name'] as String? ?? '',
  type: json['type'] == null
      ? const CategoryPositionTypeDto()
      : CategoryPositionTypeDto.fromJson(json['type'] as Map<String, dynamic>),
);

CategoryPositionTypeDto _$CategoryPositionTypeDtoFromJson(
  Map<String, dynamic> json,
) => CategoryPositionTypeDto(
  id: json['id'] as String? ?? '',
  name: json['name'] as String? ?? '',
);
