import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:msmart_kids_faceid/assets/theme/theme_extensions.dart';

import '../../../../assets/colors/colors.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/utils/service_locator.dart';
import '../../data/service/hikvision_service.dart';
import '../../domain/entity/hikvision_user.dart';
import '../bloc/hikvision_bloc.dart';

class HikvisionScreen extends StatefulWidget {
  final String employeeNo;
  final String name;
  final String hikvisionBaseUrl;
  final String hikvisionUsername;
  final String hikvisionPassword;
  final String organizationId;
  final String deviceId;
  final String? studentId;
  final String? staffId;

  const HikvisionScreen({
    super.key,
    required this.employeeNo,
    required this.name,
    this.hikvisionBaseUrl = "",
    this.hikvisionUsername = "",
    this.hikvisionPassword = "",
    this.organizationId = "",
    this.deviceId = "",
    this.studentId,
    this.staffId,
  });

  @override
  State<HikvisionScreen> createState() => _HikvisionScreenState();
}

class _HikvisionScreenState extends State<HikvisionScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.hikvisionBaseUrl.isNotEmpty) {
      serviceLocator<HikvisionService>().updateConnection(
        baseUrl: widget.hikvisionBaseUrl,
        username: widget.hikvisionUsername,
        password: widget.hikvisionPassword,
      );
    }
    context.read<HikvisionBloc>().add(HikvisionStarted(employeeNo: widget.employeeNo, name: widget.name));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.onPrimaryColor),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Hikvision foydalanuvchi',
          style: context.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<HikvisionBloc, HikvisionState>(
        listener: (context, state) {
          if (state is HikvisionFailure) {
            context.showPopUp(status: PopUpStatus.error, message: state.message);
          } else if (state is HikvisionSuccess) {
            context.showPopUp(status: PopUpStatus.success, message: state.message);
          }
        },
        builder: (context, state) {
          if (state is HikvisionLoading || state is HikvisionActionInProgress) {
            return Center(child: CircularProgressIndicator(color: context.onPrimaryColor));
          }

          if (state is HikvisionUserFound) {
            return _UserInfoView(
              user: state.user,
              photoBytes: state.photoBytes,
              lookupEmployeeNo: widget.employeeNo,
              organizationId: widget.organizationId,
              deviceId: widget.deviceId,
              studentId: widget.studentId,
              staffId: widget.staffId,
              onDeleteSuccess: () {
                if (!mounted) return;
                context.pop();
              },
            );
          }

          if (state is HikvisionUserNotFound) {
            return _UserNotFoundView(employeeNo: state.employeeNo, name: state.name);
          }

          if (state is HikvisionFailure) {
            return Center(child: Text(state.message));
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _UserInfoView extends StatelessWidget {
  final HikvisionUser user;
  final List<int>? photoBytes;
  final String lookupEmployeeNo;
  final String organizationId;
  final String deviceId;
  final String? studentId;
  final String? staffId;
  final VoidCallback onDeleteSuccess;

  const _UserInfoView({
    required this.user,
    required this.photoBytes,
    required this.lookupEmployeeNo,
    required this.organizationId,
    required this.deviceId,
    required this.staffId,
    required this.studentId,
    required this.onDeleteSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Foydalanuvchi topildi',
            style: context.textTheme.bodyLarge!.copyWith(fontSize: 18.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 16.h),
          Center(
            child: SizedBox(
              width: 160.w,
              height: 160.w,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: photoBytes != null
                    ? Image.memory(Uint8List.fromList(photoBytes!), fit: BoxFit.cover)
                    : Container(
                        color: cBlack.withValues(alpha: .1),
                        child: Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: cBlue,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                            ),
                            onPressed: () {
                              final orgOk = organizationId.trim().isNotEmpty;
                              final devOk = deviceId.trim().isNotEmpty;
                              context.read<HikvisionBloc>().add(
                                HikvisionAddPhotoPressed(
                                  deviceEmployeeNo: user.employeeNo,
                                  lookupEmployeeNo: lookupEmployeeNo,
                                  /*studentId: orgOk && devOk ? lookupEmployeeNo : null,*/
                                  studentId: studentId,
                                  staffId: staffId,
                                  organizationId: orgOk ? organizationId : null,
                                  deviceId: devOk ? deviceId : null,
                                ),
                              );
                            },
                            child: Text(
                              'Rasm qo‘shish',
                              style: context.textTheme.bodyMedium!.copyWith(color: cWhite, fontSize: 16.sp),
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          _InfoRow(label: 'Employee No', value: user.employeeNo),
          _InfoRow(label: 'Ism', value: user.name),
          _InfoRow(label: 'User type', value: user.userType),
          _InfoRow(label: 'Door right', value: user.doorRight),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: cRed,
                side: const BorderSide(color: cRed),
              ),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(
                      'Foydalanuvchini o‘chirish',
                      style: context.textTheme.bodyMedium!.copyWith(color: context.onPrimaryColor, fontSize: 18.sp),
                    ),
                    content: Text(
                      'Foydalanuvchini o‘chirishni hohlaysizmi?',
                      style: context.textTheme.bodyMedium!.copyWith(color: context.onPrimaryColor, fontSize: 14.sp),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(
                          'Bekor qilish',
                          style: context.textTheme.bodyMedium!.copyWith(color: context.onPrimaryColor, fontSize: 14.sp),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text(
                          'O‘chirish',
                          style: context.textTheme.bodyMedium!.copyWith(color: cRed, fontSize: 14.sp),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirm == true && context.mounted) {
                  context.read<HikvisionBloc>().add(
                    HikvisionDeleteUserPressed(employeeNo: user.employeeNo, onSuccess: onDeleteSuccess),
                  );
                }
              },
              child: const Text('O‘chirish'),
            ),
          ),
          SizedBox(height: 24.h,),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: cWhite,
                side: BorderSide(color: context.onPrimaryColor),
              ),
              child: Text(
                "Orqaga",
                style: context.textTheme.bodyMedium!.copyWith(color: context.onPrimaryColor, fontSize: 14.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserNotFoundView extends StatelessWidget {
  final String employeeNo;
  final String name;

  const _UserNotFoundView({required this.employeeNo, required this.name});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Foydalanuvchi Hikvision da topilmadi.', textAlign: TextAlign.center, style: context.textTheme.bodyMedium),
          SizedBox(height: 8.h),
          Text(
            'Foydalanuvchini Hikvision ga qo‘shishni hohlaysizmi?',
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium,
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: cBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
              ),
              onPressed: () {
                context.read<HikvisionBloc>().add(HikvisionCreateUserPressed(employeeNo: employeeNo, name: name));
              },
              child: Text(
                'Qo‘shish',
                style: context.textTheme.bodyMedium!.copyWith(color: cWhite, fontSize: 16.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: context.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w500)),
          ),
          Expanded(flex: 3, child: Text(value, style: context.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
