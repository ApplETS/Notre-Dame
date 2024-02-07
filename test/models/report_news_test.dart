// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/core/models/report_news.dart';

void main() {
  group('ReportNews class tests', () {
    test('ReportNews should initialize correctly', () {
      final reportNews = ReportNews(
        title: 'Report Title',
        description: 'Report Description',
      );

      expect(reportNews.title, equals('Report Title'));
      expect(reportNews.description, equals('Report Description'));
    });
  });
}
