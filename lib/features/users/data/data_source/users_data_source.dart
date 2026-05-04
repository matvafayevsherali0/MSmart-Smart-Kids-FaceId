import 'package:dio/dio.dart';

import '../../../../assets/constants/network_constants.dart';
import '../../../../core/network/dio_setting.dart';
import '../../../../core/storage/storage.dart';
import '../../../../core/storage/store_keys.dart';
import '../../../../core/utils/service_locator.dart';
import '../../domain/entity/employees_response.dart';
import '../../domain/entity/get_users_response.dart';
import '../../domain/entity/staff_employee_ids_response.dart';
import '../../domain/entity/staff_response.dart';

abstract class UsersRemoteDataSource {
  Future<GetUsersResponse> getUsers({required int page});

  Future<StaffResponse> getStaff({required String organizationId, required int page});

  Future<EmployeesResponse> getEmployees({required String organizationId, required int page});

  Future<StaffEmployeeIdsResponse> getStaffIds({required String organizationId});

  Future<StaffEmployeeIdsResponse> getEmployeeIds({required String organizationId});
}

class UsersDataSourceImpl extends UsersRemoteDataSource {
  final _dio = serviceLocator<DioSettings>().dio;
  final _local = serviceLocator<StorageRepository>();

  @override
  Future<GetUsersResponse> getUsers({required int page}) async {
    try {
      final response = await _dio.get(
        usersEndpoint,
        options: Options(headers: {"Authorization": "Bearer ${_local.getString(StoreKeys.accessToken)}"}),
        queryParameters: {"page": page, "limit": 15},
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return GetUsersResponse.fromJson(response.data);
      } else {
        throw Exception("""${response.statusCode} ${response.statusMessage}""");
      }
    } catch (e) {
      throw Exception("""$e""");
    }
  }

  @override
  Future<EmployeesResponse> getEmployees({required String organizationId, required int page}) async {
    try {
      final response = await _dio.get(
        employeeEndpoint,
        options: Options(headers: {"Authorization": "Bearer ${_local.getString(StoreKeys.accessToken)}"}),
        queryParameters: {"organizationId": organizationId, "page": page, "limit": 15},
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return EmployeesResponse.fromJson(response.data);
      } else {
        throw Exception("""${response.statusCode} ${response.statusMessage}""");
      }
    } catch (e) {
      throw Exception("""$e""");
    }
  }

  @override
  Future<StaffEmployeeIdsResponse> getStaffIds({required String organizationId}) async {
    try {
      final response = await _dio.get(
        staffIdsEndpoint,
        options: Options(headers: {'Authorization': 'Bearer ${_local.getString(StoreKeys.accessToken)}'}),
        queryParameters: {'organizationId': organizationId, 'referenceType': "staff"},
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return StaffEmployeeIdsResponse.fromJson(data);
        }
        throw Exception('Kutilmagan javob turi');
      } else {
        throw Exception('${response.statusCode} ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  @override
  Future<StaffEmployeeIdsResponse> getEmployeeIds({required String organizationId}) async {
    try {
      final response = await _dio.get(
        employeeIdsEndpoint,
        options: Options(headers: {'Authorization': 'Bearer ${_local.getString(StoreKeys.accessToken)}'}),
        queryParameters: {'organizationId': organizationId},
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return StaffEmployeeIdsResponse.fromJson(data);
        }
        throw Exception('Kutilmagan javob turi');
      } else {
        throw Exception('${response.statusCode} ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  @override
  Future<StaffResponse> getStaff({required String organizationId, required int page}) async {
    try {
      final response = await _dio.get(
        staffEndpoint,
        options: Options(headers: {"Authorization": "Bearer ${_local.getString(StoreKeys.accessToken)}"}),
        queryParameters: {"organizationId": organizationId, "page": page, "limit": 15},
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return StaffResponse.fromJson(response.data);
      } else {
        throw Exception("""${response.statusCode} ${response.statusMessage}""");
      }
    } catch (e) {
      throw Exception("""$e""");
    }
  }
}
