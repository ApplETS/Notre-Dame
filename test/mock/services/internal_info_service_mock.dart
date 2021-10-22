// FLUTTER / DART / THIRD-PARTIES
import 'package:mockito/mockito.dart';
import 'package:notredame/core/services/internal_info_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

class InternalInfoServiceMock extends Mock implements InternalInfoService {
  /// Stub the answer of [getDeviceInfoForErrorReporting]
  static void stubGetDeviceInfoForErrorReporting(InternalInfoServiceMock mock) {
    when(mock.getDeviceInfoForErrorReporting())
        .thenAnswer((_) async => "error");
  }

  /// Stub the answer of [getPackageInfo]
  static void stubGetPackageInfo(InternalInfoServiceMock mock,
      {String version}) {
    when(mock.getPackageInfo()).thenAnswer((_) async => PackageInfo(
        appName: "ÉTSMobile",
        packageName: "ca.etsmtl.applets.etsmobile",
        version: version,
        buildNumber: "1"));
  }
}
