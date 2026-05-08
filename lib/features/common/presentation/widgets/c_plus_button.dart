import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../assets/colors/colors.dart';
import '../../../../assets/constants/app_icons.dart';
import '../../../../assets/theme/theme_extensions.dart';

class CPlusButton extends StatelessWidget {
  final VoidCallback onTap;
  const CPlusButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100000),
      child: Container(
        width: 48.sp,
        height: 48.sp,
        decoration: ShapeDecoration(
          color: context.surfaceColor,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 2,
              strokeAlign: BorderSide.strokeAlignOutside,
              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8E8E93) : cWhite,
            ),
            borderRadius: BorderRadius.circular(59),
          ),
          shadows: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark ? Color(0x19000000) : Color(0x33000000),
              blurRadius: 27.sp,
              offset: Offset(0, 10.sp),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Center(child: SvgPicture.asset(AppIcons.add, width: 24.sp, height: 24.sp)),
      ),
    );
  }
}
