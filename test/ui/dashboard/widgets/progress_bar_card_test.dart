import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notredame/ui/dashboard/widgets/progress_bar_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../helpers.dart';

void main() {
  late AppIntl intl;

  group("ProgressBarCard - ", () {
    setUp(() async {
      intl = await setupAppIntl();
    });

    testWidgets('Has card progressBar displayed',
        (WidgetTester tester) async {

      await tester.pumpWidget(localizedWidget(child: ProgressBarCard(
          onDismissed: () {},
          progressBarText: "progressBarText",
          changeProgressBarText: () {},
          progress: 0.5,
          loading: false
      )));
      await tester.pumpAndSettle();

      // Find progress card
      final progressCard = find.widgetWithText(Card, intl.progress_bar_title);
      expect(progressCard, findsOneWidget);

      // Find progress card Title
      final progressTitle = find.text(intl.progress_bar_title);
      expect(progressTitle, findsOneWidget);

      // Find progress card linearProgressBar
      final linearProgressBarFinder = find.byType(LinearProgressIndicator);
      expect(linearProgressBarFinder, findsOneWidget);

      final LinearProgressIndicator linearProgressBar = tester.widget<LinearProgressIndicator>(linearProgressBarFinder);
      expect(linearProgressBar.value, 0.5);
    });
  });
}