import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/navigation/router.dart';
import '../../../../../assets/colors/colors.dart';
import '../../../../../core/utils/context_extensions.dart';
import '../../../../common/presentation/widgets/custom_button.dart';
import '../../../../common/presentation/widgets/line_widget.dart';

class CategorySelectionScreen extends StatelessWidget {
  final String organizationId;
  final String hikvisionBaseUrl;
  final String hikvisionUsername;
  final String hikvisionPassword;
  final String deviceId;

  const CategorySelectionScreen({
    super.key,
    required this.organizationId,
    required this.hikvisionBaseUrl,
    required this.hikvisionUsername,
    required this.hikvisionPassword,
    required this.deviceId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          "Kategoryiani tanlang",
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: LineWidget(
                backgroundColor: cGrey,
                body: Text(
                  "Ishchilar",
                  style: context.textTheme.bodyMedium!.copyWith(
                    color: cWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  context.push(
                    AppRoutes.employees,
                    extra: {
                      'hikvisionBaseUrl': hikvisionBaseUrl,
                      'hikvisionUsername': hikvisionUsername,
                      'hikvisionPassword': hikvisionPassword,
                      'organizationId': organizationId,
                      'deviceId': deviceId,
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: LineWidget(
                backgroundColor: cGrey,
                body: Text(
                  "Tarbiyalanuvchilar",
                  style: context.textTheme.bodyMedium!.copyWith(
                    color: cWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  context.push(
                    AppRoutes.pupilsClasses,
                    extra: {
                      'hikvisionBaseUrl': hikvisionBaseUrl,
                      'hikvisionUsername': hikvisionUsername,
                      'hikvisionPassword': hikvisionPassword,
                      'organizationId': organizationId,
                      'deviceId': deviceId,
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 24.h),
        child: CustomButton(
          onPressed: () {
            context.push(
              AppRoutes.usersComparison,
              extra: {
                "organizationId": organizationId,
                "hikvisionBaseUrl": hikvisionBaseUrl,
                "hikvisionUsername": hikvisionUsername,
                "hikvisionPassword": hikvisionPassword,
              },
            );
          },
          backgroundColor: cBlue,
          child: Text(
            "Ma'lumotlarni sinxromlash",
            style: context.textTheme.bodyMedium!.copyWith(
              color: cWhite,
              fontSize: 16.sp,
            ),
          ),
        ),
      ),
    );
  }
}
