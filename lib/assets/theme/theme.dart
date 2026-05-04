import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../colors/colors.dart';

class AppTheme {
  static ThemeData getThemeData({required bool isDarkModeOn}) {
    final colorScheme = isDarkModeOn ? _darkColorScheme : _lightColorScheme;
    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
          statusBarColor: Colors.transparent,
          systemStatusBarContrastEnforced: true,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: colorScheme.onPrimary,
          fontFamily: 'Inter Display',
          letterSpacing: 0,
          height: 1.0,
        ),
        displayMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: colorScheme.onPrimary,
          fontFamily: 'Inter Display',
          letterSpacing: .2,
        ),
        displaySmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: colorScheme.onPrimary,
          fontFamily: 'Inter Display',
          letterSpacing: .2,
        ),
        titleLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: colorScheme.onPrimary,
          fontFamily: 'Inter Display',
          letterSpacing: .1,
        ),
        titleMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colorScheme.onPrimary,
          fontFamily: 'Inter Display',
          letterSpacing: .1,
        ),
        titleSmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: colorScheme.onPrimary,
          fontFamily: 'Inter Display',
          letterSpacing: .1,
        ),
        bodyLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          color: colorScheme.onPrimary,
          fontFamily: 'Inter Display',
          letterSpacing: .1,
        ),
        bodyMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w400,
          color: colorScheme.onPrimary,
          fontFamily: 'Inter Display',
          letterSpacing: .1,
        ),
        bodySmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: colorScheme.onPrimary,
          fontFamily: 'Inter Display',
          letterSpacing: .1,
        ),
      ),
    );
  }

  static const ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: dPrimary,
    onPrimary: dOnPrimary,
    secondary: dSecondary,
    onSecondary: dOnSecondary,
    error: dError,
    onError: dOnError,
    surface: dSurface,
    onSurface: dOnSurface,
    shadow: dShadow,
    primaryFixed: dPrimaryFixed,
    primaryFixedDim: dPrimaryFixedDim,
    tertiary: dTertiary,
    onTertiary: dOnTertiary,
  );

  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: lPrimary,
    onPrimary: lOnPrimary,
    secondary: lSecondary,
    onSecondary: lOnSecondary,
    error: lError,
    onError: lOnError,
    surface: lSurface,
    onSurface: lOnSurface,
    shadow: lShadow,
    primaryFixed: lPrimaryFixed,
    primaryFixedDim: lPrimaryFixedDim,
    tertiary: lTertiary,
    onTertiary: lOnTertiary,
  );
}
