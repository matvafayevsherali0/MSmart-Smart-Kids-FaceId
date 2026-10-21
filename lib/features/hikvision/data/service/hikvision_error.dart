import 'dart:convert';

import 'package:http/http.dart' as http;

class HikvisionErrorDetails {
  final int? statusCode;
  final int? errorCode;
  final String? subStatusCode;
  final String? deviceMessage;
  final String? reason;
  final String? lockStatus;
  final int? unlockTime;
  final int? retryLoginTime;

  const HikvisionErrorDetails({
    this.statusCode,
    this.errorCode,
    this.subStatusCode,
    this.deviceMessage,
    this.reason,
    this.lockStatus,
    this.unlockTime,
    this.retryLoginTime,
  });
}

class HikvisionErrorTranslator {
  static const int _invalidFaceModel = 0x4000109B;
  static const int _duplicateLibraryName = 0x4000109C;
  static const int _faceRecordNotFound = 0x4000109D;
  static const int _countFaceRecordsFailed = 0x4000109E;
  static const int _faceThumbnailFailed = 0x4000109F;
  static const int _faceModelingFailed = 0x400010A0;
  static const int _faceComparisonFailed = 0x400010A1;
  static const int _pictureCheckFailed = 0x40001100;
  static const int _pictureModelingFailed = 0x40001101;
  static const int _picturePixelsTooLarge = 0x40001105;
  static const int _picturePixelsTooSmall = 0x40001106;
  static const int _faceLibraryArmed = 0x400010A2;
  static const int _licenseLimit = 0x400010A3;
  static const int _licenseExpired = 0x400010A4;
  static const int _licenseDisabled = 0x400010A5;
  static const int _licenseMissing = 0x400010A6;
  static const int _sessionExpired = 0x400010A7;
  static const int _concurrentLimit = 0x400010A8;
  static const int _addFaceFailed = 0x400010C1;
  static const int _deleteFaceFailed = 0x400010C2;
  static const int _editFaceFailed = 0x400010C3;
  static const int _searchFaceFailed = 0x400010C4;
  static const int _detectFaceFailed = 0x400010C5;
  static const int _faceLibraryMissing = 0x400010C6;
  static const int _diskError = 0x60001009;
  static const int _diskFull = 0x6000100A;
  static const int _faceLibraryBusy = 0x6000100B;
  static const int _capturePacketFailed = 0x6000100C;
  static const int _capturePacketProcessing = 0x6000100D;
  static const int _captureResolutionUnsupported = 0x60000016;
  static const int _captureConflict = 0x60001019;
  static const int _noAnalysisEngine = 0x60001000;
  static const int _analysisEngineOverloaded = 0x60001001;
  static const int _imageAnalysisNoResource = 0x60001002;
  static const int _analysisEngineLoading = 0x60001003;
  static const int _analysisEngineException = 0x60001004;
  static const int _faceLibraryImportFailed = 0x60001005;
  static const int _analysisEngineLinked = 0x60001006;
  static const int _insufficientNetworkBandwidth = 0x6000100F;
  static const int _personDensityConflict = 0x60001013;
  static const int _cameraResolutionInvalid = 0x60001014;
  static const int _timeDifferenceTooLarge = 0x60001016;
  static const int _motionDetectionConflict = 0x60001018;
  static const int _nameAlreadyExists = 0x60008001;
  static const int _wrongPassword = 0x400010E7;
  static const int _invalidIsoTime = 0x400010ED;

  static String userMessage({
    int? statusCode,
    int? errorCode,
    String? subStatusCode,
    String? deviceMessage,
    String? reason,
    String? lockStatus,
    int? unlockTime,
  }) {
    final text = [
      subStatusCode,
      deviceMessage,
      reason,
      lockStatus,
      errorCode?.toString(),
    ].whereType<String>().join(' ').toLowerCase();

    if (lockStatus?.trim().toLowerCase() == 'lock') {
      return 'Face ID qurilmasi vaqtincha bloklangan. Qurilma ochilguncha qayta urinmang.';
    }

    if (_containsAny(text, ['capturetimeout', 'cancelflag'])) {
      return 'Face ID rasmni vaqtida ola olmadi. Qurilma kamerasi qarshisida turing va qayta urinib ko‘ring.';
    }

    switch (errorCode) {
      case _invalidFaceModel:
        return 'Bu rasm Face ID uchun mos emas. Yuz aniq ko‘ringan boshqa rasmni yuboring.';
      case _duplicateLibraryName:
        return 'Face ID yuzlar bazasining bu nomi allaqachon mavjud.';
      case _faceRecordNotFound:
        return 'Face ID qurilmasida kerakli yuz rasmi topilmadi.';
      case _countFaceRecordsFailed:
        return 'Face ID yuzlar bazasidagi ma’lumotlarni o‘qib bo‘lmadi. Qayta urinib ko‘ring.';
      case _faceThumbnailFailed:
        return 'Face ID qurilmasidan yuz rasmini olib bo‘lmadi. Qayta urinib ko‘ring.';
      case _faceModelingFailed:
        return 'Face ID rasmni qayta ishlay olmadi. Yuz aniq ko‘ringan boshqa rasmni yuboring.';
      case _faceComparisonFailed:
        return 'Yuz rasmini taqqoslab bo‘lmadi. Rasmni qayta yuboring.';
      case _pictureCheckFailed:
        return 'Face ID rasmni tekshira olmadi. Yuz aniq ko‘ringan rasm tanlang.';
      case _pictureModelingFailed:
        return 'Face ID rasmni qayta ishlay olmadi. Rasm o‘lchami yoki sifati mos emas.';
      case _picturePixelsTooLarge:
        return 'Rasm o‘lchami Face ID uchun juda katta. Rasm avtomatik moslashtiriladi yoki boshqa rasm tanlang.';
      case _picturePixelsTooSmall:
        return 'Rasm o‘lchami Face ID uchun juda kichik. Yuz aniq ko‘ringan kattaroq rasm tanlang.';
      case _faceLibraryArmed:
        return 'Face ID yuzlar bazasi hozir ishlatilmoqda. Birozdan so‘ng qayta urinib ko‘ring.';
      case _licenseLimit:
        return 'Face ID qurilmasida ruxsat etilgan limit tugagan.';
      case _licenseExpired:
        return 'Face ID qurilmasining litsenziyasi muddati tugagan.';
      case _licenseDisabled:
        return 'Face ID qurilmasining litsenziyasi faol emas.';
      case _licenseMissing:
        return 'Face ID qurilmasi uchun kerakli litsenziya topilmadi.';
      case _sessionExpired:
        return 'Face ID qurilmasi bilan ulanish muddati tugagan. Qayta urinib ko‘ring.';
      case _concurrentLimit:
        return 'Face ID qurilmasida bir vaqtda juda ko‘p amal bajarilmoqda. Birozdan so‘ng qayta urinib ko‘ring.';
      case _addFaceFailed:
        return 'Yuz rasmini Face ID qurilmasiga qo‘shib bo‘lmadi. Qayta urinib ko‘ring.';
      case _deleteFaceFailed:
        return 'Yuz rasmini Face ID qurilmasidan o‘chirib bo‘lmadi. Qayta urinib ko‘ring.';
      case _editFaceFailed:
        return 'Yuz rasmini Face ID qurilmasida yangilab bo‘lmadi. Qayta urinib ko‘ring.';
      case _searchFaceFailed:
        return 'Face ID qurilmasidan yuz rasmini topib bo‘lmadi. Qayta urinib ko‘ring.';
      case _detectFaceFailed:
        return 'Face ID yuzni aniqlay olmadi. Yuzni kameraga to‘g‘ri qarating va qayta urinib ko‘ring.';
      case _faceLibraryMissing:
        return 'Face ID qurilmasida yuzlar bazasi topilmadi. Qurilma sozlamalarini tekshiring.';
      case _diskError:
        return 'Face ID qurilmasi xotirasida xatolik yuz berdi. Qurilmani tekshiring.';
      case _diskFull:
        return 'Face ID qurilmasining xotirasi to‘lib qolgan. Qurilmada bo‘sh joy yarating.';
      case _faceLibraryBusy:
        return 'Face ID yuzlar bazasi band. Birozdan so‘ng qayta urinib ko‘ring.';
      case _capturePacketFailed:
        return 'Face ID qurilmasidan rasm olishda xatolik yuz berdi. Qayta urinib ko‘ring.';
      case _capturePacketProcessing:
        return 'Face ID qurilmasi rasmni qayta ishlayapti. Birozdan so‘ng qayta urinib ko‘ring.';
      case _captureResolutionUnsupported:
        return 'Face ID bu rasm o‘lchamini qo‘llab-quvvatlamaydi. Boshqa rasm bilan urinib ko‘ring.';
      case _captureConflict:
        return 'Face ID qurilmasida yuzni olish funksiyasi band yoki mos emas. Qurilma sozlamalarini tekshiring.';
      case _noAnalysisEngine:
        return 'Face ID qurilmasida rasmni tahlil qiluvchi modul topilmadi.';
      case _analysisEngineOverloaded:
        return 'Face ID qurilmasida rasm tahlili band. Birozdan so‘ng qayta urinib ko‘ring.';
      case _imageAnalysisNoResource:
        return 'Face ID rasmni tahlil qilish uchun resurs yetarli emas. Birozdan so‘ng qayta urinib ko‘ring.';
      case _analysisEngineLoading:
        return 'Face ID rasm tahlili moduli ishga tushmoqda. Birozdan so‘ng qayta urinib ko‘ring.';
      case _analysisEngineException:
        return 'Face ID rasm tahlili modulida xatolik yuz berdi. Qurilmani tekshiring.';
      case _faceLibraryImportFailed:
        return 'Yuz rasmini Face ID bazasiga saqlab bo‘lmadi. Qayta urinib ko‘ring.';
      case _analysisEngineLinked:
        return 'Face ID tahlil moduli boshqa kamera bilan band. Qurilma sozlamalarini tekshiring.';
      case _insufficientNetworkBandwidth:
        return 'Face ID qurilmasi bilan aloqa sifati past. Tarmoqni tekshirib, qayta urinib ko‘ring.';
      case _personDensityConflict:
        return 'Face ID qurilmasida boshqa odamlarni aniqlash funksiyasi yoqilgan. Qurilma sozlamalarini tekshiring.';
      case _cameraResolutionInvalid:
        return 'Kamera o‘lchami Face ID talabiga mos emas. Qurilma sozlamalarini tekshiring.';
      case _timeDifferenceTooLarge:
        return 'Telefon va Face ID qurilmasining vaqti mos emas. Vaqtni sinxronlang.';
      case _motionDetectionConflict:
        return 'Face ID qurilmasida harakatni aniqlash funksiyasi xalaqit bermoqda. Qurilma sozlamalarini tekshiring.';
      case _nameAlreadyExists:
        return 'Bu ism Face ID qurilmasida allaqachon mavjud. Boshqa ism kiriting.';
      case _wrongPassword:
        return 'Face ID qurilmasi paroli noto‘g‘ri. Login va parolni tekshiring.';
      case _invalidIsoTime:
        return 'Face ID qurilmasiga yuborilgan vaqt formati noto‘g‘ri.';
    }

    if (statusCode == 2 || statusCode == 429) {
      return 'Face ID qurilmasi band. Birozdan so‘ng qayta urinib ko‘ring.';
    }
    if (statusCode == 3) {
      return 'Face ID qurilmasida ichki xatolik yuz berdi. Qurilmani tekshirib, qayta urinib ko‘ring.';
    }
    if (statusCode == 4) {
      return 'Face ID qurilmasi bu amalni bajara olmaydi. Qurilma holatini tekshiring.';
    }
    if (statusCode == 5 || statusCode == 6) {
      return 'Face ID qurilmasiga yuborilgan ma’lumot noto‘g‘ri. Qayta urinib ko‘ring.';
    }
    if (statusCode == 7) {
      return 'Face ID qurilmasini qayta ishga tushirish kerak. Qurilmani qayta yoqing.';
    }
    if (statusCode == 9) {
      return 'Face ID qurilmasida qo‘shimcha xatolik yuz berdi. Qayta urinib ko‘ring.';
    }
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

    if (_containsAny(text, ['multiplefaces', 'multiple faces'])) {
      return 'Rasmda bir nechta yuz bor. Faqat bitta yuz tushgan rasmni yuboring.';
    }

    if (_containsAny(text, ['facesizesmall', 'face size small'])) {
      return 'Yuz rasmi juda kichik yoki uzoq tushgan. Yuzni yaqinroq va aniqroq qilib qayta oling.';
    }

    if (_containsAny(text, ['facesizebig', 'face size big'])) {
      return 'Yuz rasmi juda katta tushgan. Yuzni biroz uzoqroq qilib qayta oling.';
    }

    if (_containsAny(text, ['shadeface', 'face is covered', 'face covered'])) {
      return 'Yuzning bir qismi yopilgan. Ko‘zoynak, niqob yoki boshqa to‘siqni olib, qayta oling.';
    }

    if (_containsAny(text, ['imageurldownloadfailed'])) {
      return 'Face ID rasmni yuklay olmadi. Telefon va qurilma tarmog‘ini tekshirib, qayta urinib ko‘ring.';
    }

    if (_containsAny(text, [
      'subpicanalysismodelingerror',
      'savefacepic',
      'picturemodelingfailed',
      'picturecheckfailed',
    ])) {
      return 'Face ID rasmni qayta ishlay olmadi. Rasm o‘lchami yoki sifati mos emas.';
    }

    if (_containsAny(text, ['nojpgpicture'])) {
      return 'Face ID faqat JPG formatidagi rasmni qabul qiladi. Boshqa rasm tanlang.';
    }

    if (_containsAny(text, [
      'errorpictureresolution',
      'image resolution',
      'picture resolution',
    ])) {
      return 'Rasm o‘lchami Face ID talabiga mos emas. Boshqa rasm bilan urinib ko‘ring.';
    }

    if (_containsAny(text, ['analysisfailed'])) {
      return 'Face ID rasmni tahlil qila olmadi. Yuz aniq ko‘ringan rasmni qayta yuboring.';
    }

    if (_containsAny(text, ['diskfull'])) {
      return 'Face ID qurilmasining xotirasi to‘lib qolgan. Qurilmada bo‘sh joy yarating.';
    }

    if (_containsAny(text, ['diskerror'])) {
      return 'Face ID qurilmasi xotirasida xatolik yuz berdi. Qurilmani tekshiring.';
    }

    if (_containsAny(text, [
      'noface',
      'no face',
      'face not detected',
      'face size',
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

    if (statusCode == 400 || statusCode == 422) {
      return 'Face ID qurilmasiga yuborilgan ma’lumot noto‘g‘ri. Qayta urinib ko‘ring.';
    }
    if (statusCode == 404) {
      return 'Face ID qurilmasida kerakli ma’lumot topilmadi.';
    }
    if (statusCode == 408) {
      return 'Face ID qurilmasi javob berishi uchun ko‘p vaqt ketdi. Qayta urinib ko‘ring.';
    }
    if (statusCode == 409) {
      return 'Bu ma’lumot Face ID qurilmasida allaqachon mavjud.';
    }
    if (statusCode == 415) {
      return 'Face ID qurilmasi yuborilgan ma’lumot formatini qabul qilmadi.';
    }

    if (statusCode != null && statusCode >= 500) {
      return 'Face ID qurilmasi vaqtincha javob bermadi. Birozdan so‘ng qayta urinib ko‘ring.';
    }

    return 'Face ID qurilmasida amal bajarilmadi. Qayta urinib ko‘ring.';
  }

  static bool isMissingFaceRecord({
    int? statusCode,
    int? errorCode,
    String? deviceMessage,
    String? reason,
    String? subStatusCode,
  }) {
    if (statusCode == 404 || errorCode == _faceRecordNotFound) return true;
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
    final trimmed = body.trim().replaceFirst('\uFEFF', '');
    if (trimmed.isEmpty) return const HikvisionErrorDetails();

    if (trimmed.startsWith('{')) {
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is Map) {
          final nested = decoded['ResponseStatus'] ?? decoded['responseStatus'];
          final source = nested is Map ? nested : decoded;
          return HikvisionErrorDetails(
            statusCode: _intValue(
              source['statusCode'] ?? source['statusValue'],
            ),
            errorCode: _errorCodeFrom(source),
            subStatusCode: _stringValue(source['subStatusCode']),
            deviceMessage: _firstString(source, const [
              'errorMsg',
              'errorMessage',
              'message',
              'statusString',
            ]),
            reason: _firstString(source, const [
              'reason',
              'responseStatusStrg',
            ]),
            lockStatus: _stringValue(source['lockStatus']),
            unlockTime: _intValue(source['unlockTime']),
            retryLoginTime: _intValue(source['retryLoginTime']),
          );
        }
      } catch (_) {
        // Fall through to the text-based fallback below.
      }
    }

    String? tag(String name) {
      final match = RegExp(
        '<(?:[\\w.-]+:)?$name\\b[^>]*>([\\s\\S]*?)</(?:[\\w.-]+:)?$name>',
        caseSensitive: false,
      ).firstMatch(trimmed);
      return match?.group(1)?.trim();
    }

    return HikvisionErrorDetails(
      statusCode: _intValue(tag('statusCode') ?? tag('statusValue')),
      errorCode: _errorCodeFrom({
        'errorCode': tag('errorCode'),
        'MErrCode': tag('MErrCode'),
        'MErrDevSelfEx': tag('MErrDevSelfEx'),
      }),
      subStatusCode: tag('subStatusCode'),
      deviceMessage: tag('errorMsg') ?? tag('statusString'),
      reason: tag('reason') ?? tag('responseStatusStrg'),
      lockStatus: tag('lockStatus'),
      unlockTime: _intValue(tag('unlockTime')),
      retryLoginTime: _intValue(tag('retryLoginTime')),
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

  static int? _intValue(Object? value) {
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty) return null;
    if (text.toLowerCase().startsWith('0x')) {
      return int.tryParse(text.substring(2), radix: 16);
    }
    return int.tryParse(text);
  }

  static int? _errorCodeFrom(Map<dynamic, dynamic> source) {
    final errorCode = _intValue(source['errorCode']);
    final deviceErrorCode = _firstNonZeroCode([
      source['MErrCode'],
      source['MErrDevSelfEx'],
    ]);
    if (deviceErrorCode != null && (errorCode == null || errorCode == 1)) {
      return deviceErrorCode;
    }
    return errorCode ?? deviceErrorCode;
  }

  static int? _firstNonZeroCode(List<Object?> values) {
    for (final value in values) {
      final code = _intValue(value);
      if (code != null && code != 0) return code;
    }
    return null;
  }

  static bool _containsAny(String text, List<String> values) {
    return values.any(text.contains);
  }
}

class HikvisionDeviceException implements Exception {
  final String message;
  final int? statusCode;
  final int? errorCode;
  final bool isMissingFaceRecord;
  final String? lockStatus;
  final int? unlockTime;

  const HikvisionDeviceException({
    required this.message,
    this.statusCode,
    this.errorCode,
    this.isMissingFaceRecord = false,
    this.lockStatus,
    this.unlockTime,
  });

  factory HikvisionDeviceException.fromResponse(
    http.Response response, {
    required String operation,
  }) {
    final details = HikvisionErrorTranslator.parseBody(response.body);
    final statusCode = response.statusCode >= 400
        ? response.statusCode
        : details.statusCode ?? response.statusCode;
    final deviceMessage = details.deviceMessage ?? response.reasonPhrase;
    return HikvisionDeviceException(
      message: HikvisionErrorTranslator.userMessage(
        statusCode: statusCode,
        errorCode: details.errorCode,
        subStatusCode: details.subStatusCode,
        deviceMessage: deviceMessage,
        reason: details.reason,
        lockStatus: details.lockStatus,
        unlockTime: details.unlockTime,
      ),
      statusCode: statusCode,
      errorCode: details.errorCode,
      isMissingFaceRecord: HikvisionErrorTranslator.isMissingFaceRecord(
        statusCode: statusCode,
        errorCode: details.errorCode,
        deviceMessage: deviceMessage,
        reason: details.reason,
        subStatusCode: details.subStatusCode,
      ),
      lockStatus: details.lockStatus,
      unlockTime: details.unlockTime,
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
        lockStatus: details.lockStatus,
        unlockTime: details.unlockTime,
      ),
      statusCode: statusCode,
      errorCode: errorCode,
      isMissingFaceRecord: HikvisionErrorTranslator.isMissingFaceRecord(
        statusCode: statusCode,
        errorCode: errorCode,
        deviceMessage: details.deviceMessage,
        reason: details.reason,
        subStatusCode: details.subStatusCode,
      ),
      lockStatus: details.lockStatus,
      unlockTime: details.unlockTime,
    );
  }

  static bool _isSuccessCode(int code) => code == 1 || code == 200;

  @override
  String toString() => message;
}
