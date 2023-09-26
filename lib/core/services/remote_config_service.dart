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
  static const _dashboardMsgColor = "dashboard_message_color";
  static const _dashboardMsgUrl = "dashboard_message_url";
  static const _dashboardMsgType = "dashboard_message_type";

  static const _scheduleListViewDefault = "schedule_list_view_default";
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  final defaults = <String, dynamic>{
    _serviceIsDown: false,
    _dashboardMsgFr: "",
    _dashboardMsgEn: "",
    _dashboardMsgTitleFr: "",
    _dashboardMsgTitleEn: "",
    _dashboardMsgColor: "",
    _dashboardMsgUrl: "",
    _dashboardMsgType: "",
    _scheduleListViewDefault: true
  };

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

  String get dashboardMessageFr {
    fetch();
    return _remoteConfig.getString(_dashboardMsgFr);
  }

  String get dashboardMessageEn {
    fetch();
    return _remoteConfig.getString(_dashboardMsgEn);
  }

  String get dashboardMessageTitleFr {
    fetch();
    return _remoteConfig.getString(_dashboardMsgTitleFr);
  }

  String get dashboardMessageTitleEn {
    fetch();
    return _remoteConfig.getString(_dashboardMsgTitleEn);
  }

  String get dashboardMsgColor {
    fetch();
    return _remoteConfig.getString(_dashboardMsgColor);
  }

  String get dashboardMsgUrl {
    fetch();
    return _remoteConfig.getString(_dashboardMsgUrl);
  }

  String get dashboardMsgType {
    fetch();
    return _remoteConfig.getString(_dashboardMsgType);
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
