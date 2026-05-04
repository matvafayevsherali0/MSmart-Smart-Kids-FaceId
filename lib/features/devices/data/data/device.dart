import 'package:equatable/equatable.dart';

class Device extends Equatable {
  final String id;
  final String name;
  final String macAddress;
  final String serialNumber;
  final String ipAddress;
  final int port;
  final String direction;
  final String locationDescription;
  final String organizationId;
  final String username;
  final String password;
  final String status;
  final bool isActive;

  const Device({
    this.id = "",
    this.name = "",
    this.macAddress = "",
    this.serialNumber = "",
    this.ipAddress = "",
    this.port = 0,
    this.direction = "",
    this.locationDescription = "",
    this.organizationId = "",
    this.username = "",
    this.password = "",
    this.status = "",
    this.isActive = false,
  });

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
    username,
    password,
    status,
    isActive,
  ];
}
