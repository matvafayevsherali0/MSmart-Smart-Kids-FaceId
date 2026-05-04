import '../../../common/data/data/meta_info.dart';
import '../../../common/data/data/user_info.dart';
import '../../data/data/employee.dart';
import '../../data/data/staff.dart';
import '../../data/data/users.dart';
import '../entity/employees_response.dart';
import '../entity/get_users_response.dart';
import '../entity/staff_employee_ids_response.dart';
import '../entity/staff_response.dart';

class UsersMapper {
  Users mapGetUsersResponseToUsers(GetUsersResponse response) {
    final meta = response.data != null
        ? response.data!.meta != null
              ? MetaInfo(
                  total: response.data!.meta!.total ?? 0,
                  page: response.data!.meta!.page ?? 0,
                  limit: response.data!.meta!.limit ?? 0,
                  totalPages: response.data!.meta!.totalPages ?? 0,
                )
              : const MetaInfo()
        : const MetaInfo();
    final List<UserInfo> users = response.data != null
        ? response.data!.items != null
              ? response.data!.items!
                    .map(
                      (item) => UserInfo(
                        id: item.id ?? "",
                        fullName: item.fullname,
                        phone: item.phone ?? "",
                        isActive: item.isActive ?? false,
                      ),
                    )
                    .toList()
              : []
        : [];
    return Users(users: users, meta: meta);
  }

  Staff mapStaffResponseToStaff(StaffResponse res) {
    return Staff(
      items: res.data.items
          .map((e) => StaffItem(id: e.id, fullName: e.fullname, organizationId: e.organizationId, isActive: e.isActive))
          .toList(),
      meta: MetaInfo(
        total: res.data.meta.total ?? 0,
        page: res.data.meta.page ?? 0,
        limit: res.data.meta.limit ?? 0,
        totalPages: res.data.meta.totalPages ?? 0,
      ),
    );
  }

  List<String> mapStaffEmployeeIdsResponseToIdList(StaffEmployeeIdsResponse res) {
    return res.data.map((e) => e.id).where((id) => id.isNotEmpty).toList();
  }

  Employee mapEmployeeResponseToEmployee(EmployeesResponse res) {
    return Employee(
      items: res.data.items
          .map(
            (e) => EmployeeItem(
              id: e.id,
              fullName: e.fullname,
              phone: e.phoneNumber,
              organizationId: e.organizationId,
              isActive: e.isActive,
            ),
          )
          .toList(),
      meta: MetaInfo(
        total: res.data.meta.total ?? 0,
        page: res.data.meta.page ?? 0,
        limit: res.data.meta.limit ?? 0,
        totalPages: res.data.meta.totalPages ?? 0,
      ),
    );
  }
}
