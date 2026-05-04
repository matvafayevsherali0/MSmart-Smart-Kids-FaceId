import '../../../../core/exceptions/failures.dart';
import '../../../../core/utils/either.dart';
import '../../domain/mapper/devices_mapper.dart';
import '../../domain/repository/devices_repository.dart';
import '../data/devices.dart';
import '../data_source/devices_data_source.dart';

class DevicesRepositoryImpl extends DevicesRepository {
  final DevicesRemoteDataSource _dataSource;
  final DevicesMapper _mapper;

  DevicesRepositoryImpl(this._dataSource, this._mapper);

  @override
  Future<Either<Failure, Devices>> getDevices({
    required String organizationId,
    required int page,
  }) async {
    try {
      final response = await _dataSource.getDevices(
        organizationId: organizationId,
        page: page,
      );
      final devices = _mapper.mapDevicesResponseToDevice(response);
      return Right(devices);
    } catch (e) {
      return Left(AppFailure(errorMessage: """$e"""));
    }
  }
}
