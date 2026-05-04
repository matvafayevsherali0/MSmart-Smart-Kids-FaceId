import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../common/domain/entities/meta_response.dart';

part 'devices_response.g.dart';

@JsonSerializable(createToJson: false)
class DevicesResponse extends Equatable {
  final bool success;
  final DevicesDataDto data;

  const DevicesResponse({this.success = false, this.data = const DevicesDataDto()});

  factory DevicesResponse.fromJson(Map<String, dynamic> json) => _$DevicesResponseFromJson(json);

  @override
  List<Object?> get props => [success, data];
}

@JsonSerializable(createToJson: false)
class DevicesDataDto extends Equatable {
  final List<DevicesItemDto> items;
  final MetaResponse meta;

  const DevicesDataDto({this.items = const [], this.meta = const MetaResponse()});

  factory DevicesDataDto.fromJson(Map<String, dynamic> json) => _$DevicesDataDtoFromJson(json);

  @override
  List<Object?> get props => [items, meta];
}

@JsonSerializable(createToJson: false)
class DevicesItemDto extends Equatable {
  final String id;
  final String name;
  final String macAddress;
  final String serialNumber;
  final String ipAddress;
  final int port;
  final String direction;
  final String locationDescription;
  final String organizationId;
  final String classroomId;
  final String username;
  final String password;
  final String status;
  final String lastHeartbeatAt;
  final bool isActive;
  final String createdAt;
  final String updatedAt;
  final bool isDeleted;

  const DevicesItemDto({
    this.id = "",
    this.name = "",
    this.macAddress = "",
    this.serialNumber = "",
    this.ipAddress = "",
    this.port = 0,
    this.direction = "",
    this.locationDescription = "",
    this.organizationId = "",
    this.classroomId = "",
    this.username = "",
    this.password = "",
    this.status = "",
    this.lastHeartbeatAt = "",
    this.isActive = false,
    this.createdAt = "",
    this.updatedAt = "",
    this.isDeleted = false,
  });

  factory DevicesItemDto.fromJson(Map<String, dynamic> json) => _$DevicesItemDtoFromJson(json);

  @override
  List<Object?> get props => [
    id,
    name,
    macAddress,
    serialNumber,
    ipAddress,
    port,
    direction,
    locationDescription,
    organizationId,
    classroomId,
    username,
    password,
    status,
    lastHeartbeatAt,
    isActive,
    createdAt,
    updatedAt,
    isDeleted,
  ];
}
