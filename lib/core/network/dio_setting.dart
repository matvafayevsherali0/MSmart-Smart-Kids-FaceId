import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

import '../../assets/constants/network_constants.dart';
import '../storage/storage.dart';
import '../storage/store_keys.dart';

final StreamController<String> dioStreamController =
    StreamController.broadcast();

class DioSettings {
  final StorageRepository _storage;
  bool listen = true;
  bool _unauthorizedHandled = false;

  DioSettings(this._storage);

  BaseOptions get _dioBaseOptions => BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(milliseconds: 35000),
    receiveTimeout: const Duration(milliseconds: 35000),
    followRedirects: false,
    persistentConnection: false,
    contentType: Headers.jsonContentType,
    headers: <String, dynamic>{
      Headers.acceptHeader: Headers.jsonContentType,
      'Accept-Language': _storage.getString('language', defValue: 'uz'),
    },
    validateStatus: (status) => status != null && status <= 500,
  );

  Dio get dio {
    final dio = Dio(_dioBaseOptions);
    if (kDebugMode && baseUrl.startsWith('https://')) {
      (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback = (cert, host, port) =>
            host == '85.198.70.124';
        return client;
      };
    }

    dio.interceptors
      ..add(
        LogInterceptor(
          responseBody: true,
          requestBody: true,
          request: true,
          requestHeader: true,
        ),
      )
      ..add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            final path = options.path;
            final token = _storage.getString(StoreKeys.accessToken);
            if (token.isNotEmpty) {
              _unauthorizedHandled = false;
            }
            final isAuthRequest =
                path.contains(signInEndpoint) ||
                path.contains(refreshTokenEndpoint);
            if (token.isNotEmpty &&
                !isAuthRequest &&
                !options.uri.toString().contains('billing/pay')) {
              options.headers['Authorization'] = 'Bearer $token';
            } else {
              options.headers.removeWhere(
                (key, value) => key.toString().toLowerCase() == 'authorization',
              );
            }
            return handler.next(options);
          },
          onResponse: (response, handler) async {
            final refreshTokenValue = _storage.getString(
              StoreKeys.refreshToken,
            );
            if (response.statusCode == 401 && refreshTokenValue.isNotEmpty) {
              final newAccessToken = await refreshToken();
              if (newAccessToken.isNotEmpty) {
                response.requestOptions.headers['Authorization'] =
                    'Bearer $newAccessToken';
                return handler.resolve(
                  await dio.fetch(response.requestOptions),
                );
              }
              await _handleUnauthorized();
              return handler.next(response);
            }
            if (response.statusCode == 401 && refreshTokenValue.isEmpty) {
              await _handleUnauthorized();
            }
            return handler.next(response);
          },
          onError: (e, handler) async {
            // kerak bo'lsa error handling
            return handler.next(e);
          },
        ),
      );
    return dio;
  }

  Future<String> refreshToken() async {
    try {
      final refresh = _storage.getString(StoreKeys.refreshToken);
      final response = await Dio(
        _dioBaseOptions,
      ).post(refreshTokenEndpoint, data: {'refreshToken': refresh});
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! <= 300) {
        listen = true;
        _unauthorizedHandled = false;
        final newAccess = response.data["data"]["accessToken"] as String;
        final newRefresh = response.data["data"]["refreshToken"] as String;

        await _storage.putString(StoreKeys.accessToken, value: newAccess);
        await _storage.putString(StoreKeys.refreshToken, value: newRefresh);

        return newAccess;
      }
      if (response.statusCode == 401) {
        listen = false;
        await _handleUnauthorized();
      }
    } catch (e) {
      listen = false;
      await _handleUnauthorized();
      return '';
    }
    return '';
  }

  Future<void> _handleUnauthorized() async {
    if (_unauthorizedHandled) return;
    _unauthorizedHandled = true;
    await _storage.clearAll();
    if (!dioStreamController.isClosed) {
      dioStreamController.add('401');
    }
  }
}
