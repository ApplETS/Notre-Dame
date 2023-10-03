// Package imports:
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/core/services/launch_url_service.dart';

/// Mock for the [LaunchUrlService]
class LaunchUrlServiceMock extends Mock implements LaunchUrlService {
  static void stubCanLaunchUrl(LaunchUrlServiceMock client, String url,
      {bool toReturn = true}) {
    when(client.canLaunch(url)).thenAnswer((_) async => toReturn);
  }

  static void stubLaunchUrl(LaunchUrlServiceMock client, String url,
      {bool toReturn = true}) {
    when(client.launch(url)).thenAnswer((_) async => toReturn);
  }
}
