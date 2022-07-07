// FLUTTER / DART / THIRD-PARTIES
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';

/// Manage the analytics of the application
class RemoteConfigService {
  static const _ServiceIsDown = "service_is_down";
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  final defaults = <String, dynamic>{_ServiceIsDown: false};

  Future initialise() async {
    try {
      await _remoteConfig.setDefaults(defaults);
      await _fetchAndActivate();
    } catch (exception) {
      print('Unable to fetch remote config. Cached or default values will be '
          'used');
    }
  }

  bool get outage => _remoteConfig.getBool(_ServiceIsDown);

  Future _fetchAndActivate() async {
    await _remoteConfig.fetch();
    await _remoteConfig.fetchAndActivate();
    _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(seconds: 30),
    ));
  }
}
