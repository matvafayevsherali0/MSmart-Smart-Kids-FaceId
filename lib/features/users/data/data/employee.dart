import 'package:equatable/equatable.dart';

import '../../../common/data/data/meta_info.dart';

class Employee extends Equatable {
  final List<EmployeeItem> items;
  final MetaInfo meta;

  const Employee({
    this.items = const [],
    this.meta = const MetaInfo()
  });

  @override
  List<Object?> get props => [items, meta];
}

class EmployeeItem extends Equatable {
  final String id;
  final String fullName;
  final String phone;
  final String organizationId;
  final bool isActive;

  const EmployeeItem({
    this.id = "",
    this.fullName = "",
    this.phone = "",
    this.organizationId = "",
    this.isActive = false,
  });

  @override
  List<Object?> get props => [id, fullName, phone, organizationId, isActive];
}