// Package imports:
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pub_semver/pub_semver.dart';

// Project imports:
import 'package:notredame/core/services/siren_flutter_service.dart';

import 'siren_flutter_service_mock.mocks.dart';

/// Mock for the [SirenFlutterService]
@GenerateNiceMocks([MockSpec<SirenFlutterService>()])
class SirenFlutterServiceMock extends MockSirenFlutterService {
  /// Stub the updateIsAvailable function of [SirenFlutterService]
  static void stubUpdateIsAvailable(SirenFlutterServiceMock mock,
      {bool valueToReturn = false}) {
    when(mock.updateIsAvailable()).thenAnswer((_) async => valueToReturn);
  }

  /// Stub the localVersion function of [SirenFlutterService]
  static void stubLocalVersion(SirenFlutterServiceMock mock,
      {required Version valueToReturn}) {
    when(mock.localVersion).thenAnswer((_) async => valueToReturn);
  }

  /// Stub the storeVersion function of [SirenFlutterService]
  static void stubStoreVersion(SirenFlutterServiceMock mock,
      {required Version valueToReturn}) {
    when(mock.storeVersion).thenAnswer((_) async => valueToReturn);
  }
}
