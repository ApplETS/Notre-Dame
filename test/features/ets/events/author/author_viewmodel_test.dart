// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/features/app/repository/author_repository.dart';
import 'package:notredame/features/app/repository/news_repository.dart';
import 'package:notredame/features/ets/events/api-client/models/activity_area.dart';
import 'package:notredame/features/ets/events/api-client/models/news.dart';
import 'package:notredame/features/ets/events/api-client/models/news_tags.dart';
import 'package:notredame/features/ets/events/api-client/models/organizer.dart';
import 'package:notredame/features/ets/events/api-client/models/paginated_news.dart';
import 'package:notredame/features/ets/events/author/author_viewmodel.dart';
import '../../../../common/helpers.dart';
import '../../../app/repository/mocks/author_repository_mock.dart';
import '../../../app/repository/mocks/news_repository_mock.dart';

void main() {
  late AuthorViewModel viewModel;
  late AuthorRepositoryMock authorRepository;
  late NewsRepositoryMock newsRepository;
  late AppIntl appIntl;

  const organizerId = '1234';
  final organizer = Organizer(
    id: organizerId,
    name: 'Test Organizer',
    email: 'test@example.com',
    avatarUrl: 'https://example.com/avatar.png',
    type: 'type',
    organization: 'Test Organization',
    activityArea: ActivityArea(
        id: 'Test Area',
        nameEn: 'Test Area',
        nameFr: 'Test Area',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now()),
    isActive: true,
    profileDescription: 'Test Description',
    facebookLink: 'https://facebook.com/test',
    instagramLink: 'https://instagram.com/test',
    tikTokLink: 'https://tiktok.com/test',
    xLink: 'https://x.com/test',
    discordLink: 'https://discord.com/test',
    linkedInLink: 'https://linkedin.com/test',
    redditLink: 'https://reddit.com/test',
    webSiteLink: 'https://example.com',
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
      news: news, pageNumber: 1, pageSize: 3, totalRecords: 0, totalPages: 1);

  group('AuthorViewModel tests', () {
    setUp(() async {
      authorRepository = setupAuthorRepositoryMock();
      newsRepository = setupNewsRepositoryMock();
      appIntl = await setupAppIntl();
      setupLogger();
      AuthorRepositoryMock.stubGetOrganizer(
          authorRepository, organizerId, organizer);
      NewsRepositoryMock.stubGetNews(newsRepository, toReturn: paginatedNews);
      viewModel = AuthorViewModel(authorId: organizerId, appIntl: appIntl);
    });

    tearDown(() {
      unregister<AuthorRepository>();
      unregister<NewsRepository>();
      unregister<Logger>();
    });

    test('Fetching author and news updates the author and news list', () async {
      await viewModel.fetchAuthorData();

      verify(authorRepository.getOrganizer(organizerId)).called(1);
      expect(viewModel.author, equals(organizer));
    });
  });
}
