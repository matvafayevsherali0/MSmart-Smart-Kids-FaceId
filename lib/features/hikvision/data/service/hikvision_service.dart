import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:mime/mime.dart';

import '../../domain/entity/hikvision_user.dart';
import '../../domain/entity/hikvision_user_search_result.dart';
import 'face_image_normalizer.dart';
import 'hikvision_error.dart';

class HikvisionService {
  static const String captureFaceRequestBody = '''
<CaptureFaceDataCond version="2.0" xmlns="http://www.isapi.org/ver20/XMLSchema">
  <dataType>url</dataType>
</CaptureFaceDataCond>
''';
  static const String captureFaceBinaryRequestBody = '''
<CaptureFaceDataCond version="2.0" xmlns="http://www.isapi.org/ver20/XMLSchema">
  <dataType>binary</dataType>
</CaptureFaceDataCond>
''';

  String baseUrl;
  String username;
  String password;
  final void Function(String message) _debugLogger;

  Map<String, String>? _digestChallenge;
  int _digestNonceCount = 0;
  static int _clientNonceSequence = 0;
  // Digest nonce state is shared by all requests made through this singleton.
  // Keep requests in order so two student screens cannot generate the same
  // nonce count or overwrite the cached challenge while another request is
  // still being authenticated.
  Future<void> _digestRequestQueue = Future<void>.value();

  HikvisionService({
    required String baseUrl,
    required this.username,
    required this.password,
    void Function(String message)? debugLogger,
  }) : baseUrl = _normalizeBaseUrl(baseUrl),
       _debugLogger = debugLogger ?? _defaultDebugLogger {
    _logConnection('ulanish sozlandi');
  }

  void updateConnection({
    required String baseUrl,
    required String username,
    required String password,
  }) {
    final normalizedBaseUrl = _normalizeBaseUrl(baseUrl);
    final connectionChanged =
        this.baseUrl != normalizedBaseUrl ||
        this.username != username ||
        this.password != password;

    this.baseUrl = normalizedBaseUrl;
    this.username = username;
    this.password = password;
    if (connectionChanged) {
      _digestChallenge = null;
      _digestNonceCount = 0;
    }
    _logConnection('ulanish yangilandi');
  }

  static String normalizeEmployeeNoForIsapi(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return s;
    final uuid = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    if (uuid.hasMatch(s)) {
      return s.replaceAll('-', '');
    }
    return s;
  }

  static bool employeeNoMatches(String deviceValue, String requested) {
    final a = deviceValue.trim();
    final b = requested.trim();
    if (a == b) return true;
    return normalizeEmployeeNoForIsapi(a) == normalizeEmployeeNoForIsapi(b);
  }

  Future<HikvisionUser?> getUserByEmployeeNo(String employeeNo) async {
    final emp = normalizeEmployeeNoForIsapi(employeeNo);
    if (emp.isEmpty) {
      throw Exception('employeeNo bo‘sh — Hikvision qidiruv yuborilmaydi.');
    }

    final uri = Uri.parse(
      '$baseUrl/ISAPI/AccessControl/UserInfo/Search?format=json',
    );

    final body = jsonEncode(
      _userInfoSearchBody(
        searchResultPosition: 0,
        maxResults: 1,
        employeeNos: [emp],
      ),
    );

    final jsonMap = await postJsonWithDigest(uri, body);
    final search = jsonMap['UserInfoSearch'];
    if (search is! Map) return null;

    final userInfo = search['UserInfo'];
    if (userInfo == null) return null;

    final List list = (userInfo is List) ? userInfo : [userInfo];
    for (final item in list) {
      if (item is Map<String, dynamic>) {
        final deviceEmp = item['employeeNo']?.toString() ?? '';
        if (employeeNoMatches(deviceEmp, employeeNo)) {
          return HikvisionUser.fromJson(item);
        }
      }
    }
    return null;
  }

  Future<HikvisionUserSearchResult> searchUsers({
    int searchResultPosition = 0,
    int maxResults = 30,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/ISAPI/AccessControl/UserInfo/Search?format=json',
    );

    final body = jsonEncode(
      _userInfoSearchBody(
        searchResultPosition: searchResultPosition,
        maxResults: maxResults,
      ),
    );

    final jsonMap = await postJsonWithDigest(uri, body);
    final search = jsonMap['UserInfoSearch'];
    if (search is! Map) {
      return const HikvisionUserSearchResult(totalMatches: 0, users: []);
    }

    final totalMatches = userInfoSearchTotalMatches(search);
    final userInfo = search['UserInfo'];
    if (userInfo == null) {
      return HikvisionUserSearchResult(
        totalMatches: totalMatches,
        users: const [],
      );
    }

    final List list = (userInfo is List) ? userInfo : [userInfo];
    final users = <HikvisionUser>[];
    for (final item in list) {
      if (item is Map<String, dynamic>) {
        users.add(HikvisionUser.fromJson(item));
      }
    }

    return HikvisionUserSearchResult(totalMatches: totalMatches, users: users);
  }

  Future<String?> getFaceUrlByEmployeeNo(String employeeNo) async {
    final emp = normalizeEmployeeNoForIsapi(employeeNo);
    if (emp.isEmpty) return null;

    final uri = Uri.parse(
      '$baseUrl/ISAPI/Intelligent/FDLib/FDSearch?format=json',
    );
    final body = jsonEncode({
      'searchID': _generateSearchId(),
      'searchResultPosition': 0,
      'maxResults': 1,
      'FDID': '1',
      'FPID': emp,
      'faceLibType': 'blackFD',
    });

    final jsonMap = await postJsonWithDigest(uri, body);
    return extractFaceUrlFromSearchResponse(jsonMap);
  }

  static String? extractFaceUrlFromSearchResponse(
    Map<String, dynamic> jsonMap,
  ) {
    final matchLists = <Object?>[
      jsonMap['MatchList'],
      (jsonMap['FaceInfoSearch'] as Map?)?['MatchList'],
      (jsonMap['FDSearchResult'] as Map?)?['MatchList'],
    ];

    for (final rawList in matchLists) {
      if (rawList is! List || rawList.isEmpty) continue;
      for (final item in rawList) {
        if (item is! Map) continue;
        for (final key in const ['picURL', 'faceURL', 'faceDataUrl']) {
          final value = item[key]?.toString().trim() ?? '';
          if (value.isNotEmpty) return value;
        }
      }
    }
    return null;
  }

  Future<List<int>> downloadBytesWithDigest(Uri uri) async {
    final response = await _sendAuthorizedRequest(
      'GET',
      uri,
      headers: {'Accept': '*/*'},
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HikvisionDeviceException.fromResponse(
        response,
        operation: 'rasmni yuklash',
      );
    }
    return response.bodyBytes;
  }

  Future<String> captureFaceUrl() async {
    final uri = Uri.parse('$baseUrl/ISAPI/AccessControl/CaptureFaceData');
    _log('rasm olish boshlandi: $uri');

    final response = await _sendAuthorizedRequest(
      'POST',
      uri,
      headers: {'Content-Type': 'application/xml', 'Accept': '*/*'},
      body: captureFaceRequestBody,
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HikvisionDeviceException.fromResponse(
        response,
        operation: 'rasmga olish',
      );
    }
    _throwIfIsapiBodyHasError(response, operation: 'rasmga olish');
    final directUrl = extractCaptureFaceDataUrl(response.body);
    final progress = extractCaptureProgress(response.body);
    if (directUrl != null && (progress == null || progress >= 100)) {
      _log('rasm olish yakunlandi: faceDataUrl=$directUrl');
      return directUrl;
    }
    if (progress == 0 && extractCaptureRequestOver(response.body) == true) {
      throw const HikvisionDeviceException(
        message:
            'Face ID rasmni ola olmadi. Yuzni kameraga to‘g‘ri qarating va qayta urinib ko‘ring.',
      );
    }

    return _waitForCapturedFaceUrl(
      readerId: extractCaptureReaderId(response.body),
    );
  }

  Future<List<int>> captureFaceBytes() async {
    final uri = Uri.parse('$baseUrl/ISAPI/AccessControl/CaptureFaceData');
    _log('rasmni binary shaklda olish boshlandi: $uri');
    final response = await _sendAuthorizedRequest(
      'POST',
      uri,
      headers: {'Content-Type': 'application/xml', 'Accept': '*/*'},
      body: captureFaceBinaryRequestBody,
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HikvisionDeviceException.fromResponse(
        response,
        operation: 'rasmga olish',
      );
    }
    final bytes = await extractCapturedFaceBytes(response);
    _log('rasm binary shaklda olindi: ${bytes.length} bayt');
    return bytes;
  }

  static Future<List<int>> extractCapturedFaceBytes(
    http.Response response,
  ) async {
    final contentType = response.headers['content-type'] ?? '';
    if (contentType.toLowerCase().startsWith('image/jpeg')) {
      return response.bodyBytes;
    }
    final boundaryMatch = RegExp(
      r'boundary\s*=\s*"?([^";\s]+)',
      caseSensitive: false,
    ).firstMatch(contentType);
    if (boundaryMatch == null) {
      throw const HikvisionDeviceException(
        message:
            'Face ID qurilmasi rasm faylini qaytarmadi. Qayta urinib ko‘ring.',
      );
    }
    final parts = Stream<List<int>>.value(
      response.bodyBytes,
    ).transform(MimeMultipartTransformer(boundaryMatch.group(1)!));
    await for (final part in parts) {
      final disposition = part.headers['content-disposition'] ?? '';
      if (RegExp(
        r'name\s*=\s*"?FaceData"?',
        caseSensitive: false,
      ).hasMatch(disposition)) {
        final builder = BytesBuilder(copy: false);
        await for (final chunk in part) {
          builder.add(chunk);
        }
        final bytes = builder.takeBytes();
        if (bytes.isNotEmpty) return bytes;
      } else {
        await part.drain<void>();
      }
    }
    throw const HikvisionDeviceException(
      message:
          'Face ID qurilmasi rasm faylini qaytarmadi. Qayta urinib ko‘ring.',
    );
  }

  Future<String> _waitForCapturedFaceUrl({int? readerId}) async {
    for (var attempt = 0; attempt < 20; attempt++) {
      final baseUri = Uri.parse(
        '$baseUrl/ISAPI/AccessControl/CaptureFaceData/Progress',
      );
      final uri = readerId == null
          ? baseUri
          : baseUri.replace(queryParameters: {'readerID': '$readerId'});
      final response = await _sendAuthorizedRequest(
        'GET',
        uri,
        headers: {'Accept': '*/*'},
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HikvisionDeviceException.fromResponse(
          response,
          operation: 'rasm olish jarayonini tekshirish',
        );
      }
      _throwIfIsapiBodyHasError(
        response,
        operation: 'rasm olish jarayonini tekshirish',
      );

      final url = extractCaptureFaceDataUrl(response.body);
      final progress = extractCaptureProgress(response.body);
      if (url != null && (progress == null || progress >= 100)) return url;

      if (progress == 0 && extractCaptureRequestOver(response.body) == true) {
        throw const HikvisionDeviceException(
          message:
              'Face ID rasmni ola olmadi. Yuzni kameraga to‘g‘ri qarating va qayta urinib ko‘ring.',
        );
      }

      if (attempt < 19) {
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }
    }

    throw const HikvisionDeviceException(
      message:
          'Face ID rasm olish jarayonini yakunlamadi. Birozdan so‘ng qayta urinib ko‘ring.',
    );
  }

  static String? extractCaptureFaceDataUrl(String xml) {
    return _captureTag(xml, 'faceDataUrl')
        ?.trim()
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');
  }

  static int? extractCaptureProgress(String xml) {
    return int.tryParse(_captureTag(xml, 'captureProgress') ?? '');
  }

  static bool? extractCaptureRequestOver(String xml) {
    final value = _captureTag(xml, 'isCurRequestOver')?.toLowerCase();
    if (value == 'true') return true;
    if (value == 'false') return false;
    return null;
  }

  static int? extractCaptureReaderId(String xml) {
    return int.tryParse(_captureTag(xml, 'readerID') ?? '');
  }

  static String? _captureTag(String xml, String tagName) {
    final match = RegExp(
      '<(?:[\\w.-]+:)?$tagName\\b[^>]*>([^<]*)</(?:[\\w.-]+:)?$tagName>',
      caseSensitive: false,
    ).firstMatch(xml);
    return match?.group(1)?.trim();
  }

  void _throwIfIsapiBodyHasError(
    http.Response response, {
    required String operation,
  }) {
    final statusCode = HikvisionErrorTranslator.parseBody(
      response.body,
    ).statusCode;
    if (statusCode != null && statusCode != 1 && statusCode != 200) {
      throw HikvisionDeviceException.fromResponse(
        response,
        operation: operation,
      );
    }
  }

  Future<Map<String, dynamic>> addFaceByUrl({
    required String employeeNo,
    required String faceUrl,
    required String name,
  }) async {
    final emp = normalizeEmployeeNoForIsapi(employeeNo);
    if (emp.isEmpty) {
      throw Exception('employeeNo bo‘sh — yuz qo‘shilmaydi.');
    }

    final uri = Uri.parse(
      '$baseUrl/ISAPI/Intelligent/FDLib/FaceDataRecord?format=json',
    );
    final body = jsonEncode({
      'faceLibType': 'blackFD',
      'FDID': '1',
      'FPID': emp,
      'faceURL': faceUrl,
      'name': name.trim().isEmpty ? emp : name.trim(),
      'bornTime': '1970-01-01+08:00',
      'gender': 'unknown',
      'saveFacePic': true,
    });
    return postJsonWithDigest(uri, body, operation: 'yuz rasmini qo‘shish');
  }

  Future<Map<String, dynamic>> updateFaceByUrl({
    required String employeeNo,
    required String faceUrl,
    required String name,
  }) async {
    final emp = normalizeEmployeeNoForIsapi(employeeNo);
    if (emp.isEmpty) {
      throw const HikvisionDeviceException(
        message: 'Tarbiyalanuvchi raqami topilmadi. Qayta urinib ko‘ring.',
      );
    }

    final body = jsonEncode({
      'faceURL': faceUrl,
      'faceLibType': 'blackFD',
      'FDID': '1',
      'FPID': emp,
      'name': name.trim().isEmpty ? emp : name.trim(),
      'bornTime': '1970-01-01+08:00',
      'gender': 'unknown',
      'saveFacePic': true,
    });

    final uri = Uri.parse(
      '$baseUrl/ISAPI/Intelligent/FDLib/FDModify?format=json',
    );
    try {
      return await putJsonWithDigest(
        uri,
        body,
        operation: 'yuz rasmini yangilash',
      );
    } on HikvisionDeviceException catch (error) {
      // Older terminals expose the same operation through FDSearch.
      if (error.statusCode != 404 &&
          error.statusCode != 405 &&
          error.statusCode != 501) {
        rethrow;
      }

      final legacyUri = Uri.parse('$baseUrl/ISAPI/Intelligent/FDLib/FDSearch')
          .replace(
            queryParameters: {
              'format': 'json',
              'FDID': '1',
              'FPID': emp,
              'faceLibType': 'blackFD',
            },
          );
      return putJsonWithDigest(
        legacyUri,
        jsonEncode({
          'faceURL': faceUrl,
          'name': name.trim().isEmpty ? emp : name.trim(),
          'bornTime': '1970-01-01+08:00',
          'gender': 'unknown',
          'saveFacePic': true,
        }),
        operation: 'yuz rasmini yangilash',
      );
    }
  }

  Future<void> upsertFaceByUrl({
    required String employeeNo,
    required String faceUrl,
    required String name,
  }) async {
    // FDModify only works when the FPID already has a face record.  The
    // device returns NO MATCH for a new user, but older code attempted PUT
    // unconditionally and the terminal answered faceDataPIDError/saveFacePic.
    // Decide the operation from the device state first, just like the byte
    // upload flow does.
    final existingFaceUrl = await getFaceUrlByEmployeeNo(employeeNo);
    final hasExistingFace = existingFaceUrl?.trim().isNotEmpty == true;
    if (!hasExistingFace) {
      await addFaceByUrl(employeeNo: employeeNo, faceUrl: faceUrl, name: name);
      return;
    }

    try {
      await updateFaceByUrl(
        employeeNo: employeeNo,
        faceUrl: faceUrl,
        name: name,
      );
    } on HikvisionDeviceException catch (error) {
      if (!error.isMissingFaceRecord) rethrow;
      await addFaceByUrl(employeeNo: employeeNo, faceUrl: faceUrl, name: name);
    }
  }

  Future<void> upsertFaceByBytes({
    required String employeeNo,
    required List<int> imageBytes,
    required String name,
  }) async {
    final emp = normalizeEmployeeNoForIsapi(employeeNo);
    if (emp.isEmpty || imageBytes.isEmpty) {
      throw const HikvisionDeviceException(
        message:
            'Rasm yoki tarbiyalanuvchi raqami topilmadi. Qayta urinib ko‘ring.',
      );
    }

    // FDModify is only valid when the FPID already exists in the face
    // library. The terminal returns NO MATCH for a new person, but the old
    // implementation still sent PUT and the device answered
    // faceDataPIDError/saveFacePic. Query the library first so new records
    // use FaceDataRecord (POST) and existing records use FDModify (PUT).
    final existingFaceUrl = await getFaceUrlByEmployeeNo(emp);
    final hasExistingFace = existingFaceUrl?.trim().isNotEmpty == true;
    final method = hasExistingFace ? 'PUT' : 'POST';
    final uri = Uri.parse(
      hasExistingFace
          ? '$baseUrl/ISAPI/Intelligent/FDLib/FDModify?format=json'
          : '$baseUrl/ISAPI/Intelligent/FDLib/FaceDataRecord?format=json',
    );
    _log(
      'yuz yozuvi ${hasExistingFace ? 'yangilanmoqda' : 'qo‘shilmoqda'}: '
      'employeeNo=$emp, method=$method, uri=$uri',
    );
    await _sendFaceMultipart(
      method,
      uri,
      employeeNo: emp,
      imageBytes: imageBytes,
      name: name,
    );
  }

  Future<void> _sendFaceMultipart(
    String method,
    Uri uri, {
    required String employeeNo,
    required List<int> imageBytes,
    required String name,
  }) async {
    final normalizedImageBytes = normalizeHikvisionFaceImage(imageBytes);
    final boundary = 'hikvision-${_randomHex(12)}';
    final metadata = jsonEncode({
      'faceLibType': 'blackFD',
      'FDID': '1',
      'FPID': employeeNo,
      'name': name.trim().isEmpty ? employeeNo : name.trim(),
      'bornTime': '1970-01-01+08:00',
      'gender': 'unknown',
      'saveFacePic': true,
    });
    final metadataBytes = utf8.encode(metadata);
    final multipart = BytesBuilder(copy: false)
      ..add(
        utf8.encode(
          '--$boundary\r\n'
          'Content-Disposition: form-data; name="FaceDataRecord"\r\n'
          'Content-Type: application/json\r\n'
          'Content-Length: ${metadataBytes.length}\r\n\r\n',
        ),
      )
      ..add(metadataBytes)
      ..add(
        utf8.encode(
          '\r\n'
          '--$boundary\r\n'
          'Content-Disposition: form-data; name="FaceImage"; filename="facePic.jpg"\r\n'
          'Content-Type: image/jpeg\r\n'
          'Content-Length: ${normalizedImageBytes.length}\r\n\r\n',
        ),
      )
      ..add(normalizedImageBytes)
      ..add(utf8.encode('\r\n--$boundary--\r\n'));
    final response = await _sendAuthorizedRequest(
      method,
      uri,
      headers: {
        'Content-Type': 'multipart/form-data; boundary=$boundary',
        'Accept': 'application/json',
      },
      bodyBytes: multipart.takeBytes(),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HikvisionDeviceException.fromResponse(
        response,
        operation: 'yuz rasmini saqlash',
      );
    }
    _decodeAsJson(response, operation: 'yuz rasmini saqlash');
  }

  Future<Map<String, dynamic>> deleteUser(String employeeNo) async {
    final emp = normalizeEmployeeNoForIsapi(employeeNo);
    if (emp.isEmpty) {
      throw Exception('employeeNo bo‘sh — o‘chirish yuborilmaydi.');
    }

    await deleteFaceByEmployeeNo(emp);
    return _deleteUserRecords([emp]);
  }

  Future<Map<String, dynamic>> deleteUsersBatch(
    List<String> employeeNos,
  ) async {
    final normalized = employeeNos
        .map(normalizeEmployeeNoForIsapi)
        .where((employeeNo) => employeeNo.isNotEmpty)
        .toSet()
        .toList();
    if (normalized.isEmpty) return <String, dynamic>{};

    for (final employeeNo in normalized) {
      await deleteFaceByEmployeeNo(employeeNo);
    }
    return _deleteUserRecords(normalized);
  }

  Future<void> deleteFaceByEmployeeNo(String employeeNo) async {
    final emp = normalizeEmployeeNoForIsapi(employeeNo);
    if (emp.isEmpty) return;

    final uri = Uri.parse(
      '$baseUrl/ISAPI/Intelligent/FDLib/FDSearch/Delete?format=json&FDID=1&faceLibType=blackFD',
    );
    final body = jsonEncode({
      'FPID': [
        {'value': emp},
      ],
    });

    try {
      await putJsonWithDigest(uri, body, operation: 'yuz rasmini o‘chirish');
    } on HikvisionDeviceException catch (error) {
      if (!error.isMissingFaceRecord) rethrow;
    }
  }

  Future<Map<String, dynamic>> _deleteUserRecords(List<String> employeeNos) {
    final uri = Uri.parse(
      '$baseUrl/ISAPI/AccessControl/UserInfoDetail/Delete?format=json',
    );
    final body = jsonEncode(userInfoDeleteBody(employeeNos));
    return _deleteUserRecordsAndWait(uri, body);
  }

  Future<Map<String, dynamic>> _deleteUserRecordsAndWait(
    Uri uri,
    String body,
  ) async {
    final result = await putJsonWithDigest(
      uri,
      body,
      operation: 'foydalanuvchini o‘chirish',
    );
    await _waitForUserDeleteProcess();
    return result;
  }

  Future<void> _waitForUserDeleteProcess() async {
    final uri = Uri.parse(
      '$baseUrl/ISAPI/AccessControl/UserInfoDetail/DeleteProcess?format=json',
    );

    for (var attempt = 0; attempt < 20; attempt++) {
      try {
        final process = await getJsonWithDigest(
          uri,
          operation: 'o‘chirish jarayonini tekshirish',
        );
        final rawProcess = process['UserInfoDetailDeleteProcess'];
        if (rawProcess is! Map) return;

        final status = rawProcess['status']?.toString().toLowerCase();
        final percent = int.tryParse(rawProcess['percent']?.toString() ?? '');
        if (status == 'failed') {
          throw const HikvisionDeviceException(
            message:
                'Face ID qurilmasidagi foydalanuvchini o‘chirish amalga oshmadi.',
          );
        }
        if (status != 'processing' || (percent != null && percent >= 100)) {
          return;
        }
      } on HikvisionDeviceException catch (error) {
        // Some older terminals do not expose the progress endpoint. The
        // successful delete request is still treated as completed there.
        if (error.statusCode == 404 || error.statusCode == 405) return;
        rethrow;
      }

      if (attempt < 19) {
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }
    }

    throw const HikvisionDeviceException(
      message:
          'Face ID qurilmasi foydalanuvchini o‘chirishni yakunlamadi. Birozdan so‘ng qayta urinib ko‘ring.',
    );
  }

  static Map<String, dynamic> userInfoDeleteBody(Iterable<String> employeeNos) {
    return {
      'UserInfoDetail': {
        'mode': 'byEmployeeNo',
        'EmployeeNoList': employeeNos
            .map(
              (employeeNo) => {
                'employeeNo': normalizeEmployeeNoForIsapi(employeeNo),
              },
            )
            .toList(),
      },
    };
  }

  Future<void> createUser({
    required String employeeNo,
    required String name,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/ISAPI/AccessControl/UserInfo/Record?format=json',
    );

    String fmt(DateTime dt) => dt.toIso8601String().split('.').first;

    final now = DateTime.now();
    final beginTime = fmt(now);
    final endTime = fmt(
      DateTime(
        now.year + 10,
        now.month,
        now.day,
        now.hour,
        now.minute,
        now.second,
      ),
    );

    final emp = normalizeEmployeeNoForIsapi(employeeNo);
    if (emp.isEmpty) {
      throw Exception('employeeNo bo‘sh — foydalanuvchi yaratilmaydi.');
    }

    final displayName = name.trim().isEmpty ? emp : name.trim();

    final body = jsonEncode({
      'UserInfo': {
        'employeeNo': emp,
        'name': displayName,
        'userType': 'normal',
        'gender': 'unknown',
        'localUIRight': true,
        'maxOpenDoorTime': 0,
        'Valid': {
          'enable': true,
          'beginTime': beginTime,
          'endTime': endTime,
          'timeType': 'local',
        },
        'belongGroup': '',
        'password': '',
        'doorRight': '1',
        'RightPlan': [
          {'doorNo': 1, 'planTemplateNo': '1'},
        ],
        'floorNumber': 0,
        'roomNumber': 0,
        'PersonInfoExtends': [
          {'value': ''},
        ],
      },
    });

    await postJsonWithDigest(uri, body);
  }

  Future<Map<String, dynamic>> getJsonWithDigest(
    Uri uri, {
    String operation = 'amal bajarish',
  }) async {
    final response = await _sendAuthorizedRequest(
      'GET',
      uri,
      headers: {'Accept': 'application/json'},
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HikvisionDeviceException.fromResponse(
        response,
        operation: operation,
      );
    }
    return _decodeAsJson(response, operation: operation);
  }

  Future<Map<String, dynamic>> postJsonWithDigest(
    Uri uri,
    String body, {
    String operation = 'amal bajarish',
  }) async {
    final response = await _sendAuthorizedRequest(
      'POST',
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: body,
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HikvisionDeviceException.fromResponse(
        response,
        operation: operation,
      );
    }
    return _decodeAsJson(response, operation: operation);
  }

  Future<Map<String, dynamic>> putJsonWithDigest(
    Uri uri,
    String body, {
    String operation = 'amal bajarish',
  }) async {
    final response = await _sendAuthorizedRequest(
      'PUT',
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: body,
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HikvisionDeviceException.fromResponse(
        response,
        operation: operation,
      );
    }
    return _decodeAsJson(response, operation: operation);
  }

  static const Duration _connectTimeout = Duration(seconds: 20);
  static const Duration _bodyTimeout = Duration(seconds: 45);

  Future<http.Response> _sendAuthorizedRequest(
    String method,
    Uri uri, {
    Map<String, String>? headers,
    String? body,
    List<int>? bodyBytes,
  }) {
    final previous = _digestRequestQueue;
    final current = previous.then(
      (_) => _sendAuthorizedRequestUnlocked(
        method,
        uri,
        headers: headers,
        body: body,
        bodyBytes: bodyBytes,
      ),
    );

    // A failed request must not prevent later requests from leaving the queue.
    _digestRequestQueue = current.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return current;
  }

  Future<http.Response> _sendAuthorizedRequestUnlocked(
    String method,
    Uri uri, {
    Map<String, String>? headers,
    String? body,
    List<int>? bodyBytes,
  }) async {
    final client = _createIoClient();
    try {
      final cachedChallenge = _digestChallenge;
      if (cachedChallenge != null) {
        final response = await _sendWithDigest(
          client,
          method,
          uri,
          headers: headers,
          body: body,
          bodyBytes: bodyBytes,
          challenge: cachedChallenge,
        ).timeout(_connectTimeout + _bodyTimeout);
        if (response.statusCode != 401) return response;

        final freshChallenge = _digestChallengeFrom(response);
        if (freshChallenge == null) {
          if (_needsFreshDigestCount(uri, method)) {
            _log(
              'Face ID maxsus URL uchun yangi Digest challenge so‘ralmoqda: $uri',
            );
            _digestChallenge = null;
            _digestNonceCount = 0;

            // Some terminal firmware invalidates the whole nonce after a
            // capture/face-library request and answers the 401 without a new
            // WWW-Authenticate header. Reusing the cached nonce, even with
            // nc=1, still fails on those devices. Ask the terminal for a new
            // challenge before retrying the same request.
            final challengeResponse = await _sendRawRequest(
              client,
              method,
              uri,
              headers: headers,
              body: body,
              bodyBytes: bodyBytes,
            ).timeout(_connectTimeout + _bodyTimeout);
            final refreshedChallenge = _digestChallengeFrom(challengeResponse);
            if (refreshedChallenge != null) {
              _rememberDigestChallenge(refreshedChallenge);
              final refreshedRetry = await _sendWithDigest(
                client,
                method,
                uri,
                headers: headers,
                body: body,
                bodyBytes: bodyBytes,
                challenge: refreshedChallenge,
              ).timeout(_connectTimeout + _bodyTimeout);
              if (refreshedRetry.statusCode != 401) {
                return refreshedRetry;
              }
            }

            // Keep a compatibility fallback for older firmware that does not
            // issue a fresh challenge but accepts the cached nonce at nc=1.
            _log('Face ID maxsus URL uchun Digest nonce qayta boshlandi: $uri');
            final localPictureRetry = await _sendWithDigest(
              client,
              method,
              uri,
              headers: headers,
              body: body,
              bodyBytes: bodyBytes,
              challenge: cachedChallenge,
              nonceCountOverride: 1,
            ).timeout(_connectTimeout + _bodyTimeout);
            if (localPictureRetry.statusCode != 401) {
              return localPictureRetry;
            }
          }

          _digestChallenge = null;
          _digestNonceCount = 0;
          return response;
        }

        _rememberDigestChallenge(freshChallenge);
        return await _sendWithDigest(
          client,
          method,
          uri,
          headers: headers,
          body: body,
          bodyBytes: bodyBytes,
          challenge: freshChallenge,
        ).timeout(_connectTimeout + _bodyTimeout);
      }

      final initialResponse = await _sendRawRequest(
        client,
        method,
        uri,
        headers: headers,
        body: body,
        bodyBytes: bodyBytes,
      ).timeout(_connectTimeout + _bodyTimeout);

      if (initialResponse.statusCode != 401) {
        return initialResponse;
      }

      final digest = _digestChallengeFrom(initialResponse);
      if (digest == null) {
        throw HikvisionDeviceException.fromResponse(
          initialResponse,
          operation: 'Face ID qurilmasiga kirish',
        );
      }

      _rememberDigestChallenge(digest);
      final authenticatedResponse = await _sendWithDigest(
        client,
        method,
        uri,
        headers: headers,
        body: body,
        bodyBytes: bodyBytes,
        challenge: digest,
      ).timeout(_connectTimeout + _bodyTimeout);
      if (authenticatedResponse.statusCode != 401) {
        return authenticatedResponse;
      }

      // A few terminals can reject the very first authenticated request
      // without returning a new WWW-Authenticate header. Treat this the same
      // way as a stale cached nonce so opening a different student's screen
      // does not surface a false login error.
      final freshChallenge = _digestChallengeFrom(authenticatedResponse);
      if (freshChallenge == null && _needsFreshDigestCount(uri, method)) {
        _log('Yangi Digest challenge so‘ralmoqda: $uri');
        _digestChallenge = null;
        _digestNonceCount = 0;

        final challengeResponse = await _sendRawRequest(
          client,
          method,
          uri,
          headers: headers,
          body: body,
          bodyBytes: bodyBytes,
        ).timeout(_connectTimeout + _bodyTimeout);
        final refreshedChallenge = _digestChallengeFrom(challengeResponse);
        if (refreshedChallenge != null) {
          _rememberDigestChallenge(refreshedChallenge);
          final refreshedRetry = await _sendWithDigest(
            client,
            method,
            uri,
            headers: headers,
            body: body,
            bodyBytes: bodyBytes,
            challenge: refreshedChallenge,
          ).timeout(_connectTimeout + _bodyTimeout);
          if (refreshedRetry.statusCode != 401) {
            return refreshedRetry;
          }
        }

        // Compatibility fallback for firmware that accepts the original
        // challenge again only after resetting its nonce count.
        final fallbackRetry = await _sendWithDigest(
          client,
          method,
          uri,
          headers: headers,
          body: body,
          bodyBytes: bodyBytes,
          challenge: digest,
          nonceCountOverride: 1,
        ).timeout(_connectTimeout + _bodyTimeout);
        if (fallbackRetry.statusCode != 401) {
          return fallbackRetry;
        }
      } else if (freshChallenge != null) {
        _rememberDigestChallenge(freshChallenge);
        final freshRetry = await _sendWithDigest(
          client,
          method,
          uri,
          headers: headers,
          body: body,
          bodyBytes: bodyBytes,
          challenge: freshChallenge,
        ).timeout(_connectTimeout + _bodyTimeout);
        if (freshRetry.statusCode != 401) {
          return freshRetry;
        }
      }

      _digestChallenge = null;
      _digestNonceCount = 0;
      return authenticatedResponse;
    } on TimeoutException {
      _log('timeout: $method $uri');
      throw const HikvisionDeviceException(
        message:
            'Face ID qurilmasi javob bermadi. Telefon va qurilma bir xil Wi-Fi tarmog‘ida ekanini tekshiring.',
      );
    } on SocketException catch (error) {
      _log('socket xatosi: $method $uri; $error');
      throw HikvisionDeviceException(
        message:
            'Face ID qurilmasiga ulanib bo‘lmadi. Telefon va qurilma bir xil Wi-Fi tarmog‘ida ekanini tekshiring.',
      );
    } on http.ClientException catch (error) {
      _log('HTTP klient xatosi: $method $uri; $error');
      throw HikvisionDeviceException(
        message:
            'Face ID qurilmasiga ulanib bo‘lmadi. Telefon va qurilma bir xil Wi-Fi tarmog‘ida ekanini tekshiring.',
      );
    } finally {
      client.close();
    }
  }

  Future<http.Response> _sendWithDigest(
    http.Client client,
    String method,
    Uri uri, {
    Map<String, String>? headers,
    String? body,
    List<int>? bodyBytes,
    required Map<String, String> challenge,
    int? nonceCountOverride,
  }) async {
    final nonceCount = nonceCountOverride ?? ++_digestNonceCount;
    final nc = nonceCount.toRadixString(16).padLeft(8, '0');
    final digestHeader = _buildDigestHeader(
      username: username,
      password: password,
      method: method,
      uri: digestUriForRequest(uri),
      auth: challenge,
      nc: nc,
      cnonce: _generateClientNonce(),
    );

    return _sendRawRequest(
      client,
      method,
      uri,
      headers: {...?headers, 'Authorization': digestHeader},
      body: body,
      bodyBytes: bodyBytes,
    );
  }

  static bool _isCapturedFacePictureUri(Uri uri) {
    return uri.path.toLowerCase().startsWith('/locals/pic/');
  }

  static bool _needsFreshDigestCount(Uri uri, String method) {
    final path = uri.path.toLowerCase();
    final isCapturedPicture =
        method.toUpperCase() == 'GET' && _isCapturedFacePictureUri(uri);
    final isFaceLibraryRequest = path.startsWith('/isapi/intelligent/fdlib/');
    final isCaptureRequest =
        path == '/isapi/accesscontrol/capturefacedata' ||
        path.startsWith('/isapi/accesscontrol/capturefacedata/');
    // UserInfo/Search is called whenever the user opens another student.
    // Some terminals answer a stale digest with 401 and no challenge header,
    // so it must use the same fresh-challenge recovery as face operations.
    final isUserInfoRequest = path.startsWith('/isapi/accesscontrol/userinfo/');
    // DeleteProcess is polled after a user is removed.  Some terminals
    // invalidate the cached digest nonce between the delete request and the
    // next poll, then return 401 without a WWW-Authenticate header.
    final isUserInfoDetailRequest = path.startsWith(
      '/isapi/accesscontrol/userinfodetail/',
    );
    return isCapturedPicture ||
        isFaceLibraryRequest ||
        isCaptureRequest ||
        isUserInfoRequest ||
        isUserInfoDetailRequest;
  }

  Map<String, String>? _digestChallengeFrom(http.Response response) {
    final header = response.headers['www-authenticate'];
    if (header == null ||
        !RegExp(r'^\s*Digest\b', caseSensitive: false).hasMatch(header)) {
      return null;
    }
    return _parseDigest(header);
  }

  void _rememberDigestChallenge(Map<String, String> challenge) {
    if (_digestChallenge?['nonce'] != challenge['nonce']) {
      _digestNonceCount = 0;
    }
    _digestChallenge = challenge;
  }

  IOClient _createIoClient() {
    final httpClient = HttpClient()
      ..connectionTimeout = _connectTimeout
      ..idleTimeout = _bodyTimeout
      ..maxConnectionsPerHost = 4;
    return IOClient(httpClient);
  }

  Future<http.Response> _sendRawRequest(
    http.Client client,
    String method,
    Uri uri, {
    Map<String, String>? headers,
    String? body,
    List<int>? bodyBytes,
  }) async {
    final request = http.Request(method, uri)
      ..followRedirects = false
      ..persistentConnection = false;

    request.headers['Connection'] = 'close';
    request.headers['Expect'] = '';
    if (headers != null && headers.isNotEmpty) {
      request.headers.addAll(headers);
    }
    if (body != null) {
      request.body = body;
    } else if (bodyBytes != null) {
      request.bodyBytes = bodyBytes;
    }

    _log('''
so‘rov yuborilmoqda
method: $method
uri: $uri
headers: ${_headersForLog(request.headers)}
body: ${bodyBytes == null ? body ?? '' : '<binary multipart: ${bodyBytes.length} bytes>'}
''');
    final streamedResponse = await client.send(request);
    final response = await http.Response.fromStream(
      streamedResponse,
    ).timeout(_bodyTimeout);
    _log('''
javob qabul qilindi
method: $method
uri: $uri
statusCode: ${response.statusCode}
headers: ${response.headers}
body: ${_responseBodyForLog(response)}
''');
    return response;
  }

  void _logConnection(String event) {
    _log('$event: baseUrl=$baseUrl, username=$username');
  }

  void _log(String message) => _debugLogger('[Hikvision] $message');

  static void _defaultDebugLogger(String message) {
    if (kDebugMode) debugPrint(message);
  }

  static String _responseBodyForLog(http.Response response) {
    final contentType = response.headers['content-type']?.toLowerCase() ?? '';
    if (contentType.startsWith('image/') ||
        contentType.startsWith('multipart/')) {
      return '<binary image: ${response.bodyBytes.length} bytes>';
    }
    return response.body;
  }

  static Map<String, String> _headersForLog(Map<String, String> headers) {
    final safeHeaders = <String, String>{};
    for (final entry in headers.entries) {
      final isSensitive = const {
        'authorization',
        'proxy-authorization',
        'cookie',
        'set-cookie',
      }.contains(entry.key.toLowerCase());
      safeHeaders[entry.key] = isSensitive ? '<redacted>' : entry.value;
    }
    return safeHeaders;
  }

  Map<String, String> _parseDigest(String header) {
    final regex = RegExp(r'''(\w+)=("(?:[^"\\]|\\.)*"|[^,]+)''');
    final result = <String, String>{};
    for (final match in regex.allMatches(header)) {
      final key = match.group(1);
      var value = match.group(2)?.trim();
      if (value != null &&
          value.length >= 2 &&
          value.startsWith('"') &&
          value.endsWith('"')) {
        value = value.substring(1, value.length - 1);
      }
      if (key != null && value != null) {
        result[key] = value;
      }
    }
    return result;
  }

  String _buildDigestHeader({
    required String username,
    required String password,
    required String method,
    required String uri,
    required Map<String, String> auth,
    required String nc,
    required String cnonce,
  }) {
    final realm = auth['realm'];
    final nonce = auth['nonce'];
    if (realm == null || nonce == null) {
      throw const HikvisionDeviceException(
        message: 'Face ID qurilmasi bilan xavfsiz ulanishni o‘rnatib bo‘lmadi.',
      );
    }

    final qopValues = auth['qop']
        ?.split(',')
        .map((value) => value.trim().toLowerCase())
        .where((value) => value.isNotEmpty)
        .toList();
    final qop = qopValues == null || qopValues.isEmpty
        ? null
        : qopValues.contains('auth')
        ? 'auth'
        : qopValues.first;

    final ha1 = _md5('$username:$realm:$password');
    final ha2 = _md5('$method:$uri');
    final response = qop == null
        ? _md5('$ha1:$nonce:$ha2')
        : _md5('$ha1:$nonce:$nc:$cnonce:$qop:$ha2');

    final fields = <String>[
      'Digest username="$username"',
      'realm="$realm"',
      'nonce="$nonce"',
      'uri="$uri"',
    ];
    if (qop != null) {
      fields.add('qop=$qop');
      fields.add('nc=$nc');
      fields.add('cnonce="$cnonce"');
    }
    final opaque = auth['opaque'];
    if (opaque != null && opaque.isNotEmpty) {
      fields.add('opaque="$opaque"');
    }
    fields.add('response="$response"');
    return fields.join(', ');
  }

  Map<String, dynamic> _decodeAsJson(
    http.Response resp, {
    required String operation,
  }) {
    final text = resp.body.trim();
    if (text.isEmpty) return <String, dynamic>{};

    dynamic decoded;
    try {
      decoded = jsonDecode(text);
    } catch (_) {
      throw HikvisionDeviceException(
        message:
            'Face ID qurilmasi kutilmagan javob qaytardi. Qayta urinib ko‘ring.',
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw HikvisionDeviceException(
        message:
            'Face ID qurilmasi kutilmagan javob qaytardi. Qayta urinib ko‘ring.',
      );
    }

    try {
      throw HikvisionDeviceException.fromPayload(decoded, operation: operation);
    } on StateError {
      return decoded;
    }
  }

  String _md5(String input) =>
      crypto.md5.convert(utf8.encode(input)).toString();

  String _generateClientNonce() {
    final now = DateTime.now();
    final timestamp =
        '${now.microsecond}:${now.millisecond}:${now.second}:'
        '${now.minute}:${now.hour}:${now.day}:${now.month}:${now.year}';
    final sequence = ++_clientNonceSequence;

    // The terminal owns the server `nonce` from WWW-Authenticate. This is
    // the client-owned `cnonce` and must be different for every request.
    // Hashing the timestamp, process-wide sequence, and secure random bytes
    // keeps the value in the 32-hex format accepted by Hikvision terminals.
    return _md5('$timestamp:$sequence:${_randomHex(16)}');
  }

  String _randomHex(int bytes) {
    final rand = Random.secure();
    return List.generate(
      bytes,
      (_) => rand.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
  }

  String _generateSearchId() {
    const alphabet = '0123456789abcdefghijklmnopqrstuvwxyz';
    final rnd = Random();
    final suffix = String.fromCharCodes(
      Iterable.generate(
        9,
        (_) => alphabet.codeUnitAt(rnd.nextInt(alphabet.length)),
      ),
    );
    return 'search-${DateTime.now().millisecondsSinceEpoch}-$suffix';
  }

  Map<String, dynamic> _userInfoSearchBody({
    required int searchResultPosition,
    required int maxResults,
    List<String> employeeNos = const [],
  }) {
    final cond = <String, dynamic>{
      'searchID': _generateSearchId(),
      'searchResultPosition': searchResultPosition,
      'maxResults': maxResults,
    };
    if (employeeNos.isNotEmpty) {
      cond['EmployeeNoList'] = employeeNos
          .map((employeeNo) => <String, dynamic>{'employeeNo': employeeNo})
          .toList();
    }
    return <String, dynamic>{'UserInfoSearchCond': cond};
  }

  static int userInfoSearchTotalMatches(Map<dynamic, dynamic> search) {
    final raw = search['totalMatches'] ?? search['numOfMatches'];
    return int.tryParse(raw?.toString() ?? '') ?? 0;
  }

  static String digestUriForRequest(Uri uri) {
    final query = uri.hasQuery ? '?${uri.query}' : '';
    return '${uri.path}$query';
  }

  static String _normalizeBaseUrl(String rawBaseUrl) {
    final trimmed = rawBaseUrl.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed.endsWith('/')
          ? trimmed.substring(0, trimmed.length - 1)
          : trimmed;
    }
    final withScheme = 'http://$trimmed';
    return withScheme.endsWith('/')
        ? withScheme.substring(0, withScheme.length - 1)
        : withScheme;
  }
}
