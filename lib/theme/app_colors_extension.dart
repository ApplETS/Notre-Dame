import 'package:flutter/material.dart';

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  AppColorsExtension({
    required this.appBar,
    required this.navBar,
    required this.background,
    required this.scheduleLineColor
  });

  final Color appBar;
  final Color navBar;
  final Color background;
  final Color scheduleLineColor;

  @override
  ThemeExtension<AppColorsExtension> copyWith({
    Color? appBar,
    Color? navBar,
    Color? background,
    Color? scheduleLineColor
  }) {
    return AppColorsExtension(
      appBar: appBar ?? this.appBar,
      navBar: navBar ?? this.navBar,
      background: background ?? this.background,
      scheduleLineColor: scheduleLineColor ?? this.scheduleLineColor
    );
  }

  @override
  ThemeExtension<AppColorsExtension> lerp(
      covariant ThemeExtension<AppColorsExtension>? other,
      double t,
      ) {
    if (other is! AppColorsExtension) {
      return this;
    }

    return AppColorsExtension(
      appBar: Color.lerp(appBar, other.appBar, t)!,
      navBar: Color.lerp(navBar, other.navBar, t)!,
      background: Color.lerp(background, other.background, t)!,
      scheduleLineColor: Color.lerp(scheduleLineColor, other.scheduleLineColor, t)!
    );
  }
}