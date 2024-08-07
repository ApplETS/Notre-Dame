// Package imports:
import 'package:mockito/annotations.dart';

// Project imports:
import 'package:notredame/features/app/navigation/navigation_service.dart';
import 'navigation_service_mock.mocks.dart';

/// Mock for the [NavigationService]
@GenerateNiceMocks([MockSpec<NavigationService>()])
class NavigationServiceMock extends MockNavigationService {}
