// Flutter imports:
import 'package:flutter/material.dart';

/// Contains all the colors and theme of the ETS, App|ETS and specific to the app
class AppThemeOld {
  AppThemeOld._();

  // Backgrounds
  static const Color darkThemeBackgroundAccent = Color.fromARGB(255, 50, 48, 48);
  static const Color lightThemeBackground = Color(0xfffafafa);

  // Primary dark
  static const Color primaryDark = Color(0xff121212);

  // News tags color palettes


  // News colors
  static const Color newsAccentColorDark = Color(0xff00cdb7);
  static const Color newsAccentColorLight = Color(0xff007c6f);
  static const Color newsSecondaryColor = Color.fromARGB(255, 237, 237, 237);

  /// Light theme
  static ThemeData lightTheme() {
    final ThemeData lightTheme = ThemeData.light();
    return lightTheme;
  }

  /// Dark theme
  static ThemeData darkTheme() {
    final ThemeData darkTheme = ThemeData.dark();
    return darkTheme;
  }
}
