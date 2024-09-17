// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/features/app/integration/networking_service.dart';
import 'package:notredame/features/app/navigation/navigation_service.dart';
import 'package:notredame/features/app/repository/course_repository.dart';
import 'package:notredame/features/app/repository/news_repository.dart';
import 'package:notredame/features/ets/events/api-client/models/news.dart';
import 'package:notredame/features/ets/events/api-client/models/news_tags.dart';
import 'package:notredame/features/ets/events/api-client/models/organizer.dart';
import 'package:notredame/features/ets/events/api-client/models/paginated_news.dart';
import 'package:notredame/features/ets/events/news/news_view.dart';
import 'package:notredame/features/ets/events/news/widgets/news_card.dart';
import 'package:notredame/features/more/settings/settings_manager.dart';
import '../../../../common/helpers.dart';
import '../../../app/repository/mocks/news_repository_mock.dart';

void main() {
  late NewsRepositoryMock newsRepository;

  final List<News> news = <News>[
    News(
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
    ),
  ];
  final PaginatedNews paginatedNews = PaginatedNews(
      news: news, pageNumber: 1, pageSize: 3, totalRecords: 3, totalPages: 1);

  final List<News> emptyNews = List<News>.empty();
  final PaginatedNews paginatedEmptyNews = PaginatedNews(
      news: emptyNews,
      pageNumber: 1,
      pageSize: 3,
      totalRecords: 0,
      totalPages: 1);

  group('NewsView -', () {
    setUp(() async {
      await setupAppIntl();
      setupLogger();

      newsRepository = setupNewsRepositoryMock();
      setupNavigationServiceMock();
      setupNetworkingServiceMock();
      setupSettingsManagerMock();

      NewsRepositoryMock.stubGetNews(newsRepository, toReturn: paginatedNews);
    });

    tearDown(() {
      unregister<SettingsManager>();
      unregister<NewsRepository>();
      unregister<NavigationService>();
      unregister<CourseRepository>();
      unregister<NetworkingService>();
    });

    testWidgets('Empty news', (WidgetTester tester) async {
      NewsRepositoryMock.stubGetNews(newsRepository,
          toReturn: paginatedEmptyNews);

      await tester.pumpWidget(localizedWidget(child: NewsView()));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.byType(RefreshIndicator), findsOneWidget);

      expect(find.byKey(const Key("pagedListView")), findsOneWidget);

      expect(find.byType(NewsCard), findsNothing);
    });

    testWidgets('List of news', (WidgetTester tester) async {
      NewsRepositoryMock.stubGetNews(newsRepository, toReturn: paginatedNews);

      await tester.pumpWidget(localizedWidget(child: NewsView()));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.byType(RefreshIndicator), findsOneWidget);

      expect(find.byKey(const Key("pagedListView")), findsOneWidget);

      expect(find.byType(NewsCard), findsNWidgets(1));
    });
  });
}
