import 'package:flutter/material.dart';

import '../../../../assets/colors/colors.dart';
import '../../../../core/utils/context_extensions.dart';

Future<bool> showLogoutDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(
          "Chiqishni tasdiqlaysizmi?",
          style: context.textTheme.bodyMedium!.copyWith(
            color: cWhite,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              "Yo'q",
              style: context.textTheme.bodyMedium!.copyWith(color: cWhite, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              "Ha",
              style: context.textTheme.bodyMedium!.copyWith(color: cRed, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      );
    },
  );
  return result ?? false;
}

Future<bool> showDeleteAccountDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(
          "Hisob o'chirilisinmi?",
          style: context.textTheme.bodyMedium!.copyWith(
            color: cWhite,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              "Yo'q",
              style: context.textTheme.bodyMedium!.copyWith(color: cWhite, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              "Ha",
              style: context.textTheme.bodyMedium!.copyWith(color: cRed, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      );
    },
  );
  return result ?? false;
}
