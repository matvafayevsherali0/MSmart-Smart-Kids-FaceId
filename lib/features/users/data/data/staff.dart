import 'package:equatable/equatable.dart';

import '../../../common/data/data/meta_info.dart';

class Staff extends Equatable {
  final List<StaffItem> items;
  final MetaInfo meta;

  const Staff({this.items = const [], this.meta = const MetaInfo()});

  @override
  List<Object?> get props => [items, meta];
}

class StaffItem extends Equatable {
  final String id;
  final String fullName;
  final String organizationId;
  final bool isActive;

  const StaffItem({this.id = "", this.fullName = "", this.organizationId = "", this.isActive = false});

  @override
  List<Object?> get props => [id, fullName, organizationId, isActive];
}
