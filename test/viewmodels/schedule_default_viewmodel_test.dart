// Dart imports:
import 'dart:ui';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/features/app/repository/course_repository.dart';
import 'package:notredame/features/app/signets-api/models/schedule_activity.dart';
import 'package:notredame/features/schedule/schedule_default/schedule_default_viewmodel.dart';
import '../helpers.dart';

void main() {
  late CourseRepository mockCourseRepository;
  late ScheduleDefaultViewModel viewModel;
  late ScheduleActivity lectureActivity;
  late ScheduleActivity examActivity;

  group('ScheduleDefaultViewModel -', () {
    setUp(() {
      setupLogger();
      mockCourseRepository = setupCourseRepositoryMock();

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

      examActivity = ScheduleActivity(
          courseAcronym: 'COURSE101',
          courseGroup: '01',
          courseTitle: 'Intro to Dart',
          dayOfTheWeek: 2, // Tuesday
          day: 'Tuesday',
          startTime: DateTime(2023, 1, 1, 10),
          endTime: DateTime(2023, 1, 1, 11),
          activityCode: 'Exam',
          isPrincipalActivity: true,
          activityLocation: 'Room 202',
          name: 'Final Exam');

      viewModel = ScheduleDefaultViewModel(sessionCode: 'A2023');
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
        when(mockCourseRepository.getDefaultScheduleActivities(
                session: 'A2023'))
            .thenAnswer((_) async => [lectureActivity]);

        await viewModel.futureToRun();

        verify(mockCourseRepository.getDefaultScheduleActivities(
                session: 'A2023'))
            .called(1);
        expect(viewModel.isBusy, false);
        expect(viewModel.calendarEvents.length, equals(1));
      });

      test('Filters out exam activities', () async {
        when(mockCourseRepository.getDefaultScheduleActivities(
                session: 'A2023'))
            .thenAnswer((_) async => [examActivity]);

        await viewModel.futureToRun();

        expect(viewModel.calendarEvents, isEmpty);
      });
    });

    group('ScheduleDefaultViewModel - Additional Methods', () {
      // Test pour la méthode 'calendarEventData'
      test('calendarEventData returns correctly formatted CalendarEventData',
          () {
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
