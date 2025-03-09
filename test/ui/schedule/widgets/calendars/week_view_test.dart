// Package imports:
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
import 'package:notredame/ui/schedule/widgets/calendars/calendar_controller.dart';
import 'package:notredame/ui/schedule/widgets/calendars/week_calendar.dart';
import 'package:notredame/utils/utils.dart';
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
      startDateTime:
          Utils.getFirstdayOfWeek(DateTime.now()).add(Duration(hours: 9)),
      endDateTime:
          Utils.getFirstdayOfWeek(DateTime.now()).add(Duration(hours: 12)),
      courseGroup: 'LOG100',
      activityLocation: 'Room 102',
      activityName: 'Lab Session',
      activityDescription: 'Regular',
    ),
    CourseActivity(
      courseName: 'Lecture',
      startDateTime: Utils.getFirstdayOfWeek(DateTime.now())
          .add(Duration(days: 6, hours: 9)),
      endDateTime: Utils.getFirstdayOfWeek(DateTime.now())
          .add(Duration(days: 6, hours: 12)),
      courseGroup: 'ING150-01',
      activityLocation: 'Room 101',
      activityName: 'Lecture 1',
      activityDescription: 'Regular',
    )
  ];

  group("week calendar view - ", () {
    setUp(() async {
      settingsManagerMock = setupSettingsManagerMock();
      courseRepositoryMock = setupCourseRepositoryMock();
      await setupAppIntl();
      setupNetworkingServiceMock();
      setupAnalyticsServiceMock();

      SettingsRepositoryMock.stubLocale(settingsManagerMock);
      CourseRepositoryMock.stubGetScheduleActivities(courseRepositoryMock);
    });

    tearDown(() => {
          unregister<NavigationService>(),
          unregister<SettingsRepository>(),
          unregister<CourseRepository>(),
          unregister<RemoteConfigService>(),
          unregister<NetworkingService>(),
          unregister<AnalyticsService>(),
        });

    testWidgets("displays saturday and sunday", (WidgetTester tester) async {
      CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock);
      CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock,
          toReturn: activites);

      await tester.runAsync(() async {
        await tester.pumpWidget(
            localizedWidget(child: WeekCalendar(controller: CalendarController())));
        await tester.pumpAndSettle();
      });

      expect(find.text("ING150\nRoom 101\nLecture 1"), findsOneWidget);
      expect(find.text("LOG100\nRoom 102\nLab Session"), findsOneWidget);
      // Saturday and sunday displayed
      expect(find.text("S"), findsOneWidget);
      expect(find.text("D"), findsOneWidget);
    });

    testWidgets("does not display saturday and sunday",
        (WidgetTester tester) async {
      CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock);
      CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock,
          toReturn: []);

      await tester.runAsync(() async {
        await tester.pumpWidget(
            localizedWidget(child: WeekCalendar(controller: CalendarController())));
        await tester.pumpAndSettle();
      });

      // Saturday and sunday displayed
      expect(find.text("S"), findsNothing);
      expect(find.text("D"), findsNothing);
    });
  });
}
