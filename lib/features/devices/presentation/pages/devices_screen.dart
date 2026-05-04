import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/navigation/router.dart';
import '../../../../assets/colors/colors.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../data/data/device.dart';

import '../bloc/devices_bloc.dart';

class DevicesScreen extends StatefulWidget {
  final String organizationId;
  final String organizationName;

  const DevicesScreen({
    super.key,
    required this.organizationId,
    this.organizationName = "",
  });

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    context.read<DevicesBloc>().add(
      GetDevicesEvent(
        organizationId: widget.organizationId,
        organizationName: widget.organizationName,
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final bloc = context.read<DevicesBloc>();
    final current = bloc.state.devicesData;
    if (current is! DevicesDataContent) return;
    if (!current.hasMore || current.isLoadingMore) return;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      bloc.add(const LoadMoreDevicesEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DevicesBloc, DevicesState>(
      builder: (context, state) {
        final data = state.devicesData;
        final title = widget.organizationName.isNotEmpty
            ? widget.organizationName
            : state.organizationName.isNotEmpty
            ? state.organizationName
            : "Qurilmalar";

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            title: Text(
              title,
              style: context.textTheme.bodyMedium!.copyWith(
                color: cBlack,
                fontSize: 16.sp,
              ),
            ),
            centerTitle: true,
          ),
          backgroundColor: cWhite,
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Builder(
              builder: (context) {
                if (data is DevicesDataLoading) {
                  return Center(
                    child: SizedBox(
                      width: 20.sp,
                      height: 20.sp,
                      child: CircularProgressIndicator(color: cBlack, strokeWidth: 2,),
                    ),
                  );
                }

                if (data is DevicesDataMessageContent) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          data.content.isEmpty
                              ? "Qurilmalarni yuklab bo'lmadi"
                              : data.content,
                          textAlign: TextAlign.center,
                          style: context.textTheme.bodyMedium!.copyWith(
                            color: cBlack,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        TextButton(
                          onPressed: () {
                            context.read<DevicesBloc>().add(
                              GetDevicesEvent(
                                organizationId: widget.organizationId,
                                organizationName: widget.organizationName,
                              ),
                            );
                          },
                          child: Text(
                            "Qayta urinish",
                            style: context.textTheme.bodyMedium!.copyWith(
                              color: cBlue,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (data is DevicesDataContent) {
                  if (data.devices.isEmpty) {
                    return Center(
                      child: Text(
                        "Qurilmalar topilmadi",
                        style: context.textTheme.bodyMedium!.copyWith(
                          color: cBlack,
                          fontSize: 14.sp,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    itemCount:
                        data.devices.length + (data.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= data.devices.length) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          child: Center(
                            child: SizedBox(
                              width: 18.sp,
                              height: 18.sp,
                              child: CircularProgressIndicator(color: cBlack, strokeWidth: 2,),
                            ),
                          ),
                        );
                      }

                      final device = data.devices[index];
                      return _DeviceCard(
                        device: device,
                        organizationId: widget.organizationId,
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        );
      },
    );
  }
}

String _hikvisionBaseUrlForDevice(Device device) {
  final host = device.port > 0
      ? '${device.ipAddress}:${device.port}'
      : device.ipAddress;
  if (host.startsWith('http://') || host.startsWith('https://')) {
    return host.endsWith('/') ? host.substring(0, host.length - 1) : host;
  }
  return 'http://$host';
}

class _DeviceCard extends StatelessWidget {
  final Device device;
  final String organizationId;

  const _DeviceCard({
    required this.device,
    required this.organizationId,
  });

  @override
  Widget build(BuildContext context) {
    final statusText = device.status.isNotEmpty
        ? device.status
        : device.isActive
        ? "active"
        : "inactive";
    final ipText = device.port > 0
        ? "${device.ipAddress}:${device.port}"
        : device.ipAddress;

    return InkWell(
      onTap: () {
        context.push(
          AppRoutes.categorySelection,
          extra: {
            'hikvisionBaseUrl': _hikvisionBaseUrlForDevice(device),
            'hikvisionUsername': device.username,
            'hikvisionPassword': device.password,
            'organizationId': organizationId,
            'deviceId': device.id,
          },
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: cGrey.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: cGrey.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    device.name.isNotEmpty ? device.name : "Nomsiz qurilma",
                    style: context.textTheme.bodyMedium!.copyWith(
                      color: cBlack,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _StatusChip(text: statusText, isActive: device.isActive),
              ],
            ),
            if (ipText.isNotEmpty) ...[
              SizedBox(height: 10.h),
              _DeviceInfoRow(icon: Icons.dns_outlined, text: ipText),
            ],
            if (device.serialNumber.isNotEmpty) ...[
              SizedBox(height: 8.h),
              _DeviceInfoRow(
                icon: Icons.qr_code_2_outlined,
                text: device.serialNumber,
              ),
            ],
            if (device.locationDescription.isNotEmpty) ...[
              SizedBox(height: 8.h),
              _DeviceInfoRow(
                icon: Icons.location_on_outlined,
                text: device.locationDescription,
              ),
            ],
            if (device.username.isNotEmpty) ...[
              SizedBox(height: 8.h),
              _DeviceInfoRow(icon: Icons.person_outline, text: device.username),
            ],
            if (device.password.isNotEmpty) ...[
              SizedBox(height: 8.h),
              _DeviceInfoRow(
                icon: Icons.compare_arrows_outlined,
                text: device.password,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DeviceInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _DeviceInfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: cBlue),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: context.textTheme.bodyMedium!.copyWith(
              color: cBlack,
              fontSize: 13.sp,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String text;
  final bool isActive;

  const _StatusChip({required this.text, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isActive
        ? cGreen.withValues(alpha: 0.15)
        : cRed.withValues(alpha: 0.15);
    final foregroundColor = isActive ? cGreen : cRed;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        text,
        style: context.textTheme.bodySmall!.copyWith(
          color: foregroundColor,
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
