// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/data/models/activity_code.dart';
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/data/services/calendar_service.dart';
import 'package:notredame/data/services/signets-api/models/schedule_activity.dart';
import 'package:notredame/ui/schedule/schedule_controller.dart';
import 'package:notredame/ui/schedule/view_model/schedule_settings_viewmodel.dart';
import '../../../data/mocks/repositories/course_repository_mock.dart';
import '../../../data/mocks/repositories/settings_repository_mock.dart';
import '../../../helpers.dart';

late SettingsRepositoryMock settingsManagerMock;
late CourseRepositoryMock courseRepositoryMock;

late ScheduleSettingsViewModel viewModel;
ScheduleController controller = ScheduleController();

void main() {
  controller.settingsUpdated = () {};

  final List<ScheduleActivity> classOneWithLaboratoryABscheduleActivities = [
    ScheduleActivity(
      courseAcronym: "ABC123",
      courseTitle: "Sample Course",
      dayOfTheWeek: 1,
      startTime: DateFormat("hh:mm").parse("08:30"),
      endTime: DateFormat("hh:mm").parse("12:00"),
      activityCode: ActivityCode.lectureCourse,
    ),
    ScheduleActivity(
      courseAcronym: "ABC123",
      courseTitle: "Sample Course",
      dayOfTheWeek: 2,
      startTime: DateFormat("hh:mm").parse("13:30"),
      endTime: DateFormat("hh:mm").parse("15:00"),
      activityCode: ActivityCode.labGroupA,
    ),
    ScheduleActivity(
      courseAcronym: "ABC123",
      courseTitle: "Sample Course",
      dayOfTheWeek: 2,
      startTime: DateFormat("hh:mm").parse("15:00"),
      endTime: DateFormat("hh:mm").parse("16:30"),
      activityCode: ActivityCode.labGroupB,
    ),
  ];

  final List<ScheduleActivity> classTwoWithLaboratoryABscheduleActivities = [
    ScheduleActivity(
      courseAcronym: "XYZ321",
      courseTitle: "Sample Course",
      dayOfTheWeek: 1,
      startTime: DateFormat("hh:mm").parse("08:30"),
      endTime: DateFormat("hh:mm").parse("12:00"),
      activityCode: ActivityCode.lectureCourse,
    ),
    ScheduleActivity(
      courseAcronym: "XYZ321",
      courseTitle: "Sample Course",
      dayOfTheWeek: 2,
      startTime: DateFormat("hh:mm").parse("13:30"),
      endTime: DateFormat("hh:mm").parse("15:00"),
      activityCode: ActivityCode.labGroupA,
    ),
    ScheduleActivity(
      courseAcronym: "XYZ321",
      courseTitle: "Sample Course",
      dayOfTheWeek: 2,
      startTime: DateFormat("hh:mm").parse("15:00"),
      endTime: DateFormat("hh:mm").parse("16:30"),
      activityCode: ActivityCode.labGroupB,
    ),
  ];
  final List<ScheduleActivity> twoClassesWithLaboratoryABscheduleActivities = [];
  group("ScheduleSettingsViewModel - ", () {
    setUp(() {
      settingsManagerMock = setupSettingsRepositoryMock();
      courseRepositoryMock = setupCourseRepositoryMock();
      viewModel = ScheduleSettingsViewModel(controller: controller);

      twoClassesWithLaboratoryABscheduleActivities.addAll(classOneWithLaboratoryABscheduleActivities);
      twoClassesWithLaboratoryABscheduleActivities.addAll(classTwoWithLaboratoryABscheduleActivities);
    });

    tearDown(() {
      unregister<SettingsRepository>();
    });

    group("futureToRun - ", () {
      test("Fetches the activities", () async {
        await viewModel.futureToRun();
        verify(courseRepositoryMock.getScheduleActivities()).called(1);
        verifyNoMoreInteractions(courseRepositoryMock);
      });
    });

    group("laboratories - ", () {
      test(
        "If there is one valid class which has grouped laboratory, we parse it and store it (None selected)",
        () async {
          CourseRepositoryMock.stubGetScheduleActivities(
            courseRepositoryMock,
            toReturn: classOneWithLaboratoryABscheduleActivities,
          );

          final courseAcronymWithLaboratory = classOneWithLaboratoryABscheduleActivities.first.courseAcronym;

          SettingsRepositoryMock.stubGetLaboratoryGroup(settingsManagerMock, courseAcronymWithLaboratory);

          await viewModel.futureToRun();

          expect(viewModel.scheduleActivitiesByCourse.containsKey(courseAcronymWithLaboratory), true);
          expect(viewModel.scheduleActivitiesByCourse[courseAcronymWithLaboratory]!.length, 2);
          expect(viewModel.selectedScheduleActivity.containsKey(courseAcronymWithLaboratory), false);

          verify(courseRepositoryMock.getScheduleActivities()).called(1);
          verifyNoMoreInteractions(courseRepositoryMock);

          verify(settingsManagerMock.schedule.getLaboratoryGroup(courseAcronymWithLaboratory)).called(1);
        },
      );

      test(
        "If there is two valid class which has grouped laboratory, we store both (First => none selected, Second => group A selected)",
        () async {
          CourseRepositoryMock.stubGetScheduleActivities(
            courseRepositoryMock,
            toReturn: twoClassesWithLaboratoryABscheduleActivities,
          );

          final firstCourseAcronymWithLab = classOneWithLaboratoryABscheduleActivities.first.courseAcronym;

          final secondCourseAcronymWithLab = classTwoWithLaboratoryABscheduleActivities.first.courseAcronym;

          SettingsRepositoryMock.stubGetLaboratoryGroup(settingsManagerMock, firstCourseAcronymWithLab);
          SettingsRepositoryMock.stubGetLaboratoryGroup(
            settingsManagerMock,
            secondCourseAcronymWithLab,
            toReturn: ActivityCode.labGroupA,
          );

          await viewModel.futureToRun();

          expect(viewModel.scheduleActivitiesByCourse.keys.length, 2);
          expect(viewModel.scheduleActivitiesByCourse[firstCourseAcronymWithLab]!.length, 2);
          expect(viewModel.scheduleActivitiesByCourse[secondCourseAcronymWithLab]!.length, 2);
          expect(viewModel.selectedScheduleActivity.containsKey(firstCourseAcronymWithLab), false);
          expect(viewModel.selectedScheduleActivity.containsKey(secondCourseAcronymWithLab), true);
          expect(
            viewModel.selectedScheduleActivity[secondCourseAcronymWithLab],
            classTwoWithLaboratoryABscheduleActivities.firstWhere(
              (element) => element.activityCode == ActivityCode.labGroupA,
            ),
          );

          verify(courseRepositoryMock.getScheduleActivities()).called(1);
          verifyNoMoreInteractions(courseRepositoryMock);

          verify(settingsManagerMock.schedule.getLaboratoryGroup(firstCourseAcronymWithLab)).called(1);
          verify(settingsManagerMock.schedule.getLaboratoryGroup(secondCourseAcronymWithLab)).called(1);
        },
      );
    });

    group("settings - ", () {
      test("gets correct settings", () {
        SettingsRepositoryMock.stubScheduleCalendarFormat(settingsManagerMock, toReturn: CalendarTimeFormat.month);
        SettingsRepositoryMock.stubTodayButton(settingsManagerMock, toReturn: true);
        SettingsRepositoryMock.stubScheduleListView(settingsManagerMock, toReturn: false);

        CourseRepositoryMock.stubGetScheduleActivities(courseRepositoryMock, toReturn: []);

        expect(viewModel.calendarFormat, CalendarTimeFormat.month);
        expect(viewModel.showTodayBtn, true);
        expect(viewModel.listViewFormat, false);

        verify(settingsManagerMock.schedule.calendarFormat).called(1);
        verify(settingsManagerMock.schedule.todayButton).called(1);
        verify(settingsManagerMock.schedule.listView).called(1);

        verifyNoMoreInteractions(settingsManagerMock);
      });

      test("calendarFormat is updated", () {
        SettingsRepositoryMock.stubScheduleCalendarFormat(settingsManagerMock, toReturn: CalendarTimeFormat.month);

        viewModel.calendarFormat = CalendarTimeFormat.day;

        verify(settingsManagerMock.schedule.calendarFormat = CalendarTimeFormat.day).called(1);

        verifyNoMoreInteractions(settingsManagerMock);
      });

      test("calendarView is updated", () {
        SettingsRepositoryMock.stubScheduleListView(settingsManagerMock, toReturn: true);

        viewModel.listViewFormat = false;

        verify(settingsManagerMock.schedule.listView = false).called(1);

        verifyNoMoreInteractions(settingsManagerMock);
      });

      test("showTodayBtn is updated", () {
        SettingsRepositoryMock.stubTodayButton(settingsManagerMock, toReturn: false);

        viewModel.showTodayBtn = true;

        verify(settingsManagerMock.schedule.todayButton = true).called(1);

        verifyNoMoreInteractions(settingsManagerMock);
      });
    });
  });
}
