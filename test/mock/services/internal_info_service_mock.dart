// FLUTTER / DART / THIRD-PARTIES
import 'package:mockito/mockito.dart';
import 'package:notredame/core/services/internal_info_service.dart';

class InternalInfoServiceMock extends Mock implements InternalInfoService {
  
  /// Stub the answer of [fromPlatform]
  static void stubGetDeviceInfoForErrorReporting(InternalInfoServiceMock mock) {
    when(mock.getDeviceInfoForErrorReporting()).thenAnswer((_) async => "error");
  }
}

