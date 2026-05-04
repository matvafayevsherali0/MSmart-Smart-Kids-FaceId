import 'package:dio/dio.dart';

import '../../../../../assets/constants/network_constants.dart';
import '../../../../../core/network/dio_setting.dart';
import '../../../../../core/storage/storage.dart';
import '../../../../../core/storage/store_keys.dart';
import '../../../../../core/utils/service_locator.dart';
import '../../domain/entity/category_class_groups_response.dart';
import '../../domain/entity/category_positions_response.dart';
import '../../domain/entity/category_pupils_response.dart';
import '../../domain/entity/category_staff_response.dart';

abstract class CategorySelectionRemoteDataSource {
  Future<CategoryClassGroupsResponse> getClassGroups({
    required String organizationId,
    required int page,
  });

  Future<CategoryPupilsResponse> getPupils({
    required String organizationId,
    required String classGroupId,
    required int page,
    String search = '',
  });

  Future<CategoryStaffResponse> getStaff({
    required String organizationId,
    required int page,
    String search = '',
    String positionId = '',
  });

  Future<CategoryPositionsResponse> getPositions({required int page});
}

class CategorySelectionDataSourceImpl
    extends CategorySelectionRemoteDataSource {
  final _dio = serviceLocator<DioSettings>().dio;
  final _local = serviceLocator<StorageRepository>();

  Options get _options => Options(
    headers: {
      'Authorization': 'Bearer ${_local.getString(StoreKeys.accessToken)}',
    },
  );

  @override
  Future<CategoryClassGroupsResponse> getClassGroups({
    required String organizationId,
    required int page,
  }) async {
    try {
      final response = await _dio.get(
        classGroupsEndpoint,
        options: _options,
        queryParameters: {
          'page': page,
          'limit': 10,
          'organizationId': organizationId,
        },
      );

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return CategoryClassGroupsResponse.fromJson(response.data);
      }
      throw Exception('${response.statusCode} ${response.statusMessage}');
    } catch (e) {
      throw Exception('$e');
    }
  }

  @override
  Future<CategoryPupilsResponse> getPupils({
    required String organizationId,
    required String classGroupId,
    required int page,
    String search = '',
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'limit': 10,
        'organizationId': organizationId,
        'classGroupId': classGroupId,
      };

      if (search.trim().isNotEmpty) {
        queryParameters['search'] = search.trim();
      }

      final response = await _dio.get(
        employeeEndpoint,
        options: _options,
        queryParameters: queryParameters,
      );

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return CategoryPupilsResponse.fromJson(response.data);
      }
      throw Exception('${response.statusCode} ${response.statusMessage}');
    } catch (e) {
      throw Exception('$e');
    }
  }

  @override
  Future<CategoryStaffResponse> getStaff({
    required String organizationId,
    required int page,
    String search = '',
    String positionId = '',
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'limit': 10,
        'organizationId': organizationId,
      };

      if (search.trim().isNotEmpty) {
        queryParameters['search'] = search.trim();
      }
      if (positionId.trim().isNotEmpty) {
        queryParameters['positionId'] = positionId.trim();
      }
      final response = await _dio.get(
        staffEndpoint,
        options: _options,
        queryParameters: queryParameters,
      );

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return CategoryStaffResponse.fromJson(response.data);
      }
      throw Exception('${response.statusCode} ${response.statusMessage}');
    } catch (e) {
      throw Exception('$e');
    }
  }

  @override
  Future<CategoryPositionsResponse> getPositions({required int page}) async {
    try {
      final response = await _dio.get(
        organizationTypePositionsEndpoint,
        options: _options,
        queryParameters: {'page': page, 'limit': 10},
      );

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return CategoryPositionsResponse.fromJson(response.data);
      }
      throw Exception('${response.statusCode} ${response.statusMessage}');
    } catch (e) {
      throw Exception('$e');
    }
  }
}
