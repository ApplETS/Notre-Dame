import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class DashboardViewModelV5 extends ChangeNotifier {
  /// Localization class of the application.
  final AppIntl _appIntl;

  /// Static flag to track if the animation has been played
  static bool hasAnimationPlayed = false;

  /// Tracks if the animation should be played
  final bool shouldPlayAnimation;

  /// TODO : add AppIntl to the messages
  DashboardViewModelV5({required AppIntl intl})
      : _appIntl = intl,

        /// if the animation has not been played, play it
        shouldPlayAnimation = !hasAnimationPlayed {
    hasAnimationPlayed = true;
  }

  late AnimationController controller;
  late Animation<double> heightAnimation;
  late Animation<double> opacityAnimation;
  late Animation<double> titleAnimation;

  /// Loading state of the widget
  bool isLoading = false;

  /// Slide offset for title and subtitle animations (slide from top)
  /// Vertical slide offset from 0.0 (x), -15.0 (y) to 0 (y)
  Offset get titleSlideOffset => Offset(0.0, -15.0 * (1 - titleAnimation.value));

  /// Fade-in opacity based on title animation progress
  double get titleFadeOpacity => titleAnimation.value;

  /// Animation controller for the circle
  void init(TickerProvider ticker) {
    controller = AnimationController(
      vsync: ticker,
      duration: const Duration(milliseconds: 1250),
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

    /// Play the animation if it hasn't been played before
    /// Otherwise, set the animation to value 100%
    if (shouldPlayAnimation) {
      controller.forward();
    } else {
      controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
