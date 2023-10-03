// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/ui/widgets/dismissible_card.dart';
import '../../helpers.dart';

void main() {
  const String cardText = "I'm a dismissible card !";
  group("DismissibleCard - ", () {
    testWidgets("Display the card and the child widget",
        (WidgetTester tester) async {
      await tester.pumpWidget(localizedWidget(
          child: DismissibleCard(
              onDismissed: (DismissDirection direction) {},
              child: const Text(cardText))));

      await tester.pumpAndSettle();

      expect(find.text(cardText), findsOneWidget);
    });
    testWidgets("isBusy", (WidgetTester tester) async {
      await tester.pumpWidget(localizedWidget(
          child: DismissibleCard(
              isBusy: true,
              onDismissed: (DismissDirection direction) {},
              child: const Text(cardText))));

      expect(find.text(cardText), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
