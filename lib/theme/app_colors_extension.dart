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
    required this.newsBackgroundVibrant,
    required this.newsAuthorProfile,
    required this.newsAuthorProfileDescription,
    required this.modalTitle,
    required this.modalHandle,
    required this.fadedText,
    required this.fadedInvertText,
    required this.faqCarouselCard
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
  final Color newsAuthorProfile;
  final Color newsAuthorProfileDescription;
  final Color modalTitle;
  final Color modalHandle;
  final Color fadedText;
  final Color fadedInvertText;
  final Color faqCarouselCard;

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
    Color? newsAuthorProfile,
    Color? newsAuthorProfileDescription,
    Color? modalTitle,
    Color? modalHandle,
    Color? fadedText,
    Color? fadedInvertText,
    Color? faqCarouselCard
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
      newsBackgroundVibrant: newsBackgroundVibrant ?? this.newsBackgroundVibrant,
      newsAuthorProfile: newsAuthorProfile ?? this.newsAuthorProfile,
      newsAuthorProfileDescription: newsAuthorProfileDescription ?? this.newsAuthorProfileDescription,
      modalTitle: modalTitle ?? this.modalTitle,
      modalHandle: modalHandle ?? this.modalHandle,
      fadedText: fadedText ?? this.fadedText,
      fadedInvertText: fadedInvertText ?? this.fadedInvertText,
      faqCarouselCard: faqCarouselCard ?? this.faqCarouselCard
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
      newsAuthorProfile: _lerp(newsAuthorProfile, other.newsBackgroundVibrant, t),
      newsAuthorProfileDescription: _lerp(newsAuthorProfileDescription, other.newsAuthorProfileDescription, t),
      modalTitle: _lerp(modalTitle, other.modalTitle, t),
      modalHandle: _lerp(modalHandle, other.modalHandle, t),
      fadedText: _lerp(fadedText, other.fadedText, t),
      fadedInvertText: _lerp(fadedInvertText, other.fadedInvertText, t),
      faqCarouselCard: _lerp(faqCarouselCard, other.faqCarouselCard, t)
    );
  }
}