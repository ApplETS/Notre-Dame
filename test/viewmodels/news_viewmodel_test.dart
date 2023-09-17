// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// MANAGERS
import 'package:notredame/core/managers/settings_manager.dart';
import 'package:notredame/core/managers/news_repository.dart';

// MODEL
import 'package:notredame/core/models/news.dart';

// VIEWMODEL
import 'package:notredame/core/viewmodels/news_viewmodel.dart';

// UTILS
import 'package:notredame/locator.dart';
import 'package:logger/logger.dart';
import '../helpers.dart';

class MockNewsRepository extends Mock implements NewsRepository {
  @override
  List<News> get news => [
        News(
          id: 1,
          title: 'Mock News 1',
          description: 'Mock Description 1',
          image: 'https://example.com/mock-image1.jpg',
          tags: [],
          date: DateTime.now(),
          important: false,
        ),
        News(
          id: 2,
          title: 'Mock News 2',
          description: 'Mock Description 2',
          image: 'https://example.com/mock-image2.jpg',
          tags: [],
          date: DateTime.now(),
          important: true,
        ),
      ];

  static void stubGetNews(MockNewsRepository mock, List<News> newsList) {
    when(mock.getNews(fromCacheOnly: anyNamed('fromCacheOnly')))
        .thenAnswer((_) async => newsList);
  }
}

void main() {
  NewsViewModel viewModel;

  group('NewsViewModel tests', () {
    setUp(() {
      setupLogger();
      setupSettingsManagerMock();
      final mockNewsRepository = MockNewsRepository();
      MockNewsRepository.stubGetNews(mockNewsRepository, []);
      locator.registerSingleton<NewsRepository>(mockNewsRepository);
      viewModel = NewsViewModel(intl: null); // Pass null for AppIntl
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
