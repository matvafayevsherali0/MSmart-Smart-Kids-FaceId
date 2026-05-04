import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../assets/colors/colors.dart';
import '../../../../assets/theme/theme_extensions.dart';
import '../../../../core/utils/context_extensions.dart';

class TwinsContainer extends StatelessWidget {
  final String title;
  final String text;
  final bool haveData;

  const TwinsContainer({super.key, required this.title, required this.text, required this.haveData});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60.sp,
      padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: haveData ? 12.sp : 16.sp),
      decoration: ShapeDecoration(
        color: context.onTertiaryColor,
        shape: OutlineInputBorder(borderRadius: BorderRadius.circular(60.r), borderSide: BorderSide.none),
      ),
      child: haveData
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  textScaler: TextScaler.linear(1.0),
                  style: context.textTheme.bodyLarge!.copyWith(
                    color: secondTextColor,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.sp),
                Text(
                  text,
                  textScaler: TextScaler.linear(1.0),
                  style: context.textTheme.bodyLarge!.copyWith(
                    color: context.onPrimaryColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            )
          : Text(
              title,
              textScaler: TextScaler.linear(1.0),
              style: context.textTheme.bodyLarge!.copyWith(color: secondTextColor, fontSize: 14.sp, fontWeight: FontWeight.w500),
            ),
    );
  }
}
