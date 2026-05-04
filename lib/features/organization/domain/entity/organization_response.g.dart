// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrganizationResponse _$OrganizationResponseFromJson(
  Map<String, dynamic> json,
) => OrganizationResponse(
  success: json['success'] as bool? ?? false,
  data: json['data'] == null
      ? const OrganizationDataDto()
      : OrganizationDataDto.fromJson(json['data'] as Map<String, dynamic>),
);

OrganizationDataDto _$OrganizationDataDtoFromJson(Map<String, dynamic> json) =>
    OrganizationDataDto(
      items:
          (json['items'] as List<dynamic>?)
              ?.map(
                (e) => OrganizationDataItem.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      meta: json['meta'] == null
          ? const MetaResponse()
          : MetaResponse.fromJson(json['meta'] as Map<String, dynamic>),
    );

OrganizationDataItem _$OrganizationDataItemFromJson(
  Map<String, dynamic> json,
) => OrganizationDataItem(
  id: json['id'] as String? ?? "",
  soatoId: (json['soatoId'] as num?)?.toInt() ?? 0,
  name: json['name'] as String? ?? "",
  typeId: json['typeId'] as String? ?? "",
  phoneNumber: json['phoneNumber'] as String? ?? "",
  address: json['address'] as String? ?? "",
  parentId: json['parentId'] as String? ?? "",
  isEducational: json['isEducational'] as bool? ?? false,
  activationDate: json['activationDate'] as String? ?? "",
  isLock: json['isLock'] as bool? ?? false,
  soato: json['soato'] == null
      ? const OrganizationDataItemSoatoDto()
      : OrganizationDataItemSoatoDto.fromJson(
          json['soato'] as Map<String, dynamic>,
        ),
  type: json['type'] == null
      ? const OrganizationDataItemTypeDto()
      : OrganizationDataItemTypeDto.fromJson(
          json['type'] as Map<String, dynamic>,
        ),
  createdAt: json['createdAt'] as String? ?? "",
  updatedAt: json['updatedAt'] as String? ?? "",
  isDeleted: json['isDeleted'] as bool? ?? false,
  deletedAt: json['deletedAt'] as String? ?? "",
);

OrganizationDataItemSoatoDto _$OrganizationDataItemSoatoDtoFromJson(
  Map<String, dynamic> json,
) => OrganizationDataItemSoatoDto(
  id: (json['id'] as num?)?.toInt() ?? 0,
  orderNum: (json['orderNum'] as num?)?.toInt() ?? 0,
  latitude: json['latitude'] as String? ?? "",
  longitude: json['longitude'] as String? ?? "",
  nameUz: json['nameUz'] as String? ?? "",
  nameUzc: json['nameUzc'] as String? ?? "",
  nameEn: json['nameEn'] as String? ?? "",
  nameRu: json['nameRu'] as String? ?? "",
  shortNameUz: json['shortNameUz'] as String? ?? "",
  shortNameUzc: json['shortNameUzc'] as String? ?? "",
  shortNameRu: json['shortNameRu'] as String? ?? "",
  shortNameEn: json['shortNameEn'] as String? ?? "",
  createdAt: json['createdAt'] as String? ?? "",
  updatedAt: json['updatedAt'] as String? ?? "",
  isDeleted: json['isDeleted'] as bool? ?? false,
);

OrganizationDataItemTypeDto _$OrganizationDataItemTypeDtoFromJson(
  Map<String, dynamic> json,
) => OrganizationDataItemTypeDto(
  id: json['id'] as String? ?? "",
  name: json['name'] as String? ?? "",
  createdAt: json['createdAt'] as String? ?? "",
  updatedAt: json['updatedAt'] as String? ?? "",
  isDeleted: json['isDeleted'] as bool? ?? false,
  deletedAt: json['deletedAt'] as String? ?? "",
);
