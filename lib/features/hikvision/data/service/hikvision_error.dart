import 'dart:convert';

import 'package:http/http.dart' as http;

class HikvisionErrorDetails {
  final int? statusCode;
  final int? errorCode;
  final String? subStatusCode;
  final String? deviceMessage;
  final String? reason;

  const HikvisionErrorDetails({
    this.statusCode,
    this.errorCode,
    this.subStatusCode,
    this.deviceMessage,
    this.reason,
  });
}

class HikvisionErrorTranslator {
  static String userMessage({
    int? statusCode,
    int? errorCode,
    String? subStatusCode,
    String? deviceMessage,
    String? reason,
  }) {
    final text = [
      subStatusCode,
      deviceMessage,
      reason,
      errorCode?.toString(),
    ].whereType<String>().join(' ').toLowerCase();

    if (statusCode == 401 ||
        statusCode == 403 ||
        _containsAny(text, [
          'unauthorized',
          'authentication',
          'authorization',
          'invalid user',
          'invalid password',
          'credential',
          'login',
          '认证',
          '密码',
        ])) {
      return 'Face ID qurilmasiga kirish rad etildi. Login va parolni tekshiring.';
    }

    if (_containsAny(text, [
      'duplicate',
      'already exists',
      'already exist',
      'record exists',
      'face exist',
      'fpid exist',
      '重复',
      '已存在',
    ])) {
      return 'Bu tarbiyalanuvchi uchun Face ID qurilmasida rasm allaqachon mavjud. '
          'Yangi rasm bilan almashtirib ko‘ring.';
    }

    if (_containsAny(text, [
      'noface',
      'no face',
      'face not detected',
      'multiplefaces',
      'multiple faces',
      'face size',
      'shadeface',
      'image resolution',
      'picture resolution',
      '图片',
      '人脸',
    ])) {
      return 'Yuz rasmi tanib olinmadi. Yuzni kameraga to‘g‘ri qarating va qayta urinib ko‘ring.';
    }

    if (_containsAny(text, [
      'not found',
      'not exist',
      'no such',
      'no record',
      'no match',
      'nomatch',
      '不存在',
      '未找到',
    ])) {
      return 'Face ID qurilmasida kerakli ma’lumot topilmadi. Qayta urinib ko‘ring.';
    }

    if (statusCode != null && statusCode >= 500) {
      return 'Face ID qurilmasi vaqtincha javob bermadi. Birozdan so‘ng qayta urinib ko‘ring.';
    }

    return 'Face ID qurilmasida amal bajarilmadi. Qayta urinib ko‘ring.';
  }

  static bool isMissingFaceRecord({
    int? statusCode,
    String? deviceMessage,
    String? reason,
    String? subStatusCode,
  }) {
    if (statusCode == 404) return true;
    final text = [
      deviceMessage,
      reason,
      subStatusCode,
    ].whereType<String>().join(' ').toLowerCase();
    return _containsAny(text, [
      'not found',
      'not exist',
      'no such',
      'no record',
      'no match',
      'nomatch',
      '不存在',
      '未找到',
    ]);
  }

  static HikvisionErrorDetails parseBody(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return const HikvisionErrorDetails();

    if (trimmed.startsWith('{')) {
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is Map) {
          return HikvisionErrorDetails(
            statusCode: _intValue(decoded['statusCode']),
            errorCode: _intValue(decoded['errorCode']),
            subStatusCode: _stringValue(decoded['subStatusCode']),
            deviceMessage: _firstString(decoded, const [
              'errorMsg',
              'errorMessage',
              'message',
              'statusString',
            ]),
            reason: _firstString(decoded, const [
              'reason',
              'responseStatusStrg',
            ]),
          );
        }
      } catch (_) {
        // Fall through to the text-based fallback below.
      }
    }

    String? tag(String name) {
      final match = RegExp('<$name[^>]*>([^<]*)</$name>').firstMatch(trimmed);
      return match?.group(1)?.trim();
    }

    return HikvisionErrorDetails(
      statusCode: _intValue(tag('statusCode')),
      errorCode: _intValue(tag('errorCode')),
      subStatusCode: tag('subStatusCode'),
      deviceMessage: tag('errorMsg') ?? tag('statusString'),
      reason: tag('reason') ?? tag('responseStatusStrg'),
    );
  }

  static String? _firstString(Map<dynamic, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = _stringValue(map[key]);
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  static String? _stringValue(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  static int? _intValue(Object? value) => int.tryParse(value?.toString() ?? '');

  static bool _containsAny(String text, List<String> values) {
    return values.any(text.contains);
  }
}

class HikvisionDeviceException implements Exception {
  final String message;
  final int? statusCode;
  final int? errorCode;
  final bool isMissingFaceRecord;

  const HikvisionDeviceException({
    required this.message,
    this.statusCode,
    this.errorCode,
    this.isMissingFaceRecord = false,
  });

  factory HikvisionDeviceException.fromResponse(
    http.Response response, {
    required String operation,
  }) {
    final details = HikvisionErrorTranslator.parseBody(response.body);
    final deviceMessage = details.deviceMessage ?? response.reasonPhrase;
    return HikvisionDeviceException(
      message: HikvisionErrorTranslator.userMessage(
        statusCode: response.statusCode,
        errorCode: details.errorCode,
        subStatusCode: details.subStatusCode,
        deviceMessage: deviceMessage,
        reason: details.reason,
      ),
      statusCode: response.statusCode,
      errorCode: details.errorCode,
      isMissingFaceRecord: HikvisionErrorTranslator.isMissingFaceRecord(
        statusCode: response.statusCode,
        deviceMessage: deviceMessage,
        reason: details.reason,
        subStatusCode: details.subStatusCode,
      ),
    );
  }

  factory HikvisionDeviceException.fromPayload(
    Map<String, dynamic> payload, {
    required String operation,
  }) {
    final details = HikvisionErrorTranslator.parseBody(jsonEncode(payload));
    final statusCode = details.statusCode;
    final errorCode = details.errorCode;
    final isFailure =
        (statusCode != null && !_isSuccessCode(statusCode)) ||
        (errorCode != null && !_isSuccessCode(errorCode)) ||
        payload['responseStatus'] == false;
    if (!isFailure) {
      throw StateError('Payload xato holat emas');
    }

    return HikvisionDeviceException(
      message: HikvisionErrorTranslator.userMessage(
        statusCode: statusCode,
        errorCode: errorCode,
        subStatusCode: details.subStatusCode,
        deviceMessage: details.deviceMessage,
        reason: details.reason,
      ),
      statusCode: statusCode,
      errorCode: errorCode,
      isMissingFaceRecord: HikvisionErrorTranslator.isMissingFaceRecord(
        statusCode: statusCode,
        deviceMessage: details.deviceMessage,
        reason: details.reason,
        subStatusCode: details.subStatusCode,
      ),
    );
  }

  static bool _isSuccessCode(int code) => code == 1 || code == 200;

  @override
  String toString() => message;
}
