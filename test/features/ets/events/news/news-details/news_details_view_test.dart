// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/features/app/analytics/analytics_service.dart';
import 'package:notredame/features/app/analytics/remote_config_service.dart';
import 'package:notredame/features/app/integration/networking_service.dart';
import 'package:notredame/features/app/navigation/navigation_service.dart';
import 'package:notredame/features/ets/events/api-client/models/news.dart';
import 'package:notredame/features/ets/events/api-client/models/news_tags.dart';
import 'package:notredame/features/ets/events/api-client/models/organizer.dart';
import 'package:notredame/features/ets/events/news/news-details/news_details_view.dart';
import '../../../../../common/helpers.dart';

// Package imports:

void main() {
  late News sampleNews;

  setUp(() {
    setupNavigationServiceMock();
    setupAppIntl();
    setupAnalyticsServiceMock();
    setupNetworkingServiceMock();
    setupRemoteConfigServiceMock();

    sampleNews = News(
      id: "4627a622-f7c7-4ff9-9a01-50c69333ff42",
      title: 'Mock News 1',
      content:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec tempus arcu sed quam tincidunt, non venenatis orci mollis. 1',
      state: "1",
      publicationDate: DateTime.now().subtract(const Duration(days: 5)),
      eventStartDate: DateTime.now().add(const Duration(days: 2)),
      eventEndDate: DateTime.now().add(const Duration(days: 2, hours: 2)),
      tags: <NewsTags>[
        NewsTags(
            id: 'e3e3e3e3-e3e3-e3e3-e3e3-e3e3e3e3e3e3',
            name: "tag 1",
            createdAt: DateTime.now().subtract(const Duration(days: 180)),
            updatedAt: DateTime.now().subtract(const Duration(days: 180))),
        NewsTags(
            id: 'faaaaaaa-e3e3-e3e3-e3e3-e3e3e3e3e3e3',
            name: "tag 2",
            createdAt: DateTime.now().subtract(const Duration(days: 180)),
            updatedAt: DateTime.now().subtract(const Duration(days: 180)))
      ],
      organizer: Organizer(
        id: "e3e3e3e3-e3e3-e3e3-e3e3-e3e3e3e3e3e3",
        type: "organizer",
        organization: "Mock Organizer",
        email: "",
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    );
  });

  tearDown(() {
    unregister<NavigationService>();
    unregister<AnalyticsService>();
    unregister<NetworkingService>();
    unregister<RemoteConfigService>();
  });

  group('NewsDetailsView Tests', () {
    testWidgets('Displays all news details correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          localizedWidget(child: NewsDetailsView(news: sampleNews)));
      await tester.pumpAndSettle();

      expect(find.text(sampleNews.title), findsOneWidget);
      expect(find.text(sampleNews.content), findsOneWidget);
      expect(find.text(sampleNews.organizer.organization!), findsOneWidget);
      expect(find.byType(IconButton), findsWidgets);
    });

    group("golden - ", () {
      testWidgets("news details view", (WidgetTester tester) async {
        tester.view.physicalSize = const Size(800, 1410);

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
