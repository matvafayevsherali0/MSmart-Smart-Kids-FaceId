part of 'devices_bloc.dart';

@immutable
sealed class DevicesEvent extends Equatable {
  const DevicesEvent();

  @override
  List<Object?> get props => [];
}

class GetDevicesEvent extends DevicesEvent {
  final String organizationId;
  final String organizationName;

  const GetDevicesEvent({
    required this.organizationId,
    this.organizationName = "",
  });

  @override
  List<Object?> get props => [organizationId, organizationName];
}

class LoadMoreDevicesEvent extends DevicesEvent {
  const LoadMoreDevicesEvent();
}
