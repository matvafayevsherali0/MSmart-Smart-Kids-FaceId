import '../../../../core/exceptions/failures.dart';
import '../../../../core/utils/either.dart';
import '../entity/hikvision_user.dart';
import '../entity/hikvision_user_search_result.dart';

abstract class HikvisionRepository {
  Future<Either<Failure, HikvisionUser?>> getUserByEmployeeNo(
    String employeeNo,
  );
  Future<Either<Failure, void>> createUser({
    required String employeeNo,
    required String name,
  });
  Future<Either<Failure, HikvisionUserSearchResult>> searchUsers({
    int searchResultPosition,
    int maxResults,
  });
  Future<Either<Failure, String?>> getFaceUrlByEmployeeNo(String employeeNo);
  Future<Either<Failure, List<int>>> downloadBytesWithDigest(Uri uri);
  Future<Either<Failure, String>> captureFaceUrl();
  Future<Either<Failure, List<int>>> captureFaceBytes();
  Future<Either<Failure, void>> upsertFaceByBytes({
    required String employeeNo,
    required List<int> imageBytes,
    required String name,
  });
  Future<Either<Failure, void>> addFaceByUrl({
    required String employeeNo,
    required String faceUrl,
    required String name,
  });
  Future<Either<Failure, void>> upsertFaceByUrl({
    required String employeeNo,
    required String faceUrl,
    required String name,
  });
  Future<Either<Failure, void>> deleteUser(String employeeNo);
  Future<Either<Failure, void>> deleteUsersBatch(List<String> employeeNos);
}
