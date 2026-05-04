import 'package:equatable/equatable.dart';

import '../../../../common/data/data/meta_info.dart';

class CategoryPositions extends Equatable {
  final List<CategoryPositionItem> items;
  final MetaInfo meta;

  const CategoryPositions({
    this.items = const [],
    this.meta = const MetaInfo(),
  });

  @override
  List<Object?> get props => [items, meta];
}

class CategoryPositionItem extends Equatable {
  final String id;
  final String name;
  final String typeId;
  final String typeName;

  const CategoryPositionItem({
    this.id = '',
    this.name = '',
    this.typeId = '',
    this.typeName = '',
  });

  @override
  List<Object?> get props => [id, name, typeId, typeName];
}
