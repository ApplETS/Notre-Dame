// Dart imports:
import 'dart:io';

// Flutter imports:
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
import 'package:notredame/core/models/news.dart';
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
        id: 1,
        title:
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec tempus arcu sed quam tincidunt, non venenatis orci mollis.",
        description: "Test 1 description",
        authorId: 1,
        author: "Author 1",
        avatar: "https://example.com/avatar1.jpg",
        activity: "Activity 1",
        image: "",
        tags: ["tag1", "tag2"],
        publishedDate: DateTime.parse('2022-01-01T12:00:00Z'),
        eventStartDate: DateTime.parse('2022-01-02T12:00:00Z'),
        eventEndDate: DateTime.parse('2022-01-02T12:00:00Z'),
        shareLink: "https://www.google.com"),
    News(
        id: 2,
        title: "Test 2",
        description: "Test 2 description",
        authorId: 2,
        author: "Author 2",
        avatar: "https://example.com/avatar2.jpg",
        activity: "Activity 2",
        image: "",
        tags: ["tag3", "tag4"],
        publishedDate: DateTime.parse('2022-02-01T12:00:00Z'),
        eventStartDate: DateTime.parse('2022-01-02T12:00:00Z'),
        eventEndDate: DateTime.parse('2022-01-02T12:00:00Z'),
        shareLink: "https://www.google.com"),
    News(
        id: 3,
        title: "Test 3",
        description: "Test 3 description",
        authorId: 3,
        author: "Author 3",
        avatar: "https://example.com/avatar3.jpg",
        activity: "Activity 3",
        image: "",
        tags: ["tag5", "tag6"],
        publishedDate: DateTime.parse('2022-02-01T12:00:00Z'),
        eventStartDate: DateTime.parse('2022-01-02T12:00:00Z'),
        eventEndDate: DateTime.parse('2022-01-02T12:00:00Z'),
        shareLink: "https://www.google.com"),
  ];

  final List<News> emptyNews = List<News>.empty();

  final Author author = Author(
      id: 1,
      organisation: "Capra",
      email: "capra@ens.etsmtl.ca",
      description:
          "Le club Capra fait la conception et la fabrication d’un robot de recherche et de sauvetage en milieux accidentés et participe à la compétition RoboCupRescue.",
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

      NewsRepositoryMock.stubFetchAuthorNewsFromAPI(newsRepository, author.id);
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
      NewsRepositoryMock.stubFetchAuthorNewsFromAPI(newsRepository, author.id,
          toReturn: emptyNews);

      await tester
          .pumpWidget(localizedWidget(child: AuthorView(authorId: author.id)));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify that the news list is empty
      expect(find.byType(NewsCard), findsNothing);
    });

    testWidgets('AuthorView - Loaded with News', (WidgetTester tester) async {
      NewsRepositoryMock.stubFetchAuthorNewsFromAPI(newsRepository, author.id,
          toReturn: news);

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
        NewsRepositoryMock.stubFetchAuthorNewsFromAPI(newsRepository, author.id,
            toReturn: emptyNews);
        tester.binding.window.physicalSizeTestValue = const Size(800, 1410);

        await tester.pumpWidget(
            localizedWidget(child: AuthorView(authorId: author.id)));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        await expectLater(find.byType(AuthorView),
            matchesGoldenFile(goldenFilePath("authorView_1")));
      });

      testWidgets("author view", (WidgetTester tester) async {
        NewsRepositoryMock.stubFetchAuthorNewsFromAPI(newsRepository, author.id,
            toReturn: news);
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
