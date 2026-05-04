import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../../core/utils/service_locator.dart';
import '../../data/data/device.dart';
import '../../domain/repository/devices_repository.dart';

part 'devices_event.dart';
part 'devices_state.dart';

class DevicesBloc extends Bloc<DevicesEvent, DevicesState> {
  final _devicesRepository = serviceLocator<DevicesRepository>();

  DevicesBloc() : super(DevicesState()) {
    on<GetDevicesEvent>(_onGetDevices);
    on<LoadMoreDevicesEvent>(_onLoadMoreDevices);
  }

  FutureOr<void> _onGetDevices(GetDevicesEvent event, Emitter<DevicesState> emit) async {
    try {
      emit(
        state.copyWith(
          organizationId: event.organizationId,
          organizationName: event.organizationName,
          devicesData: const DevicesDataLoading(),
        ),
      );

      final result = await _devicesRepository.getDevices(organizationId: event.organizationId, page: 1);

      if (result.isRight) {
        final devices = result.right;
        final currentPage = devices.meta.page == 0 ? 1 : devices.meta.page;

        emit(
          state.copyWith(
            devicesData: DevicesDataContent(
              devices: devices.devices,
              page: currentPage,
              hasMore: devices.meta.totalPages > currentPage,
            ),
          ),
        );
      } else {
        emit(state.copyWith(devicesData: DevicesDataMessageContent(content: """"${result.left}""")));
      }
    } catch (e) {
      emit(state.copyWith(devicesData: DevicesDataMessageContent(content: """$e""")));
    }
  }

  FutureOr<void> _onLoadMoreDevices(LoadMoreDevicesEvent event, Emitter<DevicesState> emit) async {
    final current = state.devicesData;
    if (current is! DevicesDataContent) return;
    if (current.isLoadingMore || !current.hasMore || state.organizationId.isEmpty) return;

    emit(state.copyWith(devicesData: current.copyWith(isLoadingMore: true)));

    try {
      final nextPage = current.page + 1;
      final result = await _devicesRepository.getDevices(organizationId: state.organizationId, page: nextPage);

      if (result.isRight) {
        final devices = result.right;
        if (devices.devices.isEmpty) {
          emit(state.copyWith(devicesData: current.copyWith(isLoadingMore: false, hasMore: false)));
          return;
        }

        final currentPage = devices.meta.page == 0 ? nextPage : devices.meta.page;
        emit(
          state.copyWith(
            devicesData: current.copyWith(
              devices: [...current.devices, ...devices.devices],
              page: currentPage,
              isLoadingMore: false,
              hasMore: devices.meta.totalPages > currentPage,
            ),
          ),
        );
      } else {
        emit(state.copyWith(devicesData: current.copyWith(isLoadingMore: false)));
      }
    } catch (_) {
      emit(state.copyWith(devicesData: current.copyWith(isLoadingMore: false)));
    }
  }
}
