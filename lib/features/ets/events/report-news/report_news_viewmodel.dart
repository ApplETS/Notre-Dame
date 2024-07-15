// Package imports:

import 'package:notredame/features/ets/events/api-client/hello_api_client.dart';
import 'package:notredame/features/ets/events/api-client/models/report.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/utils/locator.dart';

class ReportNewsViewModel extends BaseViewModel {
  final HelloAPIClient _helloApiClient = locator<HelloAPIClient>();

  void reportNews(String newsId, String category, String reason) {
    final Report report = Report(category: category, reason: reason);
    _helloApiClient.reportNews(newsId, report);
  }
}
