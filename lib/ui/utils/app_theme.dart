// Flutter imports:
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

  // Backgrounds
  static const Color darkThemeBackground = Color(0xff2c2c2c);
  static const Color darkThemeBackgroundAccent =
      Color.fromARGB(255, 50, 48, 48);
  static const Color lightThemeBackground = Color(0xfffafafa);

  // App|ETS colors
  static const Color appletsPurple = Color(0xff19375f);
  static const Color appletsDarkPurple = Color(0xff122743);

  // Grade colors
  static const Color gradeFailureMin = Color(0xffd32f2f);
  static const Color gradeFailureMax = Color(0xffff7043);
  static const Color gradePassing = Color(0xfffff176);
  static const Color gradeGoodMin = Color(0xffaed581);
  static const Color gradeGoodMax = Color(0xff43a047);

  // Primary
  static const Color primary = etsLightRed;

  // Primary dark
  static const Color primaryDark = Color(0xff121212);

  // Accent
  static const Color accent = etsLightRed;
  static const Color lightThemeAccent = Color.fromARGB(255, 228, 225, 225);
  static const Color darkThemeAccent = Color(0xff424242);

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

  /// Schedule calendar colors
  static const Color scheduleLineColorLight = Color(0xffe8e8e8);
  static const Color scheduleLineColorDark = Color(0xff3d3d3d);

  /// Light theme
  static ThemeData lightTheme() {
    final ThemeData lightTheme = ThemeData.light();
    return lightTheme.copyWith(
        primaryColor: etsLightRed,
        bottomNavigationBarTheme: lightTheme.bottomNavigationBarTheme
            .copyWith(selectedItemColor: etsLightRed),
        textTheme: lightTheme.textTheme.copyWith(
          bodySmall: const TextStyle(fontSize: 14, color: Colors.black),
          bodyMedium: const TextStyle(fontSize: 16, color: Colors.black),
          bodyLarge: const TextStyle(fontSize: 18, color: Colors.black),
          titleSmall: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.w400, color: Colors.black),
          displaySmall: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.w400, color: Colors.black),
        ),
        colorScheme: lightTheme.colorScheme
            .copyWith(primary: etsLightRed, secondary: etsLightRed)
            .copyWith(secondary: etsLightRed)
            .copyWith(
                surface: const Color(0xfff1f1f1), surfaceTint: Colors.white));
  }

  /// Dark theme
  static ThemeData darkTheme() {
    final ThemeData darkTheme = ThemeData.dark();
    return darkTheme.copyWith(
        // primaryColor: primaryDark,
        // appBarTheme: const AppBarTheme(color: Color(0xff121212)),
        scaffoldBackgroundColor: const Color(0xff121212),
        cardColor: const Color(0xff1e1e1e),
        textTheme: darkTheme.textTheme.copyWith(
          titleSmall: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
          bodySmall: const TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
          bodyMedium: const TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
          bodyLarge: const TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        bottomNavigationBarTheme: darkTheme.bottomNavigationBarTheme
            .copyWith(selectedItemColor: etsLightRed),
        colorScheme: darkTheme.colorScheme
            .copyWith(primary: etsLightRed, secondary: etsLightRed)
            .copyWith(secondary: etsLightRed)
            .copyWith(
                surface: const Color(0xff1e1e1e),
                surfaceTint: const Color(0xff1e1e1e)));
  }
}
