import 'package:flutter/material.dart';

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  AppColorsExtension({
    required this.appBar,
    required this.navBar,
    required this.backgroundAlt,
    required this.scheduleLine,
    required this.tabBarLabel,
    required this.tabBarIndicator,
    required this.shimmerHighlight,
  });

  final Color appBar;
  final Color navBar;
  final Color backgroundAlt;
  final Color scheduleLine;
  final Color tabBarLabel;
  final Color tabBarIndicator;
  final Color shimmerHighlight;

  @override
  ThemeExtension<AppColorsExtension> copyWith({
    Color? appBar,
    Color? navBar,
    Color? backgroundAlt,
    Color? scheduleLine,
    Color? tabBarLabel,
    Color? tabBarIndicator,
    Color? shimmerHighlight
  }) {
    return AppColorsExtension(
      appBar: appBar ?? this.appBar,
      navBar: navBar ?? this.navBar,
      backgroundAlt: backgroundAlt ?? this.backgroundAlt,
      scheduleLine: scheduleLine ?? this.scheduleLine,
      tabBarLabel: tabBarLabel ?? this.tabBarLabel,
      tabBarIndicator: tabBarIndicator ?? this.tabBarIndicator,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight
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
      backgroundAlt: Color.lerp(backgroundAlt, other.backgroundAlt, t)!,
      scheduleLine: Color.lerp(scheduleLine, other.scheduleLine, t)!,
      tabBarLabel: Color.lerp(tabBarLabel, other.tabBarLabel, t)!,
      tabBarIndicator: Color.lerp(tabBarIndicator, other.tabBarIndicator, t)!,
      shimmerHighlight: Color.lerp(shimmerHighlight, other.shimmerHighlight, t)!
    );
  }
}