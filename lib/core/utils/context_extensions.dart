import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:vibration/vibration.dart';

import '../../assets/colors/colors.dart';
import '../../assets/constants/app_icons.dart';

enum PopUpStatus { error, warning, success }

extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => theme.textTheme;

  ColorScheme get colorScheme => theme.colorScheme;

  EdgeInsets get padding => MediaQuery.paddingOf(this);

  Size get size => MediaQuery.sizeOf(this);

  Future<void> showPopUp({
    required PopUpStatus status,
    Widget? child,
    double? height,
    String? message,
    Duration? displayDuration,
    Duration? animationDuration,
    Duration? reverseAnimationDuration,
    DismissType? dismissType,
    TextStyle? messageStyle,
  }) async {
    if (status == PopUpStatus.error) {
      await Vibration.vibrate(duration: 400);
    } else if (status == PopUpStatus.warning) {
      await Vibration.vibrate(duration: 200);
    }
    showTopSnackBar(
      Overlay.of(this),
      ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Material(
          child:
              child ??
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h).copyWith(right: 0),
                height: height ?? 52.h,
                decoration: ShapeDecoration(
                  color:
                      status == PopUpStatus.error
                          ? cRed
                          : status == PopUpStatus.warning
                          ? cBlue
                          : cGreen,
                  shape: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(12.r)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: cWhite,
                      radius: 16.r,
                      child: SvgPicture.asset(statusIcon(status), width: 18.w, height: 18.h),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        message ?? '',
                        textScaler: TextScaler.linear(1.0),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: messageStyle ?? TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: cWhite),
                      ),
                    ),
                  ],
                ),
              ),
        ),
      ),
      displayDuration: displayDuration ?? const Duration(seconds: 3),
      animationDuration: animationDuration ?? const Duration(milliseconds: 250),
      reverseAnimationDuration: reverseAnimationDuration ?? const Duration(milliseconds: 250),
      dismissType: dismissType ?? DismissType.onSwipe,
      dismissDirection: [DismissDirection.horizontal],

    );
  }
}

String statusIcon(PopUpStatus status) {
  switch (status) {
    case PopUpStatus.error:
      return AppIcons.error;
    case PopUpStatus.warning:
      return AppIcons.warning;
    case PopUpStatus.success:
      return AppIcons.success;
  }
}
