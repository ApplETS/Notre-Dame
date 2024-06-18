// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/features/ets/report-news/models/report_news.dart';

void main() {
  group('ReportNews class tests', () {
    test('ReportNews should initialize correctly', () {
      final reportNews = ReportNews(
        title: 'Report Title',
        description: 'Report Description',
        category: "1",
      );

      expect(reportNews.title, equals('Report Title'));
      expect(reportNews.description, equals('Report Description'));
      expect(reportNews.category, equals('1'));
    });
  });
}
