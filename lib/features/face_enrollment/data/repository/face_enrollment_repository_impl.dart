import '../../../../core/exceptions/failures.dart';
import '../../../../core/utils/either.dart';
import '../../domain/repository/face_enrollment_repository.dart';
import '../data_source/face_enrollment_data_source.dart';

class FaceEnrollmentRepositoryImpl implements FaceEnrollmentRepository {
  final FaceEnrollmentRemoteDataSource _remote;

  FaceEnrollmentRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, List<int>>> downloadFaceImageBytes(
    String relativeOrAbsoluteUrl,
  ) async {
    try {
      final bytes = await _remote.downloadFaceImageBytes(relativeOrAbsoluteUrl);
      return Right(bytes);
    } catch (e) {
      return Left(AppFailure(errorMessage: e.toString()));
    }
  }

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
  Future<Either<Failure, String>> enrollFromDevice({
    required String? studentId,
    required String? staffId,
    required String faceImageId,
    required String organizationId,
    required String deviceId,
  }) async {
    try {
      final id = await _remote.enrollFromDevice(
        studentId: studentId,
        staffId: staffId,
        faceImageId: faceImageId,
        organizationId: organizationId,
        deviceId: deviceId,
      );
      return Right(id);
    } catch (e) {
      return Left(AppFailure(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String?>> findFaceEnrollmentId({
    required String ownerType,
    required String ownerId,
    required String organizationId,
  }) async {
    try {
      final id = await _remote.findFaceEnrollmentId(
        ownerType: ownerType,
        ownerId: ownerId,
        organizationId: organizationId,
      );
      return Right(id);
    } catch (e) {
      return Left(AppFailure(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateFaceEnrollment({
    required String id,
    required String faceImageId,
  }) async {
    try {
      await _remote.updateFaceEnrollment(id: id, faceImageId: faceImageId);
      return Right(null);
    } catch (e) {
      return Left(AppFailure(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateDeviceSync({
    required String faceEnrollmentId,
    required String deviceId,
    required bool isSynced,
    String? errorMessage,
  }) async {
    try {
      await _remote.updateDeviceSync(
        faceEnrollmentId: faceEnrollmentId,
        deviceId: deviceId,
        isSynced: isSynced,
        errorMessage: errorMessage,
      );
      return Right(null);
    } catch (e) {
      return Left(AppFailure(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteFaceEnrollment(String id) async {
    try {
      await _remote.deleteFaceEnrollment(id);
      return Right(null);
    } catch (e) {
      return Left(AppFailure(errorMessage: e.toString()));
    }
  }
}
