// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:http/http.dart' as http;

// Project imports:
import 'package:notredame/data/models/hello/report.dart';
import 'package:notredame/data/services/hello/hello_service.dart';
import 'package:notredame/utils/command.dart';
import 'package:notredame/utils/http_exception.dart';

/// Call the Hello API to report a news
/// [newsId] The news id
/// [report] The report
class ReportNewsCommand implements Command<bool> {
  final HelloService client;
  final http.Client _httpClient;
  final String newsId;
  final Report report;

  ReportNewsCommand(this.client, this._httpClient, this.newsId, this.report);

  @override
  Future<bool> execute() async {
    if (client.apiLink == null || client.apiLink!.isEmpty) {
      throw ArgumentError("_apiLink is null or empty");
    }
    final uri = Uri.https(client.apiLink!, '/api/reports/$newsId');
    final response = await _httpClient.post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'reason': report.reason,
        'category': report.category,
      }),
    );

    // Log the http error and throw a exception
    if (response.statusCode != 200) {
      throw HttpException(
        message: response.body,
        prefix: HelloService.tagError,
        code: response.statusCode,
      );
    }

    return true;
  }
}
