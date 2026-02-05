// Dart imports:
import 'dart:ui';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/data/repositories/course_repository.dart';
import 'package:notredame/data/services/signets-api/models/schedule_activity.dart';
import 'package:notredame/ui/student/session_schedule/view_model/session_schedule_viewmodel.dart';
import '../../../../helpers.dart';

void main() {
  late CourseRepository mockCourseRepository;
  late SessionScheduleViewModel viewModel;
  late ScheduleActivity lectureActivity;
  late ScheduleActivity examActivity;
  late ScheduleActivity saturdayActivity;
  late ScheduleActivity sundayActivity;

  group('ScheduleDefaultViewModel -', () {
    setUp(() {
      setupLogger();
      mockCourseRepository = setupCourseRepositoryMock();

      lectureActivity = ScheduleActivity(
        courseAcronym: 'COURSE101',
        courseTitle: 'Intro to Dart',
        dayOfTheWeek: 2,
        startTime: DateTime(2023, 1, 1, 10),
        endTime: DateTime(2023, 1, 1, 11),
        activityCode: 'Lecture',
      );

      examActivity = ScheduleActivity(
        courseAcronym: 'COURSE101',
        courseTitle: 'Intro to Dart',
        dayOfTheWeek: 2,
        startTime: DateTime(2023, 1, 1, 10),
        endTime: DateTime(2023, 1, 1, 11),
        activityCode: 'Exam',
      );

      saturdayActivity = ScheduleActivity(
        courseAcronym: 'COURSE101',
        courseTitle: 'Intro to Dart',
        dayOfTheWeek: 6,
        startTime: DateTime(2023, 1, 5, 10),
        endTime: DateTime(2023, 1, 5, 11),
        activityCode: 'Lecture',
      );

      sundayActivity = ScheduleActivity(
        courseAcronym: 'COURSE101',
        courseTitle: 'Intro to Dart',
        dayOfTheWeek: 7,
        startTime: DateTime(2023, 1, 5, 10),
        endTime: DateTime(2023, 1, 5, 11),
        activityCode: 'Lecture',
      );

      viewModel = SessionScheduleViewModel(sessionCode: 'A2023');
    });

    tearDown(() {
      unregister<CourseRepository>();
    });

    test('Initial state', () {
      expect(viewModel.isBusy, false);
      expect(viewModel.calendarEvents, isEmpty);
    });

    group('futureToRun -', () {
      test('When called, sets busy state and fetches events', () async {
        when(
          mockCourseRepository.getDefaultScheduleActivities(session: 'A2023'),
        ).thenAnswer((_) async => [lectureActivity]);

        await viewModel.futureToRun();

        verify(mockCourseRepository.getDefaultScheduleActivities(session: 'A2023')).called(1);
        expect(viewModel.isBusy, false);
        expect(viewModel.displaySaturday, false);
        expect(viewModel.calendarEvents.length, equals(1));
      });

      test('Filters out exam activities', () async {
        when(
          mockCourseRepository.getDefaultScheduleActivities(session: 'A2023'),
        ).thenAnswer((_) async => [examActivity]);

        await viewModel.futureToRun();

        expect(viewModel.calendarEvents, isEmpty);
      });

      test('Sets displaySaturday to true', () async {
        when(
          mockCourseRepository.getDefaultScheduleActivities(session: 'A2023'),
        ).thenAnswer((_) async => [saturdayActivity]);

        await viewModel.futureToRun();
        expect(viewModel.displaySaturday, true);
      });

      test('Sets displaySunday to true', () async {
        when(
          mockCourseRepository.getDefaultScheduleActivities(session: 'A2023'),
        ).thenAnswer((_) async => [sundayActivity]);

        await viewModel.futureToRun();
        expect(viewModel.displaySunday, true);
      });
    });

    group('ScheduleDefaultViewModel - Additional Methods', () {
      // Test pour la méthode 'calendarEventData'
      test('calendarEventData returns correctly formatted CalendarEventData', () {
        final eventData = viewModel.calendarEventData(lectureActivity);

        expect(eventData.title, contains('COURSE101'));
        expect(eventData.color, isNotNull);
      });

      // Test pour la méthode 'getCourseColor'
      test('getCourseColor assigns and reuses colors for courses', () {
        final color1 = viewModel.getCourseColor('COURSE101');
        final color2 = viewModel.getCourseColor('COURSE102');
        final color1Again = viewModel.getCourseColor('COURSE101');

        expect(color1, isA<Color>());
        expect(color2, isA<Color>());
        expect(color1, equals(color1Again));
        // Vérifier que des couleurs différentes sont attribuées à des cours différents
        expect(color1, isNot(equals(color2)));
      });
    });
  });
}
