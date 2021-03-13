// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notredame/ui/views/dashboard_view.dart';
import '../../helpers.dart';

void main() {
  group('DashboardView - ', () {
    setUp(() async {
      setupNavigationServiceMock();
    });

    tearDown(() {});

    group('UI - ', () {
      testWidgets('Has view title and restore button, displayed',
          (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(child: const DashboardView()));
        await tester.pumpAndSettle();

        // Find Dashboard Title
        final dashboardTitle = find.descendant(
          of: find.byType(AppBar),
          matching: find.byType(Text),
        );
        expect(dashboardTitle, findsOneWidget);

        // Find restoreCards Button
        final restoreCardsIcon = find.byIcon(Icons.restore);
        expect(restoreCardsIcon, findsOneWidget);
      });

      testWidgets('Has card aboutUs displayed', (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(child: const DashboardView()));
        await tester.pumpAndSettle();

        // Find aboutUs card
        final aboutUsCard = find.byType(Card);
        expect(aboutUsCard, findsOneWidget);

        // Find aboutUs card Title
        final aboutUsTitle = find.text("ApplETS");
        expect(aboutUsTitle, findsOneWidget);

        // Find aboutUs card Text Paragraph
        final aboutUsParagraph =
            find.textContaining("ÉTSMobile was made by the club");
        expect(aboutUsParagraph, findsOneWidget);

        // Find aboutUs card Link Buttons
        final aboutUsLinkButtons = find.byType(TextButton);
        expect(aboutUsLinkButtons, findsNWidgets(3));

        expect(find.text("FACEBOOK"), findsOneWidget);
        expect(find.text("GITHUB"), findsOneWidget);
        expect(find.text("EMAIL"), findsOneWidget);
      });

      testWidgets('AboutUsCard is dismissible and can be restored',
          (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(child: const DashboardView()));
        await tester.pumpAndSettle();

        // Find Dismissible aboutUs Card
        expect(find.byType(Dismissible), findsOneWidget);

        // Swipe Dismissible aboutUs Card horizontally
        await tester.drag(find.byType(Dismissible), const Offset(1000.0, 0.0));

        // Check that the card is now absent from the view
        await tester.pumpAndSettle();
        expect(find.text("ApplETS"), findsNothing);

        // Tap the restoreCards button
        await tester.tap(find.byIcon(Icons.restore));
        await tester.pumpAndSettle();

        // Check that the card is now present in the view
        expect(find.text("ApplETS"), findsOneWidget);
      });
    });

    group("golden - ", () {
      testWidgets("default view", (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(800, 1410);

        await tester.pumpWidget(localizedWidget(child: const DashboardView()));
        await tester.pumpAndSettle();

        await expectLater(find.byType(DashboardView),
            matchesGoldenFile(goldenFilePath("dashboardView_1")));
      });
    });
  });
}
