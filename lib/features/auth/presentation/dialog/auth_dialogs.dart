import 'package:flutter/material.dart';
import 'package:msmart_kids_faceid/assets/theme/theme_extensions.dart';

import '../../../../assets/colors/colors.dart';
import '../../../../core/utils/context_extensions.dart';

Future<bool> showEnableBiometricDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: context.onPrimaryColor,
        title: Text(
          "Biometrik kirishni yoqasizmi?",
          style: context.textTheme.bodyMedium!.copyWith(
            color: context.tertiaryColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              "Yo'q",
              style: context.textTheme.bodyMedium!.copyWith(color: context.tertiaryColor),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              "Ha",
              style: context.textTheme.bodyMedium!.copyWith(color: cBlue),
            ),
          ),
        ],
      );
    },
  );

  return result ?? false;
}

Future<void> showForceUpdateDialog(
  BuildContext context, {
  required Future<void> Function() onUpdate,
}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: context.onPrimaryColor,
          title: Text(
            "Yangilash talab qilinadi",
            style: context.textTheme.bodyMedium!.copyWith(
              backgroundColor: context.tertiaryColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            "Ilovaning yangi versiyasi mavjud. Davom etish uchun ilovani yangilang.",
            style: context.textTheme.bodyMedium!.copyWith(backgroundColor: context.tertiaryColor,),
          ),
          actions: [
            TextButton(
              onPressed: onUpdate,
              child: Text(
                "Yangilash",
                style: context.textTheme.bodyMedium!.copyWith(color: cBlue),
              ),
            ),
          ],
        ),
      );
    },
  );
}
