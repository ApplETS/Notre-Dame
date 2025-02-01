import 'package:flutter/material.dart';
import 'package:notredame/theme/app_palette.dart';
import 'app_colors_extension.dart';

class AppTheme with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  set themeMode(ThemeMode themeMode) {
    _themeMode = themeMode;
    notifyListeners();
  }

  static final light = () {
    final defaultTheme = ThemeData.light();

    return defaultTheme.copyWith(
      appBarTheme: AppBarTheme(
        color: _lightAppColors.appBar,
      ),
      tabBarTheme: const TabBarTheme(labelColor: Colors.white),
      cardColor: const Color(0xff1D1B20),
      bottomNavigationBarTheme: defaultTheme.bottomNavigationBarTheme.copyWith(
          selectedItemColor: AppPalette.etsLightRed,
          backgroundColor: _lightAppColors.navBar
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: _lightAppColors.navBar,
        groupAlignment: 0,
        indicatorColor: Colors.transparent,
        selectedLabelTextStyle: TextStyle(color: AppPalette.etsLightRed),
        selectedIconTheme: IconThemeData(color: AppPalette.etsLightRed),
      ),
      colorScheme: defaultTheme.colorScheme.copyWith(
          primary: AppPalette.etsLightRed,
          secondary: AppPalette.etsLightRed,
          surface: const Color(0xff1e1e1e),
          surfaceTint: const Color(0xff1e1e1e)),
      extensions: [
        _lightAppColors
      ],
    );
  }();

  static final _lightAppColors = AppColorsExtension(
    appBar: const Color(0xffeae7ea),
    navBar: const Color(0xffefeaee),
    backgroundAlt: const Color(0xfffafafa),
    scheduleLine: const Color(0xffe8e8e8),
    tabBarLabel: Colors.black,
    tabBarIndicator: Colors.black26,
    shimmerHighlight: const Color.fromARGB(255, 228, 225, 225),
    vibrantAppBar: AppPalette.etsLightRed
  );

  static final dark = () {
    final defaultTheme = ThemeData.dark();

    return defaultTheme.copyWith(
      appBarTheme: AppBarTheme(
        color: _darkAppColors.appBar,
      ),
      tabBarTheme: const TabBarTheme(labelColor: Colors.white),
      scaffoldBackgroundColor: const Color(0xff121212),
      cardColor: const Color(0xff1D1B20),
      bottomNavigationBarTheme: defaultTheme.bottomNavigationBarTheme.copyWith(
          selectedItemColor: AppPalette.etsLightRed,
          backgroundColor: _darkAppColors.navBar
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: _darkAppColors.navBar,
        groupAlignment: 0,
        indicatorColor: Colors.transparent,
        selectedLabelTextStyle: TextStyle(color: AppPalette.etsLightRed),
        selectedIconTheme: IconThemeData(color: AppPalette.etsLightRed),
      ),
      colorScheme: defaultTheme.colorScheme.copyWith(
          primary: AppPalette.etsLightRed,
          secondary: AppPalette.etsLightRed,
          surface: const Color(0xff1e1e1e),
          surfaceTint: const Color(0xff1e1e1e)
      ),
      extensions: [
        _darkAppColors
      ],
    );
  }();

  static final _darkAppColors = AppColorsExtension(
    appBar: const Color(0xff16171a),
    navBar: const Color(0xff1c1d21),
    backgroundAlt: const Color(0xff2c2c2c),
    scheduleLine: const Color(0xff2c2929),
    tabBarLabel: Colors.white,
    tabBarIndicator: Colors.white,
    shimmerHighlight: const Color(0xff424242),
    vibrantAppBar: const Color(0xff16171a)
  );
}

extension AppThemeExtension on ThemeData {
  AppColorsExtension get appColors => extension<AppColorsExtension>() ?? AppTheme._lightAppColors;
}

extension ThemeGetter on BuildContext {
  ThemeData get theme => Theme.of(this);
}