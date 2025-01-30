import 'package:flutter/material.dart';

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  AppColorsExtension({
    required this.appBar,
    required this.navBar,
    required this.background
  });

  final Color appBar;
  final Color navBar;
  final Color background;

  @override
  ThemeExtension<AppColorsExtension> copyWith({
    Color? appBar,
    Color? navBar,
    Color? background
  }) {
    return AppColorsExtension(
      appBar: appBar ?? this.appBar,
      navBar: navBar ?? this.navBar,
      background: background ?? this.background
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
    );
  }
}