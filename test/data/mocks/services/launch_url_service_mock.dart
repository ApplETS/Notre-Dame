// Package imports:
import 'package:mockito/annotations.dart';

// Project imports:
import 'package:notredame/data/services/launch_url_service.dart';
import 'launch_url_service_mock.mocks.dart';

/// Mock for the [LaunchUrlService]
@GenerateNiceMocks([MockSpec<LaunchUrlService>()])
class LaunchUrlServiceMock extends MockLaunchUrlService {}
