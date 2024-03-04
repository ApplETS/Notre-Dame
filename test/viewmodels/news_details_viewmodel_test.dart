// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/core/models/news.dart';
import 'package:notredame/core/viewmodels/news_details_viewmodel.dart';
import 'package:notredame/ui/utils/app_theme.dart';

void main() {
  late NewsDetailsViewModel viewModel;
  final News mockNews = News(
      id: 1,
      title: "Test News",
      description: "Test Description",
      authorId: 1,
      author: "Test Author",
      avatar: "https://example.com/avatar.jpg",
      activity: "Test Activity",
      image: "https://example.com/image.jpg",
      tags: ["tag1", "tag2"],
      publishedDate: DateTime.parse('2022-01-01T12:00:00Z'),
      eventStartDate: DateTime.parse('2022-01-02T12:00:00Z'),
      eventEndDate: DateTime.parse('2022-01-02T12:00:00Z'),
      shareLink: "https://www.google.com");

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
