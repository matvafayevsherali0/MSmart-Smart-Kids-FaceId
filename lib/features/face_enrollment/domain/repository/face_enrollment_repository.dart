import '../../../../core/exceptions/failures.dart';
import '../../../../core/utils/either.dart';

abstract class FaceEnrollmentRepository {
  Future<Either<Failure, List<int>>> downloadFaceImageBytes(
    String relativeOrAbsoluteUrl,
  );

  Future<Either<Failure, String>> uploadFaceImageBytes(List<int> bytes);

  Future<Either<Failure, String>> enrollFromDevice({
    required String? studentId,
    required String? staffId,
    required String faceImageId,
    required String organizationId,
    required String deviceId,
  });

  Future<Either<Failure, String?>> findFaceEnrollmentId({
    required String ownerType,
    required String ownerId,
    required String organizationId,
  });

  Future<Either<Failure, void>> updateFaceEnrollment({
    required String id,
    required String faceImageId,
  });

  Future<Either<Failure, void>> updateDeviceSync({
    required String faceEnrollmentId,
    required String deviceId,
    required bool isSynced,
    String? errorMessage,
  });

  Future<Either<Failure, void>> deleteFaceEnrollment(String id);
}
