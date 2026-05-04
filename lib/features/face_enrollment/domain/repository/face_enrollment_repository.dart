
import '../../../../core/exceptions/failures.dart';
import '../../../../core/utils/either.dart';

abstract class FaceEnrollmentRepository {

  Future<Either<Failure, String>> uploadFaceImageBytes(List<int> bytes);

  Future<Either<Failure, void>> enrollFromDevice({
    required String? studentId,
    required String? staffId,
    required String faceImageId,
    required String organizationId,
    required String deviceId,
  });
}
