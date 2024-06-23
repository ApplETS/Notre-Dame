// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:ets_api_clients/models.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:notredame/features/app/repository/course_repository.dart';
import 'package:notredame/features/app/repository/news_repository.dart';
import 'package:notredame/features/more/settings/settings_manager.dart';
import 'package:notredame/features/app/analytics/analytics_service.dart';
import 'package:notredame/features/app/integration/launch_url_service.dart';
import 'package:notredame/features/app/navigation/navigation_service.dart';
import 'package:notredame/features/app/integration/networking_service.dart';
import 'package:notredame/features/ets/events/author/author_view.dart';
import 'package:notredame/features/ets/events/news/widgets/news_card.dart';
import 'package:notredame/features/ets/events/social/social_links_card.dart';
import '../../helpers.dart';
import '../../mock/managers/author_repository_mock.dart';
import '../../mock/managers/news_repository_mock.dart';

void main() {
  late AuthorRepositoryMock authorRepository;
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

  final List<News> emptyNews = List<News>.empty();

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

      authorRepository = setupAuthorRepositoryMock();
      newsRepository = setupNewsRepositoryMock();
      setupNavigationServiceMock();
      setupNetworkingServiceMock();
      setupSettingsManagerMock();
      setupAnalyticsServiceMock();
      setupLaunchUrlServiceMock();

      NewsRepositoryMock.stubGetNews(newsRepository, toReturn: paginatedNews);
      AuthorRepositoryMock.stubGetOrganizer(
          authorRepository, organizerId, organizer);
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
      await tester.pumpWidget(
          localizedWidget(child: const AuthorView(authorId: organizerId)));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify that the back button is present
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      // Verify that the author information is displayed
      expect(find.text(organizer.organization ?? ""), findsOneWidget);
      expect(find.text(organizer.profileDescription ?? ""), findsOneWidget);

      // Verify that the notify button is present
      // expect(find.byType(TextButton), findsOneWidget);
    });

    // testWidgets('Notify button toggles text correctly',
    //     (WidgetTester tester) async {
    //   await tester.pumpWidget(
    //       localizedWidget(child: const AuthorView(authorId: organizerId)));
    //   await tester.pumpAndSettle(const Duration(seconds: 1));
    //
    //   // Initially, the button should show "Notify Me"
    //   expect(find.text(intl.news_author_notify_me), findsOneWidget);
    //
    //   // Tap the notify button
    //   await tester.tap(find.byType(TextButton));
    //   await tester.pump();
    //
    //   // After tapping, the button should show "Don't Notify Me"
    //   expect(find.text(intl.news_author_dont_notify_me), findsOneWidget);
    // });

    testWidgets('Social Links Modal', (WidgetTester tester) async {
      await tester.pumpWidget(
          localizedWidget(child: const AuthorView(authorId: organizerId)));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Tap the social links button
      await tester.tap(find.byType(FaIcon));
      await tester.pumpAndSettle();

      // Verify that the modal sheet is displayed
      expect(find.byType(SocialLinks), findsOneWidget);

      // Verify that the correct number of social links are displayed + 2 for the buttons already there
      expect(find.byType(IconButton), findsNWidgets(10));
    });

    testWidgets('Empty News List', (WidgetTester tester) async {
      NewsRepositoryMock.stubGetNewsOrganizer(newsRepository, organizerId,
          toReturn: paginatedNewsEmpty);

      await tester.pumpWidget(
          localizedWidget(child: const AuthorView(authorId: organizerId)));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify that the news list is empty
      expect(find.byType(NewsCard), findsNothing);
    });

    testWidgets('AuthorView - Loaded with News', (WidgetTester tester) async {
      NewsRepositoryMock.stubGetNewsOrganizer(newsRepository, organizerId,
          toReturn: paginatedNews);

      await tester.pumpWidget(
          localizedWidget(child: const AuthorView(authorId: organizerId)));
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
        NewsRepositoryMock.stubGetNewsOrganizer(newsRepository, organizerId,
            toReturn: paginatedNewsEmpty);
        tester.view.physicalSize = const Size(800, 1410);

        await tester.pumpWidget(
            localizedWidget(child: const AuthorView(authorId: organizerId)));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        await expectLater(find.byType(AuthorView),
            matchesGoldenFile(goldenFilePath("authorView_1")));
      });

      testWidgets("author view", (WidgetTester tester) async {
        NewsRepositoryMock.stubGetNewsOrganizer(newsRepository, organizerId,
            toReturn: paginatedNews);
        tester.view.physicalSize = const Size(800, 1410);

        await tester.pumpWidget(
            localizedWidget(child: const AuthorView(authorId: organizerId)));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        await expectLater(find.byType(AuthorView),
            matchesGoldenFile(goldenFilePath("authorView_2")));
      });
    }, skip: !Platform.isLinux);
  });
}
