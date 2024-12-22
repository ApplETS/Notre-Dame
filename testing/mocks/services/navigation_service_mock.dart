// Package imports:
import 'package:mockito/annotations.dart';

// Project imports:
import 'package:notredame/data/services/navigation_service.dart';
import '../../../test/features/app/navigation/mocks/navigation_service_mock.mocks.dart';

/// Mock for the [NavigationService]
@GenerateNiceMocks([MockSpec<NavigationService>()])
class NavigationServiceMock extends MockNavigationService {}
