import 'package:equatable/equatable.dart';

import '../../../common/data/data/meta_info.dart';
import 'device.dart';

class Devices extends Equatable {
  final List<Device> devices;
  final MetaInfo meta;

  const Devices({this.devices = const [], this.meta = const MetaInfo()});

  @override
  List<Object?> get props => [devices, meta];
}
