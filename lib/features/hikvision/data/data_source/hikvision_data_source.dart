import '../../domain/entity/hikvision_user.dart';
import '../../domain/entity/hikvision_user_search_result.dart';
import '../service/hikvision_service.dart';

abstract class HikvisionRemoteDataSource {
  Future<HikvisionUser?> getUserByEmployeeNo(String employeeNo);
  Future<void> createUser({required String employeeNo, required String name});
  Future<HikvisionUserSearchResult> searchUsers({int searchResultPosition, int maxResults});
  Future<String?> getFaceUrlByEmployeeNo(String employeeNo);
  Future<List<int>> downloadBytesWithDigest(Uri uri);
  Future<String> captureFaceUrl();
  Future<void> addFaceByUrl({required String employeeNo, required String faceUrl});
  Future<void> deleteUser(String employeeNo);
  Future<void> deleteUsersBatch(List<String> employeeNos);
}

class HikvisionRemoteDataSourceImpl extends HikvisionRemoteDataSource {
  final HikvisionService _service;

  HikvisionRemoteDataSourceImpl(this._service);

  @override
  Future<HikvisionUser?> getUserByEmployeeNo(String employeeNo) {
    return _service.getUserByEmployeeNo(employeeNo);
  }

  @override
  Future<void> createUser({required String employeeNo, required String name}) {
    return _service.createUser(employeeNo: employeeNo, name: name);
  }

  @override
  Future<HikvisionUserSearchResult> searchUsers({
    int searchResultPosition = 0,
    int maxResults = 30,
  }) {
    return _service.searchUsers(
      searchResultPosition: searchResultPosition,
      maxResults: maxResults,
    );
  }

  @override
  Future<String?> getFaceUrlByEmployeeNo(String employeeNo) {
    return _service.getFaceUrlByEmployeeNo(employeeNo);
  }

  @override
  Future<List<int>> downloadBytesWithDigest(Uri uri) {
    return _service.downloadBytesWithDigest(uri);
  }

  @override
  Future<String> captureFaceUrl() {
    return _service.captureFaceUrl();
  }

  @override
  Future<void> addFaceByUrl({required String employeeNo, required String faceUrl}) async {
    await _service.addFaceByUrl(employeeNo: employeeNo, faceUrl: faceUrl);
  }

  @override
  Future<void> deleteUser(String employeeNo) async {
    await _service.deleteUser(employeeNo);
  }

  @override
  Future<void> deleteUsersBatch(List<String> employeeNos) async {
    await _service.deleteUsersBatch(employeeNos);
  }
}

