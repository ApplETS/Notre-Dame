// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/data/services/navigation_service.dart';
import 'package:notredame/data/services/signets-api/models/course_activity.dart';
import 'package:notredame/ui/dashboard/view_model/dashboard_viewmodel.dart';
import 'package:notredame/ui/dashboard/widgets/course_activity_tile.dart';
import 'package:notredame/ui/dashboard/widgets/schedule_card.dart';
import '../../../data/mocks/repositories/course_repository_mock.dart';
import '../../../data/mocks/repositories/settings_repository_mock.dart';
import '../../../helpers.dart';
import '../../schedule/view_model/schedule_settings_viewmodel_test.dart';

main() {
  // Activities for today
  final gen101 = CourseActivity(
      courseGroup: "GEN101",
      courseName: "Generic course",
      activityName: "TD",
      activityDescription: "Activity description",
      activityLocation: "location",
      startDateTime: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 9),
      endDateTime: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 12));

  final gen102 = CourseActivity(
      courseGroup: "GEN102",
      courseName: "Generic course",
      activityName: "TD",
      activityDescription: "Activity description",
      activityLocation: "location",
      startDateTime: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 13),
      endDateTime: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 16));

  final gen103 = CourseActivity(
      courseGroup: "GEN103",
      courseName: "Generic course",
      activityName: "TD",
      activityDescription: "Activity description",
      activityLocation: "location",
      startDateTime: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 18),
      endDateTime: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 21));

  final List<CourseActivity> activities = [gen101, gen102, gen103];

  group("ScheduleCard - ", () {
    setUp(() async {
      setupNavigationServiceMock();
    });

    tearDown(() {
      unregister<NavigationService>();
    });

    Future<Widget> testDashboardSchedule(WidgetTester tester, DateTime now,
        List<CourseActivity> courses, int expected) async {

      await tester.pumpWidget(localizedWidget(
          child: ScheduleCard(
              model: DashboardViewModel(intl: intl), onDismissed: () {})));
      await tester.pumpAndSettle();

      // Find schedule card in second position by its title
      return tester.firstWidget(find.descendant(
        of: find.byType(Dismissible, skipOffstage: false).at(1),
        matching: find.byType(Text),
      ));
    }

    testWidgets("Has card schedule displayed today's events properly",
        (WidgetTester tester) async {
      final now = DateTime.now();
      final simulatedDate = DateTime(now.year, now.month, now.day, 8);
      final scheduleTitle =
          await testDashboardSchedule(tester, simulatedDate, activities, 3);
      expect((scheduleTitle as Text).data, intl.title_schedule);

      // Find three activities in the card
      expect(
          find.descendant(
            of: find.byType(Dismissible, skipOffstage: false),
            matching: find.byType(CourseActivityTile),
          ),
          findsNWidgets(3));
    });

    testWidgets(
        "Has card schedule displayed tomorrow events properly after today's last event",
        (WidgetTester tester) async {
      final now = DateTime.now();
      final simulatedDate = DateTime(now.year, now.month, now.day, 21, 0, 1);
      final gen104 = CourseActivity(
          courseGroup: "GEN104",
          courseName: "Generic course",
          activityName: "TD",
          activityDescription: "Activity description",
          activityLocation: "location",
          startDateTime: DateTime(now.year, now.month, now.day + 1, 9),
          endDateTime: DateTime(now.year, now.month, now.day + 1, 12));
      final courses = List<CourseActivity>.from(activities)..add(gen104);
      final scheduleTitle =
          await testDashboardSchedule(tester, simulatedDate, courses, 1);
      expect((scheduleTitle as Text).data,
          intl.title_schedule + intl.card_schedule_tomorrow);

      // Find one activities in the card
      expect(
          find.descendant(
            of: find.byType(Dismissible, skipOffstage: false),
            matching: find.byType(CourseActivityTile),
          ),
          findsNWidgets(1));
    });

    testWidgets(
        "Has card schedule displayed no event when today's last activity is finished and no events the day after",
        (WidgetTester tester) async {
      final now = DateTime.now();
      final simulatedDate = DateTime(now.year, now.month, now.day, 21, 0, 1);

      final scheduleTitle =
          await testDashboardSchedule(tester, simulatedDate, activities, 1);
      expect((scheduleTitle as Text).data, intl.title_schedule);

      // Find no activity and no grade available text boxes
      expect(
          find.descendant(
            of: find.byType(SizedBox, skipOffstage: false),
            matching: find.byType(Text),
          ),
          findsNWidgets(2));
    });
  });
}
