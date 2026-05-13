import 'package:equatable/equatable.dart';

import '../../../../common/data/data/meta_info.dart';

class CategoryPupils extends Equatable {
  final List<CategoryPupilItem> items;
  final MetaInfo meta;

  const CategoryPupils({this.items = const [], this.meta = const MetaInfo()});

  @override
  List<Object?> get props => [items, meta];
}

class CategoryPupilItem extends Equatable {
  final String id;
  final String fullName;
  final String birthday;
  final String address;
  final String photoId;
  final String classGroupId;
  final String organizationId;
  final bool isActive;
  final String enrolledAt;
  final bool hasFaceEnrollment;
  final String faceEnrollmentId;
  final String faceEnrollmentFileRelativeUrl;

  const CategoryPupilItem({
    this.id = '',
    this.fullName = '',
    this.birthday = '',
    this.address = '',
    this.photoId = '',
    this.classGroupId = '',
    this.organizationId = '',
    this.isActive = false,
    this.enrolledAt = '',
    this.hasFaceEnrollment = false,
    this.faceEnrollmentId = '',
    this.faceEnrollmentFileRelativeUrl = '',
  });

  @override
  List<Object?> get props => [
    id,
    fullName,
    birthday,
    address,
    photoId,
    classGroupId,
    organizationId,
    isActive,
    enrolledAt,
    hasFaceEnrollment,
    faceEnrollmentId,
    faceEnrollmentFileRelativeUrl,
  ];
}
