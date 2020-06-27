
import 'package:flutter/material.dart';

/// Contains all the colors and theme of the ETS, App|ETS and specific to the app
class AppTheme {
  AppTheme._();

  // ETS colors
  static const Color etsLightRed = Color(0xffef3e45);
  static const Color etsDarkRed = Color(0xffbf311a);
  static const Color etsLightGrey = Color(0xff807f83);
  static const Color etsDarkGrey = Color(0xff636467);
  static const Color etsBlack = Color(0xff2e2a25);

  // App|ETS colors
  static const Color appletsPurple = Color(0xff19375f);

  // Grade colors
  static const Color gradeFailureMin = Color(0xffd32f2f);
  static const Color gradeFailureMax = Color(0xffff7043);
  static const Color gradePassing = Color(0xfffff176);
  static const Color gradeGoodMin = Color(0xffaed581);
  static const Color gradeGoodMax = Color(0xff43a047);

  // Primary
  static const Color primary = etsLightRed;

  // Primary dark
  static const Color primaryDark = Colors.black;

  // Accent
  static const Color accent = etsLightRed;

  /// Light theme
  static final ThemeData lightTheme = ThemeData.light().copyWith(
      primaryColor: primary,
      accentColor: accent
  );

  /// Dark theme
  static final ThemeData darkTheme = ThemeData.dark().copyWith(
      primaryColor: primaryDark,
      accentColor: accent
  );
}