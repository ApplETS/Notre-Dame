// Package imports:
import 'package:logger/logger.dart';

// Project imports:
import 'package:notredame/data/repositories/base_stream_repository.dart';
import 'package:notredame/data/services/signets_client_service.dart';
import 'package:notredame/domain/models/signets-api/course_activity.dart';
import 'package:notredame/locator.dart';

class CourseActivityRepository extends BaseStreamRepository<List<CourseActivity>> {
  static const String cacheKey = 'coursesActivitiesCache';
  static const String tag = 'CourseActivityRepository';

  final _signetsClientService = locator<SignetsClientService>();
  final _logger = locator<Logger>();

  CourseActivityRepository() : super(cacheKey);

  Future<void> getCourseActivities(
    String session, {
    String? courseGroup,
    DateTime? startDate,
    DateTime? endDate,
    bool forceUpdate = false,
  }) async {
    await fetch(
      () => _signetsClientService.getSchedule(
          session, courseGroup, startDate, endDate),
      CourseActivity.fromJson,
      forceUpdate: forceUpdate,
      filterEmittedCache: filterCache,
    );

    if (value != null) {
      _logger.d("$tag - getCourseActivities: ${value!.length} course activities loaded.");
    }
  }

  /// Helper that can be used outside of the repository to filter an
  /// arbitrary list of activities.  This no longer relies on the stored
  /// `value` property so it can be used by the caching logic as well as
  /// callers who just need to operate on a supplied list.
  List<CourseActivity> filterCache(
    List<CourseActivity> items, {
    String? courseGroup,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return items.where((activity) {
      final matchesCourseGroup =
          courseGroup == null || activity.courseGroup == courseGroup;

      final matchesStartDate =
          startDate == null || !activity.startDate.isAfter(startDate);

      final matchesEndDate =
          endDate == null || !activity.endDate.isBefore(endDate);

      return matchesCourseGroup &&
          matchesStartDate &&
          matchesEndDate;
    }).toList();
  }
  
}
