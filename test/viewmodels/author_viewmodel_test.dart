// Package imports:
import 'package:ets_api_clients/models.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/core/managers/author_repository.dart';
import 'package:notredame/core/managers/news_repository.dart';
import 'package:notredame/core/models/author.dart';
import 'package:notredame/core/viewmodels/author_viewmodel.dart';
import '../helpers.dart';
import '../mock/managers/author_repository_mock.dart';
import '../mock/managers/news_repository_mock.dart';

void main() {
  late AuthorViewModel viewModel;
  late AuthorRepositoryMock authorRepository;
  late NewsRepositoryMock newsRepository;
  late AppIntl appIntl;

  final Author author = Author(
    id: "",
    organisation: "Mock Author",
    email: "author@example.com",
    description: "Test author description",
    activity: "Test author activity",
    website: "example.com",
    image: "https://example.com/author.jpg",
    socialLinks: [],
  );

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
      organizer: NewsUser(
        id: "e3e3e3e3-e3e3-e3e3-e3e3-e3e3e3e3e3e3",
        type: "organizer",
        organisation: "Mock Organizer",
        email: "",
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
        updatedAt: DateTime.now().subtract(const Duration(days: 180)),
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  final PaginatedNews paginatedNews = PaginatedNews(
      news: news, pageNumber: 1, pageSize: 3, totalRecords: 0, totalPages: 1);

  group('AuthorViewModel tests', () {
    setUp(() async {
      authorRepository = setupAuthorRepositoryMock();
      newsRepository = setupNewsRepositoryMock();
      appIntl = await setupAppIntl();
      setupLogger();
      AuthorRepositoryMock.stubFetchAuthorFromAPI(
          authorRepository, author.id, author);
      NewsRepositoryMock.stubGetNews(newsRepository, toReturn: paginatedNews);
      viewModel = AuthorViewModel(authorId: author.id, appIntl: appIntl);
    });

    tearDown(() {
      unregister<AuthorRepository>();
      unregister<NewsRepository>();
      unregister<Logger>();
    });

    test('Fetching author and news updates the author and news list', () async {
      viewModel.initialise();

      verify(authorRepository.fetchAuthorFromAPI(author.id)).called(1);
      expect(viewModel.author, equals(author));
    });
  });
}
