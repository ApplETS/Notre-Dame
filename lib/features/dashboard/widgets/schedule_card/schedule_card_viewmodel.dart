import 'package:calendar_view/calendar_view.dart';
import 'package:stacked/stacked.dart';

import 'package:notredame/features/app/signets-api/models/course_activity.dart';
import 'package:notredame/features/app/repository/course_repository.dart';
import 'package:notredame/features/more/settings/settings_manager.dart';
import 'package:notredame/utils/locator.dart';
import 'package:notredame/constants/preferences_flags.dart';
import 'package:notredame/utils/activity_code.dart';

enum ScheduleCardType { none, today, tomorrow }

class ScheduleCardViewmodel extends FutureViewModel<(ScheduleCardType, List<CourseActivity>)> {
  final SettingsManager _settingsManager = locator<SettingsManager>();
  final CourseRepository _courseRepository = locator<CourseRepository>();

  @override
  Future<(ScheduleCardType, List<CourseActivity>)> futureToRun() async {
    try {
      await _courseRepository.getCoursesActivities();

      final courseActivities = _courseRepository.coursesActivities?.toList();

      if (courseActivities == null || courseActivities.isEmpty) {
        return (ScheduleCardType.none, <CourseActivity>[]);
      }

      final todayDate = _settingsManager.dateTimeNow;
      final tomorrowDate = todayDate
          .add(const Duration(days: 1))
          .withoutTime;
      final twoDaysFromToday = todayDate
          .add(const Duration(days: 2))
          .withoutTime;

      courseActivities.sort((a, b) =>
          a.startDateTime.compareTo(b.startDateTime));


      var cardType = ScheduleCardType.none;
      final events = <CourseActivity>[];

      for (final courseActivity in courseActivities) {
        if (courseActivity.startDateTime.isBefore(todayDate)) continue;
        if (twoDaysFromToday.isBefore(courseActivity.endDateTime.withoutTime)) {
          return (cardType, events);
        }

        if (todayDate.withoutTime == courseActivity.startDateTime.withoutTime &&
            await isLaboratoryGroupToAdd(courseActivity)) {
          cardType = ScheduleCardType.today;
          events.add(courseActivity);
        } else if (tomorrowDate == courseActivity.startDateTime.withoutTime) {
          if (cardType == ScheduleCardType.today) {
            return (cardType, events);
          }
          if (await isLaboratoryGroupToAdd(courseActivity)) {
            cardType = ScheduleCardType.tomorrow;
            events.add(courseActivity);
          }
        }
      }
      return (cardType, events);
    } catch (error) {
      onError(error);
    }
    return (ScheduleCardType.none, <CourseActivity>[]);
  }

  Future<bool> isLaboratoryGroupToAdd(CourseActivity courseActivity) async {
    final courseKey = courseActivity.courseGroup.split('-')[0];

    final activityCodeToUse = await _settingsManager.getDynamicString(
        PreferencesFlag.scheduleLaboratoryGroup, courseKey);

    if (activityCodeToUse == ActivityCode.labGroupA) {
      return courseActivity.activityDescription != ActivityDescriptionName.labB;
    } else if (activityCodeToUse == ActivityCode.labGroupB) {
      return courseActivity.activityDescription != ActivityDescriptionName.labA;
    }
    return true;
  }
}
