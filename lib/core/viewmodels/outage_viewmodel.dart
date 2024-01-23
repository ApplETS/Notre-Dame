// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/core/constants/router_paths.dart';
import 'package:notredame/core/services/navigation_service.dart';
import 'package:notredame/core/services/remote_config_service.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/views/startup_view.dart';

class OutageViewModel extends BaseViewModel {
  int _lastTap = DateTime.now().millisecondsSinceEpoch;
  int _consecutiveTaps = 0;

  double getImagePlacement(BuildContext context) {
    return MediaQuery.of(context).size.height * 0.10;
  }

  double getTextPlacement(BuildContext context) {
    return MediaQuery.of(context).size.height * 0.20;
  }

  double getButtonPlacement(BuildContext context) {
    return MediaQuery.of(context).size.height * 0.08;
  }

  double getContactTextPlacement(BuildContext context) {
    return MediaQuery.of(context).size.height * 0.04;
  }

  void tapRefreshButton(BuildContext context) {
    final RemoteConfigService remoteConfigService =
        locator<RemoteConfigService>();
    if (!remoteConfigService.outage) {
      final NavigationService navigationService = locator<NavigationService>();
      navigationService.pushNamedAndRemoveUntil(RouterPaths.startup);
    }
  }

  void triggerTap(BuildContext context) {
    final int now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastTap < 1000) {
      _consecutiveTaps++;
      if (_consecutiveTaps > 4) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => StartUpView()),
        );
      }
    } else {
      _consecutiveTaps = 1;
    }
    _lastTap = now;
  }
}
