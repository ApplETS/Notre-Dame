// Flutter imports:
import 'package:ets_api_clients/models.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/features/ets/events/news/news_card.dart';
import '../../helpers.dart';

void main() {
  final news = News(
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
