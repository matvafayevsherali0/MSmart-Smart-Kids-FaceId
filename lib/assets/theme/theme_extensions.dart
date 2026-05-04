import 'package:flutter/material.dart';

extension ColorSchemeExtension on BuildContext {
  Color get primaryColor => Theme.of(this).colorScheme.primary;

  Color get onPrimaryColor => Theme.of(this).colorScheme.onPrimary;

  Color get secondaryColor => Theme.of(this).colorScheme.secondary;

  // Color get onSecondaryColor => Theme.of(this).colorScheme.onSecondary;

  Color get surfaceColor => Theme.of(this).colorScheme.surface;

  Color get onSurfaceColor => Theme.of(this).colorScheme.onSurface;

  Color get primaryFixedColor => Theme.of(this).colorScheme.primaryFixed;

  Color get primaryFixedDimColor => Theme.of(this).colorScheme.primaryFixedDim;

  Color get tertiaryColor => Theme.of(this).colorScheme.tertiary;

  Color get onTertiaryColor => Theme.of(this).colorScheme.onTertiary;
}

extension TextThemeExtension on BuildContext {
  TextStyle? get bodySmall => Theme.of(this).textTheme.bodySmall;

  TextStyle? get bodyMedium => Theme.of(this).textTheme.bodyMedium;

  TextStyle? get bodyLarge => Theme.of(this).textTheme.bodyLarge;

  TextStyle? get titleSmall => Theme.of(this).textTheme.titleSmall;

  TextStyle? get titleMedium => Theme.of(this).textTheme.titleMedium;

  TextStyle? get titleLarge => Theme.of(this).textTheme.titleLarge;

  TextStyle? get displaySmall => Theme.of(this).textTheme.displaySmall;

  TextStyle? get displayMedium => Theme.of(this).textTheme.displayMedium;

  TextStyle? get displayLarge => Theme.of(this).textTheme.displayLarge;
}
