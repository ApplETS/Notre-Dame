// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/data/services/navigation_service.dart';
import 'package:notredame/data/services/signets-api/models/course_activity.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/ui/dashboard/widgets/course_activity_tile.dart';
import 'package:notredame/ui/dashboard/widgets/schedule_card.dart';
import '../../../data/mocks/repositories/settings_repository_mock.dart';
import '../../../helpers.dart';

main() {
  // Activities for today
  final gen101 = CourseActivity(
    courseGroup: "GEN101",
    courseName: "Generic course",
    activityName: "TD",
    activityDescription: "Activity description",
    activityLocation: "location",
    startDateTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 9),
    endDateTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 12),
  );

  final gen102 = CourseActivity(
    courseGroup: "GEN102",
    courseName: "Generic course",
    activityName: "TD",
    activityDescription: "Activity description",
    activityLocation: "location",
    startDateTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 13),
    endDateTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 16),
  );

  final gen103 = CourseActivity(
    courseGroup: "GEN103",
    courseName: "Generic course",
    activityName: "TD",
    activityDescription: "Activity description",
    activityLocation: "location",
    startDateTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 18),
    endDateTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 21),
  );

  final List<CourseActivity> activities = [gen101, gen102, gen103];
  late AppIntl intl;

  group("ScheduleCard - ", () {
    setUp(() async {
      intl = await setupAppIntl();
      setupNavigationServiceMock();
      final settingRepository = setupSettingsRepositoryMock();
      SettingsRepositoryMock.stubDateTimeNow(settingRepository, toReturn: DateTime.now());
    });

    tearDown(() {
      unregister<NavigationService>();
      unregister<SettingsRepository>();
    });

    Future<Widget> testDashboardSchedule(WidgetTester tester, List<CourseActivity> courses, int expected) async {
      await tester.pumpWidget(
        localizedWidget(
          child: ScheduleCard(onDismissed: () {}, events: courses, loading: false),
        ),
      );
      await tester.pumpAndSettle();

      return tester.firstWidget(
        find.descendant(of: find.byType(Dismissible, skipOffstage: false).at(0), matching: find.byType(Text)),
      );
    }

    testWidgets("Has card schedule displayed today's events properly", (WidgetTester tester) async {
      final scheduleTitle = await testDashboardSchedule(tester, activities, 3);

      expect((scheduleTitle as Text).data, intl.title_schedule);

      // Find three activities in the card
      expect(
        find.descendant(of: find.byType(Dismissible, skipOffstage: false), matching: find.byType(CourseActivityTile)),
        findsNWidgets(3),
      );
    });

    testWidgets("Has card schedule displayed tomorrow title properly when events are tomorrow", (
      WidgetTester tester,
    ) async {
      final now = DateTime.now();
      final gen104 = CourseActivity(
        courseGroup: "GEN104",
        courseName: "Generic course",
        activityName: "TD",
        activityDescription: "Activity description",
        activityLocation: "location",
        startDateTime: DateTime(now.year, now.month, now.day + 1, 9),
        endDateTime: DateTime(now.year, now.month, now.day + 1, 12),
      );

      final scheduleTitle = await testDashboardSchedule(tester, [gen104], 1);

      expect((scheduleTitle as Text).data, intl.title_schedule + intl.card_schedule_tomorrow);

      // Find one activities in the card
      expect(
        find.descendant(of: find.byType(Dismissible, skipOffstage: false), matching: find.byType(CourseActivityTile)),
        findsNWidgets(1),
      );
    });

    testWidgets("Has card schedule displayed no event when event list empty", (WidgetTester tester) async {
      final scheduleTitle = await testDashboardSchedule(tester, [], 1);
      expect((scheduleTitle as Text).data, intl.title_schedule);
    });

    testWidgets("Has card schedule loading properly", (WidgetTester tester) async {
      final scheduleTitle = await testDashboardSchedule(tester, [], 1);

      expect((scheduleTitle as Text).data, intl.title_schedule);
    });
  });
}
