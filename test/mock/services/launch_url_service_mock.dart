// Package imports:
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/core/services/launch_url_service.dart';

import 'launch_url_service_mock.mocks.dart';

/// Mock for the [LaunchUrlService]
@GenerateNiceMocks([MockSpec<LaunchUrlService>()])
class LaunchUrlServiceMock extends MockLaunchUrlService {
  static void stubCanLaunchUrl(LaunchUrlServiceMock client, String url,
      {bool toReturn = true}) {
    when(client.canLaunch(url)).thenAnswer((_) async => toReturn);
  }

  static void stubLaunchUrl(LaunchUrlServiceMock client, String url,
      {bool toReturn = true}) {
    when(client.launch(url)).thenAnswer((_) async => toReturn);
  }
}
