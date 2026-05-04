import '../../../../core/exceptions/failures.dart';
import '../../../../core/utils/either.dart';
import '../../data/data/devices.dart';

abstract class DevicesRepository {
  Future<Either<Failure, Devices>> getDevices({required String organizationId, required int page});
}
