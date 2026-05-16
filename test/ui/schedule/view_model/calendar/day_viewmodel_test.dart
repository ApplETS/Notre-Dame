// Package imports:
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/data/repositories/course_activity_repository.dart';
import 'package:notredame/data/repositories/course_repository.dart';
import 'package:notredame/data/repositories/list_sessions_repository.dart';
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/data/services/signets-api/models/course.dart';
import 'package:notredame/domain/models/signets-api/course_activity.dart';
import 'package:notredame/domain/models/signets-api/session.dart';
import 'package:notredame/ui/schedule/view_model/calendars/day_viewmodel.dart';
import '../../../../helpers.dart';

class CourseActivityRepositoryMock extends Mock implements CourseActivityRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late DayViewModel viewModel;
  late CourseActivityRepositoryMock courseActivityRepositoryMock;

  setUp(() async {
    setupLogger();
    setupCourseRepositoryMock();
    setupSettingsRepositoryMock();
    setupListSessionsRepositoryMock();
    setupFlutterToastMock();

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

    ListSessionsRepositoryMock.stubGetActiveSession(setupListSessionsRepositoryMock(), session: activeSession);
    CourseRepositoryMock.stubGetCourses(setupCourseRepositoryMock(), toReturn: [
      Course(acronym: 'LOG100', group: '01', session: 'H2025', programCode: '999', numberOfCredits: 3, title: 'Programmation', teacherName: 'Prof X'),
    ]);
    SettingsRepositoryMock.stubGetLaboratoryGroup(setupSettingsRepositoryMock(), 'LOG100', toReturn: null);

    final List<CourseActivity> courseActivities = [
      CourseActivity(
        courseGroup: 'LOG100-01',
        startDate: DateTime.now().withoutTime,
        endDate: DateTime.now().withoutTime.add(const Duration(hours: 2)),
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

    viewModel = DayViewModel(intl: await setupAppIntl());
  });

  group('return to current date', () {
    test('updates daySelected', () {
      viewModel.daySelected = DateTime(2023, 10, 2);
      final result = viewModel.returnToCurrentDate();
      expect(result, true);
    });

    test('does not update daySelected', () {
      viewModel.daySelected = DateTime.now().withoutTime;
      final result = viewModel.returnToCurrentDate();
      expect(result, false);
    });
  });

  group('handle date selected changed', () {
    test('handleDateSelectedChanged updates events', () {
      viewModel.handleDateSelectedChanged(DateTime(2023, 10, 3));
      expect(viewModel.daySelected, DateTime(2023, 10, 3).withoutTime);
    });
  });

  group('today and tomorrow activities', () {
    test('getTodayActivities gets data', () async {
      final activities = await viewModel.getTodayActivities();
      expect(activities.length, 1);
      expect(activities.first.courseGroup, 'LOG100-01');
    });

    test('getTomorrowActivities gets data', () async {
      final activities = await viewModel.getTomorrowActivities();
      expect(activities.length, 1);
      expect(activities.first.courseGroup, 'LOG100-01');
    });
  });
}
