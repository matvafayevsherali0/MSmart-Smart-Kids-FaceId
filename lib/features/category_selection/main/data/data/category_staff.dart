import 'package:equatable/equatable.dart';

import '../../../../common/data/data/meta_info.dart';

class CategoryStaff extends Equatable {
  final List<CategoryStaffItem> items;
  final MetaInfo meta;

  const CategoryStaff({this.items = const [], this.meta = const MetaInfo()});

  @override
  List<Object?> get props => [items, meta];
}

class CategoryStaffItem extends Equatable {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String jobEntryDate;
  final String organizationId;
  final String positionId;
  final String staffType;
  final bool isActive;
  final bool hasFaceEnrollment;
  final String faceEnrollmentId;
  /// `faceEnrollment.file.url` (masalan `/uploads/...`); bo‘sh bo‘lishi mumkin.
  final String faceEnrollmentFileRelativeUrl;

  const CategoryStaffItem({
    this.id = '',
    this.fullName = '',
    this.phoneNumber = '',
    this.jobEntryDate = '',
    this.organizationId = '',
    this.positionId = '',
    this.staffType = '',
    this.isActive = false,
    this.hasFaceEnrollment = false,
    this.faceEnrollmentId = '',
    this.faceEnrollmentFileRelativeUrl = '',
  });

  @override
  List<Object?> get props => [
    id,
    fullName,
    phoneNumber,
    jobEntryDate,
    organizationId,
    positionId,
    staffType,
    isActive,
    hasFaceEnrollment,
    faceEnrollmentId,
    faceEnrollmentFileRelativeUrl,
  ];
}
