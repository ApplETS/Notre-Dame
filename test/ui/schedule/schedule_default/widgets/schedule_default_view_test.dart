// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/data/services/networking_service.dart';
import 'package:notredame/data/services/navigation_service.dart';
import 'package:notredame/data/repositories/course_repository.dart';
import 'package:notredame/ui/schedule/schedule_default/widgets/schedule_default.dart';
import 'package:notredame/ui/schedule/schedule_default/widgets/schedule_default_view.dart';
import '../../../../data/mocks/repositories/course_repository_mock.mocks.dart';
import '../../../../helpers.dart';

void main() {
  late CourseRepository mockCourseRepository;
  // late ScheduleActivity lectureActivity;
  late AppIntl intl;

  group('ScheduleDefaultView -', () {
    setUp(() async {
      intl = await setupAppIntl();
      setupLogger();

      setupNavigationServiceMock();
      mockCourseRepository = setupCourseRepositoryMock();
      setupNetworkingServiceMock();
      // lectureActivity = ScheduleActivity(
      //     activityCode: "C",
      //     activityLocation: "B-3428",
      //     courseAcronym: "GTI725",
      //     courseGroup: "01",
      //     courseTitle: "Interfaces utilisateurs avancées",
      //     day: "Jeudi",
      //     dayOfTheWeek: 4,
      //     endTime: DateTime(2024, 1, 1, 12),
      //     isPrincipalActivity: true,
      //     name: "Activité de cours",
      //     startTime: DateTime(2024, 1, 1, 8, 30));
    });

    tearDown(() {
      unregister<NavigationService>();
      unregister<CourseRepository>();
      unregister<NetworkingService>();
    });

    testWidgets('ScheduleDefaultView has a title and shows schedule',
        (WidgetTester tester) async {
      mockCourseRepository = MockCourseRepository();
      when(mockCourseRepository.getDefaultScheduleActivities(
              session: "valid_session"))
          .thenAnswer((_) async => []);
      await tester.pumpWidget(localizedWidget(
          child: const ScheduleDefaultView(sessionCode: "A2023")));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      final fallSessionText = find.text("${intl.session_fall} 2023");
      expect(fallSessionText, findsOneWidget);
      expect(find.byType(ScheduleDefault), findsOneWidget);
    });
  });
}
