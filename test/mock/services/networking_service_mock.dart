// Package imports:
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/core/services/networking_service.dart';

import 'networking_service_mock.mocks.dart';

/// Mock for the [NetworkingService]
@GenerateNiceMocks([MockSpec<NetworkingService>()])
class NetworkingServiceMock extends MockNetworkingService {
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
