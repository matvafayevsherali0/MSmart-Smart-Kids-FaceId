import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../assets/colors/colors.dart';
import '../../../../core/utils/context_extensions.dart';

class CommonTextField extends StatelessWidget {
  final TextEditingController controller;
  final int? maxLines;
  final double? height;
  final bool? obscureText;
  final Widget? trailing;
  final String? hintText;
  final String? labelText;
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
    this.hintText,
    this.labelText,
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
          labelText: labelText,
          labelStyle: context.textTheme.bodyLarge!.copyWith(color: cBlack, fontSize: 14, fontWeight: FontWeight.w500),
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
    final rawDigits = newValue.text.replaceAll(RegExp(r'\D'), '');
    String localDigits = '';

    if (rawDigits.startsWith('998')) {
      localDigits = rawDigits.substring(3);
    } else if (rawDigits.isNotEmpty && !'998'.startsWith(rawDigits)) {
      // If user types without country code, treat input as local part.
      localDigits = rawDigits;
    }

    if (localDigits.length > 9) {
      localDigits = localDigits.substring(0, 9);
    }

    final formatted = _formatUzPhone(localDigits);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatUzPhone(String localDigits) {
    int end(int value, int max) => value < max ? value : max;

    final buffer = StringBuffer('+998');
    if (localDigits.isEmpty) return buffer.toString();

    buffer.write(' ');
    final first = localDigits.substring(0, end(localDigits.length, 2));
    buffer.write(first);

    if (localDigits.length > 2) {
      buffer.write(' ');
      buffer.write(localDigits.substring(2, end(localDigits.length, 5)));
    }
    if (localDigits.length > 5) {
      buffer.write(' ');
      buffer.write(localDigits.substring(5, end(localDigits.length, 7)));
    }
    if (localDigits.length > 7) {
      buffer.write(' ');
      buffer.write(localDigits.substring(7, end(localDigits.length, 9)));
    }

    return buffer.toString();
  }
}