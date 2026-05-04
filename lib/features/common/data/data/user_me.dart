import 'package:equatable/equatable.dart';

class UserMe extends Equatable {
  final String id;
  final String phone;
  final bool isActive;
  final List<UserMeOrganizationItem> organizations;

  const UserMe({this.id = "", this.phone = "", this.isActive = false, this.organizations = const []});

  @override
  List<Object?> get props => [id, phone, isActive, organizations];
}

class UserMeOrganizationItem extends Equatable {
  final String id;
  final String name;
  final String positionId;
  final String positionName;
  final bool isPrimary;

  const UserMeOrganizationItem({this.id = "", this.name = "", this.positionId = "", this.positionName = "", this.isPrimary = false});

  @override
  List<Object?> get props => [id, name, positionId, positionName, isPrimary];
}
