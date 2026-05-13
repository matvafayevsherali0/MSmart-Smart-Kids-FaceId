import '../../../../common/data/data/meta_info.dart';
import '../../data/data/category_class_group.dart';
import '../../data/data/category_position.dart';
import '../../data/data/category_pupil.dart';
import '../../data/data/category_staff.dart';
import '../entity/category_class_groups_response.dart';
import '../entity/category_positions_response.dart';
import '../entity/category_pupils_response.dart';
import '../entity/category_staff_response.dart';

class CategorySelectionMapper {
  CategoryClassGroups mapClassGroupsResponseToClassGroups(
    CategoryClassGroupsResponse response,
  ) {
    return CategoryClassGroups(
      items: response.data.items
          .map(
            (e) => CategoryClassGroupItem(
              id: e.id,
              name: e.name,
              section: e.section,
              shiftId: e.shiftId,
              curatorId: e.curatorId ?? '',
              classroomId: e.classroomId ?? '',
              studentCount: e.studentCount,
              organizationId: e.organizationId,
              shiftName: e.shift.name,
              shiftStartTime: e.shift.startTime,
              shiftEndTime: e.shift.endTime,
              organizationName: e.organization.name,
            ),
          )
          .toList(),
      meta: MetaInfo(
        total: response.data.meta.total ?? 0,
        page: response.data.meta.page ?? 0,
        limit: response.data.meta.limit ?? 0,
        totalPages: response.data.meta.totalPages ?? 0,
      ),
    );
  }

  CategoryPupils mapPupilsResponseToPupils(CategoryPupilsResponse response) {
    return CategoryPupils(
      items: response.data.items
          .map(
            (e) => CategoryPupilItem(
              id: e.id,
              fullName: e.fullname,
              birthday: e.birthday,
              address: e.address,
              photoId: e.photoId ?? '',
              classGroupId: e.classGroupId,
              organizationId: e.organizationId,
              isActive: e.isActive,
              enrolledAt: e.enrolledAt,
              hasFaceEnrollment: e.faceEnrollment != null,
              faceEnrollmentId: _extractFaceEnrollmentId(e.faceEnrollment),
              faceEnrollmentFileRelativeUrl:
                  _extractFaceEnrollmentFileRelativeUrl(e.faceEnrollment),
            ),
          )
          .toList(),
      meta: MetaInfo(
        total: response.data.meta.total ?? 0,
        page: response.data.meta.page ?? 0,
        limit: response.data.meta.limit ?? 0,
        totalPages: response.data.meta.totalPages ?? 0,
      ),
    );
  }

  CategoryStaff mapStaffResponseToStaff(CategoryStaffResponse response) {
    return CategoryStaff(
      items: response.data.items
          .map(
            (e) => CategoryStaffItem(
              id: e.id,
              fullName: e.fullname,
              phoneNumber: e.phoneNumber,
              jobEntryDate: e.jobEntryDate,
              organizationId: e.organizationId,
              positionId: e.positionId,
              staffType: e.staffType,
              isActive: e.isActive,
              hasFaceEnrollment: e.faceEnrollment != null,
              faceEnrollmentId: _extractFaceEnrollmentId(e.faceEnrollment),
              faceEnrollmentFileRelativeUrl:
                  _extractFaceEnrollmentFileRelativeUrl(e.faceEnrollment),
            ),
          )
          .toList(),
      meta: MetaInfo(
        total: response.data.meta.total ?? 0,
        page: response.data.meta.page ?? 0,
        limit: response.data.meta.limit ?? 0,
        totalPages: response.data.meta.totalPages ?? 0,
      ),
    );
  }

  CategoryPositions mapPositionsResponseToPositions(
    CategoryPositionsResponse response,
  ) {
    return CategoryPositions(
      items: response.data.items
          .map(
            (e) => CategoryPositionItem(
              id: e.id,
              name: e.name,
              typeId: e.type.id,
              typeName: e.type.name,
            ),
          )
          .toList(),
      meta: MetaInfo(
        total: response.data.meta.total ?? 0,
        page: response.data.meta.page ?? 0,
        limit: response.data.meta.limit ?? 0,
        totalPages: response.data.meta.totalPages ?? 0,
      ),
    );
  }

  String _extractFaceEnrollmentId(Object? raw) {
    if (raw is Map<String, dynamic>) {
      final v = raw['id']?.toString() ?? '';
      return v.trim();
    }
    if (raw is Map) {
      final v = raw['id']?.toString() ?? '';
      return v.trim();
    }
    return '';
  }

  /// `file.url` — o‘chirilgan enrollment uchun rasm URL berilmaydi.
  String _extractFaceEnrollmentFileRelativeUrl(Object? raw) {
    Map<dynamic, dynamic>? fe;
    if (raw is Map<String, dynamic>) {
      fe = raw;
    } else if (raw is Map) {
      fe = raw;
    }
    if (fe == null) return '';
    if (fe['isDeleted'] == true) return '';

    final file = fe['file'];
    if (file is! Map) return '';
    final url = file['url']?.toString().trim() ?? '';
    return url;
  }
}
