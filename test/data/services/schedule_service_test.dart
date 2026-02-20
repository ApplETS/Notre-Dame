// Package imports:
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:notredame/data/models/activity_code.dart';
import 'package:notredame/data/services/schedule_service.dart';
import 'package:notredame/data/services/signets-api/models/course.dart';
import 'package:notredame/data/services/signets-api/models/course_activity.dart';
import 'package:notredame/domain/constants/preferences_flags.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:notredame/data/repositories/course_repository.dart';
import 'package:notredame/data/repositories/settings_repository.dart';
import '../../helpers.dart';
import '../mocks/repositories/course_repository_mock.dart';
import '../mocks/repositories/settings_repository_mock.dart';

void main() {
  SharedPreferences.setMockInitialValues({});
  late SettingsRepositoryMock settingsManagerMock;
  late CourseRepositoryMock courseRepositoryMock;
  late ScheduleService service;

  final activityGen101LabA = CourseActivity(
    courseGroup: "GEN101",
    courseName: "Generic course",
    activityName: ActivityName.labA,
    activityDescription: "Activity description",
    activityLocation: ["D-2020"],
    startDateTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 9),
    endDateTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 12),
  );
  final activityGen101LabB = CourseActivity(
    courseGroup: "GEN101",
    courseName: "Generic course",
    activityName: ActivityName.labB,
    activityDescription: "Activity description",
    activityLocation: ["D-2020"],
    startDateTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 9),
    endDateTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 12),
  );
  final activityGen102 = CourseActivity(
    courseGroup: "GEN102",
    courseName: "Generic course",
    activityName: "TD",
    activityDescription: "Activity description",
    activityLocation: ["D-2020"],
    startDateTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 13),
    endDateTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 16),
  );
  final activityGen103 = CourseActivity(
    courseGroup: "GEN103",
    courseName: "Generic course",
    activityName: "TD",
    activityDescription: "Activity description",
    activityLocation: ["D-2020"],
    startDateTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 18),
    endDateTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 21),
  );

  final List<CourseActivity> activities = [activityGen101LabA, activityGen101LabB, activityGen102, activityGen103];

  final Course courseGen101 = Course(
    acronym: 'GEN101',
    group: '01',
    session: 'Irrelevant',
    programCode: '999',
    numberOfCredits: 3,
    title: 'Cours générique',
  );
  final Course courseGen102 = Course(
    acronym: 'GEN102',
    group: '01',
    session: 'Irrelevant',
    programCode: '999',
    numberOfCredits: 3,
    title: 'Cours générique',
  );
  final Course courseGen103 = Course(
    acronym: 'GEN103',
    group: '01',
    session: 'Irrelevant',
    programCode: '999',
    numberOfCredits: 3,
    title: 'Cours générique',
  );

  final courses = [courseGen101, courseGen102, courseGen103];

  group("Creates map - ", () {
    setUp(() {
      settingsManagerMock = setupSettingsRepositoryMock();
      courseRepositoryMock = setupCourseRepositoryMock();

      SettingsRepositoryMock.stubGetDynamicString(
        settingsManagerMock,
        PreferencesFlag.scheduleLaboratoryGroup,
        "GEN101",
        toReturn: ActivityCode.labGroupB,
      );

      CourseRepositoryMock.stubGetCourses(courseRepositoryMock, toReturn: courses);
      CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock, toReturn: activities);

      service = ScheduleService();
    });

    tearDown(() {
      unregister<SettingsRepository>();
      unregister<CourseRepository>();
    });

    test("filters lab A when lab group B is selected", () async {
      final result = await service.coursesActivities;

      final date = activityGen101LabA.startDateTime.withoutTime;

      expect(result[date], isNotNull);
      expect(result[date]!.any((e) => e.activityName == ActivityName.labA), false);
      expect(result[date]!.any((e) => e.activityName == ActivityName.labB), true);
    });

    test("groups activities by date", () async {
      final result = await service.coursesActivities;

      expect(result.length, 1);

      final date = activityGen101LabA.startDateTime.withoutTime;
      expect(result.containsKey(date), true);
    });

    test("sorts activities by start time", () async {
      final result = await service.coursesActivities;
      final date = activityGen101LabA.startDateTime.withoutTime;

      final activitiesSorted = result[date]!;

      for (int i = 0; i < activitiesSorted.length - 1; i++) {
        expect(activitiesSorted[i].startDateTime.isBefore(activitiesSorted[i + 1].startDateTime), true);
      }
    });

    test("creates EventData correctly from activities", () async {
      final result = await service.events;

      final date = activityGen101LabA.startDateTime.withoutTime;
      final events = result[date]!;

      final gen102Event = events.firstWhere((e) => e.courseAcronym == "GEN102");

      expect(gen102Event.courseAcronym, "GEN102");
      expect(gen102Event.group, "GEN102");
      expect(gen102Event.locations, ["D-2020"]);
      expect(gen102Event.startTime, activityGen102.startDateTime);
      expect(gen102Event.endTime, activityGen102.endDateTime);
    });

    test("uses cache when not invalidated", () async {
      await service.events;
      await service.events;

      verify(courseRepositoryMock.getCourses()).called(1);
    });

    test("refetches data when cache is invalidated", () async {
      await service.events;

      service.invalidateCache();

      await service.events;

      verify(courseRepositoryMock.getCourses()).called(2);
    });

    test("assigns a color to each unique course", () async {
      final result = await service.events;
      final date = activityGen101LabA.startDateTime.withoutTime;

      final events = result[date]!;

      final gen101Color = events.firstWhere((e) => e.courseAcronym == "GEN101").color;

      final gen102Color = events.firstWhere((e) => e.courseAcronym == "GEN102").color;

      expect(gen101Color, isNotNull);
      expect(gen102Color, isNotNull);
      expect(gen101Color != gen102Color, true);
    });
  });
}
