import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:notredame/core/managers/author_repository.dart';
import 'package:notredame/core/managers/news_repository.dart';
import 'package:notredame/core/models/author.dart';
import 'package:notredame/core/models/news.dart';
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
    id: 1,
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
      id: 1,
      title: "Mock News 1",
      description: "Test 1 description",
      authorId: 1,
      author: "Author 1",
      avatar: "https://example.com/avatar1.jpg",
      activity: "Activity 1",
      image: "",
      tags: ["tag1", "tag2"],
      publishedDate: DateTime.parse('2022-01-01T12:00:00Z'),
      eventDate: DateTime.parse('2022-01-02T12:00:00Z'),
    ),
    News(
      id: 2,
      title: "Mock News 2",
      description: "Test 2 description",
      authorId: 2,
      author: "Author 2",
      avatar: "https://example.com/avatar2.jpg",
      activity: "Activity 2",
      image: "",
      tags: ["tag3", "tag4"],
      publishedDate: DateTime.parse('2022-02-01T12:00:00Z'),
      eventDate: DateTime.parse('2022-02-02T12:00:00Z'),
    )
  ];

  group('AuthorViewModel tests', () {
    setUp(() async {
      authorRepository = setupAuthorRepositoryMock();
      newsRepository = setupNewsRepositoryMock();
      appIntl = await setupAppIntl();
      setupLogger();
      viewModel = AuthorViewModel(authorId: author.id, appIntl: appIntl);
    });

    tearDown(() {
      unregister<AuthorRepository>();
      unregister<NewsRepository>();
      unregister<Logger>();
    });

    test('Fetching author and news updates the author and news list', () async {
      AuthorRepositoryMock.stubFetchAuthorFromAPI(
          authorRepository, author.id, author);
      NewsRepositoryMock.stubFetchAuthorNewsFromAPI(newsRepository, author.id,
          toReturn: news);

      await viewModel.futureToRun();

      expect(viewModel.author, equals(author));
      expect(viewModel.news, equals(news));
      expect(viewModel.isBusy, isFalse);
    });

    test('Refresh method updates author and news list', () async {
      // Stub API calls to return updated author and news
      AuthorRepositoryMock.stubFetchAuthorFromAPI(
          authorRepository, author.id, author);
      NewsRepositoryMock.stubFetchAuthorNewsFromAPI(newsRepository, author.id,
          toReturn: news);

      await viewModel.refresh();

      // Verify that author and news are updated after refresh
      expect(viewModel.author, equals(author));
      expect(viewModel.news, equals(news));
    });
  });
}
