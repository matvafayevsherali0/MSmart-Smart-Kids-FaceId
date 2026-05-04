import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../assets/constants/network_constants.dart';
import '../../../../core/network/dio_setting.dart';
import '../../../../core/storage/storage.dart';
import '../../../../core/storage/store_keys.dart';
import '../../../../core/utils/service_locator.dart';
import '../../domain/entity/logout_response.dart';
import '../../domain/entity/sign_in_request.dart';
import '../../domain/entity/sign_in_response.dart';

abstract class AuthRemoteDataSource {
  Future<SignInResponse> signIn({required SignInRequest signInRequest});

  Future<LogoutResponse> logout();
}

class AuthDataSourceImpl extends AuthRemoteDataSource {
  final _dio = serviceLocator<DioSettings>().dio;
  final _local = serviceLocator<StorageRepository>();

  @override
  Future<SignInResponse> signIn({required SignInRequest signInRequest}) async {
    try {
      final response = await _dio.post(
        signInEndpoint,
        data: signInRequest.toJson(),
        options: Options(
          contentType: Headers.jsonContentType,
          headers: {Headers.acceptHeader: Headers.jsonContentType},
        ),
      );
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        return SignInResponse.fromJson(response.data);
      } else {
        throw Exception("""${response.statusCode} ${response.statusMessage}""");
      }
    } on DioException catch (e) {
      if (e.error is HandshakeException) {
        throw Exception(
          "SSL sertifikat tasdiqlanmadi. Server sertifikatini tekshiring yoki debug rejimda ishonchli sertifikatdan foydalaning.",
        );
      }
      if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception(
          "Server 35 soniyada javob bermadi. Base URL, HTTP/HTTPS va serverning javob vaqtini tekshiring.",
        );
      }
      throw Exception(
        e.response != null
            ? """${e.response?.statusCode} ${e.response?.statusMessage}"""
            : (e.message ?? e.toString()),
      );
    } catch (e) {
      throw Exception("""$e""");
    }
  }

  @override
  Future<LogoutResponse> logout() async {
    try {
      final response = await _dio.post(
        logoutEndpoint,
        data: {"refreshToken": _local.getString(StoreKeys.refreshToken)},
        options: Options(
          headers: {
            "Authorization":
                "Bearer ${_local.getString(StoreKeys.accessToken)}",
          },
        ),
      );
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        return LogoutResponse.fromJson(response.data);
      } else {
        throw Exception("""${response.statusCode} ${response.statusMessage}""");
      }
    } on DioException catch (e) {
      throw Exception(
        e.response != null
            ? """${e.response?.statusCode} ${e.response?.statusMessage}"""
            : (e.message ?? e.toString()),
      );
    } catch (e) {
      throw Exception("""$e""");
    }
  }
}
