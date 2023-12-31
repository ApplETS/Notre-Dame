// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:ets_api_clients/models.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/core/managers/course_repository.dart';
import 'package:notredame/core/services/navigation_service.dart';
import 'package:notredame/core/services/networking_service.dart';
import 'package:notredame/ui/views/schedule_default_view.dart';
import 'package:notredame/ui/widgets/schedule_default.dart';
import '../../helpers.dart';

void main() {
  CourseRepository mockCourseRepository;
  ScheduleActivity lectureActivity;
  AppIntl intl;

  group('ScheduleDefaultView -', () {
    setUp(() async {
      intl = await setupAppIntl();
      setupLogger();

      setupNavigationServiceMock();
      mockCourseRepository = setupCourseRepositoryMock();
      setupNetworkingServiceMock();

      lectureActivity = ScheduleActivity(
          courseAcronym: 'COURSE101',
          courseGroup: '01',
          courseTitle: 'Intro to Dart',
          dayOfTheWeek: 2, // Tuesday
          day: 'Tuesday',
          startTime: DateTime(2023, 1, 1, 10),
          endTime: DateTime(2023, 1, 1, 11),
          activityCode: 'Lecture',
          isPrincipalActivity: true,
          activityLocation: 'Room 202',
          name: 'Lecture Session');
    });

    tearDown(() {
      unregister<NavigationService>();
      unregister<CourseRepository>();
      unregister<NetworkingService>();
    });

    testWidgets('ScheduleDefaultView has a title and shows schedule',
        (WidgetTester tester) async {
      await tester.pumpWidget(localizedWidget(
          child: const ScheduleDefaultView(sessionCode: "A2023")));
      await tester.pumpAndSettle();

      final fallSessionText = find.text("${intl.session_fall} 2023");
      expect(fallSessionText, findsOneWidget);
      expect(find.byType(ScheduleDefault), findsOneWidget);
    });

    group("golden - ", () {
      testWidgets("default view", (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(800, 1410);

        await tester.pumpWidget(localizedWidget(
            child: const ScheduleDefaultView(sessionCode: "A2023"),
            useScaffold: false));
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 500));

        await expectLater(find.byType(ScheduleDefaultView),
            matchesGoldenFile(goldenFilePath("scheduleDefaultView_1")));
      });

      testWidgets("calendar view", (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(800, 1410);

        when(mockCourseRepository.getDefaultScheduleActivities(
                session: anyNamed('session')))
            .thenAnswer((_) async => [lectureActivity]);

        await tester.pumpWidget(localizedWidget(
            child: const ScheduleDefaultView(sessionCode: "A2023"),
            useScaffold: false));
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 500));

        await expectLater(find.byType(ScheduleDefaultView),
            matchesGoldenFile(goldenFilePath("scheduleDefaultView_2")));
      });
    }, skip: !Platform.isLinux);
  });
}
