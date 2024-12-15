// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/data/services/remote_config_service.dart';
import 'package:notredame/data/services/navigation_service.dart';
import 'package:notredame/domain/constants/router_paths.dart';
import 'package:notredame/locator.dart';

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
