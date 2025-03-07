//SERVICE

// Package imports:
import 'package:firebase_remote_config/firebase_remote_config.dart';

// Project imports:
import 'package:notredame/data/services/analytics_service.dart';
import 'package:notredame/locator.dart';

//OTHERS

/// Manage the analytics of the application
class RemoteConfigService {
  static const String tag = "RemoteConfigService";
  static const _serviceIsDown = "service_is_down";

  // Privacy policy
  static const _privacyPolicyToggle = "privacy_policy_toggle";
  static const _privacyPolicyURL = "privacy_policy_url";

  // dashboard message remote config keys
  static const _dashboardMsgToggle = "dashboard_message_toggle";
  static const _dashboardMsgFr = "dashboard_message_fr";
  static const _dashboardMsgEn = "dashboard_message_en";
  static const _dashboardMsgTitleFr = "dashboard_message_title_fr";
  static const _dashboardMsgTitleEn = "dashboard_message_title_en";
  static const _dashboardMsgColor = "dashboard_message_color";
  static const _dashboardMsgUrl = "dashboard_message_url";
  static const _dashboardMsgType = "dashboard_message_type";

  // links
  static const _signetsPasswordResetUrl = "signets_password_reset_url";

  // Hello
  static const _helloFeatureToggle = "hello_feature_toggle";
  static const _helloApiUrl = "hello_api_url";
  static const _helloWebsiteUrl = "hello_website_url";

  static const _scheduleListViewDefault = "schedule_list_view_default";
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  final defaults = <String, dynamic>{
    _serviceIsDown: false,
    _privacyPolicyURL: "",
    _dashboardMsgFr: "",
    _dashboardMsgEn: "",
    _dashboardMsgTitleFr: "",
    _dashboardMsgTitleEn: "",
    _dashboardMsgColor: "",
    _dashboardMsgUrl: "",
    _dashboardMsgType: "",
    _signetsPasswordResetUrl: "",
    _privacyPolicyToggle: true,
    _scheduleListViewDefault: true,
    _helloFeatureToggle: false,
    _helloApiUrl: "",
    _helloWebsiteUrl: "",
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

  bool get privacyPolicyToggle {
    fetch();
    return _remoteConfig.getBool(_privacyPolicyToggle);
  }

  String get privacyPolicyUrl {
    fetch();
    return _remoteConfig.getString(_privacyPolicyURL);
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

  String get signetsPasswordResetUrl {
    fetch();
    return _remoteConfig.getString(_signetsPasswordResetUrl);
  }

  bool get helloFeatureToggle {
    fetch();
    return _remoteConfig.getBool(_helloFeatureToggle);
  }

  String get helloApiUrl {
    fetch();
    return _remoteConfig.getString(_helloApiUrl);
  }

  String get helloWebsiteUrl {
    fetch();
    return _remoteConfig.getString(_helloWebsiteUrl);
  }

  Future<String> get aadAndroidRedirectUri async {
    await fetch();
    return _remoteConfig.getString("AAD_ANDROID_REDIRECT_URI_DEBUG");
  }

  Future<String> get aadAppleAuthority async {
    await fetch();
    return _remoteConfig.getString("AAD_APPLE_AUTHORITY");
  }

  Future<String> get aadClientId async {
    await fetch();
    return _remoteConfig.getString("AAD_CLIENT_ID_DEBUG");
  }

  Future<void> fetch() async {
    final AnalyticsService analyticsService = locator<AnalyticsService>();
    try {
      await _remoteConfig.fetch();
      await _remoteConfig.fetchAndActivate();
    } on Exception catch (exception) {
      analyticsService.logError(
          tag, "Exception raised during fetching: $exception", exception);
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
