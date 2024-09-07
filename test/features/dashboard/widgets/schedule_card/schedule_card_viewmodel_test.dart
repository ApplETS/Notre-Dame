import 'package:calendar_view/calendar_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:notredame/constants/preferences_flags.dart';
import 'package:notredame/features/app/repository/course_repository.dart';
import 'package:notredame/features/app/signets-api/models/course_activity.dart';
import 'package:notredame/features/dashboard/widgets/schedule_card/schedule_card_viewmodel.dart';
import 'package:notredame/features/more/settings/settings_manager.dart';
import 'package:notredame/utils/activity_code.dart';

import '../../../../common/helpers.dart';
import '../../../app/repository/mocks/course_repository_mock.dart';
import '../../../more/settings/mocks/settings_manager_mock.dart';
import 'schedule_card_models.dart';

void main() {
  group("ScheduleCardViewmodel", () {
    late CourseRepositoryMock courseRepository;
    late SettingsManagerMock settingsManager;
    late ScheduleCardViewmodel viewModel;
    late ScheduleCardModels models;

    setUp(() {
      courseRepository = setupCourseRepositoryMock();
      settingsManager = setupSettingsManagerMock();

      models = ScheduleCardModels();
      viewModel = ScheduleCardViewmodel();
    });

    tearDown(() => {
      unregister<CourseRepository>(),
      unregister<SettingsManager>()
    });
    
    group("futureToRun - ", () {
      test("should sort activities by increasing start time", () async {
        CourseRepositoryMock.stubGetCoursesActivities(courseRepository);
        CourseRepositoryMock.stubCoursesActivities(courseRepository,
            toReturn: models.activities);
        final now = DateTime.now();
        SettingsManagerMock.stubDateTimeNow(settingsManager,
            toReturn: DateTime(now.year, now.month, now.day, 8));

        final (type, events) = await viewModel.futureToRun();

        expect(type, ScheduleCardType.today);
        expect(events, models.todayActivities);

        verify(courseRepository.getCoursesActivities()).called(1);

        verify(courseRepository.coursesActivities).called(1);
      });

      test("should remove lab activity when lab group is set", () async {
            CourseRepositoryMock.stubGetCoursesActivities(courseRepository);
            CourseRepositoryMock.stubCoursesActivities(courseRepository,
                toReturn: models.activities);
            final now = DateTime.now();
            SettingsManagerMock.stubDateTimeNow(settingsManager,
                toReturn: DateTime(now.year, now.month, now.day, 12, 01));

            final (type, events) = await viewModel.futureToRun();

            final activitiesFinishedCourse =
            List<CourseActivity>.from(models.todayActivities)..remove(models.gen101);

            expect(type, ScheduleCardType.today);
            expect(events, activitiesFinishedCourse);

            verify(courseRepository.getCoursesActivities()).called(1);
            verify(courseRepository.coursesActivities).called(1);
          });

      test("should build the list tomorrow activities sorted by increasing start time", () async {
        CourseRepositoryMock.stubGetCoursesActivities(courseRepository);
        CourseRepositoryMock.stubCoursesActivities(courseRepository,
            toReturn: models.activities);
        final now = DateTime.now();
        SettingsManagerMock.stubDateTimeNow(settingsManager,
            toReturn: DateTime(now.year, now.month, now.day, 22));

        final (type, events) = await viewModel.futureToRun();

        expect(type, ScheduleCardType.tomorrow);
        expect(events, models.tomorrowActivities);

        verify(courseRepository.getCoursesActivities()).called(1);
        verify(courseRepository.coursesActivities).called(1);
      });

      test("should return none when events is null", () async {
        CourseRepositoryMock.stubCoursesActivities(courseRepository);
        CourseRepositoryMock.stubGetCoursesActivities(courseRepository, toReturn: null);

        final (type, events) = await viewModel.futureToRun();

        expect(type, ScheduleCardType.none);
        expect(events.isEmpty, true);

        verify(courseRepository.getCoursesActivities()).called(1);
        verify(courseRepository.coursesActivities).called(1);
      });

      test("should return none when no events", () async {
        CourseRepositoryMock.stubCoursesActivities(courseRepository);
        CourseRepositoryMock.stubGetCoursesActivities(courseRepository, toReturn: []);

        final (type, events) = await viewModel.futureToRun();

        expect(type, ScheduleCardType.none);
        expect(events.isEmpty, true);

        verify(courseRepository.getCoursesActivities()).called(1);
        verify(courseRepository.coursesActivities).called(1);
      });

      test("should return none when exception occurs", () async {
        CourseRepositoryMock.stubGetCoursesActivitiesException(courseRepository);

        final (type, events) = await viewModel.futureToRun();

        expect(type, ScheduleCardType.none);
        expect(events.isEmpty, true);

        verify(courseRepository.getCoursesActivities()).called(1);
      });
    });

    group("isLaboratoryGroupToAdd - ", () {
      test("activities should not include labo A when removing labo A",
          () async {
        CourseRepositoryMock.stubGetCoursesActivities(courseRepository);
        CourseRepositoryMock.stubCoursesActivities(courseRepository,
            toReturn: models.activitiesWithLabs);
        SettingsManagerMock.stubDateTimeNow(settingsManager,
            toReturn: DateTime.now().withoutTime);

        SettingsManagerMock.stubGetDynamicString(settingsManager,
            PreferencesFlag.scheduleLaboratoryGroup, "GEN101");

        SettingsManagerMock.stubGetDynamicString(settingsManager,
            PreferencesFlag.scheduleLaboratoryGroup, "GEN102");

        SettingsManagerMock.stubGetDynamicString(settingsManager,
            PreferencesFlag.scheduleLaboratoryGroup, "GEN103",
            toReturn: ActivityCode.labGroupB);

        final (type, events) = await viewModel.futureToRun();

        expect(type, ScheduleCardType.today);
        expect(events, [
          models.activitiesWithLabs[0],
          models.activitiesWithLabs[1],
          models.activitiesWithLabs[2],
          models.activitiesWithLabs[4]
        ]);
      });

      test("should not have labo B when removing labo B",
          () async {
        CourseRepositoryMock.stubGetCoursesActivities(courseRepository);
        CourseRepositoryMock.stubCoursesActivities(courseRepository,
            toReturn: models.activitiesWithLabs);
        SettingsManagerMock.stubDateTimeNow(settingsManager,
            toReturn: DateTime.now().withoutTime);

        SettingsManagerMock.stubGetDynamicString(settingsManager,
            PreferencesFlag.scheduleLaboratoryGroup, "GEN101");

        SettingsManagerMock.stubGetDynamicString(settingsManager,
            PreferencesFlag.scheduleLaboratoryGroup, "GEN102");

        SettingsManagerMock.stubGetDynamicString(settingsManager,
            PreferencesFlag.scheduleLaboratoryGroup, "GEN103",
            toReturn: ActivityCode.labGroupA);

        final (type, events) = await viewModel.futureToRun();

        expect(type, ScheduleCardType.today);
        expect(events, [
          models.activitiesWithLabs[0],
          models.activitiesWithLabs[1],
          models.activitiesWithLabs[2],
          models.activitiesWithLabs[3]
        ]);
      });

      test("should have both labs if no activity code to use",
          () async {
        CourseRepositoryMock.stubGetCoursesActivities(courseRepository);
        CourseRepositoryMock.stubCoursesActivities(courseRepository,
            toReturn: models.activitiesWithLabs);
        SettingsManagerMock.stubDateTimeNow(settingsManager,
            toReturn: DateTime.now().withoutTime);

        SettingsManagerMock.stubGetDynamicString(settingsManager,
            PreferencesFlag.scheduleLaboratoryGroup, "GEN101");

        SettingsManagerMock.stubGetDynamicString(settingsManager,
            PreferencesFlag.scheduleLaboratoryGroup, "GEN102");

        SettingsManagerMock.stubGetDynamicString(settingsManager,
            PreferencesFlag.scheduleLaboratoryGroup, "GEN103");

        final (type, events) = await viewModel.futureToRun();

        expect(type, ScheduleCardType.today);
        expect(events, models.activitiesWithLabs);
      });
    });
  });
}
