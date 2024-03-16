// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/core/managers/course_repository.dart';
import 'package:notredame/core/managers/news_repository.dart';
import 'package:notredame/core/managers/settings_manager.dart';
import 'package:notredame/core/models/news.dart';
import 'package:notredame/core/services/navigation_service.dart';
import 'package:notredame/core/services/networking_service.dart';
import 'package:notredame/ui/views/news_view.dart';
import 'package:notredame/ui/widgets/news_card.dart';
import '../../helpers.dart';
import '../../mock/managers/news_repository_mock.dart';

void main() {
  late NewsRepositoryMock newsRepository;

  final List<News> news = <News>[
    News(
      id: 1,
      title:
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec tempus arcu sed quam tincidunt, non venenatis orci mollis.",
      description: "Test 1 description",
      author: "Author 1",
      avatar: "https://example.com/avatar1.jpg",
      activity: "Activity 1",
      image: "",
      tags: ["tag1", "tag2"],
      publishedDate: DateTime.parse('2022-01-01T12:00:00Z'),
      eventStartDate: DateTime.parse('2022-02-02T12:00:00Z'),
      eventEndDate: DateTime.parse('2022-02-02T12:00:00Z'),
    ),
    News(
      id: 2,
      title: "Test 2",
      description: "Test 2 description",
      author: "Author 2",
      avatar: "https://example.com/avatar2.jpg",
      activity: "Activity 2",
      image: "",
      tags: ["tag3", "tag4"],
      publishedDate: DateTime.parse('2022-02-01T12:00:00Z'),
      eventStartDate: DateTime.parse('2022-02-02T12:00:00Z'),
      eventEndDate: DateTime.parse('2022-02-02T12:00:00Z'),
    ),
    News(
      id: 3,
      title: "Test 3",
      description: "Test 3 description",
      author: "Author 3",
      avatar: "https://example.com/avatar3.jpg",
      activity: "Activity 3",
      image: "",
      tags: ["tag5", "tag6"],
      publishedDate: DateTime.parse('2022-02-01T12:00:00Z'),
      eventStartDate: DateTime.parse('2022-02-02T12:00:00Z'),
      eventEndDate: DateTime.parse('2022-02-02T12:00:00Z'),
    ),
  ];

  final List<News> emptyNews = List<News>.empty();

  group('NewsView -', () {
    setUp(() async {
      await setupAppIntl();
      setupLogger();

      newsRepository = setupNewsRepositoryMock();
      setupNavigationServiceMock();
      setupNetworkingServiceMock();
      setupSettingsManagerMock();

      NewsRepositoryMock.stubGetNews(newsRepository, toReturn: news);
      NewsRepositoryMock.stubNews(newsRepository, toReturn: news);
    });

    tearDown(() {
      unregister<SettingsManager>();
      unregister<NewsRepository>();
      unregister<NavigationService>();
      unregister<CourseRepository>();
      unregister<NetworkingService>();
    });

    testWidgets('Empty news', (WidgetTester tester) async {
      NewsRepositoryMock.stubGetNews(newsRepository, toReturn: emptyNews);
      NewsRepositoryMock.stubNews(newsRepository, toReturn: emptyNews);

      await tester.pumpWidget(localizedWidget(child: NewsView()));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.byType(RefreshIndicator), findsOneWidget);

      expect(find.byType(ListView), findsOneWidget);

      expect(find.byType(NewsCard), findsNothing);
    });

    testWidgets('List of news', (WidgetTester tester) async {
      NewsRepositoryMock.stubGetNews(newsRepository, toReturn: news);
      NewsRepositoryMock.stubNews(newsRepository, toReturn: news);

      await tester.pumpWidget(localizedWidget(child: NewsView()));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.byType(RefreshIndicator), findsOneWidget);

      expect(find.byType(ListView), findsOneWidget);

      expect(find.byType(NewsCard), findsNWidgets(3));
    });

    group("golden - ", () {
      testWidgets("news view empty", (WidgetTester tester) async {
        NewsRepositoryMock.stubGetNews(newsRepository, toReturn: emptyNews);
        NewsRepositoryMock.stubNews(newsRepository, toReturn: emptyNews);

        tester.binding.window.physicalSizeTestValue = const Size(800, 1410);

        await tester.pumpWidget(localizedWidget(child: NewsView()));
        await tester.pumpAndSettle(const Duration(seconds: 1));

        await expectLater(find.byType(NewsView),
            matchesGoldenFile(goldenFilePath("newsView_1")));
      });

      testWidgets("news view", (WidgetTester tester) async {
        NewsRepositoryMock.stubGetNews(newsRepository, toReturn: news);
        NewsRepositoryMock.stubNews(newsRepository, toReturn: news);

        tester.binding.window.physicalSizeTestValue = const Size(800, 1410);

        await tester.pumpWidget(localizedWidget(child: NewsView()));
        await tester.pumpAndSettle(const Duration(seconds: 1));

        await expectLater(find.byType(NewsView),
            matchesGoldenFile(goldenFilePath("newsView_2")));
      });
    }, skip: !Platform.isLinux);
  });
}
