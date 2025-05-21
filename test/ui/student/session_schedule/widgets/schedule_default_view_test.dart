// Package imports:
import 'package:notredame/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/data/repositories/course_repository.dart';
import 'package:notredame/data/services/navigation_service.dart';
import 'package:notredame/data/services/networking_service.dart';
import 'package:notredame/ui/student/session_schedule/widgets/session_schedule.dart';
import 'package:notredame/ui/student/session_schedule/widgets/session_schedule_view.dart';
import '../../../../data/mocks/repositories/course_repository_mock.mocks.dart';
import '../../../../helpers.dart';

void main() {
  late CourseRepository mockCourseRepository;
  late AppIntl intl;

  group('ScheduleDefaultView -', () {
    setUp(() async {
      intl = await setupAppIntl();
      setupLogger();

      setupNavigationServiceMock();
      mockCourseRepository = setupCourseRepositoryMock();
      setupNetworkingServiceMock();
    });

    tearDown(() {
      unregister<NavigationService>();
      unregister<CourseRepository>();
      unregister<NetworkingService>();
    });

    testWidgets('ScheduleDefaultView has a title and shows schedule', (WidgetTester tester) async {
      mockCourseRepository = MockCourseRepository();
      when(mockCourseRepository.getDefaultScheduleActivities(session: "valid_session")).thenAnswer((_) async => []);
      await tester.pumpWidget(localizedWidget(child: const SessionScheduleView(sessionCode: "A2023")));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      final fallSessionText = find.text("${intl.session_fall} 2023");
      expect(fallSessionText, findsOneWidget);
      expect(find.byType(SessionSchedule), findsOneWidget);
    });
  });
}
