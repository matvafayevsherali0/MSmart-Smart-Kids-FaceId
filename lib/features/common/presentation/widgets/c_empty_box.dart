import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../assets/colors/colors.dart';
import '../../../../assets/constants/app_icons.dart';
import '../../../../assets/theme/theme_extensions.dart';
import '../../../../core/utils/context_extensions.dart';

class CEmptyBox extends StatelessWidget {
  const CEmptyBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(AppIcons.box, width: 24.sp, height: 24.sp),
          Text(
            "LocaleKeys.empty.tr()",
            textScaler: TextScaler.linear(1.0),
            style: context.textTheme.bodyLarge!.copyWith(
              color: context.onPrimaryColor,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class PaginationLoadingIndicator extends StatelessWidget {
  const PaginationLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 20.sp,
        height: 20.sp,
        child: CircularProgressIndicator
            .adaptive(
          strokeWidth: 2.sp,
        ),
      ),
    );
  }
}

class PageErrorWidget extends StatelessWidget {
  const PageErrorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Error",
        textScaler: TextScaler.linear(1.0),
        style: context.textTheme.bodyLarge!.copyWith(
          color: cRed,
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}


