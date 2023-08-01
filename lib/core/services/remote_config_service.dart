// FLUTTER / DART / THIRD-PARTIES
//SERVICE
import 'package:notredame/core/services/analytics_service.dart';

//OTHERS
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:notredame/locator.dart';

/// Manage the analytics of the application
class RemoteConfigService {
  static const String tag = "RemoteConfigService";
  static const _serviceIsDown = "service_is_down";

  // dashboard message remote config keys
  static const _dashboardMsgToggle = "dashboard_message_toggle";
  static const _dashboardMsgFr = "dashboard_message_fr";
  static const _dashboardMsgEn = "dashboard_message_en";
  static const _dashboardMsgTitleFr = "dashboard_message_title_fr";
  static const _dashboardMsgTitleEn = "dashboard_message_title_en";

  static const _scheduleListViewDefault = "schedule_list_view_default";
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  final defaults = <String, dynamic>{
    _serviceIsDown: false,
    _dashboardMsgFr: "",
    _dashboardMsgEn: "",
    _scheduleListViewDefault: true
    // TODO: either add default values for the rest or delete the ones above
  };

  static const String tag = "RemoteConfigService";

  Future initialize() async {
    await _remoteConfig.setDefaults(defaults);
    await _fetchAndActivate();
  }

  bool get outage {
    fetch();
    return _remoteConfig.getBool(_serviceIsDown);
  }

  bool get dashboardMessageActive {
    fetch();
    return _remoteConfig.getBool(_dashboardMsgToggle);
  }

  bool get scheduleListViewDefault {
    fetch();
    return _remoteConfig.getBool(_scheduleListViewDefault);
  }

  Future<String> get dashboardMessageFr async {
    fetch();
    return _remoteConfig.getString(_dashboardMsgFr);
  }

  Future<String> get dashboardMessageEn async {
    fetch();
    return _remoteConfig.getString(_dashboardMsgEn);
  }

  Future<String> get dashboardMessageTitleFr async {
    fetch();
    return _remoteConfig.getString(_dashboardMsgTitleFr);
  }

  Future<String> get dashboardMessageTitleEn async {
    fetch();
    return _remoteConfig.getString(_dashboardMsgTitleEn);
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
