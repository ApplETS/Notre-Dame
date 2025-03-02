// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:calendar_view/calendar_view.dart' as calendar_view;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notredame/ui/schedule/widgets/calendars/month_calendar.dart';
import 'package:notredame/ui/schedule/widgets/calendars/week_calendar.dart';
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
import 'package:notredame/ui/schedule/widgets/schedule_calendar_tile.dart';
import '../../../../data/mocks/repositories/course_repository_mock.dart';
import '../../../../data/mocks/repositories/settings_repository_mock.dart';
import '../../../../helpers.dart';

void main() {
  SharedPreferences.setMockInitialValues({});
  late SettingsRepositoryMock settingsManagerMock;
  late CourseRepositoryMock courseRepositoryMock;
  late AppIntl intl;

  List<CourseActivity> activites = [
    CourseActivity(
      courseName: 'Lecture',
      startDateTime: DateTime.now().withoutTime.add(Duration(hours: 14)),
      endDateTime: DateTime.now().withoutTime.add(Duration(hours: 17)),
      courseGroup: 'ING150',
      activityLocation: 'Room 101',
      activityName: 'Lecture 1',
      activityDescription: 'Regular',
    ),
    CourseActivity(
      courseName: 'Lab',
      startDateTime: DateTime.now().withoutTime.add(Duration(hours: 9)),
      endDateTime: DateTime.now().withoutTime.add(Duration(hours: 12)),
      courseGroup: 'LOG100',
      activityLocation: 'Room 102',
      activityName: 'Lab Session',
      activityDescription: 'Regular',
    )
  ];

  group("month calendar view - ", () {
    setUp(() async {
      settingsManagerMock = setupSettingsManagerMock();
      courseRepositoryMock = setupCourseRepositoryMock();
      intl = await setupAppIntl();
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

    testWidgets("displays events", (WidgetTester tester) async {
      CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock);
      CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock,
          fromCacheOnly: true, toReturn: activites);
      CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock, toReturn: activites);

      await tester.runAsync(() async {
        await tester.pumpWidget(localizedWidget(
            child: MonthCalendar(
                controller: CalendarController())));
        await tester.pumpAndSettle();
      });

      expect(find.byType(calendar_view.FilledCell), findsExactly(42));
      expect(find.text("ING150\nRoom 101\nLecture 1"), findsOneWidget);
      expect(find.text("LOG100\nRoom 102\nLab Session"), findsOneWidget);

    });
  });
}
