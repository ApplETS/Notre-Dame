// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';

// Project imports:
import 'package:notredame/core/managers/news_repository.dart';
import 'package:notredame/core/managers/settings_manager.dart';
import 'package:notredame/core/models/news.dart';
import 'package:notredame/core/viewmodels/news_viewmodel.dart';
import 'package:notredame/locator.dart';
import '../helpers.dart';
import '../mock/managers/news_repository_mock.dart';

void main() {
  late NewsViewModel viewModel;
  late NewsRepositoryMock newsRepository;
  late AppIntl appIntl;

  final List<News> news = <News>[
    News(
      id: 1,
      title: "Mock News 1",
      description: "Test 1 description",
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
      author: "Author 2",
      avatar: "https://example.com/avatar2.jpg",
      activity: "Activity 2",
      image: "",
      tags: ["tag3", "tag4"],
      publishedDate: DateTime.parse('2022-02-01T12:00:00Z'),
      eventDate: DateTime.parse('2022-02-02T12:00:00Z'),
    )
  ];

  group('NewsViewModel tests', () {
    setUp(() async {
      newsRepository = setupNewsRepositoryMock();
      setupLogger();
      setupSettingsManagerMock();
      NewsRepositoryMock.stubNews(newsRepository, toReturn: news);
      appIntl = await setupAppIntl();
      viewModel = NewsViewModel(intl: appIntl);
    });

    tearDown(() {
      locator.unregister<Logger>();
      locator.unregister<NewsRepository>();
      locator.unregister<SettingsManager>();
    });

    test('Fetching news updates the news list', () async {
      expect(viewModel.isBusy, isFalse);

      await viewModel.futureToRun();

      expect(viewModel.news, hasLength(2));
      expect(viewModel.news[0].title, equals('Mock News 1'));
      expect(viewModel.news[1].title, equals('Mock News 2'));
      expect(viewModel.isBusy, isFalse);
    });
  });
}
