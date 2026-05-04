import 'package:equatable/equatable.dart';

import '../../../../common/data/data/meta_info.dart';

class CategoryClassGroups extends Equatable {
  final List<CategoryClassGroupItem> items;
  final MetaInfo meta;

  const CategoryClassGroups({
    this.items = const [],
    this.meta = const MetaInfo(),
  });

  @override
  List<Object?> get props => [items, meta];
}

class CategoryClassGroupItem extends Equatable {
  final String id;
  final String name;
  final String section;
  final String shiftId;
  final String curatorId;
  final String classroomId;
  final int studentCount;
  final String organizationId;
  final String shiftName;
  final String shiftStartTime;
  final String shiftEndTime;
  final String organizationName;

  const CategoryClassGroupItem({
    this.id = '',
    this.name = '',
    this.section = '',
    this.shiftId = '',
    this.curatorId = '',
    this.classroomId = '',
    this.studentCount = 0,
    this.organizationId = '',
    this.shiftName = '',
    this.shiftStartTime = '',
    this.shiftEndTime = '',
    this.organizationName = '',
  });

  @override
  List<Object?> get props => [
    id,
    name,
    section,
    shiftId,
    curatorId,
    classroomId,
    studentCount,
    organizationId,
    shiftName,
    shiftStartTime,
    shiftEndTime,
    organizationName,
  ];
}
