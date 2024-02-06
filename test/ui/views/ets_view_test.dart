// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/core/managers/course_repository.dart';
import 'package:notredame/core/managers/news_repository.dart';
import 'package:notredame/core/managers/settings_manager.dart';
import 'package:notredame/core/models/news.dart';
import 'package:notredame/core/services/analytics_service.dart';
import 'package:notredame/core/services/navigation_service.dart';
import 'package:notredame/core/services/networking_service.dart';
import 'package:notredame/ui/views/ets_view.dart';
import 'package:notredame/ui/widgets/base_scaffold.dart';
import '../../helpers.dart';
import '../../mock/managers/news_repository_mock.dart';

void main() {
  NewsRepositoryMock newsRepository;

  final List<News> news = <News>[
    News(
      id: 1,
      title:
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec tempus arcu sed quam tincidunt, non venenatis orci mollis.",
      description: "Test 1 description",
      date: DateTime.now(),
      image: "",
      tags: [
        "tag1",
        "tag2",
      ],
    ),
    News(
      id: 2,
      title: "Test 2",
      description: "Test 2 description",
      date: DateTime.now(),
      image: "",
      tags: [
        "tag1",
        "tag2",
      ],
    ),
    News(
      id: 3,
      title: "Test 3",
      description: "Test 3 description",
      date: DateTime.now(),
      image: "",
      tags: [
        "tag1",
        "tag2",
      ],
    ),
  ];

  group('ETSView -', () {
    setUp(() async {
      await setupAppIntl();
      setupLogger();

      newsRepository = setupNewsRepositoryMock();
      setupNavigationServiceMock();
      setupNetworkingServiceMock();
      setupAnalyticsServiceMock();
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
      unregister<AnalyticsService>();
    });

    testWidgets('has Tab bar and sliverAppBar and BaseScaffold',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          localizedWidget(child: FeatureDiscovery(child: ETSView())));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.byType(TabBar), findsOneWidget);

      expect(find.byType(SliverAppBar), findsOneWidget);

      expect(find.byType(BaseScaffold), findsOneWidget);
    });

    group("golden - ", () {
      testWidgets("default view", (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(800, 1410);

        await tester.pumpWidget(
            localizedWidget(child: FeatureDiscovery(child: ETSView())));
        await tester.pumpAndSettle(const Duration(seconds: 1));

        await expectLater(find.byType(ETSView),
            matchesGoldenFile(goldenFilePath("etsView_1")));
      });
    }, skip: !Platform.isLinux);
  });
}
