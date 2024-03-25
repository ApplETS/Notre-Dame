// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:ets_api_clients/models.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:notredame/core/managers/course_repository.dart';
import 'package:notredame/core/managers/news_repository.dart';
import 'package:notredame/core/managers/settings_manager.dart';
import 'package:notredame/core/models/author.dart';
import 'package:notredame/core/models/socialLink.dart';
import 'package:notredame/core/services/analytics_service.dart';
import 'package:notredame/core/services/launch_url_service.dart';
import 'package:notredame/core/services/navigation_service.dart';
import 'package:notredame/core/services/networking_service.dart';
import 'package:notredame/ui/views/author_view.dart';
import 'package:notredame/ui/widgets/news_card.dart';
import 'package:notredame/ui/widgets/social_links_card.dart';
import '../../helpers.dart';
import '../../mock/managers/author_repository_mock.dart';
import '../../mock/managers/news_repository_mock.dart';

void main() {
  late AuthorRepositoryMock authorRepository;
  late NewsRepositoryMock newsRepository;
  late AppIntl intl;

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

  final List<News> emptyNews = List<News>.empty();

  final Author author = Author(
      id: "1",
      organisation: "Capra",
      email: "capra@ens.etsmtl.ca",
      description:
          "Le club Capra fait la conception et la fabrication d'un robot.",
      activity: "Club scientifique",
      website: "capra.com",
      image: "",
      socialLinks: [
        SocialLink(id: 1, name: "discord", link: "facebook.com/capra"),
        SocialLink(id: 2, name: "linkedin", link: "facebook.com/capra"),
        SocialLink(id: 3, name: "email", link: "facebook.com/capra"),
        SocialLink(id: 4, name: "x", link: "facebook.com/capra"),
        SocialLink(id: 5, name: "tiktok", link: "facebook.com/capra"),
        SocialLink(id: 6, name: "facebook", link: "facebook.com/capra"),
        SocialLink(id: 7, name: "instagram", link: "facebook.com/capra"),
        SocialLink(id: 8, name: "reddit", link: "facebook.com/capra"),
      ]);

  final PaginatedNews paginatedNews = PaginatedNews(
      news: news, pageNumber: 1, pageSize: 3, totalRecords: 3, totalPages: 1);

  final PaginatedNews paginatedNewsEmpty = PaginatedNews(
      news: emptyNews,
      pageNumber: 1,
      pageSize: 3,
      totalRecords: 0,
      totalPages: 1);

  group('AuthorView -', () {
    setUp(() async {
      await setupAppIntl();
      setupLogger();

      intl = await setupAppIntl();
      authorRepository = setupAuthorRepositoryMock();
      newsRepository = setupNewsRepositoryMock();
      setupNavigationServiceMock();
      setupNetworkingServiceMock();
      setupSettingsManagerMock();
      setupAnalyticsServiceMock();
      setupLaunchUrlServiceMock();

      NewsRepositoryMock.stubGetNews(newsRepository, toReturn: paginatedNews);
      AuthorRepositoryMock.stubFetchAuthorFromAPI(
          authorRepository, author.id, author);

      AuthorRepositoryMock.stubAuthor(authorRepository, author);
    });

    tearDown(() {
      unregister<SettingsManager>();
      unregister<NewsRepository>();
      unregister<NavigationService>();
      unregister<CourseRepository>();
      unregister<NetworkingService>();
      unregister<AnalyticsService>();
      unregister<LaunchUrlService>();
    });

    testWidgets('Loaded with Author information', (WidgetTester tester) async {
      await tester
          .pumpWidget(localizedWidget(child: AuthorView(authorId: author.id)));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify that the back button is present
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      // Verify that the author information is displayed
      expect(find.text(author.organisation), findsOneWidget);
      expect(find.text(author.description), findsOneWidget);

      // Verify that the notify button is present
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('Notify button toggles text correctly',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(localizedWidget(child: AuthorView(authorId: author.id)));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Initially, the button should show "Notify Me"
      expect(find.text(intl.news_author_notify_me), findsOneWidget);

      // Tap the notify button
      await tester.tap(find.byType(TextButton));
      await tester.pump();

      // After tapping, the button should show "Don't Notify Me"
      expect(find.text(intl.news_author_dont_notify_me), findsOneWidget);
    });

    testWidgets('Social Links Modal', (WidgetTester tester) async {
      await tester
          .pumpWidget(localizedWidget(child: AuthorView(authorId: author.id)));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Tap the social links button
      await tester.tap(find.byType(FaIcon));
      await tester.pumpAndSettle();

      // Verify that the modal sheet is displayed
      expect(find.byType(SocialLinks), findsOneWidget);

      // Verify that the correct number of social links are displayed + 2 for the buttons already there
      expect(find.byType(IconButton),
          findsNWidgets(author.socialLinks.length + 2));
    });

    testWidgets('Empty News List', (WidgetTester tester) async {
      NewsRepositoryMock.stubGetNews(newsRepository,
          toReturn: paginatedNewsEmpty);

      await tester
          .pumpWidget(localizedWidget(child: AuthorView(authorId: author.id)));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify that the news list is empty
      expect(find.byType(NewsCard), findsNothing);
    });

    testWidgets('AuthorView - Loaded with News', (WidgetTester tester) async {
      NewsRepositoryMock.stubGetNews(newsRepository, toReturn: paginatedNews);

      await tester
          .pumpWidget(localizedWidget(child: AuthorView(authorId: author.id)));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify that the news cards are displayed
      expect(find.byType(NewsCard), findsNWidgets(news.length));

      // Verify that each news card displays the correct information
      for (final newsItem in news) {
        expect(find.text(newsItem.title), findsOneWidget);
      }
    });

    group("golden - ", () {
      testWidgets("author view news empty", (WidgetTester tester) async {
        NewsRepositoryMock.stubGetNews(newsRepository,
            toReturn: paginatedNewsEmpty);
        tester.binding.window.physicalSizeTestValue = const Size(800, 1410);

        await tester.pumpWidget(
            localizedWidget(child: AuthorView(authorId: author.id)));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        await expectLater(find.byType(AuthorView),
            matchesGoldenFile(goldenFilePath("authorView_1")));
      });

      testWidgets("author view", (WidgetTester tester) async {
        NewsRepositoryMock.stubGetNews(newsRepository, toReturn: paginatedNews);
        tester.binding.window.physicalSizeTestValue = const Size(800, 1410);

        await tester.pumpWidget(
            localizedWidget(child: AuthorView(authorId: author.id)));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        await expectLater(find.byType(AuthorView),
            matchesGoldenFile(goldenFilePath("authorView_2")));
      });
    }, skip: !Platform.isLinux);
  });
}
