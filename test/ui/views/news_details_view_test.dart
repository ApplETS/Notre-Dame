// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/core/models/news.dart';
import 'package:notredame/core/services/analytics_service.dart';
import 'package:notredame/core/services/navigation_service.dart';
import 'package:notredame/core/services/networking_service.dart';
import 'package:notredame/ui/views/news_details_view.dart';
import '../../helpers.dart';

void main() {
  late News sampleNews;

  setUp(() {
    setupNavigationServiceMock();
    setupAppIntl();
    setupAnalyticsServiceMock();
    setupNetworkingServiceMock();

    sampleNews = News(
        id: 1,
        title: 'Sample News Title',
        description: 'Sample News Description',
        authorId: 1,
        author: 'Sample Author',
        avatar: '',
        activity: 'Sample Activity',
        image: '',
        tags: ['sampleTag1', 'sampleTag2'],
        publishedDate: DateTime.parse('2022-01-01T12:00:00Z'),
        eventStartDate: DateTime.parse('2022-02-02T12:00:00Z'),
        eventEndDate: DateTime.parse('2022-02-02T12:00:00Z'),
        shareLink: "https://www.google.com");
  });

  tearDown(() {
    unregister<NavigationService>();
    unregister<AnalyticsService>();
    unregister<NetworkingService>();
  });

  group('NewsDetailsView Tests', () {
    testWidgets('Displays all news details correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          localizedWidget(child: NewsDetailsView(news: sampleNews)));
      await tester.pumpAndSettle();

      expect(find.text(sampleNews.title), findsOneWidget);
      expect(find.text(sampleNews.description), findsOneWidget);
      expect(find.text(sampleNews.author), findsOneWidget);
      expect(find.textContaining(sampleNews.activity), findsOneWidget);
      expect(find.byType(IconButton), findsWidgets);
    });

    group("golden - ", () {
      testWidgets("news details view", (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(800, 1410);

        await tester.pumpWidget(localizedWidget(
            child: NewsDetailsView(
          news: sampleNews,
        )));
        await tester.pumpAndSettle(const Duration(seconds: 1));

        await expectLater(find.byType(NewsDetailsView),
            matchesGoldenFile(goldenFilePath("newsDetailsView_1")));
      });
    }, skip: !Platform.isLinux);
  });
}
