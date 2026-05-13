import 'package:dio/dio.dart';

import '../../../../assets/constants/network_constants.dart';
import '../../../../core/network/dio_setting.dart';
import '../../../../core/utils/service_locator.dart';

abstract class FaceEnrollmentRemoteDataSource {
  Future<String> uploadFaceImage(List<int> bytes);

  Future<void> enrollFromDevice({
    required String? studentId,
    required String? staffId,
    required String faceImageId,
    required String organizationId,
    required String deviceId,
  });

  Future<void> deleteFaceEnrollment(String id);
}

class FaceEnrollmentDataSourceImpl implements FaceEnrollmentRemoteDataSource {
  final _dio = serviceLocator<DioSettings>().dio;

  @override
  Future<String> uploadFaceImage(List<int> bytes) async {
    final formData = FormData.fromMap({'file': MultipartFile.fromBytes(bytes, filename: 'face_enrollment.jpg')});

    final response = await _dio.post<Map<String, dynamic>>(fileEndpoint, data: formData);

    final status = response.statusCode;
    if (status == null || status < 200 || status >= 300) {
      throw Exception('POST $fileEndpoint: $status ${response.statusMessage}');
    }

    final body = response.data;
    if (body == null) {
      throw Exception('Javob tanasi bo‘sh');
    }
    if (body['success'] != true) {
      throw Exception(body['message']?.toString() ?? body.toString());
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
  Future<void> enrollFromDevice({
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
      options: Options(contentType: Headers.jsonContentType, headers: const {Headers.acceptHeader: Headers.jsonContentType}),
    );

    final status = response.statusCode;
    if (status == null || status < 200 || status >= 300) {
      throw Exception('POST $faceEnrollmentFromDeviceEndpoint: $status ${response.statusMessage}');
    }

    final body = response.data;
    if (body == null) {
      throw Exception('Javob tanasi bo‘sh');
    }
    if (body['success'] != true) {
      throw Exception(body['message']?.toString() ?? body.toString());
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
      throw Exception('DELETE $faceEnrollmentEndpoint: $status ${response.statusMessage}');
    }

    final body = response.data;
    if (body == null) return;
    if (body['success'] != true) {
      throw Exception(body['message']?.toString() ?? body.toString());
    }
  }
}
