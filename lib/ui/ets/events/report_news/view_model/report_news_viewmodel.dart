// Package imports:
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/data/models/hello/report.dart';
import 'package:notredame/data/services/hello/hello_service.dart';
import 'package:notredame/locator.dart';

class ReportNewsViewModel extends BaseViewModel {
  final HelloService _helloApiClient = locator<HelloService>();

  void reportNews(String newsId, String category, String reason) {
    final Report report = Report(category: category, reason: reason);
    _helloApiClient.reportNews(newsId, report);
  }
}
