// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/data/services/launch_url_service.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/ui/dashboard/widgets/about_us_card.dart';
import '../../../helpers.dart';

void main() {
  late AppIntl intl;

  group("AboutUsCard - ", () {
    setUp(() async {
      intl = await setupAppIntl();
      setupLaunchUrlServiceMock();
    });

    tearDown(() {
      unregister<AppIntl>();
      unregister<LaunchUrlService>();
    });

    testWidgets('Has card aboutUs displayed properly', (WidgetTester tester) async {
      await tester.pumpWidget(
        localizedWidget(
          child: AboutUsCard(key: UniqueKey(), onDismissed: () {}),
        ),
      );
      await tester.pumpAndSettle();

      // Find aboutUs card
      final aboutUsCard = find.widgetWithText(Card, intl.card_applets_title);
      expect(aboutUsCard, findsOneWidget);

      // Find aboutUs card Text Paragraph
      final aboutUsParagraph = find.textContaining(intl.card_applets_text);
      expect(aboutUsParagraph, findsOneWidget);

      // Find aboutUs card Link Buttons
      final aboutUsLinkButtons = find.byType(IconButton);
      expect(aboutUsLinkButtons, findsNWidgets(5));
    });
  });
}
