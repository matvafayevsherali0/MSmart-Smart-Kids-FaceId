import '../../../hikvision/data/service/hikvision_service.dart';
import 'backend_face_id_user.dart';

class UsersComparisonSyncPlan {
  final List<BackendFaceIdUser> backendUsersToCreate;
  final List<String> hikvisionUsersToDelete;

  const UsersComparisonSyncPlan({
    required this.backendUsersToCreate,
    required this.hikvisionUsersToDelete,
  });

  factory UsersComparisonSyncPlan.build({
    required List<BackendFaceIdUser> backendUsers,
    required List<String> hikvisionEmployeeNos,
  }) {
    final backendByNormalizedId = <String, BackendFaceIdUser>{};
    for (final user in backendUsers) {
      final normalizedId = HikvisionService.normalizeEmployeeNoForIsapi(
        user.employeeNo,
      );
      if (normalizedId.isEmpty) continue;

      final current = backendByNormalizedId[normalizedId];
      if (current == null ||
          (current.name.trim().isEmpty && user.name.trim().isNotEmpty)) {
        backendByNormalizedId[normalizedId] = user;
      }
    }

    final hikvisionIds = hikvisionEmployeeNos
        .map(HikvisionService.normalizeEmployeeNoForIsapi)
        .where((id) => id.isNotEmpty)
        .toSet();

    final backendUsersToCreate = backendByNormalizedId.entries
        .where((entry) => !hikvisionIds.contains(entry.key))
        .map((entry) => entry.value)
        .toList();

    final hikvisionUsersToDelete = <String>[];
    final seenHikvisionIds = <String>{};
    for (final employeeNo in hikvisionEmployeeNos) {
      final normalizedId = HikvisionService.normalizeEmployeeNoForIsapi(
        employeeNo,
      );
      if (normalizedId.isEmpty ||
          backendByNormalizedId.containsKey(normalizedId) ||
          !seenHikvisionIds.add(normalizedId)) {
        continue;
      }
      hikvisionUsersToDelete.add(employeeNo);
    }

    return UsersComparisonSyncPlan(
      backendUsersToCreate: backendUsersToCreate,
      hikvisionUsersToDelete: hikvisionUsersToDelete,
    );
  }
}
