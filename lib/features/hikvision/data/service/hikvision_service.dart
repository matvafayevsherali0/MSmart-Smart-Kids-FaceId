import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart' as crypto;
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import '../../domain/entity/hikvision_user.dart';
import '../../domain/entity/hikvision_user_search_result.dart';

class HikvisionService {
  String baseUrl;
  String username;
  String password;

  HikvisionService({
    required String baseUrl,
    required this.username,
    required this.password,
  }) : baseUrl = _normalizeBaseUrl(baseUrl);

  void updateConnection({
    required String baseUrl,
    required String username,
    required String password,
  }) {
    this.baseUrl = _normalizeBaseUrl(baseUrl);
    this.username = username;
    this.password = password;
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

    final body = jsonEncode(_userInfoSearchBody(
      searchResultPosition: 0,
      maxResults: 1,
      employeeNos: [emp],
    ));

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

    final body = jsonEncode(_userInfoSearchBody(
      searchResultPosition: searchResultPosition,
      maxResults: maxResults,
    ));

    final jsonMap = await postJsonWithDigest(uri, body);
    final search = jsonMap['UserInfoSearch'];
    if (search is! Map) {
      return const HikvisionUserSearchResult(totalMatches: 0, users: []);
    }

    final totalMatches = _userInfoSearchNumMatches(search);
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
      'searchResultPosition': 0,
      'maxResults': 1,
      'FDID': '1',
      'FPID': emp,
      'faceLibType': 'blackFD',
    });

    final jsonMap = await postJsonWithDigest(uri, body);

    final matchList = jsonMap['MatchList'];
    if (matchList is List && matchList.isNotEmpty) {
      final first = matchList.first;
      if (first is Map) return first['faceURL']?.toString();
    }

    final faceInfoSearch = jsonMap['FaceInfoSearch'];
    if (faceInfoSearch is Map) {
      final ml = faceInfoSearch['MatchList'];
      if (ml is List && ml.isNotEmpty) {
        final first = ml.first;
        if (first is Map) return first['faceURL']?.toString();
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
      throw Exception('Hikvision GET ${response.statusCode}: ${response.body}');
    }
    return response.bodyBytes;
  }

  Future<String> captureFaceUrl() async {
    final uri = Uri.parse('$baseUrl/ISAPI/AccessControl/CaptureFaceData');

    const body = '''
<CaptureFaceDataCond version="2.0" xmlns="http://www.isapi.org/ver20/XMLSchema">
  <captureInfrared>false</captureInfrared>
  <dataType>url</dataType>
</CaptureFaceDataCond>
''';

    final response = await _sendAuthorizedRequest(
      'POST',
      uri,
      headers: {'Content-Type': 'application/xml', 'Accept': '*/*'},
      body: body,
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Hikvision ${response.statusCode}: ${response.body}');
    }
    return _parseFaceDataUrl(response.body);
  }

  String _parseFaceDataUrl(String xml) {
    final reg = RegExp(r'<faceDataUrl>([^<]+)</faceDataUrl>');
    final match = reg.firstMatch(xml);
    if (match == null) {
      throw Exception('faceDataUrl topilmadi: $xml');
    }
    return match.group(1)!;
  }

  Future<Map<String, dynamic>> addFaceByUrl({
    required String employeeNo,
    required String faceUrl,
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
    });
    return postJsonWithDigest(uri, body);
  }

  Future<Map<String, dynamic>> deleteUser(String employeeNo) async {
    final emp = normalizeEmployeeNoForIsapi(employeeNo);
    if (emp.isEmpty) {
      throw Exception('employeeNo bo‘sh — o‘chirish yuborilmaydi.');
    }

    final uri = Uri.parse(
      '$baseUrl/ISAPI/AccessControl/UserInfo/Delete?format=json',
    );
    final body = jsonEncode({
      'UserInfoDelCond': {
        'EmployeeNoList': [
          {'employeeNo': emp},
        ],
      },
    });
    return putJsonWithDigest(uri, body);
  }

  Future<Map<String, dynamic>> deleteUsersBatch(
    List<String> employeeNos,
  ) async {
    if (employeeNos.isEmpty) return <String, dynamic>{};
    final uri = Uri.parse(
      '$baseUrl/ISAPI/AccessControl/UserInfo/Delete?format=json',
    );
    final body = jsonEncode({
      'UserInfoDelCond': {
        'EmployeeNoList': employeeNos
            .map((e) => {'employeeNo': normalizeEmployeeNoForIsapi(e)})
            .toList(),
      },
    });
    return putJsonWithDigest(uri, body);
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
    final customTime = DateTime(now.year, now.month, now.day, (now.hour > 0 ? now.hour - 1 : 0), now.minute, now.second);
    final beginTime = fmt(customTime);
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

    final body = jsonEncode({
      'UserInfo': {
        'employeeNo': emp,
        'name': name,
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

  Future<Map<String, dynamic>> postJsonWithDigest(Uri uri, String body) async {
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
      throw Exception('Hikvision ${response.statusCode}: ${response.body}');
    }
    return _decodeAsJson(response);
  }

  Future<Map<String, dynamic>> putJsonWithDigest(Uri uri, String body) async {
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
      throw Exception('Hikvision ${response.statusCode}: ${response.body}');
    }
    return _decodeAsJson(response);
  }

  static const Duration _connectTimeout = Duration(seconds: 20);
  static const Duration _bodyTimeout = Duration(seconds: 45);

  Future<http.Response> _sendAuthorizedRequest(
    String method,
    Uri uri, {
    Map<String, String>? headers,
    String? body,
  }) async {
    final client = _createIoClient();
    try {
      final initialResponse = await _sendRawRequest(
        client,
        method,
        uri,
        headers: headers,
        body: body,
      ).timeout(_connectTimeout + _bodyTimeout);

      if (initialResponse.statusCode != 401) {
        return initialResponse;
      }

      final authHeader = initialResponse.headers['www-authenticate'];
      if (authHeader == null || !authHeader.startsWith('Digest')) {
        throw Exception('WWW-Authenticate Digest emas: $authHeader');
      }

      final digest = _parseDigest(authHeader);
      final cnonce = _randomHex(16);
      const nc = '00000001';
      final digestHeader = _buildDigestHeader(
        username: username,
        password: password,
        method: method,
        uri: uri.path,
        auth: digest,
        nc: nc,
        cnonce: cnonce,
      );

      final authorizedHeaders = <String, String>{
        if (headers != null) ...headers,
        'Authorization': digestHeader,
      };

      return await _sendRawRequest(
        client,
        method,
        uri,
        headers: authorizedHeaders,
        body: body,
      ).timeout(_connectTimeout + _bodyTimeout);
    } on TimeoutException {
      throw Exception(
        "Hikvision so'rov timeout bo'ldi. URL: $uri "
        "(telefon va kamera bir xil Wi-Fi tarmog'ida ekanini tekshiring)",
      );
    } on SocketException catch (e) {
      throw Exception(
        'Hikvision tarmoq xatosi: ${e.message}. URL: $uri',
      );
    } on http.ClientException catch (e) {
      throw Exception('Hikvision ulanish xatosi: ${e.message}. URL: $uri');
    } finally {
      client.close();
    }
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
    }

    final streamedResponse = await client.send(request);
    return http.Response.fromStream(streamedResponse).timeout(_bodyTimeout);
  }

  Map<String, String> _parseDigest(String header) {
    final regex = RegExp("(\\w+)=[\"']?([^\"',]+)[\"']?");
    final result = <String, String>{};
    for (final match in regex.allMatches(header)) {
      final key = match.group(1);
      final value = match.group(2);
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
    final ha1 = _md5('$username:${auth['realm']}:$password');
    final ha2 = _md5('$method:$uri');
    final response = _md5(
      '$ha1:${auth['nonce']}:$nc:$cnonce:${auth['qop']}:$ha2',
    );

    return 'Digest username="$username", '
        'realm="${auth['realm']}", '
        'nonce="${auth['nonce']}", '
        'uri="$uri", '
        'qop=${auth['qop']}, '
        'nc=$nc, '
        'cnonce="$cnonce", '
        'response="$response"';
  }

  Map<String, dynamic> _decodeAsJson(http.Response resp) {
    final ct = resp.headers['content-type'] ?? '';
    final text = resp.body;

    try {
      final decoded = jsonDecode(text);
      if (decoded is Map<String, dynamic>) return decoded;
      throw Exception('JSON Map emas: $decoded');
    } catch (_) {
      throw Exception('JSON parse bo‘lmadi. content-type=$ct, body=$text');
    }
  }

  String _md5(String input) =>
      crypto.md5.convert(utf8.encode(input)).toString();

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

  static int _userInfoSearchNumMatches(Map<dynamic, dynamic> search) {
    final raw = search['numOfMatches'] ?? search['totalMatches'];
    return int.tryParse(raw?.toString() ?? '') ?? 0;
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
