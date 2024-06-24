// Dart imports:
import 'dart:io';

// Package imports:
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

// Project imports:
import 'package:notredame/features/ets/events/api-client/commands/get_events_command.dart';
import 'package:notredame/features/ets/events/api-client/commands/get_organizer_command.dart';
import 'package:notredame/features/ets/events/api-client/commands/report_news_command.dart';
import 'package:notredame/features/ets/events/api-client/models/organizer.dart';
import 'package:notredame/features/ets/events/api-client/models/paginated_news.dart';
import 'package:notredame/features/ets/events/api-client/models/report.dart';

/// A Wrapper for all calls to Hello API.
class HelloAPIClient {
  static const String tag = "HelloApi";
  static const String tagError = "$tag - Error";

  final http.Client _httpClient;

  String? apiLink;

  HelloAPIClient({http.Client? client})
      : _httpClient = client ?? IOClient(HttpClient());

  /// Call the Hello API to get the news
  /// [startDate] The start date of the news (optional)
  /// [endDate] The end date of the news (optional)
  /// [tags] The tags of the news (optional)
  /// [activityAreas] The activity areas of the news (optional)
  /// [organizerId] The organizer id (optional)
  /// [title] The news title (optional)
  /// [pageNumber] The page number (default: 1)
  /// [pageSize] The page size (default: 10)
  Future<PaginatedNews> getEvents({
    DateTime? startDate,
    DateTime? endDate,
    List<String>? tags,
    List<String>? activityAreas,
    String? organizerId,
    String? title,
    int pageNumber = 1,
    int pageSize = 10,
  }) {
    final command = GetEventsCommand(
      this,
      _httpClient,
      startDate: startDate,
      endDate: endDate,
      tags: tags,
      activityAreas: activityAreas,
      organizerId: organizerId,
      title: title,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
    return command.execute();
  }

  /// Call the Hello API to get the organizer
  /// [organizerId] The organizer id
  Future<Organizer?> getOrganizer(String organizerId) {
    final command = GetOrganizerCommand(this, _httpClient, organizerId);
    return command.execute();
  }

  /// Call the Hello API to report a news
  /// [newsId] The news id
  /// [report] The report
  Future<bool> reportNews(String newsId, Report report) {
    final command = ReportNewsCommand(this, _httpClient, newsId, report);
    return command.execute();
  }
}
