// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/core/models/news.dart';
import 'package:notredame/ui/widgets/news_card.dart';
import '../../helpers.dart';

void main() {
  final news = News(
    id: 1,
    title: "Test 3",
    description: "Test 3 description",
    authorId: 1,
    author: "Author 3",
    avatar: "https://example.com/avatar3.jpg",
    activity: "Activity 3",
    image: "",
    tags: ["tag5", "tag6"],
    publishedDate: DateTime.parse('2022-02-01T12:00:00Z'),
    eventDate: DateTime.parse('2022-02-02T12:00:00Z'),
  );

  group('News card Tests', () {
    setUpAll(() async {
      await setupAppIntl();
      setupNavigationServiceMock();
    });

    testWidgets('Displays a news card without an image',
        (WidgetTester tester) async {
      await tester.pumpWidget(localizedWidget(child: NewsCard(news)));
      await tester.pumpAndSettle();

      expect(find.text(news.title), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });
  });
}
