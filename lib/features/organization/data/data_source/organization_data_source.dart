import 'package:dio/dio.dart';

import '../../../../assets/constants/network_constants.dart';
import '../../../../core/network/dio_setting.dart';
import '../../../../core/storage/storage.dart';
import '../../../../core/storage/store_keys.dart';
import '../../../../core/utils/service_locator.dart';
import '../../../common/domain/entities/user_me_response.dart';
import '../../domain/entity/organization_response.dart';

abstract class OrganizationRemoteDataSource {
  Future<OrganizationResponse> getOrganizations({required int page});

  Future<UserMeResponse> getUserMe();
}

class OrganizationDataSourceImpl extends OrganizationRemoteDataSource {
  final _dio = serviceLocator<DioSettings>().dio;
  final _local = serviceLocator<StorageRepository>();

  @override
  Future<OrganizationResponse> getOrganizations({required int page}) async {
    try {
      final response = await _dio.get(
        organizationsEndpoint,
        queryParameters: {"page": page, "limit": 15},
        options: Options(headers: {"Authorization": "Bearer ${_local.getString(StoreKeys.accessToken)}"}),
      );

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return OrganizationResponse.fromJson(response.data);
      } else {
        throw Exception("""${response.statusCode} ${response.statusMessage}""");
      }
    } catch (e) {
      throw Exception("""$e""");
    }
  }

  @override
  Future<UserMeResponse> getUserMe() async {
    try {
      final response = await _dio.get(
        userMeEndpoint,
        options: Options(headers: {"Authorization": "Bearer ${_local.getString(StoreKeys.accessToken)}"}),
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return UserMeResponse.fromJson(response.data);
      } else {
        throw Exception("""${response.statusCode} ${response.statusMessage}""");
      }
    } catch (e) {
      throw Exception("""$e""");
    }
  }
}
