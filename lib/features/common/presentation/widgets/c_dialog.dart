import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../assets/colors/colors.dart';
import '../../../../assets/theme/theme_extensions.dart';
import '../../../../core/utils/context_extensions.dart';


void commonDeleteDialog({required String title, required BuildContext context, required VoidCallback onTap}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: context.secondaryColor,
        title: Text(
          title,
          textScaler: TextScaler.linear(1.0),
          style: context.textTheme.bodyMedium!.copyWith(color: context.onPrimaryColor, fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              "LocaleKeys.no.tr()",
              textScaler: TextScaler.linear(1.0),
              style: Theme.of(context).textTheme.bodySmall!.copyWith(color: cRed, fontSize: 12.sp, fontWeight: FontWeight.w400),
            ),
          ),

          TextButton(
            onPressed: () {
              onTap.call();
              Navigator.of(context).pop(); // Dismiss dialog
            },
            child: Text(
              "LocaleKeys.yes.tr()",
              textScaler: TextScaler.linear(1.0),
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: cBlue, fontSize: 12.sp, fontWeight: FontWeight.w400),
            ),
          ),
        ],
      );
    },
  );
}
