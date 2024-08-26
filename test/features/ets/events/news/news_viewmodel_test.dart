// Package imports:

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/features/app/repository/news_repository.dart';
import 'package:notredame/features/ets/events/api-client/models/news.dart';
import 'package:notredame/features/ets/events/api-client/models/organizer.dart';
import 'package:notredame/features/ets/events/api-client/models/paginated_news.dart';
import 'package:notredame/features/ets/events/news/news_viewmodel.dart';
import 'package:notredame/features/more/settings/settings_manager.dart';
import 'package:notredame/utils/locator.dart';
import '../../../../common/helpers.dart';
import '../../../app/repository/mocks/news_repository_mock.dart';

void main() {
  late NewsViewModel viewModel;
  late NewsRepositoryMock newsRepository;

  final List<News> news = <News>[
    News(
      id: "4627a622-f7c7-4ff9-9a01-50c69333ff42",
      title: 'Mock News 1',
      content: 'Mock Description 1',
      imageUrl: 'https://example.com/mock-image1.jpg',
      state: "1",
      publicationDate: DateTime.now().subtract(const Duration(days: 5)),
      eventStartDate: DateTime.now().add(const Duration(days: 2)),
      eventEndDate: DateTime.now().add(const Duration(days: 2, hours: 2)),
      organizer: Organizer(
        id: "e3e3e3e3-e3e3-e3e3-e3e3-e3e3e3e3e3e3",
        type: "organizer",
        organization: "Mock Organizer",
        email: "",
      ),
      tags: [],
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    News(
      id: "5627a622-f7c7-4ff9-9a01-50c69333ff42",
      title: 'Mock News 2',
      content: 'Mock Description 2',
      imageUrl: 'https://example.com/mock-image2.jpg',
      state: "1",
      publicationDate: DateTime.now().subtract(const Duration(days: 5)),
      eventStartDate: DateTime.now().add(const Duration(days: 2)),
      eventEndDate: DateTime.now().add(const Duration(days: 2, hours: 2)),
      organizer: Organizer(
        id: "e3e3e3e3-e3e3-e3e3-e3e3-e3e3e3e3e3e3",
        type: "organizer",
        organization: "Mock Organizer",
        email: "",
      ),
      tags: [],
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  final PaginatedNews paginatedNews = PaginatedNews(
      news: news, totalRecords: 2, totalPages: 2, pageNumber: 1, pageSize: 3);

  group('NewsViewModel tests', () {
    setUp(() async {
      newsRepository = setupNewsRepositoryMock();
      setupLogger();
      setupSettingsManagerMock();
      NewsRepositoryMock.stubGetNews(newsRepository, toReturn: paginatedNews);
      viewModel = NewsViewModel();
    });

    tearDown(() {
      locator.unregister<Logger>();
      locator.unregister<NewsRepository>();
      locator.unregister<SettingsManager>();
    });

    test('NewsViewModel fetch first page', () async {
      expect(viewModel.isBusy, isFalse);

      await viewModel.fetchPage(1);

      verify(newsRepository.getNews()).called(1);
      expect(viewModel.pagingController.nextPageKey, 2);
    });

    test('NewsViewModel fetch last page', () async {
      expect(viewModel.isBusy, isFalse);

      await viewModel.fetchPage(2);

      verify(newsRepository.getNews(pageNumber: 2)).called(1);
      expect(viewModel.pagingController.nextPageKey, 3);
    });
  });
}
