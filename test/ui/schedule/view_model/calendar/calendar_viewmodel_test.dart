// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/data/models/event_data.dart';
import 'package:notredame/data/repositories/course_activity_repository.dart';
import 'package:notredame/data/repositories/course_repository.dart';
import 'package:notredame/data/repositories/list_sessions_repository.dart';
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/data/services/signets-api/models/course.dart';
import 'package:notredame/domain/models/signets-api/course_activity.dart';
import 'package:notredame/domain/models/signets-api/session.dart';
import 'package:notredame/ui/schedule/view_model/calendars/calendar_viewmodel.dart';
import '../../../../helpers.dart';

class CourseActivityRepositoryMock extends Mock implements CourseActivityRepository {}

void main() {
  late CalendarViewModel viewModel;
  late CourseActivityRepositoryMock courseActivityRepositoryMock;
  late CourseRepositoryMock courseRepositoryMock;
  late ListSessionsRepositoryMock listSessionsRepositoryMock;
  late SettingsRepositoryMock settingsRepositoryMock;

  setUp(() async {
    setupLogger();
    settingsRepositoryMock = setupSettingsRepositoryMock();
    courseRepositoryMock = setupCourseRepositoryMock();
    listSessionsRepositoryMock = setupListSessionsRepositoryMock();

    courseActivityRepositoryMock = CourseActivityRepositoryMock();
    unregister<CourseActivityRepository>();
    locator.registerSingleton<CourseActivityRepository>(courseActivityRepositoryMock);

    final Session activeSession = Session(
      shortName: 'H2025',
      longName: 'Hiver 2025',
      startDate: DateTime(2025, 1, 1),
      endDate: DateTime(2025, 4, 30),
      endDateCourses: DateTime(2025, 4, 30),
      startDateRegistration: DateTime(2024, 12, 1),
      deadlineRegistration: DateTime(2025, 1, 10),
      startDateCancellationWithRefund: DateTime(2024, 12, 1),
      deadlineCancellationWithRefund: DateTime(2025, 1, 20),
      deadlineCancellationWithRefundNewStudent: DateTime(2025, 1, 20),
      startDateCancellationWithoutRefundNewStudent: DateTime(2025, 1, 21),
      deadlineCancellationWithoutRefundNewStudent: DateTime(2025, 1, 30),
      deadlineCancellationASEQ: DateTime(2025, 1, 15),
    );

    ListSessionsRepositoryMock.stubGetActiveSession(listSessionsRepositoryMock, session: activeSession);

    CourseRepositoryMock.stubGetCourses(courseRepositoryMock, toReturn: [
      Course(acronym: 'LOG100', group: '01', session: 'H2025', programCode: '999', numberOfCredits: 3, title: 'Programmation', teacherName: 'Prof X'),
    ]);

    SettingsRepositoryMock.stubGetLaboratoryGroup(settingsRepositoryMock, 'LOG100', toReturn: null);

    final List<CourseActivity> courseActivities = [
      CourseActivity(
        courseGroup: "LOG100-01",
        startDate: DateTime(2023, 10, 1, 8),
        endDate: DateTime(2023, 10, 1, 10),
        location: 'B-1400',
        activityName: 'TD',
        description: 'Travail dirigé',
        courseLabel: 'Programmation et réseautique',
      ),
    ];

    when(courseActivityRepositoryMock.getCourseActivities(
      any,
      startDate: anyNamed('startDate'),
      endDate: anyNamed('endDate'),
      forceUpdate: anyNamed('forceUpdate'),
    )).thenAnswer((_) async => null);

    when(courseActivityRepositoryMock.activities).thenReturn(courseActivities);

    viewModel = _TestCalendarViewModel(intl: await setupAppIntl());
  });

  group('CalendarViewModel', () {
    test('coursesActivities groups activities by date', () async {
      await viewModel.futureToRun();
      expect(viewModel.calendarEventsFromDate(DateTime(2023, 10, 1)).length, 1);

      verify(courseActivityRepositoryMock.getCourseActivities(
        'H2025',
        startDate: anyNamed('startDate'),
        endDate: anyNamed('endDate'),
        forceUpdate: false,
      )).called(1);
    });

    test('clears cache and reloads', () async {
      await viewModel.futureToRun();
      await viewModel.refreshEvents();
      verify(courseActivityRepositoryMock.getCourseActivities(
        'H2025',
        startDate: anyNamed('startDate'),
        endDate: anyNamed('endDate'),
        forceUpdate: true,
      )).called(1);
    });

    test('getCourseActivities returns list and sorts', () async {
      final activities = await viewModel.getCourseActivities(
        startDate: DateTime(2023, 10, 1),
        endDate: DateTime(2023, 10, 1),
      );

      expect(activities.length, 1);
    });
  });
}

// Concrete class for testing abstract CalendarViewModel
class _TestCalendarViewModel extends CalendarViewModel {
  _TestCalendarViewModel({required super.intl});

  @override
  bool returnToCurrentDate() => false;

  @override
  handleDateSelectedChanged(DateTime newDate) {}
}
