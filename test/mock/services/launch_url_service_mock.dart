// FLUTTER / DART / THIRD-PARTIES
import 'package:mockito/mockito.dart';

// SERVICE
import 'package:notredame/core/services/launch_url_service.dart';

/// Mock for the [LaunchUrlService]
class LaunchUrlServiceMock extends Mock implements LaunchUrlService {
  static void stubCanLaunchUrl(LaunchUrlServiceMock client, String url,
      {bool toReturn = true}) {
    when(client.canLaunchUrl(url)).thenAnswer((_) async => toReturn);
  }

  static void stubLaunchUrl(LaunchUrlServiceMock client, String url,
      {bool toReturn = true}) {
    when(client.launchUrl(url)).thenAnswer((_) async => toReturn);
  }
}
