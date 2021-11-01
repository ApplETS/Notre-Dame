// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:pub_semver/pub_semver.dart';

// SERVICE
import 'package:notredame/core/services/siren_flutter_service.dart';

/// Mock for the [SirenFlutterService]
class SirenFlutterServiceMock extends Mock implements SirenFlutterService {
  /// Stub the updateIsAvailable function of [SirenFlutterService]
  static void stubUpdateIsAvailable(SirenFlutterServiceMock mock,
      {bool valueToReturn = false}) {
    when(mock.updateIsAvailable()).thenAnswer((_) async => valueToReturn);
  }

  /// Stub the localVersion function of [SirenFlutterService]
  static void stubLocalVersion(SirenFlutterServiceMock mock,
      {@required Version valueToReturn}) {
    when(mock.localVersion).thenAnswer((_) async => valueToReturn);
  }

  /// Stub the storeVersion function of [SirenFlutterService]
  static void stubStoreVersion(SirenFlutterServiceMock mock,
      {@required Version valueToReturn}) {
    when(mock.storeVersion).thenAnswer((_) async => valueToReturn);
  }
}
