import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
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
    test('parses a locked userCheck response as an authentication error', () {
      const xml = '''
<userCheck version="2.0" xmlns="http://www.isapi.org/ver20/XMLSchema">
  <statusValue>401</statusValue>
  <statusString>Unauthorized</statusString>
  <isActivated>true</isActivated>
  <lockStatus>lock</lockStatus>
  <unlockTime>1783</unlockTime>
  <retryLoginTime>0</retryLoginTime>
</userCheck>
''';

      final details = HikvisionErrorTranslator.parseBody(xml);

      expect(details.statusCode, 401);
      expect(details.deviceMessage, 'Unauthorized');
      expect(details.lockStatus, 'lock');
      expect(details.unlockTime, 1783);
      expect(details.retryLoginTime, 0);
      expect(
        HikvisionErrorTranslator.userMessage(
          statusCode: details.statusCode,
          deviceMessage: details.deviceMessage,
          lockStatus: details.lockStatus,
          unlockTime: details.unlockTime,
        ),
        'Face ID qurilmasi vaqtincha bloklangan. Qurilma ochilguncha qayta urinmang.',
      );
    });

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

    test('recognizes MErrCode returned inside a successful ISAPI response', () {
      final error = HikvisionDeviceException.fromPayload({
        'statusCode': 1,
        'errorCode': 1,
        'MErrCode': '0x400010A0',
      }, operation: 'yuz rasmini yangilash');

      expect(error.errorCode, 0x400010A0);
      expect(
        error.message,
        'Face ID rasmni qayta ishlay olmadi. Yuz aniq ko‘ringan boshqa rasmni yuboring.',
      );
    });

    test('translates official face search reasons into simple Uzbek', () {
      expect(
        HikvisionErrorTranslator.userMessage(reason: 'multipleFaces'),
        'Rasmda bir nechta yuz bor. Faqat bitta yuz tushgan rasmni yuboring.',
      );
      expect(
        HikvisionErrorTranslator.userMessage(reason: 'faceSizeSmall'),
        'Yuz rasmi juda kichik yoki uzoq tushgan. Yuzni yaqinroq va aniqroq qilib qayta oling.',
      );
      expect(
        HikvisionErrorTranslator.userMessage(reason: 'imageURLDownloadFailed'),
        'Face ID rasmni yuklay olmadi. Telefon va qurilma tarmog‘ini tekshirib, qayta urinib ko‘ring.',
      );
    });

    test('translates a capture timeout into a simple user message', () {
      const xml = '''
<ResponseStatus>
  <statusCode>3</statusCode>
  <statusString>Device Error</statusString>
  <subStatusCode>captureTimeout</subStatusCode>
  <errorMsg>cancelFlag</errorMsg>
</ResponseStatus>
''';
      final details = HikvisionErrorTranslator.parseBody(xml);

      expect(
        HikvisionErrorTranslator.userMessage(
          statusCode: details.statusCode,
          subStatusCode: details.subStatusCode,
          deviceMessage: details.deviceMessage,
        ),
        'Face ID rasmni vaqtida ola olmadi. Qurilma kamerasi qarshisida turing va qayta urinib ko‘ring.',
      );
    });

    test('translates official face error codes', () {
      expect(
        HikvisionErrorTranslator.userMessage(errorCode: 0x400010A0),
        'Face ID rasmni qayta ishlay olmadi. Yuz aniq ko‘ringan boshqa rasmni yuboring.',
      );
      expect(
        HikvisionErrorTranslator.userMessage(errorCode: 0x6000100A),
        'Face ID qurilmasining xotirasi to‘lib qolgan. Qurilmada bo‘sh joy yarating.',
      );
      expect(
        HikvisionErrorTranslator.userMessage(
          errorCode: HikvisionErrorTranslator.parseBody(
            '{"errorCode":"0x4000109D"}',
          ).errorCode,
        ),
        'Face ID qurilmasida kerakli yuz rasmi topilmadi.',
      );
    });

    test('recognizes a missing face record by its official error code', () {
      expect(
        HikvisionErrorTranslator.isMissingFaceRecord(errorCode: 0x4000109D),
        isTrue,
      );
    });

    test('translates documented oversized and undersized picture errors', () {
      expect(
        HikvisionErrorTranslator.userMessage(errorCode: 0x40001105),
        'Rasm o‘lchami Face ID uchun juda katta. Rasm avtomatik moslashtiriladi yoki boshqa rasm tanlang.',
      );
      expect(
        HikvisionErrorTranslator.userMessage(errorCode: 0x40001106),
        'Rasm o‘lchami Face ID uchun juda kichik. Yuz aniq ko‘ringan kattaroq rasm tanlang.',
      );
    });

    test('translates face modeling errors returned without a numeric code', () {
      expect(
        HikvisionErrorTranslator.userMessage(
          statusCode: 400,
          subStatusCode: 'SubpicAnalysisModelingError',
          deviceMessage: 'saveFacePic',
        ),
        'Face ID rasmni qayta ishlay olmadi. Rasm o‘lchami yoki sifati mos emas.',
      );
    });
  });

  group('Hikvision ISAPI request helpers', () {
    test('logs the complete Face ID capture request and response', () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final logs = <String>[];

      server.listen((request) async {
        if (request.headers.value('authorization') == null) {
          request.response.statusCode = HttpStatus.unauthorized;
          request.response.headers.set(
            'www-authenticate',
            'Digest realm="test", nonce="capture-nonce", qop="auth"',
          );
          await request.response.close();
          return;
        }

        await utf8.decoder.bind(request).join();
        request.response.statusCode = HttpStatus.ok;
        request.response.write('''
<CaptureFaceData>
  <faceDataUrl>http://device/captured-face.jpg</faceDataUrl>
  <captureProgress>100</captureProgress>
</CaptureFaceData>
''');
        await request.response.close();
      });

      try {
        final service = HikvisionService(
          baseUrl: 'http://127.0.0.1:${server.port}',
          username: 'admin',
          password: 'password',
          debugLogger: logs.add,
        );

        await service.captureFaceUrl();

        final output = logs.join('\n');
        expect(output, contains('CaptureFaceData'));
        expect(output, contains('<dataType>url</dataType>'));
        expect(output, contains('captured-face.jpg'));
        expect(output, contains('username=admin'));
        expect(output, isNot(contains('password=password')));
        expect(output, isNot(contains('Authorization: Digest')));
      } finally {
        await server.close(force: true);
      }
    });

    test('builds the documented face capture request body', () {
      expect(HikvisionService.captureFaceRequestBody, '''
<CaptureFaceDataCond version="2.0" xmlns="http://www.isapi.org/ver20/XMLSchema">
  <dataType>url</dataType>
</CaptureFaceDataCond>
''');
    });

    test('extracts FaceData JPEG bytes from a binary capture response', () async {
      const boundary = 'face-boundary';
      const image = [0xFF, 0xD8, 0xFF, 0xD9];
      final body = <int>[
        ...utf8.encode(
          '--$boundary\r\n'
          'Content-Disposition: form-data; name="CaptureFace"\r\n'
          'Content-Type: application/xml\r\n\r\n'
          '<CaptureFaceData/>\r\n'
          '--$boundary\r\n'
          'Content-Disposition: form-data; name="FaceData"; filename="FaceData.jpg"\r\n'
          'Content-Type: image/jpeg\r\n\r\n',
        ),
        ...image,
        ...utf8.encode('\r\n--$boundary--\r\n'),
      ];
      final response = http.Response.bytes(
        body,
        200,
        headers: {'content-type': 'multipart/form-data; boundary=$boundary'},
      );

      expect(await HikvisionService.extractCapturedFaceBytes(response), image);
    });

    test('adds a new face record after FDSearch returns no match', () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final paths = <String>[];
      final methods = <String>[];

      server.listen((request) async {
        if (request.headers.value('authorization') == null) {
          request.response.statusCode = HttpStatus.unauthorized;
          request.response.headers.set(
            'www-authenticate',
            'Digest realm="test", nonce="face-upsert", qop="auth"',
          );
          await request.response.close();
          return;
        }

        paths.add(request.uri.path);
        methods.add(request.method);
        if (request.uri.path.endsWith('/FDSearch')) {
          request.response.headers.contentType = ContentType.json;
          request.response.write('''
{
  "statusCode": 1,
  "statusString": "OK",
  "subStatusCode": "ok",
  "responseStatusStrg": "NO MATCH",
  "numOfMatches": 0,
  "totalMatches": 0
}
''');
        } else {
          request.response.headers.contentType = ContentType.json;
          request.response.write('{}');
        }
        await request.response.close();
      });

      try {
        final service = HikvisionService(
          baseUrl: 'http://127.0.0.1:${server.port}',
          username: 'admin',
          password: 'password',
        );

        await service.upsertFaceByBytes(
          employeeNo: 'student-1',
          imageBytes: img.encodeJpg(img.Image(width: 1, height: 1)),
          name: 'Student One',
        );

        expect(paths, contains(contains('/FDSearch')));
        expect(paths, contains(contains('/FaceDataRecord')));
        expect(methods.last, 'POST');
        expect(paths, isNot(contains(contains('/FDModify'))));
      } finally {
        await server.close(force: true);
      }
    });

    test(
      'uses Hikvision multipart field names for a binary face upload',
      () async {
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
        String? uploadBody;

        server.listen((request) async {
          if (request.headers.value('authorization') == null) {
            request.response.statusCode = HttpStatus.unauthorized;
            request.response.headers.set(
              'www-authenticate',
              'Digest realm="test", nonce="multipart-fields", qop="auth"',
            );
            await request.response.close();
            return;
          }

          final bytes = await request.fold<List<int>>(
            <int>[],
            (collected, chunk) => collected..addAll(chunk),
          );
          if (request.uri.path.endsWith('/FDSearch')) {
            request.response.headers.contentType = ContentType.json;
            request.response.write(
              '{"statusCode":1,"responseStatusStrg":"NO MATCH",'
              '"totalMatches":0}',
            );
          } else {
            uploadBody = latin1.decode(bytes, allowInvalid: true);
            request.response.headers.contentType = ContentType.json;
            request.response.write('{"statusCode":1}');
          }
          await request.response.close();
        });

        try {
          final service = HikvisionService(
            baseUrl: 'http://127.0.0.1:${server.port}',
            username: 'admin',
            password: 'password',
          );

          await service.upsertFaceByBytes(
            employeeNo: 'student-3',
            imageBytes: img.encodeJpg(img.Image(width: 1, height: 1)),
            name: 'Student Three',
          );

          expect(uploadBody, contains('name="FaceDataRecord"'));
          expect(uploadBody, contains('name="FaceImage"'));
          expect(uploadBody, isNot(contains('name="faceURL"')));
          expect(uploadBody, isNot(contains('name="img"')));
        } finally {
          await server.close(force: true);
        }
      },
    );

    test(
      'uses FaceDataRecord for a URL when FDSearch returns no match',
      () async {
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
        final methodsByPath = <String, String>{};

        server.listen((request) async {
          if (request.headers.value('authorization') == null) {
            request.response.statusCode = HttpStatus.unauthorized;
            request.response.headers.set(
              'www-authenticate',
              'Digest realm="test", nonce="url-upsert", qop="auth"',
            );
            await request.response.close();
            return;
          }

          methodsByPath[request.uri.path] = request.method;
          request.response.headers.contentType = ContentType.json;
          if (request.uri.path.endsWith('/FDSearch')) {
            request.response.write('''
{
  "statusCode": 1,
  "statusString": "OK",
  "subStatusCode": "ok",
  "responseStatusStrg": "NO MATCH",
  "numOfMatches": 0,
  "totalMatches": 0
}
''');
          } else {
            request.response.write('{}');
          }
          await request.response.close();
        });

        try {
          final service = HikvisionService(
            baseUrl: 'http://127.0.0.1:${server.port}',
            username: 'admin',
            password: 'password',
          );

          await service.upsertFaceByUrl(
            employeeNo: 'student-2',
            faceUrl: 'https://example.com/student-2.jpg',
            name: 'Student Two',
          );

          expect(methodsByPath['/ISAPI/Intelligent/FDLib/FDSearch'], 'POST');
          expect(
            methodsByPath['/ISAPI/Intelligent/FDLib/FaceDataRecord'],
            'POST',
          );
          expect(
            methodsByPath,
            isNot(contains('/ISAPI/Intelligent/FDLib/FDModify')),
          );
        } finally {
          await server.close(force: true);
        }
      },
    );

    test('uses totalMatches for paginated user searches', () {
      expect(
        HikvisionService.userInfoSearchTotalMatches({
          'numOfMatches': 30,
          'totalMatches': 95,
        }),
        95,
      );
    });

    test('builds the documented user delete request', () {
      expect(HikvisionService.userInfoDeleteBody(['student-1']), {
        'UserInfoDetail': {
          'mode': 'byEmployeeNo',
          'EmployeeNoList': [
            {'employeeNo': 'student-1'},
          ],
        },
      });
    });

    test('includes the query string in the digest URI', () {
      expect(
        HikvisionService.digestUriForRequest(
          Uri.parse('http://device/ISAPI/User?format=json'),
        ),
        '/ISAPI/User?format=json',
      );
    });

    test(
      'increments the digest nonce count when the device reuses a nonce',
      () async {
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
        final nonceCounts = <String>[];
        final clientNonces = <String>[];

        server.listen((request) async {
          final authorization = request.headers.value('authorization');
          if (authorization == null) {
            request.response.statusCode = HttpStatus.unauthorized;
            request.response.headers.set(
              'www-authenticate',
              'Digest realm="test", nonce="fixed-nonce", qop="auth"',
            );
            await request.response.close();
            return;
          }

          final nonceCount = RegExp(
            r'\bnc=([0-9a-fA-F]+)',
          ).firstMatch(authorization)?.group(1);
          nonceCounts.add(nonceCount ?? '');
          clientNonces.add(
            RegExp(r'cnonce="([^"]+)"').firstMatch(authorization)?.group(1) ??
                '',
          );
          if (nonceCount != '00000001' && nonceCount != '00000002') {
            request.response.statusCode = HttpStatus.unauthorized;
            await request.response.close();
            return;
          }

          if (nonceCounts.length == 2 && nonceCount != '00000002') {
            request.response.statusCode = HttpStatus.unauthorized;
            request.response.write(
              '<userCheck><statusValue>401</statusValue><lockStatus>lock</lockStatus></userCheck>',
            );
          } else {
            request.response.statusCode = HttpStatus.ok;
            request.response.headers.contentType = ContentType.json;
            request.response.write('{}');
          }
          await request.response.close();
        });

        try {
          final service = HikvisionService(
            baseUrl: 'http://127.0.0.1:${server.port}',
            username: 'admin',
            password: 'password',
          );
          final uri = Uri.parse('${service.baseUrl}/test');

          await service.getJsonWithDigest(uri);
          service.updateConnection(
            baseUrl: service.baseUrl,
            username: 'admin',
            password: 'password',
          );
          await service.getJsonWithDigest(uri);

          expect(nonceCounts, ['00000001', '00000002']);
          expect(clientNonces, hasLength(2));
          expect(clientNonces[0], isNot(clientNonces[1]));
        } finally {
          await server.close(force: true);
        }
      },
    );

    test(
      'keeps a locked userCheck body when the 401 has no digest challenge',
      () async {
        const body = '''
<userCheck version="2.0" xmlns="http://www.isapi.org/ver20/XMLSchema">
  <statusValue>401</statusValue>
  <statusString>Unauthorized</statusString>
  <lockStatus>lock</lockStatus>
</userCheck>
''';
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
        server.listen((request) async {
          request.response.statusCode = HttpStatus.unauthorized;
          request.response.write(body);
          await request.response.close();
        });

        try {
          final service = HikvisionService(
            baseUrl: 'http://127.0.0.1:${server.port}',
            username: 'admin',
            password: 'password',
          );

          await expectLater(
            () =>
                service.getJsonWithDigest(Uri.parse('${service.baseUrl}/test')),
            throwsA(
              isA<HikvisionDeviceException>().having(
                (error) => error.message,
                'message',
                'Face ID qurilmasi vaqtincha bloklangan. Qurilma ochilguncha qayta urinmang.',
              ),
            ),
          );
        } finally {
          await server.close(force: true);
        }
      },
    );

    test(
      'retries a captured local face image with a fresh digest count',
      () async {
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
        final nonceCounts = <String>[];
        final nonces = <String>[];
        var challengeCount = 0;

        server.listen((request) async {
          final authorization = request.headers.value('authorization');
          if (authorization == null) {
            challengeCount++;
            request.response.statusCode = HttpStatus.unauthorized;
            request.response.headers.set(
              'www-authenticate',
              'Digest realm="test", nonce="${challengeCount == 1 ? 'fixed-nonce' : 'fresh-$challengeCount'}", qop="auth"',
            );
            await request.response.close();
            return;
          }

          final nonceCount = RegExp(
            r'\bnc=([0-9a-fA-F]+)',
          ).firstMatch(authorization)?.group(1);
          nonceCounts.add(nonceCount ?? '');
          nonces.add(
            RegExp(r'nonce="([^"]+)"').firstMatch(authorization)?.group(1) ??
                '',
          );

          final isLocalPicture = request.uri.path.startsWith('/LOCALS/pic/');
          final isFaceLibrary = request.uri.path.startsWith(
            '/ISAPI/Intelligent/FDLib/',
          );
          final isCapture = request.uri.path.startsWith(
            '/ISAPI/AccessControl/CaptureFaceData',
          );
          if (isLocalPicture || isFaceLibrary || isCapture) {
            if (nonceCount == '00000001') {
              request.response.statusCode = HttpStatus.ok;
              if (isLocalPicture) {
                request.response.headers.contentType = ContentType(
                  'image',
                  'jpeg',
                );
                request.response.add(const [0xFF, 0xD8, 0xFF, 0xD9]);
              } else {
                request.response.headers.contentType = ContentType.json;
                request.response.write('{}');
              }
            } else {
              // Some older terminals reject the global nonce count for the
              // temporary image URL and return 401 without a new challenge.
              request.response.statusCode = HttpStatus.unauthorized;
              request.response.write(
                '<userCheck><statusValue>401</statusValue></userCheck>',
              );
            }
          } else {
            request.response.statusCode = HttpStatus.ok;
            request.response.headers.contentType = ContentType.json;
            request.response.write('{}');
          }
          await request.response.close();
        });

        try {
          final service = HikvisionService(
            baseUrl: 'http://127.0.0.1:${server.port}',
            username: 'admin',
            password: 'password',
          );
          final apiUri = Uri.parse('${service.baseUrl}/test');
          await service.getJsonWithDigest(apiUri);
          await service.getJsonWithDigest(apiUri);
          await service.getJsonWithDigest(
            Uri.parse('${service.baseUrl}/ISAPI/AccessControl/CaptureFaceData'),
          );

          final bytes = await service.downloadBytesWithDigest(
            Uri.parse('${service.baseUrl}/LOCALS/pic/captured.jpg@WEB0001'),
          );
          await service.getJsonWithDigest(
            Uri.parse(
              '${service.baseUrl}/ISAPI/Intelligent/FDLib/FDModify?format=json',
            ),
          );

          expect(bytes, [0xFF, 0xD8, 0xFF, 0xD9]);
          expect(nonceCounts, [
            '00000001',
            '00000002',
            '00000003',
            '00000001',
            '00000002',
            '00000001',
            '00000002',
            '00000001',
          ]);
          expect(nonces, [
            'fixed-nonce',
            'fixed-nonce',
            'fixed-nonce',
            'fresh-2',
            'fresh-2',
            'fresh-3',
            'fresh-3',
            'fresh-4',
          ]);
        } finally {
          await server.close(force: true);
        }
      },
    );

    test(
      'retries UserInfo after a stale digest returns 401 without a challenge',
      () async {
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
        final nonceCounts = <String>[];
        final nonces = <String>[];
        var challengeCount = 0;
        var authorizedCount = 0;

        server.listen((request) async {
          final authorization = request.headers.value('authorization');
          if (authorization == null) {
            challengeCount++;
            request.response.statusCode = HttpStatus.unauthorized;
            request.response.headers.set(
              'www-authenticate',
              'Digest realm="test", nonce="${challengeCount == 1 ? 'old-nonce' : 'fresh-nonce'}", qop="auth"',
            );
            await request.response.close();
            return;
          }

          authorizedCount++;
          nonceCounts.add(
            RegExp(
                  r'\bnc=([0-9a-fA-F]+)',
                ).firstMatch(authorization)?.group(1) ??
                '',
          );
          nonces.add(
            RegExp(r'nonce="([^"]+)"').firstMatch(authorization)?.group(1) ??
                '',
          );

          if (authorizedCount == 1) {
            // This is the intermittent terminal response seen when a screen
            // is opened with a nonce left by the previous student request.
            request.response.statusCode = HttpStatus.unauthorized;
            request.response.write(
              '<userCheck><statusValue>401</statusValue></userCheck>',
            );
          } else {
            request.response.statusCode = HttpStatus.ok;
            request.response.headers.contentType = ContentType.json;
            request.response.write('{}');
          }
          await request.response.close();
        });

        try {
          final service = HikvisionService(
            baseUrl: 'http://127.0.0.1:${server.port}',
            username: 'admin',
            password: 'password',
          );

          await service.getJsonWithDigest(
            Uri.parse(
              '${service.baseUrl}/ISAPI/AccessControl/UserInfo/Search?format=json',
            ),
          );

          expect(challengeCount, 2);
          expect(nonces, ['old-nonce', 'fresh-nonce']);
          expect(nonceCounts, ['00000001', '00000001']);
        } finally {
          await server.close(force: true);
        }
      },
    );

    test(
      'retries UserInfoDetail DeleteProcess after a stale digest returns 401',
      () async {
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
        final nonceCounts = <String>[];
        final nonces = <String>[];
        var challengeCount = 0;
        var authorizedCount = 0;

        server.listen((request) async {
          final authorization = request.headers.value('authorization');
          if (authorization == null) {
            challengeCount++;
            request.response.statusCode = HttpStatus.unauthorized;
            request.response.headers.set(
              'www-authenticate',
              'Digest realm="test", nonce="${challengeCount == 1 ? 'old-nonce' : 'fresh-nonce'}", qop="auth"',
            );
            await request.response.close();
            return;
          }

          authorizedCount++;
          nonceCounts.add(
            RegExp(
                  r'\bnc=([0-9a-fA-F]+)',
                ).firstMatch(authorization)?.group(1) ??
                '',
          );
          nonces.add(
            RegExp(r'nonce="([^"]+)"').firstMatch(authorization)?.group(1) ??
                '',
          );

          if (authorizedCount == 1) {
            request.response.statusCode = HttpStatus.unauthorized;
            request.response.write(
              '<userCheck><statusValue>401</statusValue></userCheck>',
            );
          } else {
            request.response.statusCode = HttpStatus.ok;
            request.response.headers.contentType = ContentType.json;
            request.response.write(
              '{"UserInfoDetailDeleteProcess":{"status":"success"}}',
            );
          }
          await request.response.close();
        });

        try {
          final service = HikvisionService(
            baseUrl: 'http://127.0.0.1:${server.port}',
            username: 'admin',
            password: 'password',
          );

          final response = await service.getJsonWithDigest(
            Uri.parse(
              '${service.baseUrl}/ISAPI/AccessControl/UserInfoDetail/DeleteProcess?format=json',
            ),
          );

          expect(response['UserInfoDetailDeleteProcess']['status'], 'success');
          expect(challengeCount, 2);
          expect(nonces, ['old-nonce', 'fresh-nonce']);
          expect(nonceCounts, ['00000001', '00000001']);
        } finally {
          await server.close(force: true);
        }
      },
    );

    test('reads an asynchronous face capture response', () {
      const xml = '''
<CaptureFaceData xmlns="http://www.isapi.org/ver20/XMLSchema">
  <captureProgress>0</captureProgress>
  <isCurRequestOver>false</isCurRequestOver>
</CaptureFaceData>
''';

      expect(HikvisionService.extractCaptureProgress(xml), 0);
      expect(HikvisionService.extractCaptureRequestOver(xml), isFalse);
      expect(HikvisionService.extractCaptureFaceDataUrl(xml), isNull);
    });

    test('reads a completed namespaced face capture response', () {
      const xml = '''
<isapi:CaptureFaceData xmlns:isapi="http://www.isapi.org/ver20/XMLSchema">
  <isapi:faceDataUrl>http://device/face&amp;1.jpg</isapi:faceDataUrl>
  <isapi:captureProgress>100</isapi:captureProgress>
</isapi:CaptureFaceData>
''';

      expect(
        HikvisionService.extractCaptureFaceDataUrl(xml),
        'http://device/face&1.jpg',
      );
      expect(HikvisionService.extractCaptureProgress(xml), 100);
    });
  });
}
