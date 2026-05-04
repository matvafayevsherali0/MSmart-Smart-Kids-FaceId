import '../../../../core/exceptions/failures.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entity/hikvision_user.dart';
import '../../domain/entity/hikvision_user_search_result.dart';
import '../../domain/repository/hikvision_repository.dart';
import '../data_source/hikvision_data_source.dart';

class HikvisionRepositoryImpl extends HikvisionRepository {
  final HikvisionRemoteDataSource _remote;

  HikvisionRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, HikvisionUser?>> getUserByEmployeeNo(String employeeNo) async {
    try {
      final user = await _remote.getUserByEmployeeNo(employeeNo);
      return Right(user);
    } catch (e) {
      return Left(AppFailure(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createUser({required String employeeNo, required String name}) async {
    try {
      await _remote.createUser(employeeNo: employeeNo, name: name);
      return Right(null);
    } catch (e) {
      return Left(AppFailure(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failure, HikvisionUserSearchResult>> searchUsers({int searchResultPosition = 0, int maxResults = 30}) async {
    try {
      final res = await _remote.searchUsers(searchResultPosition: searchResultPosition, maxResults: maxResults);
      return Right(res);
    } catch (e) {
      return Left(AppFailure(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String?>> getFaceUrlByEmployeeNo(String employeeNo) async {
    try {
      final url = await _remote.getFaceUrlByEmployeeNo(employeeNo);
      return Right(url);
    } catch (e) {
      return Left(AppFailure(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<int>>> downloadBytesWithDigest(Uri uri) async {
    try {
      final bytes = await _remote.downloadBytesWithDigest(uri);
      return Right(bytes);
    } catch (e) {
      return Left(AppFailure(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> captureFaceUrl() async {
    try {
      final url = await _remote.captureFaceUrl();
      return Right(url);
    } catch (e) {
      return Left(AppFailure(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addFaceByUrl({required String employeeNo, required String faceUrl}) async {
    try {
      await _remote.addFaceByUrl(employeeNo: employeeNo, faceUrl: faceUrl);
      return Right(null);
    } catch (e) {
      return Left(AppFailure(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUser(String employeeNo) async {
    try {
      await _remote.deleteUser(employeeNo);
      return Right(null);
    } catch (e) {
      return Left(AppFailure(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUsersBatch(List<String> employeeNos) async {
    try {
      await _remote.deleteUsersBatch(employeeNos);
      return Right(null);
    } catch (e) {
      return Left(AppFailure(errorMessage: e.toString()));
    }
  }
}
