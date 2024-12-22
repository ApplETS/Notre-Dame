// Package imports:
import 'package:mockito/annotations.dart';

// Project imports:
import 'package:notredame/data/services/analytics_service.dart';
import '../../../test/features/app/analytics/mocks/analytics_service_mock.mocks.dart';

/// Mock for the [AnalyticsService]
@GenerateNiceMocks([MockSpec<AnalyticsService>()])
class AnalyticsServiceMock extends MockAnalyticsService {}
