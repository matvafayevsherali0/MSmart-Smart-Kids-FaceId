import '../../../common/data/data/meta_info.dart';
import '../../data/data/device.dart';
import '../../data/data/devices.dart';
import '../entity/devices_response.dart';

class DevicesMapper {
  Devices mapDevicesResponseToDevice(DevicesResponse res) {
    final data = res.data;
    final metaRes = data.meta;
    final devices = (data.items)
        .map(
          (e) => Device(
            id: e.id,
            name: e.name,
            macAddress: e.macAddress,
            serialNumber: e.serialNumber,
            ipAddress: e.ipAddress,
            port: e.port,
            direction: e.direction,
            locationDescription: e.locationDescription,
            organizationId: e.organizationId,
            username: e.username,
            password: e.password,
            status: e.status,
            isActive: e.isActive,
          ),
        )
        .toList();

    return Devices(
      devices: devices,
      meta: MetaInfo(
        total: metaRes.total ?? 0,
        page: metaRes.page ?? 0,
        limit: metaRes.limit ?? 0,
        totalPages: metaRes.totalPages ?? 0,
      ),
    );
  }
}
