import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:msmart_kids_faceid/assets/constants/network_constants.dart';
import 'package:msmart_kids_faceid/features/face_enrollment/data/data_source/face_enrollment_data_source.dart';
import 'package:msmart_kids_faceid/features/users/domain/entity/staff_response.dart';
import 'package:msmart_kids_faceid/features/users/domain/mapper/users_mapper.dart';

void main() {
  test('maps faceEnrollment.file.url from students response', () {
    final response = StaffResponse.fromJson({
      'success': true,
      'data': {
        'items': [
          {
            'id': 'student-1',
            'fullname': 'Test student',
            'organizationId': 'org-1',
            'isActive': true,
            'faceEnrollment': {
              'id': 'enrollment-1',
              'faceImageId': 'image-1',
              'file': {'url': '/uploads/test-face.jpg'},
            },
          },
        ],
        'meta': {'page': 1, 'limit': 10, 'total': 1, 'totalPages': 1},
      },
    });

    final mapped = UsersMapper().mapStaffResponseToStaff(response);

    expect(mapped.items.single.faceImageUrl, '/uploads/test-face.jpg');
  });

  test('resolves a relative face image URL on the backend API host', () {
    expect(
      resolveFaceEnrollmentImageUrl('/uploads/test-face.jpg'),
      'https://api.msmartkids.uz/uploads/test-face.jpg',
    );
  });

  test(
    'downloads backend face image bytes for multipart device upload',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server.listen((request) async {
        request.response
          ..headers.contentType = ContentType('image', 'jpeg')
          ..add([0xff, 0xd8, 0xff, 0xd9]);
        await request.response.close();
      });

      try {
        final source = FaceEnrollmentDataSourceImpl(
          dio: Dio(BaseOptions(baseUrl: 'http://127.0.0.1:${server.port}')),
        );
        final bytes = await source.downloadFaceImageBytes(
          'http://127.0.0.1:${server.port}/uploads/face.jpg',
        );

        expect(bytes, [0xff, 0xd8, 0xff, 0xd9]);
      } finally {
        await server.close(force: true);
      }
    },
  );

  test('rejects an HTML page returned instead of a face image', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      request.response
        ..headers.contentType = ContentType('text', 'html')
        ..add('<html>not an image</html>'.codeUnits);
      await request.response.close();
    });

    try {
      final source = FaceEnrollmentDataSourceImpl(
        dio: Dio(BaseOptions(baseUrl: 'http://127.0.0.1:${server.port}')),
      );

      await expectLater(
        source.downloadFaceImageBytes(
          'http://127.0.0.1:${server.port}/uploads/face.jpg',
        ),
        throwsA(isA<Exception>()),
      );
    } finally {
      await server.close(force: true);
    }
  });
}
