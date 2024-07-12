// Package imports:
import 'package:ets_api_clients/clients.dart';
import 'package:ets_api_clients/models.dart';
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
