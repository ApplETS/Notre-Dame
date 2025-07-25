// Package imports:
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:notredame/data/repositories/course_repository.dart';
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/data/services/analytics_service.dart';
import 'package:notredame/data/services/navigation_service.dart';
import 'package:notredame/data/services/networking_service.dart';
import 'package:notredame/data/services/remote_config_service.dart';
import 'package:notredame/data/services/signets-api/models/course_activity.dart';
import 'package:notredame/ui/schedule/schedule_controller.dart';
import 'package:notredame/ui/schedule/widgets/calendars/month_calendar.dart';
import '../../../../data/mocks/repositories/course_repository_mock.dart';
import '../../../../data/mocks/repositories/settings_repository_mock.dart';
import '../../../../helpers.dart';

void main() {
  SharedPreferences.setMockInitialValues({});
  late SettingsRepositoryMock settingsManagerMock;
  late CourseRepositoryMock courseRepositoryMock;

  List<CourseActivity> activites = [
    CourseActivity(
      courseName: 'Lab',
      startDateTime: DateTime.now().withoutTime.add(Duration(hours: 9)),
      endDateTime: DateTime.now().withoutTime.add(Duration(hours: 12)),
      courseGroup: 'LOG100',
      activityLocation: ['Room 102'],
      activityName: 'Lab Session',
      activityDescription: 'Regular',
    ),
    CourseActivity(
      courseName: 'Lecture',
      startDateTime: DateTime.now().withoutTime.add(Duration(hours: 14)),
      endDateTime: DateTime.now().withoutTime.add(Duration(hours: 17)),
      courseGroup: 'ING150',
      activityLocation: ['Room 101'],
      activityName: 'Lecture 1',
      activityDescription: 'Regular',
    ),
  ];

  group("month calendar view - ", () {
    setUp(() async {
      settingsManagerMock = setupSettingsRepositoryMock();
      courseRepositoryMock = setupCourseRepositoryMock();
      await setupAppIntl();
      setupNetworkingServiceMock();
      setupAnalyticsServiceMock();

      SettingsRepositoryMock.stubLocale(settingsManagerMock);
      CourseRepositoryMock.stubGetScheduleActivities(courseRepositoryMock);
    });

    tearDown(
      () => {
        unregister<NavigationService>(),
        unregister<SettingsRepository>(),
        unregister<CourseRepository>(),
        unregister<RemoteConfigService>(),
        unregister<NetworkingService>(),
        unregister<AnalyticsService>(),
      },
    );

    testWidgets("displays events", (WidgetTester tester) async {
      CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock);
      CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock, toReturn: activites);

      await tester.runAsync(() async {
        await tester.pumpWidget(localizedWidget(child: MonthCalendar(controller: ScheduleController())));
        await tester.pumpAndSettle();
      });

      expect(find.byType(FilledCell), findsExactly(42));
      expect(find.text("LOG100\nRoom 102\nLab Session"), findsOneWidget);
      expect(find.text("ING150\nRoom 101\nLecture 1"), findsOneWidget);
    });
  });
}
