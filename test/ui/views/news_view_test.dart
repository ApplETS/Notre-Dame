// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/core/managers/course_repository.dart';
import 'package:notredame/core/managers/news_repository.dart';
import 'package:notredame/core/managers/settings_manager.dart';
import 'package:notredame/core/models/news.dart';
import 'package:notredame/core/models/tags.dart';
import 'package:notredame/core/services/analytics_service.dart';
import 'package:notredame/core/services/navigation_service.dart';
import 'package:notredame/core/services/networking_service.dart';
import 'package:notredame/ui/views/ets_view.dart';
import 'package:notredame/ui/views/news_view.dart';
import 'package:notredame/ui/widgets/base_scaffold.dart';
import 'package:notredame/ui/widgets/news_card.dart';
import '../../helpers.dart';
import '../../mock/managers/news_repository_mock.dart';

void main() {
  AppIntl intl;
  NewsRepositoryMock newsRepository;

  final List<News> news = <News>[
    News(
      id: 1,
      title:
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec tempus arcu sed quam tincidunt, non venenatis orci mollis.",
      description: "Test 1 description",
      date: DateTime.now(),
      image: null,
      tags: <Tag>[
        Tag(text: "tag1", color: Colors.blue),
        Tag(text: "tag2", color: Colors.green),
      ],
    ),
    News(
      id: 2,
      title: "Test 2",
      description: "Test 2 description",
      date: DateTime.now(),
      image: null,
      tags: <Tag>[
        Tag(text: "tag1", color: Colors.blue),
        Tag(text: "tag2", color: Colors.green),
      ],
    ),
    News(
      id: 3,
      title: "Test 3",
      description: "Test 3 description",
      date: DateTime.now(),
      image: null,
      tags: <Tag>[
        Tag(text: "tag1", color: Colors.blue),
        Tag(text: "tag2", color: Colors.green),
      ],
    ),
  ];

  final List<News> emptyNews = List<News>.empty();

  group('NewsView -', () {
    setUp(() async {
      intl = await setupAppIntl();
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
      await tester.pumpAndSettle(const Duration(seconds: 1));

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
