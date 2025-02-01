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

  // Schedule color palettes
  static const List<Color> schedulePaletteLight = [
    Color(0xfff1c40f),
    Color(0xffe67e22),
    Color(0xffe91e63),
    Color(0xff16a085),
    Color(0xff2ecc71),
    Color(0xff3498db),
    Color(0xff9b59b6),
    Color(0xff34495e),
    Color(0xffe67e22),
    Color(0xffe74c3c),
  ];

  // schedulePaletteDark, same colors than schedulePaletteLight but darker
  static const List<Color> schedulePaletteDark = [
    Color(0xffb7950b),
    Color(0xffa84300),
    Color(0xffad1457),
    Color(0xff0b5345),
    Color(0xff1b5e20),
    Color(0xff1e3a56),
    Color(0xff6a1b9a),
    Color(0xff2c3e50),
    Color(0xffa84300),
    Color(0xff992d22),
  ];

  // News tags color palettes
  static const List<Color> tagsPalette = [
    Color(0xfff39c12),
    Color(0xffef476f),
    Color(0xffd35400),
    Color(0xff16a085),
    Color.fromARGB(255, 46, 151, 204),
    Color(0xff8e44ad),
    Color.fromARGB(255, 12, 168, 77),
    Color.fromARGB(255, 161, 185, 41),
  ];

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
