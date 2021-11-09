import 'package:flutter/material.dart';

/// Contains all the colors and theme of the ETS, App|ETS and specific to the app
class AppTheme {
  static String flavorName;
  AppTheme._();

  // ETS colors
  static Color _etsLightRed = const Color(0xffef3e45);
  static Color get etsLightRed { return _etsLightRed; }

  static Color _etsDarkRed = const Color(0xffbf311a);
  static Color get etsDarkRed { return _etsDarkRed; }

  static const Color etsLightGrey = Color(0xff807f83);
  static const Color etsDarkGrey = Color(0xff636467);
  static const Color etsBlack = Color(0xff2e2a25);

  // Backgrounds
  static const Color darkThemeBackground = Color(0xff303030);
  static const Color lightThemeBackground = Color(0xfffafafa);

  // App|ETS colors
  static Color _appletsPurple = const Color(0xff19375f);
  static Color get appletsPurple { return _appletsPurple; }

  static Color _appletsDarkPurple = const Color(0xff122743);
  static Color get appletsDarkPurple { return _appletsDarkPurple; }

  // Grade colors
  static const Color gradeFailureMin = Color(0xffd32f2f);
  static const Color gradeFailureMax = Color(0xffff7043);
  static const Color gradePassing = Color(0xfffff176);
  static const Color gradeGoodMin = Color(0xffaed581);
  static const Color gradeGoodMax = Color(0xff43a047);

  // Primary
  static Color primary = _etsLightRed;

  // Primary dark
  static const Color primaryDark = Color(0xff121212);

  // Accent
  static Color accent = _etsDarkRed;

  /// Light theme
  static ThemeData lightTheme() {
    final ThemeData lightTheme = ThemeData.light();
    return lightTheme.copyWith(
        primaryColor: etsLightRed,
        bottomNavigationBarTheme: lightTheme.bottomNavigationBarTheme
            .copyWith(selectedItemColor: etsLightRed),
        colorScheme: lightTheme.colorScheme
            .copyWith(primary: etsLightRed, secondary: etsLightRed)
            .copyWith(secondary: etsLightRed));
  }

  /// Dark theme
  static ThemeData darkTheme() {
    final ThemeData darkTheme = ThemeData.dark();
    return darkTheme.copyWith(
        // primaryColor: primaryDark,
        // appBarTheme: const AppBarTheme(color: Color(0xff121212)),
        scaffoldBackgroundColor: const Color(0xff121212),
        cardColor: const Color(0xff1e1e1e),
        bottomNavigationBarTheme: darkTheme.bottomNavigationBarTheme
            .copyWith(selectedItemColor: etsLightRed),
        colorScheme: darkTheme.colorScheme
            .copyWith(primary: etsLightRed, secondary: etsLightRed)
            .copyWith(secondary: etsLightRed));
  }

  static void setFlavorBeta() {
    final tempPrimary = _etsLightRed;
    final tempAccent = _etsDarkRed;
    _etsLightRed = _appletsPurple;
    _etsDarkRed = _appletsDarkPurple;
    _appletsPurple = tempPrimary;
    _appletsDarkPurple = tempAccent;
  }
}
