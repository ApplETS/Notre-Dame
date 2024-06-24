// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:notredame/features/ets/events/api-client/models/news.dart';
import 'package:notredame/features/ets/events/api-client/models/news_tags.dart';
import 'package:notredame/features/ets/events/api-client/models/organizer.dart';

// Project imports:
import 'package:notredame/features/ets/events/news/news-details/news_details_viewmodel.dart';
import 'package:notredame/utils/app_theme.dart';

void main() {
  late NewsDetailsViewModel viewModel;
  final News mockNews = News(
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
  );

  group('NewsDetailsViewModel Tests', () {
    setUp(() {
      viewModel = NewsDetailsViewModel(news: mockNews);
    });

    test('futureToRun returns the correct News object', () async {
      final result = await viewModel.futureToRun();
      expect(result, isA<News>());
      expect(result.title, equals(mockNews.title));
    });

    test('getTagColor assigns unique colors to tags', () {
      final tag1Color = viewModel.getTagColor('tag1');
      final tag2Color = viewModel.getTagColor('tag2');

      // Verify that colors are assigned
      expect(tag1Color, isNotNull);
      expect(tag2Color, isNotNull);

      // Verify that colors are from the palette
      expect(AppTheme.tagsPalette.contains(tag1Color), isTrue);
      expect(AppTheme.tagsPalette.contains(tag2Color), isTrue);

      // Verify that each tag gets a unique color
      expect(tag1Color, isNot(equals(tag2Color)));
    });

    test('getTagColor reuses color for the same tag', () {
      final firstCallColor = viewModel.getTagColor('tag1');
      final secondCallColor = viewModel.getTagColor('tag1');

      expect(firstCallColor, equals(secondCallColor));
    });
  });
}
