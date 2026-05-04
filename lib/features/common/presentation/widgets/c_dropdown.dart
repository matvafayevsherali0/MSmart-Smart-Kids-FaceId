import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../assets/colors/colors.dart';
import '../../../../assets/theme/theme_extensions.dart';
import '../../../../core/utils/context_extensions.dart';

class CDropdown extends StatelessWidget {
  final List<String> items;
  final Function(String value) onTap;
  final String value;
  final Color? backgroundColor;

  const CDropdown({super.key, required this.value, required this.onTap, this.backgroundColor, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 52.h,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: ShapeDecoration(
        color: backgroundColor ?? context.onTertiaryColor,
        shape: OutlineInputBorder(borderRadius: BorderRadius.circular(60.r), borderSide: BorderSide.none),
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        value: value,
        borderRadius: BorderRadius.circular(12.r),
        underline: const SizedBox.shrink(),
        items:
            items
                .map(
                  (String value) => DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      textScaler: TextScaler.linear(1.0),
                      style: context.textTheme.bodyLarge!.copyWith(
                        color: secondTextColor,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
                .toList(),
        onChanged: (String? value) {
          if (value != null) {
            onTap(value);
          }
        },
      ),
    );
  }
}
