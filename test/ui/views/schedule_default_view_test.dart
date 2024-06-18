// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/features/app/repository/course_repository.dart';
import 'package:notredame/features/app/navigation/navigation_service.dart';
import 'package:notredame/features/app/integration/networking_service.dart';
import 'package:notredame/features/student/grades/schedule_default/schedule_default_view.dart';
import 'package:notredame/features/student/grades/schedule_default/schedule_default.dart';
import '../../helpers.dart';
import '../../mock/managers/course_repository_mock.mocks.dart';

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

    group("golden - ", () {
      testWidgets("default view", (WidgetTester tester) async {
        tester.view.physicalSize = const Size(800, 1410);

        when(mockCourseRepository.getDefaultScheduleActivities(
                session: "valid_session"))
            .thenAnswer((_) async => []);
        await tester.pumpWidget(localizedWidget(
            child: const ScheduleDefaultView(sessionCode: "A2024"),
            useScaffold: false));
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 500));

        await expectLater(find.byType(ScheduleDefaultView),
            matchesGoldenFile(goldenFilePath("scheduleDefaultView_1")));
      });

      /// TODO: add when https://github.com/SimformSolutionsPvtLtd/flutter_calendar_view/pull/343
      /// is merged
      // testWidgets("calendar view", (WidgetTester tester) async {
      //   tester.view.physicalSize = const Size(800, 1410);
      //
      //   when(mockCourseRepository.getDefaultScheduleActivities(
      //           session: "H2024"))
      //       .thenAnswer((_) async => [lectureActivity]);
      //
      //   await tester.pumpWidget(localizedWidget(
      //       child: const ScheduleDefaultView(sessionCode: "H2024"),
      //       useScaffold: false));
      //   await tester.pumpAndSettle();
      //   await tester.pump(const Duration(seconds: 2));
      //
      //   await expectLater(find.byType(ScheduleDefaultView),
      //       matchesGoldenFile(goldenFilePath("scheduleDefaultView_2")));
      // });
    }, skip: !Platform.isLinux);
  });
}
