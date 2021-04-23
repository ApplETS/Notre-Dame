// FLUTTER / DART / THIRD-PARTIES
import 'package:mockito/mockito.dart';

// SERVICE
import 'package:notredame/core/services/networking_service.dart';

/// Mock for the [NetworkingService]
class NetworkingServiceMock extends Mock implements NetworkingService {
  /// Stub the localFile of propertie [localFile] and return [fileToReturn].
  static void stubHasConnectivityIssue(NetworkingServiceMock service) {
    when(service.hasConnectivity()).thenAnswer((_) async => true);
  }
}
