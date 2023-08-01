// FLUTTER / DART / THIRD-PARTIES
import 'package:mockito/mockito.dart';
import 'package:notredame/core/services/remote_config_service.dart';

/// Mock for the [RemoteConfigService]
class RemoteConfigServiceMock extends Mock implements RemoteConfigService {
  /// Stub the getter [coursesActivities] of [mock] when called will return [toReturn].
  static void stubGetCalendarViewEnabled(RemoteConfigServiceMock mock,
      {bool toReturn = true}) {
    when(mock.scheduleListViewDefault).thenReturn(toReturn);
  }
}
