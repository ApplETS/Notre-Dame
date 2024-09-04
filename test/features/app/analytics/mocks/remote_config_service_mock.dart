// Package imports:
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/features/app/analytics/remote_config_service.dart';
import 'remote_config_service_mock.mocks.dart';

/// Mock for the [RemoteConfigService]
@GenerateNiceMocks([MockSpec<RemoteConfigService>()])
class RemoteConfigServiceMock extends MockRemoteConfigService {
  /// Stub the getter [coursesActivities] of [mock] when called will return [toReturn].
  static void stubGetCalendarViewEnabled(RemoteConfigServiceMock mock,
      {bool toReturn = true}) {
    when(mock.scheduleListViewDefault).thenReturn(toReturn);
  }

  static void stubGetBroadcastEnabled(RemoteConfigServiceMock mock,
      {bool toReturn = true}) {
    when(mock.dashboardMessageActive).thenReturn(toReturn);
  }

  static void stubGetPrivacyPolicyEnabled(RemoteConfigServiceMock mock,
      {bool toReturn = true}) {
    when(mock.privacyPolicyToggle).thenReturn(toReturn);
  }

  static void stubGetBroadcastColor(RemoteConfigServiceMock mock,
      {String toReturn = "0xffd48404"}) {
    when(mock.dashboardMsgColor).thenReturn(Future.value(toReturn));
  }

  static void stubGetBroadcastTitleEn(RemoteConfigServiceMock mock,
      {String toReturn = "TitleEn"}) {
    when(mock.dashboardMessageTitleEn).thenReturn(Future.value(toReturn));
  }

  static void stubGetBroadcastTitleFr(RemoteConfigServiceMock mock,
      {String toReturn = "TitleFr"}) {
    when(mock.dashboardMessageTitleFr).thenReturn(Future.value(toReturn));
  }

  static void stubGetBroadcastEn(RemoteConfigServiceMock mock,
      {String toReturn = "En"}) {
    when(mock.dashboardMessageEn).thenReturn(Future.value(toReturn));
  }

  static void stubGetBroadcastFr(RemoteConfigServiceMock mock,
      {String toReturn = "Fr"}) {
    when(mock.dashboardMessageFr).thenReturn(Future.value(toReturn));
  }

  static void stubGetBroadcastType(RemoteConfigServiceMock mock,
      {String toReturn = "info"}) {
    when(mock.dashboardMsgType).thenReturn(Future.value(toReturn));
  }

  static void stubGetBroadcastUrl(RemoteConfigServiceMock mock,
      {String toReturn = "https://clubapplets.ca/"}) {
    when(mock.dashboardMsgUrl).thenReturn(Future.value(toReturn));
  }

  static void stubGetHelloFeatureToggle(RemoteConfigServiceMock mock,
      {bool toReturn = true}) {
    when(mock.helloFeatureToggle).thenReturn(toReturn);
  }
}
