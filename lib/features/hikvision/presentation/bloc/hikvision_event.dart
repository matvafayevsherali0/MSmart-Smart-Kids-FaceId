part of 'hikvision_bloc.dart';

@immutable
sealed class HikvisionEvent extends Equatable {
  const HikvisionEvent();

  @override
  List<Object?> get props => [];
}

class HikvisionStarted extends HikvisionEvent {
  final String employeeNo;
  final String name;

  const HikvisionStarted({required this.employeeNo, required this.name});

  @override
  List<Object?> get props => [employeeNo, name];
}

class HikvisionCreateUserPressed extends HikvisionEvent {
  final String employeeNo;
  final String name;

  const HikvisionCreateUserPressed({required this.employeeNo, required this.name});

  @override
  List<Object?> get props => [employeeNo, name];
}

class HikvisionAddPhotoPressed extends HikvisionEvent {
  final String deviceEmployeeNo;
  final String lookupEmployeeNo;
  final String? studentId;
  final String? staffId;
  final String? organizationId;
  final String? deviceId;

  const HikvisionAddPhotoPressed({
    required this.deviceEmployeeNo,
    required this.lookupEmployeeNo,
    this.studentId,
    this.staffId,
    this.organizationId,
    this.deviceId,
  });

  @override
  List<Object?> get props =>
      [deviceEmployeeNo, lookupEmployeeNo, studentId, staffId, organizationId, deviceId];
}

class HikvisionDeleteUserPressed extends HikvisionEvent {
  final String employeeNo;
  final VoidCallback onSuccess;

  const HikvisionDeleteUserPressed({required this.employeeNo, required this.onSuccess});

  @override
  List<Object?> get props => [employeeNo];
}

