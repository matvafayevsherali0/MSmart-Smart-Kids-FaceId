import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:msmart_kids_faceid/features/hikvision/data/service/hikvision_service.dart';
import 'package:msmart_kids_faceid/features/hikvision/data/service/face_image_normalizer.dart';

void main() {
  test(
    'normalizes an oversized backend face image before Face ID upload',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      var uploadedBytes = 0;

      server.listen((request) async {
        if (request.headers.value('authorization') == null) {
          request.response.statusCode = HttpStatus.unauthorized;
          request.response.headers.set(
            'www-authenticate',
            'Digest realm="test", nonce="large-image", qop="auth"',
          );
          await request.response.close();
          return;
        }

        final body = await request.fold<List<int>>(
          <int>[],
          (bytes, chunk) => bytes..addAll(chunk),
        );
        if (request.uri.path.endsWith('/FDSearch')) {
          request.response.headers.contentType = ContentType.json;
          request.response.write(
            jsonEncode({
              'statusCode': 1,
              'statusString': 'OK',
              'subStatusCode': 'ok',
              'responseStatusStrg': 'NO MATCH',
              'numOfMatches': 0,
              'totalMatches': 0,
            }),
          );
        } else {
          uploadedBytes = body.length;
          request.response.headers.contentType = ContentType.json;
          request.response.write(
            jsonEncode({
              'statusCode': 1,
              'statusString': 'OK',
              'subStatusCode': 'ok',
              'FPID': 'student-1',
            }),
          );
        }
        await request.response.close();
      });

      try {
        final source = img.Image(width: 1920, height: 2560);
        for (var y = 0; y < source.height; y++) {
          for (var x = 0; x < source.width; x++) {
            final value = (x * 31 + y * 17 + (x * y % 251)) % 256;
            source.setPixelRgb(
              x,
              y,
              value,
              (value * 3) % 256,
              (value * 7) % 256,
            );
          }
        }
        final original = img.encodeJpg(source, quality: 95);
        expect(original.length, greaterThan(100000));
        expect(
          normalizeHikvisionFaceImage(original).length,
          lessThanOrEqualTo(maxHikvisionFaceImageBytes),
        );

        final service = HikvisionService(
          baseUrl: 'http://127.0.0.1:${server.port}',
          username: 'admin',
          password: 'password',
        );

        await service.upsertFaceByBytes(
          employeeNo: 'student-1',
          imageBytes: original,
          name: 'Student One',
        );

        expect(uploadedBytes, lessThan(original.length));
      } finally {
        await server.close(force: true);
      }
    },
  );
}
