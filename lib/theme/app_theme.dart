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

      extensions: [
        _lightAppColors
      ],
    );
  }();

  static final _lightAppColors = AppColorsExtension(
    appBar: const Color(0xffeae7ea),
    navBar: const Color(0xffefeaee),
    background: const Color(0xfffafafa),
    scheduleLineColor: const Color(0xffe8e8e8)
  );

  static final dark = () {
    final defaultTheme = ThemeData.dark();

    return defaultTheme.copyWith(
        appBarTheme: AppBarTheme(color: _darkAppColors.appBar),
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
        colorScheme: defaultTheme.colorScheme
            .copyWith(primary: AppPalette.etsLightRed, secondary: AppPalette.etsLightRed)
            .copyWith(secondary: AppPalette.etsLightRed)
            .copyWith(
            surface: const Color(0xff1e1e1e),
            surfaceTint: const Color(0xff1e1e1e)),
      extensions: [
        _darkAppColors
      ],
    );
  }();

  static final _darkAppColors = AppColorsExtension(
      appBar: const Color(0xff16171a),
      navBar: const Color(0xff1c1d21),
      background: const Color(0xff2c2c2c),
      scheduleLineColor: const Color(0xff3d3d3d)
  );
}

extension AppThemeExtension on ThemeData {
  AppColorsExtension get appColors => extension<AppColorsExtension>() ?? AppTheme._lightAppColors;
}

extension ThemeGetter on BuildContext {
  ThemeData get theme => Theme.of(this);
}