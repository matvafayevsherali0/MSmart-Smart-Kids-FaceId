import 'package:equatable/equatable.dart';

class UserInfo extends Equatable {
  final String id;
  final String? fullName;
  final String phone;
  final bool isActive;

  const UserInfo({
    this.id = "",
    this.fullName,
    this.phone = "",
    this.isActive = false,
  });

  @override
  List<Object?> get props => [id, fullName, phone, isActive];
}