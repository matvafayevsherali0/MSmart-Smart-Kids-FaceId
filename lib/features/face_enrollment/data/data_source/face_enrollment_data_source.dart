import 'package:dio/dio.dart';

import '../../../../assets/constants/network_constants.dart';
import '../../../../core/network/dio_setting.dart';
import '../../../../core/utils/service_locator.dart';

String _backendErrorMessage(Map<String, dynamic>? body) {
  if (body == null) return 'Javob tanasi bo‘sh';

  final directMessage = body['message']?.toString().trim() ?? '';
  if (directMessage.isNotEmpty && directMessage != 'null') {
    return directMessage;
  }

  final error = body['error'];
  if (error is Map) {
    final message = error['message']?.toString().trim() ?? '';
    if (message.isNotEmpty && message != 'null') return message;

    final issues = error['issues'];
    if (issues is List && issues.isNotEmpty) {
      final messages = issues
          .whereType<Map>()
          .map((issue) => issue['message']?.toString().trim() ?? '')
          .where((message) => message.isNotEmpty)
          .toList();
      if (messages.isNotEmpty) return messages.join('; ');
    }

    final code = error['code']?.toString().trim() ?? '';
    if (code.isNotEmpty && code != 'null') return code;
  }

  return body.toString();
}

bool _hasKnownImageSignature(List<int> bytes) {
  if (bytes.length >= 3 &&
      bytes[0] == 0xff &&
      bytes[1] == 0xd8 &&
      bytes[2] == 0xff) {
    return true;
  }
  if (bytes.length >= 8 &&
      bytes[0] == 0x89 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x4e &&
      bytes[3] == 0x47 &&
      bytes[4] == 0x0d &&
      bytes[5] == 0x0a &&
      bytes[6] == 0x1a &&
      bytes[7] == 0x0a) {
    return true;
  }
  if (bytes.length >= 6) {
    final header = String.fromCharCodes(bytes.take(6));
    if (header == 'GIF87a' || header == 'GIF89a') return true;
  }
  if (bytes.length >= 12 &&
      String.fromCharCodes(bytes.take(4)) == 'RIFF' &&
      String.fromCharCodes(bytes.sublist(8, 12)) == 'WEBP') {
    return true;
  }
  return bytes.length >= 2 && bytes[0] == 0x42 && bytes[1] == 0x4d;
}

abstract class FaceEnrollmentRemoteDataSource {
  Future<List<int>> downloadFaceImageBytes(String relativeOrAbsoluteUrl);

  Future<String> uploadFaceImage(List<int> bytes);

  Future<String> enrollFromDevice({
    required String? studentId,
    required String? staffId,
    required String faceImageId,
    required String organizationId,
    required String deviceId,
  });

  Future<String?> findFaceEnrollmentId({
    required String ownerType,
    required String ownerId,
    required String organizationId,
  });

  Future<void> updateFaceEnrollment({
    required String id,
    required String faceImageId,
  });

  Future<void> updateDeviceSync({
    required String faceEnrollmentId,
    required String deviceId,
    required bool isSynced,
    String? errorMessage,
  });

  Future<void> deleteFaceEnrollment(String id);
}

class FaceEnrollmentDataSourceImpl implements FaceEnrollmentRemoteDataSource {
  final Dio _dio;

  FaceEnrollmentDataSourceImpl({Dio? dio})
    : _dio = dio ?? serviceLocator<DioSettings>().dio;

  @override
  Future<List<int>> downloadFaceImageBytes(String relativeOrAbsoluteUrl) async {
    final imageUrl = resolveFaceEnrollmentImageUrl(relativeOrAbsoluteUrl);
    if (imageUrl.isEmpty) {
      throw Exception('Backend rasm URL’i bo‘sh');
    }

    final response = await _dio.get<List<int>>(
      imageUrl,
      options: Options(
        responseType: ResponseType.bytes,
        headers: const {Headers.acceptHeader: 'image/*'},
      ),
    );
    final status = response.statusCode;
    if (status == null || status < 200 || status >= 300) {
      throw Exception(
        'GET $imageUrl: $status ${response.statusMessage ?? 'Rasm yuklanmadi'}',
      );
    }

    final bytes = response.data;
    if (bytes == null || bytes.isEmpty) {
      throw Exception('Backenddan kelgan rasm bo‘sh');
    }

    final contentType =
        response.headers.value(Headers.contentTypeHeader)?.toLowerCase() ?? '';
    final isHtmlOrJson =
        contentType.contains('text/html') ||
        contentType.contains('application/json');
    if (isHtmlOrJson || !_hasKnownImageSignature(bytes)) {
      throw Exception(
        'Backend rasm o‘rniga noto‘g‘ri fayl qaytardi: '
        '${contentType.isEmpty ? 'noma’lum format' : contentType}',
      );
    }
    return List<int>.from(bytes);
  }

  @override
  Future<String> uploadFaceImage(List<int> bytes) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: 'face_enrollment.jpg'),
    });

    final response = await _dio.post<Map<String, dynamic>>(
      fileEndpoint,
      data: formData,
    );

    final status = response.statusCode;
    if (status == null || status < 200 || status >= 300) {
      throw Exception(
        'POST $fileEndpoint: $status ${_backendErrorMessage(response.data)}',
      );
    }

    final body = response.data;
    if (body == null) {
      throw Exception('Javob tanasi bo‘sh');
    }
    if (body['success'] != true) {
      throw Exception(_backendErrorMessage(body));
    }
    final data = body['data'];
    if (data is! Map) {
      throw Exception('Kutilmagan javob: $body');
    }
    final id = data['id']?.toString() ?? '';
    if (id.isEmpty) {
      throw Exception('file id topilmadi: $body');
    }
    return id;
  }

  @override
  Future<String> enrollFromDevice({
    required String? studentId,
    required String? staffId,
    required String faceImageId,
    required String organizationId,
    required String deviceId,
  }) async {
    final sid = studentId?.trim();
    final stid = staffId?.trim();
    final hasStudent = sid != null && sid.isNotEmpty;
    final hasStaff = stid != null && stid.isNotEmpty;
    if (!hasStudent && !hasStaff) {
      throw Exception('studentId yoki staffId kerak');
    }

    final ownerType = hasStudent && !hasStaff ? 'student' : 'staff';

    final data = <String, dynamic>{
      'ownerType': ownerType,
      'faceImageId': faceImageId,
      'organizationId': organizationId,
      'deviceSyncs': [
        {'deviceId': deviceId},
      ],
    };
    if (hasStudent) {
      data['studentId'] = sid;
    }
    if (hasStaff) {
      data['staffId'] = stid;
    }

    final response = await _dio.post<Map<String, dynamic>>(
      faceEnrollmentFromDeviceEndpoint,
      data: data,
      options: Options(
        contentType: Headers.jsonContentType,
        headers: const {Headers.acceptHeader: Headers.jsonContentType},
      ),
    );

    final status = response.statusCode;
    if (status == null || status < 200 || status >= 300) {
      throw Exception(
        'POST $faceEnrollmentFromDeviceEndpoint: $status '
        '${_backendErrorMessage(response.data)}',
      );
    }

    final body = response.data;
    if (body == null) {
      throw Exception('Javob tanasi bo‘sh');
    }
    if (body['success'] != true) {
      throw Exception(_backendErrorMessage(body));
    }

    final result = body['data'];
    final id = result is Map ? result['id']?.toString().trim() ?? '' : '';
    if (id.isEmpty) {
      throw Exception('faceEnrollment id topilmadi: $body');
    }
    return id;
  }

  @override
  Future<String?> findFaceEnrollmentId({
    required String ownerType,
    required String ownerId,
    required String organizationId,
  }) async {
    final type = ownerType.trim().toLowerCase();
    final owner = ownerId.trim();
    final organization = organizationId.trim();
    if (type.isEmpty || owner.isEmpty || organization.isEmpty) return null;

    final ownerField = type == 'student' ? 'studentId' : 'staffId';
    var page = 1;
    var totalPages = 1;
    const limit = 100;

    while (page <= totalPages) {
      final query = <String, dynamic>{
        'page': page,
        'limit': limit,
        'organizationId': organization,
      };
      // Some backend versions use `staff`, others use `teacher` for the
      // staff owner type. Scan both through the organization list instead of
      // hiding an existing enrollment from the mobile client.
      if (type == 'student') query['ownerType'] = type;

      final response = await _dio.get<Map<String, dynamic>>(
        faceEnrollmentEndpoint,
        queryParameters: query,
      );

      final status = response.statusCode;
      if (status == null || status < 200 || status >= 300) {
        throw Exception(
          'GET $faceEnrollmentEndpoint: $status '
          '${_backendErrorMessage(response.data)}',
        );
      }

      final body = response.data;
      if (body == null || body['success'] != true) {
        throw Exception(_backendErrorMessage(body));
      }

      final data = body['data'];
      if (data is! Map) {
        throw Exception('Kutilmagan face enrollment ro‘yxati: $body');
      }

      final items = data['items'];
      if (items is List) {
        for (final raw in items) {
          if (raw is! Map) continue;
          final value = raw[ownerField]?.toString().trim() ?? '';
          final id = raw['id']?.toString().trim() ?? '';
          final isDeleted = raw['isDeleted'] == true;
          final isActive = raw['isActive'] != false;
          if (value == owner && id.isNotEmpty && !isDeleted && isActive) {
            return id;
          }
        }
      }

      final meta = data['meta'];
      final parsedTotalPages = meta is Map
          ? int.tryParse(meta['totalPages']?.toString() ?? '')
          : null;
      totalPages = parsedTotalPages == null || parsedTotalPages < 1
          ? page
          : parsedTotalPages;
      page++;
    }

    return null;
  }

  @override
  Future<void> updateFaceEnrollment({
    required String id,
    required String faceImageId,
  }) async {
    final enrollmentId = id.trim();
    final imageId = faceImageId.trim();
    if (enrollmentId.isEmpty || imageId.isEmpty) {
      throw Exception('faceEnrollment id va faceImageId kerak');
    }

    final response = await _dio.put<Map<String, dynamic>>(
      '$faceEnrollmentEndpoint/$enrollmentId',
      data: {'faceImageId': imageId},
      options: Options(
        contentType: Headers.jsonContentType,
        headers: const {Headers.acceptHeader: Headers.jsonContentType},
      ),
    );

    final status = response.statusCode;
    if (status == null || status < 200 || status >= 300) {
      throw Exception(
        'PUT $faceEnrollmentEndpoint/$enrollmentId: $status '
        '${_backendErrorMessage(response.data)}',
      );
    }

    final body = response.data;
    if (body == null || body['success'] != true) {
      throw Exception(_backendErrorMessage(body));
    }
  }

  @override
  Future<void> updateDeviceSync({
    required String faceEnrollmentId,
    required String deviceId,
    required bool isSynced,
    String? errorMessage,
  }) async {
    final enrollmentId = faceEnrollmentId.trim();
    final terminalId = deviceId.trim();
    if (enrollmentId.isEmpty || terminalId.isEmpty) {
      throw Exception('faceEnrollmentId va deviceId kerak');
    }

    final data = <String, dynamic>{
      'deviceId': terminalId,
      'isSynced': isSynced,
    };
    final message = errorMessage?.trim() ?? '';
    if (message.isNotEmpty) data['errorMessage'] = message;

    final response = await _dio.put<Map<String, dynamic>>(
      '$faceEnrollmentEndpoint/$enrollmentId/device-sync',
      data: data,
      options: Options(
        contentType: Headers.jsonContentType,
        headers: const {Headers.acceptHeader: Headers.jsonContentType},
      ),
    );

    final status = response.statusCode;
    if (status == null || status < 200 || status >= 300) {
      throw Exception(
        'PUT $faceEnrollmentEndpoint/$enrollmentId/device-sync: '
        '$status ${_backendErrorMessage(response.data)}',
      );
    }

    final body = response.data;
    if (body == null || body['success'] != true) {
      throw Exception(_backendErrorMessage(body));
    }
  }

  @override
  Future<void> deleteFaceEnrollment(String id) async {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) {
      throw Exception('faceEnrollment id bo‘sh');
    }

    final response = await _dio.delete<Map<String, dynamic>>(
      '$faceEnrollmentEndpoint/$trimmedId',
      options: Options(
        contentType: Headers.jsonContentType,
        headers: const {Headers.acceptHeader: Headers.jsonContentType},
      ),
    );

    final status = response.statusCode;
    if (status == null || status < 200 || status >= 300) {
      throw Exception(
        'DELETE $faceEnrollmentEndpoint: $status '
        '${_backendErrorMessage(response.data)}',
      );
    }

    final body = response.data;
    if (body == null) return;
    if (body['success'] != true) {
      throw Exception(_backendErrorMessage(body));
    }
  }
}
