// FLUTTER / DART / THIRD-PARTIES
//SERVICE
import 'package:notredame/core/services/analytics_service.dart';

//OTHERS
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:notredame/locator.dart';

/// Manage the analytics of the application
class RemoteConfigService {
  static const _serviceIsDown = "service_is_down";
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  final defaults = <String, dynamic>{_serviceIsDown: false};
  static const String tag = "RemoteConfigService";

  Future initialize() async {
    await _remoteConfig.setDefaults(defaults);
    await _fetchAndActivate();
  }

  bool get outage {
    fetch();
    return _remoteConfig.getBool(_serviceIsDown);
  }

  Future<String> get dashboardMessageFr async {
    fetch();
    return _remoteConfig.getString("dashboard_message_fr");
  }

  Future<String> get dashboardMessageEn async {
    fetch();
    return _remoteConfig.getString("dashboard_message_en");
  }

  Future<void> fetch() async {
    final AnalyticsService analyticsService = locator<AnalyticsService>();
    try {
      await _remoteConfig.fetch();
      await _remoteConfig.fetchAndActivate();
    } on Exception catch (exception) {
      analyticsService.logError(
          tag,
          "Exception raised during fetching: ${exception.toString()}",
          exception);
    }
  }

  Future _fetchAndActivate() async {
    fetch();
    _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 30),
      minimumFetchInterval: const Duration(minutes: 1),
    ));
  }
}
