import '../../../../core/exceptions/failures.dart';
import '../../../../core/utils/either.dart';
import '../../domain/repository/face_enrollment_repository.dart';
import '../data_source/face_enrollment_data_source.dart';

class FaceEnrollmentRepositoryImpl implements FaceEnrollmentRepository {
  final FaceEnrollmentRemoteDataSource _remote;

  FaceEnrollmentRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, String>> uploadFaceImageBytes(List<int> bytes) async {
    try {
      final id = await _remote.uploadFaceImage(bytes);
      return Right(id);
    } catch (e) {
      return Left(AppFailure(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> enrollFromDevice({
    required String? studentId,
    required String? staffId,
    required String faceImageId,
    required String organizationId,
    required String deviceId,
  }) async {
    try {
      await _remote.enrollFromDevice(
        studentId: studentId,
        staffId: staffId,
        faceImageId: faceImageId,
        organizationId: organizationId,
        deviceId: deviceId,
      );
      return Right(null);
    } catch (e) {
      return Left(AppFailure(errorMessage: e.toString()));
    }
  }
}
