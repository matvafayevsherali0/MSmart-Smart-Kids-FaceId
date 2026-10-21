import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../assets/colors/colors.dart';
import '../../../../assets/theme/theme_extensions.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/utils/service_locator.dart';
import '../../../common/presentation/widgets/custom_button.dart';
import '../../../hikvision/data/service/hikvision_service.dart';
import '../bloc/users_comparison_bloc.dart';

class UsersComparisonScreen extends StatefulWidget {
  final String organizationId;
  final String hikvisionBaseUrl;
  final String hikvisionUsername;
  final String hikvisionPassword;

  const UsersComparisonScreen({
    super.key,
    required this.organizationId,
    this.hikvisionBaseUrl = "",
    this.hikvisionUsername = "",
    this.hikvisionPassword = "",
  });

  @override
  State<UsersComparisonScreen> createState() => _UsersComparisonScreenState();
}

class _UsersComparisonScreenState extends State<UsersComparisonScreen> {
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
    context.read<UsersComparisonBloc>().add(
      UsersComparisonStarted(organizationId: widget.organizationId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UsersComparisonBloc, UsersComparisonState>(
      builder: (context, state) {
        if (state is UsersComparisonLoading) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: context.onPrimaryColor),
            ),
          );
        }

        if (state is UsersComparisonFailure) {
          return Scaffold(
            appBar: AppBar(title: const Text('Users comparison')),
            body: Center(child: Text(state.message)),
          );
        }

        final content = state as UsersComparisonContent;
        final backendFaceImageCount = content.backendUsers
            .where((user) => user.faceImageUrl.trim().isNotEmpty)
            .length;
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Users comparison',
              style: context.textTheme.bodyMedium!.copyWith(fontSize: 16.sp),
            ),
            centerTitle: true,
          ),
          body: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                _CountCard(
                  title: 'Backend — staff (ids)',
                  count: content.staffBackendIds.length,
                ),
                SizedBox(height: 12.h),
                _CountCard(
                  title: 'Backend — employee (ids)',
                  count: content.employeeBackendIds.length,
                ),
                SizedBox(height: 12.h),
                _CountCard(
                  title: 'Backend — jami (noyob)',
                  count: content.backendIds.length,
                ),
                SizedBox(height: 12.h),
                _CountCard(
                  title: 'Hikvision',
                  count: content.hikvisionIds.length,
                ),
                if (!content.isSynchronizing)
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: CustomButton(
                      onPressed: () {
                        context.read<UsersComparisonBloc>().add(
                          DataSynchronizationUsersComparisonEvent(
                            backendIds: content.backendIds,
                            hikvisionIds: content.hikvisionIds,
                          ),
                        );
                      },
                      child: Text(
                        "Ma'lumotlarni sinxromlash",
                        style: context.textTheme.bodyMedium!.copyWith(
                          color: cWhite,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                if (content.isSynchronizing)
                  Padding(
                    padding: EdgeInsets.only(top: 12.h),
                    child: Column(
                      children: [
                        _SyncCountRow(
                          title: "Backendda bor, Face ID'da yo'q:",
                          count: content.backendUsersToCreate.length,
                        ),
                        SizedBox(height: 8.h),
                        _SyncCountRow(
                          title: "Face ID'da bor, backendda yo'q:",
                          count: content.usersComparisonIds.length,
                        ),
                        SizedBox(height: 8.h),
                        _SyncCountRow(
                          title: "Backendda rasmi bor, Face ID'ga yuboriladi:",
                          count: backendFaceImageCount,
                        ),
                      ],
                    ),
                  ),
                if (content.isSynchronizing &&
                    content.backendUsersToCreate.isEmpty &&
                    content.usersComparisonIds.isEmpty &&
                    backendFaceImageCount == 0)
                  Padding(
                    padding: EdgeInsets.only(top: 20.h),
                    child: Text(
                      "Ma'lumotlar allaqachon mos.",
                      style: context.textTheme.bodyMedium!.copyWith(
                        color: cGreen,
                        fontSize: 15.sp,
                      ),
                    ),
                  ),
                if (content.isSynchronizing &&
                    (content.backendUsersToCreate.isNotEmpty ||
                        content.usersComparisonIds.isNotEmpty ||
                        backendFaceImageCount > 0))
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: CustomButton(
                      isLoading: content.isApplying,
                      onPressed: () async {
                        if (content.isApplying) return;
                        final bloc = context.read<UsersComparisonBloc>();
                        final confirmed =
                            await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text(
                                  "Face ID ma'lumotlarini sinxronlash",
                                ),
                                content: Text(
                                  "Backenddagi ${content.backendUsersToCreate.length} ta foydalanuvchi Face ID'ga qo‘shiladi. "
                                  "$backendFaceImageCount ta backend rasmi Face ID'ga yuboriladi. "
                                  "Face ID'dagi ${content.usersComparisonIds.length} ta ortiqcha foydalanuvchi o‘chiriladi. Davom etilsinmi?",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: Text(
                                      'Bekor qilish',
                                      style: context.textTheme.bodyMedium!
                                          .copyWith(
                                            color: context.onPrimaryColor,
                                          ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: Text(
                                      "Sinxronlash",
                                      style: context.textTheme.bodyMedium!
                                          .copyWith(color: cBlue),
                                    ),
                                  ),
                                ],
                              ),
                            ) ??
                            false;

                        if (confirmed) {
                          bloc.add(
                            const ApplyUsersComparisonSynchronizationEvent(),
                          );
                        }
                      },
                      child: Text(
                        "Sinxronlashni bajarish",
                        style: context.textTheme.bodyMedium!.copyWith(
                          color: cWhite,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SyncCountRow extends StatelessWidget {
  final String title;
  final int count;

  const _SyncCountRow({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: context.textTheme.bodyMedium!.copyWith(
              color: context.onPrimaryColor,
              fontSize: 14.sp,
            ),
          ),
        ),
        Text(
          count.toString(),
          style: context.textTheme.bodyMedium!.copyWith(
            color: context.onPrimaryColor,
            fontSize: 18.sp,
          ),
        ),
      ],
    );
  }
}

class _CountCard extends StatelessWidget {
  final String title;
  final int count;

  const _CountCard({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: Colors.black.withValues(alpha: 0.04),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: context.textTheme.bodyMedium),
          Text(count.toString(), style: context.textTheme.bodyLarge),
        ],
      ),
    );
  }
}
