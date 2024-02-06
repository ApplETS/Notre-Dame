// Package imports:
import 'package:mockito/annotations.dart';

// Project imports:
import 'package:notredame/core/services/app_widget_service.dart';

import 'app_widget_service_mock.mocks.dart';

/// Mock for the [AppWidgetService]
@GenerateNiceMocks([MockSpec<AppWidgetService>()])
class AppWidgetServiceMock extends MockAppWidgetService {}
