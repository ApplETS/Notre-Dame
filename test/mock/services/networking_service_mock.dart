// FLUTTER / DART / THIRD-PARTIES
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mockito/mockito.dart';

// SERVICE
import 'package:notredame/core/services/networking_service.dart';

/// Mock for the [NetworkingService]
class NetworkingServiceMock extends Mock implements NetworkingService {
  /// Stub the user connection state
  static void stubHasConnectivity(NetworkingServiceMock service,
      {bool hasConnectivity = true}) {
    when(service.hasConnectivity()).thenAnswer((_) async => hasConnectivity);
  }

  static void stubChangeConnectivityStream(NetworkingServiceMock service) {
    when(service.onConnectivityChanged)
        .thenAnswer((_) => Stream.fromIterable([ConnectivityResult.wifi]));
  }
}
