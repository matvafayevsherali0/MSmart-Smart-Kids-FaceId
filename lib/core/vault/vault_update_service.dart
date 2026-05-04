import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../assets/constants/network_constants.dart';

class VaultUpdateService {
  late final Dio _dio =
      Dio(
          BaseOptions(
            baseUrl: vaultBaseUrl,
            connectTimeout: const Duration(milliseconds: 35000),
            receiveTimeout: const Duration(milliseconds: 35000),
            contentType: Headers.jsonContentType,
            headers: <String, dynamic>{
              Headers.acceptHeader: Headers.jsonContentType,
            },
            validateStatus: (status) => status != null && status <= 500,
          ),
        )
        ..interceptors.add(
          LogInterceptor(
            request: true,
            requestHeader: true,
            requestBody: true,
            responseHeader: true,
            responseBody: true,
          ),
        );

  Future<ForceUpdateResult> checkForForceUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final isAndroid = Platform.isAndroid;
      final isIos = Platform.isIOS;

      final appVersionCode = int.tryParse(packageInfo.buildNumber) ?? 1;
      final appVersionName = packageInfo.version;
      debugPrint(
        "[VaultUpdateService] appVersionName=$appVersionName, appVersionCode=$appVersionCode, platform=${isAndroid ? 'android' : 'ios'}",
      );

      final response = await _dio.post(
        vaultConfigsEndpoint,
        data: <String, dynamic>{
          "platform": "mobile",
          "conditions": <String, dynamic>{
            "android_version": isAndroid ? appVersionName : null,
            "ios_version": isIos ? appVersionName : null,
            "mode": kReleaseMode ? "release" : "debug",
          },
        },
        options: Options(
          headers: <String, dynamic>{
            "X-Vault-App-Id": vaultAppId,
            "X-Vault-App-Secure": vaultSecureToken,
            "X-Device-Type": isAndroid ? "android" : "ios",
            "X-App-Version": appVersionName,
            "X-App-Version-Code": appVersionCode.toString(),
          },
        ),
      );

      if (response.statusCode == null ||
          response.statusCode! < 200 ||
          response.statusCode! >= 300) {
        debugPrint(
          "[VaultUpdateService] request failed status=${response.statusCode}",
        );
        return const ForceUpdateResult.notRequired();
      }

      final updateData = _extractUpdateData(response.data);
      if (updateData == null) {
        debugPrint("[VaultUpdateService] updateData is null");
        return const ForceUpdateResult.notRequired();
      }

      final remoteAndroidVersion = _toInt(updateData["androidVersion"]);
      final remoteIosVersion = _toInt(updateData["iosVersion"]);
      debugPrint(
        "[VaultUpdateService] remoteAndroidVersion=$remoteAndroidVersion remoteIosVersion=$remoteIosVersion",
      );

      if (isAndroid && remoteAndroidVersion > appVersionCode) {
        final url = (updateData["playMarketUrl"] ?? "").toString().trim();
        if (url.isNotEmpty) {
          debugPrint("[VaultUpdateService] force update required for android");
          return ForceUpdateResult.required(url: url);
        }
      }

      if (isIos && remoteIosVersion > appVersionCode) {
        final url = (updateData["appStoreUrl"] ?? "").toString().trim();
        if (url.isNotEmpty) {
          debugPrint("[VaultUpdateService] force update required for ios");
          return ForceUpdateResult.required(url: url);
        }
      }

      return const ForceUpdateResult.notRequired();
    } catch (e) {
      debugPrint("[VaultUpdateService] checkForForceUpdate error: $e");
      return const ForceUpdateResult.notRequired();
    }
  }

  Map<String, dynamic>? _extractUpdateData(dynamic responseData) {
    if (responseData is! Map) return null;

    final directData = responseData["data"];
    if (directData is Map<String, dynamic> &&
        (directData.containsKey("androidVersion") ||
            directData.containsKey("iosVersion"))) {
      return directData;
    }

    final envelopeData = responseData["data"];
    if (envelopeData is! Map) return null;
    final items = envelopeData["items"];
    if (items is! List) return null;

    for (final raw in items) {
      if (raw is! Map) continue;
      if (raw["key"] != vaultUpdateConfigKey) continue;
      final value = raw["value"];
      if (value is Map<String, dynamic>) {
        final nested = value["data"];
        if (nested is Map<String, dynamic>) return nested;
        return value;
      }
      if (value is String) {
        try {
          final decoded = jsonDecode(value);
          if (decoded is Map<String, dynamic>) {
            final nested = decoded["data"];
            if (nested is Map<String, dynamic>) return nested;
            return decoded;
          }
        } catch (_) {}
      }
    }
    return null;
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Future<void> _openExternal(String rawUrl) async {
    final uri = Uri.tryParse(rawUrl);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> openStore(String rawUrl) async {
    await _openExternal(rawUrl);
  }
}

class ForceUpdateResult {
  final bool required;
  final String storeUrl;

  const ForceUpdateResult._({required this.required, required this.storeUrl});

  const ForceUpdateResult.notRequired() : this._(required: false, storeUrl: "");

  const ForceUpdateResult.required({required String url})
    : this._(required: true, storeUrl: url);
}
