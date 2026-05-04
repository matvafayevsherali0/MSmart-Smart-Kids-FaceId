import 'package:equatable/equatable.dart';

import '../../../common/data/data/meta_info.dart';

class Organization extends Equatable {
  final MetaInfo meta;
  final List<OrganizationItems> items;

  const Organization({required this.meta, this.items = const []});

  @override
  List<Object?> get props => [meta, items];
}

class OrganizationItems extends Equatable {
  final String id;
  final String name;
  final String address;

  const OrganizationItems({required this.id, required this.name, required this.address});

  @override
  List<Object?> get props => [id, name, address];
}
