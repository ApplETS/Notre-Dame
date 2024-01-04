// Package imports:
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:package_info_plus/package_info_plus.dart';

// Project imports:
import 'package:notredame/core/services/internal_info_service.dart';

import 'internal_info_service_mock.mocks.dart';

@GenerateNiceMocks([MockSpec<InternalInfoService>()])
class InternalInfoServiceMock extends MockInternalInfoService {
  /// Stub the answer of [getDeviceInfoForErrorReporting]
  static void stubGetDeviceInfoForErrorReporting(InternalInfoServiceMock mock) {
    when(mock.getDeviceInfoForErrorReporting())
        .thenAnswer((_) async => "error");
  }

  /// Stub the answer of [getPackageInfo]
  static void stubGetPackageInfo(InternalInfoServiceMock mock,
      {String version = "0.0.0"}) {
    when(mock.getPackageInfo()).thenAnswer((_) async => PackageInfo(
        appName: "ÉTSMobile",
        packageName: "ca.etsmtl.applets.etsmobile",
        version: version,
        buildNumber: "1"));
  }
}
