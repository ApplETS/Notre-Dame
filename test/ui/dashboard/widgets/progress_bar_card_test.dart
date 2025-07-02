// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/ui/dashboard/widgets/progress_bar_card.dart';
import '../../../helpers.dart';

void main() {
  late AppIntl intl;

  group("ProgressBarCard - ", () {
    setUp(() async {
      intl = await setupAppIntl();
    });

    testWidgets('Has card progressBar displayed', (WidgetTester tester) async {
      await tester.pumpWidget(
        localizedWidget(
          child: ProgressBarCard(
            progressBarText: "45",
            progress: 0.5,
            loading: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find progress card
      final progressCard = find.widgetWithText(Card, intl.progress_bar);
      expect(progressCard, findsOneWidget);
      
      // Find progress card linearProgressBar
      final linearProgressBarFinder = find.byType(CustomPaint);
      expect(linearProgressBarFinder, findsNWidgets(3));
    });
  });
}
