import 'package:flutter_test/flutter_test.dart';
import 'package:msmart_kids_faceid/features/users_comparison/domain/entity/backend_face_id_user.dart';
import 'package:msmart_kids_faceid/features/users_comparison/domain/entity/users_comparison_sync_plan.dart';

void main() {
  test(
    'plans backend users for Face ID and keeps Face ID-only users for deletion',
    () {
      final plan = UsersComparisonSyncPlan.build(
        backendUsers: const [
          BackendFaceIdUser(
            employeeNo: '11111111-1111-1111-1111-111111111111',
            name: 'Ali',
          ),
          BackendFaceIdUser(
            employeeNo: '22222222-2222-2222-2222-222222222222',
            name: 'Vali',
          ),
        ],
        hikvisionEmployeeNos: const [
          '11111111111111111111111111111111',
          '99999999999999999999999999999999',
        ],
      );

      expect(plan.backendUsersToCreate.map((user) => user.name), ['Vali']);
      expect(plan.hikvisionUsersToDelete, ['99999999999999999999999999999999']);
    },
  );

  test(
    'does not create duplicate backend users with the same normalized employee number',
    () {
      final plan = UsersComparisonSyncPlan.build(
        backendUsers: const [
          BackendFaceIdUser(
            employeeNo: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
            name: 'Ali',
          ),
          BackendFaceIdUser(
            employeeNo: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
            name: 'Ali 2',
          ),
        ],
        hikvisionEmployeeNos: const [],
      );

      expect(plan.backendUsersToCreate, hasLength(1));
      expect(plan.backendUsersToCreate.single.name, 'Ali');
    },
  );
}
