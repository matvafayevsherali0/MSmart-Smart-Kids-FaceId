// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'devices_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DevicesResponse _$DevicesResponseFromJson(Map<String, dynamic> json) =>
    DevicesResponse(
      success: json['success'] as bool? ?? false,
      data: json['data'] == null
          ? const DevicesDataDto()
          : DevicesDataDto.fromJson(json['data'] as Map<String, dynamic>),
    );

DevicesDataDto _$DevicesDataDtoFromJson(Map<String, dynamic> json) =>
    DevicesDataDto(
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => DevicesItemDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      meta: json['meta'] == null
          ? const MetaResponse()
          : MetaResponse.fromJson(json['meta'] as Map<String, dynamic>),
    );

DevicesItemDto _$DevicesItemDtoFromJson(Map<String, dynamic> json) =>
    DevicesItemDto(
      id: json['id'] as String? ?? "",
      name: json['name'] as String? ?? "",
      macAddress: json['macAddress'] as String? ?? "",
      serialNumber: json['serialNumber'] as String? ?? "",
      ipAddress: json['ipAddress'] as String? ?? "",
      port: (json['port'] as num?)?.toInt() ?? 0,
      direction: json['direction'] as String? ?? "",
      locationDescription: json['locationDescription'] as String? ?? "",
      organizationId: json['organizationId'] as String? ?? "",
      classroomId: json['classroomId'] as String? ?? "",
      username: json['username'] as String? ?? "",
      password: json['password'] as String? ?? "",
      status: json['status'] as String? ?? "",
      lastHeartbeatAt: json['lastHeartbeatAt'] as String? ?? "",
      isActive: json['isActive'] as bool? ?? false,
      createdAt: json['createdAt'] as String? ?? "",
      updatedAt: json['updatedAt'] as String? ?? "",
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
