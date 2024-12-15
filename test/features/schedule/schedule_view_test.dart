// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:notredame/data/services/calendar_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:notredame/domain/constants/preferences_flags.dart';
import 'package:notredame/data/services/analytics_service.dart';
import 'package:notredame/data/services/remote_config_service.dart';
import 'package:notredame/data/services/networking_service.dart';
import 'package:notredame/data/services/navigation_service.dart';
import 'package:notredame/data/repositories/course_repository.dart';
import 'package:notredame/data/services/signets-api/models/course_activity.dart';
import 'package:notredame/features/more/settings/settings_manager.dart';
import 'package:notredame/features/schedule/schedule_view.dart';
import 'package:notredame/features/schedule/widgets/schedule_settings.dart';
import '../../common/helpers.dart';
import '../app/analytics/mocks/remote_config_service_mock.dart';
import '../app/repository/mocks/course_repository_mock.dart';
import '../more/settings/mocks/settings_manager_mock.dart';

void main() {
  SharedPreferences.setMockInitialValues({});
  late SettingsManagerMock settingsManagerMock;
  late CourseRepositoryMock courseRepositoryMock;
  late RemoteConfigServiceMock remoteConfigServiceMock;

  // Some activities
  late CourseActivity activityToday;

  // Some settings
  Map<PreferencesFlag, dynamic> settings = {
    PreferencesFlag.scheduleCalendarFormat: CalendarTimeFormat.week,
    PreferencesFlag.scheduleShowTodayBtn: true
  };

  group("ScheduleView - ", () {
    setUpAll(() {
      DateTime today = DateTime(2020);
      today = today.subtract(Duration(
          hours: today.hour,
          minutes: today.minute,
          seconds: today.second,
          milliseconds: today.millisecond,
          microseconds: today.microsecond));

      activityToday = CourseActivity(
          courseGroup: "GEN101",
          courseName: "Generic course",
          activityName: "TD",
          activityDescription: "Activity description",
          activityLocation: "location",
          startDateTime: today,
          endDateTime: today.add(const Duration(hours: 4)));
    });

    setUp(() async {
      setupNavigationServiceMock();
      settingsManagerMock = setupSettingsManagerMock();
      courseRepositoryMock = setupCourseRepositoryMock();
      remoteConfigServiceMock = setupRemoteConfigServiceMock();
      setupNetworkingServiceMock();
      setupAnalyticsServiceMock();

      SettingsManagerMock.stubLocale(settingsManagerMock);

      settings = {
        PreferencesFlag.scheduleCalendarFormat: CalendarTimeFormat.week,
        PreferencesFlag.scheduleShowTodayBtn: true,
        PreferencesFlag.scheduleListView: true,
      };

      CourseRepositoryMock.stubGetScheduleActivities(courseRepositoryMock);
      RemoteConfigServiceMock.stubGetCalendarViewEnabled(
          remoteConfigServiceMock);
    });

    tearDown(() => {
          unregister<NavigationService>(),
          unregister<SettingsManager>(),
          unregister<CourseRepository>(),
          unregister<RemoteConfigService>(),
          unregister<NetworkingService>(),
          unregister<AnalyticsService>(),
        });
    group("interactions - ", () {
      testWidgets("tap on settings button to open the schedule settings",
          (WidgetTester tester) async {
        tester.view.physicalSize = const Size(800, 1410);

        CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock,
            toReturn: [activityToday]);
        CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock,
            fromCacheOnly: true);
        CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock);
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock,
            fromCacheOnly: true);
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock);
        SettingsManagerMock.stubGetScheduleSettings(settingsManagerMock,
            toReturn: settings);

        await tester.runAsync(() async {
          await tester.pumpWidget(localizedWidget(
              child: const ScheduleView()));
          await tester.pumpAndSettle();
        }).then((value) async {
          expect(find.byType(ScheduleSettings), findsNothing,
              reason: "The settings page should not be open");

          // Tap on the settings button
          await tester.tap(find.byIcon(Icons.settings_outlined));
          // Reload view
          await tester.pumpAndSettle();

          expect(find.byType(ScheduleSettings), findsOneWidget,
              reason: "The settings view should be open");
        });
      });
    });
  });
}
