// Package imports:
import 'package:logger/logger.dart';

// Project imports:
import 'package:notredame/data/repositories/base_stream_repository.dart';
import 'package:notredame/data/services/signets_client_service.dart';
import 'package:notredame/domain/models/signets-api/course_activity.dart';
import 'package:notredame/locator.dart';

class CourseActivityRepository extends BaseStreamRepository<List<CourseActivity>> {
  static const String cacheKey = 'coursesActivitiesCache';
  static const String tag = "CourseActivityRepository";

  final _signetsClientService = locator<SignetsClientService>();
  final _logger = locator<Logger>();

  CourseActivityRepository() : super(cacheKey);

  Future<void> getCourseActivities(String session, String? courseGroup, DateTime? startDate, DateTime? endDate, {bool forceUpdate = false}) async {
    await fetch(() => _signetsClientService.getSchedule(session, courseGroup, startDate, endDate), CourseActivity.fromJson, forceUpdate: forceUpdate);
    if (value != null) {
      _logger.d("$tag - getCourseActivities: ${value!.length} course activities loaded.");
    }
  }

  
}
