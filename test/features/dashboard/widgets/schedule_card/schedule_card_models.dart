import 'package:notredame/features/app/signets-api/models/course_activity.dart';
import 'package:notredame/utils/activity_code.dart';

class ScheduleCardModels {
  final gen101 = CourseActivity(
      courseGroup: "GEN101",
      courseName: "Generic course",
      activityName: "TD",
      activityDescription: "Activity description",
      activityLocation: "location",
      startDateTime: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 9),
      endDateTime: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 12));

  final gen102 = CourseActivity(
      courseGroup: "GEN102",
      courseName: "Generic course",
      activityName: "TD",
      activityDescription: "Activity description",
      activityLocation: "location",
      startDateTime: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 13),
      endDateTime: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 16));

  final gen103 = CourseActivity(
      courseGroup: "GEN103",
      courseName: "Generic course",
      activityName: "TD",
      activityDescription: "Activity description",
      activityLocation: "location",
      startDateTime: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 18),
      endDateTime: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 21));

  final gen104LabA = CourseActivity(
      courseGroup: "GEN103",
      courseName: "Generic course",
      activityName: "TD",
      activityDescription: ActivityDescriptionName.labA,
      activityLocation: "location",
      startDateTime: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 18),
      endDateTime: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 21));

  final gen104LabB = CourseActivity(
      courseGroup: "GEN103",
      courseName: "Generic course",
      activityName: "TD",
      activityDescription: ActivityDescriptionName.labB,
      activityLocation: "location",
      startDateTime: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 18),
      endDateTime: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 21));

  final gen105 = CourseActivity(
      courseGroup: "GEN105",
      courseName: "Generic course",
      activityName: "TD",
      activityDescription: "Activity description",
      activityLocation: "location",
      startDateTime: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day + 1, 8),
      endDateTime: DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day + 1, 12));

  final gen106 = CourseActivity(
      courseGroup: "GEN106",
      courseName: "Generic course",
      activityName: "TD",
      activityDescription: "Activity description",
      activityLocation: "location",
      startDateTime: DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day + 1, 13),
      endDateTime: DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day + 1, 16));

  final gen107 = CourseActivity(
      courseGroup: "GEN107",
      courseName: "Generic course",
      activityName: "TD",
      activityDescription: "Activity description",
      activityLocation: "location",
      startDateTime: DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day + 2, 13),
      endDateTime: DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day + 2, 16));

  late List<CourseActivity> activities = [
    gen101, gen102, gen103, gen105, gen106, gen107
  ];

  late List<CourseActivity> todayActivities = [gen101, gen102, gen103];

  late List<CourseActivity> tomorrowActivities = [gen105, gen106];

  late List<CourseActivity> activitiesWithLabs = [
    gen101, gen102, gen103, gen104LabA, gen104LabB
  ];
}
