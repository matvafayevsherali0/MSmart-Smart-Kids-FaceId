import 'package:dio/dio.dart';

import '../../../../assets/constants/network_constants.dart';
import '../../../../core/network/dio_setting.dart';
import '../../../../core/storage/storage.dart';
import '../../../../core/storage/store_keys.dart';
import '../../../../core/utils/service_locator.dart';
import '../../domain/entity/devices_response.dart';

abstract class DevicesRemoteDataSource {
  Future<DevicesResponse> getDevices({
    required String organizationId,
    required int page,
  });
}

class DevicesDataSourceImpl extends DevicesRemoteDataSource {
  final _dio = serviceLocator<DioSettings>().dio;
  final _local = serviceLocator<StorageRepository>();

  @override
  Future<DevicesResponse> getDevices({
    required String organizationId,
    required int page,
  }) async {
    try {
      final response = await _dio.get(
        devicesEndpoint,
        options: Options(
          headers: {
            "Authorization":
                "Bearer ${_local.getString(StoreKeys.accessToken)}",
          },
        ),
        queryParameters: {
          "organizationId": organizationId,
          "page": page,
          "limit": 15,
        },
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return DevicesResponse.fromJson(response.data);
      } else {
        throw Exception("""${response.statusCode} ${response.statusMessage}""");
      }
    } catch (e) {
      throw Exception("""$e""");
    }
  }
}
