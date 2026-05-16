// Package imports:
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:notredame/data/models/filters/course_activity_filter.dart';

// Project imports:
import 'package:notredame/data/repositories/base_stream_repository.dart';
import 'package:notredame/data/services/signets_client_service.dart';
import 'package:notredame/domain/models/signets-api/course_activity.dart';
import 'package:notredame/locator.dart';

class CourseActivityRepository extends BaseStreamRepository<List<CourseActivity>> {
  static const String cacheKey = 'coursesActivitiesCache';
  static const String tag = 'CourseActivityRepository';
  
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  final _signetsClientService = locator<SignetsClientService>();
  final _logger = locator<Logger>();

  CourseActivityRepository() : super(cacheKey);

  /// Expose the in-memory course activities loaded by the repository.
  List<CourseActivity>? get activities => value;

  /// Get the schedule for a given session, course group, and date range
  /// [session] Short session (H2025, E2025, A2025), long session (Hiver 2025, Été 2025, Automne 2025), or digital session (20251, 20252, 20253).
  /// [courseGroup] Group courses in the acronym-group format, for example CHM131-01. If not specified, retrieves all group courses. 
  /// [startDate] Start date in the format YYYY-MM-DD. If not specified, retrieves all courses from the beginning of the session.
  /// [endDate] End date in the format YYYY-MM-DD. If not specified, retrieves all courses until the end of the session.
  /// For example, the [startDate] 2025-03-10 and [endDate] 2025-03-13 would retrieve all courses between March 11 and March 12, inclusive.
  Future<void> getCourseActivities(
    String session, {
    String? courseGroup,
    DateTime? startDate,
    DateTime? endDate,
    bool forceUpdate = false,
  }) async {
    String? startDateFormat = startDate != null ? _dateFormat.format(startDate) : null;
    String? endDateFormat = endDate != null ? _dateFormat.format(endDate) : null;



    CourseActivityFilter filter = CourseActivityFilter(
      courseGroup: courseGroup,
      startDate: startDate,
      endDate: endDate,
    );
    await fetch(
      () => _signetsClientService.getSchedule(
          session, courseGroup, startDateFormat, endDateFormat),
      CourseActivity.fromJson,
      forceUpdate: forceUpdate,
      filter: filter,
    );

    if (value != null) {
      _logger.d("$tag - getCourseActivities: ${value!.length} course activities loaded.");
    }
  }

  
  
}
