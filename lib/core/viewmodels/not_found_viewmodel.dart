// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:stacked/stacked.dart';

// SERVICE
import 'package:notredame/core/services/analytics_service.dart';
import 'package:notredame/core/services/navigation_service.dart';
import 'package:notredame/core/services/rive_animation_service.dart';

// OTHER
import 'package:notredame/locator.dart';
import 'package:notredame/core/constants/router_paths.dart';

class NotFoundViewModel extends BaseViewModel {
  static const String tag = "NotFoundViewModel";

  /// Used to redirect on the dashboard.
  final NavigationService _navigationService = locator<NavigationService>();

  /// Used to log the event that pushed it from
  final AnalyticsService _analyticsService = locator<AnalyticsService>();

  /// Used to access the rive animations
  final RiveAnimationService _riveAnimationService = locator<RiveAnimationService>();

  final String _riveAnimationFileName = 'dot_jumping';

  final String notFoundPageName;

  Artboard _artboard;
  Artboard get artboard => _artboard;

  NotFoundViewModel({@required String pageName}) : notFoundPageName = pageName {
    _analyticsService.logEvent(tag, "An unknown page ($pageName) has been access from the app.");
  }

  void navigateToDashboard() {
    _navigationService.pushNamed(RouterPaths.schedule);
  }

  Future<void> loadRiveAnimation() async {
    try {
      _artboard = await _riveAnimationService.loadRiveFile(riveFileName: _riveAnimationFileName);
    } catch (e) {
      _analyticsService.logError(tag, "An Error has occured during rive animation $_riveAnimationFileName loading.");
    }
  }

  void startRiveAnimation() {
    try {
      _riveAnimationService.addControllerToAnimation(artboard: _artboard);
    } catch (e) {
      _analyticsService.logError(tag, "An Error has occured during rive animation start.");
    }
  }
}
