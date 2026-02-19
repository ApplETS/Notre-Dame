// Package imports:
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notredame/data/models/event_data.dart';
import 'package:notredame/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:notredame/data/repositories/course_repository.dart';
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/data/services/analytics_service.dart';
import 'package:notredame/data/services/navigation_service.dart';
import 'package:notredame/data/services/networking_service.dart';
import 'package:notredame/data/services/remote_config_service.dart';
import 'package:notredame/ui/schedule/schedule_controller.dart';
import 'package:notredame/ui/schedule/widgets/calendars/month_calendar.dart';
import '../../../../data/mocks/repositories/settings_repository_mock.dart';
import '../../../../data/mocks/services/schedule_service_mock.dart';
import '../../../../helpers.dart';

void main() {
  SharedPreferences.setMockInitialValues({});
  late SettingsRepositoryMock settingsManagerMock;
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

  group("month calendar view - ", () {
    setUp(() async {
      settingsManagerMock = setupSettingsRepositoryMock();
      scheduleServiceMock = setupScheduleServiceMock();
      setupCourseRepositoryMock();
      await setupAppIntl();
      setupNetworkingServiceMock();
      setupAnalyticsServiceMock();

      SettingsRepositoryMock.stubLocale(settingsManagerMock);
      ScheduleServiceMock.stubEvents(scheduleServiceMock, events);
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
      await tester.runAsync(() async {
        await tester.pumpWidget(localizedWidget(child: MonthCalendar(controller: ScheduleController())));
        await tester.pumpAndSettle();
      });

      expect(find.byType(FilledCell), findsExactly(42));
      expect(find.text("LOG100"), findsOneWidget);
      expect(find.text("ING150"), findsOneWidget);
    });

    // TODO add sheet test
  });
}
