import 'package:flutter/material.dart';

import '../../../../assets/colors/colors.dart';
import '../../../../core/utils/context_extensions.dart';

AppBar organizationAppBar(BuildContext context, VoidCallback onClickAccount) {
  return AppBar(
    centerTitle: true,
    title: Text(
      "MSmart FaceId",
      style: context.textTheme.bodyMedium!.copyWith(color: cBlack),
    ),
    actions: [
      IconButton(
        onPressed: onClickAccount,
        icon: Icon(Icons.account_circle, size: 32),
      ),
    ],
  );
}
