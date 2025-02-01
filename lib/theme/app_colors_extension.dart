import 'package:flutter/material.dart';

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  AppColorsExtension({
    required this.appBar,
    required this.navBar,
    required this.backgroundAlt,
    required this.backgroundVibrant,
    required this.scheduleLine,
    required this.tabBarLabel,
    required this.tabBarIndicator,
    required this.shimmerHighlight,
    required this.vibrantAppBar,
    required this.newsAccent,
    required this.newsBackgroundVibrant
  });

  final Color appBar;
  final Color navBar;
  final Color backgroundAlt;
  final Color backgroundVibrant;
  final Color scheduleLine;
  final Color tabBarLabel;
  final Color tabBarIndicator;
  final Color shimmerHighlight;
  final Color vibrantAppBar;
  final Color newsAccent;
  final Color newsBackgroundVibrant;

  @override
  ThemeExtension<AppColorsExtension> copyWith({
    Color? appBar,
    Color? navBar,
    Color? backgroundAlt,
    Color? backgroundVibrant,
    Color? scheduleLine,
    Color? tabBarLabel,
    Color? tabBarIndicator,
    Color? shimmerHighlight,
    Color? vibrantAppBar,
    Color? newsAccent,
    Color? newsBackgroundVibrant,
  }) {
    return AppColorsExtension(
      appBar: appBar ?? this.appBar,
      navBar: navBar ?? this.navBar,
      backgroundAlt: backgroundAlt ?? this.backgroundAlt,
      backgroundVibrant: backgroundVibrant ?? this.backgroundVibrant,
      scheduleLine: scheduleLine ?? this.scheduleLine,
      tabBarLabel: tabBarLabel ?? this.tabBarLabel,
      tabBarIndicator: tabBarIndicator ?? this.tabBarIndicator,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
      vibrantAppBar: vibrantAppBar ?? this.vibrantAppBar,
      newsAccent: newsAccent ?? this.newsAccent,
      newsBackgroundVibrant: newsBackgroundVibrant ?? this.newsBackgroundVibrant
    );
  }

  Color _lerp(Color a, Color b, double t) => Color.lerp(a, b, t)!;

  @override
  ThemeExtension<AppColorsExtension> lerp(
      covariant ThemeExtension<AppColorsExtension>? other,
      double t,
      ) {
    if (other is! AppColorsExtension) {
      return this;
    }

    return AppColorsExtension(
      appBar: _lerp(appBar, other.appBar, t),
      navBar: _lerp(navBar, other.navBar, t),
      backgroundAlt: _lerp(backgroundAlt, other.backgroundAlt, t),
      backgroundVibrant: _lerp(backgroundVibrant, other.backgroundVibrant, t),
      scheduleLine: _lerp(scheduleLine, other.scheduleLine, t),
      tabBarLabel: _lerp(tabBarLabel, other.tabBarLabel, t),
      tabBarIndicator: _lerp(tabBarIndicator, other.tabBarIndicator, t),
      shimmerHighlight: _lerp(shimmerHighlight, other.shimmerHighlight, t),
      vibrantAppBar: _lerp(vibrantAppBar, other.vibrantAppBar, t),
      newsAccent: _lerp(newsAccent, other.newsAccent, t),
      newsBackgroundVibrant: _lerp(newsBackgroundVibrant, other.newsBackgroundVibrant, t),
    );
  }
}