import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../assets/colors/colors.dart';
import '../../../../core/utils/context_extensions.dart';

class CommonTextField extends StatelessWidget {
  final TextEditingController controller;
  final int? maxLines;
  final double? height;
  final bool? obscureText;
  final Widget? trailing;
  final String hintText;
  final Color? bgColor;
  final TextInputType? keyboardType;
  final String? Function(String? value)? validator;
  final void Function(String value)? onChanged;
  final EdgeInsetsGeometry? contentPadding;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;
  final bool enableInteractiveSelection;

  const CommonTextField({
    super.key,
    required this.controller,
    this.maxLines,
    this.height,
    this.obscureText,
    this.trailing,
    this.bgColor,
    this.keyboardType,
    required this.hintText,
    this.validator,
    this.onChanged,
    this.contentPadding,
    this.focusNode,
    this.inputFormatters,
    this.enableInteractiveSelection = true,
  });

  @override
  Widget build(BuildContext context) {
    double cHeight = height ?? 52;
    if (validator != null) {
      cHeight = cHeight + 20;
    }
    return SizedBox(
      height: cHeight,
      child: TextFormField(
        controller: controller,
        maxLines: maxLines ?? 1,
        obscureText: obscureText ?? false,
        validator: validator,
        onChanged: onChanged,
        cursorColor: cBlue,
        focusNode: focusNode,
        keyboardType: keyboardType ?? TextInputType.text,
        enableInteractiveSelection: enableInteractiveSelection,
        magnifierConfiguration: TextMagnifierConfiguration.disabled,
        spellCheckConfiguration: const SpellCheckConfiguration.disabled(),
        style: context.textTheme.bodyLarge!.copyWith(color: cBlack, fontSize: 14, fontWeight: FontWeight.w500),
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          filled: true,
          hintStyle: context.textTheme.bodyLarge?.copyWith(color: cGrey, fontSize: 14, fontWeight: FontWeight.w500),
          hintText: hintText,
          fillColor: bgColor ?? cWhite,
          suffixIcon: trailing != null
              ? Padding(padding: const EdgeInsets.all(16), child: trailing)
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(48),
              borderSide: BorderSide(color: cBlack, width: 1, style: BorderStyle.solid)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(48),
              borderSide: BorderSide(color: cBlue, width: 1, style: BorderStyle.solid)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(48), borderSide: BorderSide(color: cRed, width: 1, style: BorderStyle.solid)),
          focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(48), borderSide: BorderSide(color: cRed, width: 1, style: BorderStyle.solid)),
          contentPadding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 16),
          errorStyle: context.textTheme.bodyLarge!.copyWith(color: cRed, fontSize: 12, fontWeight: FontWeight.w400, height: 0),
        ),
      ),
    );
  }
}

class UzPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    String digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (!digits.startsWith('998')) {
      if (digits.startsWith('9')) {
        digits = '998$digits';
      } else {
        digits = '998';
      }
    }

    if (digits.length > 12) {
      digits = digits.substring(0, 12);
    }

    String formatted = '+';

    for (int i = 0; i < digits.length; i++) {
      if (i == 3) formatted += ' ';
      if (i == 5) formatted += ' ';
      if (i == 8) formatted += ' ';
      if (i == 10) formatted += ' ';
      formatted += digits[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}