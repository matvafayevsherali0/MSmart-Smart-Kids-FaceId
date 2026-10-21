import 'package:equatable/equatable.dart';

class BackendFaceIdUser extends Equatable {
  final String employeeNo;
  final String name;
  final String faceImageUrl;

  const BackendFaceIdUser({
    required this.employeeNo,
    required this.name,
    this.faceImageUrl = '',
  });

  String get displayName {
    final trimmedName = name.trim();
    return trimmedName.isEmpty ? employeeNo : trimmedName;
  }

  @override
  List<Object?> get props => [employeeNo, name, faceImageUrl];
}
