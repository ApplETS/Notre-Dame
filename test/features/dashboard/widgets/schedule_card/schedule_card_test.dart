import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mockito/mockito.dart';

import 'package:notredame/features/app/navigation/navigation_service.dart';
import 'package:notredame/features/app/navigation/router_paths.dart';
import 'package:notredame/features/app/repository/course_repository.dart';
import 'package:notredame/features/app/signets-api/models/course_activity.dart';
import 'package:notredame/features/app/widgets/dismissible_card.dart';
import 'package:notredame/features/dashboard/widgets/course_activity_tile.dart';
import 'package:notredame/features/dashboard/widgets/schedule_card/schedule_card.dart';
import 'package:notredame/features/more/settings/settings_manager.dart';

import '../../../../common/helpers.dart';
import '../../../app/navigation/mocks/navigation_service_mock.dart';
import '../../../app/repository/mocks/course_repository_mock.dart';
import '../../../more/settings/mocks/settings_manager_mock.dart';
import 'schedule_card_models.dart';

void main() {
  late CourseRepositoryMock courseRepository;
  late SettingsManagerMock settingsManager;
  late NavigationServiceMock navigationService;
  late ScheduleCardModels models;
  late AppIntl intl;

  setUp(() async {
    courseRepository = setupCourseRepositoryMock();
    settingsManager = setupSettingsManagerMock();
    navigationService = setupNavigationServiceMock();
    models = ScheduleCardModels();
    intl = await setupAppIntl();
  });

  tearDown(() {
    unregister<CourseRepository>();
    unregister<SettingsManager>();
    unregister<NavigationService>();
  });

  Future testDashboardSchedule(WidgetTester tester, DateTime now,
      List<CourseActivity> courses, Function() dismissCard) async {
    CourseRepositoryMock.stubCoursesActivities(courseRepository,
        toReturn: courses);
    CourseRepositoryMock.stubGetCoursesActivities(courseRepository);

    SettingsManagerMock.stubDateTimeNow(settingsManager, toReturn: now);

    await tester.pumpWidget(localizedWidget(
        child: ScheduleCard(onDismissed: dismissCard, key: UniqueKey())));
    await tester.pumpAndSettle();
  }

  group("ScheduleCard - ", () {
    group("UI", () {
      testWidgets("Has card schedule displayed today's events properly",
          (WidgetTester tester) async {
        final now = DateTime.now();
        final simulatedDate = DateTime(now.year, now.month, now.day, 8);

        await testDashboardSchedule(tester, simulatedDate, models.todayActivities, () {});

        find.text(intl.title_schedule);

        // Find three activities in the card
        expect(find.byType(CourseActivityTile), findsNWidgets(3));
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

        final courses = List<CourseActivity>.from(models.todayActivities)..add(gen104);

        await testDashboardSchedule(tester, simulatedDate, courses, () {});

        find.text(intl.title_schedule + intl.card_schedule_tomorrow);
        expect(find.byType(CourseActivityTile), findsNWidgets(1));
      });

      testWidgets(
        "Has card schedule displayed no event when today's last activity is finished and no events the day after",
            (WidgetTester tester) async {
        final now = DateTime.now();
        final simulatedDate = DateTime(now.year, now.month, now.day, 21, 0, 1);

        await testDashboardSchedule(tester, simulatedDate, models.todayActivities, () {});

        find.text(intl.schedule_no_event);
        expect(find.byType(CourseActivityTile), findsNothing);
      });

      testWidgets("ScheduleCard is dismissible",
          (WidgetTester tester) async {
        final now = DateTime.now();
        final simulatedDate = DateTime(now.year, now.month, now.day, 21, 0, 1);

        bool isDismissed = false;

        await testDashboardSchedule(tester, simulatedDate, models.todayActivities, () { isDismissed = true; });

        // Swipe Dismissible progress Card horizontally
        final discardCard =
          find.widgetWithText(DismissibleCard, intl.title_schedule);
        await tester.ensureVisible(discardCard);
        await tester.drag(discardCard, const Offset(-1000.0, 0.0));
        await tester.pumpAndSettle();

        expect(isDismissed, true);
      });

      testWidgets("ScheduleCard reacts to click",
              (WidgetTester tester) async {
            final now = DateTime.now();
            final simulatedDate = DateTime(now.year, now.month, now.day, 0, 0, 1);

            await testDashboardSchedule(tester, simulatedDate, models.todayActivities, () { });

            // Swipe Dismissible progress Card horizontally
            final card = find.widgetWithText(Column, intl.title_schedule);

            await tester.tap(card);
            await tester.pumpAndSettle();

            verify(navigationService.pushNamedAndRemoveUntil(RouterPaths.schedule)).called(1);
          });
    });
  });
}
