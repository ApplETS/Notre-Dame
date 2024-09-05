// Flutter imports:
import 'dart:async';

import 'package:flutter/material.dart';

// Package imports:
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/features/app/analytics/remote_config_service.dart';
import 'package:notredame/features/app/navigation/navigation_service.dart';
import 'package:notredame/features/app/navigation/router_paths.dart';
import 'package:notredame/utils/locator.dart';

class OutageViewModel extends BaseViewModel {
  final BuildContext _context;
  Timer? _timer;

  OutageViewModel(this._context) {
    setupPeriodicTimer();
  }

  void setupPeriodicTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer t) {
      refreshOutageConfig();
    });
  }

  double getImagePlacement() {
    return MediaQuery.of(_context).size.height * 0.10;
  }

  double getTextPlacement() {
    return MediaQuery.of(_context).size.height * 0.15;
  }

  double getButtonPlacement() {
    return MediaQuery.of(_context).size.height * 0.08;
  }

  double getContactTextHeight() {
    return MediaQuery.of(_context).size.height * 0.06;
  }

  void refreshOutageConfig() {
    final RemoteConfigService remoteConfigService =
        locator<RemoteConfigService>();
    if (!remoteConfigService.outage) {
      _timer?.cancel();
      final NavigationService navigationService = locator<NavigationService>();
      navigationService.pushNamedAndRemoveUntil(RouterPaths.startup);
    }
  }
}
