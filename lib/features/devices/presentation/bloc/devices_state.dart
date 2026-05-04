part of 'devices_bloc.dart';

@immutable
class DevicesState extends Equatable {
  final String organizationId;
  final String organizationName;
  final DevicesDataState devicesData;

  const DevicesState({this.organizationId = "", this.organizationName = "", this.devicesData = const DevicesDataContent()});

  DevicesState copyWith({String? organizationId, String? organizationName, DevicesDataState? devicesData}) {
    return DevicesState(
      organizationId: organizationId ?? this.organizationId,
      organizationName: organizationName ?? this.organizationName,
      devicesData: devicesData ?? this.devicesData,
    );
  }

  @override
  List<Object?> get props => [organizationId, organizationName, devicesData];
}

sealed class DevicesDataState extends Equatable {
  const DevicesDataState();

  @override
  List<Object?> get props => [];
}

class DevicesDataContent extends DevicesDataState {
  final List<Device> devices;
  final bool isLoadingMore;
  final bool hasMore;
  final int page;

  const DevicesDataContent({this.devices = const [], this.isLoadingMore = false, this.hasMore = false, this.page = 1});

  DevicesDataContent copyWith({List<Device>? devices, bool? isLoadingMore, bool? hasMore, int? page}) {
    return DevicesDataContent(
      devices: devices ?? this.devices,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
    );
  }

  @override
  List<Object?> get props => [devices, isLoadingMore, hasMore, page];
}

class DevicesDataLoading extends DevicesDataState {
  const DevicesDataLoading();
}

class DevicesDataMessageContent extends DevicesDataState {
  final String content;

  const DevicesDataMessageContent({this.content = ""});

  @override
  List<Object?> get props => [content];
}
