// Package imports:
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/features/app/integration/launch_url_service.dart';
import 'launch_url_service_mock.mocks.dart';

/// Mock for the [LaunchUrlService]
@GenerateNiceMocks([MockSpec<LaunchUrlService>()])
class LaunchUrlServiceMock extends MockLaunchUrlService {

}
