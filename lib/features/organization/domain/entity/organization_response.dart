import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../common/domain/entities/meta_response.dart';

part 'organization_response.g.dart';

@JsonSerializable(createToJson: false)
class OrganizationResponse extends Equatable {
  final bool? success;
  final OrganizationDataDto? data;

  const OrganizationResponse({this.success = false, this.data = const OrganizationDataDto()});

  factory OrganizationResponse.fromJson(Map<String, dynamic> json) => _$OrganizationResponseFromJson(json);

  @override
  List<Object?> get props => [success, data];
}

@JsonSerializable(createToJson: false)
class OrganizationDataDto extends Equatable {
  final List<OrganizationDataItem>? items;
  final MetaResponse? meta;

  const OrganizationDataDto({this.items = const [], this.meta = const MetaResponse()});

  factory OrganizationDataDto.fromJson(Map<String, dynamic> json) => _$OrganizationDataDtoFromJson(json);

  @override
  List<Object?> get props => [items, meta];
}

@JsonSerializable(createToJson: false)
class OrganizationDataItem extends Equatable {
  final String? id;
  final int? soatoId;
  final String? name;
  final String? typeId;
  final String? phoneNumber;
  final String? address;
  final String? parentId;
  final bool? isEducational;
  final String? activationDate;
  final bool? isLock;
  final OrganizationDataItemSoatoDto? soato;
  final OrganizationDataItemTypeDto? type;
  final String? createdAt;
  final String? updatedAt;
  final bool? isDeleted;
  final String? deletedAt;

  const OrganizationDataItem({
    this.id = "",
    this.soatoId = 0,
    this.name = "",
    this.typeId = "",
    this.phoneNumber = "",
    this.address = "",
    this.parentId = "",
    this.isEducational = false,
    this.activationDate = "",
    this.isLock = false,
    this.soato = const OrganizationDataItemSoatoDto(),
    this.type = const OrganizationDataItemTypeDto(),
    this.createdAt = "",
    this.updatedAt = "",
    this.isDeleted = false,
    this.deletedAt = "",
  });

  factory OrganizationDataItem.fromJson(Map<String, dynamic> json) => _$OrganizationDataItemFromJson(json);

  @override
  List<Object?> get props => [
    id,
    soatoId,
    name,
    typeId,
    phoneNumber,
    address,
    parentId,
    isEducational,
    activationDate,
    isLock,
    soato,
    type,
    createdAt,
    updatedAt,
    isDeleted,
    deletedAt,
  ];
}

@JsonSerializable(createToJson: false)
class OrganizationDataItemSoatoDto extends Equatable {
  final int? id;
  final int? orderNum;
  final String? latitude;
  final String? longitude;
  final String? nameUz;
  final String? nameUzc;
  final String? nameEn;
  final String? nameRu;
  final String? shortNameUz;
  final String? shortNameUzc;
  final String? shortNameRu;
  final String? shortNameEn;
  final String? createdAt;
  final String? updatedAt;
  final bool? isDeleted;

  const OrganizationDataItemSoatoDto({
    this.id = 0,
    this.orderNum = 0,
    this.latitude = "",
    this.longitude = "",
    this.nameUz = "",
    this.nameUzc = "",
    this.nameEn = "",
    this.nameRu = "",
    this.shortNameUz = "",
    this.shortNameUzc = "",
    this.shortNameRu = "",
    this.shortNameEn = "",
    this.createdAt = "",
    this.updatedAt = "",
    this.isDeleted = false,
  });

  factory OrganizationDataItemSoatoDto.fromJson(Map<String, dynamic> json) => _$OrganizationDataItemSoatoDtoFromJson(json);

  @override
  List<Object?> get props => [
    id,
    orderNum,
    latitude,
    longitude,
    nameUz,
    nameUzc,
    nameEn,
    nameRu,
    shortNameUz,
    shortNameUzc,
    shortNameRu,
    shortNameEn,
    createdAt,
    updatedAt,
    isDeleted,
  ];
}

@JsonSerializable(createToJson: false)
class OrganizationDataItemTypeDto extends Equatable {
  final String? id;
  final String? name;
  final String? createdAt;
  final String? updatedAt;
  final bool? isDeleted;
  final String? deletedAt;

  const OrganizationDataItemTypeDto({
    this.id = "",
    this.name = "",
    this.createdAt = "",
    this.updatedAt = "",
    this.isDeleted = false,
    this.deletedAt = "",
  });

  factory OrganizationDataItemTypeDto.fromJson(Map<String, dynamic> json) => _$OrganizationDataItemTypeDtoFromJson(json);

  @override
  List<Object?> get props => [id, name, createdAt, updatedAt, isDeleted, deletedAt];
}
