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

  /// Backend `faceEnrollment.file.url` (nisbiy yoki to‘liq); Hikvisionda yuz bo‘lmasa shu yerdan qo‘shiladi.
  final String? faceEnrollmentFileRelativeUrl;
  final String? faceEnrollmentId;
  final String? studentId;
  final String? staffId;
  final String? organizationId;

  const HikvisionStarted({
    required this.employeeNo,
    required this.name,
    this.faceEnrollmentFileRelativeUrl,
    this.faceEnrollmentId,
    this.studentId,
    this.staffId,
    this.organizationId,
  });

  @override
  List<Object?> get props => [
    employeeNo,
    name,
    faceEnrollmentFileRelativeUrl,
    faceEnrollmentId,
    studentId,
    staffId,
    organizationId,
  ];
}

class HikvisionCreateUserPressed extends HikvisionEvent {
  final String employeeNo;
  final String name;

  const HikvisionCreateUserPressed({
    required this.employeeNo,
    required this.name,
  });

  @override
  List<Object?> get props => [employeeNo, name];
}

class HikvisionAddPhotoPressed extends HikvisionEvent {
  final String deviceEmployeeNo;
  final String lookupEmployeeNo;
  final String name;
  final String? studentId;
  final String? staffId;
  final String? organizationId;
  final String? deviceId;
  final String? faceEnrollmentId;

  const HikvisionAddPhotoPressed({
    required this.deviceEmployeeNo,
    required this.lookupEmployeeNo,
    required this.name,
    this.studentId,
    this.staffId,
    this.organizationId,
    this.deviceId,
    this.faceEnrollmentId,
  });

  @override
  List<Object?> get props => [
    deviceEmployeeNo,
    lookupEmployeeNo,
    name,
    studentId,
    staffId,
    organizationId,
    deviceId,
    faceEnrollmentId,
  ];
}

class HikvisionDeleteUserPressed extends HikvisionEvent {
  final String employeeNo;
  final VoidCallback onSuccess;
  final String? faceEnrollmentId;
  final String deviceId;

  const HikvisionDeleteUserPressed({
    required this.employeeNo,
    required this.onSuccess,
    this.faceEnrollmentId,
    this.deviceId = '',
  });

  @override
  List<Object?> get props => [employeeNo, faceEnrollmentId, deviceId];
}
