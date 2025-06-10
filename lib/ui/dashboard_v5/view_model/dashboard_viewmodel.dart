import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class DashboardViewModelV5 extends ChangeNotifier {
  /// Localization class of the application.
  final AppIntl _appIntl;

  /// TODO : add AppIntl to the messages
  DashboardViewModelV5({required AppIntl intl}) : _appIntl = intl;

  late AnimationController controller;
  late Animation<double> heightAnimation;
  late Animation<double> opacityAnimation;
  late Animation<double> titleAnimation;

  /// Loading state of the widget
  bool isLoading = false;

  /// Slide offset for title and subtitle animations (slide from top)
  /// Vertical slide offset from ( 0.0 (x), -15.0 (y) ) to 0 (y)
  Offset get titleSlideOffset => Offset(0.0, -15.0 * (1 - titleAnimation.value));

  /// Fade-in opacity based on title animation progress
  double get titleFadeOpacity => titleAnimation.value;

  /// Animation controller for the circle
  void init(TickerProvider ticker) {
    controller = AnimationController(
      vsync: ticker,
      duration: const Duration(milliseconds: 1500),
    );

    // Animation of the circle's height
    // Grows from (0) to the end (330)
    heightAnimation = Tween<double>(begin: 0, end: 330).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.ease,
      ),
    );

    // Animation for the circle's opacity
    // From transparent (0.0) to opaque (1.0)
    opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );

    /// Animation for the title and subtitle
    titleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );

    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
