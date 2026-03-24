import 'package:calendar_view/calendar_view.dart';
import 'package:notredame/data/models/filters/filter.dart';
import 'package:notredame/domain/models/signets-api/course_activity.dart';

class CourseActivityFilter implements Filter<List<CourseActivity>> {
  final String? courseGroup;
  final DateTime? startDate;
  final DateTime? endDate;

  CourseActivityFilter({
    this.courseGroup,
    this.startDate,
    this.endDate,
  });

  @override
  List<CourseActivity> filterEmittedCache(List<CourseActivity> items) {
    return items.where((activity) {
      final matchesCourseGroup =
          courseGroup == null || activity.courseGroup == courseGroup;

      final matchesStartDate =
          startDate == null || activity.endDate.withoutTime.isAfter(startDate!);

      final matchesEndDate =
          endDate == null || activity.startDate.withoutTime.isBefore(endDate!);

      return matchesCourseGroup &&
          matchesStartDate &&
          matchesEndDate;
    }).toList();
  }

  @override
  List<CourseActivity> filterApiCached(List<CourseActivity> items) {
    // TODO: implement
    return items;
  }

}