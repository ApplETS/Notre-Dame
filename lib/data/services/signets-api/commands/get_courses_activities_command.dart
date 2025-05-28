// Package imports:
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:xml/xml.dart';
import 'package:collection/collection.dart';

// Project imports:
import 'package:notredame/data/services/signets-api/models/course_activity.dart';
import 'package:notredame/data/services/signets-api/request_builder_service.dart';
import 'package:notredame/data/services/signets-api/signets_api_client.dart';
import 'package:notredame/utils/command.dart';

/// Call the SignetsAPI to get the courses activities for the [session] for
/// the student ([username]). By specifying [courseGroup] we can filter the
/// results to get only the activities for this course.
/// If the [startDate] and/or [endDate] are specified the results will contains
/// all the activities between these dates
class GetCoursesActivitiesCommand implements Command<List<CourseActivity>> {
  static const String endpoint = "/api/Etudiant/lireHoraireDesSeances";
  static const String responseTag = "ListeSeances";

  final SignetsAPIClient client;
  final http.Client _httpClient;
  final RegExp _sessionShortNameRegExp;
  final RegExp _courseGroupRegExp;
  final String token;
  final String session;
  final String courseGroup;
  final DateTime? startDate;
  final DateTime? endDate;

  GetCoursesActivitiesCommand(
    this.client,
    this._httpClient,
    this._sessionShortNameRegExp,
    this._courseGroupRegExp, {
    required this.token,
    required this.session,
    this.courseGroup = "",
    this.startDate,
    this.endDate,
  });

  @override
  Future<List<CourseActivity>> execute() async {
    // Validate the format of parameters
    if (!_sessionShortNameRegExp.hasMatch(session)) {
      throw FormatException("Session $session isn't a correctly formatted");
    }
    if (courseGroup.isNotEmpty && !_courseGroupRegExp.hasMatch(courseGroup)) {
      throw FormatException("CourseGroup $courseGroup isn't a correctly formatted");
    }
    if (startDate != null && endDate != null && startDate!.isAfter(endDate!)) {
      throw ArgumentError("The startDate can't be after endDate.");
    }

    final queryParams = {"session": session};

    if (courseGroup.isNotEmpty) queryParams["coursGroupe"] = courseGroup;

    final dateFormat = DateFormat('yyyy-MM-dd');
    if (startDate != null) {
      queryParams["dateDebut"] = dateFormat.format(startDate!);
    }
    if (endDate != null) {
      queryParams["dateFin"] = dateFormat.format(endDate!);
    }

    final responseBody = await RequestBuilderService.sendRequest(
      _httpClient,
      endpoint,
      token,
      responseTag,
      queryParameters: queryParams,
    );

    /// Build and return the list of CourseActivity
    List<CourseActivity> activities = responseBody.findAllElements("Seance").map((node) => CourseActivity.fromXmlNode(node)).toList();
    return mergeLocations(activities);
  }

  List<CourseActivity> mergeLocations(List<CourseActivity> activities) {
    final grouped = groupBy(activities, (CourseActivity a) =>
    '${a.courseGroup}‖${a.activityName}‖${a.startDateTime}‖${a.endDateTime}'
    );

    return grouped.values.map((bucket) {
      List<String> locations = [];
      for (CourseActivity item in bucket) {
        locations.addAll(item.activityLocation);
      }
      return bucket.first.copyWith(locations);
    }).toList();
  }
}
