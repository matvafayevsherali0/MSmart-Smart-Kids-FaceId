import 'package:flutter_test/flutter_test.dart';
import 'package:msmart_kids_faceid/features/hikvision/data/service/hikvision_error.dart';
import 'package:msmart_kids_faceid/features/hikvision/data/service/hikvision_service.dart';

void main() {
  group('Hikvision face search response', () {
    test('reads the official picURL field from MatchList', () {
      final url = HikvisionService.extractFaceUrlFromSearchResponse({
        'MatchList': [
          {'FPID': 'student-1', 'picURL': 'http://device/face.jpg'},
        ],
      });

      expect(url, 'http://device/face.jpg');
    });

    test('supports FaceInfoSearch responses and legacy faceURL field', () {
      final url = HikvisionService.extractFaceUrlFromSearchResponse({
        'FaceInfoSearch': {
          'MatchList': [
            {'faceURL': 'http://device/legacy-face.jpg'},
          ],
        },
      });

      expect(url, 'http://device/legacy-face.jpg');
    });
  });

  group('Hikvision error translation', () {
    test('explains duplicate face errors in simple Uzbek', () {
      final message = HikvisionErrorTranslator.userMessage(
        statusCode: 400,
        deviceMessage: 'Face record already exists for this FPID',
      );

      expect(
        message,
        'Bu tarbiyalanuvchi uchun Face ID qurilmasida rasm allaqachon mavjud. '
        'Yangi rasm bilan almashtirib ko‘ring.',
      );
    });

    test('recognizes a missing face record for upsert fallback', () {
      expect(
        HikvisionErrorTranslator.isMissingFaceRecord(
          statusCode: 404,
          deviceMessage: 'Face record not found',
        ),
        isTrue,
      );
    });

    test(
      'recognizes device-level errors returned inside a successful HTTP response',
      () {
        final error = HikvisionDeviceException.fromPayload({
          'statusCode': 0,
          'errorMsg': 'Face record not found',
        }, operation: 'yuz rasmini yangilash');

        expect(error.isMissingFaceRecord, isTrue);
      },
    );
  });
}
