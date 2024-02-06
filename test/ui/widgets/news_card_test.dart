// Package imports:
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notredame/core/models/news.dart';
import 'package:notredame/ui/widgets/news_card.dart';

// Project imports:
import '../../helpers.dart';

void main() {
  final news = News(
    id: 3,
    title: "Test 3",
    description: "Test 3 description",
    date: DateTime.now(),
    image: "",
    tags: [
      "tag1",
      "tag2",
    ],
  );

  group('News card Tests', () {
    setUpAll(() async {
      await setupAppIntl();
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
