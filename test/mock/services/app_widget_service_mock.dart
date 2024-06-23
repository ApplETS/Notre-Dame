// Package imports:
import 'package:mockito/annotations.dart';

// Project imports:
import 'package:notredame/features/app/widgets/app_widget_service.dart';
import 'app_widget_service_mock.mocks.dart';

/// Mock for the [AppWidgetService]
@GenerateNiceMocks([MockSpec<AppWidgetService>()])
class AppWidgetServiceMock extends MockAppWidgetService {}
