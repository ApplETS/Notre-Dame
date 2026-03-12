// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/dashboard/widgets/cards/session_progress_card.dart';
import '../../../helpers.dart';

void main() {
  late AppIntl intl;

  group("SessionProgressCard - ", () {
    setUp(() async {
      intl = await setupAppIntl();
      setupListSessionsRepositoryMock();
    });

    tearDown(() {
      locator.reset();
    });

    testWidgets('Has card SessionProgressCard displayed without session', (WidgetTester tester) async {
      await tester.pumpWidget(
        localizedWidget(child: SessionProgressCard()),
      );
      await tester.pumpAndSettle();

      // Find progress card
      final progressCard = find.widgetWithText(Card, intl.session_without);
      expect(progressCard, findsOneWidget);
    });
  });
}
