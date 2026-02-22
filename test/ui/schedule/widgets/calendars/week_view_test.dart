// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:notredame/data/models/event_data.dart';
import 'package:notredame/data/repositories/course_repository.dart';
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/data/services/analytics_service.dart';
import 'package:notredame/data/services/navigation_service.dart';
import 'package:notredame/data/services/networking_service.dart';
import 'package:notredame/data/services/remote_config_service.dart';
import 'package:notredame/ui/schedule/schedule_controller.dart';
import 'package:notredame/ui/schedule/widgets/calendars/week_calendar.dart';
import 'package:notredame/utils/utils.dart';
import '../../../../data/mocks/repositories/course_repository_mock.dart';
import '../../../../data/mocks/repositories/settings_repository_mock.dart';
import '../../../../data/mocks/services/schedule_service_mock.dart';
import '../../../../helpers.dart';

void main() {
  SharedPreferences.setMockInitialValues({});
  late SettingsRepositoryMock settingsManagerMock;
  late CourseRepositoryMock courseRepositoryMock;
  late ScheduleServiceMock scheduleServiceMock;

  Map<DateTime, List<EventData>> events = {
    Utils.getFirstdayOfWeek(DateTime.now()): [
      EventData(
        courseAcronym: "LOG100",
        group: "LOG100-01",
        locations: ["D-2020"],
        activityName: "Cours",
        courseName: "Programmation et réseautique en génie logiciel",
        teacherName: "John Doe",
        date: Utils.getFirstdayOfWeek(DateTime.now()),
        startTime: Utils.getFirstdayOfWeek(DateTime.now()).add(Duration(hours: 9)),
        endTime: Utils.getFirstdayOfWeek(DateTime.now()).add(Duration(hours: 12)),
      ),
    ],
    Utils.getFirstdayOfWeek(DateTime.now()).add(Duration(days: 6)): [
      EventData(
        courseAcronym: "ING150",
        group: "ING150-01",
        locations: ["D-2020"],
        activityName: "Cours",
        courseName: "Statique et dynamique",
        teacherName: "Jane Doe",
        date: Utils.getFirstdayOfWeek(DateTime.now()),
        startTime: Utils.getFirstdayOfWeek(DateTime.now()).add(Duration(days: 6, hours: 9)),
        endTime: Utils.getFirstdayOfWeek(DateTime.now()).add(Duration(days: 6, hours: 12)),
      ),
    ],
  };

  group("week calendar view - ", () {
    setUp(() async {
      settingsManagerMock = setupSettingsRepositoryMock();
      courseRepositoryMock = setupCourseRepositoryMock();
      await setupAppIntl();
      setupNetworkingServiceMock();
      setupAnalyticsServiceMock();
      scheduleServiceMock = setupScheduleServiceMock();

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

    testWidgets("displays saturday and sunday", (WidgetTester tester) async {
      CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock);
      ScheduleServiceMock.stubEvents(scheduleServiceMock, events);

      await tester.runAsync(() async {
        await tester.pumpWidget(localizedWidget(child: WeekCalendar(controller: ScheduleController())));
        await tester.pumpAndSettle();
      });

      expect(find.text("LOG100"), findsOneWidget);
      expect(find.text("ING150"), findsOneWidget);
      // Saturday and sunday displayed
      expect(find.text("S"), findsOneWidget);
      expect(find.text("D"), findsOneWidget);
    });

    testWidgets("does not display saturday and sunday", (WidgetTester tester) async {
      CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock);
      CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock, toReturn: []);

      await tester.runAsync(() async {
        await tester.pumpWidget(localizedWidget(child: WeekCalendar(controller: ScheduleController())));
        await tester.pumpAndSettle();
      });

      // Saturday and sunday displayed
      expect(find.text("S"), findsNothing);
      expect(find.text("D"), findsNothing);
    });
  });
}
